/*
 * Data-only recovery, never evaluation. Generic SQF strings are consumed as
 * they close; comments and irrelevant tokens are never retained as a corpus.
 */
params [["_text", "", [""]], ["_requestedName", "", [""]], ["_operation", [], [[]]]];
if (_text isEqualTo "") exitWith {[[], [], ["The clipboard is empty."]]};

private _telemetry = _operation param [4, createHashMap, [createHashMap]];
private _phaseStarted = diag_tickTime;
private _generated = [_text, _operation] call RACA_fnc_decodeGeneratedSqfLiteral;
_generated params ["_generatedMatched", "_generatedMalformed", "_generatedValues", "_generatedNotice"];
if (_generatedMalformed) exitWith {[[], [], [_generatedNotice]]};

private _buckets = [[], [], [], []];
private _seen = createHashMap;
private _missingSamples = [];
private _missingCount = 0;
private _readCount = 0;
private _candidateCount = 0;
private _ignored = 0;
private _cancelled = false;
private _filterSeconds = 0;
private _resolutionSeconds = 0;

private _consume = {
    params ["_candidate"];
    _readCount = _readCount + 1;
    private _filterStarted = diag_tickTime;
    private _isSqfIdentifier = (_candidate select [0,1]) isEqualTo "_" || {(_candidate find "_fnc_") >= 0};
    private _safe = [_candidate] call RACA_fnc_isSafeClassName && {!_isSqfIdentifier};
    private _key = if (_safe) then {toLowerANSI _candidate} else {""};
    private _new = _safe && {!(_seen getOrDefault [_key, false])};
    _filterSeconds = _filterSeconds + (diag_tickTime - _filterStarted);
    if (!_new) exitWith {_ignored = _ignored + 1};

    _seen set [_key, true];
    _candidateCount = _candidateCount + 1;
    if ((_candidateCount mod 256) isEqualTo 0 && {!([_operation, "Resolving catalogue classes", _candidateCount, _readCount max _candidateCount] call RACA_fnc_importCheckpoint)}) exitWith {
        _cancelled = true;
    };
    private _resolutionStarted = diag_tickTime;
    private _bucket = ([_candidate] call RACA_fnc_resolveCatalogClass) select 0;
    _resolutionSeconds = _resolutionSeconds + (diag_tickTime - _resolutionStarted);
    if (_bucket >= 0) then {
        (_buckets select _bucket) pushBack _candidate;
    } else {
        _missingCount = _missingCount + 1;
        if ((count _missingSamples) < 64) then {_missingSamples pushBack _candidate};
    };
};

private _plain = false;
private _state = "NORMAL";
private _start = 0;
if (_generatedMatched) then {
    {if (!_cancelled) then {[_x] call _consume}} forEach _generatedValues;
    _generatedValues = [];
} else {
    private _characters = toArray _text;
    _plain = (_characters findIf {!(_x in [9,10,13,32,44] || {_x >= 48 && {_x <= 57}} || {_x >= 65 && {_x <= 90}} || {_x >= 97 && {_x <= 122}} || {_x isEqualTo 95})}) < 0;
    if (_plain) then {
        {
            if ((_forEachIndex mod 256) isEqualTo 0 && {!([_operation, "Reading class list", _forEachIndex, count _characters] call RACA_fnc_importCheckpoint)}) exitWith {_cancelled = true};
            if (!_cancelled) then {[_x] call _consume};
        } forEach (_text splitString (toString [9,10,13,32,44]));
    } else {
        private _quote = 0;
        private _buffer = [];
        private _i = 0;
        while {_i < count _characters && {!_cancelled}} do {
            if ((_i mod 4096) isEqualTo 0) then {
                _cancelled = !([_operation, "Reading SQF", _i, count _characters] call RACA_fnc_importCheckpoint);
            };
            private _c = _characters select _i;
            private _next = _characters param [_i + 1, -1];
            switch (_state) do {
                case "NORMAL": {
                    if (_c isEqualTo 47 && {_next isEqualTo 47}) then {_state = "LINECOMMENT"; _i = _i + 1} else {
                        if (_c isEqualTo 47 && {_next isEqualTo 42}) then {_state = "BLOCKCOMMENT"; _start = _i; _i = _i + 1} else {
                            if (_c in [34,39]) then {
                                _state = ["SINGLE", "DOUBLE"] select (_c isEqualTo 34);
                                _quote = _c; _buffer = []; _start = _i;
                            };
                        };
                    };
                };
                case "LINECOMMENT": {if (_c in [10,13]) then {_state = "NORMAL"}};
                case "BLOCKCOMMENT": {if (_c isEqualTo 42 && {_next isEqualTo 47}) then {_state = "NORMAL"; _i = _i + 1}};
                default {
                    if (_c isEqualTo _quote) then {
                        if (_next isEqualTo _quote) then {_buffer pushBack _c; _i = _i + 1} else {
                            [toString _buffer] call _consume;
                            _buffer = [];
                            _state = "NORMAL";
                        };
                    } else {_buffer pushBack _c};
                };
            };
            _i = _i + 1;
        };
        _characters = [];
    };
};

if (_cancelled) exitWith {[[], [], ["Import cancelled."]]};
if (_state in ["SINGLE", "DOUBLE", "BLOCKCOMMENT"]) exitWith {
    [[], [], [format ["Unterminated %1 beginning at character %2. Nothing was imported.", _state, _start]]]
};

_telemetry set ["candidates", _candidateCount];
[_operation, "lexical_scan", _phaseStarted, [["candidates", _readCount]]] call RACA_fnc_importTelemetry;
[_operation, "candidate_filtering", diag_tickTime - _filterSeconds, [["candidates", _candidateCount]]] call RACA_fnc_importTelemetry;
private _available = 0;
{_available = _available + count _x} forEach _buckets;
[_operation, "catalogue_resolution", diag_tickTime - _resolutionSeconds, [["candidates", _candidateCount], ["available", _available], ["unavailable", _missingCount]]] call RACA_fnc_importTelemetry;
[_operation, "unavailable_handling", diag_tickTime, [["unavailable", _missingCount]]] call RACA_fnc_importTelemetry;

{_x sort true} forEach _buckets;
if (_available isEqualTo 0) exitWith {[[], [], ["No available arsenal classes were recovered. Use JSON to retain known unavailable cargo and metadata."]]};
private _warnings = [];
if (_generatedMatched) then {
    _warnings pushBack _generatedNotice;
} else {
    if (!_plain) then {_warnings pushBack "Review recovered SQF strings: dynamic conditions and variable flow cannot be inferred. Comments are excluded."};
};
_warnings pushBack format ["Read %1 values; recovered %2 unique available classes; %3 unavailable candidates; %4 duplicate or non-cargo values ignored.", _readCount, _available, _missingCount, _ignored];
{_warnings pushBack format ["Unavailable quoted class: %1", _x]} forEach _missingSamples;
if (_missingCount > count _missingSamples) then {
    _warnings pushBack format ["%1 additional unavailable candidates were omitted from this bounded review.", _missingCount - count _missingSamples];
};
[_operation, "preset_validation", diag_tickTime, [["available", _available], ["unavailable", _missingCount], ["warnings", count _warnings]]] call RACA_fnc_importTelemetry;

private _name = toString (((toArray _requestedName) select {_x >= 32 && {_x isNotEqualTo 127}}) select [0,128]);
if (_name isEqualTo "") then {_name = "Imported SQF Arsenal"};
[["RACA_PRESET", 1, _name, _buckets], [["RACA_SQF_REVIEW", 1, _missingSamples, _missingCount]], _warnings]
