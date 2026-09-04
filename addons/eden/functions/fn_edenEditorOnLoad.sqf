#include "..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display || {!is3DEN}) exitWith {};

private _libraryState=call RACA_fnc_edenGetConfigurationState;
_display setVariable ["RACA_configurationLibraryState", _libraryState];
private _working = _libraryState select 2;
_display setVariable ["RACA_workingConfigurations", +_working];
_display setVariable ["RACA_currentSlot", -1];
_display setVariable ["RACA_configurationsDirty", false];
_display setVariable ["RACA_dashboardObjects", []];
_display setVariable ["RACA_dashboardSelectedObject", objNull];
_display setVariable ["RACA_transactionPreflightReport", ""];
_display setVariable ["RACA_transactionPreflightSummary", [0, 0, 0]];

private _historyHandlers = [];
{
    private _event = _x;
    private _handler = add3DENEventHandler [_event, {
        private _dashboard = findDisplay RACA_EDEN_IDD_CONFIG;
        if (!isNull _dashboard) then {[_dashboard, true] call RACA_fnc_edenDashboardQueueRefresh};
    }];
    _historyHandlers pushBack [_event, _handler];
} forEach ["OnUndo", "OnRedo"];
_display setVariable ["RACA_edenHistoryHandlers", _historyHandlers];

private _presetOptions = [];
{
    private _preset = [_x] call RACA_fnc_flattenPreset;
    if (_preset isNotEqualTo [] && {(_presetOptions findIf {_x isEqualTo _preset}) < 0}) then {
        _presetOptions pushBack _preset;
    };
} forEach (call RACA_fnc_getPresetLibrary);
{
    private _preset = +(_x select 2);
    if ((_presetOptions findIf {_x isEqualTo _preset}) < 0) then {_presetOptions pushBack _preset};
} forEach _working;
_display setVariable ["RACA_presetOptions", _presetOptions];

private _mode = _display displayCtrl RACA_EDEN_IDC_ACCESS_MODE;
lbClear _mode;
{
    private _row = _mode lbAdd _x;
    _mode lbSetData [_row, _x];
} forEach ["AND", "OR"];
_mode lbSetCurSel 0;

private _kind = _display displayCtrl RACA_EDEN_IDC_CONDITION_KIND;
lbClear _kind;
{
    _x params ["_label", "_data"];
    private _row = _kind lbAdd _label;
    _kind lbSetData [_row, _data];
} forEach [
    ["Side", "side"],
    ["Faction", "faction"],
    ["Group ID", "group"],
    ["Minimum rank", "rank"],
    ["Unit class", "unit"],
    ["Player UID", "uid"],
    ["Vehicle role", "vehiclerole"],
    ["Required item", "requireditem"],
    ["ACE permission key", "acepermission"]
];
_kind lbSetCurSel 0;

private _variableFilter = _display displayCtrl RACA_EDEN_IDC_VARIABLE_FILTER;
lbClear _variableFilter;
{
    _x params ["_label", "_data"];
    private _row = _variableFilter lbAdd _label;
    _variableFilter lbSetData [_row, _data];
} forEach [
    ["All", "all"],
    ["No variable name", "none"],
    ["Only variable names", "only"]
];
_variableFilter lbSetCurSel 0;

private _objectFilter = _display displayCtrl RACA_EDEN_IDC_OBJECT_FILTER;
lbClear _objectFilter;
{
    _x params ["_label", "_data"];
    private _row = _objectFilter lbAdd _label;
    _objectFilter lbSetData [_row, _data];
} forEach [
    ["All", "all"],
    ["Unit", "unit"],
    ["Module", "module"],
    ["Object", "object"]
];
_objectFilter lbSetCurSel 3;
(_display displayCtrl RACA_EDEN_IDC_DASHBOARD_SEARCH) ctrlSetText "";

[_display, 0] call RACA_fnc_edenEditorRefresh;
[_display, "DASHBOARD"] call RACA_fnc_edenSwitchTab;
private _status=_libraryState select 0;
private _entries=_libraryState select 4;
private _locked=_status isNotEqualTo "READY";
{(_display displayCtrl _x) ctrlEnable !_locked} forEach [RACA_EDEN_IDC_CONFIG_SAVE,RACA_EDEN_IDC_CONFIG_ADD,RACA_EDEN_IDC_CONFIG_DELETE,RACA_EDEN_IDC_DASHBOARD_APPLY,RACA_EDEN_IDC_SAVE_CLOSE];
(_display displayCtrl RACA_EDEN_IDC_REPAIR) ctrlShow (_status isEqualTo "RECOVERY" && {(_entries findIf {(_x select 1) isEqualTo "REPAIRABLE"})>=0});
(_display displayCtrl RACA_EDEN_IDC_REMOVE_BLOCKED) ctrlShow (_status isEqualTo "RECOVERY" && {(_entries findIf {(_x select 1) in ["BLOCKED", "REPAIRABLE"]})>=0});
if (_locked) then {
    private _reasons = (_entries select [0, 4]) apply {
        format ["Record %1: %2", (_x select 0) + 1, _x select 2]
    };
    (_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText format [
        "Library %1 (version %2). Mutating actions are disabled. Copy Report preserves the exact raw value. %3",
        _status,
        _libraryState select 1,
        _reasons joinString "; "
    ];
};
