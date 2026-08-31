/* Runtime policy: [tag, version, limits, notes, revision, author, modifiedAtUTC, requirements]. */
params [['_preset', [], [[]]]];

private _policy = ["RACA_RUNTIME", 1, [], "", 0, "", [], []];
if ((count _preset) <= 4) exitWith {_policy};

for "_index" from 4 to ((count _preset) - 1) do {
    private _candidate = _preset param [_index, [], [[]]];
    if ((count _candidate) >= 2 && {(_candidate param [0, "", [""]]) isEqualTo "RACA_RUNTIME"}) exitWith {
        if ((_candidate param [1, -1, [0]]) isEqualTo 1) then {
            _policy = [
                "RACA_RUNTIME",
                1,
                [_candidate param [2, [], [[]]]] call RACA_fnc_normalizeLimits,
                _candidate param [3, "", [""]],
                (_candidate param [4, 0, [0]]) max 0,
                _candidate param [5, "", [""]],
                _candidate param [6, [], [[]]],
                _candidate param [7, [], [[]]]
            ];
        };
    };
};

_policy
