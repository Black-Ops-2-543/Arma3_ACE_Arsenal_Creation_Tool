/*
 * Returns [virtual cargo bucket, broad category, config entry].
 * Buckets match BIS virtual cargo ordering: items, weapons, magazines, backpacks.
 */
params [["_className", "", [""]]];

if (_className isEqualTo "") exitWith {[-1, "", configNull]};

private _config = configFile >> "CfgMagazines" >> _className;
if (isClass _config) exitWith {
    /*
     * CfgMagazines also contains throwables, placed explosives, mines, and
     * magazine-backed inventory items such as ACE medical supplies. Keep the
     * ACE virtual-cargo bucket intact while presenting only conventional
     * ammunition in the user-facing Magazines category.
     */
    private _nonAmmunition = uiNamespace getVariable ["RACA_nonAmmunitionMagazines", createHashMap];
    if (isNil {uiNamespace getVariable "RACA_nonAmmunitionMagazines"}) then {
        private _cfgWeapons = configFile >> "CfgWeapons";
        {
            private _weaponConfig = _cfgWeapons >> _x;
            {
                {
                    _nonAmmunition set [_x, true];
                } forEach getArray (_weaponConfig >> _x >> "magazines");
            } forEach getArray (_weaponConfig >> "muzzles");
        } forEach ["Throw", "Put"];
        uiNamespace setVariable ["RACA_nonAmmunitionMagazines", _nonAmmunition];
    };

    private _magazineType = getNumber (_config >> "type");
    private _isMagazineBackedItem =
        getNumber (_config >> "ACE_asItem") > 0 ||
        {getNumber (_config >> "ACE_isUnique") isEqualTo 1};
    private _isConventionalMagazine =
        _magazineType in [16, 256, 512, 768, 1536] &&
        {!(_className in _nonAmmunition)} &&
        {!_isMagazineBackedItem};

    [2, ["Equipment", "Magazines"] select _isConventionalMagazine, _config]
};

_config = configFile >> "CfgVehicles" >> _className;
if (isClass _config && {getNumber (_config >> "isBackpack") isEqualTo 1}) exitWith {
    [3, "Backpacks", _config]
};

_config = configFile >> "CfgGlasses" >> _className;
if (isClass _config) exitWith {[0, "Facewear", _config]};

_config = configFile >> "CfgWeapons" >> _className;
if (isClass _config) exitWith {
    private _itemType = [_className] call BIS_fnc_itemType;
    if ((_itemType param [0, ""]) isEqualTo "Weapon") then {
        [1, "Weapons", _config]
    } else {
        [0, "Equipment", _config]
    }
};

[-1, "", configNull]
