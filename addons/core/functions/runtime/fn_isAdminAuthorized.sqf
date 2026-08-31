params [["_unit", objNull, [objNull]]];
if (isNull _unit) exitWith {false};
private _uid = getPlayerUID _unit;
private _allowed = missionNamespace getVariable ["RACA_adminUIDs", []];
_uid in _allowed || {admin owner _unit > 0} || {_unit isEqualTo player && {serverCommandAvailable "#kick"}}
