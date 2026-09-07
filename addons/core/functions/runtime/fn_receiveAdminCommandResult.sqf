#include "..\..\script_component.hpp"
params [["_requestId","",[""]],["_message","",[""]],["_result",[],[[]]]];
if (!hasInterface || {isRemoteExecuted && {remoteExecutedOwner isNotEqualTo 2}}) exitWith {false};
uiNamespace setVariable ["RACA_lastAdminCommandResult",[_requestId,_message,_result,diag_tickTime]];
private _display=findDisplay RACA_IDD_ADMIN;
if (!isNull _display) then {(_display displayCtrl RACA_IDC_ADMIN_STATUS) ctrlSetText _message};
systemChat format ["RACA administration: %1",_message];
true
