#include "..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]], ["_preferred", -1, [0]]];
if (isNull _display) exitWith {false};

private _configurations = _display getVariable ["RACA_workingConfigurations", []];
private _list = _display displayCtrl RACA_EDEN_IDC_SLOT_LIST;
_display setVariable ["RACA_editorRefreshing", true];
lbClear _list;
{
    private _presetName = (_x select 2) param [2, "Unnamed preset", [""]];
    private _row = _list lbAdd format ["%1  -  %2", _x select 1, _presetName];
    _list lbSetData [_row, _x select 0];
    _list lbSetTooltip [_row, format ["Configuration '%1' uses preset '%2'.", _x select 1, _presetName]];
} forEach _configurations;

private _editingControls = [
    RACA_EDEN_IDC_SLOT_NAME,
    RACA_EDEN_IDC_SLOT_PRESET,
    RACA_EDEN_IDC_SLOT_ICON,
    RACA_EDEN_IDC_ACCESS_MODE,
    RACA_EDEN_IDC_DENIAL_MESSAGE,
    RACA_EDEN_IDC_CONDITION_LIST,
    RACA_EDEN_IDC_CONDITION_KIND,
    RACA_EDEN_IDC_CONDITION_VALUE,
    RACA_EDEN_IDC_CONFIG_SAVE,
    RACA_EDEN_IDC_CONFIG_DELETE,
    RACA_EDEN_IDC_SIMULATE_ACCESS
];
private _hasConfiguration = _configurations isNotEqualTo [];
{(_display displayCtrl _x) ctrlEnable _hasConfiguration} forEach _editingControls;

if (!_hasConfiguration) then {
    _display setVariable ["RACA_currentSlot", -1];
    (_display displayCtrl RACA_EDEN_IDC_SLOT_NAME) ctrlSetText "";
    lbClear (_display displayCtrl RACA_EDEN_IDC_SLOT_PRESET);
    (_display displayCtrl RACA_EDEN_IDC_SLOT_ICON) ctrlSetText "";
    lbClear (_display displayCtrl RACA_EDEN_IDC_CONDITION_LIST);
    (_display displayCtrl RACA_EDEN_IDC_DENIAL_MESSAGE) ctrlSetText "";
    (_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText "No Arsenal Configurations exist yet. Choose Add Configuration to create one from a saved RACA preset.";
    _display setVariable ["RACA_editorRefreshing", false];
    true
} else {
    private _selection = if (_preferred < 0) then {0} else {_preferred min ((count _configurations) - 1)};
    _list lbSetCurSel _selection;
    _display setVariable ["RACA_editorRefreshing", false];
    [_list, _selection] call RACA_fnc_edenEditorSelectSlot;
    true
}
