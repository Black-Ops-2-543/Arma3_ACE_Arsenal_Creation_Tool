params [["_authorized", false, [true]]];
if (!hasInterface || {isRemoteExecuted && {remoteExecutedOwner isNotEqualTo 2}} || {!isRemoteExecuted && {!isServer}}) exitWith {false};
missionNamespace setVariable ["RACA_adminAccess", _authorized];
true
