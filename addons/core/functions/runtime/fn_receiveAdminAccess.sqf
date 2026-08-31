params [["_authorized", false, [true]]];
if (!hasInterface || {!isRemoteExecuted} || {remoteExecutedOwner isNotEqualTo 2}) exitWith {false};
missionNamespace setVariable ["RACA_adminAccess", _authorized];
true
