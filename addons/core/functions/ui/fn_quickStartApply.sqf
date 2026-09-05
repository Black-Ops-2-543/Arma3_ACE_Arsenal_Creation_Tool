#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
private _parent = _display getVariable ["RACA_parentCreator", displayNull];
if (isNull _parent) exitWith {false};
private _name = ctrlText (_display displayCtrl RACA_IDC_QUICK_NAME);
if ((_name splitString (toString [9, 10, 13, 32])) isEqualTo []) exitWith {
    (_display displayCtrl RACA_IDC_QUICK_HELP) ctrlSetText "Enter a descriptive preset name first.";
    false
};
if ((count _name) > 128) exitWith {
    (_display displayCtrl RACA_IDC_QUICK_HELP) ctrlSetText "Preset names are limited to 128 characters.";
    false
};
[_parent] call RACA_fnc_pushCreatorHistory;
uiNamespace setVariable ["RACA_builderRawPreset", []];
uiNamespace setVariable ["RACA_builderOrigin", ""];
uiNamespace setVariable ["RACA_builderSelected", createHashMap];
uiNamespace setVariable ["RACA_selectionRevision",(uiNamespace getVariable ["RACA_selectionRevision",0])+1];
uiNamespace setVariable ["RACA_builderLimits", createHashMap];
uiNamespace setVariable ["RACA_limitsRevision",(uiNamespace getVariable ["RACA_limitsRevision",0])+1];
uiNamespace setVariable ["RACA_builderComposition", []];
uiNamespace setVariable ["RACA_builderInherited", createHashMap];
uiNamespace setVariable ["RACA_inheritedRevision",(uiNamespace getVariable ["RACA_inheritedRevision",0])+1];
private _roleCombo = _display displayCtrl RACA_IDC_QUICK_ROLE;
private _settingsOpen = _display getVariable ["RACA_quickSettingsOpen", false];
private _templateSetting = _roleCombo lbData (lbCurSel _roleCombo);
private _templateId = if (_settingsOpen) then {_templateSetting} else {""};
private _warnings = [];
private _sourceCombo = _display displayCtrl RACA_IDC_QUICK_SOURCE;
private _sourceSetting = _sourceCombo lbData (lbCurSel _sourceCombo);
private _source = if (_settingsOpen) then {_sourceSetting} else {""};
private _catalog = uiNamespace getVariable ["RACA_itemCatalog", []];
if (_source isNotEqualTo "") then {_catalog = _catalog select {(_x select 4) isEqualTo _source}};
if (_templateId isNotEqualTo "") then {
    private _result = [_templateId, _catalog, true] call RACA_fnc_applyRoleTemplate;
    _warnings = _result param [1, []];
};
private _readPolicy = {
    params ["_control"];
    private _index = lbCurSel _control;
    if (_index < 0) then {"DEFAULT"} else {_control lbData _index}
};
private _opticPolicy = [_display displayCtrl RACA_IDC_QUICK_OPTICS] call _readPolicy;
private _suppressorPolicy = [_display displayCtrl RACA_IDC_QUICK_SUPPRESSORS] call _readPolicy;
private _nvgPolicy = [_display displayCtrl RACA_IDC_QUICK_NVG] call _readPolicy;
private _medicalPolicy = [_display displayCtrl RACA_IDC_QUICK_MEDICAL] call _readPolicy;
private _savedPolicies = [_opticPolicy, _suppressorPolicy, _nvgPolicy, _medicalPolicy];
if (!_settingsOpen) then {
    _opticPolicy = "DEFAULT";
    _suppressorPolicy = "DEFAULT";
    _nvgPolicy = "DEFAULT";
    _medicalPolicy = "DEFAULT";
};
private _parameterResult = [
    _catalog,
    uiNamespace getVariable ["RACA_builderSelected", createHashMap],
    _opticPolicy,
    _suppressorPolicy,
    _nvgPolicy,
    _medicalPolicy
] call RACA_fnc_applyTemplateParameters;
uiNamespace setVariable ["RACA_builderSelected", _parameterResult select 0];
uiNamespace setVariable ["RACA_selectionRevision",(uiNamespace getVariable ["RACA_selectionRevision",0])+1];
_warnings append (_parameterResult select 1);
private _parameterActions = _parameterResult select 2;
profileNamespace setVariable [
    "RACA_generatorParameters_v1",
    ["RACA_GENERATOR", 1, _templateSetting, _sourceSetting, _savedPolicies select 0, _savedPolicies select 1, _savedPolicies select 2, _savedPolicies select 3]
];
saveProfileNamespace;
(_parent displayCtrl RACA_IDC_PRESET_NAME) ctrlSetText _name;
_display closeDisplay 1;
[_parent, "ASSIGNMENT"] call RACA_fnc_switchCreatorTab;
[_parent] call RACA_fnc_refreshCategoryCombo;
[_parent] call RACA_fnc_refreshItemList;
[_parent, format [
    "Quick Start generated the unsaved '%1' draft with %2 item(s), %3 active policy adjustment(s), and %4 notice(s). Review Arsenal Contents, check compatibility, then save.",
    _name,
    count (uiNamespace getVariable ["RACA_builderSelected", createHashMap]),
    count _parameterActions,
    count _warnings
]] call RACA_fnc_setStatus;
true
