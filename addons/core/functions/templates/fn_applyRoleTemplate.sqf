params [
    ["_templateId", "rifleman", [""]],
    ["_catalog", [], [[]]],
    ["_replace", false, [true]]
];
private _templates = call RACA_fnc_getRoleTemplates;
private _index = _templates findIf {(_x select 0) isEqualTo toLowerANSI _templateId};
if (_index < 0) exitWith {[createHashMap, [format ["Unknown role template '%1'.", _templateId]] ]};
private _template = _templates select _index;
private _rules = _template select 3;
private _selected = if (_replace) then {createHashMap} else {uiNamespace getVariable ["RACA_builderSelected", createHashMap]};
private _warnings = [];
{
    _x params ["_category", "_keywords"];
    private _matches = _catalog select {
        private _blob = _x select 7;
        (_x select 2) isEqualTo _category && {{(_blob find toLowerANSI _x) >= 0} count _keywords > 0}
    };
    if (_matches isEqualTo []) then {_warnings pushBack format ["No loaded %1 matched %2.", _category, _keywords]} else {
        { _selected set [_x select 1, true] } forEach _matches;
    };
} forEach _rules;
uiNamespace setVariable ["RACA_builderSelected", _selected];
[_selected, _warnings, _template]
