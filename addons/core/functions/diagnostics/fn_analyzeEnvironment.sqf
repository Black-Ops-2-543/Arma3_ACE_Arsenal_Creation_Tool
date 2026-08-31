/*
 * Adds loaded-mod and catalogue health evidence to creator/support preflight.
 * Entry layout matches RACA_fnc_analyzePreset:
 * [severity, code, message, className, sourceMod, sourceAddon].
 */
params [
    ["_catalog", [], [[]]],
    ["_rawPreset", [], [[]]]
];

private _entries = [];
private _aceLoaded = isClass (configFile >> "CfgPatches" >> "ace_main");
private _cbaLoaded = isClass (configFile >> "CfgPatches" >> "cba_main");
if (_aceLoaded && {_cbaLoaded}) then {
    _entries pushBack ["INFO", "CORE_DEPENDENCIES", "ACE3 and CBA_A3 are loaded for this creator session.", "", "ACE3 / CBA_A3", ""];
} else {
    if (!_aceLoaded) then {
        _entries pushBack ["ERROR", "ACE_MISSING", "ACE3 was not detected. RACA cannot build or apply an ACE Arsenal until ACE3 is loaded.", "", "ACE3", "ace_main"];
    };
    if (!_cbaLoaded) then {
        _entries pushBack ["ERROR", "CBA_MISSING", "CBA_A3 was not detected. Load CBA_A3 before ACE3 and RACA.", "", "CBA_A3", "cba_main"];
    };
};

if (isClass (configFile >> "CfgPatches" >> "RACA_Eden")) then {
    _entries pushBack ["INFO", "EDEN_INTEGRATION", "RACA Eden integration is loaded and available for mission assignment.", "", "RACA", "RACA_Eden"];
} else {
    _entries pushBack ["WARNING", "EDEN_MISSING", "RACA Eden integration was not detected. Presets can be authored, but the Restricted Arsenals object attribute will be unavailable.", "", "RACA", "RACA_Eden"];
};

if (_catalog isEqualTo []) then {
    _entries pushBack ["ERROR", "CATALOG_EMPTY", "The active ACE Arsenal catalogue is empty. Verify the loaded mod preset, then reopen Arma and RACA.", "", "", ""];
} else {
    private _sourceMods = [];
    private _sourceAddons = [];
    private _authors = [];
    private _categories = [];
    {
        _x params ["", "", "_category", "", "_modName", "_author", "", "", ["_sourceAddon", ""]];
        if (_modName isNotEqualTo "") then {_sourceMods pushBackUnique _modName};
        if (_sourceAddon isNotEqualTo "") then {_sourceAddons pushBackUnique _sourceAddon};
        if (_author isNotEqualTo "") then {_authors pushBackUnique _author};
        if (_category isNotEqualTo "") then {_categories pushBackUnique _category};
    } forEach _catalog;
    _entries pushBack [
        "INFO",
        "CATALOG_SCOPE",
        format [
            "This session exposes %1 ACE-compatible classes across %2 source mod(s), %3 owning add-on(s), %4 author(s), and %5 category/categories. The catalogue reflects only mods loaded before Arma started.",
            count _catalog,
            count _sourceMods,
            count _sourceAddons,
            count _authors,
            count _categories
        ],
        "",
        "",
        ""
    ];
};

if (_rawPreset isNotEqualTo []) then {
    private _classes = [_rawPreset] call RACA_fnc_flattenPresetClasses;
    private _requirements = ([_rawPreset] call RACA_fnc_getRuntimePolicy) param [7, [], [[]]];
    private _sourceByClass = createHashMap;
    {
        _x params ["", "_className", "", "", "_modName", "", "", "", ["_sourceAddon", ""]];
        _sourceByClass set [_className, [_modName, _sourceAddon]];
    } forEach _catalog;
    {
        _x params [["_className", ""], ["_modName", ""], ["_sourceAddon", ""]];
        if (_className isNotEqualTo "" && {!(_className in _sourceByClass)}) then {
            _sourceByClass set [_className, [_modName, _sourceAddon]];
        };
    } forEach _requirements;
    private _requiredMods = [];
    private _requiredAddons = [];
    {
        (_sourceByClass getOrDefault [_x, ["Unknown", ""]]) params ["_modName", "_sourceAddon"];
        if (_modName isNotEqualTo "") then {_requiredMods pushBackUnique _modName};
        if (_sourceAddon isNotEqualTo "") then {_requiredAddons pushBackUnique _sourceAddon};
    } forEach _classes;
    if (_classes isEqualTo []) then {
        _entries pushBack ["WARNING", "EMPTY_DRAFT", "The current draft contains no classes. Add at least one item before saving or assigning it.", "", "", ""];
    } else {
        _entries pushBack [
            "INFO",
            "PRESET_SOURCE_SCOPE",
            format ["The draft contains %1 class(es) recorded from %2 source mod(s) and %3 owning add-on(s).", count _classes, count _requiredMods, count _requiredAddons],
            "",
            "",
            ""
        ];
    };
};

_entries
