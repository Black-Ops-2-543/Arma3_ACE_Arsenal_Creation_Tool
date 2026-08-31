params [["_group", controlNull, [controlNull]]];

if (isNull _group) exitWith {};
private _config = [_group getVariable ["RACA_edenObjectConfig", []]] call RACA_fnc_normalizeObjectConfig;
if (_config isEqualTo []) exitWith {[_group] call RACA_fnc_edenUpdateSummary};
private _library = call RACA_fnc_getPresetLibrary;
private _updated = 0;
{
    private _presetName = (_x select 2) select 2;
    private _match = _library findIf {toLowerANSI (_x select 2) isEqualTo toLowerANSI _presetName};
    if (_match >= 0) then {
        private _replacement = [_library select _match] call RACA_fnc_flattenPreset;
        if (_replacement isNotEqualTo [] && {_replacement isNotEqualTo (_x select 2)}) then {
            _x set [2, _replacement];
            _x set [5, (([_replacement] call RACA_fnc_getRuntimePolicy) select 2)];
            _updated = _updated + 1;
        };
    };
} forEach (_config select 2);
_group setVariable ["RACA_edenObjectConfig", _config];
[_group] call RACA_fnc_edenUpdateSummary;
systemChat format ["RACA: Refreshed %1 configured slot(s) from profile presets.", _updated];
