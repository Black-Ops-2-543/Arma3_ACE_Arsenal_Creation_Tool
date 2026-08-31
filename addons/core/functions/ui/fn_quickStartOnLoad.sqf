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

private _populatePolicy = {
    params ["_control", "_choices"];
    lbClear _control;
    {
        _x params ["_label", "_data"];
        private _index = _control lbAdd _label;
        _control lbSetData [_index, _data];
    } forEach _choices;
};
[
    _display displayCtrl RACA_IDC_QUICK_OPTICS,
    [["Keep starter / pack optics", "DEFAULT"], ["Add matching loaded optics", "ADD"], ["Exclude matching optics", "EXCLUDE"]]
] call _populatePolicy;
[
    _display displayCtrl RACA_IDC_QUICK_SUPPRESSORS,
    [["Keep starter / pack suppressors", "DEFAULT"], ["Add matching loaded suppressors", "ADD"], ["Exclude matching suppressors", "EXCLUDE"]]
] call _populatePolicy;
[
    _display displayCtrl RACA_IDC_QUICK_NVG,
    [["Keep starter / pack night vision", "DEFAULT"], ["Add loaded night vision", "ADD"], ["Exclude night vision", "EXCLUDE"]]
] call _populatePolicy;
[
    _display displayCtrl RACA_IDC_QUICK_MEDICAL,
    [["Keep starter / pack medical items", "DEFAULT"], ["Add basic loaded medical items", "BASIC"], ["Add all matching medical items", "ALL"], ["Exclude matching medical items", "EXCLUDE"]]
] call _populatePolicy;

private _settings = profileNamespace getVariable ["RACA_generatorParameters_v1", ["RACA_GENERATOR", 1, "rifleman", "", "DEFAULT", "DEFAULT", "DEFAULT", "DEFAULT"]];
if !(
    _settings isEqualType [] &&
    {(count _settings) >= 8} &&
    {(_settings param [0, "", [""]]) isEqualTo "RACA_GENERATOR"} &&
    {(_settings param [1, -1, [0]]) isEqualTo 1}
) then {
    _settings = ["RACA_GENERATOR", 1, "rifleman", "", "DEFAULT", "DEFAULT", "DEFAULT", "DEFAULT"];
};
private _selectData = {
    params ["_control", "_data", ["_fallback", 0, [0]]];
    private _match = _fallback;
    for "_i" from 0 to ((lbSize _control) - 1) do {
        if ((_control lbData _i) isEqualTo _data) exitWith {_match = _i};
    };
    _control lbSetCurSel _match;
};
[_combo, _settings param [2, "rifleman", [""]], 1] call _selectData;
[_sourceCombo, _settings param [3, "", [""]]] call _selectData;
[_display displayCtrl RACA_IDC_QUICK_OPTICS, _settings param [4, "DEFAULT", [""]]] call _selectData;
[_display displayCtrl RACA_IDC_QUICK_SUPPRESSORS, _settings param [5, "DEFAULT", [""]]] call _selectData;
[_display displayCtrl RACA_IDC_QUICK_NVG, _settings param [6, "DEFAULT", [""]]] call _selectData;
[_display displayCtrl RACA_IDC_QUICK_MEDICAL, _settings param [7, "DEFAULT", [""]]] call _selectData;
(_display displayCtrl RACA_IDC_QUICK_NAME) ctrlSetText "My First Restricted Arsenal";
