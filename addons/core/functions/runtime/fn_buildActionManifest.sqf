/* Removes presets, limits, and other restricted content before JIP broadcast. */
params [["_config", [], [[]]]];
if (_config isEqualTo []) exitWith {[]};
private _slots = [];
{
    _x params ["_id", "_name", "", "_enabled", "_access", "", "_icon", "_hideDenied"];
    _slots pushBack [_id, _name, [], _enabled, _access, [], _icon, _hideDenied];
} forEach (_config select 2);
["RACA_ACTION_MANIFEST", 1, _slots]
