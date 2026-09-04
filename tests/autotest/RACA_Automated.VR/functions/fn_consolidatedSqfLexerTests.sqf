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
true
