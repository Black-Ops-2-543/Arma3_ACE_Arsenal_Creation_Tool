params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {};
private _revision = (uiNamespace getVariable ["RACA_filterRevision", 0]) + 1;
uiNamespace setVariable ["RACA_filterRevision", _revision];

[_display, _revision] spawn {
    params ["_display", "_revision"];
    uiSleep 0.12;
    if (!isNull _display && {uiNamespace getVariable ["RACA_filterRevision", 0] isEqualTo _revision}) then {
        [_display] call RACA_fnc_refreshItemList;
    };
};
