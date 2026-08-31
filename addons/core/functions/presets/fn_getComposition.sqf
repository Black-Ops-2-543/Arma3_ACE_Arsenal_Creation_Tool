/* Returns recognized authoring-only adoption metadata, or an empty array. */
params [["_preset", [], [[]]]];

if ((count _preset) < 5) exitWith {[]};
private _composition = [];
for "_index" from 4 to ((count _preset) - 1) do {
    private _candidate = _preset param [_index, [], [[]]];
    if ((count _candidate) >= 6 &&
        {(_candidate param [0, "", [""]]) in ["RACA_ADOPTION", "RACA_COMPOSITION"]} &&
        {(_candidate param [1, -1, [0]]) isEqualTo 1}) exitWith {
        _composition = _candidate;
    };
};

_composition
