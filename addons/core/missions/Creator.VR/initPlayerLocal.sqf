params [["_player", objNull, [objNull]]];

if (isNull _player) exitWith {};
_player allowDamage false;
_player enableSimulation false;

private _catalogObject = "Box_NATO_Equip_F" createVehicleLocal [0, 0, 0];
_catalogObject hideObject true;
_catalogObject enableSimulation false;
[_catalogObject, true, false] call ace_arsenal_fnc_initBox;
uiNamespace setVariable ["RACA_catalogObject", _catalogObject];

waitUntil {
    uiSleep 0.01;
    !isNull findDisplay 46
};

private _creatorDisplay = (findDisplay 46) createDisplay "RACA_RscDisplayCreator";
waitUntil {
    uiSleep 0.05;
    isNull _creatorDisplay
};

uiNamespace setVariable ["RACA_catalogObject", objNull];
deleteVehicle _catalogObject;
endMission "END1";
