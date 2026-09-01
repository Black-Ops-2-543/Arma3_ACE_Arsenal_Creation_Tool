#include "..\..\script_component.hpp"
params [
    ["_display", displayNull, [displayNull]],
    ["_comboIdc", RACA_IDC_PRESET_TOOL, [0]]
];

if (isNull _display) exitWith {false};
private _library = uiNamespace getVariable ["RACA_builderLibrary", []];

if (_comboIdc != RACA_IDC_PRESET_TOOL) exitWith {
    [_display, "Use the Preset Analysis selector to choose a saved preset before comparing with the draft."] call RACA_fnc_setStatus;
    false
};
private _combo = _display displayCtrl _comboIdc;
private _selection = lbCurSel _combo;
if (_selection <= 0) exitWith {
    [_display, "Select a preset in Preset Analysis before comparing with the draft."] call RACA_fnc_setStatus;
    false
};
private _selectedName = _combo lbData _selection;

private _savedIndex = _library findIf {toLowerANSI (_x select 2) isEqualTo toLowerANSI _selectedName};
private _saved = if (_savedIndex >= 0) then {_library select _savedIndex} else {[]};
if (_saved isEqualTo []) exitWith {
    [_display, "Choose a valid saved preset first. The selected entry has no matching profile data."] call RACA_fnc_setStatus;
    false
};

private _draft = [_display] call RACA_fnc_buildPreset;
private _savedSet = createHashMap;
{_savedSet set [_x, true]} forEach ([_saved] call RACA_fnc_flattenPresetClasses);
private _draftSet = createHashMap;
{_draftSet set [_x, true]} forEach ([_draft] call RACA_fnc_flattenPresetClasses);
private _added = (keys _draftSet) select {!(_savedSet getOrDefault [_x, false])};
private _removed = (keys _savedSet) select {!(_draftSet getOrDefault [_x, false])};
_added sort true;
_removed sort true;

private _savedLimits = ([_saved] call RACA_fnc_getRuntimePolicy) select 2;
private _draftLimits = ([_draft] call RACA_fnc_getRuntimePolicy) select 2;
private _policyDelta = if (_savedLimits isEqualTo _draftLimits) then {"no"} else {"yes"};
private _newline = toString [13, 10];
private _lines = [
    format ["RACA preset diff: current draft vs %1", _saved select 2],
    format [
        "Added: %1 | Removed: %2 | Quantity policy changed: %3",
        count _added,
        count _removed,
        _policyDelta
    ],
    "",
    "ADDED TO DRAFT",
    if (_added isEqualTo []) then {"<none>"} else {_added joinString _newline},
    "",
    "REMOVED FROM DRAFT",
    if (_removed isEqualTo []) then {"<none>"} else {_removed joinString _newline},
    "",
    "SAVED LIMITS",
    str _savedLimits,
    "DRAFT LIMITS",
    str _draftLimits
];
forceUnicode 1;
copyToClipboard (_lines joinString _newline);
[_display, format ["Compared the draft with '%1': +%2 / -%3 classes. The complete diff is on the clipboard.", _saved select 2, count _added, count _removed]] call RACA_fnc_setStatus;
true
