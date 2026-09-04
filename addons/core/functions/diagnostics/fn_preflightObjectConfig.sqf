params [
    ["_rawConfig", [], [[]]],
    ["_catalog", [], [[]]]
];

private _entries = [];
private _rawSlotCount = -1;
private _rawSignature = _rawConfig param [0, ""];
if (_rawSignature isEqualType "" && {_rawSignature isEqualTo "RACA_OBJECT_CONFIG"}) then {
    if ((count _rawConfig) > 2 && {!((_rawConfig select 2) isEqualType [])}) then {
        _entries pushBack ["ERROR", "INVALID_SLOT_CONTAINER", "The object configuration's slot collection is not an array.", "", "", ""];
    };
    private _rawSlots = _rawConfig param [2, [], [[]]];
    _rawSlotCount = count _rawSlots;
    private _supportedConditions = ["side", "faction", "group", "rank", "unit", "uid", "vehiclerole", "requireditem", "acepermission"];
    private _validCategories = ["weapons", "attachments", "magazines", "uniforms", "vests", "backpacks", "headgear", "nvgs", "facewear", "equipment"];
    {
        if !(_x isEqualType [] && {(count _x) >= 3}) then {
            _entries pushBack ["ERROR", "MALFORMED_SLOT", format ["Object slot record %1 is malformed and would be discarded.", _forEachIndex + 1], "", "", ""];
        } else {
            if !((_x select 0) isEqualType "") then {
                _entries pushBack ["ERROR", "INVALID_SLOT_ID_TYPE", format ["Slot record %1 has a non-text identifier.", _forEachIndex + 1], "", "", ""];
            };
            if !((_x select 1) isEqualType "") then {
                _entries pushBack ["ERROR", "INVALID_SLOT_NAME_TYPE", format ["Slot record %1 has a non-text display name.", _forEachIndex + 1], "", "", ""];
            };
            private _rawSlotName = _x param [1, format ["Slot %1", _forEachIndex + 1], [""]];
            private _rawSlotId = _x param [0, "", [""]];
            if (_rawSlotId isEqualTo "") then {
                _entries pushBack ["ERROR", "EMPTY_SLOT_ID", format ["Slot '%1' has no stable identifier.", _rawSlotName], "", "", ""];
            };
            if (_rawSlotId isNotEqualTo "" && {!([_rawSlotId] call RACA_fnc_isSafeClassName)}) then {
                _entries pushBack ["ERROR", "UNSAFE_SLOT_ID", format ["Slot '%1' has an identifier containing unsupported characters.", _rawSlotName], "", "", ""];
            };
            if (_rawSlotName isEqualTo "") then {
                _entries pushBack ["WARNING", "EMPTY_SLOT_NAME", format ["Slot record %1 has no display name and will use its preset name.", _forEachIndex + 1], "", "", ""];
            };
            if ((count _rawSlotName) > 128) then {
                _entries pushBack ["ERROR", "SLOT_NAME_TOO_LONG", format ["Slot record %1 has a display name longer than 128 characters.", _forEachIndex + 1], "", "", ""];
            };
            if ((count _x) > 3 && {!((_x select 3) isEqualType true)}) then {
                _entries pushBack ["ERROR", "INVALID_SLOT_STATE", format ["Slot '%1' has a non-Boolean enabled state.", _rawSlotName], "", "", ""];
            };
            if ((count _x) > 6 && {!((_x select 6) isEqualType "")}) then {
                _entries pushBack ["ERROR", "INVALID_SLOT_ICON", format ["Slot '%1' has a non-text interaction icon path.", _rawSlotName], "", "", ""];
            };
            if ((count _x) > 6 && {(_x select 6) isEqualType ""} && {(count (_x select 6)) > 512}) then {
                _entries pushBack ["ERROR", "SLOT_ICON_TOO_LONG", format ["Slot '%1' has an interaction icon path longer than 512 characters.", _rawSlotName], "", "", ""];
            };
            if ((count _x) > 7 && {!((_x select 7) isEqualType true)}) then {
                _entries pushBack ["ERROR", "INVALID_SLOT_VISIBILITY", format ["Slot '%1' has a non-Boolean hide-when-denied state.", _rawSlotName], "", "", ""];
            };

            if ((count _x) > 4 && {!((_x select 4) isEqualType [])}) then {
                _entries pushBack ["ERROR", "INVALID_ACCESS_CONTAINER", format ["Slot '%1' has a non-array access policy.", _rawSlotName], "", "", ""];
            } else {
                private _rawAccess = _x param [4, [], [[]]];
                if (_rawAccess isNotEqualTo []) then {
                    if ((_rawAccess param [0, "", [""]]) isNotEqualTo "RACA_ACCESS" ||
                        {(_rawAccess param [1, -1, [0]]) isNotEqualTo 1}) then {
                        _entries pushBack ["ERROR", "INVALID_ACCESS_ENVELOPE", format ["Slot '%1' has malformed access-rule metadata.", _rawSlotName], "", "", ""];
                    };
                    if ((count _rawAccess) > 2 && {!((_rawAccess select 2) isEqualType "")}) then {
                        _entries pushBack ["ERROR", "INVALID_ACCESS_MODE_TYPE", format ["Slot '%1' has a non-text access mode.", _rawSlotName], "", "", ""];
                    } else {
                        private _rawMode = toUpperANSI (_rawAccess param [2, "AND", [""]]);
                        if !(_rawMode in ["AND", "OR"]) then {
                            _entries pushBack ["ERROR", "INVALID_ACCESS_MODE", format ["Slot '%1' uses unsupported access mode '%2'.", _rawSlotName, _rawMode], "", "", ""];
                        };
                    };
                    if ((count _rawAccess) > 3 && {!((_rawAccess select 3) isEqualType [])}) then {
                        _entries pushBack ["ERROR", "INVALID_CONDITION_CONTAINER", format ["Slot '%1' has a non-array access-condition collection.", _rawSlotName], "", "", ""];
                    } else {
                        {
                            if !(_x isEqualType [] && {(count _x) >= 2}) then {
                                _entries pushBack ["ERROR", "MALFORMED_ACCESS_CONDITION", format ["Slot '%1' contains malformed access condition %2.", _rawSlotName, _forEachIndex + 1], "", "", ""];
                            } else {
                                private _kindValue = _x select 0;
                                private _kind = if (_kindValue isEqualType "") then {toLowerANSI _kindValue} else {""};
                                if !(_kind in _supportedConditions) then {
                                    _entries pushBack ["ERROR", "UNSUPPORTED_ACCESS_CONDITION", format ["Slot '%1' contains unsupported access condition '%2'.", _rawSlotName, _kindValue], "", "", ""];
                                } else {
                                    private _value = _x select 1;
                                    private _validValue = if (_kind isEqualTo "uid") then {
                                        if (_value isEqualType []) then {
                                            _value isNotEqualTo [] && {{!(_x isEqualType "") || {_x isEqualTo ""} || {(count _x) > 64}} count _value isEqualTo 0}
                                        } else {
                                            _value isEqualType "" && {_value isNotEqualTo ""} && {(count _value) <= 64}
                                        }
                                    } else {
                                        _value isEqualType "" && {_value isNotEqualTo ""} && {(count _value) <= 256}
                                    };
                                    if (!_validValue) then {
                                        _entries pushBack ["ERROR", "INVALID_ACCESS_VALUE", format ["Slot '%1' has an invalid value for access condition '%2'.", _rawSlotName, _kind], "", "", ""];
                                    };
                                };
                            };
                        } forEach (_rawAccess param [3, [], [[]]]);
                    };
                    if ((count _rawAccess) > 5 && {!((_rawAccess select 5) isEqualType "")}) then {
                        _entries pushBack ["ERROR", "INVALID_DENIAL_MESSAGE", format ["Slot '%1' has a non-text denial message.", _rawSlotName], "", "", ""];
                    };
                    if ((count _rawAccess) > 5 && {(_rawAccess select 5) isEqualType ""} && {(count (_rawAccess select 5)) > 512}) then {
                        _entries pushBack ["ERROR", "DENIAL_MESSAGE_TOO_LONG", format ["Slot '%1' has a denial message longer than 512 characters.", _rawSlotName], "", "", ""];
                    };
                    if ((count _rawAccess) > 6 && {!((_rawAccess select 6) isEqualType [])}) then {
                        _entries pushBack ["ERROR", "INVALID_OPTIONAL_ITEMS", format ["Slot '%1' has a non-array optional-item collection.", _rawSlotName], "", "", ""];
                    } else {
                        {
                            if !(_x isEqualType "" && {[_x] call RACA_fnc_isSafeClassName}) then {
                                _entries pushBack ["ERROR", "INVALID_OPTIONAL_ITEM", format ["Slot '%1' contains an invalid optional class entry.", _rawSlotName], "", "", ""];
                            };
                        } forEach (_rawAccess param [6, [], [[]]]);
                    };
                };
            };

            if ((count _x) > 5 && {!((_x select 5) isEqualType [])}) then {
                _entries pushBack ["ERROR", "INVALID_LIMIT_CONTAINER", format ["Slot '%1' has a non-array quantity-limit collection.", _rawSlotName], "", "", ""];
            } else {
                {
                    if !(_x isEqualType [] && {(count _x) >= 2}) then {
                        _entries pushBack ["ERROR", "MALFORMED_LIMIT", format ["Slot '%1' contains a malformed quantity-limit record.", _rawSlotName], "", "", ""];
                    } else {
                        private _classValue = _x select 0;
                        private _className = _x param [0, "", [""]];
                        private _classKey = toLowerANSI _className;
                        private _validRule = (_classValue isEqualType "") && {
                            [_className] call RACA_fnc_isSafeClassName ||
                            {(_classKey find "category:") isEqualTo 0 && {(_classKey select [9]) in _validCategories}}
                        };
                        if (!_validRule) then {
                            _entries pushBack ["ERROR", "INVALID_LIMIT_RULE", format ["Slot '%1' contains an invalid quantity-limit class or category identifier.", _rawSlotName], _className, "", ""];
                        };
                        if !((_x select 1) isEqualType 0) then {
                            _entries pushBack ["ERROR", "INVALID_LIMIT_VALUE_TYPE", format ["Slot '%1' gives '%2' a non-numeric quantity limit.", _rawSlotName, _className], _className, "", ""];
                        } else {
                            private _limit = _x select 1;
                            if (_limit < -1) then {
                                _entries pushBack ["ERROR", "NEGATIVE_LIMIT", format ["Slot '%1' gives '%2' a negative quantity limit.", _rawSlotName, _className], _className, "", ""];
                            };
                        };
                        if ((count _x) > 2 && {!((_x select 2) isEqualType "")}) then {
                            _entries pushBack ["ERROR", "INVALID_LIMIT_SCOPE_TYPE", format ["Slot '%1' gives '%2' a non-text limit scope.", _rawSlotName, _className], _className, "", ""];
                        } else {
                            private _scope = toLowerANSI (_x param [2, "arsenal", [""]]);
                            if !(_scope in ["interaction", "player", "life", "mission", "arsenal"]) then {
                                _entries pushBack ["ERROR", "INVALID_LIMIT_SCOPE", format ["Slot '%1' uses unsupported limit scope '%2'.", _rawSlotName, _scope], _className, "", ""];
                            };
                        };
                        if ((count _x) > 3 && {!((_x select 3) isEqualType "")}) then {
                            _entries pushBack ["ERROR", "INVALID_RESET_POLICY_TYPE", format ["Slot '%1' gives '%2' a non-text reset policy.", _rawSlotName, _className], _className, "", ""];
                        } else {
                            private _reset = toLowerANSI (_x param [3, "never", [""]]);
                            if !(_reset in ["never", "respawn", "round", "phase", "interaction"]) then {
                                _entries pushBack ["ERROR", "INVALID_RESET_POLICY", format ["Slot '%1' uses unsupported reset policy '%2'.", _rawSlotName, _reset], _className, "", ""];
                            };
                        };
                    };
                } forEach (_x param [5, [], [[]]]);
            };
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
private _slotIds = createHashMap;
{
    _x params ["_slotId", "_slotName", "_preset", "_enabled", "_access", "_limits"];
    if (_slotIds getOrDefault [_slotId, false]) then {
        _entries pushBack ["ERROR", "DUPLICATE_SLOT_ID", format ["Slot identifier '%1' is duplicated.", _slotId], "", "", ""];
    } else {
        _slotIds set [_slotId, true];
    };
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
