#include "..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
if !([_display, -1, false] call RACA_fnc_edenEditorCommitSlot) exitWith {false};
private _configurationIndex = _display getVariable ["RACA_currentSlot", -1];
private _conditionIndex = lbCurSel (_display displayCtrl RACA_EDEN_IDC_CONDITION_LIST);
private _configurations = +(_display getVariable ["RACA_workingConfigurations", []]);
if (_configurationIndex < 0 || {_configurationIndex >= count _configurations} || {_conditionIndex < 0}) exitWith {false};
private _configuration = _configurations select _configurationIndex;
private _access = +(_configuration select 4);
private _conditions = +(_access param [3, [], [[]]]);
if (_conditionIndex >= count _conditions) exitWith {false};
_conditions deleteAt _conditionIndex;
_access set [3, _conditions];
_configuration set [4, [_access] call RACA_fnc_normalizeAccess];
_configurations set [_configurationIndex, _configuration];
_display setVariable ["RACA_workingConfigurations", _configurations];
_display setVariable ["RACA_configurationsDirty", true];
_display setVariable ["RACA_currentSlot", -1];
[_display, _configurationIndex] call RACA_fnc_edenEditorRefresh;
true
