#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};

private _classes = [_display] call RACA_fnc_resolveCreatorSelection;
uiNamespace setVariable ["RACA_catalogTagsParent", _display];
uiNamespace setVariable ["RACA_catalogTagsSelection", _classes];
private _tagsDisplay = _display createDisplay "RACA_RscDisplayCatalogTags";
if (isNull _tagsDisplay) exitWith {
    [_display, "The catalogue tag manager could not be opened."] call RACA_fnc_setStatus;
    false
};
true
