params [
    ["_unit",objNull,[objNull]],
    ["_operation","",[""]],
    ["_objects",[],[[]]],
    ["_payload",[],[[]]],
    ["_mode","atomic",[""]],
    ["_requestId","",[""]]
];
if (!isServer || {isNull _unit} || {!isPlayer _unit}) exitWith {false};
if (isRemoteExecuted && {owner _unit isNotEqualTo remoteExecutedOwner}) exitWith {false};
if (_requestId isEqualTo "") then {_requestId=format ["a%1_%2",owner _unit,floor (diag_tickTime*1000)]};
if !([_unit] call RACA_fnc_isAdminAuthorized) exitWith {
    private _denied=["RACA_BULK_RESULT",1,toLowerANSI _operation,toLowerANSI _mode,false,count _objects,0,0,count _objects,false,[]];
    ["DENIED",_unit,objNull,"",["Unauthorized runtime administration",_operation,_mode]] call RACA_fnc_logEvent;
    [_requestId,"Administration request rejected: unauthorized.",_denied] remoteExecCall ["RACA_fnc_receiveAdminCommandResult",owner _unit];
    false
};

private _op=toLowerANSI _operation;
private _result=switch _op do {
    case "resetquotas";
    case "resetround";
    case "resetphase": {
        private _reset=["all","round","phase"] select (["resetquotas","resetround","resetphase"] find _op);
        private _removed=[_reset,objNull,"",""] call RACA_fnc_resetQuotas;
        ["RACA_BULK_RESULT",1,_op,"atomic",true,1,[1,0] select (_removed isEqualTo 0),[0,1] select (_removed isEqualTo 0),0,false,[["mission",["CHANGED","UNCHANGED"] select (_removed isEqualTo 0),format ["%1 quota record(s) removed.",_removed]]]]
    };
    case "resetobject": {[_objects,"reset",[],true,_mode] call RACA_fnc_bulkUpdateObjects};
    case "clear": {[_objects,"clear",[],true,_mode] call RACA_fnc_bulkUpdateObjects};
    case "enable": {[_objects,"enable",[],true,_mode] call RACA_fnc_bulkUpdateObjects};
    case "disable": {[_objects,"disable",[],true,_mode] call RACA_fnc_bulkUpdateObjects};
    case "assign": {[_objects,"assign",_payload,true,_mode] call RACA_fnc_bulkUpdateObjects};
    case "replace": {[_objects,"replace",_payload,true,_mode] call RACA_fnc_bulkUpdateObjects};
    default {["RACA_BULK_RESULT",1,_op,toLowerANSI _mode,false,count _objects,0,0,count _objects,false,[["<request>","REJECTED","Unsupported administration operation."]]]};
};
private _accepted=_result param [4,false];
private _message=format ["%1 %2: %3 changed, %4 unchanged, %5 rejected%6.",toUpperANSI _op,["failed","completed"] select _accepted,_result param [6,0],_result param [7,0],_result param [8,0],["","; rollback completed"] select (_result param [9,false])];
diag_log format ["[RACA][ADMIN:%1] operation=%2 mode=%3 accepted=%4 result=%5",_requestId,_op,toLowerANSI _mode,_accepted,toJSON _result];
["ADMIN_CHANGE",_unit,_objects param [0,objNull],"",[_requestId,_operation,_mode,_result]] call RACA_fnc_logEvent;
[_requestId,_message,_result] remoteExecCall ["RACA_fnc_receiveAdminCommandResult",owner _unit];
_accepted
