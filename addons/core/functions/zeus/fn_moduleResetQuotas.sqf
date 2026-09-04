params ["_logic","_units","_activated"];
if (!_activated) exitWith {false};
[_logic,"RESET",_units] call RACA_fnc_requestZeusModule
