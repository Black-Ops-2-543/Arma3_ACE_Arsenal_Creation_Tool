#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {};
uiNamespace setVariable ["RACA_catalogTagsDisplay", _display];
_display setVariable ["RACA_catalogTagsParentDisplay", uiNamespace getVariable ["RACA_catalogTagsParent", displayNull]];
_display setVariable ["RACA_catalogTagsSelectedClasses", uiNamespace getVariable ["RACA_catalogTagsSelection", []]];
[_display] call RACA_fnc_catalogTagsRefresh;
(_display displayCtrl RACA_IDC_CATALOG_TAG_UNDO) ctrlEnable ((profileNamespace getVariable ["RACA_catalogTagHistory_v1", []]) isNotEqualTo []);
(_display displayCtrl RACA_IDC_CATALOG_TAG_REDO) ctrlEnable ((profileNamespace getVariable ["RACA_catalogTagRedo_v2", []]) isNotEqualTo []);
