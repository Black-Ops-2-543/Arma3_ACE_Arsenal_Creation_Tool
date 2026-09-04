#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
private _classes = [_display] call RACA_fnc_resolveCreatorSelection;
if (_classes isEqualTo []) exitWith {false};
private _favorites = uiNamespace getVariable ["RACA_catalogFavorites", createHashMap];
private _favorite = (_classes findIf {!(_favorites getOrDefault [_x, false])}) >= 0;
_classes = _classes select {(_favorites getOrDefault [_x, false]) isNotEqualTo _favorite};
{
    if (_favorite) then {_favorites set [_x, true]} else {_favorites deleteAt _x};
} forEach _classes;
uiNamespace setVariable ["RACA_catalogFavorites", _favorites];
private _stored = keys _favorites;
_stored sort true;
profileNamespace setVariable ["RACA_favoriteClasses_v1", _stored];
saveProfileNamespace;
[_display] call RACA_fnc_refreshItemList;
[_display, format ["%1 %2 selected class(es) %3 favorites.", ["Removed", "Added"] select _favorite, count _classes, ["from", "to"] select _favorite]] call RACA_fnc_setStatus;
true
