params [
    ["_group", controlNull, [controlNull]],
    ["_value", [], [[]]]
];

if (!isNull _group) then {
    [_group, _value] call RACA_fnc_edenPopulate;
};
