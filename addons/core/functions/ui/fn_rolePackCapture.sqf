#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
private _parent = _display getVariable ["RACA_rolePacksParentDisplay", displayNull];
if (isNull _parent) exitWith {false};

private _name = ctrlText (_display displayCtrl RACA_IDC_ROLE_PACK_NAME);
if ((_name splitString (toString [9, 10, 13, 32])) isEqualTo []) exitWith {
    (_display displayCtrl RACA_IDC_ROLE_PACK_DETAILS) ctrlSetText "Enter a role-pack name before capturing the current draft.";
    false
};
if ((count _name) > 64) exitWith {
    (_display displayCtrl RACA_IDC_ROLE_PACK_DETAILS) ctrlSetText "Role-pack names are limited to 64 characters.";
    false
};
private _description = ctrlText (_display displayCtrl RACA_IDC_ROLE_PACK_DESCRIPTION);
if ((count _description) > 180) exitWith {
    (_display displayCtrl RACA_IDC_ROLE_PACK_DETAILS) ctrlSetText "Role-pack descriptions are limited to 180 characters.";
    false
};
private _classes = keys (uiNamespace getVariable ["RACA_builderSelected", createHashMap]);
_classes sort true;
if (_classes isEqualTo []) exitWith {
    (_display displayCtrl RACA_IDC_ROLE_PACK_DETAILS) ctrlSetText "Include at least one class in the creator draft before capturing a role pack.";
    false
};
if ((count _classes) > 5000) exitWith {
    (_display displayCtrl RACA_IDC_ROLE_PACK_DETAILS) ctrlSetText "Role packs are limited to 5,000 explicit classes. Narrow the draft before capturing it.";
    false
};

private _packs = call RACA_fnc_getRolePacks;
private _record = ["RACA_ROLE_PACK", 1, _name, _description, _classes];
private _existing = _packs findIf {toLowerANSI (_x select 2) isEqualTo toLowerANSI _name};
[_display, _parent, _packs, _record, _existing] spawn {
    disableSerialization;
    params ["_display", "_parent", "_packs", "_record", "_existing"];
    private _canSave = true;
    if (_existing >= 0) then {
        private _confirmed = [format ["Replace custom role pack '%1'?", _record select 2], "RACA Role Packs", true, true, _display] call BIS_fnc_guiMessage;
        if (_confirmed) then {_packs set [_existing, _record]} else {_canSave = false};
    } else {
        if ((count _packs) >= 50) then {
            (_display displayCtrl RACA_IDC_ROLE_PACK_DETAILS) ctrlSetText "The 50-pack limit has been reached. Delete an older custom role pack first.";
            _canSave = false;
        } else {
            _packs pushBack _record;
        };
    };
    if (!_canSave) exitWith {};
    profileNamespace setVariable ["RACA_rolePacks_v1", _packs];
    saveProfileNamespace;
    [_display] call RACA_fnc_rolePackRefresh;
    private _return = _display getVariable ["RACA_rolePacksReturnDisplay", displayNull];
    if (!isNull _return) then {
        [_return] call RACA_fnc_refreshQuickRoleCombo;
        (_return displayCtrl RACA_IDC_QUICK_HELP) ctrlSetText format ["Saved custom role pack '%1'. It is now available under Optional Settings.", _record select 2];
    };
    [_parent, format ["Captured custom role pack '%1' with %2 class(es).", _record select 2, count (_record select 4)]] call RACA_fnc_setStatus;
};
true
