/*
 * Builds searchable metadata for every item ACE Arsenal exposes from the
 * currently loaded base game, DLC, and mods.
 *
 * Record layout:
 * [displayName, className, category, bucket, modName, author, picture,
 *  searchBlob, sourceAddon]
 */
params [["_display", displayNull, [displayNull]]];

private _catalogObject = uiNamespace getVariable ["RACA_catalogObject", objNull];
if (isNull _catalogObject) exitWith {
    if (!isNull _display) then {
        [_display, "The creator catalogue object is unavailable. Reopen the tool from Tutorials."] call RACA_fnc_setStatus;
    };
    []
};

private _aceItems = _catalogObject call ace_arsenal_fnc_getVirtualItems;
if ((count _aceItems) isEqualTo 0) exitWith {
    if (!isNull _display) then {
        [_display, "ACE Arsenal returned an empty item catalogue. Verify that ACE and CBA are loaded."] call RACA_fnc_setStatus;
    };
    []
};

private _classNames = keys _aceItems;
private _catalog = [];
private _modCache = createHashMap;
private _total = count _classNames;

{
    private _className = _x;
    ([_className] call RACA_fnc_classifyClass) params ["_bucket", "_category", "_config"];

    if (_bucket >= 0) then {
        private _displayName = getText (_config >> "displayName");
        if (_displayName isEqualTo "") then {_displayName = _className};

        private _picture = getText (_config >> "picture");
        private _author = getText (_config >> "author");
        private _sourceAddons = configSourceAddonList _config;
        private _addon = _config call ace_common_fnc_getAddon;
        private _sourceAddon = _addon;

        /*
         * configSourceMod on the item class can still be "A3" for a class
         * introduced by an official DLC patch. Resolve the owning CfgPatches
         * entry first. Prefer the patch that explicitly declares this class so
         * later compatibility patches (for example ACE) cannot claim it.
         */
        private _declaringAddon = "";
        {
            private _patchName = _x;
            private _patch = configFile >> "CfgPatches" >> _patchName;
            if (isClass _patch) then {
                private _declared = [];
                {_declared append getArray (_patch >> _x)} forEach ["weapons", "units", "magazines"];
                if (_className in _declared) exitWith {_declaringAddon = _patchName};
            };
        } forEach _sourceAddons;
        if (_declaringAddon isNotEqualTo "") then {_sourceAddon = _declaringAddon};
        if (_sourceAddon isEqualTo "") then {_sourceAddon = _sourceAddons param [0, ""]};

        private _sourcePatch = configFile >> "CfgPatches" >> _sourceAddon;
        private _sourceMod = if (isClass _sourcePatch) then {configSourceMod _sourcePatch} else {""};
        private _modName = "Arma 3";

        if (_sourceMod isNotEqualTo "" && {_sourceMod isNotEqualTo "A3"}) then {
            private _cachedMod = _modCache getOrDefault [_sourceMod, []];
            if (_cachedMod isEqualTo []) then {
                private _params = modParams [_sourceMod, ["name"]];
                _modName = _params param [0, _sourceMod];
                if (_modName isEqualTo "") then {_modName = _sourceMod};
                _cachedMod = [_modName];
                _modCache set [_sourceMod, _cachedMod];
            } else {
                _cachedMod params ["_modName"];
            };
        };

        if (_author isEqualTo "") then {_author = "Unknown"};

        private _itemType = [_className] call BIS_fnc_itemType;
        /*
         * Search the owning add-on, not every config patch touching a class.
         * A compatibility patch (for example ACE adjusting a vanilla item)
         * must not make that vanilla item appear to be ACE content.
         */
        private _searchBlob = toLowerANSI format [
            "%1 %2 %3 %4 %5 %6 %7 %8",
            _displayName,
            _className,
            _category,
            _modName,
            _author,
            _sourceMod,
            _addon,
            _sourceAddon,
            _itemType joinString " "
        ];

        _catalog pushBack [
            _displayName,
            _className,
            _category,
            _bucket,
            _modName,
            _author,
            _picture,
            _searchBlob,
            _sourceAddon
        ];
    };

    if ((_forEachIndex mod 200) isEqualTo 0) then {
        if (!isNull _display) then {
            [_display, format ["Reading loaded arsenal items... %1 / %2", _forEachIndex min _total, _total]] call RACA_fnc_setStatus;
        };
        uiSleep 0.001;
    };
} forEach _classNames;

_catalog sort true;
_catalog
