/*
 * Builds searchable metadata for every item ACE Arsenal exposes from the
 * currently loaded base game, DLC, and mods.
 *
 * Record layout:
 * [displayName, className, category, bucket, modName, author, picture, searchBlob]
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
        private _sourceAddon = (configSourceAddonList _config) param [0, ""];
        private _addon = _config call ace_common_fnc_getAddon;
        private _modName = "Arma 3";

        if (_addon isNotEqualTo "") then {
            private _cachedMod = _modCache getOrDefault [_addon, []];
            if (_cachedMod isEqualTo []) then {
                // "author" is not a supported modParams option and produces an
                // engine error for every add-on encountered during a scan.
                private _params = modParams [_addon, ["name"]];
                _modName = _params param [0, _addon];
                if (_modName isEqualTo "") then {_modName = _addon};
                _cachedMod = [_modName];
                _modCache set [_addon, _cachedMod];
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
            _searchBlob
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
