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
        {!isNil "RACA_fnc_removePresetFromLibrary"} &&
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
        {!isNil "RACA_fnc_removePresetFromLibrary"} &&
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

    private _environmentEntries = [_catalog, _preset] call RACA_fnc_analyzeEnvironment;
    [
        (_environmentEntries findIf {(_x select 1) isEqualTo "CORE_DEPENDENCIES"}) >= 0 &&
        {(_environmentEntries findIf {(_x select 1) isEqualTo "EDEN_INTEGRATION"}) >= 0} &&
        {(_environmentEntries findIf {(_x select 1) isEqualTo "CATALOG_SCOPE"}) >= 0} &&
        {(_environmentEntries findIf {(_x select 1) isEqualTo "PRESET_SOURCE_SCOPE"}) >= 0},
        "Environment health reports loaded dependencies, Eden integration, catalogue, and preset scope"
    ] call _record;

    private _modManifest = [_preset, _catalog] call RACA_fnc_buildModManifest;
    private _manifestClasses = [];
    { _manifestClasses append (_x select 2) } forEach (_modManifest param [3, []]);
    _manifestClasses sort true;
    [
        (_modManifest param [0, ""]) isEqualTo "RACA_MOD_MANIFEST" &&
        {(_modManifest param [1, 0]) isEqualTo 1} &&
        {_manifestClasses isEqualTo _expectedClasses},
        "Required-mod manifest groups every preset class by loaded source"
    ] call _record;

    private _supportBundle = [_preset, _catalog] call RACA_fnc_buildSupportBundle;
    [
        (_supportBundle param [0, ""]) isEqualTo "RACA_SUPPORT_BUNDLE" &&
        {((_supportBundle param [3, []]) param [0, ""]) isEqualTo "RACA_MOD_MANIFEST"} &&
        {((_supportBundle param [5, []]) param [0, ""]) isEqualTo "RACA_PORTABLE_PRESET"},
        "Support bundle embeds environment diagnostics, required mods, and the portable preset"
    ] call _record;

    private _roleTemplates = call RACA_fnc_getRoleTemplates;
    [
        (count _roleTemplates) >= 10 &&
        {(_roleTemplates findIf {(_x select 0) isEqualTo "rifleman"}) >= 0} &&
        {(_roleTemplates findIf {(_x select 0) isEqualTo "medic"}) >= 0},
        "Built-in role templates expose the expected mission-maker starters"
    ] call _record;

    private _parameterCatalog = [
        ["Test Optic", "optic_Aco", "Attachments", 2, "Arma 3", "Bohemia Interactive", "", "test optic sight", "A3_Weapons_F"],
        ["Test NVG", "NVGoggles", "NVGs", 0, "Arma 3", "Bohemia Interactive", "", "test nvg", "A3_Characters_F"],
        ["Test Medical", "FirstAidKit", "Equipment", 0, "Arma 3", "Bohemia Interactive", "", "test first aid kit medical", "A3_Characters_F"]
    ];
    ([_parameterCatalog, createHashMap, "ADD", "DEFAULT", "ADD", "BASIC"] call RACA_fnc_applyTemplateParameters) params ["_parameterSelection", "_parameterNotices", "_parameterActions"];
    [
        _parameterSelection getOrDefault ["optic_Aco", false] &&
        {_parameterSelection getOrDefault ["NVGoggles", false]} &&
        {_parameterSelection getOrDefault ["FirstAidKit", false]} &&
        {(count _parameterActions) isEqualTo 3},
        "Parameterized templates apply optic, night-vision, and medical policies"
    ] call _record;

    private _nextRevisionPreset = [_preset, "Autotest revision", _catalog] call RACA_fnc_setPresetRevision;
    private _nextRuntime = [_nextRevisionPreset] call RACA_fnc_getRuntimePolicy;
    [
        (_nextRuntime select 3) isEqualTo "Autotest revision" &&
        {(_nextRuntime select 4) isEqualTo 2} &&
        {(count (_nextRuntime select 7)) isEqualTo count _expectedClasses},
        "Preset revisions advance monotonically and retain source requirements"
    ] call _record;

    private _wasAcceptanceHistoryMissing = isNil {profileNamespace getVariable "RACA_presetHistory_v1"};
    private _oldAcceptanceHistory = profileNamespace getVariable ["RACA_presetHistory_v1", []];
    profileNamespace setVariable ["RACA_presetHistory_v1", []];
    private _archivedRevision = [_preset, "Autotest revision archive"] call RACA_fnc_archivePreset;
    private _acceptanceHistory = [_preset select 2] call RACA_fnc_getPresetHistory;
    [
        _archivedRevision &&
        {_acceptanceHistory isNotEqualTo []} &&
        {((_acceptanceHistory select 0) param [7, ""]) isEqualTo "Autotest revision archive"},
        "Revision history archives and retrieves immutable preset snapshots"
    ] call _record;
    if (_wasAcceptanceHistoryMissing) then {profileNamespace setVariable ["RACA_presetHistory_v1", nil]} else {profileNamespace setVariable ["RACA_presetHistory_v1", _oldAcceptanceHistory]};
    saveProfileNamespace;

    private _wasRolePacksMissing = isNil {profileNamespace getVariable "RACA_rolePacks_v1"};
    private _oldRolePacks = profileNamespace getVariable ["RACA_rolePacks_v1", []];
    profileNamespace setVariable ["RACA_rolePacks_v1", [
        ["RACA_ROLE_PACK", 1, "Autotest Pack", "Disposable acceptance pack", ["arifle_MX_F"]],
        ["RACA_ROLE_PACK", 1, "Unsafe Pack", "Rejected", ["bad;call"]]
    ]];
    private _normalizedRolePacks = call RACA_fnc_getRolePacks;
    [
        (count _normalizedRolePacks) isEqualTo 1 &&
        {((_normalizedRolePacks select 0) select 2) isEqualTo "Autotest Pack"},
        "Custom role packs reject unsafe classes and normalize valid unit doctrine"
    ] call _record;
    if (_wasRolePacksMissing) then {profileNamespace setVariable ["RACA_rolePacks_v1", nil]} else {profileNamespace setVariable ["RACA_rolePacks_v1", _oldRolePacks]};

    private _wasViewsMissing = isNil {profileNamespace getVariable "RACA_savedCatalogViews_v1"};
    private _oldViews = profileNamespace getVariable ["RACA_savedCatalogViews_v1", []];
    profileNamespace setVariable ["RACA_savedCatalogViews_v1", [
        ["RACA_CATALOG_VIEW", 2, "Autotest View", "mx", "Weapons", "Arma 3", "A3_Weapons_F", "Bohemia Interactive", "unit", "class", true],
        ["RACA_CATALOG_VIEW", 2, "Autotest View", "duplicate", "All", "", "", "", "", "item", true]
    ]];
    private _normalizedViews = call RACA_fnc_getSavedCatalogViews;
    [
        (count _normalizedViews) isEqualTo 1 &&
        {((_normalizedViews select 0) select 8) isEqualTo "unit"} &&
        {((_normalizedViews select 0) select 9) isEqualTo "class"},
        "Saved catalogue views retain advanced filters and reject duplicate names"
    ] call _record;
    if (_wasViewsMissing) then {profileNamespace setVariable ["RACA_savedCatalogViews_v1", nil]} else {profileNamespace setVariable ["RACA_savedCatalogViews_v1", _oldViews]};

    private _wasTagsMissing = isNil {profileNamespace getVariable "RACA_catalogTags_v1"};
    private _oldTags = profileNamespace getVariable ["RACA_catalogTags_v1", []];
    profileNamespace setVariable ["RACA_catalogTags_v1", [["RACA_CATALOG_TAG", 1, "Unit Gear", ["arifle_MX_F", "bad;call", "arifle_MX_F"]]]];
    private _normalizedTags = call RACA_fnc_getCatalogTags;
    [
        (count _normalizedTags) isEqualTo 1 &&
        {((_normalizedTags select 0) select 3) isEqualTo ["arifle_MX_F"]},
        "Catalogue tags persist only safe, unique class names"
    ] call _record;
    if (_wasTagsMissing) then {profileNamespace setVariable ["RACA_catalogTags_v1", nil]} else {profileNamespace setVariable ["RACA_catalogTags_v1", _oldTags]};
    saveProfileNamespace;

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

    private _matchingAccess = [
        "RACA_ACCESS",
        1,
        "AND",
        [["side", str (side group player)], ["unit", typeOf player]],
        false,
        "Autotest access denied.",
        []
    ];
    private _deniedAccess = [
        "RACA_ACCESS",
        1,
        "OR",
        [["side", "EAST"], ["unit", "O_Soldier_F"]],
        false,
        "Autotest access denied.",
        []
    ];
    ([_matchingAccess] call RACA_fnc_normalizeAccess) params ["", "", "", "_normalizedConditions"];
    ([player, _matchingAccess] call RACA_fnc_evaluateAccess) params ["_accessAllowed"];
    ([player, _deniedAccess] call RACA_fnc_evaluateAccess) params ["_accessDenied", "_accessReason"];
    [
        (count _normalizedConditions) isEqualTo 2 &&
        {_accessAllowed} &&
        {!_accessDenied} &&
        {_accessReason isEqualTo "Autotest access denied."},
        "Access policies normalize and evaluate AND, OR, and denial-message semantics",
        format [
            "conditions=%1 allowed=%2 deniedResult=%3 reason='%4' side=%5 unit=%6",
            count _normalizedConditions,
            _accessAllowed,
            _accessDenied,
            _accessReason,
            str (side group player),
            typeOf player
        ]
    ] call _record;

    private _missingClass = "RACA_Missing_Class_Autotest";
    private _missingPreset = [
        "RACA_PRESET",
        1,
        "Missing Content Acceptance",
        [["arifle_MX_F", _missingClass], [], [], []],
        ["RACA_RUNTIME", 1, [], "", 0, "", [], [[_missingClass, "Missing Test Mod", "raca_missing_test"]]]
    ];
    ([_missingPreset] call RACA_fnc_validatePreset) params ["_validatedMissingPreset", "_missingNotices"];
    private _missingSlot = ["missing", "Missing Content", _validatedMissingPreset, true, _access, [], "", false];
    private _missingConfig = ["RACA_OBJECT_CONFIG", 1, [_missingSlot], []];
    ([_missingConfig, _catalog] call RACA_fnc_preflightObjectConfig) params ["_missingCanApply", "_normalizedMissingConfig", "_missingEntries"];
    [
        _validatedMissingPreset isNotEqualTo [] &&
        {_missingClass in ([_validatedMissingPreset] call RACA_fnc_flattenPresetClasses)} &&
        {_missingCanApply} &&
        {_normalizedMissingConfig isNotEqualTo []} &&
        {(_missingEntries findIf {(_x select 1) isEqualTo "MISSING_REQUIRED" && {(_x select 0) isEqualTo "WARNING"}}) >= 0},
        "Missing content remains portable while object preflight degrades it to an explicit runtime warning",
        format ["validationNotices=%1", count _missingNotices]
    ] call _record;

    private _distanceBox = createVehicle ["Box_NATO_Ammo_F", player modelToWorld [100, 0, 0], [], 0, "CAN_COLLIDE"];
    private _sessionsBeforeDistance = count keys (missionNamespace getVariable ["RACA_openSessions", createHashMap]);
    private _distanceDenied = [_distanceBox, player, "autotest"] call RACA_fnc_requestOpen;
    private _sessionsAfterDistance = count keys (missionNamespace getVariable ["RACA_openSessions", createHashMap]);
    [
        !_distanceDenied && {_sessionsAfterDistance isEqualTo _sessionsBeforeDistance},
        "Server denies a distant arsenal request without creating a session"
    ] call _record;
    deleteVehicle _distanceBox;

    private _exhaustedBox = createVehicle ["Box_NATO_Ammo_F", player modelToWorld [2, 0, 0], [], 0, "CAN_COLLIDE"];
    private _exhaustedPreset = ["RACA_PRESET", 1, "Exhausted Acceptance", [["arifle_MX_F"], [], [], []]];
    private _exhaustedSlot = [
        "exhausted",
        "Exhausted Acceptance",
        _exhaustedPreset,
        true,
        _access,
        [["arifle_MX_F", 0, "player", "never"], ["category:Weapons", 0, "mission", "never"]],
        "",
        false
    ];
    private _exhaustedConfig = ["RACA_OBJECT_CONFIG", 1, [_exhaustedSlot], []];
    private _exhaustedApplied = [_exhaustedBox, _exhaustedConfig] call RACA_fnc_applyObjectConfig;
    private _sessionsBeforeExhausted = count keys (missionNamespace getVariable ["RACA_openSessions", createHashMap]);
    private _exhaustedOpened = [_exhaustedBox, player, "exhausted"] call RACA_fnc_requestOpen;
    private _sessionsAfterExhausted = count keys (missionNamespace getVariable ["RACA_openSessions", createHashMap]);
    [
        _exhaustedApplied && {!_exhaustedOpened} && {_sessionsAfterExhausted isEqualTo _sessionsBeforeExhausted},
        "Exhausted exact and category policies remove the final class and refuse an empty session"
    ] call _record;
    [_exhaustedBox] call RACA_fnc_unregisterObject;
    [_exhaustedBox, []] remoteExecCall ["RACA_fnc_registerActions", 0, _exhaustedBox];
    deleteVehicle _exhaustedBox;

    private _oldAdminUIDs = missionNamespace getVariable ["RACA_adminUIDs", []];
    missionNamespace setVariable ["RACA_adminUIDs", [getPlayerUID player]];
    private _whitelistedAdmin = [player] call RACA_fnc_isAdminAuthorized;
    private _nonAdminUnit = createAgent ["B_Soldier_F", player modelToWorld [4, 0, 0], [], 0, "CAN_COLLIDE"];
    missionNamespace setVariable ["RACA_adminUIDs", ["__raca_no_matching_uid__"]];
    private _unlistedDenied = !([_nonAdminUnit] call RACA_fnc_isAdminAuthorized);
    missionNamespace setVariable ["RACA_adminUIDs", _oldAdminUIDs];
    [_whitelistedAdmin && {_unlistedDenied}, "Administration authorization accepts an allowlisted UID and rejects an unlisted unit"] call _record;
    deleteVehicle _nonAdminUnit;

    private _cleanupBox = createVehicle ["Box_NATO_Ammo_F", player modelToWorld [6, 0, 0], [], 0, "CAN_COLLIDE"];
    private _cleanupApplied = [_cleanupBox, _normalizedConfig] call RACA_fnc_applyObjectConfig;
    private _cleanupObjectId = [_cleanupBox] call RACA_fnc_getRuntimeObjectId;
    private _cleanupSessionId = "raca_autotest_unregister_cleanup";
    private _cleanupSessions = missionNamespace getVariable ["RACA_openSessions", createHashMap];
    _cleanupSessions set [_cleanupSessionId, [_cleanupBox, player, _slot, getUnitLoadout player, owner player, diag_tickTime]];
    missionNamespace setVariable ["RACA_openSessions", _cleanupSessions];
    private _cleanupQuotaKey = format ["%1|autotest|mission|arifle_MX_F", _cleanupObjectId];
    private _cleanupQuota = missionNamespace getVariable ["RACA_quotaState", createHashMap];
    _cleanupQuota set [_cleanupQuotaKey, [1, "mission", "never", _cleanupObjectId, "autotest", getPlayerUID player, "arifle_MX_F"]];
    missionNamespace setVariable ["RACA_quotaState", _cleanupQuota];
    private _cleanupUnregistered = [_cleanupBox] call RACA_fnc_unregisterObject;
    uiSleep 0.1;
    private _cleanupRegistry = call RACA_fnc_getMissionRegistry;
    private _sessionsAfterCleanup = missionNamespace getVariable ["RACA_openSessions", createHashMap];
    private _quotaAfterCleanup = missionNamespace getVariable ["RACA_quotaState", createHashMap];
    [
        _cleanupApplied &&
        {_cleanupUnregistered} &&
        {!(_cleanupSessionId in keys _sessionsAfterCleanup)} &&
        {!(_cleanupQuotaKey in keys _quotaAfterCleanup)} &&
        {(_cleanupRegistry findIf {(_x param [4, ""]) isEqualTo _cleanupObjectId}) < 0},
        "Unregistering an arsenal atomically cancels sessions and prunes registry and quota state"
    ] call _record;
    [_cleanupBox, []] remoteExecCall ["RACA_fnc_registerActions", 0, _cleanupBox];
    deleteVehicle _cleanupBox;

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
    private _quickStartDisplay = if (isNull _creatorDisplay) then {displayNull} else {[_creatorDisplay] call RACA_fnc_openQuickStart};
    uiSleep 0.1;
    [!isNull _quickStartDisplay && {!isNull findDisplay 904110}, "Quick Start opens as a live guided Creator workflow"] call _record;
    if (!isNull _quickStartDisplay) then {_quickStartDisplay closeDisplay 2};

    private _creatorList = if (isNull _creatorDisplay) then {controlNull} else {_creatorDisplay displayCtrl 1500};
    private _weaponRow = -1;
    if (!isNull _creatorList) then {
        for "_row" from 0 to (((lnbSize _creatorList) select 0) - 1) do {
            if ((_creatorList lnbData [_row, 0]) isEqualTo "arifle_MX_F") exitWith {_weaponRow = _row};
        };
    };
    if (_weaponRow >= 0) then {_creatorList lnbSetCurSelRow _weaponRow};
    private _detailsOpened = _weaponRow >= 0 && {[_creatorDisplay] call RACA_fnc_openItemDetails};
    uiSleep 0.1;
    private _detailsDisplay = findDisplay 904160;
    [
        _detailsOpened &&
        {!isNull _detailsDisplay} &&
        {(uiNamespace getVariable ["RACA_itemDetailsClass", ""]) isEqualTo "arifle_MX_F"},
        "Item details opens for the selected catalogue class"
    ] call _record;
    if (!isNull _detailsDisplay) then {_detailsDisplay closeDisplay 2};

    private _rolePacksOpened = [_creatorDisplay] call RACA_fnc_openRolePacks;
    uiSleep 0.1;
    private _rolePacksDisplay = findDisplay 904170;
    [_rolePacksOpened && {!isNull _rolePacksDisplay}, "Custom role-pack manager opens inside the live Creator"] call _record;
    if (!isNull _rolePacksDisplay) then {_rolePacksDisplay closeDisplay 2};

    private _viewsOpened = [_creatorDisplay] call RACA_fnc_openSavedCatalogViews;
    uiSleep 0.1;
    private _viewsDisplay = findDisplay 904150;
    [_viewsOpened && {!isNull _viewsDisplay}, "Saved catalogue-view manager opens inside the live Creator"] call _record;
    if (!isNull _viewsDisplay) then {_viewsDisplay closeDisplay 2};

    if (_weaponRow >= 0) then {_creatorList lnbSetCurSelRow _weaponRow};
    private _tagsOpened = [_creatorDisplay] call RACA_fnc_openCatalogTags;
    uiSleep 0.1;
    private _tagsDisplay = findDisplay 904190;
    [
        _tagsOpened &&
        {!isNull _tagsDisplay} &&
        {"arifle_MX_F" in (uiNamespace getVariable ["RACA_catalogTagsSelection", []])},
        "Catalogue-tag manager opens with the current row selection"
    ] call _record;
    if (!isNull _tagsDisplay) then {_tagsDisplay closeDisplay 2};

    private _wasFavoritesMissing = isNil {profileNamespace getVariable "RACA_favoriteClasses_v1"};
    private _oldFavoriteClasses = profileNamespace getVariable ["RACA_favoriteClasses_v1", []];
    private _oldFavoritesMap = uiNamespace getVariable ["RACA_catalogFavorites", createHashMap];
    uiNamespace setVariable ["RACA_catalogFavorites", createHashMap];
    profileNamespace setVariable ["RACA_favoriteClasses_v1", []];
    [_creatorDisplay] call RACA_fnc_refreshItemList;
    _creatorList = _creatorDisplay displayCtrl 1500;
    _weaponRow = -1;
    for "_row" from 0 to (((lnbSize _creatorList) select 0) - 1) do {
        if ((_creatorList lnbData [_row, 0]) isEqualTo "arifle_MX_F") exitWith {_weaponRow = _row};
    };
    if (_weaponRow >= 0) then {_creatorList lnbSetCurSelRow _weaponRow};
    private _favoriteAdded = _weaponRow >= 0 && {[_creatorDisplay] call RACA_fnc_toggleFavorite};
    private _storedFavoritesAfterAdd = profileNamespace getVariable ["RACA_favoriteClasses_v1", []];
    private _favoriteRemoved = [_creatorDisplay] call RACA_fnc_toggleFavorite;
    private _storedFavoritesAfterRemove = profileNamespace getVariable ["RACA_favoriteClasses_v1", []];
    [
        _favoriteAdded &&
        {"arifle_MX_F" in _storedFavoritesAfterAdd} &&
        {_favoriteRemoved} &&
        {!("arifle_MX_F" in _storedFavoritesAfterRemove)},
        "Favorites add and remove the selected class through profile persistence"
    ] call _record;
    uiNamespace setVariable ["RACA_catalogFavorites", _oldFavoritesMap];
    if (_wasFavoritesMissing) then {profileNamespace setVariable ["RACA_favoriteClasses_v1", nil]} else {profileNamespace setVariable ["RACA_favoriteClasses_v1", _oldFavoriteClasses]};
    saveProfileNamespace;

    private _oldSelectedKeys = keys (uiNamespace getVariable ["RACA_builderSelected", createHashMap]);
    private _oldInheritedKeys = keys (uiNamespace getVariable ["RACA_builderInherited", createHashMap]);
    private _oldLimitRecords = [];
    private _currentLimitMap = uiNamespace getVariable ["RACA_builderLimits", createHashMap];
    {_oldLimitRecords pushBack +(_currentLimitMap get _x)} forEach keys _currentLimitMap;
    private _oldComposition = +(uiNamespace getVariable ["RACA_builderComposition", []]);
    private _oldUndo = +(uiNamespace getVariable ["RACA_creatorUndo", []]);
    private _oldRedo = +(uiNamespace getVariable ["RACA_creatorRedo", []]);
    uiNamespace setVariable ["RACA_builderSelected", createHashMap];
    uiNamespace setVariable ["RACA_builderInherited", createHashMap];
    uiNamespace setVariable ["RACA_builderLimits", createHashMap];
    uiNamespace setVariable ["RACA_builderComposition", []];
    uiNamespace setVariable ["RACA_creatorUndo", []];
    uiNamespace setVariable ["RACA_creatorRedo", []];
    private _historyPushed = [_creatorDisplay] call RACA_fnc_pushCreatorHistory;
    private _changedSelection = uiNamespace getVariable ["RACA_builderSelected", createHashMap];
    _changedSelection set ["arifle_MX_F", true];
    private _undone = [_creatorDisplay, "UNDO"] call RACA_fnc_restoreCreatorHistory;
    private _absentAfterUndo = !((uiNamespace getVariable ["RACA_builderSelected", createHashMap]) getOrDefault ["arifle_MX_F", false]);
    private _redone = [_creatorDisplay, "REDO"] call RACA_fnc_restoreCreatorHistory;
    private _presentAfterRedo = (uiNamespace getVariable ["RACA_builderSelected", createHashMap]) getOrDefault ["arifle_MX_F", false];
    [_historyPushed && {_undone} && {_absentAfterUndo} && {_redone} && {_presentAfterRedo}, "Creator selection changes support live undo and redo"] call _record;
    private _restoredSelected = createHashMap;
    {_restoredSelected set [_x, true]} forEach _oldSelectedKeys;
    private _restoredInherited = createHashMap;
    {_restoredInherited set [_x, true]} forEach _oldInheritedKeys;
    private _restoredLimits = createHashMap;
    {_restoredLimits set [_x select 0, +_x]} forEach _oldLimitRecords;
    uiNamespace setVariable ["RACA_builderSelected", _restoredSelected];
    uiNamespace setVariable ["RACA_builderInherited", _restoredInherited];
    uiNamespace setVariable ["RACA_builderLimits", _restoredLimits];
    uiNamespace setVariable ["RACA_builderComposition", _oldComposition];
    uiNamespace setVariable ["RACA_creatorUndo", _oldUndo];
    uiNamespace setVariable ["RACA_creatorRedo", _oldRedo];
    [_creatorDisplay] call RACA_fnc_refreshItemList;
    private _wasLibraryMissing = isNil {profileNamespace getVariable "RACA_presetLibrary_v1"};
    private _oldLibrary = profileNamespace getVariable ["RACA_presetLibrary_v1", []];
    private _wasHistoryMissing = isNil {profileNamespace getVariable "RACA_presetHistory_v1"};
    private _oldHistory = profileNamespace getVariable ["RACA_presetHistory_v1", []];
    private _disposableName = format ["RACA Autotest Delete %1", diag_tickTime];
    private _disposablePreset = [
        "RACA_PRESET",
        1,
        _disposableName,
        [["arifle_MX_F"], [], [], []],
        ["RACA_RUNTIME", 1, [], "", 0, "", [], []]
    ];
    profileNamespace setVariable ["RACA_presetLibrary_v1", [_disposablePreset]];
    profileNamespace setVariable ["RACA_presetHistory_v1", []];
    private _deletedDisposable = [_disposablePreset] call RACA_fnc_removePresetFromLibrary;
    private _libraryAfterDelete = profileNamespace getVariable ["RACA_presetLibrary_v1", []];
    private _historyAfterDelete = [_disposableName] call RACA_fnc_getPresetHistory;
    [
        _deletedDisposable &&
        {_libraryAfterDelete isEqualTo []} &&
        {_historyAfterDelete isNotEqualTo []} &&
        {((_historyAfterDelete select 0) param [7, ""]) isEqualTo "Deleted from profile library"},
        "Confirmed preset deletion archives and removes a disposable profile preset"
    ] call _record;
    if (_wasLibraryMissing) then {profileNamespace setVariable ["RACA_presetLibrary_v1", nil]} else {profileNamespace setVariable ["RACA_presetLibrary_v1", _oldLibrary]};
    if (_wasHistoryMissing) then {profileNamespace setVariable ["RACA_presetHistory_v1", nil]} else {profileNamespace setVariable ["RACA_presetHistory_v1", _oldHistory]};
    saveProfileNamespace;
    [_creatorDisplay] call RACA_fnc_refreshPresetCombo;
    private _preflightOpened = if (isNull _creatorDisplay) then {false} else {[_creatorDisplay] call RACA_fnc_openCreatorDiagnostics};
    uiSleep 0.5;
    private _preflightDisplay = findDisplay 904140;
    private _preflightSummaryControl = if (isNull _preflightDisplay) then {controlNull} else {_preflightDisplay displayCtrl 1030};
    private _preflightListControl = if (isNull _preflightDisplay) then {controlNull} else {_preflightDisplay displayCtrl 1530};
    [
        _preflightOpened &&
        {!isNull _preflightDisplay} &&
        {!isNull _preflightSummaryControl} &&
        {(ctrlText _preflightSummaryControl) find "PASSED" >= 0} &&
        {!isNull _preflightListControl} &&
        {((lnbSize _preflightListControl) select 0) > 0},
        "Compatibility details render a completed report without a UI script error"
    ] call _record;
    if (!isNull _preflightDisplay) then {_preflightDisplay closeDisplay 2};
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
