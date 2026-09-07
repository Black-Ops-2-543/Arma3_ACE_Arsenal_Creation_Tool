params [["_id","",[""]],["_message","",[""]],["_accepted",false,[true]],["_result",[],[[]]]];
missionNamespace setVariable ["RACA_lastZeusResult",[_id,_message,_accepted,diag_tickTime,_result]];
if (hasInterface) then {systemChat format ["RACA Zeus %1: %2",_id,_message]; hintSilent format ["RACA Zeus\n%1",_message]};
true
