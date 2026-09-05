/* Returns normalized profile-wide catalogue tags sorted by name. */
private _raw = profileNamespace getVariable ["RACA_catalogTags_v1", []];
private _state = profileNamespace getVariable ["RACA_catalogTagState_v2",[]];
if (
    _state isEqualType [] && {(count _state) isEqualTo 6} &&
    {(_state param [0,"",[""]]) isEqualTo "RACA_TAG_STATE"} &&
    {(_state param [1,-1,[0]]) isEqualTo 2} &&
    {(_state param [3,[],[[]]]) isEqualType []}
) then {
    _raw = +(_state select 3);
    uiNamespace setVariable ["RACA_catalogTagRecoveryResult","Loaded the coherent v2 catalogue-tag transaction."];
} else {
    uiNamespace setVariable ["RACA_catalogTagRecoveryResult","Using readable legacy catalogue-tag storage; the next edit will migrate it to bounded delta history."];
};
if !(_raw isEqualType []) exitWith {[]};
private _revision = if (_state isEqualType [] && {(count _state) isEqualTo 6} && {(_state param [1,-1,[0]]) isEqualTo 2}) then {_state select 2} else {profileNamespace getVariable ["RACA_catalogTagsRevision_v1", 0]};
if ((uiNamespace getVariable ["RACA_catalogTagsCacheRevision", -1]) isEqualTo _revision) exitWith {
    +(uiNamespace getVariable ["RACA_catalogTagsCache", []])
};

private _tags = [];
private _seenNames = createHashMap;
{
    if (
        _x isEqualType [] &&
        {(count _x) >= 4} &&
        {(_x param [0, "", [""]]) isEqualTo "RACA_CATALOG_TAG"} &&
        {(_x param [1, -1, [0]]) isEqualTo 1}
    ) then {
        private _name = ((_x param [2, "", [""]]) splitString (toString [9, 10, 13, 32])) joinString " ";
        private _nameKey = toLowerANSI _name;
        private _classes = [];
        private _seenClasses = createHashMap;
        {
            if (_x isEqualType "" && {[_x] call RACA_fnc_isSafeClassName}) then {
                if !(_seenClasses getOrDefault [toLowerANSI _x, false]) then {_seenClasses set [toLowerANSI _x,true]; _classes pushBack _x};
            };
        } forEach (_x param [3, [], [[]]]);
        _classes sort true;
        if (
            _name isNotEqualTo "" &&
            {(count _name) <= 48} &&
            {!(_seenNames getOrDefault [_nameKey,false])}
        ) then {
            _seenNames set [_nameKey,true];
            _tags pushBack ["RACA_CATALOG_TAG", 1, _name, _classes];
        };
    };
} forEach _raw;

private _decorated = _tags apply {[toLowerANSI (_x select 2), _x]};
_decorated sort true;
private _result = _decorated apply {_x select 1};
uiNamespace setVariable ["RACA_catalogTagsCache", _result];
uiNamespace setVariable ["RACA_catalogTagsCacheRevision", _revision];
+_result
