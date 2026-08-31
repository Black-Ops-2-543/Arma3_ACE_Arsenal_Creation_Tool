/* Produces one clipboard-safe diagnostic bundle without executing imported content. */
params [
    ["_rawPreset", [], [[]]],
    ["_catalog", [], [[]]]
];
([_rawPreset] call RACA_fnc_validatePreset) params ["_preset", "_validationNotices"];
if (_preset isEqualTo []) exitWith {[]};
private _analysis = [_preset, _catalog, []] call RACA_fnc_analyzePreset;
private _manifest = [_preset, _catalog] call RACA_fnc_buildModManifest;
private _portable = [_preset, _catalog] call RACA_fnc_buildPortablePreset;
private _version = getText (configFile >> "CfgPatches" >> "RACA_Core" >> "versionStr");
if (_version isEqualTo "") then {_version = "development"};
[
    "RACA_SUPPORT_BUNDLE",
    1,
    [
        ["generatedAtUTC", systemTimeUTC],
        ["racaVersion", _version],
        ["armaProductVersion", productVersion],
        ["worldName", worldName],
        ["multiplayer", isMultiplayer],
        ["profileName", profileName],
        ["activatedAddons", activatedAddons],
        ["validationNotices", _validationNotices]
    ],
    _manifest,
    _analysis,
    _portable
]
