/* Registers the stable CBA settings contract once on every machine. */
if (missionNamespace getVariable ["RACA_settingsRegistered", false]) exitWith {};
missionNamespace setVariable ["RACA_settingsRegistered", true];

private _category = localize "STR_RACA_SETTINGS_CATEGORY";
private _creator = [_category, localize "STR_RACA_SETTINGS_CREATOR"];
private _server = [_category, localize "STR_RACA_SETTINGS_SERVER"];

[
    "RACA_catalogPageSize", "LIST",
    [localize "STR_RACA_SETTING_PAGE_SIZE", localize "STR_RACA_SETTING_PAGE_SIZE_TIP"],
    _creator,
    [[50, 100, 200, 400], [localize "STR_RACA_VALUE_PAGE_50", localize "STR_RACA_VALUE_PAGE_100", localize "STR_RACA_VALUE_PAGE_200", localize "STR_RACA_VALUE_PAGE_400"], 2],
    false,
    {["RACA_catalogPageSize"] call RACA_fnc_dispatchSettingChange}
] call CBA_fnc_addSetting;
[
    "RACA_defaultSearchMode", "LIST",
    [localize "STR_RACA_SETTING_SEARCH_MODE", localize "STR_RACA_SETTING_SEARCH_MODE_TIP"],
    _creator,
    [["BASIC", "ADVANCED"], [localize "STR_RACA_VALUE_BASIC", localize "STR_RACA_VALUE_ADVANCED"], 0],
    false,
    {["RACA_defaultSearchMode"] call RACA_fnc_dispatchSettingChange}
] call CBA_fnc_addSetting;
[
    "RACA_defaultCompatibilitySeverity", "LIST",
    [localize "STR_RACA_SETTING_COMPATIBILITY", localize "STR_RACA_SETTING_COMPATIBILITY_TIP"],
    _creator,
    [["ERRORS", "WARNINGS", "ALL"], [localize "STR_RACA_VALUE_ERRORS", localize "STR_RACA_VALUE_WARNINGS", localize "STR_RACA_VALUE_ALL"], 0],
    false,
    {["RACA_defaultCompatibilitySeverity"] call RACA_fnc_dispatchSettingChange}
] call CBA_fnc_addSetting;
[
    "RACA_openItemDetailsOnSelection", "CHECKBOX",
    [localize "STR_RACA_SETTING_ITEM_DETAILS", localize "STR_RACA_SETTING_ITEM_DETAILS_TIP"],
    _creator, false, false, {["RACA_openItemDetailsOnSelection"] call RACA_fnc_dispatchSettingChange}
] call CBA_fnc_addSetting;
[
    "RACA_draftRecoveryEnabled", "CHECKBOX",
    [localize "STR_RACA_SETTING_DRAFT_RECOVERY", localize "STR_RACA_SETTING_DRAFT_RECOVERY_TIP"],
    _creator, true, false, {["RACA_draftRecoveryEnabled"] call RACA_fnc_dispatchSettingChange}
] call CBA_fnc_addSetting;
[
    "RACA_showOnboardingGuidance", "CHECKBOX",
    [localize "STR_RACA_SETTING_GUIDANCE", localize "STR_RACA_SETTING_GUIDANCE_TIP"],
    _creator, true, false, {["RACA_showOnboardingGuidance"] call RACA_fnc_dispatchSettingChange}
] call CBA_fnc_addSetting;
[
    "RACA_statusVerbosity", "LIST",
    [localize "STR_RACA_SETTING_STATUS", localize "STR_RACA_SETTING_STATUS_TIP"],
    _creator,
    [["CONCISE", "STANDARD", "DETAILED"], [localize "STR_RACA_VALUE_CONCISE", localize "STR_RACA_VALUE_STANDARD", localize "STR_RACA_VALUE_DETAILED"], 1],
    false,
    {["RACA_statusVerbosity"] call RACA_fnc_dispatchSettingChange}
] call CBA_fnc_addSetting;
[
    "RACA_enableZeusModules", "CHECKBOX",
    [localize "STR_RACA_SETTING_ZEUS", localize "STR_RACA_SETTING_ZEUS_TIP"],
    _server, true, true, {["RACA_enableZeusModules"] call RACA_fnc_dispatchSettingChange}
] call CBA_fnc_addSetting;
[
    "RACA_allowZeusProfilePresetFallback", "CHECKBOX",
    [localize "STR_RACA_SETTING_ZEUS_FALLBACK", localize "STR_RACA_SETTING_ZEUS_FALLBACK_TIP"],
    _server, false, true, {["RACA_allowZeusProfilePresetFallback"] call RACA_fnc_dispatchSettingChange}
] call CBA_fnc_addSetting;
