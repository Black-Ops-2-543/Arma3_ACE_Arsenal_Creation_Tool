/* Session config is immutable. Cache both available and missing classes by ID. */
params [["_className", "", [""]]];
private _cache = uiNamespace getVariable ["RACA_classificationCache", createHashMap];
private _key = toLowerANSI _className;
private _result = _cache getOrDefault [_key, []];
if (_result isEqualTo []) then {
    _result = [_className] call RACA_fnc_classifyClass;
    _cache set [_key, _result];
    uiNamespace setVariable ["RACA_classificationCache", _cache];
};
_result
