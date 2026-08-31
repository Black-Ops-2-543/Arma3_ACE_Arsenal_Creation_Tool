/*
 * Returns [virtual cargo bucket, broad category, config entry].
 * Buckets match BIS virtual cargo ordering: items, weapons, magazines, backpacks.
 */
params [["_className", "", [""]]];

if (_className isEqualTo "") exitWith {[-1, "", configNull]};

private _config = configFile >> "CfgMagazines" >> _className;
if (isClass _config) exitWith {
    private _isMagazineBackedItem =
        getNumber (_config >> "ACE_asItem") > 0 ||
        {getNumber (_config >> "ACE_isUnique") isEqualTo 1};
    [2, ["Magazines", "Equipment"] select _isMagazineBackedItem, _config]
};

_config = configFile >> "CfgVehicles" >> _className;
if (isClass _config && {getNumber (_config >> "isBackpack") isEqualTo 1}) exitWith {
    [3, "Backpacks", _config]
};

_config = configFile >> "CfgGlasses" >> _className;
if (isClass _config) exitWith {[0, "Facewear", _config]};

_config = configFile >> "CfgWeapons" >> _className;
if (isClass _config) exitWith {
    /*
     * CBA deliberately gives CBA_MiscItem_ItemInfo type 302 (the engine's
     * bipod value) so generic mod inventory items remain usable. This makes
     * BIS_fnc_itemType report medical supplies and tools as attachments.
     * Resolve the generic-item hierarchy first, then use itemType for actual
     * weapon attachments and equipment slots.
     */
    if (_className isKindOf ["CBA_MiscItem", configFile >> "CfgWeapons"] ||
        {_className isKindOf ["ACE_ItemCore", configFile >> "CfgWeapons"]}) exitWith {
        [0, "Equipment", _config]
    };

    private _itemType = [_className] call BIS_fnc_itemType;
    private _kind = _itemType param [0, ""];
    private _type = _itemType param [1, ""];
    private _category = "Equipment";

    if (_type in ["AccessoryMuzzle", "AccessoryPointer", "AccessorySights", "AccessoryBipod"]) then {
        _category = "Attachments";
    } else {
        if (_type isEqualTo "Uniform") then {_category = "Uniforms"} else {
            if (_type isEqualTo "Vest") then {_category = "Vests"} else {
                if (_type isEqualTo "Headgear") then {_category = "Headgear"} else {
                    if (_type isEqualTo "NVGoggles") then {_category = "NVGs"} else {
                        if (_kind isEqualTo "Weapon" && {_type isNotEqualTo "Binocular"}) then {
                            _category = "Weapons";
                        };
                    };
                };
            };
        };
    };

    [[0, 1] select (_category isEqualTo "Weapons"), _category, _config]
};

[-1, "", configNull]
