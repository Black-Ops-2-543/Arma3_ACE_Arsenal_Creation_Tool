#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {};
(uiNamespace getVariable ["RACA_historyPending", [displayNull, ""]]) params ["_parent", "_name"];
_display setVariable ["RACA_parentCreator", _parent];
_display setVariable ["RACA_historyPresetName", _name];
private _history = [_name] call RACA_fnc_getPresetHistory;
_display setVariable ["RACA_historyEntries", _history];
private _list = _display displayCtrl RACA_IDC_HISTORY_LIST;
lnbClear _list;
{
    private _preset = _x param [8, []];
    private _count = count ([_preset] call RACA_fnc_flattenPresetClasses);
    private _row = _list lnbAddRow [str (_x param [4, 0]), str (_x param [5, []]), _x param [6, ""], _x param [7, ""], str _count];
    _list lnbSetData [[_row, 0], str _forEachIndex];
} forEach _history;
if (_history isNotEqualTo []) then {_list lnbSetCurSelRow 0};
[_display] call RACA_fnc_historySelect;
