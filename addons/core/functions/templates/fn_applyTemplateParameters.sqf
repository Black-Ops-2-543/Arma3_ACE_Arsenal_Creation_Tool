/*
 * Applies policy parameters to a concrete selected-class map.
 * Returns [selectedMap, notices, action summaries].
 */
params [
    ["_catalog", [], [[]]],
    ["_selected", createHashMap, [createHashMap]],
    ["_opticPolicy", "DEFAULT", [""]],
    ["_suppressorPolicy", "DEFAULT", [""]],
    ["_nvgPolicy", "DEFAULT", [""]],
    ["_medicalPolicy", "DEFAULT", [""]]
];

private _notices = [];
private _actions = [];
private _matchesTerms = {
    params ["_record", "_terms"];
    private _blob = _record select 7;
    {(_blob find (toLowerANSI _x)) >= 0} count _terms > 0
};
private _apply = {
    params ["_label", "_policy", "_matches"];
    if (_policy isEqualTo "DEFAULT") exitWith {};
    if (_matches isEqualTo []) exitWith {
        _notices pushBack format ["The %1 policy found no matching classes in the selected source boundary.", toLowerANSI _label];
    };
    private _changed = 0;
    if (_policy in ["ADD", "BASIC", "ALL"]) then {
        {
            private _className = _x select 1;
            if !(_selected getOrDefault [_className, false]) then {_changed = _changed + 1};
            _selected set [_className, true];
        } forEach _matches;
        _actions pushBack format ["%1: added %2 matching class(es)", _label, _changed];
    } else {
        if (_policy isEqualTo "EXCLUDE") then {
            {
                private _className = _x select 1;
                if (_selected getOrDefault [_className, false]) then {_changed = _changed + 1};
                _selected deleteAt _className;
            } forEach _matches;
            _actions pushBack format ["%1: excluded %2 matching class(es)", _label, _changed];
        };
    };
};

private _optics = _catalog select {
    (_x select 2) isEqualTo "Attachments" &&
    {[_x, ["optic", "scope", "sight"]] call _matchesTerms}
};
["Optics", toUpperANSI _opticPolicy, _optics] call _apply;

private _suppressors = _catalog select {
    (_x select 2) isEqualTo "Attachments" &&
    {[_x, ["suppressor", "silencer"]] call _matchesTerms}
};
["Suppressors", toUpperANSI _suppressorPolicy, _suppressors] call _apply;

private _nvgs = _catalog select {(_x select 2) isEqualTo "NVGs"};
["Night vision", toUpperANSI _nvgPolicy, _nvgs] call _apply;

private _medicalTerms = if ((toUpperANSI _medicalPolicy) isEqualTo "BASIC") then {
    ["bandage", "tourniquet", "morphine", "epinephrine", "firstaidkit", "first aid kit"]
} else {
    ["bandage", "tourniquet", "morphine", "epinephrine", "adenosine", "blood", "saline", "plasma", "splint", "surgical", "medical", "medic", "painkiller", "firstaidkit", "first aid kit", "medikit"]
};
private _medical = _catalog select {
    (_x select 2) in ["Equipment", "Magazines"] &&
    {[_x, _medicalTerms] call _matchesTerms}
};
["Medical", toUpperANSI _medicalPolicy, _medical] call _apply;

[_selected, _notices, _actions]
