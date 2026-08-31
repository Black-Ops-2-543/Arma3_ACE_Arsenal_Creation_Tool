params [["_group", controlNull, [controlNull]]];
if (isNull _group) exitWith {false};
_group setVariable ["RACA_edenObjectConfig", []];
[_group] call RACA_fnc_edenUpdateSummary;
systemChat "RACA: Cleared this object's pending arsenal configuration. Confirm the Attributes window to save the change.";
true
