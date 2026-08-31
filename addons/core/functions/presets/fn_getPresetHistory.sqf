params [["_name", "", [""]]];
if (_name isEqualTo "") exitWith {[]};
private _key = toLowerANSI _name;
private _history = profileNamespace getVariable ["RACA_presetHistory_v1", []];
if !(_history isEqualType []) exitWith {[]};
private _result = _history select {
    _x isEqualType [] &&
    {(_x param [0, ""]) isEqualTo "RACA_HISTORY"} &&
    {(_x param [1, -1]) isEqualTo 1} &&
    {(_x param [2, ""]) isEqualTo _key} &&
    {(_x param [8, []]) isEqualType []}
};
reverse _result;
_result
