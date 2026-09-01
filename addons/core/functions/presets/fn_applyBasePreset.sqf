#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {};

private _combo = _display displayCtrl RACA_IDC_BASE_PRESET;
private _selection = lbCurSel _combo;
if (_selection <= 0) exitWith {
    [_display, "Choose a source preset before applying inheritance."] call RACA_fnc_setStatus;
};

private _library = uiNamespace getVariable ["RACA_builderLibrary", []];
private _source = _library param [_selection - 1, []];
([_source] call RACA_fnc_validatePreset) params ["_validatedSource"];
if (_validatedSource isEqualTo []) exitWith {
    [_display, "The selected source preset is invalid."] call RACA_fnc_setStatus;
};

private _childName = ctrlText (_display displayCtrl RACA_IDC_PRESET_NAME);
private _sourceName = _validatedSource select 2;
if ([_childName, _sourceName, _library] call RACA_fnc_wouldCreateCycle) exitWith {
    [_display, "Inheritance rejected because it would create a circular source link."] call RACA_fnc_setStatus;
};

[_display] call RACA_fnc_pushCreatorHistory;

private _currentSelection = uiNamespace getVariable ["RACA_builderSelected", createHashMap];
private _previousSourceItems = uiNamespace getVariable ["RACA_builderInherited", createHashMap];
private _additions = createHashMap;
private _removals = createHashMap;

{
    if (_currentSelection getOrDefault [_x, false] && {!(_previousSourceItems getOrDefault [_x, false])}) then {
        _additions set [_x, true];
    };
} forEach keys _currentSelection;
{
    if !(_currentSelection getOrDefault [_x, false]) then {
        _removals set [_x, true];
    };
} forEach keys _previousSourceItems;

private _sourceItems = createHashMap;
private _nextSelection = createHashMap;
{
    {
        _sourceItems set [_x, true];
        _nextSelection set [_x, true];
    } forEach _x;
} forEach (_validatedSource select 3);

{_nextSelection set [_x, true]} forEach keys _additions;
{_nextSelection deleteAt _x} forEach keys _removals;

private _additionBuckets = [[], [], [], []];
{
    ([_x] call RACA_fnc_classifyClass) params ["_bucket"];
    if (_bucket >= 0) then {(_additionBuckets select _bucket) pushBackUnique _x};
} forEach keys _additions;
{_x sort true} forEach _additionBuckets;
private _removalClasses = keys _removals;
_removalClasses sort true;

uiNamespace setVariable ["RACA_builderSelected", _nextSelection];
uiNamespace setVariable ["RACA_builderInherited", _sourceItems];
uiNamespace setVariable [
    "RACA_builderComposition",
    [
        "RACA_INHERITANCE",
        1,
        _sourceName,
        [_validatedSource] call RACA_fnc_fingerprintPreset,
        _additionBuckets,
        _removalClasses
    ]
];

[_display] call RACA_fnc_refreshCategoryCombo;
[_display] call RACA_fnc_refreshItemList;
[_display, format ["Inherited from source preset '%1'. Its %2 source items are marked light blue in Arsenal Contents.", _sourceName, count _sourceItems]] call RACA_fnc_setStatus;
