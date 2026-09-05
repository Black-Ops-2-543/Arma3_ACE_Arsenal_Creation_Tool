/* Resolves immutable per-slot ACE cargo once for a normalized object configuration. */
params [["_object",objNull,[objNull]],["_config",[],[[]]]];
if (!isServer || {isNull _object} || {_config isEqualTo []}) exitWith {createHashMap};
private _slots = createHashMap;
{
    _x params ["_slotId","","_preset"];
    private _classes = [];
    private _categories = createHashMap;
    private _seen = createHashMap;
    {
        {
            private _key = toLowerANSI _x;
            if !(_seen getOrDefault [_key,false]) then {
                ([_x] call RACA_fnc_classifyCached) params ["_bucket","_category"];
                if (_bucket >= 0) then {
                    _seen set [_key,true];
                    _classes pushBack _x;
                    _categories set [_key,toLowerANSI _category];
                };
            };
        } forEach _x;
    } forEach (_preset select 3);
    _slots set [_slotId,[_classes,_categories]];
} forEach (_config select 2);
private _generation = (_object getVariable ["RACA_runtimeConfigGeneration",0]) + 1;
_object setVariable ["RACA_runtimeConfigGeneration",_generation,false];
_object setVariable ["RACA_runtimeCargoCache",[_generation,uiNamespace getVariable ["RACA_catalogGeneration",0],_slots],false];
diag_log format ["[RACA][PERF] runtime cargo resolved object=%1 slots=%2 generation=%3",netId _object,count keys _slots,_generation];
_slots
