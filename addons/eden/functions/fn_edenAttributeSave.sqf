#include "..\script_component.hpp"
params [["_group", controlNull, [controlNull]]];

if (isNull _group) exitWith {[]};
private _current = _group getVariable ["RACA_edenObjectConfig", []];
private _combo = _group controlsGroupCtrl RACA_EDEN_IDC_PRESET;
private _selection = lbCurSel _combo;
private _configurationId = if (_selection < 0) then {""} else {_combo lbData _selection};
if (_configurationId isEqualTo "") exitWith {[]};
if (_configurationId isEqualTo "__PRESERVE__") exitWith {+_current};
private _configurations = call RACA_fnc_edenGetConfigurations;
private _match = _configurations findIf {toLowerANSI (_x select 0) isEqualTo toLowerANSI _configurationId};
if (_match < 0) exitWith {+_current};
private _configuration = _configurations select _match;
([_configuration, uiNamespace getVariable ["RACA_itemCatalog", []]] call RACA_fnc_validateConfigurationForAssignment) params ["_canApply", "_normalized", "_entries", "_summary"];
if (!_canApply) exitWith {
    (_group controlsGroupCtrl RACA_EDEN_IDC_SUMMARY) ctrlSetText format ["Assignment blocked by %1 preflight error(s). Open the RACA Mission Arsenal Tool and copy its report for details.", _summary select 0];
    +_current
};
_normalized
