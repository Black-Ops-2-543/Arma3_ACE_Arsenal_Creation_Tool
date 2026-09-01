#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {};
private _undo = _display displayCtrl RACA_IDC_UNDO;
private _redo = _display displayCtrl RACA_IDC_REDO;
private _history = _display displayCtrl RACA_IDC_HISTORY;
private _compare = _display displayCtrl RACA_IDC_COMPARE_DRAFT;
private _analysisCombo = _display displayCtrl RACA_IDC_PRESET_TOOL;
private _savedCombo = _display displayCtrl RACA_IDC_PRESET_LIST;
private _selectedPresetIndex = lbCurSel _analysisCombo;
if (_selectedPresetIndex <= 0) then {_selectedPresetIndex = lbCurSel _savedCombo;};
private _selectedPreset = if (_selectedPresetIndex > 0) then {_analysisCombo lbData _selectedPresetIndex} else {""};
private _hasPreset = _selectedPreset isNotEqualTo "";

_undo ctrlEnable true;
_redo ctrlEnable true;
_history ctrlEnable _hasPreset;
_compare ctrlEnable _hasPreset;
[_display] call RACA_fnc_updateSummary;
