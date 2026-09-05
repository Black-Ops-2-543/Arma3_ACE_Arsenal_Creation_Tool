/* A batch boundary, not a content-size limit. Never touches persistent data. */
disableSerialization;
params [["_operation", [], [[]]], ["_phase", "", [""]], ["_done", 0, [0]], ["_total", 0, [0]]];
if (_operation isEqualTo []) exitWith {true};
_operation params ["_owner", "_generation", "_dialog", "_id", ["_state", createHashMap, [createHashMap]]];
if (isNull _owner || {isNull _dialog} || {(_owner getVariable ["RACA_generation", -1]) isNotEqualTo _generation} || {(_owner getVariable ["RACA_importId", -1]) isNotEqualTo _id}) exitWith {
    if ((_state getOrDefault ["cancelPhase", ""]) isEqualTo "") then {_state set ["cancelPhase", _phase]};
    false
};
(_dialog displayCtrl 1000) ctrlSetText format ["%1: %2 / %3. Cancel is safe; no library changes have been made.", _phase, _done, _total];
if (canSuspend) then {uiSleep 0.001};
private _active = !isNull _dialog && {!isNull _owner};
if (!_active && {(_state getOrDefault ["cancelPhase", ""]) isEqualTo ""}) then {_state set ["cancelPhase", _phase]};
_active
