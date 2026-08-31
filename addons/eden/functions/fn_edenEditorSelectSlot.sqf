#include "..\script_component.hpp"
params [["_list", controlNull, [controlNull]], ["_index", -1, [0]]];
if (isNull _list || {_index < 0}) exitWith {};
private _display = ctrlParent _list;
if (_display getVariable ["RACA_editorRefreshing", false]) exitWith {};
private _previous = _display getVariable ["RACA_currentSlot", -1];
private _canLeavePrevious = true;
if (_previous >= 0 && {_previous isNotEqualTo _index}) then {
    _canLeavePrevious = [_display, _previous, false] call RACA_fnc_edenEditorCommitSlot;
};
if (!_canLeavePrevious) exitWith {
    _display setVariable ["RACA_editorRefreshing", true];
    _list lbSetCurSel _previous;
    _display setVariable ["RACA_editorRefreshing", false];
};
private _config = _display getVariable ["RACA_workingConfig", []];
private _slot = (_config param [2, []]) param [_index, []];
if (_slot isEqualTo []) exitWith {};
_display setVariable ["RACA_currentSlot", _index];
_slot params ["", "_name", "_preset", "_enabled", "_access", "", "_icon", "_hideDenied"];
(_display displayCtrl RACA_EDEN_IDC_SLOT_NAME) ctrlSetText _name;
(_display displayCtrl RACA_EDEN_IDC_SLOT_ENABLED) cbSetChecked _enabled;
(_display displayCtrl RACA_EDEN_IDC_SLOT_HIDE_DENIED) cbSetChecked _hideDenied;
(_display displayCtrl RACA_EDEN_IDC_SLOT_ICON) ctrlSetText _icon;
(_display displayCtrl RACA_EDEN_IDC_DENIAL_MESSAGE) ctrlSetText (_access param [5, "You are not authorized to use this arsenal."]);

private _presetCombo = _display displayCtrl RACA_EDEN_IDC_SLOT_PRESET;
lbClear _presetCombo;
private _presetOptions = _display getVariable ["RACA_presetOptions", []];
private _presetSelection = 0;
{
    private _row = _presetCombo lbAdd (_x select 2);
    if (_x isEqualTo _preset) then {_presetSelection = _row};
} forEach _presetOptions;
_presetCombo lbSetCurSel _presetSelection;
private _modeCombo = _display displayCtrl RACA_EDEN_IDC_ACCESS_MODE;
private _mode = toUpperANSI (_access param [2, "AND"]);
_modeCombo lbSetCurSel ((["AND", "OR"] find _mode) max 0);
private _conditionList = _display displayCtrl RACA_EDEN_IDC_CONDITION_LIST;
lbClear _conditionList;
{
    _x params ["_kind", "_value"];
    _conditionList lbAdd format ["%1 = %2", toUpperANSI _kind, _value];
} forEach (_access param [3, []]);
(_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText format ["Editing '%1'. Empty access rules allow everyone; AND/OR applies across all listed rules.", _name];
