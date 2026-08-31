#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
private _rehearsal = _display createDisplay "RACA_RscDisplayRehearsal";
if (isNull _rehearsal) exitWith {
    (_display displayCtrl RACA_IDC_ADMIN_STATUS) ctrlSetText "The multiplayer rehearsal display could not be opened.";
    false
};
true
