#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {};

private _combo = _display displayCtrl RACA_IDC_PRESET_LIST;
private _selection = lbCurSel _combo;
if (_selection <= 0) exitWith {
    [_display, "Choose a saved preset to load."] call RACA_fnc_setStatus;
};

private _library = uiNamespace getVariable ["RACA_builderLibrary", []];
private _rawPreset = _library param [_selection - 1, []];
([_rawPreset] call RACA_fnc_validatePreset) params ["_preset", "_warnings"];
if (_preset isEqualTo []) exitWith {
    [_display, "The selected preset is invalid."] call RACA_fnc_setStatus;
};

private _selected = createHashMap;
{
    {_selected set [_x, true]} forEach _x;
} forEach (_preset select 3);
uiNamespace setVariable ["RACA_builderSelected", _selected];

private _adoption = [_preset] call RACA_fnc_getComposition;
uiNamespace setVariable ["RACA_builderComposition", _adoption];

private _sourceItems = createHashMap;
if (_adoption isNotEqualTo []) then {
    {
        {_sourceItems set [_x, true]} forEach _x;
    } forEach (_preset select 3);
    {
        {_sourceItems deleteAt _x} forEach _x;
    } forEach (_adoption select 4);
    {_sourceItems set [_x, true]} forEach (_adoption select 5);
};
uiNamespace setVariable ["RACA_builderInherited", _sourceItems];
private _limitsMap = createHashMap;
{
    _limitsMap set [_x select 0, +_x];
} forEach (([_preset] call RACA_fnc_getRuntimePolicy) select 2);
uiNamespace setVariable ["RACA_builderLimits", _limitsMap];

(_display displayCtrl RACA_IDC_PRESET_NAME) ctrlSetText (_preset select 2);
[_display] call RACA_fnc_refreshBaseCombo;
[_display] call RACA_fnc_refreshCategoryCombo;
[_display] call RACA_fnc_refreshItemList;
[_display] call RACA_fnc_updateSummary;
[_display] call RACA_fnc_runCreatorDiagnostics;

private _notices = [];
if (_warnings isNotEqualTo []) then {
    _notices pushBack format ["%1 validation notice(s)", count _warnings];
};

if (_adoption isNotEqualTo []) then {
    private _sourceName = _adoption select 2;
    if ([_preset select 2, _sourceName, _library] call RACA_fnc_wouldCreateCycle) then {
        _notices pushBack "circular adoption metadata detected; the stored complete item snapshot remains usable";
    } else {
        private _sourceIndex = _library findIf {toLowerANSI (_x select 2) isEqualTo toLowerANSI _sourceName};
        if (_sourceIndex < 0) then {
            _notices pushBack format ["adopted source '%1' is missing; the stored complete item snapshot remains unchanged", _sourceName];
        } else {
            private _currentFingerprint = [(_library select _sourceIndex)] call RACA_fnc_fingerprintPreset;
            if (_currentFingerprint isNotEqualTo (_adoption select 3)) then {
                _notices pushBack format ["adopted source '%1' changed; use ADOPT / REFRESH when you want its changes", _sourceName];
            };
        };
    };
};

private _noticeSuffix = if (_notices isEqualTo []) then {""} else {" — " + (_notices joinString "; ")};
[_display, format ["Loaded '%1'%2.", _preset select 2, _noticeSuffix]] call RACA_fnc_setStatus;
