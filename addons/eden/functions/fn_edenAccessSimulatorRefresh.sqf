#include "..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];

if (isNull _display || {!is3DEN}) exitWith {false};
private _summary = _display displayCtrl RACA_EDEN_IDC_SIMULATOR_SUMMARY;
private _list = _display displayCtrl RACA_EDEN_IDC_SIMULATOR_RULES;
lnbClear _list;
_display setVariable ["RACA_accessSimulatorReport", ""];

private _parent = _display getVariable ["RACA_parentEdenConfig", displayNull];
if (isNull _parent) exitWith {
    _summary ctrlSetText "The parent Eden tool is no longer open. Close the simulator and reopen it from Configure.";
    false
};
private _slot = _parent getVariable ["RACA_simulatorSlot", []];
if (_slot isEqualTo []) exitWith {
    _summary ctrlSetText "No current Arsenal Configuration is available to test.";
    false
};

private _units = _display getVariable ["RACA_accessSimulatorUnits", []];
private _unitCombo = _display displayCtrl RACA_EDEN_IDC_SIMULATOR_UNIT;
private _unitIndex = lbCurSel _unitCombo;
if (_unitIndex < 0 || {_unitIndex >= count _units}) exitWith {
    _summary ctrlSetText "No playable or AI units are available in this Eden mission. Place a unit, reopen the simulator, and try again.";
    false
};
private _unit = _units select _unitIndex;
if (isNull _unit) exitWith {
    _summary ctrlSetText "The chosen unit no longer exists. Close and reopen the simulator to refresh the mission-unit list.";
    false
};
private _unitName = (_unit get3DENAttribute "Name") param [0, ""];
if (_unitName isEqualTo "") then {
    _unitName = getText (configFile >> "CfgVehicles" >> typeOf _unit >> "displayName");
};
if (_unitName isEqualTo "") then {_unitName = typeOf _unit};

private _slotName = _slot param [1, "Arsenal Configuration", [""]];
private _access = [_slot param [4, [], [[]]]] call RACA_fnc_normalizeAccess;
private _mode = _access select 2;
private _conditions = _access select 3;
private _rankOrder = ["PRIVATE", "CORPORAL", "SERGEANT", "LIEUTENANT", "CAPTAIN", "MAJOR", "COLONEL"];
private _rows = [];
private _passCount = 0;
private _failCount = 0;
private _unknownCount = 0;

{
    _x params ["_kind", "_value"];
    private _expected = if (_value isEqualType []) then {_value joinString ", "} else {if (_value isEqualType "") then {_value} else {str _value}};
    private _actual = "";
    private _known = true;
    private _matched = false;
    switch (toLowerANSI _kind) do {
        case "side": {
            _actual = str (side group _unit);
            _matched = toUpperANSI _actual isEqualTo toUpperANSI _value;
        };
        case "faction": {
            _actual = faction _unit;
            _matched = toLowerANSI _actual isEqualTo toLowerANSI _value;
        };
        case "group": {
            _actual = groupId group _unit;
            _matched = toLowerANSI _actual isEqualTo toLowerANSI _value;
        };
        case "rank": {
            _actual = rank _unit;
            private _required = _rankOrder find toUpperANSI _value;
            private _present = _rankOrder find _actual;
            _matched = _required >= 0 && {_present >= _required};
        };
        case "unit": {
            _actual = typeOf _unit;
            _matched = _actual isEqualTo _value;
        };
        case "uid": {
            _known = false;
            _actual = "Runtime player UID only";
        };
        case "vehiclerole": {
            private _role = (assignedVehicleRole _unit) param [0, ""];
            _actual = if (_role isEqualTo "") then {"<none>"} else {_role};
            _matched = toLowerANSI _role isEqualTo toLowerANSI _value;
        };
        case "requireditem": {
            private _inventory = items _unit + assignedItems _unit + weapons _unit + magazines _unit;
            _matched = _value in _inventory;
            _actual = ["Not in Eden loadout", "Present in Eden loadout"] select _matched;
        };
        case "acepermission": {
            _known = false;
            _actual = "Runtime mission permission only";
        };
        default {
            _known = false;
            _actual = "Unsupported rule";
        };
    };

    private _result = if (!_known) then {"UNKNOWN"} else {["FAIL", "PASS"] select _matched};
    switch (_result) do {
        case "PASS": {_passCount = _passCount + 1};
        case "FAIL": {_failCount = _failCount + 1};
        default {_unknownCount = _unknownCount + 1};
    };
    private _row = _list lnbAddRow [_result, toUpperANSI _kind, _expected, _actual];
    private _color = switch (_result) do {
        case "PASS": {[0.45, 0.95, 0.52, 1]};
        case "FAIL": {[1, 0.42, 0.38, 1]};
        default {[1, 0.82, 0.35, 1]};
    };
    {_list lnbSetColor [[_row, _x], _color]} forEach [0, 1, 2, 3];
    _rows pushBack format ["%1 | %2 | expected: %3 | actual: %4", _result, toUpperANSI _kind, _expected, _actual];
} forEach _conditions;

private _outcome = if (_conditions isEqualTo []) then {"PASS"} else {
    if (_mode isEqualTo "OR") then {
        if (_passCount > 0) then {"PASS"} else {if (_unknownCount > 0) then {"INDETERMINATE"} else {"FAIL"}}
    } else {
        if (_failCount > 0) then {"FAIL"} else {if (_unknownCount > 0) then {"INDETERMINATE"} else {"PASS"}}
    }
};
private _outcomeColor = switch (_outcome) do {
    case "PASS": {[0.45, 0.95, 0.52, 1]};
    case "FAIL": {[1, 0.42, 0.38, 1]};
    default {[1, 0.82, 0.35, 1]};
};
_summary ctrlSetTextColor _outcomeColor;
_summary ctrlSetText format [
    "%1 - Configuration '%2' against %3 (%4).%5Mode %6: %7 pass, %8 fail, %9 runtime-only unknown.%5This is an editor rehearsal; repeat UID, permission, quota, and JIP checks in multiplayer.",
    _outcome, _slotName, _unitName, typeOf _unit, toString [10], _mode, _passCount, _failCount, _unknownCount
];

private _reportLines = [
    "RACA ACCESS-RULE SIMULATION",
    format ["Outcome: %1", _outcome],
    format ["Configuration: %1", _slotName],
    format ["Unit: %1 (%2)", _unitName, typeOf _unit],
    format ["Mode: %1", _mode],
    format ["Rules: %1 pass, %2 fail, %3 unknown", _passCount, _failCount, _unknownCount]
];
if (_rows isEqualTo []) then {_reportLines pushBack "PASS | No access rules; everyone is allowed."} else {_reportLines append _rows};
_reportLines pushBack format ["Denial message: %1", _access select 5];
_reportLines pushBack "Note: UID and ACE permission rules require runtime verification; quotas and JIP are outside this editor simulation.";
_display setVariable ["RACA_accessSimulatorReport", _reportLines joinString (toString [13, 10])];
true
