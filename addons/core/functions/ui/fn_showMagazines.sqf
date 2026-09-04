#include "..\..\script_component.hpp"
params [["_display",displayNull,[displayNull]]];
if (isNull _display) exitWith {};
private _parent=_display getVariable ["RACA_itemDetailsParentDisplay",displayNull];
if (isNull _parent) then {_parent=uiNamespace getVariable ["RACA_itemDetailsParent",displayNull]};
if (isNull _parent) exitWith {};
private _class=_display getVariable ["RACA_itemDetailsClassName",""];
private _mags=[_class] call RACA_fnc_getCompatibleMagazines;
if (_mags isEqualTo []) exitWith {};
private _prior=[_parent] call RACA_fnc_captureCatalogView;
private _label=getText (configFile >> "CfgWeapons" >> _class >> "displayName");
uiNamespace setVariable ["RACA_magazineFilterContext",[_class,_label,_mags,_prior]];
(_parent displayCtrl RACA_IDC_CLEAR_MAGAZINES) ctrlSetTooltip format ["Magazines for %1 (%2). Clear to restore the previous catalogue view.",_label,_class];
_display closeDisplay 1;
[_parent,"ASSIGNMENT"] call RACA_fnc_switchCreatorTab;
[_parent] call RACA_fnc_refreshItemList;
