#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
private _parent = _display getVariable ["RACA_parentCreator", displayNull];
if (isNull _parent) exitWith {false};
private _name = ctrlText (_display displayCtrl RACA_IDC_QUICK_NAME);
if (_name isEqualTo "") exitWith {
    (_display displayCtrl RACA_IDC_HISTORY_DETAILS) ctrlSetText "Enter a descriptive preset name first.";
    false
};
[_parent] call RACA_fnc_pushCreatorHistory;
uiNamespace setVariable ["RACA_builderSelected", createHashMap];
uiNamespace setVariable ["RACA_builderLimits", createHashMap];
uiNamespace setVariable ["RACA_builderComposition", []];
uiNamespace setVariable ["RACA_builderInherited", createHashMap];
private _roleCombo = _display displayCtrl RACA_IDC_QUICK_ROLE;
private _templateId = _roleCombo lbData (lbCurSel _roleCombo);
private _warnings = [];
if (_templateId isNotEqualTo "") then {
    private _sourceCombo = _display displayCtrl RACA_IDC_QUICK_SOURCE;
    private _source = _sourceCombo lbData (lbCurSel _sourceCombo);
    private _catalog = uiNamespace getVariable ["RACA_itemCatalog", []];
    if (_source isNotEqualTo "") then {_catalog = _catalog select {(_x select 4) isEqualTo _source}};
    private _result = [_templateId, _catalog, true] call RACA_fnc_applyRoleTemplate;
    _warnings = _result param [1, []];
};
(_parent displayCtrl RACA_IDC_PRESET_NAME) ctrlSetText _name;
_display closeDisplay 1;
[_parent, "ASSIGNMENT"] call RACA_fnc_switchCreatorTab;
[_parent] call RACA_fnc_refreshCategoryCombo;
[_parent] call RACA_fnc_refreshItemList;
[_parent, format ["Quick Start created the unsaved '%1' draft with %2 suggested items. Review the list, run preflight, then save.%3", _name, count (uiNamespace getVariable ["RACA_builderSelected", createHashMap]), if (_warnings isEqualTo []) then {""} else {format [" %1 starter rule(s) had no match in the loaded mod set.", count _warnings]}]] call RACA_fnc_setStatus;
true
