params [["_display", displayNull, [displayNull]], ["_delta", 0, [0]]];
if (isNull _display) exitWith {};
private _pages = ceil ((count (uiNamespace getVariable ["RACA_visibleClasses", []])) / 200);
_display setVariable ["RACA_page", (((_display getVariable ["RACA_page",0]) + _delta) max 0) min ((_pages-1) max 0)];
[_display] call RACA_fnc_refreshItemList;
