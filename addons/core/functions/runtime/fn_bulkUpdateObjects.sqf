/*
 * Plans every target before mutation and returns explicit per-target outcomes.
 * Result: ["RACA_BULK_RESULT",1,operation,mode,accepted,requested,changed,
 *          unchanged,rejected,rolledBack,outcomes]
 * Outcome: [objectId,status,reason], status CHANGED/UNCHANGED/REJECTED.
 */
params [
    ["_objects",[],[[]]],
    ["_operation","assign",[""]],
    ["_payload",[],[[]]],
    ["_confirm",false,[true]],
    ["_mode","atomic",[""]]
];
private _op=toLowerANSI _operation;
private _applyMode=toLowerANSI _mode;
private _requested=count _objects;
private _outcomes=[];
private _result={
    params ["_accepted","_rolledBack"];
    private _changed={(_x select 1) isEqualTo "CHANGED"} count _outcomes;
    private _unchanged={(_x select 1) isEqualTo "UNCHANGED"} count _outcomes;
    private _rejected={(_x select 1) isEqualTo "REJECTED"} count _outcomes;
    ["RACA_BULK_RESULT",1,_op,_applyMode,_accepted,_requested,_changed,_unchanged,_rejected,_rolledBack,+_outcomes]
};
if (!isServer || {!_confirm}) exitWith {
    _outcomes pushBack ["<request>","REJECTED","Server confirmation was not present."];
    [false,false] call _result
};
if !(_applyMode in ["atomic","partial"]) exitWith {
    _outcomes pushBack ["<request>","REJECTED",format ["Unsupported application mode '%1'.",_mode]];
    [false,false] call _result
};
if !(_op in ["assign","replace","clear","enable","disable","reset"]) exitWith {
    _outcomes pushBack ["<request>","REJECTED",format ["Unsupported bulk operation '%1'.",_operation]];
    [false,false] call _result
};

private _catalog=uiNamespace getVariable ["RACA_itemCatalog",[]];
private _plans=[];
private _seen=[];
{
    private _object=_x;
    private _fallback=format ["target:%1",_forEachIndex+1];
    if (isNull _object) then {
        _outcomes pushBack [_fallback,"REJECTED","Target no longer exists."];
    } else {
        private _objectId=[_object] call RACA_fnc_getRuntimeObjectId;
        if (_objectId isEqualTo "") then {_objectId=_fallback};
        if (_object in _seen) then {
            _outcomes pushBack [_objectId,"UNCHANGED","Duplicate target was ignored."];
        } else {
            _seen pushBack _object;
            private _current=[_object getVariable ["RACA_objectConfig",[]]] call RACA_fnc_normalizeObjectConfig;
            private _next=[];
            private _action="config";
            private _reason="";
            private _status="PLANNED";
            switch _op do {
                case "clear": {
                    _action="clear";
                    if (_current isEqualTo []) then {_status="UNCHANGED";_reason="Target has no restricted-arsenal configuration."};
                };
                case "reset": {_action="reset"};
                case "assign": {_next=[_payload] call RACA_fnc_normalizeObjectConfig};
                case "replace": {
                    if (_current isEqualTo []) then {
                        _status="REJECTED";
                        _reason="Target has no configuration to replace.";
                    } else {
                        _next=[_payload] call RACA_fnc_normalizeObjectConfig;
                        if (_next isNotEqualTo []) then {
                            private _accessById=createHashMap;
                            {_accessById set [_x select 0,[_x select 4,_x select 7]]} forEach (_current select 2);
                            {
                                private _savedAccess=_accessById getOrDefault [_x select 0,[]];
                                if (_savedAccess isNotEqualTo []) then {_x set [4,_savedAccess select 0];_x set [7,_savedAccess select 1]};
                            } forEach (_next select 2);
                        };
                    };
                };
                case "enable";
                case "disable": {
                    if (_current isEqualTo []) then {
                        _status="REJECTED";
                        _reason="Target has no configuration to toggle.";
                    } else {
                        _next=+_current;
                        private _enabled=_op isEqualTo "enable";
                        private _wouldChange=false;
                        {
                            if ((_x select 3) isNotEqualTo _enabled) then {_wouldChange=true};
                            _x set [3,_enabled];
                        } forEach (_next select 2);
                        if (!_wouldChange) then {_status="UNCHANGED";_reason=format ["All slots are already %1.",["disabled","enabled"] select _enabled]};
                    };
                };
            };
            if (_status isEqualTo "PLANNED" && {_action isEqualTo "config"}) then {
                if (_next isEqualTo []) then {
                    _status="REJECTED";
                    _reason="The proposed object configuration is invalid.";
                } else {
                    ([_next,_catalog] call RACA_fnc_preflightObjectConfig) params ["_canApply","_normalized","_entries"];
                    if (!_canApply || {_normalized isEqualTo []}) then {
                        _status="REJECTED";
                        private _firstError=_entries findIf {(_x select 0) isEqualTo "ERROR"};
                        _reason=if (_firstError < 0) then {"Configuration preflight failed."} else {(_entries select _firstError) select 2};
                    } else {
                        _next=_normalized;
                        if (_next isEqualTo _current) then {_status="UNCHANGED";_reason="Target already has the requested configuration."};
                    };
                };
            };
            private _outcomeIndex=_outcomes pushBack [_objectId,_status,_reason];
            if (_status isEqualTo "PLANNED") then {_plans pushBack [_object,+_current,+_next,_action,_outcomeIndex]};
        };
    };
} forEach _objects;

private _preflightRejected={(_x select 1) isEqualTo "REJECTED"} count _outcomes;
if (_applyMode isEqualTo "atomic" && {_preflightRejected > 0}) exitWith {
    {
        private _index=_x select 4;
        (_outcomes select _index) set [1,"UNCHANGED"];
        (_outcomes select _index) set [2,format ["Atomic preflight aborted because %1 target(s) were rejected.",_preflightRejected]];
    } forEach _plans;
    [false,false] call _result
};

private _quotaState=missionNamespace getVariable ["RACA_quotaState",createHashMap];
private _sessionState=missionNamespace getVariable ["RACA_openSessions",createHashMap];
private _quotaBefore=createHashMapFromArray ((keys _quotaState) apply {[_x,+(_quotaState get _x)]});
private _sessionsBefore=createHashMapFromArray ((keys _sessionState) apply {[_x,+(_sessionState get _x)]});
private _commitFailed=false;
{
    _x params ["_object","_current","_next","_action","_outcomeIndex"];
    private _ok=!isNull _object;
    private _changed=false;
    private _reason="";
    if (_ok) then {
        switch _action do {
            case "clear": {
                [_object,true] call ace_arsenal_fnc_removeBox;
                [_object,"This restricted arsenal was cleared while open. Your previous loadout was restored."] call RACA_fnc_cancelObjectSessions;
                _object setVariable ["RACA_objectConfig",nil,true];
                [_object,[]] remoteExecCall ["RACA_fnc_registerActions",0,_object];
                [_object] call RACA_fnc_unregisterObject;
                _changed=true;
            };
            case "reset": {
                private _removed=["all",_object] call RACA_fnc_resetQuotas;
                _changed=_removed>0;
                if (!_changed) then {_reason="Target had no quota records to reset."};
            };
            default {
                _ok=[_object,_next] call RACA_fnc_applyObjectConfig;
                _changed=_ok;
            };
        };
    } else {_reason="Target disappeared after preflight."};
    if (_ok) then {
        (_outcomes select _outcomeIndex) set [1,["UNCHANGED","CHANGED"] select _changed];
        (_outcomes select _outcomeIndex) set [2,_reason];
    } else {
        (_outcomes select _outcomeIndex) set [1,"REJECTED"];
        (_outcomes select _outcomeIndex) set [2,if (_reason isEqualTo "") then {"Mutation failed after successful preflight."} else {_reason}];
        if (_applyMode isEqualTo "atomic") then {_commitFailed=true};
    };
} forEach _plans;

private _rolledBack=false;
if (_commitFailed) then {
    _rolledBack=true;
    {
        _x params ["_object","_current","_ignoredNext","_ignoredAction","_outcomeIndex"];
        if (!isNull _object && {((_outcomes select _outcomeIndex) select 1) isEqualTo "CHANGED"}) then {
            if (_current isEqualTo []) then {
                [_object,true] call ace_arsenal_fnc_removeBox;
                _object setVariable ["RACA_objectConfig",nil,true];
                [_object,[]] remoteExecCall ["RACA_fnc_registerActions",0,_object];
                [_object] call RACA_fnc_unregisterObject;
            } else {[_object,_current,true] call RACA_fnc_applyObjectConfig};
            (_outcomes select _outcomeIndex) set [1,"UNCHANGED"];
            (_outcomes select _outcomeIndex) set [2,"Rolled back after an atomic commit failure."];
        };
        if (((_outcomes select _outcomeIndex) select 1) isEqualTo "PLANNED") then {
            (_outcomes select _outcomeIndex) set [1,"UNCHANGED"];
            (_outcomes select _outcomeIndex) set [2,"Not attempted after an atomic commit failure."];
        };
    } forEach _plans;
    missionNamespace setVariable ["RACA_quotaState",_quotaBefore];
    missionNamespace setVariable ["RACA_openSessions",_sessionsBefore];
    {if (!isNull (_x select 0)) then {[(_x select 0)] call RACA_fnc_refreshObjectAdminSummary}} forEach _plans;
};

private _accepted=if (_applyMode isEqualTo "atomic") then {!_commitFailed} else {true};
private _final=[_accepted,_rolledBack] call _result;
diag_log format ["[RACA][BULK] operation=%1 mode=%2 requested=%3 changed=%4 unchanged=%5 rejected=%6 accepted=%7 rollback=%8 outcomes=%9",_op,_applyMode,_requested,_final select 6,_final select 7,_final select 8,_accepted,_rolledBack,toJSON (_final select 10)];
_final
