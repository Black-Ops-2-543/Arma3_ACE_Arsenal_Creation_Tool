#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
private _requestId=format ["%1:%2",clientOwner,floor (diag_tickTime*1000)];
uiNamespace setVariable ["RACA_adminAuditExport",[_requestId,[]]];
(_display displayCtrl RACA_IDC_ADMIN_STATUS) ctrlSetText "Requesting the complete retained audit range in ordered pages...";
[player,0,250,"EXPORT",_requestId] remoteExecCall ["RACA_fnc_requestAdminSnapshot",2];
true
