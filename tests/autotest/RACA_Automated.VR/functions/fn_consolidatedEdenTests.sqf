params ["_record", "_preset", "_access"];
private _configurationRecord = ["cfg_1", "Alpha / Support", _preset, "", _access];
private _validEnvelope = ["RACA_EDEN_CONFIGURATIONS", 1, [_configurationRecord]];
private _validEnvelopeState = [_validEnvelope] call RACA_fnc_edenParseConfigurationEnvelope;
[
    (_validEnvelopeState select 0) isEqualTo "READY" &&
    {(count (_validEnvelopeState select 2)) isEqualTo 1} &&
    {(_validEnvelopeState select 3) isEqualTo _validEnvelope},
    "Configuration envelope keeps display names separate from safe opaque IDs",
    str _validEnvelopeState
] call _record;

private _malformedAccessConfiguration = +_configurationRecord;
_malformedAccessConfiguration set [4, "not-an-access-envelope"];
private _malformedAccessPreflight = [_malformedAccessConfiguration, []] call RACA_fnc_validateConfigurationForAssignment;
[
    !(_malformedAccessPreflight select 0) &&
    {((_malformedAccessPreflight select 2) findIf {(_x select 1) isEqualTo "INVALID_ACCESS_CONTAINER"}) >= 0},
    "Shared Eden assignment preflight sees malformed access data before normalization",
    str _malformedAccessPreflight
] call _record;

private _futureEnvelope = [
    "RACA_EDEN_CONFIGURATIONS", 2,
    [_configurationRecord, ["future", [1,2,3]]]
];
private _futureState = [_futureEnvelope] call RACA_fnc_edenParseConfigurationEnvelope;
[
    (_futureState select 0) isEqualTo "FUTURE" &&
    {(_futureState select 3) isEqualTo _futureEnvelope} &&
    {(_futureState select 2) isEqualTo []},
    "Unknown configuration schema remains byte-for-byte recovery data and cannot be edited"
] call _record;

private _scalarRoot = 17;
private _scalarState = [_scalarRoot] call RACA_fnc_edenParseConfigurationEnvelope;
[
    (_scalarState select 0) isEqualTo "BLOCKED" &&
    {(_scalarState select 3) isEqualTo _scalarRoot} &&
    {((_scalarState select 4 select 0) select 0) isEqualTo -1},
    "Malformed scalar configuration storage remains exact recovery data"
] call _record;

private _malformedEnvelope = ["RACA_EDEN_CONFIGURATIONS", 1, [_configurationRecord], ["unexpected", 4]];
private _malformedEnvelopeState = [_malformedEnvelope] call RACA_fnc_edenParseConfigurationEnvelope;
[
    (_malformedEnvelopeState select 0) isEqualTo "BLOCKED" &&
    {(_malformedEnvelopeState select 3) isEqualTo _malformedEnvelope} &&
    {(_malformedEnvelopeState select 2) isEqualTo []},
    "Malformed configuration envelopes are blocked without partial normalization"
] call _record;

private _unsafeEnvelope = [
    "RACA_EDEN_CONFIGURATIONS", 1,
    [["legacy unsafe/id", "Legacy", _preset, "", _access]]
];
private _unsafeState = [_unsafeEnvelope] call RACA_fnc_edenParseConfigurationEnvelope;
[
    (_unsafeState select 0) isEqualTo "RECOVERY" &&
    {((_unsafeState select 4 select 0) select 1) isEqualTo "REPAIRABLE"},
    "A unique legacy unsafe configuration ID is explicitly repairable"
] call _record;

private _duplicateEnvelope = ["RACA_EDEN_CONFIGURATIONS", 1, [
    ["cfg_duplicate", "One", _preset, "", _access],
    ["CFG_DUPLICATE", "Two", _preset, "", _access],
    ["cfg_3", "Name Collision", _preset, "", _access],
    ["cfg_4", "name collision", _preset, "", _access],
    "malformed record",
    ["cfg_5", "Invalid Preset", [], "", _access]
]];
private _duplicateState = [_duplicateEnvelope] call RACA_fnc_edenParseConfigurationEnvelope;
private _blockedReasons = (_duplicateState select 4) apply {_x select 2};
[
    (_duplicateState select 0) isEqualTo "RECOVERY" &&
    {"Duplicate configuration ID" in _blockedReasons} &&
    {"Duplicate configuration name" in _blockedReasons} &&
    {"Malformed record type" in _blockedReasons} &&
    {"Invalid standalone preset" in _blockedReasons},
    "Duplicate, malformed, and invalid configuration records are blocked without silent omission",
    str [_duplicateState select 0, _blockedReasons]
] call _record;

private _mixedEnvelope = ["RACA_EDEN_CONFIGURATIONS", 1, [
    _configurationRecord,
    ["", "Repair Me", _preset, "", _access],
    ["cfg_9", "", _preset, "", _access],
    ["cfg_10", "Too Many Fields", _preset, "", _access, "unexpected"]
]];
private _mixedState = [_mixedEnvelope] call RACA_fnc_edenParseConfigurationEnvelope;
private _mixedEntries = _mixedState select 4;
[
    (_mixedState select 0) isEqualTo "RECOVERY" &&
    {(count (_mixedState select 2)) isEqualTo 1} &&
    {((_mixedEntries select 1) select 1) isEqualTo "REPAIRABLE"} &&
    {((_mixedEntries select 2) select 2) isEqualTo "Missing configuration name"} &&
    {((_mixedEntries select 3) select 2) isEqualTo "Malformed record field count"} &&
    {(_mixedState select 3) isEqualTo _mixedEnvelope},
    "Mixed valid, repairable, and blocked records retain complete indexed recovery state",
    str [_mixedState select 0, _mixedState select 2, _mixedEntries]
] call _record;
[
    ([[_configurationRecord, ["cfg_2", "", _preset]]] call RACA_fnc_edenGenerateConfigurationId) isEqualTo "cfg_3",
    "Configuration ID generation is deterministic, collision-free, and display-name independent"
] call _record;
true
