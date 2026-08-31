#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {};
(_display displayCtrl RACA_IDC_UNDO) ctrlEnable ((count (uiNamespace getVariable ["RACA_creatorUndo", []])) > 0);
(_display displayCtrl RACA_IDC_REDO) ctrlEnable ((count (uiNamespace getVariable ["RACA_creatorRedo", []])) > 0);
private _combo = _display displayCtrl RACA_IDC_PRESET_LIST;
private _selection = lbCurSel _combo;
private _library = uiNamespace getVariable ["RACA_builderLibrary", []];
private _name = if (_selection > 0) then {(_library param [_selection - 1, []]) param [2, ""]} else {""};
(_display displayCtrl RACA_IDC_COMPARE_DRAFT) ctrlEnable (_name isNotEqualTo "");
(_display displayCtrl RACA_IDC_HISTORY) ctrlEnable (_name isNotEqualTo "" && {(count ([_name] call RACA_fnc_getPresetHistory)) > 0});
