#include "..\script_component.hpp"
disableSerialization;
params [["_group", controlNull, [controlNull]]];
if (!is3DEN) exitWith {false};
private _existing = findDisplay RACA_EDEN_IDD_CONFIG;
if (!isNull _existing) exitWith {
    ctrlSetFocus (_existing displayCtrl RACA_EDEN_IDC_TAB_DASHBOARD);
    true
};
private _parent = uiNamespace getVariable ["BIS_fnc_3DENInterface_display", displayNull];
if (isNull _parent) then {_parent = findDisplay 313};
if (isNull _parent && {!isNull _group}) then {_parent = ctrlParent _group};
if (isNull _parent) exitWith {false};
!isNull (_parent createDisplay "RACA_RscDisplayEdenConfig")
