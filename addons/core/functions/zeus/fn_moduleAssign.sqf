params ["_logic", "_units", "_activated"];
if (!_activated || {!isServer} || {!(missionNamespace getVariable ["RACA_allowZeusModules", true])}) exitWith {false};
private _presetName = _logic getVariable ["RACA_presetName", ""];
private _slotName = _logic getVariable ["RACA_slotName", "Restricted Arsenal"];
private _library = call RACA_fnc_getPresetLibrary;
private _index = _library findIf {toLowerANSI (_x select 2) isEqualTo toLowerANSI _presetName};
private _rawPreset = if (_index >= 0) then {_library select _index} else {[]};
if (_rawPreset isEqualTo []) then {
    {
        private _config = _x select 1;
        {
            private _candidate = _x select 2;
            if (toLowerANSI (_candidate param [2, ""]) isEqualTo toLowerANSI _presetName) exitWith {_rawPreset = _candidate};
        } forEach (_config select 2);
        if (_rawPreset isNotEqualTo []) exitWith {};
    } forEach call RACA_fnc_getMissionRegistry;
};
if (_rawPreset isEqualTo []) exitWith {diag_log format ["[RACA] Zeus assignment rejected: preset '%1' was not found in the server profile or an embedded mission slot.", _presetName]; false};
private _preset = [_rawPreset] call RACA_fnc_flattenPreset;
private _config = ["RACA_OBJECT_CONFIG", 1, [["zeus", _slotName, _preset, true, ["RACA_ACCESS", 1, "AND", [], false, "Access denied.", []], ([_preset] call RACA_fnc_getRuntimePolicy) select 2, "", false]], [["persistence", "session"]]];
private _targets = _units select {!isNull _x};
private _changed = [_targets, "assign", _config, true] call RACA_fnc_bulkUpdateObjects;
["ZEUS_ASSIGN", objNull, _targets param [0, objNull], "zeus", [_presetName, _changed]] call RACA_fnc_logEvent;
deleteVehicle _logic;
_changed > 0
