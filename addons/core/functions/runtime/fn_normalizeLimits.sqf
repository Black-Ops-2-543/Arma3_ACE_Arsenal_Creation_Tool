/* Canonical entry: [className, limit, scope, resetPolicy]. Limit -1 means unlimited. */
params [["_rawLimits", [], [[]]]];

private _normalized = [];
{
    if (_x isEqualType [] && {(count _x) >= 2}) then {
        private _className = _x param [0, "", [""]];
        private _limit = floor (_x param [1, -1, [0]]);
        private _scope = toLowerANSI (_x param [2, "arsenal", [""]]);
        private _reset = toLowerANSI (_x param [3, "never", [""]]);
        private _categoryRule = toLowerANSI _className find "category:" isEqualTo 0;
        private _categoryName = if (_categoryRule) then {toLowerANSI (_className select [9])} else {""};
        private _categoryNames = createHashMapFromArray [
            ["weapons", "Weapons"], ["attachments", "Attachments"], ["magazines", "Magazines"],
            ["uniforms", "Uniforms"], ["vests", "Vests"], ["backpacks", "Backpacks"],
            ["headgear", "Headgear"], ["nvgs", "NVGs"], ["facewear", "Facewear"], ["equipment", "Equipment"]
        ];
        private _categoryValid = _categoryNames getOrDefault [_categoryName, ""] isNotEqualTo "";
        if (([_className] call RACA_fnc_isSafeClassName || {_categoryRule && {_categoryValid}}) && {_limit >= -1}) then {
            if (_categoryRule) then {_className = format ["category:%1", _categoryNames get _categoryName]};
            if !(_scope in ["interaction", "player", "life", "mission", "arsenal"]) then {_scope = "arsenal"};
            if !(_reset in ["never", "respawn", "round", "phase", "interaction"]) then {_reset = "never"};
            if (_scope isEqualTo "interaction") then {_reset = "interaction"};
            private _existing = _normalized findIf {(_x select 0) isEqualTo _className};
            private _entry = [_className, _limit, _scope, _reset];
            if (_existing < 0) then {_normalized pushBack _entry} else {_normalized set [_existing, _entry]};
        };
    };
} forEach _rawLimits;
_normalized sort true;
_normalized
