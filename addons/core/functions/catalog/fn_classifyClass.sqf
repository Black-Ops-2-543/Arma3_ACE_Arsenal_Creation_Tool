/*
 * Returns [virtual cargo bucket, broad category, config entry].
 * Buckets match BIS virtual cargo ordering: items, weapons, magazines, backpacks.
 */
params [["_className", "", [""]]];

if (_className isEqualTo "") exitWith {[-1, "", configNull]};

private _config = configFile >> "CfgMagazines" >> _className;
if (isClass _config) exitWith {[2, "Magazines", _config]};

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
