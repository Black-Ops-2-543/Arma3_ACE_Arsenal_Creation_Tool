params [
    ["_unit", objNull, [objNull]],
    ["_operation", "", [""]],
    ["_objects", [], [[]]],
    ["_payload", [], [[]]]
];
if (!isServer || {!([_unit] call RACA_fnc_isAdminAuthorized)}) exitWith {
    ["DENIED", _unit, objNull, "", ["Unauthorized runtime administration", _operation]] call RACA_fnc_logEvent;
    false
};
if !(isNil "remoteExecutedOwner") then {
    if (remoteExecutedOwner > 0 && {owner _unit isNotEqualTo remoteExecutedOwner}) exitWith {false};
};
private _result = switch (toLowerANSI _operation) do {
    case "resetquotas": {["all", objNull, "", ""] call RACA_fnc_resetQuotas; true};
    case "resetround": {["round", objNull, "", ""] call RACA_fnc_resetQuotas; true};
    case "resetphase": {["phase", objNull, "", ""] call RACA_fnc_resetQuotas; true};
    case "clear": {([_objects, "clear", [], true] call RACA_fnc_bulkUpdateObjects) >= 0};
    case "enable": {([_objects, "enable", [], true] call RACA_fnc_bulkUpdateObjects) >= 0};
    case "disable": {([_objects, "disable", [], true] call RACA_fnc_bulkUpdateObjects) >= 0};
    case "assign": {([_objects, "assign", _payload, true] call RACA_fnc_bulkUpdateObjects) >= 0};
    case "replace": {([_objects, "replace", _payload, true] call RACA_fnc_bulkUpdateObjects) >= 0};
    default {false};
};
["ADMIN_CHANGE", _unit, _objects param [0, objNull], "", [_operation, _result]] call RACA_fnc_logEvent;
_result
