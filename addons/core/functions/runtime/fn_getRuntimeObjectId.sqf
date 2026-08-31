/* Returns the stable server-side identifier used by registry and quota records. */
params [
    ["_object", objNull, [objNull]],
    ["_fallback", "", [""]]
];
if (isNull _object) exitWith {_fallback};

private _objectId = netId _object;
if (_objectId in ["", "0:0"]) then {
    private _variableName = vehicleVarName _object;
    _objectId = if (_variableName isNotEqualTo "") then {format ["var:%1", _variableName]} else {str _object};
};
_objectId
