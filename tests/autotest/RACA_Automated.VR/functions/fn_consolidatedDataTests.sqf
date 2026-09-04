params ["_record", "_catalog", "_preset"];
private _unavailableClass = "RACA_Autotest_Unavailable_Item";
private _extensionMetadata = ["RACA_AUTOTEST_EXTENSION", 1, ["nested", [1, 2, 3]], "verbatim"];
private _losslessName = "Metadata */ ' " + toString [92, 937];
private _losslessRaw = [
    "RACA_PRESET",
    1,
    _losslessName,
    [["arifle_MX_F", _unavailableClass], [], ["30Rnd_65x39_caseless_mag"], []],
    [
        "RACA_RUNTIME", 1,
        [["arifle_MX_F", 2, "player", "respawn"]],
        "Exact notes", 7, "Original Author", [2026,9,4,12,0,0,0],
        [[_unavailableClass,"Missing Mod","Missing_Addon",true]]
    ],
    _extensionMetadata
];
([_losslessRaw] call RACA_fnc_validatePreset) params ["_losslessValidated"];
private _losslessJson = [
    [_losslessValidated, _catalog] call RACA_fnc_buildPortablePreset
] call RACA_fnc_formatPortableJson;
([_losslessJson] call RACA_fnc_decodePortablePreset) params [
    "_losslessDecoded", "", "_losslessWarnings"
];
[
    _losslessDecoded isEqualTo _losslessValidated &&
    {_unavailableClass in ((_losslessDecoded select 3) select 0)} &&
    {(_losslessDecoded findIf {_x isEqualTo _extensionMetadata}) >= 0},
    "JSON preserves unavailable authored cargo, runtime data, and safe extension metadata exactly",
    format ["characters=%1 notices=%2", count _losslessJson, count _losslessWarnings]
] call _record;

private _awkwardSqf = [_losslessValidated] call RACA_fnc_formatSqfExport;
private _lineCommentPrefix = toString [47, 47] + " Preset: Metadata */";
private _blockCommentPrefix = toString [47, 42] + " Preset:";
[
    (_awkwardSqf find _lineCommentPrefix) >= 0 &&
    {(_awkwardSqf find _blockCommentPrefix) < 0},
    "Generated SQF keeps comment delimiters and Unicode preset names non-executable"
] call _record;

true
