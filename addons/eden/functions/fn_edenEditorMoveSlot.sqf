params [["_display", displayNull, [displayNull]], ["_direction", 0, [0]]];
if (isNull _display || {_direction isEqualTo 0}) exitWith {false};
[_display, -1, false] call RACA_fnc_edenEditorCommitSlot;
private _index = _display getVariable ["RACA_currentSlot", -1];
private _config = _display getVariable ["RACA_workingConfig", []];
private _slots = _config param [2, []];
private _next = _index + _direction;
if (_index < 0 || {_next < 0} || {_next >= count _slots}) exitWith {false};
private _swap = _slots select _next;
_slots set [_next, _slots select _index];
_slots set [_index, _swap];
_config set [2, _slots];
_display setVariable ["RACA_workingConfig", _config];
_display setVariable ["RACA_currentSlot", -1];
[_display, _next] call RACA_fnc_edenEditorRefresh;
true
