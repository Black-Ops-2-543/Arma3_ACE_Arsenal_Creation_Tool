#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
private _parent = _display getVariable ["RACA_savedViewsParentDisplay", displayNull];
if (isNull _parent) exitWith {false};
private _name = ctrlText (_display displayCtrl RACA_IDC_SAVED_VIEW_NAME);
private _nameParts = _name splitString (toString [9, 10, 13, 32]);
if (_nameParts isEqualTo []) exitWith {
    (_display displayCtrl RACA_IDC_SAVED_VIEW_DETAILS) ctrlSetText "Enter a name before saving the current filters.";
    false
};
if ((count _name) > 64) exitWith {
    (_display displayCtrl RACA_IDC_SAVED_VIEW_DETAILS) ctrlSetText "Saved-filter names are limited to 64 characters.";
    false
};
private _readCombo = {
    params ["_control"];
    private _index = lbCurSel _control;
    if (_index < 0) then {""} else {_control lbData _index}
};
private _record = [
    "RACA_CATALOG_VIEW",
    3,
    _name,
    (ctrlText (_parent displayCtrl RACA_IDC_SEARCH)) select [0, 256],
    [_parent displayCtrl RACA_IDC_CATEGORY] call _readCombo,
    [_parent displayCtrl RACA_IDC_SOURCE_FILTER] call _readCombo,
    [_parent displayCtrl RACA_IDC_ADDON_FILTER] call _readCombo,
    [_parent displayCtrl RACA_IDC_AUTHOR_FILTER] call _readCombo,
    [_parent displayCtrl RACA_IDC_TAG_FILTER] call _readCombo,
    (uiNamespace getVariable ["RACA_catalogSort", ["item", true]]) select 0,
    (uiNamespace getVariable ["RACA_catalogSort", ["item", true]]) select 1,
    uiNamespace getVariable ["RACA_catalogSearchMode", "BASIC"]
];
private _views = call RACA_fnc_getSavedCatalogViews;
private _existing = _views findIf {toLowerANSI (_x select 2) isEqualTo toLowerANSI _name};
[_display, _parent, _views, _record, _existing] spawn {
    disableSerialization;
    params ["_display", "_parent", "_views", "_record", "_existing"];
    private _canSave = true;
    if (_existing >= 0) then {
        private _confirmed = [format ["Replace saved filters '%1'?", _record select 2], "RACA Saved Filters", true, true, _display] call BIS_fnc_guiMessage;
        if (_confirmed) then {_views set [_existing, _record]} else {_canSave = false};
    } else {
        if ((count _views) >= 50) then {
            (_display displayCtrl RACA_IDC_SAVED_VIEW_DETAILS) ctrlSetText "The 50-filter limit has been reached. Delete an older saved filter first.";
            _canSave = false;
        } else {
            _views pushBack _record;
        };
    };
    if (!_canSave) exitWith {};
    profileNamespace setVariable ["RACA_savedCatalogViews_v1", _views];
    saveProfileNamespace;
    [_display] call RACA_fnc_savedCatalogViewRefresh;
    [_parent, format ["Saved filters '%1'. Arsenal contents were not changed.", _record select 2]] call RACA_fnc_setStatus;
};
true
