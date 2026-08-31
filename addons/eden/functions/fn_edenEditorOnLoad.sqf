#include "..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {};
private _target = uiNamespace getVariable ["RACA_edenEditorTarget", controlNull];
_display setVariable ["RACA_targetGroup", _target];
private _raw = if (isNull _target) then {[]} else {_target getVariable ["RACA_edenObjectConfig", []]};
private _normalized = if (_raw isEqualTo []) then {[]} else {[_raw] call RACA_fnc_normalizeObjectConfig};
private _working = if (_normalized isEqualTo []) then {
    ["RACA_OBJECT_CONFIG", 1, [], [["auditLevel", "standard"], ["persistence", "mission"]]]
} else {+_normalized};
_display setVariable ["RACA_workingConfig", _working];
_display setVariable ["RACA_currentSlot", -1];
_display setVariable ["RACA_transactionPreflightReport", ""];
_display setVariable ["RACA_transactionPreflightSummary", [0, 0, 0]];

private _presetOptions = (call RACA_fnc_getPresetLibrary) apply {[_x] call RACA_fnc_flattenPreset};
{
    private _embedded = _x select 2;
    if ((_presetOptions findIf {_x isEqualTo _embedded}) < 0) then {_presetOptions pushBack _embedded};
} forEach (_working select 2);
_display setVariable ["RACA_presetOptions", _presetOptions];

private _mode = _display displayCtrl RACA_EDEN_IDC_ACCESS_MODE;
lbClear _mode;
{private _i = _mode lbAdd _x; _mode lbSetData [_i, _x]} forEach ["AND", "OR"];
_mode lbSetCurSel 0;
private _kind = _display displayCtrl RACA_EDEN_IDC_CONDITION_KIND;
lbClear _kind;
{
    _x params ["_label", "_data"];
    private _i = _kind lbAdd _label;
    _kind lbSetData [_i, _data];
} forEach [
    ["Side", "side"], ["Faction", "faction"], ["Group ID", "group"], ["Minimum rank", "rank"],
    ["Unit class", "unit"], ["Player UID", "uid"], ["Vehicle role", "vehiclerole"],
    ["Required item", "requireditem"], ["ACE permission key", "acepermission"]
];
_kind lbSetCurSel 0;
[_display, 0] call RACA_fnc_edenEditorRefresh;
[_display] call RACA_fnc_edenDashboardRefresh;
