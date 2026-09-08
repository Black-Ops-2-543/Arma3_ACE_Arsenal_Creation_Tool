/*
 * Data-only recovery, never evaluation. Generic SQF strings are consumed as
 * they close; comments and irrelevant tokens are never retained as a corpus.
 */
params [["_text", "", [""]], ["_requestedName", "", [""]], ["_operation", [], [[]]]];
if (_text isEqualTo "") exitWith {[[], [], ["The clipboard is empty."]]};

private _telemetry = _operation param [4, createHashMap, [createHashMap]];
private _resourcePolicy = call RACA_fnc_getImportResourcePolicy;
private _maxLiteralCharacters = _resourcePolicy get "maxLiteralCharacters";
private _maxGenericCandidates = _resourcePolicy get "maxGenericCandidates";
private _maxUnavailableSamples = _resourcePolicy get "maxUnavailableSamples";
private _maxWarningRows = _resourcePolicy get "maxWarningRows";
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
private _resourceError = "";

private _consume = {
    params ["_candidate"];
    _readCount = _readCount + 1;
    if (!_generatedMatched && {!_plain} && {_readCount > _maxGenericCandidates}) exitWith {
        _resourceError = format ["Generic recovery candidate resource exceeded: more than %1 quoted/list values were scanned. Use portable JSON, a plain class list, or a narrowed migration source.", _maxGenericCandidates];
    };
    private _filterStarted = diag_tickTime;
    private _key = toLowerANSI _candidate;
    // Only safe classes enter _seen, so a known case-insensitive key can skip
    // repeated identifier validation and catalogue resolution immediately.
    // Duplicate-heavy legacy arsenals otherwise pay the full validation cost
    // for every repeated token even though only the first can affect output.
    if (_seen getOrDefault [_key, false]) exitWith {
        _ignored = _ignored + 1;
        _filterSeconds = _filterSeconds + (diag_tickTime - _filterStarted);
    };
    private _isSqfIdentifier = (_candidate select [0,1]) isEqualTo "_" || {(_candidate find "_fnc_") >= 0};
    private _safe = [_candidate] call RACA_fnc_isSafeClassName && {!_isSqfIdentifier};
    if (!_safe) exitWith {
        _ignored = _ignored + 1;
        _filterSeconds = _filterSeconds + (diag_tickTime - _filterStarted);
    };

    _seen set [_key, true];
    _filterSeconds = _filterSeconds + (diag_tickTime - _filterStarted);
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
        if ((count _missingSamples) < _maxUnavailableSamples) then {_missingSamples pushBack _candidate};
    };
};

private _plain = false;
private _state = "NORMAL";
private _start = 0;
if (_generatedMatched) then {
    {if (!_cancelled && {_resourceError isEqualTo ""}) then {[_x] call _consume}} forEach _generatedValues;
    _generatedValues = [];
} else {
    private _textLength = count _text;
    private _scanOffset = 0;
    _plain = true;
    while {_plain && {_scanOffset < _textLength}} do {
        private _scanCharacters = toArray (_text select [_scanOffset, 65536]);
        _plain = (_scanCharacters findIf {
            !(_x in [9,10,13,32,44] ||
            {_x >= 48 && {_x <= 57}} ||
            {_x >= 65 && {_x <= 90}} ||
            {_x >= 97 && {_x <= 122}} ||
            {_x isEqualTo 95})
        }) < 0;
        _scanOffset = _scanOffset + count _scanCharacters;
    };
    if (_plain) then {
        private _characters = _text splitString (toString [9,10,13,32,44]);
        {
            if ((_forEachIndex mod 256) isEqualTo 0 && {!([_operation, "Reading class list", _forEachIndex, count _characters] call RACA_fnc_importCheckpoint)}) exitWith {_cancelled = true};
            if (_resourceError isNotEqualTo "") exitWith {};
            if (!_cancelled) then {[_x] call _consume};
        } forEach _characters;
        _characters = [];
    } else {
        private _doubleQuote = toString [34];
        private _singleQuote = toString [39];
        private _hasDoubleQuote = (_text find _doubleQuote) >= 0;
        private _hasSingleQuote = (_text find _singleQuote) >= 0;
        private _fastQuote = "";
        if (
            (_text find "//") < 0 &&
            {(_text find "/*") < 0}
        ) then {
            if (_hasDoubleQuote && {!_hasSingleQuote} && {(_text find (_doubleQuote + _doubleQuote)) < 0}) then {
                _fastQuote = _doubleQuote;
            };
            if (_hasSingleQuote && {!_hasDoubleQuote} && {(_text find (_singleQuote + _singleQuote)) < 0}) then {
                _fastQuote = _singleQuote;
            };
        };

        if (_fastQuote isNotEqualTo "") then {
            // Common legacy arrays use one quote style and contain no comments
            // or doubled-quote escapes. Match complete literals in bounded
            // native batches, carrying only one unfinished literal across a
            // boundary. This keeps 100,000-record migration linear without a
            // whole-input token corpus.
            private _offset = 0;
            private _chunkSize = 65536;
            private _carry = "";
            private _carryStart = -1;
            private _quotePattern = "[" + _fastQuote + "]";
            private _literalPattern = _fastQuote + "[^" + _fastQuote + "]*" + _fastQuote;
            while {_offset < _textLength && {!_cancelled} && {_resourceError isEqualTo ""}} do {
                _cancelled = !([_operation, "Reading SQF", _offset, _textLength] call RACA_fnc_importCheckpoint);
                private _mainLength = _chunkSize min (_textLength - _offset);
                private _scanBase = [_offset, _carryStart] select (_carry isNotEqualTo "");
                private _scan = _carry + (_text select [_offset, _mainLength]);
                private _quoteMatches = _scan regexFind [_quotePattern];
                private _literalMatches = _scan regexFind [_literalPattern];
                {
                    private _literal = (_x select 0) select 0;
                    private _literalLength = (count _literal) - 2;
                    if (_literalLength > _maxLiteralCharacters) exitWith {
                        _resourceError = format ["SQF literal resource exceeded: a quoted value is longer than %1 characters. Use portable JSON, a plain class list, or a narrowed migration source.", _maxLiteralCharacters];
                    };
                    [_literal select [1, _literalLength]] call _consume;
                    if (_cancelled || {_resourceError isNotEqualTo ""}) exitWith {};
                } forEach _literalMatches;
                if ((count _quoteMatches mod 2) isEqualTo 1 && {_resourceError isEqualTo ""}) then {
                    private _lastQuoteOffset = (((_quoteMatches select ((count _quoteMatches) - 1)) select 0) select 1);
                    _carryStart = _scanBase + _lastQuoteOffset;
                    _carry = _scan select [_lastQuoteOffset];
                    if (((count _carry) - 1) > _maxLiteralCharacters) then {
                        _resourceError = format ["SQF literal resource exceeded: a quoted value is longer than %1 characters. Use portable JSON, a plain class list, or a narrowed migration source.", _maxLiteralCharacters];
                    };
                } else {
                    _carry = "";
                    _carryStart = -1;
                };
                _quoteMatches = [];
                _literalMatches = [];
                _scan = "";
                _offset = _offset + _mainLength;
            };
            if (_carry isNotEqualTo "" && {_resourceError isEqualTo ""}) then {
                _state = ["SINGLE", "DOUBLE"] select (_fastQuote isEqualTo _doubleQuote);
                _start = _carryStart;
            };
        } else {
        private _offset = 0;
        private _chunkSize = 65536;
        private _literalStart = -1;
        private _quote = "";
        private _skipThrough = -1;
        // Ask the native regex engine for structural tokens in one bounded
        // window at a time. One look-ahead character lets two-character
        // comment delimiters cross a window boundary; matches in that overlap
        // are consumed by the following window. Only the completed literal is
        // sliced from the source, so no global token or character corpus is
        // retained.
        private _tokenPattern = "[""']|[/][/]|[/][*]|[*][/]|[\r\n]";
        while {_offset < _textLength && {!_cancelled} && {_resourceError isEqualTo ""}} do {
            _cancelled = !([_operation, "Reading SQF", _offset, _textLength] call RACA_fnc_importCheckpoint);
            private _mainLength = _chunkSize min (_textLength - _offset);
            private _chunk = _text select [_offset, (_mainLength + 1) min (_textLength - _offset)];
            private _matches = _chunk regexFind [_tokenPattern];
            {
                private _tokenRecord = _x select 0;
                private _token = _tokenRecord select 0;
                private _localOffset = _tokenRecord select 1;
                if (_localOffset < _mainLength) then {
                    private _tokenOffset = _offset + _localOffset;
                    if (_tokenOffset > _skipThrough) then {
                        switch (_state) do {
                            case "NORMAL": {
                                if (_token isEqualTo "//") then {
                                    _state = "LINECOMMENT";
                                } else {
                                    if (_token isEqualTo "/*") then {
                                        _state = "BLOCKCOMMENT";
                                        _start = _tokenOffset;
                                    } else {
                                        if (_token in ["'", '"']) then {
                                            _quote = _token;
                                            _state = ["SINGLE", "DOUBLE"] select (_quote isEqualTo '"');
                                            _start = _tokenOffset;
                                            _literalStart = _tokenOffset + 1;
                                        };
                                    };
                                };
                            };
                            case "LINECOMMENT": {
                                if (_token in [toString [10], toString [13]]) then {_state = "NORMAL"};
                            };
                            case "BLOCKCOMMENT": {
                                if (_token isEqualTo "*/") then {
                                    _state = "NORMAL";
                                    _skipThrough = _tokenOffset + 1;
                                };
                            };
                            default {
                                if (_token isEqualTo _quote) then {
                                    private _doubled = (_text select [_tokenOffset + 1, 1]) isEqualTo _quote;
                                    if (_doubled) then {
                                        _skipThrough = _tokenOffset + 1;
                                    } else {
                                        if ((_tokenOffset - _literalStart) > _maxLiteralCharacters) then {
                                            _resourceError = format ["SQF literal resource exceeded: a quoted value is longer than %1 characters. Use portable JSON, a plain class list, or a narrowed migration source.", _maxLiteralCharacters];
                                        } else {
                                            [_text select [_literalStart, _tokenOffset - _literalStart]] call _consume;
                                        };
                                        _state = "NORMAL";
                                        _literalStart = -1;
                                    };
                                };
                            };
                        };
                    };
                };
                if (_cancelled || {_resourceError isNotEqualTo ""}) exitWith {};
            } forEach _matches;
            _matches = [];
            _chunk = "";
            _offset = _offset + _mainLength;
            if (_state in ["SINGLE", "DOUBLE"] && {_literalStart >= 0} && {(_offset - _literalStart) > _maxLiteralCharacters}) then {
                _resourceError = format ["SQF literal resource exceeded: a quoted value is longer than %1 characters. Use portable JSON, a plain class list, or a narrowed migration source.", _maxLiteralCharacters];
            };
        };
        };
    };
};

if (_cancelled) exitWith {[[], [], ["Import cancelled."]]};
if (_resourceError isNotEqualTo "") exitWith {[[], [], [_resourceError]]};
if (_state in ["SINGLE", "DOUBLE", "BLOCKCOMMENT"]) exitWith {
    [[], [], [format ["Unterminated %1 beginning at character %2. Nothing was imported.", _state, _start]]]
};

_telemetry set ["candidates", _candidateCount];
_telemetry set ["unavailable", _missingCount];
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
if ((count _warnings) > _maxWarningRows) then {
    _warnings = (_warnings select [0, _maxWarningRows - 1]) + [format ["Additional notices were omitted at the %1-row review-output safeguard.", _maxWarningRows]];
};
[_operation, "preset_validation", diag_tickTime, [["available", _available], ["unavailable", _missingCount], ["warnings", count _warnings]]] call RACA_fnc_importTelemetry;

private _name = toString (((toArray _requestedName) select {_x >= 32 && {_x isNotEqualTo 127}}) select [0,128]);
if (_name isEqualTo "") then {_name = "Imported SQF Arsenal"};
[["RACA_PRESET", 1, _name, _buckets], [["RACA_SQF_REVIEW", 1, _missingSamples, _missingCount]], _warnings]
