#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};

uiNamespace setVariable ["RACA_creatorDirty", true];
private _revision = (uiNamespace getVariable ["RACA_draftRecoveryRevision", 0]) + 1;
uiNamespace setVariable ["RACA_draftRecoveryRevision", _revision];
[_display] call RACA_fnc_refreshHistoryButtons;

[_display, _revision] spawn {
    disableSerialization;
    params ["_display", "_revision"];
    uiSleep 0.75;
    if (isNull _display ||
        {!(uiNamespace getVariable ["RACA_creatorDirty", false])} ||
        {(uiNamespace getVariable ["RACA_draftRecoveryRevision", -1]) isNotEqualTo _revision}) exitWith {};
    [_display] call RACA_fnc_saveDraftRecovery;
};
true
