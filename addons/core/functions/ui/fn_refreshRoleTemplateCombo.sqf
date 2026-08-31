#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};

private _combo = _display displayCtrl RACA_IDC_ROLE_TEMPLATE;
private _previousIndex = lbCurSel _combo;
private _previous = if (_previousIndex < 0) then {""} else {_combo lbData _previousIndex};
lbClear _combo;
private _selected = 0;
{
    private _kind = _x param [4, "RULES", [""]];
    private _label = if (_kind isEqualTo "PACK") then {format ["%1 [custom pack]", _x select 1]} else {_x select 1};
    private _index = _combo lbAdd _label;
    _combo lbSetData [_index, _x select 0];
    _combo lbSetTooltip [_index, _x select 2];
    if ((_x select 0) isEqualTo _previous) then {_selected = _index};
} forEach call RACA_fnc_getRoleTemplates;
_combo lbSetCurSel _selected;
true
