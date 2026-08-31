params [
    ["_event", "INFO", [""]],
    ["_unit", objNull, [objNull]],
    ["_object", objNull, [objNull]],
    ["_slotId", "", [""]],
    ["_details", [], [[]]],
    ["_level", "standard", [""]]
];

if (!isServer) exitWith {false};
private _configuredLevel = toLowerANSI (missionNamespace getVariable ["RACA_auditLevel", "standard"]);
if (_configuredLevel isEqualTo "off") exitWith {true};
if (_configuredLevel isEqualTo "errors" && {!(_event in ["DENIED", "ERROR", "QUOTA_EXHAUSTED"])}) exitWith {true};

private _uid = if (isNull _unit) then {""} else {getPlayerUID _unit};
private _name = if (isNull _unit) then {""} else {name _unit};
if (missionNamespace getVariable ["RACA_auditPrivacy", false]) then {
    _uid = if (_uid isEqualTo "") then {""} else {format ["…%1", _uid select [((count _uid) - 4) max 0]]};
};
private _record = [systemTimeUTC, _event, _uid, _name, netId _object, _slotId, _details, _level];
private _log = missionNamespace getVariable ["RACA_auditLog", []];
_log pushBack _record;
private _maxRecords = (missionNamespace getVariable ["RACA_auditMaxRecords", 5000]) max 100;
if ((count _log) > _maxRecords) then {
    _log deleteRange [0, (count _log) - _maxRecords];
};
missionNamespace setVariable ["RACA_auditLog", _log];
diag_log format ["[RACA_AUDIT] %1", toJSON _record];
if (_configuredLevel isEqualTo "verbose") then {
    diag_log format ["[RACA] %1 by %2 (%3), object %4, slot %5: %6", _event, _name, _uid, netId _object, _slotId, _details];
};
true
