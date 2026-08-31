/* Returns [allowed, denialReason]. Evaluation is deterministic on server and client. */
params [
    ["_unit", objNull, [objNull]],
    ["_access", ["RACA_ACCESS", 1, "AND", [], false, "Access denied.", []], [[]]]
];

if (isNull _unit) exitWith {[false, "No player unit was supplied."]};
if ((_access param [0, "", [""]]) isNotEqualTo "RACA_ACCESS") exitWith {[false, "Access rules are malformed."]};

private _mode = toUpperANSI (_access param [2, "AND", [""]]);
private _conditions = _access param [3, [], [[]]];
private _denial = _access param [5, "You are not authorized to use this arsenal.", [""]];
private _results = [];
private _uid = getPlayerUID _unit;
private _rankOrder = ["PRIVATE", "CORPORAL", "SERGEANT", "LIEUTENANT", "CAPTAIN", "MAJOR", "COLONEL"];

{
    _x params [["_kind", "", [""]], ["_value", "", ["", []]]];
    _kind = toLowerANSI _kind;
    private _matched = switch (_kind) do {
        case "side": {toUpperANSI str (side group _unit) isEqualTo toUpperANSI _value};
        case "faction": {toLowerANSI faction _unit isEqualTo toLowerANSI _value};
        case "group": {toLowerANSI groupId group _unit isEqualTo toLowerANSI _value};
        case "rank": {
            private _actual = _rankOrder find rank _unit;
            private _required = _rankOrder find toUpperANSI _value;
            _required >= 0 && {_actual >= _required}
        };
        case "unit": {typeOf _unit isEqualTo _value};
        case "uid": {
            private _uids = if (_value isEqualType []) then {_value} else {[_value]};
            _uid in _uids
        };
        case "vehiclerole": {
            private _role = (assignedVehicleRole _unit) param [0, ""];
            toLowerANSI _role isEqualTo toLowerANSI _value
        };
        case "requireditem": {
            _value in (items _unit + assignedItems _unit + weapons _unit + magazines _unit)
        };
        case "acepermission": {
            private _permission = missionNamespace getVariable [format ["RACA_permission_%1", _value], []];
            if (_permission isEqualType true) then {_permission} else {_uid in _permission}
        };
        default {false};
    };
    _results pushBack _matched;
} forEach _conditions;

private _allowed = if (_results isEqualTo []) then {true} else {
    if (_mode isEqualTo "OR") then {{_x} count _results > 0} else {{!_x} count _results isEqualTo 0}
};
[_allowed, ["", _denial] select !_allowed]
