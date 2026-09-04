params [["_display",displayNull,[displayNull]]];
private _context=uiNamespace getVariable ["RACA_magazineFilterContext",[]];
if (!isNull _display && {_context isNotEqualTo []}) exitWith {
    uiNamespace setVariable ["RACA_magazineFilterContext",[]];
    [_display,_context select 3] call RACA_fnc_restoreCatalogView;
    [_display,"Magazine filter cleared; previous view restored."] call RACA_fnc_setStatus;
};
private _prior=_display getVariable ["RACA_diagnosticNavigationPrior",[]];
if (_prior isNotEqualTo []) exitWith {
    _display setVariable ["RACA_diagnosticNavigationPrior",[]];
    _display setVariable ["RACA_navigationClasses",[]];
    (_display displayCtrl RACA_IDC_CLEAR_MAGAZINES) ctrlSetText "Clear Magazine Filter";
    [_display,_prior] call RACA_fnc_restoreCatalogView;
};
if (isNull _display) exitWith {};
