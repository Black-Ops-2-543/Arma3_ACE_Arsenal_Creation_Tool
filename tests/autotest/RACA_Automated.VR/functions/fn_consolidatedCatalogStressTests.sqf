params ["_record", "_creatorDisplay"];
private _realCatalog = uiNamespace getVariable ["RACA_itemCatalog", []];
private _realGeneration = uiNamespace getVariable ["RACA_catalogGeneration", 0];
private _realIndex = uiNamespace getVariable ["RACA_catalogIndex", createHashMap];
private _realSort = +(uiNamespace getVariable ["RACA_catalogSort", ["item", true]]);
private _syntheticCatalog = [];
_syntheticCatalog resize 100000;
for "_syntheticIndex" from 0 to 99999 do {
    private _className = format ["RACA_Synthetic_%1", _syntheticIndex];
    private _displayName = format [
        "Synthetic %1%2",
        _syntheticIndex,
        ["", " needle"] select ((_syntheticIndex mod 1000) isEqualTo 0)
    ];
    _syntheticCatalog set [_syntheticIndex, [
        _displayName, _className, "Weapons", 0, "RACA Synthetic", "Autotest", "",
        toLowerANSI format [
            "%1 %2 weapons raca synthetic autotest", _displayName, _className
        ],
        "RACA_Synthetic_Addon"
    ]];
};
uiNamespace setVariable ["RACA_itemCatalog", _syntheticCatalog];
uiNamespace setVariable ["RACA_catalogGeneration", _realGeneration + 1];
uiNamespace setVariable ["RACA_catalogIndex", createHashMap];
uiNamespace setVariable ["RACA_catalogSort", ["item", true]];
uiNamespace setVariable ["RACA_catalogSearchMode", "BASIC"];
_creatorDisplay setVariable ["RACA_navigationClasses", []];
_creatorDisplay setVariable ["RACA_unresolvedFilters", []];
_creatorDisplay setVariable ["RACA_highlighted", createHashMap];
(_creatorDisplay displayCtrl 1400) ctrlSetText "";

private _firstRenderStarted = diag_tickTime;
[_creatorDisplay] call RACA_fnc_refreshItemList;
private _firstRenderElapsed = diag_tickTime - _firstRenderStarted;
private _syntheticList = _creatorDisplay displayCtrl 1500;
private _allSyntheticClasses = uiNamespace getVariable ["RACA_visibleClasses", []];
[
    (count _allSyntheticClasses) isEqualTo 100000 &&
    {(lnbSize _syntheticList select 0) isEqualTo 200},
    "100,000-record catalogue retains every match while rendering a bounded page",
    format ["firstRenderSeconds=%1", _firstRenderElapsed]
] call _record;

private _filterTimings = [];
for "_filterRun" from 0 to 9 do {
    (_creatorDisplay displayCtrl 1400) ctrlSetText (
        ["needle", ""] select ((_filterRun mod 2) isEqualTo 1)
    );
    private _filterStarted = diag_tickTime;
    [_creatorDisplay] call RACA_fnc_refreshItemList;
    _filterTimings pushBack (diag_tickTime - _filterStarted);
};
_filterTimings sort true;
private _filterP50 = _filterTimings select 4;
private _filterP95 = _filterTimings select 9;
(_creatorDisplay displayCtrl 1400) ctrlSetText "needle";
[_creatorDisplay] call RACA_fnc_refreshItemList;
private _needleClasses = uiNamespace getVariable ["RACA_visibleClasses", []];
[
    (count _needleClasses) isEqualTo 100 && {_filterP95 < 2},
    "100,000-record settled filters remain complete within the performance budget",
    format ["matches=%1 p50=%2 p95=%3", count _needleClasses, _filterP50, _filterP95]
] call _record;

(_creatorDisplay displayCtrl 1400) ctrlSetText "";
[_creatorDisplay] call RACA_fnc_refreshItemList;
_allSyntheticClasses = uiNamespace getVariable ["RACA_visibleClasses", []];
private _firstIdentity = _allSyntheticClasses select 5;
private _secondIdentity = _allSyntheticClasses select 250;
_creatorDisplay setVariable [
    "RACA_highlighted",
    createHashMapFromArray [[_firstIdentity, true], [_secondIdentity, true]]
];
[_creatorDisplay] call RACA_fnc_refreshItemList;
private _pageZeroSelected = lbSelection _syntheticList apply {
    _syntheticList lnbData [_x, 0]
};
[_creatorDisplay, 1] call RACA_fnc_catalogPage;
private _pageOneSelected = lbSelection _syntheticList apply {
    _syntheticList lnbData [_x, 0]
};
[
    _firstIdentity in _pageZeroSelected &&
    {_secondIdentity in _pageOneSelected} &&
    {(count ([_creatorDisplay] call RACA_fnc_resolveCreatorSelection)) isEqualTo 2},
    "Catalogue highlights remain class-based across result pages"
] call _record;

uiNamespace setVariable ["RACA_itemCatalog", _realCatalog];
uiNamespace setVariable ["RACA_catalogGeneration", _realGeneration];
uiNamespace setVariable ["RACA_catalogIndex", _realIndex];
uiNamespace setVariable ["RACA_catalogSort", _realSort];
uiNamespace setVariable ["RACA_catalogSearchMode", "BASIC"];
_creatorDisplay setVariable ["RACA_highlighted", createHashMap];
_creatorDisplay setVariable ["RACA_resultKey", ""];
(_creatorDisplay displayCtrl 1400) ctrlSetText "";
[_creatorDisplay] call RACA_fnc_refreshSourceCombo;
[_creatorDisplay] call RACA_fnc_refreshItemList;
true
