#include "..\..\script_component.hpp"
disableSerialization;
params [["_members", controlNull, [controlNull]]];
if (isNull _members) exitWith {false};
private _display = ctrlParent _members;
if (isNull _display) exitWith {false};
if (_display getVariable ["RACA_renderingTagMembers",false]) exitWith {true};
private _highlighted=_display getVariable ["RACA_tagMemberHighlights",createHashMap];
private _selected=createHashMapFromArray ((lbSelection _members) apply {[_members lnbData [_x,0],true]});
for "_row" from 0 to ((lnbSize _members select 0)-1) do {
    private _class=_members lnbData [_row,0];
    if (_selected getOrDefault [_class,false]) then {_highlighted set [_class,true]} else {_highlighted deleteAt _class};
};
_display setVariable ["RACA_tagMemberHighlights",_highlighted];
(_display displayCtrl RACA_IDC_CATALOG_TAG_REMOVE) ctrlEnable ((count _highlighted)>0);
true
