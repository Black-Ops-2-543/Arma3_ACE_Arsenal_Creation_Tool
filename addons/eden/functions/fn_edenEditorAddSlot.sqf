#include "..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
if !([_display, -1, false] call RACA_fnc_edenEditorCommitSlot) exitWith {false};

private _presetOptions = _display getVariable ["RACA_presetOptions", []];
if (_presetOptions isEqualTo []) exitWith {
    (_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText "No saved RACA presets are available. Create or import a preset in the Creator before adding a configuration.";
    false
};
private _configurations = +(_display getVariable ["RACA_workingConfigurations", []]);
private _number = count _configurations + 1;
private _name = format ["Arsenal Configuration %1", _number];
while {_configurations findIf {toLowerANSI (_x select 1) isEqualTo toLowerANSI _name} >= 0} do {
    _number = _number + 1;
    _name = format ["Arsenal Configuration %1", _number];
};
private _id = [_configurations] call RACA_fnc_edenGenerateConfigurationId;
private _access = ["RACA_ACCESS", 1, "AND", [], false, "You are not authorized to use this arsenal.", []];
_configurations pushBack [_id, _name, +(_presetOptions select 0), "", _access];
_display setVariable ["RACA_workingConfigurations", _configurations];
_display setVariable ["RACA_configurationsDirty", true];
_display setVariable ["RACA_currentSlot", -1];
[_display, (count _configurations) - 1] call RACA_fnc_edenEditorRefresh;
true
