#include "..\..\script_component.hpp"
disableSerialization;
params [
    ["_display", displayNull, [displayNull]],
    ["_operation", "ASSIGN", [""]]
];
if (isNull _display) exitWith {false};

private _parent = _display getVariable ["RACA_catalogTagsParentDisplay", displayNull];
private _selectedClasses = _display getVariable ["RACA_catalogTagsSelectedClasses", []];
private _list = _display displayCtrl RACA_IDC_CATALOG_TAG_LIST;
private _row = lnbCurSelRow _list;
private _selectedName = if (_row < 0) then {""} else {_list lnbData [_row, 0]};
private _name = ((ctrlText (_display displayCtrl RACA_IDC_CATALOG_TAG_NAME)) splitString (toString [9, 10, 13, 32])) joinString " ";
private _operationKey = toUpperANSI _operation;
private _tags = call RACA_fnc_getCatalogTags;

private _setStatus = {
    params ["_message"];
    (_display displayCtrl RACA_IDC_CATALOG_TAG_DETAILS) ctrlSetText _message;
};
private _save = {
    params ["_records"];
    profileNamespace setVariable ["RACA_catalogTags_v1", _records];
    saveProfileNamespace;
    call RACA_fnc_refreshCatalogTagIndex;
    if (!isNull _parent) then {
        [_parent] call RACA_fnc_refreshSourceCombo;
        [_parent] call RACA_fnc_refreshItemList;
    };
};
private _findByName = {
    params ["_candidate"];
    _tags findIf {toLowerANSI (_x select 2) isEqualTo toLowerANSI _candidate}
};

switch (_operationKey) do {
    case "ASSIGN": {
        if (_selectedClasses isEqualTo []) exitWith {["Select one or more catalogue rows before assigning a tag."] call _setStatus};
        if (_name isEqualTo "" || {(count _name) > 48}) exitWith {["Tag names must contain 1 to 48 visible characters."] call _setStatus};
        private _index = [_name] call _findByName;
        if (_index < 0) then {
            if ((count _tags) >= 100) exitWith {["The 100-tag limit has been reached. Delete an unused tag first."] call _setStatus};
            _tags pushBack ["RACA_CATALOG_TAG", 1, _name, []];
            _index = (count _tags) - 1;
        } else {
            _name = (_tags select _index) select 2;
        };
        private _classes = +((_tags select _index) select 3);
        {_classes pushBackUnique _x} forEach _selectedClasses;
        _classes sort true;
        if ((count _classes) > 5000) then {_classes resize 5000};
        _tags set [_index, ["RACA_CATALOG_TAG", 1, _name, _classes]];
        [_tags] call _save;
        _display setVariable ["RACA_catalogTagRestore", _name];
        [_display] call RACA_fnc_catalogTagsRefresh;
        [format ["Added %1 selected class(es) to '%2'.", count _selectedClasses, _name]] call _setStatus;
    };
    case "REMOVE": {
        if (_selectedName isEqualTo "" || {_selectedClasses isEqualTo []}) exitWith {["Select a tag and one or more catalogue rows first."] call _setStatus};
        private _index = [_selectedName] call _findByName;
        if (_index < 0) exitWith {["The selected tag no longer exists."] call _setStatus};
        private _classes = +((_tags select _index) select 3);
        private _removeCount = {_x in _selectedClasses} count _classes;
        if (_removeCount isEqualTo 0) exitWith {["None of the selected classes currently use this tag."] call _setStatus};
        private _confirmed = [
            format ["Remove tag '%1' from %2 selected class(es)? The classes and every preset remain unchanged.", _selectedName, _removeCount],
            "RACA Catalogue Tags",
            true,
            true,
            _display
        ] call BIS_fnc_guiMessage;
        if (!_confirmed) exitWith {};
        _classes = _classes select {!(_x in _selectedClasses)};
        _tags set [_index, ["RACA_CATALOG_TAG", 1, (_tags select _index) select 2, _classes]];
        [_tags] call _save;
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
        _tags deleteAt _index;
        [_tags] call _save;
        [_display] call RACA_fnc_catalogTagsRefresh;
        [format ["Deleted catalogue tag '%1'.", _selectedName]] call _setStatus;
    };
    case "FILTER": {
        if (_selectedName isEqualTo "" || {isNull _parent}) exitWith {false};
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
