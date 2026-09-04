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

/*
 * configSourceMod can report "A3" for community PBOs whose mod metadata is
 * supplied only by the surrounding mod folder. Arma exposes an authoritative
 * PBO-prefix -> loaded-mod index through allAddonsInfo, so build a fallback
 * lookup keyed by the final prefix segment (normally the CfgPatches name).
 */
private _loadedMods = getLoadedModsInfo;
private _addonOwners = createHashMap;
{
    private _prefix = _x param [0, "", [""]];
    private _modIndex = _x param [3, -1, [0]];
    if (_prefix isNotEqualTo "" && {_modIndex >= 0} && {_modIndex < count _loadedMods}) then {
        private _segments = _prefix splitString "\/";
        if (_segments isNotEqualTo []) then {
            private _key = toLowerANSI (_segments select ((count _segments) - 1));
            private _modInfo = _loadedMods select _modIndex;
            private _friendlyName = _modInfo param [0, "", [""]];
            private _modDir = _modInfo param [1, "", [""]];
            private _isOfficial = _modInfo param [3, false, [false]];
            if (_friendlyName isEqualTo "") then {_friendlyName = _modDir};

            private _owner = [_friendlyName, _modDir, _isOfficial];
            private _knownOwner = _addonOwners getOrDefault [_key, []];
            if (_knownOwner isEqualTo []) then {
                _addonOwners set [_key, _owner];
            } else {
                if (_knownOwner isNotEqualTo _owner) then {
                    // An ambiguous prefix tail is not safe attribution evidence.
                    _addonOwners set [_key, ["", "", false]];
                };
            };
        };
    };
} forEach allAddonsInfo;

{
    private _className = _x;
    ([_className] call RACA_fnc_classifyClass) params ["_bucket", "_category", "_config"];

    if (_bucket >= 0) then {
        private _displayName = getText (_config >> "displayName");
        if (_displayName isEqualTo "") then {_displayName = _className};

        private _picture = getText (_config >> "picture");
        private _author = getText (_config >> "author");
        private _sourceAddons = configSourceAddonList _config;
        private _sourceAddon = _sourceAddons param [0, ""];

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

        private _sourcePatch = configFile >> "CfgPatches" >> _sourceAddon;
        private _sourceMod = configSourceMod _config;
        private _patchSourceMod = if (isClass _sourcePatch) then {configSourceMod _sourcePatch} else {""};
        if (_patchSourceMod isNotEqualTo "") then {_sourceMod = _patchSourceMod};
        private _modName = "Arma 3";

        private _owner = _addonOwners getOrDefault [toLowerANSI _sourceAddon, []];
        if (_owner isNotEqualTo [] && {(_owner select 0) isNotEqualTo ""}) then {
            _owner params ["_ownerName", "_ownerDir"];
            _modName = _ownerName;
            if (_ownerDir isNotEqualTo "") then {_sourceMod = _ownerDir};
        } else {
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
