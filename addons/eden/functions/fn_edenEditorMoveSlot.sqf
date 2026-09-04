#include "..\script_component.hpp"
params [["_display", displayNull, [displayNull]], ["_direction", 0, [0]]];
if (isNull _display || {_direction isEqualTo 0}) exitWith {false};
if !([_display, -1, false] call RACA_fnc_edenEditorCommitSlot) exitWith {false};
private _index = _display getVariable ["RACA_currentSlot", -1];
private _configurations = +(_display getVariable ["RACA_workingConfigurations", []]);
private _next = _index + _direction;
if (_index < 0 || {_next < 0} || {_next >= count _configurations}) exitWith {false};
private _swap = _configurations select _next;
_configurations set [_next, _configurations select _index];
_configurations set [_index, _swap];
_display setVariable ["RACA_workingConfigurations", _configurations];
_display setVariable ["RACA_configurationsDirty", true];
_display setVariable ["RACA_currentSlot", -1];
[_display, _next] call RACA_fnc_edenEditorRefresh;
true
