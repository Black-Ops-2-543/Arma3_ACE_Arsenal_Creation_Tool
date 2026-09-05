#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
private _categoryCtrl = _display displayCtrl RACA_IDC_CATEGORY;
private _category = _categoryCtrl lbData (lbCurSel _categoryCtrl);
private _valid = ["Weapons", "Attachments", "Magazines", "Uniforms", "Vests", "Backpacks", "Headgear", "NVGs", "Facewear", "Equipment"];
if !(_category in _valid) exitWith {[_display, "Choose one equipment category before setting its shared category limit."] call RACA_fnc_setStatus; false};
([_display] call RACA_fnc_readQuantityPolicy) params ["_validPolicy", "_limit", "_scope", "_reset", "_policyError"];
if (!_validPolicy) exitWith {[_display, _policyError] call RACA_fnc_setStatus; false};
[_display] call RACA_fnc_pushCreatorHistory;
private _limits = uiNamespace getVariable ["RACA_builderLimits", createHashMap];
private _key = format ["category:%1", _category];
_limits set [_key, [_key, _limit, _scope, _reset]];
uiNamespace setVariable ["RACA_builderLimits", _limits];
uiNamespace setVariable ["RACA_limitsRevision",(uiNamespace getVariable ["RACA_limitsRevision",0])+1];
[_display] call RACA_fnc_refreshItemList;
[_display, format ["%1 limit for the complete %2 category set to %3; reset: %4.", _scope, _category, _limit, _reset]] call RACA_fnc_setStatus;
true
