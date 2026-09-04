params [["_configuration",[],[[]]],["_catalog",[],[[]]]];
private _object=[_configuration] call RACA_fnc_edenConfigurationToObjectConfig;
if (_object isEqualTo []) exitWith {[false,[],[["ERROR","INVALID_CONFIGURATION","Configuration cannot be converted.","","",""]],[1,0,0]]};
[_object,_catalog] call RACA_fnc_preflightObjectConfig
