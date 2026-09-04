params [
    ["_logic", objNull, [objNull]],
    ["_operation", "", [""]],
    ["_targets", [], [[]]]
];
if (isNull _logic) exitWith {false};
/* isGlobal modules execute on every machine; only the machine owning the logic may submit. */
if (!local _logic) exitWith {false};
private _expected = switch (toUpperANSI _operation) do {
    case "ASSIGN": {"RACA_ModuleAssign"};
    case "CLEAR": {"RACA_ModuleClear"};
    case "TOGGLE": {"RACA_ModuleToggle"};
    case "RESET": {"RACA_ModuleResetQuotas"};
    default {""};
};
if (_expected isEqualTo "" || {typeOf _logic isNotEqualTo _expected}) exitWith {false};
if (isServer) exitWith {
    [_logic, _operation, _targets, 2] call RACA_fnc_handleZeusModuleRequest
};
if (hasInterface) then {
    [_logic, _operation, _targets] remoteExecCall ["RACA_fnc_handleZeusModuleRequest", 2]
};
true
