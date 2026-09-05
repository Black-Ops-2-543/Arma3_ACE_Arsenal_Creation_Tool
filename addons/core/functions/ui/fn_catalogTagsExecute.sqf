#include "..\..\script_component.hpp"
disableSerialization;
params [
    ["_display", displayNull, [displayNull]],
    ["_operation", "ASSIGN", [""]]
];
if (isNull _display) exitWith {false};

private _parent = _display getVariable ["RACA_catalogTagsParentDisplay", displayNull];
private _selectedClasses = _display getVariable ["RACA_catalogTagsSelectedClasses", []];
private _memberClasses = keys (_display getVariable ["RACA_tagMemberHighlights",createHashMap]);
private _list = _display displayCtrl RACA_IDC_CATALOG_TAG_LIST;
private _row = lnbCurSelRow _list;
private _selectedName = if (_row < 0) then {""} else {_list lnbData [_row, 0]};
private _name = ((ctrlText (_display displayCtrl RACA_IDC_CATALOG_TAG_NAME)) splitString (toString [9, 10, 13, 32])) joinString " ";
private _operationKey = toUpperANSI _operation;
private _tags = call RACA_fnc_getCatalogTags;
private _baselineRaw = +(profileNamespace getVariable ["RACA_catalogTags_v1", []]);

private _setStatus = {
    params ["_message"];
    (_display displayCtrl RACA_IDC_CATALOG_TAG_DETAILS) ctrlSetText _message;
};
private _save = {
    params ["_records", ["_recordHistory", true, [true]], ["_delta",[],[[]]]];
    if !((profileNamespace getVariable ["RACA_catalogTags_v1", []]) isEqualTo _baselineRaw) exitWith {
        ["Tags changed while the confirmation was open. Nothing was saved; retry the operation."] call _setStatus;
        false
    };
    if (_recordHistory) then {
        private _history = profileNamespace getVariable ["RACA_catalogTagHistory_v1", []];
        if !(_history isEqualType []) then {_history = []};
        _history = _history select {
            _x isEqualType [] &&
            {(_x param [0, "", [""]]) isEqualTo "RACA_TAG_HISTORY"} &&
            {(_x param [1, -1, [0]]) isEqualTo 1} &&
            {(_x param [3, [], [[]]]) isEqualType []}
        };
        _history pushBack ["RACA_TAG_HISTORY", 1, systemTimeUTC, +_baselineRaw];
        if ((count _history) > 20) then {_history deleteRange [0, (count _history) - 20]};
        profileNamespace setVariable ["RACA_catalogTagHistory_v1", _history];
    };
    profileNamespace setVariable ["RACA_catalogTags_v1", _records];
    profileNamespace setVariable ["RACA_catalogTagsRevision_v1", (profileNamespace getVariable ["RACA_catalogTagsRevision_v1", 0]) + 1];
    saveProfileNamespace;
    uiNamespace setVariable ["RACA_catalogTagsCacheRevision", -1];
    [_delta] call RACA_fnc_refreshCatalogTagIndex;
    if (!isNull _parent) then {
        [_parent] call RACA_fnc_refreshSourceCombo;
        [_parent] call RACA_fnc_refreshItemList;
    };
    true
};
private _findByName = {
    params ["_candidate"];
    _tags findIf {toLowerANSI (_x select 2) isEqualTo toLowerANSI _candidate}
};

switch (_operationKey) do {
    case "UNDO": {
        private _history = profileNamespace getVariable ["RACA_catalogTagHistory_v1", []];
        _history = _history select {
            _x isEqualType [] &&
            {(_x param [0, "", [""]]) isEqualTo "RACA_TAG_HISTORY"} &&
            {(_x param [1, -1, [0]]) isEqualTo 1} &&
            {(_x param [3, [], [[]]]) isEqualType []}
        };
        if (_history isEqualTo []) exitWith {["No catalogue-tag edit is available to undo."] call _setStatus};
        private _entry = _history deleteAt ((count _history) - 1);
        profileNamespace setVariable ["RACA_catalogTags_v1", +(_entry select 3)];
        profileNamespace setVariable ["RACA_catalogTagHistory_v1", _history];
        profileNamespace setVariable ["RACA_catalogTagsRevision_v1", (profileNamespace getVariable ["RACA_catalogTagsRevision_v1", 0]) + 1];
        saveProfileNamespace;
        uiNamespace setVariable ["RACA_catalogTagsCacheRevision", -1];
        call RACA_fnc_refreshCatalogTagIndex;
        if (!isNull _parent) then {
            [_parent] call RACA_fnc_refreshSourceCombo;
            [_parent] call RACA_fnc_refreshItemList;
        };
        [_display] call RACA_fnc_catalogTagsRefresh;
        ["Restored the catalogue tags from before the last committed tag edit."] call _setStatus;
    };
    case "ASSIGN": {
        if (_selectedClasses isEqualTo []) exitWith {["Select one or more catalogue rows before assigning a tag."] call _setStatus};
        if (_name isEqualTo "" || {(count _name) > 48}) exitWith {["Tag names must contain 1 to 48 visible characters."] call _setStatus};
        private _index = [_name] call _findByName;
        if (_index < 0) then {
            _tags pushBack ["RACA_CATALOG_TAG", 1, _name, []];
            _index = (count _tags) - 1;
        } else {
            _name = (_tags select _index) select 2;
        };
        private _classes = +((_tags select _index) select 3);
        private _classSet = createHashMapFromArray (_classes apply {[(toLowerANSI _x),true]});
        private _added = 0;
        private _addedClasses = [];
        {if !(_classSet getOrDefault [toLowerANSI _x,false]) then {_classSet set [toLowerANSI _x,true]; _classes pushBack _x; _addedClasses pushBack _x; _added=_added+1}} forEach _selectedClasses;
        _classes sort true;
        _tags set [_index, ["RACA_CATALOG_TAG", 1, _name, _classes]];
        if !([_tags,true,["ADD",_name,_addedClasses]] call _save) exitWith {};
        _display setVariable ["RACA_catalogTagRestore", _name];
        [_display] call RACA_fnc_catalogTagsRefresh;
        [format ["Added %1 of %2 captured Creator class(es) to '%3'; %4 already belonged.", _added, count _selectedClasses, _name, (count _selectedClasses)-_added]] call _setStatus;
    };
    case "REMOVE": {
        if (_selectedName isEqualTo "" || {_memberClasses isEqualTo []}) exitWith {["Highlight one or more members in the member table first."] call _setStatus};
        private _index = [_selectedName] call _findByName;
        if (_index < 0) exitWith {["The selected tag no longer exists."] call _setStatus};
        private _classes = +((_tags select _index) select 3);
        private _removeSet=createHashMapFromArray (_memberClasses apply {[(toLowerANSI _x),true]});
        private _removeCount = {_removeSet getOrDefault [toLowerANSI _x,false]} count _classes;
        if (_removeCount isEqualTo 0) exitWith {["None of the selected classes currently use this tag."] call _setStatus};
        private _confirmed = [
            format ["Remove tag '%1' from %2 selected class(es)? The classes and every preset remain unchanged.", _selectedName, _removeCount],
            "RACA Catalogue Tags",
            true,
            true,
            _display
        ] call BIS_fnc_guiMessage;
        if (!_confirmed) exitWith {};
        _classes = _classes select {!(_removeSet getOrDefault [toLowerANSI _x,false])};
        _tags set [_index, ["RACA_CATALOG_TAG", 1, (_tags select _index) select 2, _classes]];
        if !([_tags,true,["REMOVE",_selectedName,_memberClasses]] call _save) exitWith {};
        _display setVariable ["RACA_catalogTagRestore", _selectedName];
        [_display] call RACA_fnc_catalogTagsRefresh;
        [format ["Removed '%1' from %2 selected class(es).", _selectedName, _removeCount]] call _setStatus;
    };
    case "DELETE": {
        if (_selectedName isEqualTo "") exitWith {["Select a tag before deleting it."] call _setStatus};
        private _index = [_selectedName] call _findByName;
        if (_index < 0) exitWith {["The selected tag no longer exists."] call _setStatus};
        private _classCount = count ((_tags select _index) select 3);
        private _confirmed = [
            format ["Delete catalogue tag '%1' and remove it from %2 class(es)? Presets, favorites, and mission objects are unaffected.", _selectedName, _classCount],
            "RACA Catalogue Tags",
            true,
            true,
            _display
        ] call BIS_fnc_guiMessage;
        if (!_confirmed) exitWith {};
        private _deletedClasses = +((_tags select _index) select 3);
        _tags deleteAt _index;
        if !([_tags,true,["DELETE",_selectedName,_deletedClasses]] call _save) exitWith {};
        [_display] call RACA_fnc_catalogTagsRefresh;
        [format ["Deleted catalogue tag '%1'.", _selectedName]] call _setStatus;
    };
    case "FILTER": {
        if (_selectedName isEqualTo "" || {isNull _parent}) exitWith {false};
        [_parent, "ADVANCED"] call RACA_fnc_setSearchMode;
        [_parent] call RACA_fnc_refreshSourceCombo;
        private _filter = _parent displayCtrl RACA_IDC_TAG_FILTER;
        private _match = 0;
        for "_i" from 0 to ((lbSize _filter) - 1) do {
            if ((_filter lbData _i) isEqualTo _selectedName) exitWith {_match = _i};
        };
        _filter lbSetCurSel _match;
        [_parent] call RACA_fnc_refreshItemList;
        _display closeDisplay 1;
        [_parent, format ["Filtering the catalogue to tag '%1'.", _selectedName]] call RACA_fnc_setStatus;
    };
    case "CLEAR": {
        if (isNull _parent) exitWith {false};
        (_parent displayCtrl RACA_IDC_TAG_FILTER) lbSetCurSel 0;
        [_parent] call RACA_fnc_refreshItemList;
        _display closeDisplay 1;
        [_parent, "Catalogue tag filter cleared."] call RACA_fnc_setStatus;
    };
};
true
