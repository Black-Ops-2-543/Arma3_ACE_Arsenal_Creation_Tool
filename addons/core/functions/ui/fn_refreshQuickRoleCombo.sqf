#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {};

private _combo = _display displayCtrl RACA_IDC_QUICK_ROLE;
private _previousIndex = lbCurSel _combo;
private _previous = if (_previousIndex >= 0) then {_combo lbData _previousIndex} else {""};
lbClear _combo;
private _blank = _combo lbAdd "Blank preset - choose every item yourself";
_combo lbSetData [_blank, ""];
{
    private _label = if ((_x param [4, "RULES", [""]]) isEqualTo "PACK") then {
        format ["%1 custom pack", _x select 1]
    } else {
        format ["%1 starter", _x select 1]
    };
    private _index = _combo lbAdd _label;
    _combo lbSetData [_index, _x select 0];
} forEach call RACA_fnc_getRoleTemplates;

private _selection = 0;
for "_index" from 0 to ((lbSize _combo) - 1) do {
    if ((_combo lbData _index) isEqualTo _previous) exitWith {_selection = _index};
};
_combo lbSetCurSel _selection;
