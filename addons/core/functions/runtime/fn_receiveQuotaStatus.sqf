params [
    ["_authorized", false, [true]],
    ["_message", "", [""]],
    ["_slotName", "Restricted Arsenal", [""]],
    ["_remaining", [], [[]]]
];
if (!hasInterface || {!isRemoteExecuted} || {remoteExecutedOwner isNotEqualTo 2}) exitWith {false};
if (!_authorized) exitWith {systemChat format ["RACA: %1", _message]; false};
if (_remaining isEqualTo []) exitWith {systemChat format ["RACA %1: no quantity limits are configured.", _slotName]; true};
systemChat format ["RACA %1 — remaining allowance:", _slotName];
{
    _x params ["_ruleId", "_available", "_limit", "_scope", "_reset"];
    systemChat format ["  %1: %2 of %3 (%4; reset %5)", _ruleId, if (_available < 0) then {"unlimited"} else {str _available}, if (_limit < 0) then {"unlimited"} else {str _limit}, _scope, _reset];
} forEach _remaining;
true
