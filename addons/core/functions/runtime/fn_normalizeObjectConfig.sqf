/*
 * Object config: [RACA_OBJECT_CONFIG, 1, slots, options].
 * Slot: [id, name, preset, enabled, access, limits, icon, hideWhenDenied].
 */
params [["_raw", [], [[]]]];

private _defaultAccess = ["RACA_ACCESS", 1, "AND", [], false, "You are not authorized to use this arsenal.", []];
private _slots = [];
private _options = [["auditLevel", "standard"], ["persistence", "mission"]];

if ((_raw param [0, "", [""]]) isEqualTo "RACA_PRESET") then {
    ([_raw] call RACA_fnc_validatePreset) params ["_legacyPreset"];
    if (_legacyPreset isEqualTo []) exitWith {};
    private _policy = [_legacyPreset] call RACA_fnc_getRuntimePolicy;
    _slots pushBack ["default", _legacyPreset select 2, _legacyPreset, true, _defaultAccess, _policy select 2, "", false];
} else {
    if ((_raw param [0, "", [""]]) isNotEqualTo "RACA_OBJECT_CONFIG") exitWith {};
    private _version = _raw param [1, -1, [0]];
    if (_version > 1 || {_version < 0}) exitWith {};
    private _rawSlots = _raw param [2, [], [[]]];
    _options = _raw param [3, _options, [[]]];
    {
        if (_x isEqualType [] && {(count _x) >= 3}) then {
            private _slotId = _x param [0, format ["slot_%1", _forEachIndex + 1], [""]];
            private _slotName = _x param [1, format ["Restricted Arsenal %1", _forEachIndex + 1], [""]];
            private _rawPreset = _x param [2, [], [[]]];
            ([_rawPreset] call RACA_fnc_validatePreset) params ["_preset"];
            if (_preset isNotEqualTo []) then {
                private _enabled = _x param [3, true, [true]];
                private _access = _x param [4, _defaultAccess, [[]]];
                if ((_access param [0, "", [""]]) isNotEqualTo "RACA_ACCESS") then {_access = _defaultAccess};
                private _limits = [_x param [5, ([_preset] call RACA_fnc_getRuntimePolicy) select 2, [[]]]] call RACA_fnc_normalizeLimits;
                private _icon = _x param [6, "", [""]];
                private _hideWhenDenied = _x param [7, false, [true]];
                if (_slotId isEqualTo "") then {_slotId = format ["slot_%1", _forEachIndex + 1]};
                if (_slotName isEqualTo "") then {_slotName = _preset select 2};
                _slots pushBack [_slotId, _slotName, _preset, _enabled, _access, _limits, _icon, _hideWhenDenied];
            };
        };
    } forEach _rawSlots;
};

if (_slots isEqualTo []) exitWith {[]};
["RACA_OBJECT_CONFIG", 1, _slots, _options]
