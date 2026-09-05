#include "..\..\script_component.hpp"
disableSerialization;
params [["_display",displayNull,[displayNull]],["_target","TAGS",[""]]];
if (isNull _display) exitWith {};
private _request = (_display getVariable ["RACA_tagSearchRequest",0]) + 1;
_display setVariable ["RACA_tagSearchRequest",_request];
[_display,_target,_request] spawn {
    disableSerialization;
    params ["_display","_target","_request"];
    uiSleep 0.15;
    if (isNull _display || {(_display getVariable ["RACA_tagSearchRequest",-1]) isNotEqualTo _request}) exitWith {};
    if (_target isEqualTo "MEMBERS") then {
        _display setVariable ["RACA_memberPage",0];
        [_display] call RACA_fnc_catalogTagMembersRefresh;
    } else {
        _display setVariable ["RACA_tagPage",0];
        [_display] call RACA_fnc_catalogTagsRefresh;
    };
};
