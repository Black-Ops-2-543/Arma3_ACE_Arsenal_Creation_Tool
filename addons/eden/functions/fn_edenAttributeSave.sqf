params [["_group", controlNull, [controlNull]]];

if (isNull _group) exitWith {[]};
private _value = _group getVariable ["RACA_edenObjectConfig", []];
if (_value isEqualType []) then {+_value} else {[]}
