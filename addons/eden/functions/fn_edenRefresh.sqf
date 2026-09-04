params [["_group", controlNull, [controlNull]]];

if (isNull _group) exitWith {};
[_group, _group getVariable ["RACA_edenObjectConfig", []]] call RACA_fnc_edenPopulate;
