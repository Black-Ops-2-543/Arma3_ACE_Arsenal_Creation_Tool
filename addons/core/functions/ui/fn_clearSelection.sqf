params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {};
if ((count (uiNamespace getVariable ["RACA_builderSelected", createHashMap])) isEqualTo 0) exitWith {
    [_display, "The current selection is already empty."] call RACA_fnc_setStatus;
};
[_display] call RACA_fnc_pushCreatorHistory;
uiNamespace setVariable ["RACA_builderSelected", createHashMap];
uiNamespace setVariable ["RACA_builderLimits", createHashMap];
[_display] call RACA_fnc_refreshItemList;
[_display, "Cleared all included items."] call RACA_fnc_setStatus;
