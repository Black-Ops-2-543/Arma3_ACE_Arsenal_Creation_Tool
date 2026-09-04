#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};

private _tags = call RACA_fnc_getCatalogTags;
private _search=toLowerANSI ctrlText (_display displayCtrl RACA_IDC_CATALOG_TAG_SEARCH);
_tags=_tags select {_search isEqualTo "" || {(toLowerANSI (_x select 2) find _search)>=0}};
private _selectedClasses = _display getVariable ["RACA_catalogTagsSelectedClasses", []];
private _capturedSet = createHashMapFromArray (_selectedClasses apply {[(toLowerANSI _x), true]});
private _list = _display displayCtrl RACA_IDC_CATALOG_TAG_LIST;
private _previousRow = lnbCurSelRow _list;
private _previousName = _display getVariable [
    "RACA_catalogTagRestore",
    if (_previousRow < 0) then {""} else {_list lnbData [_previousRow, 0]}
];
_display setVariable ["RACA_catalogTagRestore", nil];
private _tagPage=_display getVariable ["RACA_tagPage",0];
private _restoreIndex=_tags findIf {toLowerANSI (_x select 2) isEqualTo toLowerANSI _previousName};
if (_restoreIndex>=0) then {_tagPage=floor (_restoreIndex/100)};
private _tagPages=(ceil (count _tags/100)) max 1;
_tagPage=_tagPage min (_tagPages-1);
_display setVariable ["RACA_tagPage",_tagPage];
lnbClear _list;
private _restore = -1;
{
    _x params ["", "", "_name", "_classes"];
    private _selectedCount = {_capturedSet getOrDefault [toLowerANSI _x, false]} count _classes;
    private _row = _list lnbAddRow [_name, str count _classes, str _selectedCount];
    _list lnbSetData [[_row, 0], _name];
    private _tooltip = format ["%1%4%2 tagged class(es); %3 currently selected.", _name, count _classes, _selectedCount, toString [10]];
    {_list lnbSetTooltip [[_row, _x], _tooltip]} forEach [0, 1, 2];
    if (toLowerANSI _name isEqualTo toLowerANSI _previousName) then {_restore = _row};
} forEach (_tags select [_tagPage*100,100]);
if (_restore < 0 && {_tags isNotEqualTo []}) then {_restore = 0};
if (_restore >= 0) then {_list lnbSetCurSelRow _restore};
(_display displayCtrl RACA_IDC_CATALOG_TAG_PAGE_LABEL) ctrlSetText format ["Page %1 / %2 | %3 tag(s)",_tagPage+1,_tagPages,count _tags];
(_display displayCtrl RACA_IDC_CATALOG_TAG_PAGE_PREV) ctrlEnable (_tagPage>0);
(_display displayCtrl RACA_IDC_CATALOG_TAG_PAGE_NEXT) ctrlEnable (_tagPage+1<_tagPages);

private _parent = _display getVariable ["RACA_catalogTagsParentDisplay", displayNull];
private _activeFilter = "";
if (!isNull _parent) then {
    private _filter = _parent displayCtrl RACA_IDC_TAG_FILTER;
    private _index = lbCurSel _filter;
    if (_index >= 0) then {_activeFilter = _filter lbData _index};
};
(_display displayCtrl RACA_IDC_CATALOG_TAG_ASSIGN) ctrlEnable (_selectedClasses isNotEqualTo []);
(_display displayCtrl RACA_IDC_CATALOG_TAG_REMOVE) ctrlEnable false;
_display setVariable ["RACA_tagMemberHighlights",createHashMap];
(_display displayCtrl RACA_IDC_CATALOG_TAG_FILTER) ctrlEnable (_tags isNotEqualTo []);
(_display displayCtrl RACA_IDC_CATALOG_TAG_DELETE) ctrlEnable (_tags isNotEqualTo []);
(_display displayCtrl RACA_IDC_CATALOG_TAG_CLEAR_FILTER) ctrlEnable (_activeFilter isNotEqualTo "");
(_display displayCtrl RACA_IDC_CATALOG_TAG_UNDO) ctrlEnable ((profileNamespace getVariable ["RACA_catalogTagHistory_v1", []]) isNotEqualTo []);

if (_tags isEqualTo []) then {
    (_display displayCtrl RACA_IDC_CATALOG_TAG_NAME) ctrlSetText "";
    (_display displayCtrl RACA_IDC_CATALOG_TAG_DETAILS) ctrlSetText format [
        "No catalogue tags exist yet. %1 class(es) are selected in the creator. Enter a name and choose Add to Selected.",
        count _selectedClasses
    ];
} else {
    [_list] call RACA_fnc_catalogTagsSelect;
};
true
