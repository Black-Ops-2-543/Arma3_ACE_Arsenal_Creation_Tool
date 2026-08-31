params [
    ["_object", objNull, [objNull]],
    ["_config", [], [[]]]
];
if (isNull _object) exitWith {false};
if (isRemoteExecuted && {remoteExecutedOwner isNotEqualTo 2}) exitWith {false};
[_object, 0, ["ACE_MainActions", "RACA_Root"]] call ace_interact_menu_fnc_removeActionFromObject;
if (_config isEqualTo []) exitWith {true};
private _root = [
    "RACA_Root",
    "Restricted Arsenals",
    "\A3\ui_f\data\igui\cfg\simpleTasks\types\rearm_ca.paa",
    {},
    {true}
] call ace_interact_menu_fnc_createAction;
[_object, 0, ["ACE_MainActions"], _root] call ace_interact_menu_fnc_addActionToObject;

{
    _x params ["_slotId", "_slotName", "", "_enabled", "_access", "", "_icon", "_hideWhenDenied"];
    if (_enabled) then {
        private _actionId = format ["RACA_Slot_%1", _slotId];
        private _action = [
            _actionId,
            _slotName,
            _icon,
            {
                params ["_target", "_player", "_args"];
                _args params ["_slotId"];
                [_target, _player, _slotId] remoteExecCall ["RACA_fnc_requestOpen", 2];
            },
            {
                params ["", "_player", "_args"];
                _args params ["", "_access", "_hideWhenDenied"];
                if (!_hideWhenDenied) exitWith {true};
                ([_player, _access] call RACA_fnc_evaluateAccess) select 0
            },
            {},
            [_slotId, _access, _hideWhenDenied]
        ] call ace_interact_menu_fnc_createAction;
        [_object, 0, ["ACE_MainActions", "RACA_Root"], _action] call ace_interact_menu_fnc_addActionToObject;

        private _saveAction = [
            format ["RACA_SaveLoadout_%1", _slotId],
            format ["Save loadout for %1", _slotName],
            "",
            {params ["_target", "_player", "_args"]; [_player, _target, _args select 0, "Last saved", "personal"] call RACA_fnc_savePlayerLoadout},
            {true},
            {},
            [_slotId]
        ] call ace_interact_menu_fnc_createAction;
        [_object, 0, ["ACE_MainActions", "RACA_Root", _actionId], _saveAction] call ace_interact_menu_fnc_addActionToObject;

        private _applyAction = [
            format ["RACA_ApplyLoadout_%1", _slotId],
            format ["Apply saved loadout for %1", _slotName],
            "",
            {params ["_target", "_player", "_args"]; [_player, _target, _args select 0, "Last saved", "personal"] call RACA_fnc_applyPlayerLoadout},
            {true},
            {},
            [_slotId]
        ] call ace_interact_menu_fnc_createAction;
        [_object, 0, ["ACE_MainActions", "RACA_Root", _actionId], _applyAction] call ace_interact_menu_fnc_addActionToObject;

        private _quotaAction = [
            format ["RACA_Quota_%1", _slotId],
            format ["Check remaining allowance for %1", _slotName],
            "",
            {params ["_target", "_player", "_args"]; [_target, _player, _args select 0] remoteExecCall ["RACA_fnc_requestQuotaStatus", 2]},
            {true},
            {},
            [_slotId]
        ] call ace_interact_menu_fnc_createAction;
        [_object, 0, ["ACE_MainActions", "RACA_Root", _actionId], _quotaAction] call ace_interact_menu_fnc_addActionToObject;
    };
} forEach (_config select 2);

true
