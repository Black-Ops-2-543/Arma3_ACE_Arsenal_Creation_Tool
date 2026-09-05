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
    if (_name isEqualTo "RACA_catalogPageSize") then {[_display] call RACA_fnc_queueRefresh};
};
