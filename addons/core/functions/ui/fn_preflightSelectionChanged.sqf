#include "..\..\script_component.hpp"
disableSerialization;
params [["_list", controlNull, [controlNull]]];
if (isNull _list) exitWith {false};
private _display = ctrlParent _list;
private _row = lnbCurSelRow _list;
private _entry = (_display getVariable ["RACA_preflightRows", []]) param [_row, []];
private _className = _entry param [3, "", [""]];
private _available = _className isNotEqualTo "" && {
    (uiNamespace getVariable ["RACA_itemCatalog", []]) findIf {
        toLowerANSI (_x select 1) isEqualTo toLowerANSI _className
    } >= 0
};
private _selected = uiNamespace getVariable ["RACA_builderSelected", createHashMap];
private _authoredUnavailable = !_available && {_className isNotEqualTo ""} && {
    (keys _selected) findIf {
        toLowerANSI _x isEqualTo toLowerANSI _className &&
        {_selected getOrDefault [_x, false]}
    } >= 0
};
private _button = _display displayCtrl RACA_IDC_PREFLIGHT_SHOW_ITEM;
_button ctrlShow _available;
_button ctrlEnable _available;
private _remove = _display displayCtrl RACA_IDC_PREFLIGHT_REMOVE_UNAVAILABLE;
_remove ctrlShow _authoredUnavailable;
_remove ctrlEnable _authoredUnavailable;
private _details = _display displayCtrl RACA_IDC_PREFLIGHT_DETAILS;
if (_entry isEqualTo []) then {
    _details ctrlSetText "No result is selected. Use the Severity filter to inspect another result set."
} else {
    _entry params ["_severity", "_code", "_message", "", "_modName", "_sourceAddon"];
    _details ctrlSetText ([
        format ["Severity: %1 | Code: %2", _severity, _code],
        format ["Message: %1", _message],
        format ["Class: %1", if (_className isEqualTo "") then {"Not class-specific"} else {_className}],
        format ["Source mod: %1 | Owning add-on: %2", if (_modName isEqualTo "") then {"Unknown"} else {_modName}, if (_sourceAddon isEqualTo "") then {"Unknown"} else {_sourceAddon}]
    ] joinString toString [10]);
};
private _detailPosition = ctrlPosition _details;
_detailPosition set [3, (ctrlTextHeight _details + 0.02 * safeZoneH) max (0.15 * safeZoneH)];
_details ctrlSetPosition _detailPosition;
_details ctrlCommit 0;
true
