/* Receives authorized audit pages and assembles a complete retained export. */
params [["_requestId","",[""]],["_cursor",0,[0]],["_total",0,[0]],["_records",[],[[]]],["_done",false,[true]]];
if (!hasInterface || {isRemoteExecuted && {remoteExecutedOwner isNotEqualTo 2}}) exitWith {false};
private _state=uiNamespace getVariable ["RACA_adminAuditExport",[]];
if ((_state param [0,""]) isNotEqualTo _requestId) exitWith {false};
private _all=_state param [1,[]];
_all=+_records+_all;
uiNamespace setVariable ["RACA_adminAuditExport",[_requestId,_all]];
private _display=findDisplay RACA_IDD_ADMIN;
if (!_done) exitWith {
    if (!isNull _display) then {(_display displayCtrl RACA_IDC_ADMIN_STATUS) ctrlSetText format ["Receiving retained audit records: %1 / %2...",count _all,_total]};
    [player,_cursor+count _records,250,"EXPORT",_requestId] remoteExecCall ["RACA_fnc_requestAdminSnapshot",2];
    true
};
private _lines=["RACA runtime audit export",format ["Exported: %1",systemTimeUTC],format ["Retained records: %1 / %2",count _all,_total]];
{_lines pushBack str _x} forEach _all;
[(_lines joinString toString [13,10]),"Runtime audit"] call RACA_fnc_copyTextAndLog;
if (!isNull _display) then {(_display displayCtrl RACA_IDC_ADMIN_STATUS) ctrlSetText format ["Copied all %1 retained audit records.",count _all]};
true
