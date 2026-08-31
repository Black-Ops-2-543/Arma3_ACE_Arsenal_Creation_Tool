private _group = if (_this isEqualType controlNull) then {
    _this
} else {
    if (_this isEqualType []) then {
        _this param [0, controlNull, [controlNull]]
    } else {
        controlNull
    }
};

if (!isNull _group) then {
    [_group, []] call RACA_fnc_edenPopulate;
};
