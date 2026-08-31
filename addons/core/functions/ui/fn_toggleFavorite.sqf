#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
private _list = _display displayCtrl RACA_IDC_ITEM_LIST;
private _row = lnbCurSelRow _list;
if (_row < 0) exitWith {[_display, "Select one catalogue row before changing its favorite state."] call RACA_fnc_setStatus; false};
private _className = _list lnbData [_row, 0];
if (_className isEqualTo "") exitWith {false};
private _favorites = uiNamespace getVariable ["RACA_catalogFavorites", createHashMap];
private _favorite = !(_favorites getOrDefault [_className, false]);
if (_favorite) then {_favorites set [_className, true]} else {_favorites deleteAt _className};
uiNamespace setVariable ["RACA_catalogFavorites", _favorites];
private _stored = keys _favorites;
_stored sort true;
profileNamespace setVariable ["RACA_favoriteClasses_v1", _stored];
saveProfileNamespace;
[_display] call RACA_fnc_refreshItemList;
[_display, format ["%1 '%2' %3 favorites.", ["Removed", "Added"] select _favorite, _className, ["from", "to"] select _favorite]] call RACA_fnc_setStatus;
true
