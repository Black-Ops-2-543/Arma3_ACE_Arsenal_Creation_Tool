/* Checks prospective child -> parent ancestry by case-insensitive preset name. */
params [
    ["_childName", "", [""]],
    ["_parentName", "", [""]],
    ["_library", [], [[]]]
];

private _childKey = toLowerANSI _childName;
private _currentKey = toLowerANSI _parentName;
if (_childKey isEqualTo "" || {_currentKey isEqualTo ""}) exitWith {false};

private _visited = createHashMap;
private _cycle = false;
private _done = false;

while {!_done} do {
    if (_currentKey isEqualTo _childKey || {_visited getOrDefault [_currentKey, false]}) exitWith {
        _cycle = true;
        _done = true;
    };

    _visited set [_currentKey, true];
    private _index = _library findIf {toLowerANSI (_x select 2) isEqualTo _currentKey};
    if (_index < 0) exitWith {_done = true};

    private _composition = [(_library select _index)] call RACA_fnc_getComposition;
    if (_composition isEqualTo []) exitWith {_done = true};
    _currentKey = toLowerANSI (_composition select 2);
    if (_currentKey isEqualTo "") then {_done = true};
};

_cycle
