#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
private _selected = keys (uiNamespace getVariable ["RACA_builderSelected", createHashMap]);
private _inherited = keys (uiNamespace getVariable ["RACA_builderInherited", createHashMap]);
private _limitsMap = uiNamespace getVariable ["RACA_builderLimits", createHashMap];
private _limits = [];
{_limits pushBack +(_limitsMap get _x)} forEach keys _limitsMap;
_selected sort true;
_inherited sort true;
_limits sort true;
private _state = [_selected, _limits, +(uiNamespace getVariable ["RACA_builderComposition", []]), _inherited];
private _undo = uiNamespace getVariable ["RACA_creatorUndo", []];
if (_undo isEqualTo [] || {!((_undo select ((count _undo) - 1)) isEqualTo _state)}) then {_undo pushBack _state};
if ((count _undo) > 50) then {_undo deleteAt 0};
uiNamespace setVariable ["RACA_creatorUndo", _undo];
uiNamespace setVariable ["RACA_creatorRedo", []];
[_display] call RACA_fnc_queueDraftRecovery;
true
