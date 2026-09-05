/* Selects wording without ever suppressing a status message. */
params [
    ["_class", "standard", [""]],
    ["_standard", "", [""]],
    ["_concise", "", [""]],
    ["_detail", "", [""]]
];
private _verbosity = ["RACA_statusVerbosity"] call RACA_fnc_getSetting;
if (toLowerANSI _class isEqualTo "critical") exitWith {
    if (_verbosity isEqualTo "DETAILED" && {_detail isNotEqualTo ""}) then {_detail} else {_standard}
};
if (_verbosity isEqualTo "CONCISE" && {_concise isNotEqualTo ""}) exitWith {_concise};
if (_verbosity isEqualTo "DETAILED" && {_detail isNotEqualTo ""}) exitWith {_detail};
_standard
