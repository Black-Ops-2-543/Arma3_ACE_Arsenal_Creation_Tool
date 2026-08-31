#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
private _combo = _display displayCtrl RACA_IDC_ROLE_TEMPLATE;
private _templateId = _combo lbData (lbCurSel _combo);
if (_templateId isEqualTo "") exitWith {false};
[_display] call RACA_fnc_pushCreatorHistory;
private _result = [_templateId, uiNamespace getVariable ["RACA_itemCatalog", []], true] call RACA_fnc_applyRoleTemplate;
[_display] call RACA_fnc_refreshItemList;
private _warnings = _result param [1, []];
[_display, format ["Applied role starter '%1'. Review every suggested item before saving.%2", _combo lbText (lbCurSel _combo), if (_warnings isEqualTo []) then {""} else {format [" %1 catalogue rule(s) had no match.", count _warnings]}]] call RACA_fnc_setStatus;
true
