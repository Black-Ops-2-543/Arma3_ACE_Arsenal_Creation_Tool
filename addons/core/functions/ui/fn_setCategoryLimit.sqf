#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
private _categoryCtrl = _display displayCtrl RACA_IDC_CATEGORY;
private _category = _categoryCtrl lbData (lbCurSel _categoryCtrl);
private _valid = ["Weapons", "Attachments", "Magazines", "Uniforms", "Vests", "Backpacks", "Headgear", "NVGs", "Facewear", "Equipment"];
if !(_category in _valid) exitWith {[_display, "Choose one equipment category before setting its shared category limit."] call RACA_fnc_setStatus; false};
private _limit = floor parseNumber ctrlText (_display displayCtrl RACA_IDC_LIMIT_VALUE);
if (_limit < -1) exitWith {[_display, "Quantity must be -1 (unlimited), zero, or a positive number."] call RACA_fnc_setStatus; false};
private _scopeCtrl = _display displayCtrl RACA_IDC_LIMIT_SCOPE;
private _scope = _scopeCtrl lbData (lbCurSel _scopeCtrl);
private _resetCtrl = _display displayCtrl RACA_IDC_LIMIT_RESET;
private _reset = _resetCtrl lbData (lbCurSel _resetCtrl);
if !(_scope in ["interaction", "player", "life", "mission", "arsenal"]) then {_scope = "arsenal"};
if !(_reset in ["never", "interaction", "respawn", "round", "phase"]) then {_reset = "never"};
if (_scope isEqualTo "interaction") then {_reset = "interaction"};
[_display] call RACA_fnc_pushCreatorHistory;
private _limits = uiNamespace getVariable ["RACA_builderLimits", createHashMap];
private _key = format ["category:%1", _category];
_limits set [_key, [_key, _limit, _scope, _reset]];
uiNamespace setVariable ["RACA_builderLimits", _limits];
[_display] call RACA_fnc_refreshItemList;
[_display, format ["%1 limit for the complete %2 category set to %3; reset: %4.", _scope, _category, _limit, _reset]] call RACA_fnc_setStatus;
true
