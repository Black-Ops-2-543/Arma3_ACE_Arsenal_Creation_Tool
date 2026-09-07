/* Receives authorized audit pages and assembles a complete retained export. */
params [["_requestId","",[""]],["_cursor",0,[0]],["_total",0,[0]],["_records",[],[[]]],["_done",false,[true]],["_error","",[""]]];
if (!hasInterface || {isRemoteExecuted && {remoteExecutedOwner isNotEqualTo 2}}) exitWith {false};
private _state=uiNamespace getVariable ["RACA_adminAuditExport",[]];
if ((_state param [0,""]) isNotEqualTo _requestId) exitWith {false};
private _display=findDisplay RACA_IDD_ADMIN;
if (_error isNotEqualTo "" || {_total<0}) exitWith {
    uiNamespace setVariable ["RACA_adminAuditExport",[]];
    if (!isNull _display) then {(_display displayCtrl RACA_IDC_ADMIN_STATUS) ctrlSetText _error};
    systemChat format ["RACA: %1",_error];
    false
};
private _all=_state param [1,[]];
private _expectedTotal=_state param [2,-1];
if (_expectedTotal<0) then {_expectedTotal=_total};
if (_expectedTotal isNotEqualTo _total || {_cursor isNotEqualTo count _all} || {!_done && {_records isEqualTo []}}) exitWith {
    uiNamespace setVariable ["RACA_adminAuditExport",[]];
    private _message="Audit export paging changed or returned an invalid empty page. Start Copy Audit again.";
    if (!isNull _display) then {(_display displayCtrl RACA_IDC_ADMIN_STATUS) ctrlSetText _message};
    systemChat format ["RACA: %1",_message];
    false
};
_all=+_records+_all;
uiNamespace setVariable ["RACA_adminAuditExport",[_requestId,_all,_expectedTotal]];
if (!_done) exitWith {
    if (!isNull _display) then {(_display displayCtrl RACA_IDC_ADMIN_STATUS) ctrlSetText format ["Receiving retained audit records: %1 / %2...",count _all,_total]};
    [player,count _all,250,"EXPORT",_requestId] remoteExecCall ["RACA_fnc_requestAdminSnapshot",2];
    true
};
if ((count _all) isNotEqualTo _expectedTotal) exitWith {
    uiNamespace setVariable ["RACA_adminAuditExport",[]];
    private _message=format ["Audit export was incomplete: received %1 of %2 retained records.",count _all,_expectedTotal];
    if (!isNull _display) then {(_display displayCtrl RACA_IDC_ADMIN_STATUS) ctrlSetText _message};
    systemChat format ["RACA: %1",_message];
    false
};
private _lines=["RACA runtime audit export",format ["Exported: %1",systemTimeUTC],format ["Retained records: %1 / %2",count _all,_total]];
{_lines pushBack str _x} forEach _all;
[(_lines joinString toString [13,10]),"Runtime audit"] call RACA_fnc_copyTextAndLog;
if (!isNull _display) then {(_display displayCtrl RACA_IDC_ADMIN_STATUS) ctrlSetText format ["Copied all %1 retained audit records.",count _all]};
uiNamespace setVariable ["RACA_adminAuditExport",[]];
true
