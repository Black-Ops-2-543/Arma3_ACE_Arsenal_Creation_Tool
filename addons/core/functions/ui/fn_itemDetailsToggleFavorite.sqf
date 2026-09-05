#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
private _parent = _display getVariable ["RACA_itemDetailsParentDisplay", displayNull];
private _className = _display getVariable ["RACA_itemDetailsClassName", ""];
if (isNull _parent || {_className isEqualTo ""}) exitWith {false};

private _favorites = uiNamespace getVariable ["RACA_catalogFavorites", createHashMap];
private _favorite = !(_favorites getOrDefault [_className, false]);
if (_favorite) then {_favorites set [_className, true]} else {_favorites deleteAt _className};
uiNamespace setVariable ["RACA_catalogFavorites", _favorites];
uiNamespace setVariable ["RACA_favoritesRevision",(uiNamespace getVariable ["RACA_favoritesRevision",0])+1];
private _stored = keys _favorites;
_stored sort true;
profileNamespace setVariable ["RACA_favoriteClasses_v1", _stored];
saveProfileNamespace;
[_parent] call RACA_fnc_refreshItemList;
[_display] call RACA_fnc_itemDetailsRefresh;
[_parent, format ["%1 '%2' %3 favorites.", ["Removed", "Added"] select _favorite, _className, ["from", "to"] select _favorite]] call RACA_fnc_setStatus;
true
