/*
 * Normalizes the public access-rule envelope used by Eden and runtime checks.
 * Unknown condition kinds and malformed values are discarded, never executed.
 */
params [["_raw", [], [[]]]];

private _default = ["RACA_ACCESS", 1, "AND", [], false, "You are not authorized to use this arsenal.", []];
if ((_raw param [0, "", [""]]) isNotEqualTo "RACA_ACCESS") exitWith {_default};
if ((_raw param [1, -1, [0]]) isNotEqualTo 1) exitWith {_default};

private _mode = toUpperANSI (_raw param [2, "AND", [""]]);
if !(_mode in ["AND", "OR"]) then {_mode = "AND"};
private _conditions = [];
private _supported = ["side", "faction", "group", "rank", "unit", "uid", "vehiclerole", "requireditem", "acepermission"];
{
    if (_x isEqualType [] && {(count _x) >= 2}) then {
        private _kind = toLowerANSI (_x param [0, "", [""]]);
        private _value = _x param [1, "", ["", []]];
        private _validValue = if (_kind isEqualTo "uid") then {
            private _uids = if (_value isEqualType []) then {_value} else {[_value]};
            _uids = _uids select {_x isEqualType "" && {_x isNotEqualTo ""} && {(count _x) <= 64}};
            _value = _uids;
            _uids isNotEqualTo []
        } else {
            _value isEqualType "" && {_value isNotEqualTo ""} && {(count _value) <= 256}
        };
        if (_kind in _supported && {_validValue}) then {_conditions pushBackUnique [_kind, _value]};
    };
} forEach (_raw param [3, [], [[]]]);

private _denial = _raw param [5, _default select 5, [""]];
if (_denial isEqualTo "" || {(count _denial) > 512}) then {_denial = _default select 5};
private _optional = [];
{
    if (_x isEqualType "" && {[_x] call RACA_fnc_isSafeClassName}) then {_optional pushBackUnique _x};
} forEach (_raw param [6, [], [[]]]);

["RACA_ACCESS", 1, _mode, _conditions, false, _denial, _optional]
