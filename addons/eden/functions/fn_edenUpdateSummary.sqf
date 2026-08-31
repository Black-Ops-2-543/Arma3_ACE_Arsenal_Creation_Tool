#include "..\script_component.hpp"
params [["_group", controlNull, [controlNull]]];
if (isNull _group) exitWith {};
private _summary = _group controlsGroupCtrl RACA_EDEN_IDC_SUMMARY;
private _config = [_group getVariable ["RACA_edenObjectConfig", []]] call RACA_fnc_normalizeObjectConfig;
if (_config isEqualTo []) exitWith {_summary ctrlSetText "No restricted arsenal slots configured. Choose Configure slots to add one or more ACE interactions."};
private _slots = _config select 2;
private _lines = [format ["%1 slot(s) configured:", count _slots]];
{
    _x params ["", "_name", "_preset", "_enabled", "_access", "_limits", "", "_hide"];
    private _conditionCount = count (_access param [3, []]);
    _lines pushBack format [
        "%1  %2 — %3 | %4 access rule(s), %5 limit(s)%6",
        ["OFF", "ON"] select _enabled,
        _name,
        _preset select 2,
        _conditionCount,
        count _limits,
        ["", ", hidden when denied"] select _hide
    ];
} forEach _slots;
_summary ctrlSetText (_lines joinString (toString [10]));
