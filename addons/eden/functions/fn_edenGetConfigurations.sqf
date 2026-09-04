#include "..\script_component.hpp"
/*
 * Returns the mission-local Arsenal Configuration library.
 * Configuration: [id, name, standalonePreset, icon, normalizedAccess].
 */
if (!is3DEN) exitWith {[]};

private _state=call RACA_fnc_edenGetConfigurationState;
if ((_state select 0) isNotEqualTo "READY") exitWith {+(_state select 2)};
+(_state select 2)
