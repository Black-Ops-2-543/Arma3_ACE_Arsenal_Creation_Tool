params [["_event", [], [[]]]];
private _group = _event param [0, controlNull, [controlNull]];
if (!isNull _group) then {
    [_group, []] call RACA_fnc_edenPopulate;
};
