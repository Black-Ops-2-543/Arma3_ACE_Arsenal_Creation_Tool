#include "..\script_component.hpp"
disableSerialization;
params [
    ["_group", controlNull, [controlNull]],
    ["_value", [], [[]]]
];

if (isNull _group) exitWith {};
[_group, _value] call RACA_fnc_edenPopulate;

/*
 * Eden's scripted attribute setters reject this custom array-valued control
 * even though the native Attributes window saves it correctly.  The mission
 * Dashboard therefore opens the supported native editor action with a
 * one-shot pending assignment.  Complete that transaction here, inside the
 * control lifecycle that Eden itself owns, then accept the native dialog.
 */
private _pending = uiNamespace getVariable ["RACA_edenNativeTransaction", []];
if (_pending isEqualTo []) exitWith {};
if ((_pending param [0, "", [""]]) isNotEqualTo "RACA_EDEN_NATIVE_TRANSACTION" ||
    {(_pending param [1, -1, [0]]) isNotEqualTo 1} || {(count _pending) < 11}) exitWith {
    uiNamespace setVariable ["RACA_edenNativeTransaction", nil];
};
_pending params ["", "", "_requestId", "_entityId", "_configurationId", "_expected", "_before", "_libraryRevision", "_expiry"];
private _reject = {
    params ["_reason"];
    _pending set [9, "REJECTED:" + _reason];
    uiNamespace setVariable ["RACA_edenNativeTransaction", _pending];
};
if (_expiry <= diag_tickTime) exitWith {["expired"] call _reject};
if (str ((call RACA_fnc_edenGetConfigurationState) select 3) isNotEqualTo _libraryRevision) exitWith {["library changed"] call _reject};
private _selectedIds = (get3DENSelected "Object") apply {get3DENEntityID _x};
if (_entityId < 0 || {count _selectedIds isNotEqualTo 1} || {(_selectedIds select 0) isNotEqualTo _entityId}) exitWith {["selection changed"] call _reject};
private _objects = all3DENEntities select 0;
private _objectIndex = _objects findIf {get3DENEntityID _x isEqualTo _entityId};
if (_objectIndex < 0) exitWith {["entity missing"] call _reject};
private _object = _objects select _objectIndex;
if (((_object get3DENAttribute "RACA_RestrictedArsenalPreset") param [0, []]) isNotEqualTo _before) exitWith {["attribute changed"] call _reject};

private _combo = _group controlsGroupCtrl RACA_EDEN_IDC_PRESET;
private _target = -1;
for "_index" from 0 to ((lbSize _combo) - 1) do {
    if (toLowerANSI (_combo lbData _index) isEqualTo toLowerANSI _configurationId) exitWith {
        _target = _index;
    };
};
private _nativeDisplay = ctrlParent _group;
if (_target < 0 || {isNull _nativeDisplay}) exitWith {
    ["configuration unavailable"] call _reject;
};

_combo lbSetCurSel _target;
[_group] call RACA_fnc_edenUpdateSummary;
_pending set [9, "LOADED"];
_pending set [10, _nativeDisplay];
uiNamespace setVariable ["RACA_edenNativeTransaction", _pending];
[_nativeDisplay] spawn {
    disableSerialization;
    params ["_display"];
    uiSleep 0.05;
    if (!isNull _display) then {
        ctrlActivate (_display displayCtrl 1);
    };
};
