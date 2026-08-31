params [["_group", controlNull, [controlNull]]];
if (isNull _group) exitWith {false};
uiNamespace setVariable ["RACA_edenEditorTarget", _group];
private _parent = ctrlParent _group;
if (isNull _parent) exitWith {false};
!isNull (_parent createDisplay "RACA_RscDisplayEdenConfig")
