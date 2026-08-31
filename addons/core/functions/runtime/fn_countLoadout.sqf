/* Flattens an Arma unit loadout or inventory array into class-name counts. */
params [["_value", [], [[], ""]]];

private _counts = createHashMap;
private _walk = {
    params ["_node", "_counts", "_self"];
    if (_node isEqualType "") exitWith {
        if (_node isNotEqualTo "" && {[_node] call RACA_fnc_isSafeClassName}) then {
            _counts set [_node, (_counts getOrDefault [_node, 0]) + 1];
        };
    };
    if (_node isEqualType []) then {
        {[_x, _counts, _self] call _self} forEach _node;
    };
};
[_value, _counts, _walk] call _walk;
_counts
