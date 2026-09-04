#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display || {!canSuspend}) exitWith {};
if (isMultiplayer) exitWith {[_display, "Import is available in the single-player Creator."] call RACA_fnc_setStatus};
if (_display getVariable ["RACA_importBusy", false]) exitWith {[_display, "An import is already active. Finish or cancel it first."] call RACA_fnc_setStatus};
_display setVariable ["RACA_importBusy", true];
private _id = (uiNamespace getVariable ["RACA_importSerial", 0]) + 1;
uiNamespace setVariable ["RACA_importSerial", _id];
_display setVariable ["RACA_importId", _id];
private _dialog = _display createDisplay "RACA_ImportDialog";
private _operation = [_display, _display getVariable ["RACA_generation", -1], _dialog, _id];
private _started = diag_tickTime;
private _result = "";
try {
    forceUnicode 1;
    private _text = copyFromClipboard;
    if !([_operation, "Identifying input", count _text, count _text] call RACA_fnc_importCheckpoint) then {throw "Import cancelled."};
    private _first = (toArray _text) findIf {!(_x in [9,10,13,32])};
    private _trimmed = if (_first < 0) then {""} else {_text select [_first]};
    private _json = (_text find "RACA_PORTABLE_PRESET") >= 0 || {(_text find "RACA_PRESET") >= 0} || {(_trimmed select [0,1]) in ["[","{"]};
    // An ordinary SQF array of strings is accepted by the SQF lexer unless it
    // has a JSON transport signature. Objects are always JSON, never scripts.
    if (_json && {(_text find "RACA_") < 0} && {(_trimmed select [0,1]) isEqualTo "["}) then {_json = false};
    private _parseStart = diag_tickTime;
    private _decoded = if (_json) then {[_text, _operation] call RACA_fnc_decodePortablePreset} else {[_text, ctrlText (_display displayCtrl RACA_IDC_PRESET_NAME), _operation] call RACA_fnc_decodeSqfPreset};
    diag_log format ["[RACA][IMPORT:%1] parse seconds=%2 characters=%3 format=%4", _id, diag_tickTime - _parseStart, count _text, ["SQF/list","JSON"] select _json];
    _decoded params ["_preset", "_metadata", "_warnings"];
    if (_preset isEqualTo []) then {throw (_warnings param [(count _warnings)-1, "Invalid import."])};
    if !([_operation, "Reviewing import", 1, 1] call RACA_fnc_importCheckpoint) then {throw "Import cancelled."};
    private _library = call RACA_fnc_getPresetLibrary;
    private _baseline = +_library;
    private _name = _preset select 2;
    private _existing = _library findIf {toLowerANSI (_x select 2) isEqualTo toLowerANSI _name};
    private _items = 0;
    {_items = _items + count _x} forEach (_preset select 3);
    private _missing = {_x find "Missing item:" isEqualTo 0} count _warnings;
    (_dialog displayCtrl 1000) ctrlSetText format ["Review '%1': %2 authored items (%3 unavailable). %4 notice(s). %5\n%6", _name, _items, _missing, count _warnings, ["Create a new preset.", "This name already exists. Choose Overwrite, Import Copy, or Cancel."] select (_existing >= 0), (_warnings select [0,8]) joinString "\n"];
    (_dialog displayCtrl 1600) ctrlSetText (["Import", "Overwrite"] select (_existing >= 0));
    (_dialog displayCtrl 1600) ctrlEnable true;
    (_dialog displayCtrl 1601) ctrlEnable (_existing >= 0);
    waitUntil {uiSleep 0.05; isNull _dialog || {(_dialog getVariable ["RACA_choice", ""]) isNotEqualTo ""}};
    if (isNull _dialog || {isNull _display}) then {throw "Import cancelled."};
    private _choice = _dialog getVariable ["RACA_choice", ""];
    if !(_choice in ["OVERWRITE","COPY"]) then {throw "Import cancelled."};
    if (_choice isEqualTo "COPY") then {
        private _n = 1;
        private _candidate = "";
        while {_candidate isEqualTo "" || {(_library findIf {toLowerANSI (_x select 2) isEqualTo toLowerANSI _candidate}) >= 0}} do {
            private _suffix = format [" (Imported %1)", _n];
            _candidate = (_name select [0,128 - count _suffix]) + _suffix;
            _n = _n + 1;
        };
        _name = _candidate; _preset set [2,_name]; _existing = -1;
    };
    private _composition = [_preset] call RACA_fnc_getComposition;
    if (_composition isNotEqualTo [] && {[_name, _composition select 2, _library] call RACA_fnc_wouldCreateCycle}) then {throw "The final import name would create circular inheritance."};
    if !(_baseline isEqualTo (call RACA_fnc_getPresetLibrary)) then {throw "The preset library changed during review. Retry the import."};
    if !([_operation, "Committing", 1, 1] call RACA_fnc_importCheckpoint) then {throw "Import cancelled."};
    private _revision = if (_existing >= 0) then {(([_library select _existing] call RACA_fnc_getRuntimePolicy) select 4) + 1} else {1};
    _preset pushBack ["RACA_IMPORT_PROVENANCE", 1, +([_preset] call RACA_fnc_getRuntimePolicy), +_metadata];
    _preset = [_preset, "", uiNamespace getVariable ["RACA_itemCatalog", []], _revision] call RACA_fnc_setPresetRevision;
    // No suspension between final revision check and the one persistence call.
    isNil {
        if (_existing >= 0) then {
            [_library select _existing, "Before import overwrite", false] call RACA_fnc_archivePreset;
            _library set [_existing, _preset];
        } else {_library pushBack _preset};
        profileNamespace setVariable ["RACA_presetLibrary_v1", _library];
        saveProfileNamespace;
    };
    _dialog closeDisplay 1;
    [_display] call RACA_fnc_refreshPresetCombo;
    private _index = _library findIf {toLowerANSI (_x select 2) isEqualTo toLowerANSI _name};
    (_display displayCtrl RACA_IDC_PRESET_LIST) lbSetCurSel (_index+1);
    [_display] call RACA_fnc_loadSelectedPreset;
    _result = format ["Imported '%1': %2 authored items; %3 unavailable preserved. %4 notice(s).", _name, _items, _missing, count _warnings];
} catch {_result = format ["%1 No uncommitted import changes were saved.", _exception]};
if (!isNull _dialog) then {_dialog closeDisplay 2};
if (!isNull _display) then {
    _display setVariable ["RACA_importBusy", false];
    [_display, _result] call RACA_fnc_setStatus;
};
diag_log format ["[RACA][IMPORT:%1] elapsed=%2 result=%3", _id, diag_tickTime - _started, _result];
