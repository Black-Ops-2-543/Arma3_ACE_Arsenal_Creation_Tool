/* Materializes one object's administration counters when that object changes. */
params [["_object",objNull,[objNull]],["_config",[],[[]]]];
if (!isServer || {isNull _object}) exitWith {[]};
if (_config isEqualTo []) then {_config=[_object getVariable ["RACA_objectConfig",[]]] call RACA_fnc_normalizeObjectConfig};
if (_config isEqualTo []) exitWith {_object setVariable ["RACA_adminSummary",nil,false]; []};
private _objectId=[_object] call RACA_fnc_getRuntimeObjectId;
private _slots=[];
{
    private _preset=_x select 2;
    _slots pushBack [_x select 0,_x select 1,_x select 3,((_x select 4) param [2,"AND"]),count ((_x select 4) param [3,[]]),count (_x select 5),count ([_preset] call RACA_fnc_flattenPresetClasses)];
} forEach (_config select 2);
private _quota=missionNamespace getVariable ["RACA_quotaState",createHashMap];
private _sessions=missionNamespace getVariable ["RACA_openSessions",createHashMap];
private _quotaCount={((_quota get _x) param [3,""]) isEqualTo _objectId} count keys _quota;
private _sessionCount={((_sessions get _x) param [0,objNull]) isEqualTo _object} count keys _sessions;
private _revision=(_object getVariable ["RACA_adminSummaryRevision",0])+1;
private _summary=[_object,_objectId,vehicleVarName _object,typeOf _object,getPosWorld _object,_slots,_quotaCount,_sessionCount,_revision];
_object setVariable ["RACA_adminSummaryRevision",_revision,false];
_object setVariable ["RACA_adminSummary",_summary,false];
_summary
