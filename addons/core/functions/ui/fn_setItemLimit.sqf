#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {};
private _list = _display displayCtrl RACA_IDC_ITEM_LIST;
private _row = lnbCurSelRow _list;
if (_row < 0) exitWith {[_display, "Select one catalogue row before setting a quantity limit."] call RACA_fnc_setStatus};
private _className = _list lnbData [_row, 0];
private _limit = parseNumber ctrlText (_display displayCtrl RACA_IDC_LIMIT_VALUE);
if (_limit < -1) exitWith {[_display, "Quantity must be -1 (unlimited), zero, or a positive number."] call RACA_fnc_setStatus};
private _scopeCtrl = _display displayCtrl RACA_IDC_LIMIT_SCOPE;
private _scope = _scopeCtrl lbData (lbCurSel _scopeCtrl);
[_display] call RACA_fnc_pushCreatorHistory;
private _limits = uiNamespace getVariable ["RACA_builderLimits", createHashMap];
_limits set [_className, [_className, floor _limit, _scope, ["never", "interaction"] select (_scope isEqualTo "interaction")]];
uiNamespace setVariable ["RACA_builderLimits", _limits];
[_display] call RACA_fnc_refreshItemList;
[_display, format ["%1 limit for %2 set to %3.", _scope, _className, floor _limit]] call RACA_fnc_setStatus;
