#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
private _state = [_display] call RACA_fnc_captureCreatorState;
private _undo = uiNamespace getVariable ["RACA_creatorUndo", []];
if (_undo isEqualTo [] || {!((_undo select ((count _undo) - 1)) isEqualTo _state)}) then {_undo pushBack _state};
if ((count _undo) > 50) then {_undo deleteAt 0};
uiNamespace setVariable ["RACA_creatorUndo", _undo];
uiNamespace setVariable ["RACA_creatorRedo", []];
[_display] call RACA_fnc_queueDraftRecovery;
true
