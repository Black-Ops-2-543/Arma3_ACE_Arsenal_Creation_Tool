#include "..\..\script_component.hpp"
params [
    ["_display", displayNull, [displayNull]],
    ["_direction", "UNDO", [""]]
];
if (isNull _display) exitWith {false};
private _undoing = toUpperANSI _direction isEqualTo "UNDO";
private _sourceKey = ["RACA_creatorRedo", "RACA_creatorUndo"] select _undoing;
private _targetKey = ["RACA_creatorUndo", "RACA_creatorRedo"] select _undoing;
private _source = uiNamespace getVariable [_sourceKey, []];
if (_source isEqualTo []) exitWith {
    [_display, ["Nothing is available to redo yet.", "Nothing is available to undo yet. Make a change in Arsenal Contents first."] select _undoing] call RACA_fnc_setStatus;
    false
};

private _selected = keys (uiNamespace getVariable ["RACA_builderSelected", createHashMap]);
private _inherited = keys (uiNamespace getVariable ["RACA_builderInherited", createHashMap]);
private _limitsMap = uiNamespace getVariable ["RACA_builderLimits", createHashMap];
private _limits = [];
{_limits pushBack +(_limitsMap get _x)} forEach keys _limitsMap;
_selected sort true;
_inherited sort true;
_limits sort true;
private _current = [_selected, _limits, +(uiNamespace getVariable ["RACA_builderComposition", []]), _inherited];
private _target = uiNamespace getVariable [_targetKey, []];
_target pushBack _current;
private _state = _source deleteAt ((count _source) - 1);
uiNamespace setVariable [_sourceKey, _source];
uiNamespace setVariable [_targetKey, _target];

private _selectedMap = createHashMap;
{_selectedMap set [_x, true]} forEach (_state select 0);
private _nextLimits = createHashMap;
{_nextLimits set [_x select 0, +_x]} forEach (_state select 1);
private _inheritedMap = createHashMap;
{_inheritedMap set [_x, true]} forEach (_state select 3);
uiNamespace setVariable ["RACA_builderSelected", _selectedMap];
uiNamespace setVariable ["RACA_builderLimits", _nextLimits];
uiNamespace setVariable ["RACA_builderComposition", +(_state select 2)];
uiNamespace setVariable ["RACA_builderInherited", _inheritedMap];
[_display] call RACA_fnc_queueDraftRecovery;
[_display] call RACA_fnc_refreshBaseCombo;
[_display] call RACA_fnc_refreshCategoryCombo;
[_display] call RACA_fnc_refreshItemList;
[_display] call RACA_fnc_refreshHistoryButtons;
[_display, ["Redid the last creator change.", "Undid the last creator change."] select _undoing] call RACA_fnc_setStatus;
true
