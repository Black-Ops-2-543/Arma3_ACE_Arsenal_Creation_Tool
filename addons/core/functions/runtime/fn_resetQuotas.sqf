params [
    ["_mode", "all", [""]],
    ["_object", objNull, [objNull]],
    ["_slotId", "", [""]],
    ["_uid", "", [""]]
];
if (!isServer) exitWith {0};
private _quota = missionNamespace getVariable ["RACA_quotaState", createHashMap];
private _removed = 0;
{
    private _record = _quota get _x;
    _record params ["", "", "_reset", "_objectId", "_recordSlot", "_recordUid"];
    private _matchesMode = _mode isEqualTo "all" || {_reset isEqualTo _mode};
    private _matchesObject = isNull _object || {_objectId isEqualTo netId _object};
    private _matchesSlot = _slotId isEqualTo "" || {_recordSlot isEqualTo _slotId};
    private _matchesUid = _uid isEqualTo "" || {_recordUid isEqualTo _uid};
    if (_matchesMode && {_matchesObject} && {_matchesSlot} && {_matchesUid}) then {
        _quota deleteAt _x;
        _removed = _removed + 1;
    };
} forEach keys _quota;
missionNamespace setVariable ["RACA_quotaState", _quota, true];
_removed
