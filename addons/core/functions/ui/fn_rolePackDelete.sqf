#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
private _parent = _display getVariable ["RACA_rolePacksParentDisplay", displayNull];
private _list = _display displayCtrl RACA_IDC_ROLE_PACK_LIST;
private _row = lnbCurSelRow _list;
if (_row < 0) exitWith {false};
private _name = _list lnbData [_row, 0];

[_display, _parent, _name] spawn {
    disableSerialization;
    params ["_display", "_parent", "_name"];
    private _confirmed = [format ["Delete custom role pack '%1'?%2The current draft and every saved preset are unaffected.", _name, toString [10]], "RACA Role Packs", true, true, _display] call BIS_fnc_guiMessage;
    if (!_confirmed) exitWith {};
    private _packs = call RACA_fnc_getRolePacks;
    _packs = _packs select {toLowerANSI (_x select 2) isNotEqualTo toLowerANSI _name};
    profileNamespace setVariable ["RACA_rolePacks_v1", _packs];
    saveProfileNamespace;
    [_display] call RACA_fnc_rolePackRefresh;
    if (!isNull _parent) then {
        [_parent] call RACA_fnc_refreshRoleTemplateCombo;
        [_parent, format ["Deleted custom role pack '%1'; presets and the draft were unchanged.", _name]] call RACA_fnc_setStatus;
    };
};
true
