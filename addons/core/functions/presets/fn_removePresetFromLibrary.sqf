/*
 * Archives and removes one named profile preset after the caller has obtained
 * confirmation. Mission-embedded presets are not stored in this library.
 */
params [["_preset", [], [[]]]];

if ((_preset param [0, "", [""]]) isNotEqualTo "RACA_PRESET" || {(count _preset) < 4}) exitWith {false};

private _name = _preset param [2, "", [""]];
if (_name isEqualTo "") exitWith {false};

private _nameKey = toLowerANSI _name;
private _library = call RACA_fnc_getPresetLibrary;
private _presetIndex = _library findIf {toLowerANSI (_x param [2, "", [""]]) isEqualTo _nameKey};
if (_presetIndex < 0) exitWith {false};

private _storedPreset = _library select _presetIndex;
if !([_storedPreset, "Deleted from profile library"] call RACA_fnc_archivePreset) exitWith {false};

_library deleteAt _presetIndex;
profileNamespace setVariable ["RACA_presetLibrary_v1", _library];
saveProfileNamespace;
true
