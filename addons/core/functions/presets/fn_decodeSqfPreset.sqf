/*
 * Recovers arsenal class strings from existing SQF without compiling it.
 * This intentionally ignores variable flow: quoted classes remain discoverable
 * whether arrays are concatenated with +, append, or arrayIntersect.
 */
params [
    ["_text", "", [""]],
    ["_requestedName", "", [""]]
];

if (_text isEqualTo "") exitWith {[[], [], ["The clipboard is empty."]]};
if ((count _text) > 2000000) exitWith {
    [[], [], ["The SQF or class list exceeds the 2,000,000-character import safety limit."]]
};

private _characters = toArray _text;
private _quotedValues = [];
private _quotedOverflow = false;
private _quote = 0;
private _buffer = [];

for "_index" from 0 to ((count _characters) - 1) do {
    private _character = _characters select _index;
    if (_quote isEqualTo 0) then {
        if (_character in [34, 39]) then {
            _quote = _character;
            _buffer = [];
        };
    } else {
        if (_character isEqualTo _quote) then {
            if ((count _quotedValues) >= 50000) then {
                _quotedOverflow = true;
            } else {
                _quotedValues pushBack (toString _buffer);
            };
            _quote = 0;
            _buffer = [];
        } else {
            _buffer pushBack _character;
        };
    };
};
if (_quotedOverflow) exitWith {
    [[], [], ["The SQF contains more than 50,000 quoted values and was rejected."]]
};

private _buckets = [[], [], [], []];
private _warnings = [];
{
    private _candidate = _x;
    if ([_candidate] call RACA_fnc_isSafeClassName) then {
        ([_candidate] call RACA_fnc_classifyClass) params ["_bucket"];
        if (_bucket >= 0) then {
            (_buckets select _bucket) pushBackUnique _candidate;
        } else {
            private _isSqfIdentifier = (_candidate select [0, 1]) isEqualTo "_" || {(_candidate find "_fnc_") >= 0};
            if (!_isSqfIdentifier && {!(_candidate in ["RACA_PRESET", "RACA_PORTABLE_PRESET"])}) then {
                _warnings pushBackUnique format ["Unavailable quoted class: %1", _candidate];
            };
        };
    };
} forEach _quotedValues;

private _itemCount = 0;
{_itemCount = _itemCount + count _x} forEach _buckets;

private _tokenOverflow = false;
if (_itemCount isEqualTo 0) then {
    // Also accept the simple comma-separated export, which has no quotes.
    private _delimiters = toString [9, 10, 13, 32, 34, 39, 40, 41, 43, 44, 59, 60, 61, 62, 91, 93, 123, 125];
    private _tokens = _text splitString _delimiters;
    if ((count _tokens) > 50000) then {
        _tokenOverflow = true;
    } else {
        {
            private _candidate = _x;
            if ([_candidate] call RACA_fnc_isSafeClassName) then {
                ([_candidate] call RACA_fnc_classifyClass) params ["_bucket"];
                if (_bucket >= 0) then {
                    (_buckets select _bucket) pushBackUnique _candidate;
                };
            };
        } forEach _tokens;
    };
};
if (_tokenOverflow) exitWith {
    [[], [], ["The class list contains more than 50,000 tokens and was rejected."]]
};

{_x sort true} forEach _buckets;
_itemCount = 0;
{_itemCount = _itemCount + count _x} forEach _buckets;
if (_itemCount > 20000) exitWith {
    [[], [], _warnings + ["The import contains more than 20,000 unique available class names and was rejected."]]
};
if (_itemCount isEqualTo 0) exitWith {
    [[], [], _warnings + ["No currently available arsenal class names were found in the SQF or class list."]]
};

private _nameCharacters = (toArray _requestedName) select {_x >= 32 && {_x isNotEqualTo 127}};
private _name = toString (_nameCharacters select [0, 128]);
if (_name isEqualTo "") then {_name = "Imported SQF Arsenal"};

[["RACA_PRESET", 1, _name, _buckets], [], _warnings]
