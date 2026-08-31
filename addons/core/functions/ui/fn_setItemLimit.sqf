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
([_display] call RACA_fnc_readQuantityPolicy) params ["_validPolicy", "_limit", "_scope", "_reset", "_policyError"];
if (!_validPolicy) exitWith {[_display, _policyError] call RACA_fnc_setStatus};
[_display] call RACA_fnc_pushCreatorHistory;
private _limits = uiNamespace getVariable ["RACA_builderLimits", createHashMap];
{
    _limits set [_x, [_x, _limit, _scope, _reset]];
} forEach _classes;
uiNamespace setVariable ["RACA_builderLimits", _limits];
[_display] call RACA_fnc_refreshItemList;
[_display, format ["%1 limit set to %2 for %3 selected class(es); reset: %4.", _scope, _limit, count _classes, _reset]] call RACA_fnc_setStatus;
