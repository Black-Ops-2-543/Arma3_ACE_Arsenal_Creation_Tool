/*
 * Removes stale quota records while preserving counters for unchanged slot rules.
 * Pass an empty config when the object is being unregistered or deleted.
 */
params [
    ["_object", objNull, [objNull]],
    ["_config", [], [[]]],
    ["_storedObjectId", "", [""]]
];
if (!isServer) exitWith {0};

private _objectId = [_object, _storedObjectId] call RACA_fnc_getRuntimeObjectId;
if (_objectId isEqualTo "") exitWith {0};

private _validSlots = createHashMap;
private _validSlotIds = [];
private _normalized = if (_config isEqualTo []) then {[]} else {[_config] call RACA_fnc_normalizeObjectConfig};
if (_normalized isNotEqualTo []) then {
    {
        private _slotId = _x select 0;
        private _rules = createHashMap;
        {
            _x params ["_ruleId", "_limit", "_scope", "_reset"];
            if (_limit >= 0 && {_scope isNotEqualTo "interaction"}) then {
                _rules set [_ruleId, [_scope, _reset]];
            };
        } forEach (_x select 5);
        _validSlots set [_slotId, _rules];
        _validSlotIds pushBackUnique _slotId;
    } forEach (_normalized select 2);
};

private _quota = missionNamespace getVariable ["RACA_quotaState", createHashMap];
private _removed = 0;
{
    private _record = _quota get _x;
    private _recordScope = _record param [1, "", [""]];
    private _recordReset = _record param [2, "", [""]];
    private _recordObjectId = _record param [3, "", [""]];
    private _recordSlotId = _record param [4, "", [""]];
    private _recordRuleId = _record param [6, "", [""]];
    if (_recordObjectId isEqualTo _objectId) then {
        private _keep = false;
        if (_recordSlotId in _validSlotIds) then {
            private _rules = _validSlots get _recordSlotId;
            private _currentPolicy = _rules getOrDefault [_recordRuleId, []];
            _keep = _currentPolicy isEqualTo [_recordScope, _recordReset];
        };
        if (!_keep) then {
            _quota deleteAt _x;
            _removed = _removed + 1;
        };
    };
} forEach keys _quota;
missionNamespace setVariable ["RACA_quotaState", _quota];
_removed
