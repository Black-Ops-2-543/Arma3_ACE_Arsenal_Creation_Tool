/*
 * Object config: [RACA_OBJECT_CONFIG, 1, slots, options].
 * Slot: [id, name, preset, enabled, access, limits, icon, hideWhenDenied].
 */
params [["_raw", [], [[]]]];

private _defaultAccess = ["RACA_ACCESS", 1, "AND", [], false, "You are not authorized to use this arsenal.", []];
private _slots = [];
private _options = [["auditLevel", "standard"], ["persistence", "mission"]];
private _rawSignature = _raw param [0, ""];

if (_rawSignature isEqualType "" && {_rawSignature isEqualTo "RACA_PRESET"}) then {
    private _legacyPreset = [_raw] call RACA_fnc_flattenPreset;
    if (_legacyPreset isEqualTo []) exitWith {};
    private _policy = [_legacyPreset] call RACA_fnc_getRuntimePolicy;
    _slots pushBack ["default", _legacyPreset select 2, _legacyPreset, true, _defaultAccess, _policy select 2, "", false];
} else {
    if !(_rawSignature isEqualType "" && {_rawSignature isEqualTo "RACA_OBJECT_CONFIG"}) exitWith {};
    private _rawVersion = _raw param [1, -1];
    if !(_rawVersion isEqualType 0) exitWith {};
    private _version = _rawVersion;
    if (_version > 1 || {_version < 0}) exitWith {};
    private _rawSlotsValue = _raw param [2, []];
    private _rawSlots = if (_rawSlotsValue isEqualType []) then {_rawSlotsValue} else {[]};
    private _rawOptions = _raw param [3, _options];
    if (_rawOptions isEqualType []) then {_options = _rawOptions};
    {
        if (_x isEqualType [] && {(count _x) >= 3}) then {
            private _defaultSlotId = format ["slot_%1", _forEachIndex + 1];
            private _defaultSlotName = format ["Restricted Arsenal %1", _forEachIndex + 1];
            private _rawSlotId = _x param [0, _defaultSlotId];
            private _rawSlotName = _x param [1, _defaultSlotName];
            private _rawPresetValue = _x param [2, []];
            private _slotId = if (_rawSlotId isEqualType "") then {_rawSlotId} else {_defaultSlotId};
            private _slotName = if (_rawSlotName isEqualType "") then {_rawSlotName} else {_defaultSlotName};
            private _rawPreset = if (_rawPresetValue isEqualType []) then {_rawPresetValue} else {[]};
            private _preset = [_rawPreset] call RACA_fnc_flattenPreset;
            if (_preset isNotEqualTo []) then {
                private _rawEnabled = _x param [3, true];
                private _enabled = if (_rawEnabled isEqualType true) then {_rawEnabled} else {true};
                private _rawAccess = _x param [4, _defaultAccess];
                private _access = if (_rawAccess isEqualType []) then {[_rawAccess] call RACA_fnc_normalizeAccess} else {+_defaultAccess};
                private _defaultLimits = ([_preset] call RACA_fnc_getRuntimePolicy) select 2;
                private _rawLimits = _x param [5, _defaultLimits];
                private _limits = if (_rawLimits isEqualType []) then {[_rawLimits] call RACA_fnc_normalizeLimits} else {+_defaultLimits};
                private _rawIcon = _x param [6, ""];
                private _icon = if (_rawIcon isEqualType "") then {_rawIcon} else {""};
                private _rawHidden = _x param [7, false];
                private _hideWhenDenied = if (_rawHidden isEqualType true) then {_rawHidden} else {false};
                if (_slotId isEqualTo "") then {_slotId = format ["slot_%1", _forEachIndex + 1]};
                if (_slotName isEqualTo "") then {_slotName = _preset select 2};
                _slots pushBack [_slotId, _slotName, _preset, _enabled, _access, _limits, _icon, _hideWhenDenied];
            };
        };
    } forEach _rawSlots;
};

if (_slots isEqualTo []) exitWith {[]};
["RACA_OBJECT_CONFIG", 1, _slots, _options]
