/* Returns recognized authoring-only adoption metadata, or an empty array. */
params [["_preset", [], [[]]]];

if ((count _preset) < 5) exitWith {[]};
private _composition = _preset param [4, [], [[]]];
if ((count _composition) < 6) exitWith {[]};
if !((_composition param [0, "", [""]]) in ["RACA_ADOPTION", "RACA_COMPOSITION"]) exitWith {[]};
if ((_composition param [1, -1, [0]]) isNotEqualTo 1) exitWith {[]};

_composition
