#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {};
private _list = _display displayCtrl RACA_IDC_ITEM_LIST;
private _rows = lbSelection _list;
private _row = lnbCurSelRow _list;
if (_row < 0 && {_rows isNotEqualTo []}) then {_row = _rows select 0};
if (_row < 0) exitWith {[_display, "Select one or more catalogue rows before setting a quantity limit."] call RACA_fnc_setStatus};
if (_rows isEqualTo [] || {!(_row in _rows)}) then {_rows = [_row]};
private _classes = [];
{
    private _candidate = _list lnbData [_x, 0];
    if (_candidate isNotEqualTo "") then {_classes pushBackUnique _candidate};
} forEach _rows;
if (_classes isEqualTo []) exitWith {[_display, "The selected rows have no class names."] call RACA_fnc_setStatus};
private _limit = parseNumber ctrlText (_display displayCtrl RACA_IDC_LIMIT_VALUE);
if (_limit < -1) exitWith {[_display, "Quantity must be -1 (unlimited), zero, or a positive number."] call RACA_fnc_setStatus};
private _scopeCtrl = _display displayCtrl RACA_IDC_LIMIT_SCOPE;
private _scope = _scopeCtrl lbData (lbCurSel _scopeCtrl);
[_display] call RACA_fnc_pushCreatorHistory;
private _limits = uiNamespace getVariable ["RACA_builderLimits", createHashMap];
{
    _limits set [_x, [_x, floor _limit, _scope, ["never", "interaction"] select (_scope isEqualTo "interaction")]];
} forEach _classes;
uiNamespace setVariable ["RACA_builderLimits", _limits];
[_display] call RACA_fnc_refreshItemList;
[_display, format ["%1 limit set to %2 for %3 selected class(es).", _scope, floor _limit, count _classes]] call RACA_fnc_setStatus;
