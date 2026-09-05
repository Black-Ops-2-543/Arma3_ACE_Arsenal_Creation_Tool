params [
    ["_logic", objNull, [objNull]],
    ["_operation", "", [""]],
    ["_targets", [], [[]]],
    ["_localOwner", -1, [0]]
];
if (!isServer) exitWith {false};

private _sender = if (_localOwner >= 0) then {_localOwner} else {remoteExecutedOwner};
private _requestId = format ["z%1_%2", floor (diag_tickTime * 1000), floor random 1000000];
private _op = toUpperANSI _operation;
private _expected = switch _op do {
    case "ASSIGN": {"RACA_ModuleAssign"};
    case "CLEAR": {"RACA_ModuleClear"};
    case "TOGGLE": {"RACA_ModuleToggle"};
    case "RESET": {"RACA_ModuleResetQuotas"};
    default {""};
};

private _requestCurator = objNull;
private _authorized = _sender isEqualTo 2;
if (!_authorized && {_sender > 2}) then {
    private _curatorIndex = allCurators findIf {
        private _unit = getAssignedCuratorUnit _x;
        !isNull _unit && {owner _unit isEqualTo _sender}
    };
    if (_curatorIndex >= 0) then {
        _requestCurator = allCurators select _curatorIndex;
        _authorized = true
    };
};

private _reason = "";
if (!_authorized) then {_reason = "Requester is not the current authorized curator."};
if (_reason isEqualTo "" && {
    isNull _logic || {_expected isEqualTo ""} || {typeOf _logic isNotEqualTo _expected}
}) then {
    _reason = "Module identity did not match the requested operation.";
};
if (_reason isEqualTo "" && {
    !(["RACA_enableZeusModules"] call RACA_fnc_getSetting)
}) then {
    _reason = localize "STR_RACA_STATUS_ZEUS_DISABLED";
};
if (_reason isEqualTo "" && {_logic getVariable ["RACA_serverHandled", false]}) then {
    _reason = "This module placement was already handled."
};

private _linkedTargets = if (isNull _logic) then {[]} else {
    synchronizedObjects _logic select {!(_x isKindOf "Module_F")}
};
private _editableTargets = if (isNull _requestCurator) then {[]} else {
    curatorEditableObjects _requestCurator
};
private _validTargets = [];
{
    private _candidate = _x;
    if (
        !isNull _candidate &&
        {!(_candidate isKindOf "Module_F")} &&
        {_candidate in _linkedTargets} &&
        {isNull _requestCurator || {_candidate in _editableTargets}}
    ) then {_validTargets pushBackUnique _candidate};
} forEach _targets;
private _rejectedTargets = (count _targets) - (count _validTargets);
if (_reason isEqualTo "" && {_validTargets isEqualTo []}) then {
    _reason = "Place the module on at least one valid target. Reset All is available only through the explicit administration UI.";
};

private _changed = 0;
// Re-read the authoritative setting at the final mutation boundary. A client
// UI or a setting value captured earlier in the request cannot authorize work.
if (_reason isEqualTo "" && {!(["RACA_enableZeusModules"] call RACA_fnc_getSetting)}) then {
    _reason = localize "STR_RACA_STATUS_ZEUS_DISABLED_COMMIT";
};
if (_reason isEqualTo "") then {
    _logic setVariable ["RACA_serverHandled", true, true];
    switch _op do {
        case "CLEAR": {
            _changed = [_validTargets, "clear", [], true] call RACA_fnc_bulkUpdateObjects
        };
        case "TOGGLE": {
            private _enable = _logic getVariable ["RACA_enable", true];
            private _mode = ["disable", "enable"] select _enable;
            _changed = [_validTargets, _mode, [], true] call RACA_fnc_bulkUpdateObjects;
        };
        case "RESET": {
            {
                _changed = _changed + (["all", _x] call RACA_fnc_resetQuotas)
            } forEach _validTargets;
        };
        case "ASSIGN": {
            private _choice = _logic getVariable ["RACA_presetName", ""];
            private _slotName = _logic getVariable ["RACA_slotName", "Restricted Arsenal"];
            private _raw = missionNamespace getVariable ["RACA_missionArsenalConfigurations", []];
            private _records = if (
                _raw isEqualType [] &&
                {(_raw param [0, ""]) isEqualTo "RACA_EDEN_CONFIGURATIONS"} &&
                {(_raw param [1, -1]) isEqualTo 1}
            ) then {_raw param [2, []]} else {[]};
            private _match = _records findIf {
                toLowerANSI (_x param [0, ""]) isEqualTo toLowerANSI _choice ||
                {toLowerANSI (_x param [1, ""]) isEqualTo toLowerANSI _choice}
            };
            private _config = [];
            if (_match >= 0) then {
                private _configuration = _records select _match;
                private _preset = [_configuration param [2, []]] call RACA_fnc_flattenPreset;
                if (_preset isNotEqualTo []) then {
                    private _id = _configuration select 0;
                    private _name = _configuration select 1;
                    private _access = [_configuration param [4, []]] call RACA_fnc_normalizeAccess;
                    private _runtime = [_preset] call RACA_fnc_getRuntimePolicy;
                    _config = [
                        "RACA_OBJECT_CONFIG", 1,
                        [[
                            _id,
                            [_slotName, _name] select (_slotName isEqualTo ""),
                            _preset,
                            true,
                            _access,
                            _runtime select 2,
                            _configuration param [3, ""],
                            false
                        ]],
                        [["persistence", "mission"], ["configurationId", _id], ["configurationName", _name]]
                    ];
                };
            };
            if (_config isEqualTo []) then {
                {
                    private _slots = (_x select 1) param [2, []];
                    private _slotIndex = _slots findIf {
                        toLowerANSI (_x param [0, ""]) isEqualTo toLowerANSI _choice ||
                        {toLowerANSI ((_x param [2, []]) param [2, ""]) isEqualTo toLowerANSI _choice}
                    };
                    if (_slotIndex >= 0) exitWith {
                        private _chosenSlot = +(_slots select _slotIndex);
                        if (_slotName isNotEqualTo "") then {
                            _chosenSlot set [1, _slotName]
                        };
                        _config = [
                            "RACA_OBJECT_CONFIG", 1,
                            [_chosenSlot],
                            [["persistence", "session"]]
                        ];
                    };
                } forEach call RACA_fnc_getMissionRegistry;
            };
            if (_config isEqualTo [] && {
                ["RACA_allowZeusProfilePresetFallback"] call RACA_fnc_getSetting
            }) then {
                private _library = call RACA_fnc_getPresetLibrary;
                private _presetIndex = _library findIf {
                    toLowerANSI (_x select 2) isEqualTo toLowerANSI _choice
                };
                if (_presetIndex >= 0) then {
                    private _preset = [_library select _presetIndex] call RACA_fnc_flattenPreset;
                    private _runtime = [_preset] call RACA_fnc_getRuntimePolicy;
                    _config = [
                        "RACA_OBJECT_CONFIG", 1,
                        [[
                            "zeus", _slotName, _preset, true,
                            ["RACA_ACCESS", 1, "AND", [], false, "Access denied.", []],
                            _runtime select 2, "", false
                        ]],
                        [["persistence", "session"]]
                    ];
                };
            };
            if (_config isEqualTo []) then {
                _reason = format [
                    "Mission configuration '%1' was not found. Server-profile fallback is disabled unless the mission explicitly enables it.",
                    _choice
                ];
            } else {
                _changed = [_validTargets, "assign", _config, true] call RACA_fnc_bulkUpdateObjects;
            };
        };
    };
};

private _accepted = _reason isEqualTo "";
private _message = if (_accepted) then {
    format ["%1 accepted for %2 target(s): %3 change(s), %4 rejected input(s).", _op, count _validTargets, _changed, _rejectedTargets]
} else {
    format ["%1 rejected: %2", _op, _reason]
};
diag_log format [
    "[RACA][ZEUS:%1] owner=%2 operation=%3 targets=%4 changed=%5 rejected=%6 accepted=%7 reason=%8",
    _requestId, _sender, _op, count _validTargets, _changed, _rejectedTargets, _accepted, toJSON _reason
];
[
    format ["ZEUS_%1", _op], objNull, _validTargets param [0, objNull], "",
    [_requestId, _sender, count _validTargets, _changed, _rejectedTargets, _accepted, _reason]
] call RACA_fnc_logEvent;
if (_sender > 2) then {
    [_requestId, _message, _accepted] remoteExecCall ["RACA_fnc_receiveZeusModuleResult", _sender]
} else {
    if (hasInterface) then {
        [_requestId, _message, _accepted] call RACA_fnc_receiveZeusModuleResult
    };
    private _curatorOwners = [];
    {
        private _unit = getAssignedCuratorUnit _x;
        if (!isNull _unit && {owner _unit > 2}) then {
            _curatorOwners pushBackUnique (owner _unit)
        };
    } forEach allCurators;
    {
        [_requestId, _message, _accepted] remoteExecCall ["RACA_fnc_receiveZeusModuleResult", _x]
    } forEach _curatorOwners;
};
if (!isNull _logic) then {deleteVehicle _logic};
_accepted
