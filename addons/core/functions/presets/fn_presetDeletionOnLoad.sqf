#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};

private _pending = uiNamespace getVariable ["RACA_deletePresetPending", []];
if ((count _pending) < 2) exitWith {
    _display closeDisplay 2;
    false
};

_pending params ["_creator", "_preset"];
if (isNull _creator || {_preset isEqualTo []}) exitWith {
    _display closeDisplay 2;
    false
};

private _name = _preset param [2, "", [""]];
if (_name isEqualTo "") exitWith {
    _display closeDisplay 2;
    false
};

_display setVariable ["RACA_deletePresetCreator", _creator];
_display setVariable ["RACA_deletePresetValue", _preset];
(_display displayCtrl RACA_IDC_PRESET_DELETION_MESSAGE) ctrlSetText format ["Are you sure you want to delete %1?", _name];
true
