params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {};
uiNamespace setVariable ["RACA_builderSelected", createHashMap];
[_display] call RACA_fnc_refreshItemList;
[_display, "Cleared all included items."] call RACA_fnc_setStatus;
