params [["_player", objNull, [objNull]]];

if (isNull _player) exitWith {};
_player allowDamage false;
_player enableSimulation false;

private _catalogObject = "Box_NATO_Equip_F" createVehicleLocal [0, 0, 0];
_catalogObject hideObject true;
_catalogObject enableSimulation false;
