/* Highlight identities are independent of inclusion and native row indices. */
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {[]};
keys (_display getVariable ["RACA_highlighted", createHashMap])
