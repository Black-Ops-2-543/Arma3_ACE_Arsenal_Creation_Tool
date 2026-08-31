params [["_scope", "personal", [""]]];
if (toLowerANSI _scope isEqualTo "personal") then {
    private _saved = profileNamespace getVariable ["RACA_playerLoadouts_v1", []];
    if !(_saved isEqualType []) then {_saved = []};
    +(_saved select {_x isEqualType [] && {(_x param [0, ""]) isEqualTo "RACA_LOADOUT"} && {(_x param [1, -1]) isEqualTo 1}})
} else {
    []
}
