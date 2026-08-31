params [
    ["_rawConfig", [], [[]]],
    ["_catalog", [], [[]]]
];

private _entries = [];
private _rawSlotCount = -1;
if ((_rawConfig param [0, "", [""]]) isEqualTo "RACA_OBJECT_CONFIG") then {
    private _rawSlots = _rawConfig param [2, [], [[]]];
    _rawSlotCount = count _rawSlots;
    {
        if !(_x isEqualType [] && {(count _x) >= 3}) then {
            _entries pushBack ["ERROR", "MALFORMED_SLOT", format ["Object slot record %1 is malformed and would be discarded.", _forEachIndex + 1], "", "", ""];
        } else {
            private _rawSlotName = _x param [1, format ["Slot %1", _forEachIndex + 1], [""]];
            private _rawSlotId = _x param [0, "", [""]];
            if (_rawSlotId isEqualTo "") then {
                _entries pushBack ["ERROR", "EMPTY_SLOT_ID", format ["Slot '%1' has no stable identifier.", _rawSlotName], "", "", ""];
            };
            if ((count _x) > 3 && {!((_x select 3) isEqualType true)}) then {
                _entries pushBack ["ERROR", "INVALID_SLOT_STATE", format ["Slot '%1' has a non-Boolean enabled state.", _rawSlotName], "", "", ""];
            };
            private _rawAccess = _x param [4, [], [[]]];
            if (_rawAccess isNotEqualTo [] &&
                {(_rawAccess param [0, "", [""]]) isNotEqualTo "RACA_ACCESS" ||
                {(_rawAccess param [1, -1, [0]]) isNotEqualTo 1}}) then {
                _entries pushBack ["ERROR", "INVALID_ACCESS_ENVELOPE", format ["Slot '%1' has malformed access-rule metadata.", _rawSlotName], "", "", ""];
            };
            private _rawLimits = _x param [5, [], [[]]];
            {
                if !(_x isEqualType [] && {(count _x) >= 2}) then {
                    _entries pushBack ["ERROR", "MALFORMED_LIMIT", format ["Slot '%1' contains a malformed quantity-limit record.", _rawSlotName], "", "", ""];
                } else {
                    private _className = _x param [0, "", [""]];
                    private _limit = _x param [1, -1, [0]];
                    private _scope = toLowerANSI (_x param [2, "arsenal", [""]]);
                    private _reset = toLowerANSI (_x param [3, "never", [""]]);
                    if (_limit < -1) then {
                        _entries pushBack ["ERROR", "NEGATIVE_LIMIT", format ["Slot '%1' gives '%2' a negative quantity limit.", _rawSlotName, _className], _className, "", ""];
                    };
                    if !(_scope in ["interaction", "player", "life", "mission", "arsenal"]) then {
                        _entries pushBack ["ERROR", "INVALID_LIMIT_SCOPE", format ["Slot '%1' uses unsupported limit scope '%2'.", _rawSlotName, _scope], _className, "", ""];
                    };
                    if !(_reset in ["never", "respawn", "round", "phase", "interaction"]) then {
                        _entries pushBack ["ERROR", "INVALID_RESET_POLICY", format ["Slot '%1' uses unsupported reset policy '%2'.", _rawSlotName, _reset], _className, "", ""];
                    };
                };
            } forEach _rawLimits;
        };
    } forEach _rawSlots;
};
private _config = [_rawConfig] call RACA_fnc_normalizeObjectConfig;
if (_config isEqualTo []) exitWith {
    _entries pushBack ["ERROR", "INVALID_OBJECT_CONFIG", "Restricted-arsenal object configuration is invalid.", "", "", ""];
    [false, [], _entries, [{(_x select 0) isEqualTo "ERROR"} count _entries, {(_x select 0) isEqualTo "WARNING"} count _entries, {(_x select 0) isEqualTo "INFO"} count _entries]]
};
if (_rawSlotCount >= 0 && {_rawSlotCount isNotEqualTo count (_config select 2)}) then {
    _entries pushBack [
        "ERROR",
        "DROPPED_SLOT",
        format ["%1 of %2 raw slot record(s) could not be normalized and would be omitted at runtime.", _rawSlotCount - count (_config select 2), _rawSlotCount],
        "",
        "",
        ""
    ];
};

private _slotNames = createHashMap;
{
    _x params ["_slotId", "_slotName", "_preset", "_enabled", "_access", "_limits"];
    private _normalizedName = toLowerANSI _slotName;
    if (_slotNames getOrDefault [_normalizedName, false]) then {
        _entries pushBack ["ERROR", "DUPLICATE_SLOT_NAME", format ["Slot name '%1' is duplicated.", _slotName], "", "", ""];
    } else {
        _slotNames set [_normalizedName, true];
    };
    private _optional = _access param [6, [], [[]]];
    ([_preset, _catalog, _optional] call RACA_fnc_analyzePreset) params ["", "_presetEntries"];
    {
        if ((_x select 1) isEqualTo "MISSING_REQUIRED") then {
            _x set [0, "WARNING"];
            _x set [2, format ["%1 Runtime will omit this unavailable class and keep the remaining valid items.", _x select 2]];
        };
        _x set [2, format ["Slot '%1': %2", _slotName, _x select 2]];
        _entries pushBack _x;
    } forEach _presetEntries;
} forEach (_config select 2);

private _errorCount = {(_x select 0) isEqualTo "ERROR"} count _entries;
private _warningCount = {(_x select 0) isEqualTo "WARNING"} count _entries;
private _infoCount = {(_x select 0) isEqualTo "INFO"} count _entries;
[_errorCount isEqualTo 0, _config, _entries, [_errorCount, _warningCount, _infoCount]]
