#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};

private _className = _display getVariable ["RACA_itemDetailsClassName", ""];
private _catalog = uiNamespace getVariable ["RACA_itemCatalog", []];
private _catalogIndex = [_catalog] call RACA_fnc_indexCatalog;
private _index = (_catalogIndex get "class") getOrDefault [toLowerANSI _className, -1];
if (_className isEqualTo "" || {_index < 0}) exitWith {
    (_display displayCtrl RACA_IDC_ITEM_DETAILS_TITLE) ctrlSetText "Item Details Unavailable";
    (_display displayCtrl RACA_IDC_ITEM_DETAILS_TEXT) ctrlSetText "The selected class is no longer present in the active ACE Arsenal catalogue.";
    (_display displayCtrl RACA_IDC_ITEM_DETAILS_INCLUDE) ctrlEnable false;
    (_display displayCtrl RACA_IDC_ITEM_DETAILS_FAVORITE) ctrlEnable false;
    false
};

private _record = _catalog select _index;
_record params ["_displayName", "", "_category", "_bucket", "_modName", "_author", "_picture", "", ["_sourceAddon", ""]];
([_className] call RACA_fnc_classifyClass) params ["", "", "_config"];

private _configFamily = switch true do {
    case (isClass (configFile >> "CfgWeapons" >> _className)): {"CfgWeapons"};
    case (isClass (configFile >> "CfgMagazines" >> _className)): {"CfgMagazines"};
    case (isClass (configFile >> "CfgVehicles" >> _className)): {"CfgVehicles"};
    case (isClass (configFile >> "CfgGlasses" >> _className)): {"CfgGlasses"};
    default {"Unknown"};
};
private _baseConfig = inheritsFrom _config;
private _baseClass = if (isClass _baseConfig) then {configName _baseConfig} else {"None"};
private _itemType = [_className] call BIS_fnc_itemType;
private _itemTypeText = if (_itemType isEqualTo []) then {"Unknown"} else {_itemType joinString " / "};
private _sourceAddons = configSourceAddonList _config;
if (_sourceAddons isEqualTo [] && {_sourceAddon isNotEqualTo ""}) then {_sourceAddons = [_sourceAddon]};
private _sourceText = if (_sourceAddons isEqualTo []) then {"Unknown"} else {_sourceAddons joinString ", "};
private _dlc = getText (_config >> "dlc");
if (_dlc isEqualTo "") then {_dlc = "None / base content"};
private _model = getText (_config >> "model");
if (_model isEqualTo "") then {_model = "Not declared"};
private _mass = getNumber (_config >> "ItemInfo" >> "mass");
if (_mass <= 0) then {_mass = getNumber (_config >> "mass")};
private _massText = if (_mass <= 0) then {"Not declared"} else {str _mass};
private _scope = getNumber (_config >> "scope");
private _bucketName = ["Items", "Weapons", "Magazines", "Backpacks"] param [_bucket, "Unknown"];

private _compatibility = [];
private _magazines = getArray (_config >> "magazines");
private _magazineWells = getArray (_config >> "magazineWell");
if (_magazines isNotEqualTo [] || {_magazineWells isNotEqualTo []}) then {
    _compatibility pushBack format ["  - Direct magazines: %1", count _magazines];
    _compatibility pushBack format ["  - Magazine wells: %1", count _magazineWells];
};
private _ammo = getText (_config >> "ammo");
if (_ammo isNotEqualTo "") then {_compatibility pushBack format ["  - Ammunition class: %1", _ammo]};
private _capacity = getNumber (_config >> "maximumLoad");
if (_capacity > 0) then {_compatibility pushBack format ["  - Container capacity: %1", _capacity]};
private _itemInfoType = getNumber (_config >> "ItemInfo" >> "type");
if (_itemInfoType > 0) then {_compatibility pushBack format ["  - ItemInfo type: %1", _itemInfoType]};
if (_compatibility isEqualTo []) then {_compatibility pushBack "  - No additional compatibility metadata is declared on this config class."};

private _selectedMap = uiNamespace getVariable ["RACA_builderSelected", createHashMap];
private _inheritedMap = uiNamespace getVariable ["RACA_builderInherited", createHashMap];
private _favoriteMap = uiNamespace getVariable ["RACA_catalogFavorites", createHashMap];
private _limits = uiNamespace getVariable ["RACA_builderLimits", createHashMap];
private _selected = _selectedMap getOrDefault [_className, false];
private _inherited = _inheritedMap getOrDefault [_className, false];
private _favorite = _favoriteMap getOrDefault [_className, false];
private _tags = (uiNamespace getVariable ["RACA_catalogTagIndex", createHashMap]) getOrDefault [toLowerANSI _className, []];
private _selectionState = if (_inherited) then {
    ["Inherited from the source preset but explicitly removed", "Inherited from the source preset and included"] select _selected
} else {
    ["Excluded", "Explicitly included"] select _selected
};
private _limit = _limits getOrDefault [_className, []];
private _categoryLimit = _limits getOrDefault [format ["category:%1", _category], []];
private _policyLines = [];
{
    _x params ["_label","_policy"];
    if (_policy isNotEqualTo []) then {_policyLines pushBack format ["%1: %2 | Scope: %3 | Reset: %4",_label,_policy select 1,_policy select 2,_policy select 3]};
} forEach [["Exact item limit",_limit],["Shared category limit",_categoryLimit]];
if (_policyLines isEqualTo []) then {_policyLines pushBack "No authored quantity policies."};
_policyLines pushBack "All applicable policies apply together. These are authored limits, not live remaining quotas.";
private _limitText = _policyLines joinString toString [10];
private _resolvedMags = [_className] call RACA_fnc_getCompatibleMagazines;
(_display displayCtrl RACA_IDC_SHOW_MAGAZINES) ctrlShow (_resolvedMags isNotEqualTo []);
(_display displayCtrl RACA_IDC_SHOW_MAGAZINES) ctrlEnable (_resolvedMags isNotEqualTo []);
if (_bucket isEqualTo 1) then {_compatibility pushBack format ["Loaded compatible magazines (all muzzles and wells): %1",count _resolvedMags]};

private _lines = [
    format ["Display name: %1", _displayName],
    format ["Class name: %1", _className],
    format ["Category: %1 | ACE virtual-cargo bucket: %2", _category, _bucketName],
    format ["Config family: %1 | Immediate base class: %2 | Scope: %3", _configFamily, _baseClass, _scope],
    format ["Source mod: %1", _modName],
    format ["Owning/source add-ons: %1", _sourceText],
    format ["Author: %1 | DLC tag: %2", _author, _dlc],
    format ["BIS item type: %1 | Inventory mass: %2", _itemTypeText, _massText],
    format ["Model: %1", _model],
    format ["ACE catalogue availability: Yes — present in this running Arma session"],
    format ["Draft state: %1 | Favorite: %2", _selectionState, ["No", "Yes"] select _favorite],
    format ["Catalogue tags: %1", if (_tags isEqualTo []) then {"None"} else {_tags joinString ", "}],
    format ["Authored quantity policies: %1", _limitText],
    "Compatibility details:",
    _compatibility joinString (toString [10])
];
private _report = _lines joinString (toString [10]);
_display setVariable ["RACA_itemDetailsReport", _report];

(_display displayCtrl RACA_IDC_ITEM_DETAILS_TITLE) ctrlSetText format ["Item Details — %1", _displayName];
private _pictureControl = _display displayCtrl RACA_IDC_ITEM_DETAILS_PICTURE;
_pictureControl ctrlSetText _picture;
_pictureControl ctrlShow (_picture isNotEqualTo "");
private _textControl = _display displayCtrl RACA_IDC_ITEM_DETAILS_TEXT;
_textControl ctrlSetText _report;
private _pos = ctrlPosition _textControl;
_pos set [3, (ctrlTextHeight _textControl + 0.04 * safeZoneH) max (0.46 * safeZoneH)];
_textControl ctrlSetPosition _pos;
_textControl ctrlCommit 0;
(_display displayCtrl RACA_IDC_ITEM_DETAILS_INCLUDE) ctrlSetText (["Include Item", "Exclude Item"] select _selected);
(_display displayCtrl RACA_IDC_ITEM_DETAILS_FAVORITE) ctrlSetText (["Add Favorite", "Remove Favorite"] select _favorite);
(_display displayCtrl RACA_IDC_ITEM_DETAILS_STATUS) ctrlSetText "Details reflect the currently running Arma mod set and the unsaved creator draft.";
true
