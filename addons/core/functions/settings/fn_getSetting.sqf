/* Typed access to the complete settings contract. Never read CBA globals directly. */
params [["_name", "", [""]]];
private _contract = switch (_name) do {
    case "RACA_catalogPageSize": {[200, "LIST", [50, 100, 200, 400]]};
    case "RACA_defaultSearchMode": {["BASIC", "LIST", ["BASIC", "ADVANCED"]]};
    case "RACA_defaultCompatibilitySeverity": {["ERRORS", "LIST", ["ERRORS", "WARNINGS", "ALL"]]};
    case "RACA_openItemDetailsOnSelection": {[false, "BOOL", []]};
    case "RACA_draftRecoveryEnabled": {[true, "BOOL", []]};
    case "RACA_showOnboardingGuidance": {[true, "BOOL", []]};
    case "RACA_statusVerbosity": {["STANDARD", "LIST", ["CONCISE", "STANDARD", "DETAILED"]]};
    case "RACA_enableZeusModules": {[true, "BOOL", []]};
    case "RACA_allowZeusProfilePresetFallback": {[false, "BOOL", []]};
    default {[]};
};
if (_contract isEqualTo []) exitWith {nil};
_contract params ["_default", "_type", "_allowed"];
private _value = missionNamespace getVariable [_name, _default];
if (_type isEqualTo "BOOL") exitWith {if (_value isEqualType true) then {_value} else {_default}};
if !(_value isEqualType _default) exitWith {_default};
if !(_value in _allowed) exitWith {_default};
_value
