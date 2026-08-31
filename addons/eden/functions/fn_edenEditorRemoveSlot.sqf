params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
private _index = _display getVariable ["RACA_currentSlot", -1];
private _config = _display getVariable ["RACA_workingConfig", []];
private _slots = _config param [2, []];
if (_index < 0 || {_index >= count _slots}) exitWith {false};
_slots deleteAt _index;
_config set [2, _slots];
_display setVariable ["RACA_workingConfig", _config];
_display setVariable ["RACA_currentSlot", -1];
[_display, (_index min ((count _slots) - 1)) max 0] call RACA_fnc_edenEditorRefresh;
true
