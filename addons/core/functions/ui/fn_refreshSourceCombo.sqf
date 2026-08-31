#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {};
private _combo = _display displayCtrl RACA_IDC_SOURCE_FILTER;
private _previousIndex = lbCurSel _combo;
private _previous = if (_previousIndex < 0) then {""} else {_combo lbData _previousIndex};
private _sources = [];
{
    private _source = _x param [4, "Unknown", [""]];
    if (_source isNotEqualTo "") then {_sources pushBackUnique _source};
} forEach (uiNamespace getVariable ["RACA_itemCatalog", []]);
_sources sort true;
lbClear _combo;
private _all = _combo lbAdd "All sources";
_combo lbSetData [_all, ""];
private _selected = 0;
{
    private _index = _combo lbAdd _x;
    _combo lbSetData [_index, _x];
    if (_x isEqualTo _previous) then {_selected = _index};
} forEach _sources;
_combo lbSetCurSel _selected;
