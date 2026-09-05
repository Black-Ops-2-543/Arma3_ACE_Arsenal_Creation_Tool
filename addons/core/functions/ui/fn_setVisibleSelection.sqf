params [
    ["_display", displayNull, [displayNull]],
    ["_include", true, [true]]
];

if (isNull _display) exitWith {};

private _selected = uiNamespace getVariable ["RACA_builderSelected", createHashMap];
private _visible = uiNamespace getVariable ["RACA_visibleClasses", []];

if (_visible isEqualTo []) exitWith {[_display, "No visible items match the current filters."] call RACA_fnc_setStatus};
if ((_display getVariable ["RACA_unresolvedFilters", []]) isNotEqualTo []) exitWith {[_display, "Resolve or explicitly clear missing filters before bulk inclusion."] call RACA_fnc_setStatus};
_visible = _visible select {(_selected getOrDefault [_x, false]) isNotEqualTo _include};
if (_visible isEqualTo []) exitWith {};
[_display] call RACA_fnc_pushCreatorHistory;

{
    if (_include) then {
        _selected set [_x, true];
    } else {
        _selected deleteAt _x;
    };
} forEach _visible;

uiNamespace setVariable ["RACA_builderSelected", _selected];
uiNamespace setVariable ["RACA_selectionRevision",(uiNamespace getVariable ["RACA_selectionRevision",0])+1];
[_display] call RACA_fnc_refreshItemList;
[_display, format ["%1 %2 visible items.", ["Excluded", "Included"] select _include, count _visible]] call RACA_fnc_setStatus;
