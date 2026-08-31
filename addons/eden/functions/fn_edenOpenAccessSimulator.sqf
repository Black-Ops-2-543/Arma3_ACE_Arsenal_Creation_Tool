#include "..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];

if (isNull _display || {!is3DEN}) exitWith {false};
private _index = _display getVariable ["RACA_currentSlot", -1];
if (_index < 0) exitWith {
    (_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText "Add and select a slot before simulating access.";
    false
};
if !([_display, _index, false] call RACA_fnc_edenEditorCommitSlot) exitWith {false};

uiNamespace setVariable ["RACA_accessSimulatorParent", _display];
private _simulatorDisplay = _display createDisplay "RACA_RscDisplayAccessSimulator";
if (isNull _simulatorDisplay) exitWith {
    (_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText "The access-rule simulator could not be opened.";
    false
};
true
