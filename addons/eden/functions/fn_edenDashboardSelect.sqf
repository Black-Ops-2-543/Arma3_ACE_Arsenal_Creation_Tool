#include "..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display || {!is3DEN}) exitWith {false};
private _index = lbCurSel (_display displayCtrl RACA_EDEN_IDC_DASHBOARD_LIST);
private _object = (_display getVariable ["RACA_dashboardObjects", []]) param [_index, objNull];
if (isNull _object) exitWith {false};
set3DENSelected [_object];
(_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText format ["Selected %1 in Eden.", (_object get3DENAttribute "Name") param [0, typeOf _object]];
true
