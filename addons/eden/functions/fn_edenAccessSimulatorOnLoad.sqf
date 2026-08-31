#include "..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {};
_display setVariable ["RACA_parentEdenConfig", uiNamespace getVariable ["RACA_accessSimulatorParent", displayNull]];

private _units = (all3DENEntities select 0) select {!isNull _x && {_x isKindOf "Man"}};
private _selectedUnits = (get3DENSelected "object") select {!isNull _x && {_x isKindOf "Man"}};
private _selectedUnit = if ((count _selectedUnits) isEqualTo 1) then {_selectedUnits select 0} else {objNull};
private _unitCombo = _display displayCtrl RACA_EDEN_IDC_SIMULATOR_UNIT;
lbClear _unitCombo;
private _selectedIndex = -1;
{
    private _unitName = (_x get3DENAttribute "Name") param [0, ""];
    if (_unitName isEqualTo "") then {
        _unitName = getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayName");
    };
    if (_unitName isEqualTo "") then {_unitName = typeOf _x};
    private _row = _unitCombo lbAdd format ["%1 (%2)", _unitName, typeOf _x];
    _unitCombo lbSetValue [_row, _forEachIndex];
    if (_x isEqualTo _selectedUnit) then {_selectedIndex = _row};
} forEach _units;
_display setVariable ["RACA_accessSimulatorUnits", _units];
if (_units isNotEqualTo []) then {
    _unitCombo lbSetCurSel (if (_selectedIndex >= 0) then {_selectedIndex} else {0});
};
[_display] call RACA_fnc_edenAccessSimulatorRefresh;
