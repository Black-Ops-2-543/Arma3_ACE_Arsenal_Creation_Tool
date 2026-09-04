#include "..\..\script_component.hpp"
params [
    ["_display", displayNull, [displayNull]],
    ["_comboIdc", RACA_IDC_PRESET_TOOL, [0]]
];
if (isNull _display) exitWith {};
private _analysisComboId = if (_comboIdc isEqualTo RACA_IDC_PRESET_TOOL) then {_comboIdc} else {RACA_IDC_PRESET_TOOL};
private _undo = _display displayCtrl RACA_IDC_UNDO;
private _redo = _display displayCtrl RACA_IDC_REDO;
private _history = _display displayCtrl RACA_IDC_HISTORY;
private _compare = _display displayCtrl RACA_IDC_COMPARE_DRAFT;
private _analysisCombo = _display displayCtrl _analysisComboId;
if (isNull _analysisCombo) exitWith {};
private _selectedPresetIndex = lbCurSel _analysisCombo;
private _selectedPreset = if (_selectedPresetIndex > 0) then {_analysisCombo lbData _selectedPresetIndex} else {""};
private _hasPreset = _selectedPreset isNotEqualTo "";

_undo ctrlEnable ((uiNamespace getVariable ["RACA_creatorUndo", []]) isNotEqualTo []);
_redo ctrlEnable ((uiNamespace getVariable ["RACA_creatorRedo", []]) isNotEqualTo []);
_history ctrlEnable _hasPreset;
_compare ctrlEnable _hasPreset;
[_display] call RACA_fnc_updateSummary;
