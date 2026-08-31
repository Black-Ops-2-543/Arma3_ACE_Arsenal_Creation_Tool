uiNamespace setVariable [
    "RACA_draftRecoveryRevision",
    (uiNamespace getVariable ["RACA_draftRecoveryRevision", 0]) + 1
];
profileNamespace setVariable ["RACA_creatorDraftRecovery_v1", nil];
saveProfileNamespace;
true
