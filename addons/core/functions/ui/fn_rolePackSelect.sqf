#include "..\..\script_component.hpp"
disableSerialization;
params [["_list", controlNull, [controlNull]]];
if (isNull _list) exitWith {false};
private _row = lnbCurSelRow _list;
if (_row < 0) exitWith {false};
private _name = _list lnbData [_row, 0];
private _packs = call RACA_fnc_getRolePacks;
private _index = _packs findIf {toLowerANSI (_x select 2) isEqualTo toLowerANSI _name};
if (_index < 0) exitWith {false};
(_packs select _index) params ["", "", "", "_description", "_classes"];
private _display = ctrlParent _list;
(_display displayCtrl RACA_IDC_ROLE_PACK_NAME) ctrlSetText _name;
(_display displayCtrl RACA_IDC_ROLE_PACK_DESCRIPTION) ctrlSetText _description;
(_display displayCtrl RACA_IDC_ROLE_PACK_DETAILS) ctrlSetText format [
    "%1 explicit class(es). Merge adds available classes to the draft; Replace starts from only this pack. Missing mod classes are reported and skipped. Role packs never overwrite or delete arsenal presets.",
    count _classes
];
true
