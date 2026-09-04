/*
 * Data-only recovery, never evaluation. Strings inside comments are not cargo.
 * Plain lists have an explicit grammar; malformed SQF never falls back to lists.
 */
params [["_text", "", [""]], ["_requestedName", "", [""]], ["_operation", [], [[]]]];
if (_text isEqualTo "") exitWith {[[], [], ["The clipboard is empty."]]};
private _characters = toArray _text;
private _plain = (_characters findIf {!(_x in [9,10,13,32,44] || {_x >= 48 && {_x <= 57}} || {_x >= 65 && {_x <= 90}} || {_x >= 97 && {_x <= 122}} || {_x isEqualTo 95})}) < 0;
private _values = [];
private _state = "NORMAL";
private _quote = 0;
private _buffer = [];
private _start = 0;
private _cancelled = false;
private _error = "";
if (_plain) then {
    _values = _text splitString (toString [9,10,13,32,44]);
} else {
    private _i = 0;
    while {_i < count _characters && {_error isEqualTo ""} && {!_cancelled}} do {
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
                        _values pushBack toString _buffer; _state = "NORMAL";
                    };
                } else {_buffer pushBack _c};
            };
        };
        _i = _i + 1;
    };
};
if (_cancelled) exitWith {[[], [], ["Import cancelled."]]};
if (_state in ["SINGLE","DOUBLE","BLOCKCOMMENT"]) exitWith {[[], [], [format ["Unterminated %1 beginning at character %2. Nothing was imported.", _state, _start]]]};
private _buckets = [[], [], [], []];
private _warnings = [];
private _seen = createHashMap;
private _missing = [];
private _ignored = 0;
{
    if ((_forEachIndex mod 256) isEqualTo 0 && {!([_operation, "Classifying recovered values", _forEachIndex, count _values] call RACA_fnc_importCheckpoint)}) exitWith {_cancelled = true};
    private _candidate = _x;
    private _isSqfIdentifier = (_candidate select [0,1]) isEqualTo "_" || {(_candidate find "_fnc_") >= 0};
    if ([_candidate] call RACA_fnc_isSafeClassName && {!_isSqfIdentifier}) then {
        private _key = toLowerANSI _candidate;
        if !(_seen getOrDefault [_key, false]) then {
            _seen set [_key, true];
            private _bucket = ([_candidate] call RACA_fnc_classifyCached) select 0;
            if (_bucket >= 0) then {(_buckets select _bucket) pushBack _candidate} else {
                // SQF has no bucket/schema for missing strings: report for review,
                // never silently invent an item classification.
                _missing pushBack _candidate;
            };
        };
    } else {_ignored = _ignored + 1};
} forEach _values;
if (_cancelled) exitWith {[[], [], ["Import cancelled."]]};
{_x sort true} forEach _buckets;
private _count = 0;
{_count = _count + count _x} forEach _buckets;
if (_count isEqualTo 0) exitWith {[[], [], ["No available arsenal classes were recovered. Use JSON to retain known unavailable cargo and metadata."]]};
if (!_plain) then {_warnings pushBack "Review recovered SQF strings: dynamic conditions and variable flow cannot be inferred. Comments are excluded."};
_warnings pushBack format ["Read %1 values; recovered %2 unique available classes; %3 unavailable candidates; %4 non-cargo values ignored.", count _values, _count, count _missing, _ignored];
{_warnings pushBack format ["Unavailable quoted class: %1", _x]} forEach _missing;
private _name = toString (((toArray _requestedName) select {_x >= 32 && {_x isNotEqualTo 127}}) select [0,128]);
if (_name isEqualTo "") then {_name = "Imported SQF Arsenal"};
[["RACA_PRESET", 1, _name, _buckets], [["RACA_SQF_REVIEW", 1, _missing]], _warnings]
