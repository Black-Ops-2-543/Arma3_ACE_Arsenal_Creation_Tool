params ["_record"];
private _quote = toString [34];
private _slash = toString [47];
private _star = toString [42];
private _commentedSqf = "private _items = [" + _quote + "arifle_MX_F" + _quote + ", " +
    _slash + _star + " " + _quote + "hgun_P07_F" + _quote + " " + _star + _slash +
    " " + _quote + "30Rnd_65x39_caseless_mag" + _quote + "]; " + _slash + _slash +
    " " + _quote + "FirstAidKit" + _quote;
([_commentedSqf, "Comment Lexer"] call RACA_fnc_decodeSqfPreset) params ["_commentedPreset"];
private _commentedClasses = [_commentedPreset] call RACA_fnc_flattenPresetClasses;
[
    "arifle_MX_F" in _commentedClasses &&
    {"30Rnd_65x39_caseless_mag" in _commentedClasses} &&
    {!("hgun_P07_F" in _commentedClasses)} &&
    {!("FirstAidKit" in _commentedClasses)},
    "SQF lexer excludes quoted classes inside line and block comments"
] call _record;
private _quotedMarkers = "private _items = [" + _quote + "not" + _slash + _slash + "a" +
    _slash + _star + "class" + _star + _slash + _quote + ", " + _quote + "ignored" +
    _quote + _quote + "quote" + _quote + ", " + _quote + "FirstAidKit" + _quote + "];";
([_quotedMarkers, "Quote Lexer"] call RACA_fnc_decodeSqfPreset) params ["_quotedMarkerPreset"];
[
    ([_quotedMarkerPreset] call RACA_fnc_flattenPresetClasses) isEqualTo ["FirstAidKit"],
    "SQF lexer treats comment markers and doubled quotes inside strings as string data"
] call _record;
private _malformedBlockText = "[" + _quote + "arifle_MX_F" + _quote + "] " + _slash + _star + " unfinished";
private _malformedStringText = "[" + _quote + "arifle_MX_F]";
private _malformedBlock = [_malformedBlockText, "Malformed Block"] call RACA_fnc_decodeSqfPreset;
private _malformedString = [_malformedStringText, "Malformed String"] call RACA_fnc_decodeSqfPreset;
[
    (_malformedBlock select 0) isEqualTo [] && {(_malformedString select 0) isEqualTo []},
    "SQF lexer rejects unterminated comments and strings atomically"
] call _record;

private _generatedRaw = ["RACA_PRESET", 1, "Fast Path Fixture", [["arifle_MX_F"], ["30Rnd_65x39_caseless_mag"], [], []]];
private _generatedText = [_generatedRaw] call RACA_fnc_formatSqfExport;
private _generatedDecode = [_generatedText, "Fast Path Import"] call RACA_fnc_decodeSqfPreset;
private _generatedWarnings = _generatedDecode select 2;
[
    (_generatedDecode select 0) isNotEqualTo [] &&
    {((_generatedWarnings findIf {(_x find "Recognized RACA reusable SQF format 2") isEqualTo 0}) >= 0)} &&
    {((_generatedWarnings findIf {(_x find "raca_arsenal.sqf") >= 0}) < 0)},
    "Versioned RACA SQF uses the strict literal-array fast path"
] call _record;

private _brokenGenerated = _generatedText regexReplace ["private _arsenalItems = \\[", "private _arsenalItems = call {"];
private _brokenDecode = [_brokenGenerated, "Broken Fast Path"] call RACA_fnc_decodeSqfPreset;
[
    (_brokenDecode select 0) isEqualTo [] &&
    {(((_brokenDecode select 2) param [0, ""]) find "structural envelope") >= 0},
    "A marked but modified generated SQF envelope fails without generic guessing"
] call _record;
true
