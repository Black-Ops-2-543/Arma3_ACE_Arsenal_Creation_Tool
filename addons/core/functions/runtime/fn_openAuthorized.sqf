params [
    ["_object", objNull, [objNull]],
    ["_unit", objNull, [objNull]],
    ["_slotId", "", [""]],
    ["_slotName", "Restricted Arsenal", [""]],
    ["_classes", [], [[]]],
    ["_limits", [], [[]]],
    ["_remaining", [], [[]]],
    ["_sessionId", "", [""]],
    ["_authorized", false, [true]],
    ["_reason", "", [""]]
];
if (!hasInterface || {isNull _unit} || {_unit isNotEqualTo player}) exitWith {false};
if (isRemoteExecuted && {remoteExecutedOwner isNotEqualTo 2}) exitWith {false};
if (!isRemoteExecuted && {!isServer}) exitWith {false};
if (!_authorized) exitWith {systemChat format ["RACA: %1", _reason]; false};
if (isNull _object || {_sessionId isEqualTo ""} || {_classes isEqualTo []}) exitWith {
    systemChat "RACA: The authorized arsenal session was no longer available.";
    false
};

if (_remaining isNotEqualTo []) then {
    private _parts = _remaining apply {format ["%1: %2 remaining (%3)", _x select 0, _x select 1, _x select 2]};
    systemChat format ["RACA %1 — %2", _slotName, _parts joinString ", "];
};

private _holder = createVehicleLocal ["Box_NATO_Ammo_F", getPosATL _object, [], 0, "CAN_COLLIDE"];
_holder hideObject true;
_holder enableSimulation false;
[_holder, _classes, false] call ace_arsenal_fnc_initBox;
[_holder, _unit] call ace_arsenal_fnc_openBox;

[_holder, _unit, _object, _slotId, _sessionId] spawn {
    params ["_holder", "_unit", "_object", "_slotId", "_sessionId"];
    private _deadline = diag_tickTime + 60;
    waitUntil {uiSleep 0.05; !isNull (findDisplay 1127001) || {diag_tickTime > _deadline}};
    if (isNull (findDisplay 1127001)) exitWith {
        deleteVehicle _holder;
        systemChat "RACA: ACE Arsenal did not open before the authorized session expired.";
        [_sessionId,_unit,"failed"] remoteExecCall ["RACA_fnc_acknowledgeSession",2];
    };
    [_sessionId,_unit,"opened"] remoteExecCall ["RACA_fnc_acknowledgeSession",2];
    private _heartbeat = diag_tickTime + 30;
    waitUntil {
        uiSleep 0.1;
        if (diag_tickTime >= _heartbeat) then {
            [_sessionId,_unit,"heartbeat"] remoteExecCall ["RACA_fnc_acknowledgeSession",2];
            _heartbeat = diag_tickTime + 30;
        };
        isNull (findDisplay 1127001) || {isNull _holder} || {isNull _unit}
    };
    private _after = getUnitLoadout _unit;
    deleteVehicle _holder;
    uiSleep 0.35;
    [_sessionId, _unit, _after] remoteExecCall ["RACA_fnc_finishSession", 2];
};
true
