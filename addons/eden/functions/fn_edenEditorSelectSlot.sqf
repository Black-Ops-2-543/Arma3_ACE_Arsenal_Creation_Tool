#include "..\script_component.hpp"
disableSerialization;
params [["_list", controlNull, [controlNull]], ["_index", -1, [0]]];
if (isNull _list || {_index < 0}) exitWith {false};
private _display = ctrlParent _list;
if (isNull _display || {_display getVariable ["RACA_editorRefreshing", false]}) exitWith {false};

private _previous = _display getVariable ["RACA_currentSlot", -1];
private _canLeavePrevious = true;
if (_previous >= 0 && {_previous isNotEqualTo _index}) then {
    _canLeavePrevious = [_display, _previous, false] call RACA_fnc_edenEditorCommitSlot;
};
if (!_canLeavePrevious) exitWith {
    _display setVariable ["RACA_editorRefreshing", true];
    _list lbSetCurSel _previous;
    _display setVariable ["RACA_editorRefreshing", false];
    false
};

private _configurations = _display getVariable ["RACA_workingConfigurations", []];
private _configuration = _configurations param [_index, []];
if (_configuration isEqualTo []) exitWith {false};
_display setVariable ["RACA_currentSlot", _index];
_configuration params ["_id", "_name", "_preset", "_icon", "_access"];

(_display displayCtrl RACA_EDEN_IDC_SLOT_NAME) ctrlSetText _name;
(_display displayCtrl RACA_EDEN_IDC_SLOT_ICON) ctrlSetText _icon;
(_display displayCtrl RACA_EDEN_IDC_DENIAL_MESSAGE) ctrlSetText (_access param [5, "You are not authorized to use this arsenal."]);

private _presetCombo = _display displayCtrl RACA_EDEN_IDC_SLOT_PRESET;
lbClear _presetCombo;
private _presetOptions = _display getVariable ["RACA_presetOptions", []];
private _presetSelection = -1;
{
    private _row = _presetCombo lbAdd (_x param [2, "Unnamed preset", [""]]);
    _presetCombo lbSetValue [_row, _forEachIndex];
    _presetCombo lbSetTooltip [_row, format ["Use the standalone snapshot of preset '%1'.", _x param [2, "Unnamed preset", [""]]]];
    if (_x isEqualTo _preset) then {_presetSelection = _row};
} forEach _presetOptions;
if (_presetSelection < 0 && {_preset isNotEqualTo []}) then {
    _presetOptions pushBack _preset;
    private _row = _presetCombo lbAdd (_preset param [2, "Unnamed preset", [""]]);
    _presetCombo lbSetValue [_row, (count _presetOptions) - 1];
    _presetSelection = _row;
    _display setVariable ["RACA_presetOptions", _presetOptions];
};
if (_presetSelection >= 0) then {_presetCombo lbSetCurSel _presetSelection};

private _modeCombo = _display displayCtrl RACA_EDEN_IDC_ACCESS_MODE;
private _modeIndex = ["AND", "OR"] find toUpperANSI (_access param [2, "AND", [""]]);
_modeCombo lbSetCurSel (_modeIndex max 0);
private _conditionList = _display displayCtrl RACA_EDEN_IDC_CONDITION_LIST;
lbClear _conditionList;
{
    _x params ["_kind", "_value"];
    private _readableValue = if (_value isEqualType []) then {_value joinString ", "} else {str _value};
    if (_value isEqualType "") then {_readableValue = _value};
    _conditionList lbAdd format ["%1 = %2", toUpperANSI _kind, _readableValue];
} forEach (_access param [3, [], [[]]]);

(_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText format [
    "Editing '%1'. Empty access rules allow everyone; %2 requires %3 listed condition(s).",
    _name,
    toUpperANSI (_access param [2, "AND", [""]]),
    count (_access param [3, [], [[]]])
];
true
