params [["_id","",[""]]];
private _length = count _id;
_length >= 1 && {_length <= 64} && {_id isEqualTo toLowerANSI _id} && {(({!(_x isEqualTo 95 || {_x>=48 && {_x<=57}} || {_x>=97 && {_x<=122}})} count toArray _id) isEqualTo 0)}
