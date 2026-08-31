#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
private _list = _display displayCtrl RACA_IDC_ITEM_LIST;
private _rows = lbSelection _list;
private _row = lnbCurSelRow _list;
if (_row < 0 && {_rows isNotEqualTo []}) then {_row = _rows select 0};
if (_row < 0) exitWith {[_display, "Select one or more catalogue rows before changing favorites."] call RACA_fnc_setStatus; false};
if (_rows isEqualTo [] || {!(_row in _rows)}) then {_rows = [_row]};
private _className = _list lnbData [_row, 0];
if (_className isEqualTo "") exitWith {false};
private _classes = [];
{
    private _candidate = _list lnbData [_x, 0];
    if (_candidate isNotEqualTo "") then {_classes pushBackUnique _candidate};
} forEach _rows;
if (_classes isEqualTo []) exitWith {false};
private _favorites = uiNamespace getVariable ["RACA_catalogFavorites", createHashMap];
private _favorite = !(_favorites getOrDefault [_className, false]);
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
