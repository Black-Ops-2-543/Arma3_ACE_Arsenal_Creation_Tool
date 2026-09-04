#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {};
private _classes = [_display] call RACA_fnc_resolveCreatorSelection;
if (_classes isEqualTo []) exitWith {[_display, "The selected rows have no class names."] call RACA_fnc_setStatus};
([_display] call RACA_fnc_readQuantityPolicy) params ["_validPolicy", "_limit", "_scope", "_reset", "_policyError"];
if (!_validPolicy) exitWith {[_display, _policyError] call RACA_fnc_setStatus};
private _limits = uiNamespace getVariable ["RACA_builderLimits", createHashMap];
_classes = _classes select {!((_limits getOrDefault [_x, []]) isEqualTo [_x, _limit, _scope, _reset])};
if (_classes isEqualTo []) exitWith {[_display, "These policies are already set."] call RACA_fnc_setStatus};
[_display] call RACA_fnc_pushCreatorHistory;
{
    _limits set [_x, [_x, _limit, _scope, _reset]];
} forEach _classes;
uiNamespace setVariable ["RACA_builderLimits", _limits];
[_display] call RACA_fnc_refreshItemList;
[_display, format ["%1 limit set to %2 for %3 selected class(es); reset: %4.", _scope, _limit, count _classes, _reset]] call RACA_fnc_setStatus;
