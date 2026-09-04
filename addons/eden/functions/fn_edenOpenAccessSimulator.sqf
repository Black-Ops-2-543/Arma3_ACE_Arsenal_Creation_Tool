#include "..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display || {!is3DEN}) exitWith {false};
private _index = _display getVariable ["RACA_currentSlot", -1];
if (_index < 0) exitWith {
    (_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText "Add and select an Arsenal Configuration before testing access.";
    false
};
if !([_display, _index, false] call RACA_fnc_edenEditorCommitSlot) exitWith {false};
private _configuration = (_display getVariable ["RACA_workingConfigurations", []]) param [_index, []];
private _objectConfig = [_configuration] call RACA_fnc_edenConfigurationToObjectConfig;
private _slot = (_objectConfig param [2, [], [[]]]) param [0, []];
if (_slot isEqualTo []) exitWith {
    (_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText "This configuration cannot be simulated until it has a valid preset.";
    false
};
_display setVariable ["RACA_simulatorSlot", _slot];
uiNamespace setVariable ["RACA_accessSimulatorParent", _display];
private _simulatorDisplay = _display createDisplay "RACA_RscDisplayAccessSimulator";
if (isNull _simulatorDisplay) exitWith {
    (_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText "The access-rule simulator could not be opened.";
    false
};
true
