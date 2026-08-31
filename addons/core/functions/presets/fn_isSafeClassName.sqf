/*
 * Config class names are identifiers. Keeping imported values to that shape
 * prevents control characters and script-like text from entering the library,
 * even though the JSON import path never compiles its input.
 */
params [["_className", "", [""]]];

private _characters = toArray _className;
if (_characters isEqualTo [] || {(count _characters) > 256}) exitWith {false};

({
    !(
        (_x >= 48 && {_x <= 57}) ||
        {_x >= 65 && {_x <= 90}} ||
        {_x isEqualTo 95} ||
        {_x >= 97 && {_x <= 122}}
    )
} count _characters) isEqualTo 0
