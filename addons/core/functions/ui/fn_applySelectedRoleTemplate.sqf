#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
private _combo = _display displayCtrl RACA_IDC_ROLE_TEMPLATE;
private _templateId = _combo lbData (lbCurSel _combo);
if (_templateId isEqualTo "") exitWith {false};
[_display] call RACA_fnc_pushCreatorHistory;
private _sourceCtrl = _display displayCtrl RACA_IDC_SOURCE_FILTER;
private _source = _sourceCtrl lbData (lbCurSel _sourceCtrl);
private _catalog = uiNamespace getVariable ["RACA_itemCatalog", []];
if (_source isNotEqualTo "") then {_catalog = _catalog select {(_x select 4) isEqualTo _source}};
private _result = [_templateId, _catalog, true] call RACA_fnc_applyRoleTemplate;
[_display] call RACA_fnc_refreshItemList;
private _warnings = _result param [1, []];
[_display, format ["Applied role starter '%1'%2. Review every suggested item before saving.%3", _combo lbText (lbCurSel _combo), if (_source isEqualTo "") then {""} else {format [" within source '%1'", _source]}, if (_warnings isEqualTo []) then {""} else {format [" %1 catalogue rule(s) had no match.", count _warnings]}]] call RACA_fnc_setStatus;
true
