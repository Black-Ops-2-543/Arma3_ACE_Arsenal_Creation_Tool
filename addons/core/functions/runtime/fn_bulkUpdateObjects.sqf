params [
    ["_objects", [], [[]]],
    ["_operation", "assign", [""]],
    ["_payload", [], [[]]],
    ["_confirm", false, [true]]
];
if (!isServer) exitWith {false};
if (!_confirm) exitWith {false};

private _changed = 0;
{
    private _object = _x;
    if (!isNull _object) then {
        private _current = [_object getVariable ["RACA_objectConfig", []]] call RACA_fnc_normalizeObjectConfig;
        private _next = +_current;
        switch (toLowerANSI _operation) do {
            case "clear": {
                [_object, true] call ace_arsenal_fnc_removeBox;
                _object setVariable ["RACA_objectConfig", nil, true];
                [_object, []] remoteExecCall ["RACA_fnc_registerActions", 0, format ["RACA_actions_%1", netId _object]];
                _changed = _changed + 1;
            };
            case "assign": {
                if ([_object, _payload] call RACA_fnc_applyObjectConfig) then {_changed = _changed + 1};
            };
            case "replace": {
                if (_current isNotEqualTo []) then {
                    private _replacement = [_payload] call RACA_fnc_normalizeObjectConfig;
                    if (_replacement isNotEqualTo []) then {
                        private _accessById = createHashMap;
                        { _accessById set [_x select 0, [_x select 4, _x select 7]] } forEach (_current select 2);
                        {
                            private _savedAccess = _accessById getOrDefault [_x select 0, []];
                            if (_savedAccess isNotEqualTo []) then {_x set [4, _savedAccess select 0]; _x set [7, _savedAccess select 1]};
                        } forEach (_replacement select 2);
                        if ([_object, _replacement] call RACA_fnc_applyObjectConfig) then {_changed = _changed + 1};
                    };
                };
            };
            case "enable";
            case "disable": {
                if (_current isNotEqualTo []) then {
                    private _enabled = toLowerANSI _operation isEqualTo "enable";
                    { _x set [3, _enabled] } forEach (_current select 2);
                    if ([_object, _current] call RACA_fnc_applyObjectConfig) then {_changed = _changed + 1};
                };
            };
        };
    };
} forEach _objects;
_changed
