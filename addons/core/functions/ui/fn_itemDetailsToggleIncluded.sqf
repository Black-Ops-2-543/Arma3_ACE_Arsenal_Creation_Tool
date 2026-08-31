#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
private _parent = _display getVariable ["RACA_itemDetailsParentDisplay", displayNull];
private _className = _display getVariable ["RACA_itemDetailsClassName", ""];
if (isNull _parent || {_className isEqualTo ""}) exitWith {false};

private _selected = uiNamespace getVariable ["RACA_builderSelected", createHashMap];
private _include = !(_selected getOrDefault [_className, false]);
[_parent] call RACA_fnc_pushCreatorHistory;
if (_include) then {_selected set [_className, true]} else {_selected deleteAt _className};
uiNamespace setVariable ["RACA_builderSelected", _selected];
[_parent] call RACA_fnc_refreshItemList;
[_display] call RACA_fnc_itemDetailsRefresh;
[_parent, format ["%1 '%2' from item details.", ["Excluded", "Included"] select _include, _className]] call RACA_fnc_setStatus;
true
