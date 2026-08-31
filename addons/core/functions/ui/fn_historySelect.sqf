#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
private _list = _display displayCtrl RACA_IDC_HISTORY_LIST;
private _row = lnbCurSelRow _list;
private _history = _display getVariable ["RACA_historyEntries", []];
private _entryIndex = if (_row < 0) then {-1} else {parseNumber (_list lnbData [_row, 0])};
private _entry = _history param [_entryIndex, []];
if (_entry isEqualTo []) exitWith {(_display displayCtrl RACA_IDC_HISTORY_RESTORE) ctrlEnable false; false};
private _snapshot = _entry param [8, []];
private _library = call RACA_fnc_getPresetLibrary;
private _name = _display getVariable ["RACA_historyPresetName", ""];
private _currentIndex = _library findIf {toLowerANSI (_x select 2) isEqualTo toLowerANSI _name};
private _current = _library param [_currentIndex, []];
private _snapshotClasses = createHashMap;
{_snapshotClasses set [_x, true]} forEach ([_snapshot] call RACA_fnc_flattenPresetClasses);
private _currentClasses = createHashMap;
{_currentClasses set [_x, true]} forEach ([_current] call RACA_fnc_flattenPresetClasses);
private _wouldAdd = (keys _snapshotClasses) select {!(_currentClasses getOrDefault [_x, false])};
private _wouldRemove = (keys _currentClasses) select {!(_snapshotClasses getOrDefault [_x, false])};
private _snapshotLimits = ([_snapshot] call RACA_fnc_getRuntimePolicy) select 2;
private _currentLimits = ([_current] call RACA_fnc_getRuntimePolicy) select 2;
(_display displayCtrl RACA_IDC_HISTORY_DETAILS) ctrlSetText format [
    "Archived revision %1 by %2 (%3). Restoring creates a new revision; it would add %4 item(s), remove %5 item(s), and change %6 quantity-rule record(s). Reason: %7",
    _entry param [4, 0], _entry param [6, "Unknown"], _entry param [5, []], count _wouldAdd, count _wouldRemove,
    if (_snapshotLimits isEqualTo _currentLimits) then {0} else {(count _snapshotLimits) + (count _currentLimits)}, _entry param [7, "Saved revision"]
];
(_display displayCtrl RACA_IDC_HISTORY_RESTORE) ctrlEnable (_currentIndex >= 0);
true
