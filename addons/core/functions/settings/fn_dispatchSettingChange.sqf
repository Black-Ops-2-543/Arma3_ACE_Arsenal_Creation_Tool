#include "..\..\script_component.hpp"
/* Coalesces setting callbacks and validates display identity at dispatch time. */
params [["_name", "", [""]]];
if (_name isEqualTo "") exitWith {};

private _revisions = uiNamespace getVariable ["RACA_settingDispatchRevisions", createHashMap];
private _revision = (_revisions getOrDefault [_name, 0]) + 1;
_revisions set [_name, _revision];
uiNamespace setVariable ["RACA_settingDispatchRevisions", _revisions];

private _display = uiNamespace getVariable ["RACA_builderDisplay", displayNull];
private _generation = if (isNull _display) then {-1} else {_display getVariable ["RACA_generation", -1]};
[_name, _revision, _display, _generation] spawn {
    params ["_name", "_revision", "_display", "_generation"];
    uiSleep 0.05;
    private _current = uiNamespace getVariable ["RACA_settingDispatchRevisions", createHashMap];
    if ((_current getOrDefault [_name, -1]) isNotEqualTo _revision) exitWith {};
    if (isNull _display || {(_display getVariable ["RACA_generation", -1]) isNotEqualTo _generation}) exitWith {};

    // Consumer-specific transitions are added at their owning implementation
    // task. Page size already has a normal, state-preserving refresh path.
    if (_name isEqualTo "RACA_catalogPageSize") then {
        [_display] call RACA_fnc_queueRefresh;
        private _tagDisplay = uiNamespace getVariable ["RACA_catalogTagsDisplay", displayNull];
        if (!isNull _tagDisplay) then {[_tagDisplay] call RACA_fnc_catalogTagMembersRefresh};
    };
    if (_name isEqualTo "RACA_defaultSearchMode") then {
        [_display, [_name] call RACA_fnc_getSetting, false] call RACA_fnc_setSearchMode;
    };
    if (_name isEqualTo "RACA_defaultCompatibilitySeverity") then {
        private _preflight = uiNamespace getVariable ["RACA_preflightDisplay", displayNull];
        if (!isNull _preflight) then {
            private _filter = _preflight displayCtrl RACA_IDC_PREFLIGHT_FILTER;
            private _preferred = [_name] call RACA_fnc_getSetting;
            private _data = "ERROR";
            if (_preferred isEqualTo "WARNINGS") then {_data = "WARNING"};
            if (_preferred isEqualTo "ALL") then {_data = "ALL"};
            private _row = -1;
            for "_i" from 0 to (lbSize _filter - 1) do {
                if ((_filter lbData _i) isEqualTo _data) exitWith {_row = _i;};
            };
            _preflight setVariable ["RACA_preflightFilterSuppressed", true];
            if (_row >= 0) then {_filter lbSetCurSel _row};
            _preflight setVariable ["RACA_preflightFilterSuppressed", false];
            [_preflight] call RACA_fnc_preflightRefresh;
        };
    };
    if (_name isEqualTo "RACA_showOnboardingGuidance") then {
        [_display] call RACA_fnc_applyGuidancePreference;
    };
};
