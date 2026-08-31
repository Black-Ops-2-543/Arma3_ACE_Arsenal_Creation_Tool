#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {};
_display setVariable ["RACA_parentCreator", uiNamespace getVariable ["RACA_quickStartParent", displayNull]];
private _combo = _display displayCtrl RACA_IDC_QUICK_ROLE;
lbClear _combo;
private _blank = _combo lbAdd "Blank preset — choose every item yourself";
_combo lbSetData [_blank, ""];
{
    private _label = if ((_x param [4, "RULES", [""]]) isEqualTo "PACK") then {
        format ["%1 custom pack", _x select 1]
    } else {
        format ["%1 starter", _x select 1]
    };
    private _index = _combo lbAdd _label;
    _combo lbSetData [_index, _x select 0];
    _combo lbSetTooltip [_index, _x select 2];
} forEach call RACA_fnc_getRoleTemplates;
_combo lbSetCurSel 1;
private _sourceCombo = _display displayCtrl RACA_IDC_QUICK_SOURCE;
lbClear _sourceCombo;
private _all = _sourceCombo lbAdd "All loaded sources";
_sourceCombo lbSetData [_all, ""];
private _sources = [];
{_sources pushBackUnique (_x param [4, "Unknown"])} forEach (uiNamespace getVariable ["RACA_itemCatalog", []]);
_sources = _sources select {_x isNotEqualTo ""};
_sources sort true;
{
    private _index = _sourceCombo lbAdd _x;
    _sourceCombo lbSetData [_index, _x];
} forEach _sources;
_sourceCombo lbSetCurSel 0;
(_display displayCtrl RACA_IDC_QUICK_NAME) ctrlSetText "My First Restricted Arsenal";
