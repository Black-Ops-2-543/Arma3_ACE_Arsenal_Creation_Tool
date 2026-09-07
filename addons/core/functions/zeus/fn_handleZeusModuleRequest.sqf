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
private _applyMode=["atomic","partial"] select (_logic getVariable ["RACA_allowPartial",false]);
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
private _prefilterOutcomes=[];
{
    private _candidate = _x;
    if (
        !isNull _candidate &&
        {!(_candidate isKindOf "Module_F")} &&
        {_candidate in _linkedTargets} &&
        {isNull _requestCurator || {_candidate in _editableTargets}}
    ) then {
        if (_candidate in _validTargets) then {
            _prefilterOutcomes pushBack [[_candidate] call RACA_fnc_getRuntimeObjectId,"UNCHANGED","Duplicate target was ignored."]
        } else {
            _validTargets pushBack _candidate
        }
    } else {
        private _targetId=if (isNull _candidate) then {format ["target:%1",_forEachIndex+1]} else {[_candidate] call RACA_fnc_getRuntimeObjectId};
        _prefilterOutcomes pushBack [_targetId,"REJECTED","Target was not linked, editable, or still present."];
    };
} forEach _targets;
private _rejectedTargets={(_x select 1) isEqualTo "REJECTED"} count _prefilterOutcomes;
if (_reason isEqualTo "" && {_validTargets isEqualTo []}) then {
    _reason = "Place the module on at least one valid target. Reset All is available only through the explicit administration UI.";
};
if (_reason isEqualTo "" && {_applyMode isEqualTo "atomic"} && {_rejectedTargets>0}) then {
    _reason=format ["Atomic preflight rejected %1 target(s); no targets were changed.",_rejectedTargets];
};

private _changed = 0;
private _bulkResult=[];
// Re-read the authoritative setting at the final mutation boundary. A client
// UI or a setting value captured earlier in the request cannot authorize work.
if (_reason isEqualTo "" && {!(["RACA_enableZeusModules"] call RACA_fnc_getSetting)}) then {
    _reason = localize "STR_RACA_STATUS_ZEUS_DISABLED_COMMIT";
};
if (_reason isEqualTo "") then {
    _logic setVariable ["RACA_serverHandled", true, true];
    switch _op do {
        case "CLEAR": {
            _bulkResult=[_validTargets,"clear",[],true,_applyMode] call RACA_fnc_bulkUpdateObjects
        };
        case "TOGGLE": {
            private _enable = _logic getVariable ["RACA_enable", true];
            private _mode = ["disable", "enable"] select _enable;
            _bulkResult=[_validTargets,_mode,[],true,_applyMode] call RACA_fnc_bulkUpdateObjects;
        };
        case "RESET": {
            _bulkResult=[_validTargets,"reset",[],true,_applyMode] call RACA_fnc_bulkUpdateObjects;
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
                _bulkResult=[_validTargets,"assign",_config,true,_applyMode] call RACA_fnc_bulkUpdateObjects;
            };
        };
    };
};

if (_bulkResult isNotEqualTo []) then {
    _bulkResult set [5,count _targets];
    if (_prefilterOutcomes isNotEqualTo []) then {
        _bulkResult set [7,(_bulkResult select 7)+({(_x select 1) isEqualTo "UNCHANGED"} count _prefilterOutcomes)];
        _bulkResult set [8,(_bulkResult select 8)+_rejectedTargets];
        _bulkResult set [10,(_bulkResult select 10)+_prefilterOutcomes];
    };
    _changed=_bulkResult param [6,0];
    if !(_bulkResult param [4,false]) then {
        _reason="The all-or-nothing target plan was rejected or rolled back; no planned target changes were retained.";
    };
};

if (_bulkResult isEqualTo []) then {
    private _unchanged=[];
    {_unchanged pushBack [[_x] call RACA_fnc_getRuntimeObjectId,"UNCHANGED",_reason]} forEach _validTargets;
    _bulkResult=["RACA_BULK_RESULT",1,toLowerANSI _op,_applyMode,false,count _targets,0,count _unchanged+({(_x select 1) isEqualTo "UNCHANGED"} count _prefilterOutcomes),_rejectedTargets,false,_unchanged+_prefilterOutcomes];
};

private _accepted = _reason isEqualTo "";
private _message = if (_accepted) then {
    format ["%1 %2: %3 changed, %4 unchanged, %5 rejected.",_op,toUpperANSI _applyMode,_bulkResult param [6,0],_bulkResult param [7,0],_bulkResult param [8,0]]
} else {
    format ["%1 rejected: %2", _op, _reason]
};
diag_log format [
    "[RACA][ZEUS:%1] owner=%2 operation=%3 targets=%4 changed=%5 rejected=%6 accepted=%7 reason=%8",
    _requestId,_sender,_op,count _validTargets,_changed,_bulkResult param [8,_rejectedTargets],_accepted,toJSON [_reason,_bulkResult]
];
[
    format ["ZEUS_%1", _op], objNull, _validTargets param [0, objNull], "",
    [_requestId,_sender,_applyMode,_accepted,_bulkResult,_reason]
] call RACA_fnc_logEvent;
if (_sender > 2) then {
    [_requestId,_message,_accepted,_bulkResult] remoteExecCall ["RACA_fnc_receiveZeusModuleResult",_sender]
} else {
    if (hasInterface) then {
        [_requestId,_message,_accepted,_bulkResult] call RACA_fnc_receiveZeusModuleResult
    };
    private _curatorOwners = [];
    {
        private _unit = getAssignedCuratorUnit _x;
        if (!isNull _unit && {owner _unit > 2}) then {
            _curatorOwners pushBackUnique (owner _unit)
        };
    } forEach allCurators;
    {
        [_requestId,_message,_accepted,_bulkResult] remoteExecCall ["RACA_fnc_receiveZeusModuleResult",_x]
    } forEach _curatorOwners;
};
if (!isNull _logic) then {deleteVehicle _logic};
_accepted
