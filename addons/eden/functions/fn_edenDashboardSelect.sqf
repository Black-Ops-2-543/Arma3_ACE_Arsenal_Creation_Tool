#include "..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display || {!is3DEN}) exitWith {false};
private _index = lbCurSel (_display displayCtrl RACA_EDEN_IDC_DASHBOARD_LIST);
private _object = (_display getVariable ["RACA_dashboardObjects", []]) param [_index, objNull];
if (isNull _object) exitWith {false};
set3DENSelected [_object];
private _report = (_display getVariable ["RACA_dashboardReports", []]) param [_index, []];
private _summary = _report param [4, [0, 0, 0], [[]]];
(_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText format [
    "Selected %1 in Eden. Preflight: %2 blocker(s), %3 warning(s), %4 information notice(s).",
    (_object get3DENAttribute "Name") param [0, typeOf _object],
    _summary param [0, 0, [0]],
    _summary param [1, 0, [0]],
    _summary param [2, 0, [0]]
];
true
