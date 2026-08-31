#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
private _list = _display displayCtrl RACA_IDC_HISTORY_LIST;
private _row = lnbCurSelRow _list;
private _history = _display getVariable ["RACA_historyEntries", []];
private _entryIndex = if (_row < 0) then {-1} else {parseNumber (_list lnbData [_row, 0])};
private _entry = _history param [_entryIndex, []];
if (_entry isEqualTo []) exitWith {false};
private _name = _display getVariable ["RACA_historyPresetName", ""];
private _parent = _display getVariable ["RACA_parentCreator", displayNull];
private _confirmed = [
    format ["Restore archived revision %1 of '%2'? The current version will be archived first and the restored contents will become a new revision.", _entry param [4, 0], _name],
    "Restore RACA Preset Revision", "RESTORE", "CANCEL", _display
] call BIS_fnc_guiMessage;
if (!_confirmed) exitWith {false};
uiSleep 0.01;
private _activeHistory = findDisplay RACA_IDD_HISTORY;
if (!isNull _activeHistory) then {_display = _activeHistory};
private _activeCreator = findDisplay RACA_IDD_CREATOR;
if (!isNull _activeCreator) then {_parent = _activeCreator};
private _library = call RACA_fnc_getPresetLibrary;
private _currentIndex = _library findIf {toLowerANSI (_x select 2) isEqualTo toLowerANSI _name};
if (_currentIndex < 0) exitWith {false};
private _current = _library select _currentIndex;
[_current, format ["Before restoring revision %1", _entry param [4, 0]]] call RACA_fnc_archivePreset;
private _restored = +(_entry param [8, []]);
_restored set [2, _name];
private _nextRevision = ((([_current] call RACA_fnc_getRuntimePolicy) select 4) + 1) max 1;
private _catalog = uiNamespace getVariable ["RACA_itemCatalog", []];
_restored = [_restored, format ["Restored archived revision %1", _entry param [4, 0]], _catalog, _nextRevision] call RACA_fnc_setPresetRevision;
_library set [_currentIndex, _restored];
profileNamespace setVariable ["RACA_presetLibrary_v1", _library];
saveProfileNamespace;
if (!isNull _display) then {_display closeDisplay 1};
if (!isNull _parent) then {
    [_parent] call RACA_fnc_refreshPresetCombo;
    private _combo = _parent displayCtrl RACA_IDC_PRESET_LIST;
    _combo lbSetCurSel (_currentIndex + 1);
    [_parent] call RACA_fnc_loadSelectedPreset;
    [_parent, format ["Restored '%1' as revision %2. The previous current revision remains in history.", _name, _nextRevision]] call RACA_fnc_setStatus;
};
true
