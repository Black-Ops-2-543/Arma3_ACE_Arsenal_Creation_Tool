params [["_display", displayNull, [displayNull]]];

if ((uiNamespace getVariable ["RACA_builderDisplay", displayNull]) isEqualTo _display) then {
    uiNamespace setVariable ["RACA_builderDisplay", displayNull];
};
uiNamespace setVariable ["RACA_filterRevision", (uiNamespace getVariable ["RACA_filterRevision", 0]) + 1];
