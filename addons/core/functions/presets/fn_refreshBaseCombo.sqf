#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {};

private _combo = _display displayCtrl RACA_IDC_BASE_PRESET;
private _library = uiNamespace getVariable ["RACA_builderLibrary", []];
private _composition = uiNamespace getVariable ["RACA_builderComposition", []];
private _parentName = if (_composition isEqualTo []) then {""} else {_composition select 2};
private _selectedIndex = 0;

lbClear _combo;
private _noneIndex = _combo lbAdd "<No inherited source>";
_combo lbSetData [_noneIndex, ""];

{
    private _name = _x select 2;
    private _index = _combo lbAdd _name;
    _combo lbSetData [_index, _name];
    if (_parentName isNotEqualTo "" && {toLowerANSI _name isEqualTo toLowerANSI _parentName}) then {
        _selectedIndex = _index;
    };
} forEach _library;

_combo lbSetCurSel _selectedIndex;
