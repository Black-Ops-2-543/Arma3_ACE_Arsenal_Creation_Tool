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

private _current = [_display] call RACA_fnc_captureCreatorState;
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
uiNamespace setVariable ["RACA_selectionRevision",(uiNamespace getVariable ["RACA_selectionRevision",0])+1];
uiNamespace setVariable ["RACA_builderLimits", _nextLimits];
uiNamespace setVariable ["RACA_limitsRevision",(uiNamespace getVariable ["RACA_limitsRevision",0])+1];
uiNamespace setVariable ["RACA_builderComposition", +(_state select 2)];
uiNamespace setVariable ["RACA_builderInherited", _inheritedMap];
uiNamespace setVariable ["RACA_inheritedRevision",(uiNamespace getVariable ["RACA_inheritedRevision",0])+1];
if ((_state param [4, ""]) isEqualTo "RACA_CREATOR_STATE") then {
    (_display displayCtrl RACA_IDC_PRESET_NAME) ctrlSetText (_state select 6);
    uiNamespace setVariable ["RACA_builderRawPreset", +(_state select 7)];
    uiNamespace setVariable ["RACA_builderOrigin", _state select 8];
};
// History restoration is an unsaved change relative to the current library.
// It must never silently discard a previously dirty draft's recovery record.
[_display] call RACA_fnc_queueDraftRecovery;
[_display] call RACA_fnc_refreshBaseCombo;
[_display] call RACA_fnc_refreshCategoryCombo;
[_display] call RACA_fnc_refreshItemList;
[_display] call RACA_fnc_refreshHistoryButtons;
[_display, ["Redid the last creator change.", "Undid the last creator change."] select _undoing] call RACA_fnc_setStatus;
true
