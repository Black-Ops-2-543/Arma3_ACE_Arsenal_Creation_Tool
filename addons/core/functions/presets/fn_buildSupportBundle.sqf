/* Produces one clipboard-safe diagnostic bundle without executing imported content. */
params [
    ["_rawPreset", [], [[]]],
    ["_catalog", [], [[]]]
];
([_rawPreset] call RACA_fnc_validatePreset) params ["_preset", "_validationNotices"];
if (_preset isEqualTo []) exitWith {[]};
private _analysis = [_preset, _catalog, []] call RACA_fnc_analyzePreset;
_analysis params ["_ok", "_entries", "_summary"];
_entries append ([_catalog, _preset] call RACA_fnc_analyzeEnvironment);
_summary = [
    {(_x select 0) isEqualTo "ERROR"} count _entries,
    {(_x select 0) isEqualTo "WARNING"} count _entries,
    {(_x select 0) isEqualTo "INFO"} count _entries
];
_analysis = [(_summary select 0) isEqualTo 0, _entries, _summary];
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
