#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {};

_display setVariable ["RACA_itemDetailsParentDisplay", uiNamespace getVariable ["RACA_itemDetailsParent", displayNull]];
_display setVariable ["RACA_itemDetailsClassName", uiNamespace getVariable ["RACA_itemDetailsClass", ""]];
private _parent = _display getVariable ["RACA_itemDetailsParentDisplay", displayNull];
if (!isNull _parent) then {_parent setVariable ["RACA_itemDetailsOpening", false]};
[_display] call RACA_fnc_itemDetailsRefresh;
