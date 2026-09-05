/*
 * Resolves import cargo against the current ACE catalogue generation.
 * Returns [availableBucket, catalogueRow, conservativeMissingBucket].
 */
params [["_className", "", [""]]];
private _catalog = uiNamespace getVariable ["RACA_itemCatalog", []];
private _index = [_catalog] call RACA_fnc_indexCatalog;
private _byClass = _index getOrDefault ["class", createHashMap];
private _rowIndex = _byClass getOrDefault [toLowerANSI _className, -1];
if (_rowIndex >= 0 && {_rowIndex < count _catalog}) then {
    private _row = _catalog select _rowIndex;
    if (toLowerANSI (_row param [1, ""]) isEqualTo toLowerANSI _className) exitWith {
        [_row param [3, -1, [0]], _rowIndex, -1]
    };
};

// This path is diagnostic only. A config-known class absent from ACE's loaded
// virtual catalogue is still unavailable and must not be emitted as cargo.
private _fallbackBucket = ([_className] call RACA_fnc_classifyCached) select 0;
[-1, -1, _fallbackBucket]
