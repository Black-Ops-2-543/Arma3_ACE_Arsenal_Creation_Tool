params [
    ["_rawConfig", [], [[]]],
    ["_catalog", [], [[]]]
];

private _entries = [];
private _config = [_rawConfig] call RACA_fnc_normalizeObjectConfig;
if (_config isEqualTo []) exitWith {
    [false, [], [["ERROR", "INVALID_OBJECT_CONFIG", "Restricted-arsenal object configuration is invalid.", "", "", ""]], [1, 0, 0]]
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
    if (_slotId isEqualTo "") then {
        _entries pushBack ["ERROR", "EMPTY_SLOT_ID", format ["Slot '%1' has no stable identifier.", _slotName], "", "", ""];
    };
    if !(_enabled isEqualType true) then {
        _entries pushBack ["ERROR", "INVALID_SLOT_STATE", format ["Slot '%1' has an invalid enabled state.", _slotName], "", "", ""];
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
    {
        _x params ["_className", "_limit", "_scope", "_reset"];
        if (_limit < -1) then {
            _entries pushBack ["ERROR", "NEGATIVE_LIMIT", format ["Slot '%1' gives '%2' a negative quantity limit.", _slotName, _className], _className, "", ""];
        };
        if !(_scope in ["interaction", "player", "life", "mission", "arsenal"]) then {
            _entries pushBack ["ERROR", "INVALID_LIMIT_SCOPE", format ["Slot '%1' uses unsupported limit scope '%2'.", _slotName, _scope], _className, "", ""];
        };
        if !(_reset in ["never", "respawn", "round", "phase", "interaction"]) then {
            _entries pushBack ["ERROR", "INVALID_RESET_POLICY", format ["Slot '%1' uses unsupported reset policy '%2'.", _slotName, _reset], _className, "", ""];
        };
    } forEach _limits;
} forEach (_config select 2);

private _errorCount = {(_x select 0) isEqualTo "ERROR"} count _entries;
private _warningCount = {(_x select 0) isEqualTo "WARNING"} count _entries;
private _infoCount = {(_x select 0) isEqualTo "INFO"} count _entries;
[_errorCount isEqualTo 0, _config, _entries, [_errorCount, _warningCount, _infoCount]]
