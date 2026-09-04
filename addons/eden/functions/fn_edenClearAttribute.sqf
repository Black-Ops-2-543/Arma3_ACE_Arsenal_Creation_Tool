params [["_group", controlNull, [controlNull]]];
if (isNull _group) exitWith {false};
_group setVariable ["RACA_edenObjectConfig", []];
[_group, []] call RACA_fnc_edenPopulate;
true
