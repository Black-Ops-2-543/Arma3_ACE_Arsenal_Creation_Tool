params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {};
[_display, uiNamespace getVariable ["RACA_adminSnapshot", ["No snapshot received.", [], [], []]]] call RACA_fnc_adminRefresh;
