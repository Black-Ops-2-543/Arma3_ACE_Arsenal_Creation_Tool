/*
 * Strict data-only reader for the versioned RACA reusable SQF envelope.
 * Returns [matchedMarker, malformed, literalValues, message].
 */
params [["_text", "", [""]], ["_operation", [], [[]]]];

private _marker = "// RACA_REUSABLE_SQF_FORMAT:2";
if ((_text find _marker) < 0) exitWith {[false, false, [], ""]};

private _declaration = "private _arsenalItems = [";
private _start = _text find _declaration;
private _required = [
    'params [["_box", objNull, [objNull]]];',
    "if (!isServer) exitWith {};",
    "_arsenalItems = _arsenalItems arrayIntersect _arsenalItems;",
    "[_box, true] call ace_arsenal_fnc_removeBox;",
    "[_box, _arsenalItems, true] call ace_arsenal_fnc_initBox;"
];
if (_start < 0 || {(_required findIf {(_text find _x) < 0}) >= 0}) exitWith {
    [true, true, [], "The RACA reusable SQF marker is present, but its structural envelope is incomplete. Use an unmodified export or generic recovery without the marker."]
};

_start = _start + count _declaration;
private _tail = _text select [_start];
private _relativeFinish = _tail find "];";
if (_relativeFinish < 0) exitWith {
    [true, true, [], "The RACA reusable SQF literal array is not terminated. Nothing was imported."]
};
private _finish = _start + _relativeFinish;

private _literal = _text select [_start, _finish - _start];
private _characters = toArray _literal;
private _values = [];
private _buffer = [];
private _state = "BETWEEN";
private _cancelled = false;
private _malformed = false;
private _i = 0;
while {_i < count _characters && {!_cancelled} && {!_malformed}} do {
    if ((_i mod 4096) isEqualTo 0) then {
        _cancelled = !([_operation, "Reading generated SQF literal", _i, count _characters] call RACA_fnc_importCheckpoint);
    };
    private _c = _characters select _i;
    switch (_state) do {
        case "BETWEEN": {
            if (_c in [9,10,13,32,44]) then {} else {
                if (_c isEqualTo 34) then {_state = "STRING"; _buffer = []} else {_malformed = true};
            };
        };
        case "STRING": {
            if (_c isEqualTo 34) then {_state = "AFTER"; _values pushBack (toString _buffer)} else {_buffer pushBack _c};
        };
        case "AFTER": {
            if (_c in [9,10,13,32]) then {} else {
                if (_c isEqualTo 44) then {_state = "BETWEEN"} else {_malformed = true};
            };
        };
    };
    _i = _i + 1;
};

if (_cancelled) exitWith {[true, true, [], "Import cancelled."]};
if (_malformed || {_state isEqualTo "STRING"} || {_state isEqualTo "BETWEEN" && {_values isNotEqualTo []}}) exitWith {
    [true, true, [], "The RACA reusable SQF literal contains non-literal syntax or malformed separators. Nothing was imported."]
};
[true, false, _values, "Recognized RACA reusable SQF format 2; only the _arsenalItems literal was read."]
