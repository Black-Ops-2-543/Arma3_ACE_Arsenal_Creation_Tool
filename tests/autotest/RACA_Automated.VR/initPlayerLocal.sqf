params ["_player"];

[] spawn {
    private _results = [];
    private _record = {
        params [
            ["_passed", false, [true]],
            ["_name", "Unnamed assertion", [""]],
            ["_details", "", [""]]
        ];
        _results pushBack [_passed, _name, _details];
        diag_log format [
            "[RACA AUTOTEST] %1 | %2%3",
            ["FAIL", "PASS"] select _passed,
            _name,
            ["", format [" | %1", _details]] select (_details isNotEqualTo "")
        ];
    };
    private _finish = {
        private _failed = { !(_x select 0) } count _results;
        private _passed = (count _results) - _failed;
        diag_log format ["[RACA AUTOTEST] SUMMARY | passed=%1 failed=%2 total=%3", _passed, _failed, count _results];
        missionNamespace setVariable ["RACA_AutotestResults", +_results];
        uiSleep 0.5;
        endMission (["LOSER", "END1"] select (_failed isEqualTo 0));
    };

    diag_log "[RACA AUTOTEST] BEGIN";
    private _deadline = diag_tickTime + 30;
    waitUntil {
        uiSleep 0.05;
        (!isNil "RACA_fnc_validatePreset" &&
        {!isNil "RACA_fnc_preflightObjectConfig"} &&
        {!isNil "RACA_fnc_deletePreset"} &&
        {!isNil "RACA_fnc_edenEditorApply"} &&
        {!isNil "RACA_fnc_moduleAssign"} &&
        {!isNil "RACA_fnc_moduleClear"} &&
        {!isNil "RACA_fnc_moduleToggle"} &&
        {!isNil "RACA_fnc_moduleResetQuotas"} &&
        {!isNil "ace_arsenal_fnc_initBox"}) ||
        {diag_tickTime >= _deadline}
    };

    private _functionsReady =
        !isNil "RACA_fnc_validatePreset" &&
        {!isNil "RACA_fnc_preflightObjectConfig"} &&
        {!isNil "RACA_fnc_deletePreset"} &&
        {!isNil "RACA_fnc_edenEditorApply"} &&
        {!isNil "RACA_fnc_moduleAssign"} &&
        {!isNil "RACA_fnc_moduleClear"} &&
        {!isNil "RACA_fnc_moduleToggle"} &&
        {!isNil "RACA_fnc_moduleResetQuotas"} &&
        {!isNil "ace_arsenal_fnc_initBox"};
    [_functionsReady, "Core, Eden, and ACE functions initialize", "Required packaged functions must exist before acceptance begins."] call _record;
    if (!_functionsReady) exitWith {call _finish};

    [isClass (configFile >> "CfgPatches" >> "RACA_Core"), "RACA Core patch is registered"] call _record;
    [isClass (configFile >> "CfgPatches" >> "RACA_Eden"), "RACA Eden patch is registered"] call _record;
    [isClass (configFile >> "CfgMissions" >> "Tutorial" >> "RACA_Creator"), "Creator is registered under Tutorials"] call _record;
    [
        getText (configFile >> "CfgMissions" >> "Tutorial" >> "RACA_Creator" >> "directory") isEqualTo "\x\raca\addons\core\missions\Creator.VR",
        "Creator mission directory resolves to the packaged PBO prefix"
    ] call _record;
    [isClass (configFile >> "RACA_RscDisplayCreator"), "Creator display class is registered"] call _record;
    [isClass (configFile >> "Cfg3DEN" >> "Attributes" >> "RACA_PresetAttribute"), "Eden preset attribute control is registered"] call _record;
    [
        isClass (configFile >> "Cfg3DEN" >> "Object" >> "AttributeCategories" >> "RACA_RestrictedArsenals" >> "Attributes" >> "RACA_Preset"),
        "Eden object attribute is registered"
    ] call _record;
    private _zeusModuleClasses = ["RACA_ModuleAssign", "RACA_ModuleClear", "RACA_ModuleToggle", "RACA_ModuleResetQuotas"];
    [
        ({isClass (configFile >> "CfgVehicles" >> _x)} count _zeusModuleClasses) isEqualTo count _zeusModuleClasses,
        "All Zeus administration modules are registered"
    ] call _record;

    private _catalogObject = "Box_NATO_Equip_F" createVehicleLocal [0, 0, 0];
    _catalogObject hideObject true;
    _catalogObject enableSimulation false;
    [_catalogObject, true, false] call ace_arsenal_fnc_initBox;
    uiNamespace setVariable ["RACA_catalogObject", _catalogObject];
    uiSleep 0.25;
    private _catalog = [displayNull] call RACA_fnc_scanItems;
    uiNamespace setVariable ["RACA_itemCatalog", _catalog];
    [(count _catalog) > 100, "ACE catalogue scan returns loaded equipment", format ["items=%1", count _catalog]] call _record;
    [(_catalog findIf {(_x select 1) isEqualTo "arifle_MX_F"}) >= 0, "Catalogue includes a known vanilla weapon"] call _record;

    private _rawPreset = [
        "RACA_PRESET",
        1,
        "Automated Acceptance",
        [["FirstAidKit", "arifle_MX_F"], [], ["30Rnd_65x39_caseless_mag"], ["B_AssaultPack_mcamo"]],
        [
            "RACA_RUNTIME",
            1,
            [
                ["arifle_MX_F", 2, "player", "respawn"],
                ["category:Weapons", 3, "mission", "round"]
            ],
            "Automated round-trip coverage",
            1,
            "RACA Autotest",
            systemTimeUTC,
            []
        ]
    ];
    ([_rawPreset] call RACA_fnc_validatePreset) params ["_preset", "_presetWarnings"];
    [_preset isNotEqualTo [], "Preset validation accepts known available classes", format ["notices=%1", count _presetWarnings]] call _record;

    private _expectedClasses = ["30Rnd_65x39_caseless_mag", "arifle_MX_F", "B_AssaultPack_mcamo", "FirstAidKit"];
    _expectedClasses sort true;
    private _validatedClasses = [_preset] call RACA_fnc_flattenPresetClasses;
    _validatedClasses sort true;
    [_validatedClasses isEqualTo _expectedClasses, "Preset validation canonicalizes all four cargo buckets"] call _record;

    private _portable = [_preset, _catalog] call RACA_fnc_buildPortablePreset;
    private _json = [_portable] call RACA_fnc_formatPortableJson;
    ([_json] call RACA_fnc_decodePortablePreset) params ["_jsonPreset", "_jsonMetadata", "_jsonWarnings"];
    private _jsonClasses = [_jsonPreset] call RACA_fnc_flattenPresetClasses;
    _jsonClasses sort true;
    [
        _jsonPreset isNotEqualTo [] && {_jsonClasses isEqualTo _expectedClasses},
        "JSON export imports losslessly",
        format ["metadata=%1 notices=%2", count _jsonMetadata, count _jsonWarnings]
    ] call _record;

    private _sqf = [_preset] call RACA_fnc_formatSqfExport;
    ([_sqf, "Automated SQF Import"] call RACA_fnc_decodeSqfPreset) params ["_sqfPreset", "", "_sqfWarnings"];
    private _sqfClasses = [_sqfPreset] call RACA_fnc_flattenPresetClasses;
    _sqfClasses sort true;
    [
        _sqfPreset isNotEqualTo [] && {_sqfClasses isEqualTo _expectedClasses},
        "Reusable SQF export imports without executing source text",
        format ["notices=%1", count _sqfWarnings]
    ] call _record;

    private _classList = _expectedClasses joinString ", ";
    ([_classList, "Automated Class List"] call RACA_fnc_decodeSqfPreset) params ["_listPreset"];
    private _listClasses = [_listPreset] call RACA_fnc_flattenPresetClasses;
    _listClasses sort true;
    [_listPreset isNotEqualTo [] && {_listClasses isEqualTo _expectedClasses}, "Class-list import recovers all available class names"] call _record;

    private _unsafeJson = '["RACA_PORTABLE_PRESET",2,["RACA_PRESET",1,"Unsafe",[["arifle_MX_F;call"],[],[],[]]],[]]';
    ([_unsafeJson] call RACA_fnc_decodePortablePreset) params ["_unsafePreset"];
    [_unsafePreset isEqualTo [], "JSON import rejects unsafe class text"] call _record;

    private _normalizedLimits = [[
        ["arifle_MX_F", 2.9, "interaction", "never"],
        ["category:weapons", 3, "mission", "round"]
    ]] call RACA_fnc_normalizeLimits;
    private _interactionRule = _normalizedLimits select (_normalizedLimits findIf {(_x select 0) isEqualTo "arifle_MX_F"});
    private _categoryRule = _normalizedLimits select (_normalizedLimits findIf {(_x select 0) isEqualTo "category:Weapons"});
    [
        (_interactionRule select 1) isEqualTo 2 && {(_interactionRule select 3) isEqualTo "interaction"} && {_categoryRule isNotEqualTo []},
        "Quantity policies normalize integer limits, interaction reset, and category identifiers"
    ] call _record;

    private _access = ["RACA_ACCESS", 1, "AND", [], false, "Access denied.", []];
    private _limits = [
        ["arifle_MX_F", 2, "player", "respawn"],
        ["category:Weapons", 3, "mission", "round"]
    ];
    private _slot = ["autotest", "Automated Acceptance", _preset, true, _access, _limits, "", false];
    private _objectConfig = [
        "RACA_OBJECT_CONFIG",
        1,
        [_slot],
        [["auditLevel", "standard"], ["persistence", "mission"]]
    ];
    ([_objectConfig, _catalog] call RACA_fnc_preflightObjectConfig) params ["_canApply", "_normalizedConfig", "_preflightEntries", "_preflightSummary"];
    [_canApply && {_normalizedConfig isNotEqualTo []}, "Valid object configuration passes fail-closed preflight", format ["summary=%1", _preflightSummary]] call _record;

    private _longName = "";
    for "_index" from 1 to 129 do {_longName = _longName + "x"};
    private _badConfig = +_objectConfig;
    _badConfig set [2, [
        ["duplicate", _longName, _preset, true, _access, _limits, "", false],
        ["duplicate", "Second", _preset, true, _access, _limits, "", false]
    ]];
    ([_badConfig, _catalog] call RACA_fnc_preflightObjectConfig) params ["_badAllowed", "", "_badEntries"];
    [
        !_badAllowed &&
        {(_badEntries findIf {(_x select 1) isEqualTo "SLOT_NAME_TOO_LONG"}) >= 0} &&
        {(_badEntries findIf {(_x select 1) isEqualTo "DUPLICATE_SLOT_ID"}) >= 0},
        "Malformed object configuration is blocked with specific diagnostics"
    ] call _record;

    private _manifest = [_normalizedConfig] call RACA_fnc_buildActionManifest;
    [
        (_manifest param [0, ""]) isEqualTo "RACA_ACTION_MANIFEST" &&
        {((_manifest select 2 select 0) select 2) isEqualTo []},
        "JIP action manifest strips embedded presets and limits"
    ] call _record;

    private _box = createVehicle ["Box_NATO_Equip_F", [4256, 4195, 0], [], 0, "CAN_COLLIDE"];
    private _applied = [_box, _normalizedConfig] call RACA_fnc_applyObjectConfig;
    uiSleep 0.25;
    private _registry = call RACA_fnc_getMissionRegistry;
    private _objectId = [_box] call RACA_fnc_getRuntimeObjectId;
    private _localActions = missionNamespace getVariable ["RACA_localActionState", createHashMap];
    [
        _applied && {(_registry findIf {(_x param [4, ""]) isEqualTo _objectId}) >= 0},
        "Server applies and registers a restricted-arsenal object"
    ] call _record;
    [(_localActions getOrDefault [netId _box, []]) isNotEqualTo [], "Client receives the redacted ACE action registration"] call _record;

    private _originalLoadout = getUnitLoadout player;
    removeAllWeapons player;
    private _beforeLoadout = getUnitLoadout player;
    private _quotaSlot = +(_normalizedConfig select 2 select 0);
    _quotaSlot set [5, [
        ["arifle_MX_F", 5, "player", "never"],
        ["category:Weapons", 5, "mission", "never"]
    ]];
    private _sessionId = "raca_autotest_combined_quota";
    private _sessions = missionNamespace getVariable ["RACA_openSessions", createHashMap];
    _sessions set [_sessionId, [_box, player, _quotaSlot, _beforeLoadout, owner player, diag_tickTime]];
    missionNamespace setVariable ["RACA_openSessions", _sessions];
    player addWeapon "arifle_MX_F";
    private _sessionAccepted = [_sessionId, player, getUnitLoadout player] call RACA_fnc_finishSession;
    private _quota = missionNamespace getVariable ["RACA_quotaState", createHashMap];
    private _exactCharged = false;
    private _categoryCharged = false;
    {
        private _quotaRecord = _quota get _x;
        if ((_quotaRecord param [6, ""]) isEqualTo "arifle_MX_F" && {(_quotaRecord param [0, 0]) isEqualTo 1}) then {_exactCharged = true};
        if (toLowerANSI (_quotaRecord param [6, ""]) isEqualTo "category:weapons" && {(_quotaRecord param [0, 0]) isEqualTo 1}) then {_categoryCharged = true};
    } forEach keys _quota;
    [_sessionAccepted && {_exactCharged} && {_categoryCharged}, "One issued weapon charges both exact and category quota counters"] call _record;
    player setUnitLoadout _originalLoadout;

    private _zeusTarget = createVehicle ["Box_NATO_Ammo_F", [4259, 4195, 0], [], 0, "CAN_COLLIDE"];
    private _assignLogic = createAgent ["Logic", [4259, 4195, 0], [], 0, "CAN_COLLIDE"];
    _assignLogic setVariable ["RACA_presetName", "Automated Acceptance"];
    _assignLogic setVariable ["RACA_slotName", "Zeus Acceptance"];
    private _zeusAssigned = [_assignLogic, [_zeusTarget], true] call RACA_fnc_moduleAssign;
    uiSleep 0.1;
    private _zeusObjectId = [_zeusTarget] call RACA_fnc_getRuntimeObjectId;
    private _zeusRegistry = call RACA_fnc_getMissionRegistry;
    private _zeusIndex = _zeusRegistry findIf {(_x param [4, ""]) isEqualTo _zeusObjectId};
    private _zeusSlot = if (_zeusIndex < 0) then {[]} else {((_zeusRegistry select _zeusIndex) select 1 select 2) param [0, []]};
    [
        _zeusAssigned && {_zeusSlot isNotEqualTo []} && {(_zeusSlot select 1) isEqualTo "Zeus Acceptance"},
        "Zeus Assign resolves an embedded mission preset and configures a target"
    ] call _record;

    private _toggleLogic = createAgent ["Logic", [4259, 4195, 0], [], 0, "CAN_COLLIDE"];
    _toggleLogic setVariable ["RACA_enable", false];
    private _zeusDisabled = [_toggleLogic, [_zeusTarget], true] call RACA_fnc_moduleToggle;
    uiSleep 0.1;
    _zeusRegistry = call RACA_fnc_getMissionRegistry;
    _zeusIndex = _zeusRegistry findIf {(_x param [4, ""]) isEqualTo _zeusObjectId};
    _zeusSlot = if (_zeusIndex < 0) then {[]} else {((_zeusRegistry select _zeusIndex) select 1 select 2) param [0, []]};
    [
        _zeusDisabled && {_zeusSlot isNotEqualTo []} && {!(_zeusSlot select 3)},
        "Zeus Disable updates the registered target without losing its slot"
    ] call _record;

    private _quotaBeforeReset = count keys (missionNamespace getVariable ["RACA_quotaState", createHashMap]);
    private _resetLogic = createAgent ["Logic", [4256, 4195, 0], [], 0, "CAN_COLLIDE"];
    private _zeusReset = [_resetLogic, [_box], true] call RACA_fnc_moduleResetQuotas;
    private _quotaAfterReset = count keys (missionNamespace getVariable ["RACA_quotaState", createHashMap]);
    [
        _zeusReset && {_quotaBeforeReset > 0} && {_quotaAfterReset < _quotaBeforeReset},
        "Zeus Reset Quotas removes target-scoped quota counters"
    ] call _record;

    private _clearLogic = createAgent ["Logic", [4259, 4195, 0], [], 0, "CAN_COLLIDE"];
    private _zeusCleared = [_clearLogic, [_zeusTarget], true] call RACA_fnc_moduleClear;
    uiSleep 0.1;
    _zeusRegistry = call RACA_fnc_getMissionRegistry;
    [
        _zeusCleared && {(_zeusRegistry findIf {(_x param [4, ""]) isEqualTo _zeusObjectId}) < 0},
        "Zeus Clear removes the target from the mission registry"
    ] call _record;
    deleteVehicle _zeusTarget;

    private _wasOnboardingMissing = isNil {profileNamespace getVariable "RACA_onboardingSeen_v1"};
    private _oldOnboarding = profileNamespace getVariable ["RACA_onboardingSeen_v1", false];
    private _wasRecoveryMissing = isNil {profileNamespace getVariable "RACA_creatorDraftRecovery_v1"};
    private _oldRecovery = profileNamespace getVariable ["RACA_creatorDraftRecovery_v1", []];
    profileNamespace setVariable ["RACA_onboardingSeen_v1", true];
    profileNamespace setVariable ["RACA_creatorDraftRecovery_v1", nil];
    private _missionDisplay = findDisplay 46;
    private _creatorDisplay = if (isNull _missionDisplay) then {displayNull} else {_missionDisplay createDisplay "RACA_RscDisplayCreator"};
    uiSleep 0.75;
    private _deleteControl = if (isNull _creatorDisplay) then {controlNull} else {_creatorDisplay displayCtrl 1616};
    [!isNull _creatorDisplay, "Creator display opens inside the packaged runtime"] call _record;
    [!isNull _deleteControl && {ctrlText _deleteControl isEqualTo "DELETE"}, "Preset deletion control is present in the live Creator"] call _record;
    if (!isNull _creatorDisplay) then {_creatorDisplay closeDisplay 2};
    if (_wasOnboardingMissing) then {profileNamespace setVariable ["RACA_onboardingSeen_v1", nil]} else {profileNamespace setVariable ["RACA_onboardingSeen_v1", _oldOnboarding]};
    if (_wasRecoveryMissing) then {profileNamespace setVariable ["RACA_creatorDraftRecovery_v1", nil]} else {profileNamespace setVariable ["RACA_creatorDraftRecovery_v1", _oldRecovery]};

    [_box] call RACA_fnc_unregisterObject;
    [_box, []] remoteExecCall ["RACA_fnc_registerActions", 0, _box];
    deleteVehicle _box;
    [_catalogObject, true] call ace_arsenal_fnc_removeBox;
    uiNamespace setVariable ["RACA_catalogObject", objNull];
    deleteVehicle _catalogObject;

    call _finish;
};
