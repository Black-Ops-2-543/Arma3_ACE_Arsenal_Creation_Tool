#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};

private _creator = _display getVariable ["RACA_deletePresetCreator", displayNull];
private _preset = _display getVariable ["RACA_deletePresetValue", []];
private _name = _preset param [2, "", [""]];
if (isNull _creator || {_name isEqualTo ""}) exitWith {
    _display closeDisplay 2;
    false
};

if !([_preset] call RACA_fnc_removePresetFromLibrary) exitWith {
    _display closeDisplay 2;
    [_creator] call RACA_fnc_refreshPresetCombo;
    [_creator, format ["'%1' could not be deleted because the profile library changed. Refresh and try again.", _name]] call RACA_fnc_setStatus;
    false
};

uiNamespace setVariable ["RACA_creatorDirty", true];
private _recoveryName = (_name select [0, 116]) + " (Recovered)";
(_creator displayCtrl RACA_IDC_PRESET_NAME) ctrlSetText _recoveryName;
[_creator] call RACA_fnc_refreshPresetCombo;
[_creator] call RACA_fnc_queueDraftRecovery;
[_creator, format ["Deleted '%1'. Current items remain available as an unsaved recovery copy.", _name]] call RACA_fnc_setStatus;

uiNamespace setVariable ["RACA_deletePresetPending", nil];
_display closeDisplay 1;
true
