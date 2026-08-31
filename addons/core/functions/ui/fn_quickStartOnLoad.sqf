#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {};
_display setVariable ["RACA_parentCreator", uiNamespace getVariable ["RACA_quickStartParent", displayNull]];
private _combo = _display displayCtrl RACA_IDC_QUICK_ROLE;
lbClear _combo;
private _blank = _combo lbAdd "Blank preset — choose every item yourself";
_combo lbSetData [_blank, ""];
{
    private _index = _combo lbAdd format ["%1 starter", _x select 1];
    _combo lbSetData [_index, _x select 0];
    _combo lbSetTooltip [_index, _x select 2];
} forEach call RACA_fnc_getRoleTemplates;
_combo lbSetCurSel 1;
(_display displayCtrl RACA_IDC_QUICK_NAME) ctrlSetText "My First Restricted Arsenal";
