/*
 * Counts class quantities in getUnitLoadout format.
 * Container cargo uses [class, quantity, ...], while a weapon's loaded
 * magazine uses [class, rounds]; the two shapes must not be conflated.
 */
params [["_loadout", [], [[]]]];

private _counts = createHashMap;
private _add = {
    params ["_className", ["_quantity", 1]];
    if (_className isEqualType "" && {_className isNotEqualTo ""} && {[_className] call RACA_fnc_isSafeClassName}) then {
        _counts set [_className, (_counts getOrDefault [_className, 0]) + floor (_quantity max 0)];
    };
};

private _countWeapon = {
    params [["_weapon", [], [[]]]];
    if (_weapon isEqualTo []) exitWith {};
    [_weapon param [0, ""], 1] call _add;
    {[_weapon param [_x, ""], 1] call _add} forEach [1, 2, 3, 6];
    {
        private _magazine = _weapon param [_x, []];
        if (_magazine isEqualType [] && {_magazine isNotEqualTo []}) then {
            [_magazine param [0, ""], 1] call _add;
        };
    } forEach [4, 5];
};

private _countContainer = {
    params [["_container", [], [[]]]];
    if (_container isEqualTo []) exitWith {};
    [_container param [0, ""], 1] call _add;
    private _cargo = _container param [1, []];
    {
        if (_x isEqualType []) then {
            private _className = _x param [0, ""];
            private _quantity = _x param [1, 1];
            if (_quantity isEqualType 0) then {
                [_className, _quantity] call _add;
            } else {
                [_className, 1] call _add;
            };
        };
    } forEach _cargo;
};

{[_loadout param [_x, []]] call _countWeapon} forEach [0, 1, 2, 8];
{[_loadout param [_x, []]] call _countContainer} forEach [3, 4, 5];
{[_loadout param [_x, ""], 1] call _add} forEach [6, 7];
{
    [_x, 1] call _add;
} forEach (_loadout param [9, []]);

_counts
