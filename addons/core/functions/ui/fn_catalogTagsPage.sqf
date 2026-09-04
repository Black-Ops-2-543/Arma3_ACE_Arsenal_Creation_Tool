#include "..\..\script_component.hpp"
disableSerialization;
params [["_display",displayNull,[displayNull]],["_kind","TAG",[""]],["_delta",0,[0]]];
if (isNull _display) exitWith {false};
private _key=["RACA_tagPage","RACA_memberPage"] select (toUpperANSI _kind isEqualTo "MEMBER");
_display setVariable [_key,((_display getVariable [_key,0])+_delta) max 0];
if (toUpperANSI _kind isEqualTo "MEMBER") then {
    [_display] call RACA_fnc_catalogTagMembersRefresh
} else {
    [_display] call RACA_fnc_catalogTagsRefresh
};
true
