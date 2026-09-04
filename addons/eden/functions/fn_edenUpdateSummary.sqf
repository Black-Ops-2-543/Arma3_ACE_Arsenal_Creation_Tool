#include "..\script_component.hpp"
params [["_group", controlNull, [controlNull]]];
if (isNull _group) exitWith {};
private _summary = _group controlsGroupCtrl RACA_EDEN_IDC_SUMMARY;
_summary ctrlSetText "Additional Arsenal Configurations can be created in the Eden RACA tool accessible in the toolbar.";
