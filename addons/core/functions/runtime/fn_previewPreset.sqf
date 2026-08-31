params ["_preset", ["_unit", objNull], ["_applyTemporarily", false]];
private _catalog = uiNamespace getVariable ["RACA_itemCatalog", []];
private _analysis = [_preset, _catalog, []] call RACA_fnc_analyzePreset;
if (!(_analysis select 0) || {!_applyTemporarily} || {isNull _unit}) exitWith {_analysis};
private _before = getUnitLoadout _unit;
_unit setVariable ["RACA_previewOriginalLoadout", _before];
private _classes = [_preset] call RACA_fnc_flattenPresetClasses;
private _mass = 0;
{private _cfg = ([_x] call RACA_fnc_classifyClass) select 2; _mass = _mass + getNumber (_cfg >> "ItemInfo" >> "mass")} forEach _classes;
[_analysis, ["classCount", count _classes], ["estimatedMass", _mass], ["restoreLoadout", _before]]
