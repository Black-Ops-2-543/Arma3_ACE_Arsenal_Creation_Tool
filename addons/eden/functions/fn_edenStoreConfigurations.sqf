#include "..\script_component.hpp"
/* Persists configuration definitions and refreshes every linked object snapshot. */
params [
    ["_display", displayNull, [displayNull]],
    ["_candidate", [], [[]]],
    ["_historyName", "Update Arsenal Configurations", [""]]
];
if (!is3DEN) exitWith {false};
if (((call RACA_fnc_edenGetConfigurationState) select 0) isNotEqualTo "READY") exitWith {false};

private _normalized = [];
private _seenIds = createHashMap;
private _seenNames = createHashMap;
private _validationFailed = false;
{
    private _objectConfig = [_x] call RACA_fnc_edenConfigurationToObjectConfig;
    ([_x, uiNamespace getVariable ["RACA_itemCatalog", []]] call RACA_fnc_validateConfigurationForAssignment) params ["_canApply"];
    if (_objectConfig isNotEqualTo [] && {_canApply}) then {
        private _slot = (_objectConfig select 2) select 0;
        private _id = _slot select 0;
        private _nameKey = toLowerANSI (_slot select 1);
        if !(_seenIds getOrDefault [toLowerANSI _id, false] || {_seenNames getOrDefault [_nameKey, false]}) then {
            _seenIds set [toLowerANSI _id, true];
            _seenNames set [_nameKey, true];
            _normalized pushBack [
                _id,
                _slot select 1,
                _slot select 2,
                _slot select 6,
                _slot select 4
            ];
        } else {_validationFailed = true};
    } else {_validationFailed = true};
} forEach _candidate;
if (_validationFailed || {(count _normalized) isNotEqualTo (count _candidate)}) exitWith {false};

private _old = call RACA_fnc_edenGetConfigurations;
private _newIds = _normalized apply {toLowerANSI (_x select 0)};
private _removedIds = (_old apply {toLowerANSI (_x select 0)}) select {!(_x in _newIds)};
private _storedValue = if (_normalized isEqualTo []) then {[]} else {["RACA_EDEN_CONFIGURATIONS", 1, _normalized]};
private _objects = all3DENEntities select 0;
private _updated = 0;
private _cleared = 0;

[
    _historyName,
    "RACA Arsenal Configuration change",
    "a3\3den\data\cfg3den\history\changeattributes_ca.paa"
] collect3DENHistory {
    "RACA_RestrictedArsenals" set3DENMissionAttribute ["RACA_ArsenalConfigurations", _storedValue];
    {
        private _object = _x;
        private _raw = (_object get3DENAttribute "RACA_RestrictedArsenalPreset") param [0, []];
        private _options = _raw param [3, [], [[]]];
        private _linkedId = "";
        {
            if (_x isEqualType [] && {(count _x) >= 2} && {toLowerANSI (_x param [0, "", [""]]) isEqualTo "configurationid"}) exitWith {
                _linkedId = toLowerANSI (_x param [1, "", [""]]);
            };
        } forEach _options;
        if (_linkedId isNotEqualTo "") then {
            private _match = _normalized findIf {toLowerANSI (_x select 0) isEqualTo _linkedId};
            if (_match >= 0) then {
                _object set3DENAttribute ["RACA_RestrictedArsenalPreset", [_normalized select _match] call RACA_fnc_edenConfigurationToObjectConfig];
                _updated = _updated + 1;
            } else {
                if (_linkedId in _removedIds) then {
                    _object set3DENAttribute ["RACA_RestrictedArsenalPreset", []];
                    _cleared = _cleared + 1;
                };
            };
        };
    } forEach _objects;
};

if (!isNull _display) then {
    _display setVariable ["RACA_workingConfigurations", +_normalized];
    _display setVariable ["RACA_configurationsDirty", false];
    [_display] call RACA_fnc_edenDashboardRefresh;
};
true
