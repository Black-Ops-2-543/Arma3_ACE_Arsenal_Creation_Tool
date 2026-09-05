#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};

private _record = profileNamespace getVariable ["RACA_creatorDraftRecovery_v1", []];
if !(_record isEqualType [] && {(count _record) >= 6}) exitWith {false};
if ((_record param [0, "", [""]]) isNotEqualTo "RACA_DRAFT_RECOVERY" ||
    {(_record param [1, -1, [0]]) isNotEqualTo 1}) exitWith {
    call RACA_fnc_clearDraftRecovery;
    [_display, "An incompatible creator recovery record was safely discarded."] call RACA_fnc_setStatus;
    false
};

private _rawName = _record param [2, "", [""]];
private _rawPreset = _record param [3, [], [[]]];
private _rawComposition = _record param [4, [], [[]]];
private _candidate = +_rawPreset;
if (_rawComposition isNotEqualTo [] && {([_candidate] call RACA_fnc_getComposition) isEqualTo []}) then {_candidate pushBack _rawComposition};
([_candidate] call RACA_fnc_validatePreset) params ["_preset", "_warnings"];
if (_preset isEqualTo []) exitWith {
    call RACA_fnc_clearDraftRecovery;
    [_display, "An invalid creator recovery record was safely discarded."] call RACA_fnc_setStatus;
    false
};

private _stamp = _record param [5, [], [[]]];
private _stampText = if ((count _stamp) >= 5) then {
    format ["%1-%2-%3 %4:%5 UTC", _stamp select 0, _stamp select 1, _stamp select 2, _stamp select 3, _stamp select 4]
} else {
    "an earlier session"
};
private _itemCount = 0;
{_itemCount = _itemCount + count _x} forEach (_preset select 3);
private _restore = [
    format ["RACA recovered an unsaved draft from %1 with %2 item(s). Restore it now?", _stampText, _itemCount],
    "Unsaved RACA Draft Found",
    "RESTORE DRAFT",
    "DISCARD DRAFT",
    _display
] call BIS_fnc_guiMessage;
_display = findDisplay RACA_IDD_CREATOR;
if (isNull _display) exitWith {false};

if (!_restore) exitWith {
    call RACA_fnc_clearDraftRecovery;
    [_display, "Discarded the recovered draft. Saved presets were not changed."] call RACA_fnc_setStatus;
    true
};

private _catalog = uiNamespace getVariable ["RACA_itemCatalog", []];
private _available = createHashMap;
{_available set [_x select 1, true]} forEach _catalog;
private _selected = createHashMap;
private _missing = [];
{
    {
        if (_available getOrDefault [_x, false]) then {
            _selected set [_x, true];
        } else {
            _missing pushBack _x;
            _selected set [_x, true];
        };
    } forEach _x;
} forEach (_preset select 3);
    uiNamespace setVariable ["RACA_builderSelected", _selected];
    uiNamespace setVariable ["RACA_selectionRevision",(uiNamespace getVariable ["RACA_selectionRevision",0])+1];
uiNamespace setVariable ["RACA_builderRawPreset", +_preset];
uiNamespace setVariable ["RACA_builderOrigin", _record param [6, "", [""]]];

private _composition = [_preset] call RACA_fnc_getComposition;
uiNamespace setVariable ["RACA_builderComposition", _composition];
private _sourceItems = createHashMap;
if (_composition isNotEqualTo []) then {
    {_sourceItems set [_x, true]} forEach keys _selected;
    {{_sourceItems deleteAt _x} forEach _x} forEach (_composition select 4);
    {_sourceItems set [_x, true]} forEach (_composition select 5);
};
    uiNamespace setVariable ["RACA_builderInherited", _sourceItems];
    uiNamespace setVariable ["RACA_inheritedRevision",(uiNamespace getVariable ["RACA_inheritedRevision",0])+1];

private _limits = createHashMap;
{
    private _key = _x select 0;
    if ((toLowerANSI _key find "category:") isEqualTo 0 || {_selected getOrDefault [_key, false]}) then {
        _limits set [_key, +_x];
    };
} forEach (([_preset] call RACA_fnc_getRuntimePolicy) select 2);
uiNamespace setVariable ["RACA_builderLimits", _limits];

(_display displayCtrl RACA_IDC_PRESET_NAME) ctrlSetText _rawName;
uiNamespace setVariable ["RACA_creatorUndo", []];
uiNamespace setVariable ["RACA_creatorRedo", []];
uiNamespace setVariable ["RACA_creatorDirty", true];
uiNamespace setVariable ["RACA_creatorDiscarding", false];
[_display] call RACA_fnc_refreshBaseCombo;
[_display] call RACA_fnc_refreshPresetCombo;
[_display] call RACA_fnc_refreshCategoryCombo;
[_display] call RACA_fnc_refreshItemList;
[_display] call RACA_fnc_updateSummary;
[_display] call RACA_fnc_runCreatorDiagnostics;
[_display] call RACA_fnc_refreshHistoryButtons;
[_display] call RACA_fnc_saveDraftRecovery;
private _missingSuffix = if (_missing isEqualTo []) then {""} else {
    format [" %1 class(es) from unloaded mods were preserved as unavailable.", count _missing]
};
private _noticeSuffix = if (_warnings isEqualTo []) then {""} else {
    format [" %1 validation notice(s) were handled.", count _warnings]
};
[_display, format ["Restored the unsaved draft with %1 authored item(s).%2%3", count _selected, _missingSuffix, _noticeSuffix]] call RACA_fnc_setStatus;
true
