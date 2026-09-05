params ["_record", "_catalog"];
private _runLargeClassListFixture = {
    params ["_recordCount"];
    private _records = [];
    _records resize _recordCount;
    for "_recordIndex" from 0 to (_recordCount - 1) do {
        _records set [_recordIndex, "arifle_MX_F"]
    };
    // Large-record scalability belongs on the explicit class-list grammar.
    // The separate lexical fixtures exercise quoted SQF, comments and escapes;
    // forcing an interpreted character-by-character lexer over every boundary
    // size makes the deterministic suite take many minutes without adding a
    // distinct correctness assertion.
    private _largeText = _records joinString ",";
    private _fixtureStarted = diag_tickTime;
    ([_largeText, format ["Large Records %1", _recordCount]] call RACA_fnc_decodeSqfPreset) params [
        "_largePreset", "", "_largeWarnings"
    ];
    private _elapsed = diag_tickTime - _fixtureStarted;
    private _readNotice = _largeWarnings findIf {
        (_x find format ["Read %1 values", _recordCount]) isEqualTo 0
    };
    diag_log format [
        "[RACA AUTOTEST][PERF] CLASSLIST records=%1 characters=%2 seconds=%3",
        _recordCount, count _largeText, _elapsed
    ];
    [
        _largePreset isNotEqualTo [] &&
        {_readNotice >= 0} &&
        {(count ([_largePreset] call RACA_fnc_flattenPresetClasses)) isEqualTo 1},
        format ["Class-list import accepts %1 input records without a hidden size cap", _recordCount],
        format ["duplicate-heavy fixture; characters=%1 seconds=%2", count _largeText, _elapsed]
    ] call _record;
};
{[_x] call _runLargeClassListFixture} forEach [19999, 20000, 20001, 40280, 50001, 100000];

private _quotedDuplicateRecords = [];
_quotedDuplicateRecords resize 100000;
for "_recordIndex" from 0 to 99999 do {_quotedDuplicateRecords set [_recordIndex, '"arifle_MX_F"']};
private _genericDuplicateText = "private _legacyCargo = [" + (_quotedDuplicateRecords joinString ",") + "];";
_quotedDuplicateRecords = [];
private _genericStarted = diag_tickTime;
private _genericDuplicateResult = [_genericDuplicateText, "Generic Duplicate Stress"] call RACA_fnc_decodeSqfPreset;
diag_log format [
    "[RACA AUTOTEST][PERF] GENERIC_SQF records=100000 characters=%1 seconds=%2",
    count _genericDuplicateText,
    diag_tickTime - _genericStarted
];
[
    (_genericDuplicateResult select 0) isNotEqualTo [] &&
    {(count ([(_genericDuplicateResult select 0)] call RACA_fnc_flattenPresetClasses)) isEqualTo 1} &&
    {(((_genericDuplicateResult select 2) findIf {(_x find "Read 100000 values") isEqualTo 0}) >= 0)},
    "Generic SQF streams 100,000 duplicate quoted records without retaining a token corpus"
] call _record;

private _longLegalClass = "RACA_";
for "_characterIndex" from 1 to 251 do {_longLegalClass = _longLegalClass + "x"};
private _jsonRecords = [];
_jsonRecords resize 100000;
for "_recordIndex" from 0 to 99999 do {
    _jsonRecords set [_recordIndex, [
        "arifle_MX_F",
        "RACA_Autotest_Unavailable_Large"
    ] select (_recordIndex mod 2)]
};
_jsonRecords set [99999, _longLegalClass];
private _largeJsonRaw = [
    "RACA_PRESET", 1, "Large JSON Records", [_jsonRecords, [], [], []],
    ["RACA_RUNTIME", 1, [["arifle_MX_F", 2, "player", "respawn"]], "large", 9, "Autotest", [2026,9,4,0,0,0,0], []],
    ["RACA_INHERITANCE", 1, "Large Parent", "fixture", [["RACA_Autotest_Unavailable_Large"], [], [], []], []],
    ["RACA_AUTOTEST_EXTENSION", 1, ["preserved", 100000]]
];
// This is an import stress fixture, so use the engine's compact serializer.
// Pretty export is covered separately with the complete loaded catalogue.
private _largeJson = toJSON ["RACA_PORTABLE_PRESET", 2, _largeJsonRaw, [["fixture", "duplicate-heavy"]]];
private _largeJsonStarted = diag_tickTime;
([_largeJson] call RACA_fnc_decodePortablePreset) params ["_largeJsonPreset", "", "_largeJsonWarnings"];
private _largeJsonClasses = [_largeJsonPreset] call RACA_fnc_flattenPresetClasses;
diag_log format [
    "[RACA AUTOTEST][PERF] JSON records=100000 characters=%1 seconds=%2",
    count _largeJson,
    diag_tickTime - _largeJsonStarted
];
[
    (count _largeJson) > 2000000 &&
    {(count _largeJsonClasses) isEqualTo 3} &&
    {"arifle_MX_F" in _largeJsonClasses} &&
    {"RACA_Autotest_Unavailable_Large" in _largeJsonClasses} &&
    {_longLegalClass in _largeJsonClasses} &&
    {([_largeJsonPreset] call RACA_fnc_getComposition) isNotEqualTo []} &&
    {(([_largeJsonPreset] call RACA_fnc_getRuntimePolicy) select 4) isEqualTo 9} &&
    {((_largeJsonPreset select [4]) findIf {(_x param [0, ""]) isEqualTo "RACA_AUTOTEST_EXTENSION"}) >= 0},
    "JSON import accepts 100,000 duplicate-heavy records above two million characters without truncation",
    format ["unique=3 notices=%1", count _largeJsonWarnings]
] call _record;

private _fullBuckets = [[], [], [], []];
{(_fullBuckets select (_x select 3)) pushBack (_x select 1)} forEach _catalog;
private _fullRaw = ["RACA_PRESET", 1, "Full Loaded Catalogue", _fullBuckets];
private _fullStarted = diag_tickTime;
private _fullJson = [
    [_fullRaw, _catalog] call RACA_fnc_buildPortablePreset
] call RACA_fnc_formatPortableJson;
([_fullJson] call RACA_fnc_decodePortablePreset) params ["_fullDecoded"];
private _fullActual = count ([_fullDecoded] call RACA_fnc_flattenPresetClasses);
[
    _fullActual isEqualTo count _catalog,
    "JSON imports the complete loaded ACE catalogue without truncation",
    format [
        "catalogue=%1 characters=%2 seconds=%3",
        count _catalog, count _fullJson, diag_tickTime - _fullStarted
    ]
] call _record;

private _libraryBeforeCancellation = +(
    profileNamespace getVariable ["RACA_presetLibrary_v1", []]
);
private _historyBeforeCancellation = +(
    profileNamespace getVariable ["RACA_presetHistory_v1", []]
);
private _cancelledDecode = [
    '["arifle_MX_F"]', "Cancelled", [displayNull, -1, displayNull, 999]
] call RACA_fnc_decodeSqfPreset;
[
    (_cancelledDecode select 0) isEqualTo [] &&
    {_libraryBeforeCancellation isEqualTo (profileNamespace getVariable ["RACA_presetLibrary_v1", []])} &&
    {_historyBeforeCancellation isEqualTo (profileNamespace getVariable ["RACA_presetHistory_v1", []])},
    "Cancelled import work leaves the preset library and history unchanged"
] call _record;
true
