/* [status, version, valid records, exact raw, classified entries]. No writes. */
params [["_raw", []]];
private _preserved = if (_raw isEqualType []) then {+_raw} else {_raw};
if (_raw isEqualType [] && {_raw isEqualTo []}) exitWith {
    ["READY", 1, [], [], []]
};
if !(_raw isEqualType []) exitWith {
    ["BLOCKED", -1, [], _preserved, [[-1, "BLOCKED", "Library root is not an array", _preserved]]]
};
if ((_raw param [0, "", [""]]) isNotEqualTo "RACA_EDEN_CONFIGURATIONS") exitWith {
    ["BLOCKED", -1, [], _preserved, [[-1, "BLOCKED", "Unrecognized library signature", _preserved]]]
};
private _version = _raw param [1, -1, [0]];
if (_version > 1) exitWith {
    ["FUTURE", _version, [], _preserved, [[-1, "BLOCKED", format ["Newer configuration schema version %1", _version], _preserved]]]
};
if (_version isNotEqualTo 1) exitWith {
    ["BLOCKED", _version, [], _preserved, [[-1, "BLOCKED", format ["Unsupported configuration schema version %1", _version], _preserved]]]
};
if ((count _raw) isNotEqualTo 3 || {!((_raw select 2) isEqualType [])}) exitWith {
    ["BLOCKED", _version, [], _preserved, [[-1, "BLOCKED", "Malformed configuration-library envelope", _preserved]]]
};

private _records = _raw select 2;
private _idCounts = createHashMap;
private _nameCounts = createHashMap;
{
    if (_x isEqualType [] && {count _x >= 3}) then {
        private _rawId = _x select 0;
        private _rawName = _x select 1;
        if (_rawId isEqualType "" && {_rawId isNotEqualTo ""}) then {
            private _idKey = toLowerANSI _rawId;
            _idCounts set [_idKey, (_idCounts getOrDefault [_idKey, 0]) + 1]
        };
        if (_rawName isEqualType "" && {_rawName isNotEqualTo ""}) then {
            private _nameKey = toLowerANSI _rawName;
            _nameCounts set [_nameKey, (_nameCounts getOrDefault [_nameKey, 0]) + 1]
        };
    };
} forEach _records;

private _valid = [];
private _entries = [];
{
    private _rawRecord = if (_x isEqualType []) then {+_x} else {_x};
    private _classification = "BLOCKED";
    private _reason = "Malformed record type";
    if (_x isEqualType []) then {
        _reason = if ((count _x) < 3 || {(count _x) > 5}) then {
            "Malformed record field count"
        } else {
            private _rawId = _x select 0;
            private _rawName = _x select 1;
            private _rawPreset = _x select 2;
            private _rawIcon = _x param [3, ""];
            private _rawAccess = _x param [4, ["RACA_ACCESS", 1, "AND", [], false, "You are not authorized to use this arsenal.", []]];
            if !(_rawId isEqualType "") then {
                "Configuration ID is not text"
            } else {
                if !(_rawName isEqualType "") then {
                    "Configuration name is not text"
                } else {
                    if !(_rawPreset isEqualType []) then {
                        "Standalone preset is not an array"
                    } else {
                        if !(_rawIcon isEqualType "") then {
                            "Configuration icon is not text"
                        } else {
                            if !(_rawAccess isEqualType []) then {
                                "Access policy is not an array"
                            } else {
                                private _id = _rawId;
                                private _name = _rawName;
                                private _preset = [_rawPreset] call RACA_fnc_flattenPreset;
                                if (_name isEqualTo "") then {
                                    "Missing configuration name"
                                } else {
                                    if ((count _name) > 128 || {({(_x < 32) || {_x isEqualTo 127}} count toArray _name) > 0}) then {
                                        "Configuration name exceeds the visible-text contract"
                                    } else {
                                        if ((_nameCounts getOrDefault [toLowerANSI _name, 0]) > 1) then {
                                            "Duplicate configuration name"
                                        } else {
                                            if ((count _rawIcon) > 512) then {
                                                "Configuration icon path is too long"
                                            } else {
                                                if (_preset isEqualTo []) then {
                                                    "Invalid standalone preset"
                                                } else {
                                                    if (_id isEqualTo "") then {
                                                        "Missing configuration ID"
                                                    } else {
                                                        if ((_idCounts getOrDefault [toLowerANSI _id, 0]) > 1) then {
                                                            "Duplicate configuration ID"
                                                        } else {
                                                            if !([_id] call RACA_fnc_edenIsSafeConfigurationId) then {
                                                                "Legacy unsafe configuration ID"
                                                            } else {
                                                                private _limits = ([_preset] call RACA_fnc_getRuntimePolicy) select 2;
                                                                private _objectCandidate = [
                                                                    "RACA_OBJECT_CONFIG", 1,
                                                                    [[_id, _name, _preset, true, _rawAccess, _limits, _rawIcon, false]],
                                                                    [["configurationId", _id], ["configurationName", _name]]
                                                                ];
                                                                private _preflight = [_objectCandidate, []] call RACA_fnc_preflightObjectConfig;
                                                                private _errors = (_preflight select 2) select {(_x select 0) isEqualTo "ERROR"};
                                                                if (_errors isEqualTo []) then {""} else {
                                                                    "Invalid assignment data: " + ((_errors select 0) select 2)
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        };
        if (_reason isEqualTo "") then {
            _classification = "VALID";
            _valid pushBack [
                _x select 0,
                _x select 1,
                [_x select 2] call RACA_fnc_flattenPreset,
                _x param [3, ""],
                [_x param [4, []]] call RACA_fnc_normalizeAccess
            ]
        } else {
            if (_reason in ["Missing configuration ID", "Legacy unsafe configuration ID"]) then {
                _classification = "REPAIRABLE"
            };
        };
    };
    _entries pushBack [_forEachIndex, _classification, _reason, _rawRecord];
} forEach _records;

private _status = ["READY", "RECOVERY"] select (
    (_entries findIf {(_x select 1) in ["BLOCKED", "REPAIRABLE"]}) >= 0
);
[_status, _version, _valid, _preserved, _entries]
