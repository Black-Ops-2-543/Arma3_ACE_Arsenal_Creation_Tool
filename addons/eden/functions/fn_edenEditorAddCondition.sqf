#include "..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
if !([_display, -1, false] call RACA_fnc_edenEditorCommitSlot) exitWith {false};
private _index = _display getVariable ["RACA_currentSlot", -1];
private _configurations = +(_display getVariable ["RACA_workingConfigurations", []]);
if (_index < 0 || {_index >= count _configurations}) exitWith {false};

private _kindCombo = _display displayCtrl RACA_EDEN_IDC_CONDITION_KIND;
private _kind = _kindCombo lbData (lbCurSel _kindCombo);
private _value = trim ctrlText (_display displayCtrl RACA_EDEN_IDC_CONDITION_VALUE);
if (_kind isEqualTo "" || {_value isEqualTo ""}) exitWith {
    (_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText "Choose a condition type and enter an exact value.";
    false
};
private _maximumLength = [256, 64] select (_kind isEqualTo "uid");
if ((count _value) > _maximumLength) exitWith {
    (_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText format ["%1 values are limited to %2 characters.", toUpperANSI _kind, _maximumLength];
    false
};

private _configuration = _configurations select _index;
private _access = +(_configuration select 4);
private _conditions = +(_access param [3, [], [[]]]);
_conditions pushBackUnique [_kind, _value];
_access set [3, _conditions];
_configuration set [4, [_access] call RACA_fnc_normalizeAccess];
_configurations set [_index, _configuration];
_display setVariable ["RACA_workingConfigurations", _configurations];
_display setVariable ["RACA_configurationsDirty", true];
(_display displayCtrl RACA_EDEN_IDC_CONDITION_VALUE) ctrlSetText "";
_display setVariable ["RACA_currentSlot", -1];
[_display, _index] call RACA_fnc_edenEditorRefresh;
true
