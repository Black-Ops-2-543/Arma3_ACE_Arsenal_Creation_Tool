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
if (!_authorized) exitWith {systemChat format ["RACA: %1", _reason]; false};

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
    private _deadline = diag_tickTime + 8;
    waitUntil {uiSleep 0.05; !isNull (findDisplay 1127001) || {diag_tickTime > _deadline}};
    if (!isNull (findDisplay 1127001)) then {
        waitUntil {uiSleep 0.1; isNull (findDisplay 1127001)};
    };
    private _after = getUnitLoadout _unit;
    deleteVehicle _holder;
    uiSleep 0.35;
    [_sessionId, _unit, _after] remoteExecCall ["RACA_fnc_finishSession", 2];
};
true
