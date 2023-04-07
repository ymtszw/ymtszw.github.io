(function (scope) {
    "use strict";
    function F(arity, fun, wrapper) {
        wrapper.a = arity;
        wrapper.f = fun;
        return wrapper;
    }
    function F2(fun) {
        var curried = function (a) {
            return function (b) {
                return fun(a, b);
            };
        };
        curried.a2 = fun;
        return curried;
    }
    function F3(fun) {
        var curried = function (a) {
            return function (b) {
                return function (c) {
                    return fun(a, b, c);
                };
            };
        };
        curried.a3 =
            fun;
        return curried;
    }
    function F4(fun) {
        var curried = function (a) {
            return function (b) {
                return function (c) {
                    return function (d) {
                        return fun(a, b, c, d);
                    };
                };
            };
        };
        curried.a4 = fun;
        return curried;
    }
    function F5(fun) {
        var curried = function (a) {
            return function (b) {
                return function (c) {
                    return function (d) {
                        return function (e) {
                            return fun(a, b, c, d, e);
                        };
                    };
                };
            };
        };
        curried.a5 = fun;
        return curried;
    }
    function F6(fun) {
        var curried = function (a) {
            return function (b) {
                return function (c) {
                    return function (d) {
                        return function (e) {
                            return function (f) {
                                return fun(a, b, c, d, e, f);
                            };
                        };
                    };
                };
            };
        };
        curried.a6 = fun;
        return curried;
    }
    function F7(fun) {
        var curried = function (a) {
            return function (b) {
                return function (c) {
                    return function (d) {
                        return function (e) {
                            return function (f) {
                                return function (g) { return fun(a, b, c, d, e, f, g); };
                            };
                        };
                    };
                };
            };
        };
        curried.
            a7 = fun;
        return curried;
    }
    function F8(fun) {
        var curried = function (a) {
            return function (b) {
                return function (c) {
                    return function (d) {
                        return function (e) {
                            return function (f) {
                                return function (g) {
                                    return function (h) {
                                        return fun(a, b, c, d, e, f, g, h);
                                    };
                                };
                            };
                        };
                    };
                };
            };
        };
        curried.a8 = fun;
        return curried;
    }
    function F9(fun) {
        var curried = function (a) {
            return function (b) {
                return function (c) {
                    return function (d) {
                        return function (e) {
                            return function (f) {
                                return function (g) {
                                    return function (h) {
                                        return function (i) {
                                            return fun(a, b, c, d, e, f, g, h, i);
                                        };
                                    };
                                };
                            };
                        };
                    };
                };
            };
        };
        curried
            .a9 = fun;
        return curried;
    }
    function A2(fun, a, b) {
        return fun.a2 ? fun.a2(a, b) : fun(a)(b);
    }
    function A3(fun, a, b, c) {
        return fun.a3 ? fun.a3(a, b, c) : fun(a)(b)(c);
    }
    function A4(fun, a, b, c, d) {
        return fun.a4 ? fun.a4(a, b, c, d) : fun(a)(b)(c)(d);
    }
    function A5(fun, a, b, c, d, e) {
        return fun.a5 ? fun.a5(a, b, c, d, e)
            : fun(a)(b)(c)(d)(e);
    }
    function A6(fun, a, b, c, d, e, f) {
        return fun.a6 ? fun.a6(a, b, c, d, e, f) : fun(a)(b)(c)(d)(e)(f);
    }
    function A7(fun, a, b, c, d, e, f, g) {
        return fun.a7 ? fun.a7(a, b, c, d, e, f, g) : fun(a)(b)(c)(d)(e)(f)(g);
    }
    function A8(fun, a, b, c, d, e, f, g, h) {
        return fun.a8 ? fun.a8(a, b, c, d, e, f, g, h) : fun(a)(b)(c)(d)(e)(f)(g)(h);
    }
    function A9(fun, a, b, c, d, e, f, g, h, i) {
        return fun.a9 ? fun.a9(a, b, c, d, e, f, g, h, i) : fun(a)(b)(c)(d)(e)(f)(g)(h)(i);
    }
    var _JsArray_empty = [];
    function _JsArray_singleton(value) {
        return [value];
    }
    function _JsArray_length(array) {
        return array.length;
    }
    var _JsArray_initialize_fn = function (size, offset, func) {
        var result = new Array(size);
        for (var i = 0; i < size; i++) {
            result[i] = func(offset + i);
        }
        return result;
    }, _JsArray_initialize = F3(_JsArray_initialize_fn);
    var _JsArray_initializeFromList_fn = function (max, ls) {
        var result = new Array(max);
        for (var i = 0; i < max && ls.b; i++) {
            result[i] = ls.a;
            ls = ls.b;
        }
        result.length = i;
        return _Utils_Tuple2(result, ls);
    }, _JsArray_initializeFromList = F2(_JsArray_initializeFromList_fn);
    var _JsArray_unsafeGet_fn = function (index, array) {
        return array[index];
    }, _JsArray_unsafeGet = F2(_JsArray_unsafeGet_fn);
    var _JsArray_unsafeSet_fn = function (index, value, array) {
        var length = array.length;
        var result = new Array(length);
        for (var i = 0; i < length; i++) {
            result[i] = array[i];
        }
        result[index] = value;
        return result;
    }, _JsArray_unsafeSet = F3(_JsArray_unsafeSet_fn);
    var _JsArray_push_fn = function (value, array) {
        var length = array.length;
        var result = new Array(length + 1);
        for (var i = 0; i < length; i++) {
            result[i] = array[i];
        }
        result[length] = value;
        return result;
    }, _JsArray_push = F2(_JsArray_push_fn);
    var _JsArray_foldl_fn = function (func, acc, array) {
        var length = array.length;
        for (var i = 0; i < length; i++) {
            acc = A2(func, array[i], acc);
        }
        return acc;
    }, _JsArray_foldl_fn_unwrapped = function (func, acc, array) {
        var length = array.length;
        for (var i = 0; i < length; i++) {
            acc = func(array[i], acc);
        }
        return acc;
    }, _JsArray_foldl = F3(_JsArray_foldl_fn);
    var _JsArray_foldr_fn = function (func, acc, array) {
        for (var i = array.length - 1; i >= 0; i--) {
            acc = A2(func, array[i], acc);
        }
        return acc;
    }, _JsArray_foldr_fn_unwrapped = function (func, acc, array) {
        for (var i = array.length - 1; i >= 0; i--) {
            acc = func(array[i], acc);
        }
        return acc;
    }, _JsArray_foldr = F3(_JsArray_foldr_fn);
    var _JsArray_map_fn = function (func, array) {
        var length = array.length;
        var result = new Array(length);
        for (var i = 0; i < length; i++) {
            result[i] = func(array[i]);
        }
        return result;
    }, _JsArray_map = F2(_JsArray_map_fn);
    var _JsArray_indexedMap_fn = function (func, offset, array) {
        var length = array.length;
        var result = new Array(length);
        for (var i = 0; i < length; i++) {
            result[i] = A2(func, offset + i, array[i]);
        }
        return result;
    }, _JsArray_indexedMap_fn_unwrapped = function (func, offset, array) {
        var length = array.length;
        var result = new Array(length);
        for (var i = 0; i < length; i++) {
            result[i] = func(offset + i, array[i]);
        }
        return result;
    }, _JsArray_indexedMap = F3(_JsArray_indexedMap_fn);
    var _JsArray_slice_fn = function (from, to, array) {
        return array.slice(from, to);
    }, _JsArray_slice = F3(_JsArray_slice_fn);
    var _JsArray_appendN_fn = function (n, dest, source) {
        var destLen = dest.length;
        var itemsToCopy = n - destLen;
        if (itemsToCopy > source.length) {
            itemsToCopy = source.length;
        }
        var size = destLen + itemsToCopy;
        var result = new Array(size);
        for (var i = 0; i < destLen; i++) {
            result[i] = dest[i];
        }
        for (var i = 0; i < itemsToCopy; i++) {
            result[i + destLen] = source[i];
        }
        return result;
    }, _JsArray_appendN = F3(_JsArray_appendN_fn);
    var _Debug_log_fn = function (tag, value) {
        return value;
    }, _Debug_log = F2(_Debug_log_fn);
    var _Debug_log_UNUSED_fn = function (tag, value) {
        console.log(tag + ": " + _Debug_toString(value));
        return value;
    }, _Debug_log_UNUSED = F2(_Debug_log_UNUSED_fn);
    function _Debug_todo(moduleName, region) {
        return function (message) {
            _Debug_crash(8, moduleName, region, message);
        };
    }
    function _Debug_todoCase(moduleName, region, value) {
        return function (message) {
            _Debug_crash(9, moduleName, region, value, message);
        };
    }
    function _Debug_toString(value) {
        return "<internals>";
    }
    function _Debug_toString_UNUSED(value) {
        return _Debug_toAnsiString(false, value);
    }
    function _Debug_toAnsiString(ansi, value) {
        if (typeof value === "function") {
            return _Debug_internalColor(ansi, "<function>");
        }
        if (typeof value === "boolean") {
            return _Debug_ctorColor(ansi, value ? "True" : "False");
        }
        if (typeof value === "number") {
            return _Debug_numberColor(ansi, value + "");
        }
        if (value instanceof String) {
            return _Debug_charColor(ansi, "'" + _Debug_addSlashes(value, true) + "'");
        }
        if (typeof value === "string") {
            return _Debug_stringColor(ansi, "\"" + _Debug_addSlashes(value, false) + "\"");
        }
        if (typeof value === "object" && "$" in value) {
            var tag = value.$;
            if (typeof tag === "number") {
                return _Debug_internalColor(ansi, "<internals>");
            }
            if (tag[0] === "#") {
                var output = [];
                for (var k in value) {
                    if (k === "$")
                        continue;
                    output.push(_Debug_toAnsiString(ansi, value[k]));
                }
                return "(" + output.join(",") + ")";
            }
            if (tag === "Set_elm_builtin") {
                return _Debug_ctorColor(ansi, "Set")
                    + _Debug_fadeColor(ansi, ".fromList") + " "
                    + _Debug_toAnsiString(ansi, $elm$core$Set$toList(value));
            }
            if (tag === "RBNode_elm_builtin" || tag === "RBEmpty_elm_builtin") {
                return _Debug_ctorColor(ansi, "Dict")
                    + _Debug_fadeColor(ansi, ".fromList") + " "
                    + _Debug_toAnsiString(ansi, $elm$core$Dict$toList(value));
            }
            if (tag === "Array_elm_builtin") {
                return _Debug_ctorColor(ansi, "Array")
                    + _Debug_fadeColor(ansi, ".fromList") + " "
                    + _Debug_toAnsiString(ansi, $elm$core$Array$toList(value));
            }
            if (tag === "::" || tag === "[]") {
                var output = "[";
                value.b && (output += _Debug_toAnsiString(ansi, value.a), value = value.b);
                for (; value.b; value = value.b) {
                    output += "," + _Debug_toAnsiString(ansi, value.a);
                }
                return output + "]";
            }
            var output = "";
            for (var i in value) {
                if (i === "$")
                    continue;
                var str = _Debug_toAnsiString(ansi, value[i]);
                var c0 = str[0];
                var parenless = c0 === "{" || c0 === "(" || c0 === "[" || c0 === "<" || c0 === "\"" || str.indexOf(" ") < 0;
                output += " " + (parenless ? str : "(" + str + ")");
            }
            return _Debug_ctorColor(ansi, tag) + output;
        }
        if (typeof DataView === "function" && value instanceof DataView) {
            return _Debug_stringColor(ansi, "<" + value.byteLength + " bytes>");
        }
        if (typeof File !== "undefined" && value instanceof File) {
            return _Debug_internalColor(ansi, "<" + value.name + ">");
        }
        if (typeof value === "object") {
            var output = [];
            for (var key in value) {
                var field = key[0] === "_" ? key.slice(1) : key;
                output.push(_Debug_fadeColor(ansi, field) + " = " + _Debug_toAnsiString(ansi, value[key]));
            }
            if (output.length === 0) {
                return "{}";
            }
            return "{ " + output.join(", ") + " }";
        }
        return _Debug_internalColor(ansi, "<internals>");
    }
    function _Debug_addSlashes(str, isChar) {
        var s = str
            .replace(/\\/g, "\\\\")
            .replace(/\n/g, "\\n")
            .replace(/\t/g, "\\t")
            .replace(/\r/g, "\\r")
            .replace(/\v/g, "\\v")
            .replace(/\0/g, "\\0");
        if (isChar) {
            return s.replace(/\'/g, "\\'");
        }
        else {
            return s.replace(/\"/g, "\\\"");
        }
    }
    function _Debug_ctorColor(ansi, string) {
        return ansi ? "\u001B[96m" + string + "\u001B[0m" : string;
    }
    function _Debug_numberColor(ansi, string) {
        return ansi ? "\u001B[95m" + string + "\u001B[0m" : string;
    }
    function _Debug_stringColor(ansi, string) {
        return ansi ? "\u001B[93m" + string + "\u001B[0m" : string;
    }
    function _Debug_charColor(ansi, string) {
        return ansi ? "\u001B[92m" + string + "\u001B[0m" : string;
    }
    function _Debug_fadeColor(ansi, string) {
        return ansi ? "\u001B[37m" + string + "\u001B[0m" : string;
    }
    function _Debug_internalColor(ansi, string) {
        return ansi ? "\u001B[36m" + string + "\u001B[0m" : string;
    }
    function _Debug_toHexDigit(n) {
        return String.fromCharCode(n < 10 ? 48 + n : 55 + n);
    }
    function _Debug_crash(identifier) {
        throw new Error("https://github.com/elm/core/blob/1.0.0/hints/" + identifier + ".md");
    }
    function _Debug_crash_UNUSED(identifier, fact1, fact2, fact3, fact4) {
        switch (identifier) {
            case 0:
                throw new Error("What node should I take over? In JavaScript I need something like:\n\n    Elm.Main.init({\n        node: document.getElementById(\"elm-node\")\n    })\n\nYou need to do this with any Browser.sandbox or Browser.element program.");
            case 1:
                throw new Error("Browser.application programs cannot handle URLs like this:\n\n    " + document.location.href + "\n\nWhat is the root? The root of your file system? Try looking at this program with `elm reactor` or some other server.");
            case 2:
                var jsonErrorString = fact1;
                throw new Error("Problem with the flags given to your Elm program on initialization.\n\n" + jsonErrorString);
            case 3:
                var portName = fact1;
                throw new Error("There can only be one port named `" + portName + "`, but your program has multiple.");
            case 4:
                var portName = fact1;
                var problem = fact2;
                throw new Error("Trying to send an unexpected type of value through port `" + portName + "`:\n" + problem);
            case 5:
                throw new Error("Trying to use `(==)` on functions.\nThere is no way to know if functions are \"the same\" in the Elm sense.\nRead more about this at https://package.elm-lang.org/packages/elm/core/latest/Basics#== which describes why it is this way and what the better version will look like.");
            case 6:
                var moduleName = fact1;
                throw new Error("Your page is loading multiple Elm scripts with a module named " + moduleName + ". Maybe a duplicate script is getting loaded accidentally? If not, rename one of them so I know which is which!");
            case 8:
                var moduleName = fact1;
                var region = fact2;
                var message = fact3;
                throw new Error("TODO in module `" + moduleName + "` " + _Debug_regionToString(region) + "\n\n" + message);
            case 9:
                var moduleName = fact1;
                var region = fact2;
                var value = fact3;
                var message = fact4;
                throw new Error("TODO in module `" + moduleName + "` from the `case` expression "
                    + _Debug_regionToString(region) + "\n\nIt received the following value:\n\n    "
                    + _Debug_toString(value).replace("\n", "\n    ")
                    + "\n\nBut the branch that handles it says:\n\n    " + message.replace("\n", "\n    "));
            case 10:
                throw new Error("Bug in https://github.com/elm/virtual-dom/issues");
            case 11:
                throw new Error("Cannot perform mod 0. Division by zero error.");
        }
    }
    function _Debug_regionToString(region) {
        if (region.B.h8 === region.x.h8) {
            return "on line " + region.B.h8;
        }
        return "on lines " + region.B.h8 + " through " + region.x.h8;
    }
    function _Utils_eq(x, y) {
        for (var pair, stack = [], isEqual = _Utils_eqHelp(x, y, 0, stack); isEqual && (pair = stack.pop()); isEqual = _Utils_eqHelp(pair.a, pair.b, 0, stack)) { }
        return isEqual;
    }
    function _Utils_eqHelp(x, y, depth, stack) {
        if (x === y) {
            return true;
        }
        if (typeof x !== "object" || x === null || y === null) {
            typeof x === "function" && _Debug_crash(5);
            return false;
        }
        if (depth > 100) {
            stack.push(_Utils_Tuple2(x, y));
            return true;
        }
        if (x.$ < 0) {
            x = $elm$core$Dict$toList(x);
            y = $elm$core$Dict$toList(y);
        }
        for (var key in x) {
            if (!_Utils_eqHelp(x[key], y[key], depth + 1, stack)) {
                return false;
            }
        }
        return true;
    }
    var _Utils_equal = F2(_Utils_eq);
    var _Utils_notEqual_fn = function (a, b) { return !_Utils_eq(a, b); }, _Utils_notEqual = F2(_Utils_notEqual_fn);
    function _Utils_cmp(x, y, ord) {
        if (typeof x !== "object") {
            return x === y ? 0 : x < y ? -1 : 1;
        }
        if (typeof x.$ === "undefined") {
            return (ord = _Utils_cmp(x.a, y.a))
                ? ord
                : (ord = _Utils_cmp(x.b, y.b))
                    ? ord
                    : _Utils_cmp(x.c, y.c);
        }
        for (; x.b && y.b && !(ord = _Utils_cmp(x.a, y.a)); x = x.b, y = y.b) { }
        return ord || (x.b ? 1 : y.b ? -1 : 0);
    }
    var _Utils_lt_fn = function (a, b) { return _Utils_cmp(a, b) < 0; }, _Utils_lt = F2(_Utils_lt_fn);
    var _Utils_le_fn = function (a, b) { return _Utils_cmp(a, b) < 1; }, _Utils_le = F2(_Utils_le_fn);
    var _Utils_gt_fn = function (a, b) { return _Utils_cmp(a, b) > 0; }, _Utils_gt = F2(_Utils_gt_fn);
    var _Utils_ge_fn = function (a, b) { return _Utils_cmp(a, b) >= 0; }, _Utils_ge = F2(_Utils_ge_fn);
    var _Utils_compare_fn = function (x, y) {
        var n = _Utils_cmp(x, y);
        return n < 0 ? $elm$core$Basics$LT : n ? $elm$core$Basics$GT : $elm$core$Basics$EQ;
    }, _Utils_compare = F2(_Utils_compare_fn);
    var _Utils_Tuple0 = 0;
    var _Utils_Tuple0_UNUSED = { $: "#0" };
    function _Utils_Tuple2(a, b) { return { a: a, b: b }; }
    function _Utils_Tuple2_UNUSED(a, b) { return { $: "#2", a: a, b: b }; }
    function _Utils_Tuple3(a, b, c) { return { a: a, b: b, c: c }; }
    function _Utils_Tuple3_UNUSED(a, b, c) { return { $: "#3", a: a, b: b, c: c }; }
    function _Utils_chr(c) { return c; }
    function _Utils_chr_UNUSED(c) { return new String(c); }
    function _Utils_update(oldRecord, updatedFields) {
        var newRecord = {};
        for (var key in oldRecord) {
            newRecord[key] = oldRecord[key];
        }
        for (var key in updatedFields) {
            newRecord[key] = updatedFields[key];
        }
        return newRecord;
    }
    var _Utils_append = F2(_Utils_ap);
    function _Utils_ap(xs, ys) {
        if (typeof xs === "string") {
            return xs + ys;
        }
        if (!xs.b) {
            return ys;
        }
        var root = _List_Cons(xs.a, ys);
        xs = xs.b;
        for (var curr = root; xs.b; xs = xs.b) {
            curr = curr.b = _List_Cons(xs.a, ys);
        }
        return root;
    }
    var _List_Nil = { $: 0, a: null, b: null };
    var _List_Nil_UNUSED = { $: "[]" };
    function _List_Cons(hd, tl) { return { $: 1, a: hd, b: tl }; }
    function _List_Cons_UNUSED(hd, tl) { return { $: "::", a: hd, b: tl }; }
    var _List_cons = F2(_List_Cons);
    function _List_fromArray(arr) {
        var out = _List_Nil;
        for (var i = arr.length; i--;) {
            out = _List_Cons(arr[i], out);
        }
        return out;
    }
    function _List_toArray(xs) {
        for (var out = []; xs.b; xs = xs.b) {
            out.push(xs.a);
        }
        return out;
    }
    var _List_map2_fn = function (f, xs, ys) {
        for (var arr = []; xs.b && ys.b; xs = xs.b, ys = ys.b) {
            arr.push(A2(f, xs.a, ys.a));
        }
        return _List_fromArray(arr);
    }, _List_map2_fn_unwrapped = function (f, xs, ys) {
        for (var arr = []; xs.b && ys.b; xs = xs.b, ys = ys.b) {
            arr.push(f(xs.a, ys.a));
        }
        return _List_fromArray(arr);
    }, _List_map2 = F3(_List_map2_fn);
    var _List_map3_fn = function (f, xs, ys, zs) {
        for (var arr = []; xs.b && ys.b && zs.b; xs = xs.b, ys = ys.b, zs = zs.b) {
            arr.push(A3(f, xs.a, ys.a, zs.a));
        }
        return _List_fromArray(arr);
    }, _List_map3_fn_unwrapped = function (f, xs, ys, zs) {
        for (var arr = []; xs.b && ys.b && zs.b; xs = xs.b, ys = ys.b, zs = zs.b) {
            arr.push(f(xs.a, ys.a, zs.a));
        }
        return _List_fromArray(arr);
    }, _List_map3 = F4(_List_map3_fn);
    var _List_map4_fn = function (f, ws, xs, ys, zs) {
        for (var arr = []; ws.b && xs.b && ys.b && zs.b; ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) {
            arr.push(A4(f, ws.a, xs.a, ys.a, zs.a));
        }
        return _List_fromArray(arr);
    }, _List_map4_fn_unwrapped = function (f, ws, xs, ys, zs) {
        for (var arr = []; ws.b && xs.b && ys.b && zs.b; ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) {
            arr.push(f(ws.a, xs.a, ys.a, zs.a));
        }
        return _List_fromArray(arr);
    }, _List_map4 = F5(_List_map4_fn);
    var _List_map5_fn = function (f, vs, ws, xs, ys, zs) {
        for (var arr = []; vs.b && ws.b && xs.b && ys.b && zs.b; vs = vs.b, ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) {
            arr.push(A5(f, vs.a, ws.a, xs.a, ys.a, zs.a));
        }
        return _List_fromArray(arr);
    }, _List_map5_fn_unwrapped = function (f, vs, ws, xs, ys, zs) {
        for (var arr = []; vs.b && ws.b && xs.b && ys.b && zs.b; vs = vs.b, ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) {
            arr.push(f(vs.a, ws.a, xs.a, ys.a, zs.a));
        }
        return _List_fromArray(arr);
    }, _List_map5 = F6(_List_map5_fn);
    var _List_sortBy_fn = function (f, xs) {
        return _List_fromArray(_List_toArray(xs).sort(function (a, b) {
            return _Utils_cmp(f(a), f(b));
        }));
    }, _List_sortBy = F2(_List_sortBy_fn);
    var _List_sortWith_fn = function (f, xs) {
        return _List_fromArray(_List_toArray(xs).sort(function (a, b) {
            var ord = A2(f, a, b);
            return ord === $elm$core$Basics$EQ ? 0 : ord === $elm$core$Basics$LT ? -1 : 1;
        }));
    }, _List_sortWith_fn_unwrapped = function (f, xs) {
        return _List_fromArray(_List_toArray(xs).sort(function (a, b) {
            var ord = f(a, b);
            return ord === $elm$core$Basics$EQ ? 0 : ord === $elm$core$Basics$LT ? -1 : 1;
        }));
    }, _List_sortWith = F2(_List_sortWith_fn);
    var _Basics_add_fn = function (a, b) { return a + b; }, _Basics_add = F2(_Basics_add_fn);
    var _Basics_sub_fn = function (a, b) { return a - b; }, _Basics_sub = F2(_Basics_sub_fn);
    var _Basics_mul_fn = function (a, b) { return a * b; }, _Basics_mul = F2(_Basics_mul_fn);
    var _Basics_fdiv_fn = function (a, b) { return a / b; }, _Basics_fdiv = F2(_Basics_fdiv_fn);
    var _Basics_idiv_fn = function (a, b) { return (a / b) | 0; }, _Basics_idiv = F2(_Basics_idiv_fn);
    var _Basics_pow_fn = Math.pow, _Basics_pow = F2(_Basics_pow_fn);
    var _Basics_remainderBy_fn = function (b, a) { return a % b; }, _Basics_remainderBy = F2(_Basics_remainderBy_fn);
    var _Basics_modBy_fn = function (modulus, x) {
        var answer = x % modulus;
        return modulus === 0
            ? _Debug_crash(11)
            :
                ((answer > 0 && modulus < 0) || (answer < 0 && modulus > 0))
                    ? answer + modulus
                    : answer;
    }, _Basics_modBy = F2(_Basics_modBy_fn);
    var _Basics_pi = Math.PI;
    var _Basics_e = Math.E;
    var _Basics_cos = Math.cos;
    var _Basics_sin = Math.sin;
    var _Basics_tan = Math.tan;
    var _Basics_acos = Math.acos;
    var _Basics_asin = Math.asin;
    var _Basics_atan = Math.atan;
    var _Basics_atan2_fn = Math.atan2, _Basics_atan2 = F2(_Basics_atan2_fn);
    function _Basics_toFloat(x) { return x; }
    function _Basics_truncate(n) { return n | 0; }
    function _Basics_isInfinite(n) { return n === Infinity || n === -Infinity; }
    var _Basics_ceiling = Math.ceil;
    var _Basics_floor = Math.floor;
    var _Basics_round = Math.round;
    var _Basics_sqrt = Math.sqrt;
    var _Basics_log = Math.log;
    var _Basics_isNaN = isNaN;
    function _Basics_not(bool) { return !bool; }
    var _Basics_and_fn = function (a, b) { return a && b; }, _Basics_and = F2(_Basics_and_fn);
    var _Basics_or_fn = function (a, b) { return a || b; }, _Basics_or = F2(_Basics_or_fn);
    var _Basics_xor_fn = function (a, b) { return a !== b; }, _Basics_xor = F2(_Basics_xor_fn);
    var _String_cons_fn = function (chr, str) {
        return chr + str;
    }, _String_cons = F2(_String_cons_fn);
    function _String_uncons(string) {
        var word = string.charCodeAt(0);
        return !isNaN(word)
            ? $elm$core$Maybe$Just(55296 <= word && word <= 56319
                ? _Utils_Tuple2(_Utils_chr(string[0] + string[1]), string.slice(2))
                : _Utils_Tuple2(_Utils_chr(string[0]), string.slice(1)))
            : $elm$core$Maybe$Nothing;
    }
    var _String_append_fn = function (a, b) {
        return a + b;
    }, _String_append = F2(_String_append_fn);
    function _String_length(str) {
        return str.length;
    }
    var _String_map_fn = function (func, string) {
        var len = string.length;
        var array = new Array(len);
        var i = 0;
        while (i < len) {
            var word = string.charCodeAt(i);
            if (55296 <= word && word <= 56319) {
                array[i] = func(_Utils_chr(string[i] + string[i + 1]));
                i += 2;
                continue;
            }
            array[i] = func(_Utils_chr(string[i]));
            i++;
        }
        return array.join("");
    }, _String_map = F2(_String_map_fn);
    var _String_filter_fn = function (isGood, str) {
        var arr = [];
        var len = str.length;
        var i = 0;
        while (i < len) {
            var char = str[i];
            var word = str.charCodeAt(i);
            i++;
            if (55296 <= word && word <= 56319) {
                char += str[i];
                i++;
            }
            if (isGood(_Utils_chr(char))) {
                arr.push(char);
            }
        }
        return arr.join("");
    }, _String_filter = F2(_String_filter_fn);
    function _String_reverse(str) {
        var len = str.length;
        var arr = new Array(len);
        var i = 0;
        while (i < len) {
            var word = str.charCodeAt(i);
            if (55296 <= word && word <= 56319) {
                arr[len - i] = str[i + 1];
                i++;
                arr[len - i] = str[i - 1];
                i++;
            }
            else {
                arr[len - i] = str[i];
                i++;
            }
        }
        return arr.join("");
    }
    var _String_foldl_fn = function (func, state, string) {
        var len = string.length;
        var i = 0;
        while (i < len) {
            var char = string[i];
            var word = string.charCodeAt(i);
            i++;
            if (55296 <= word && word <= 56319) {
                char += string[i];
                i++;
            }
            state = A2(func, _Utils_chr(char), state);
        }
        return state;
    }, _String_foldl_fn_unwrapped = function (func, state, string) {
        var len = string.length;
        var i = 0;
        while (i < len) {
            var char = string[i];
            var word = string.charCodeAt(i);
            i++;
            if (55296 <= word && word <= 56319) {
                char += string[i];
                i++;
            }
            state = func(_Utils_chr(char), state);
        }
        return state;
    }, _String_foldl = F3(_String_foldl_fn);
    var _String_foldr_fn = function (func, state, string) {
        var i = string.length;
        while (i--) {
            var char = string[i];
            var word = string.charCodeAt(i);
            if (56320 <= word && word <= 57343) {
                i--;
                char = string[i] + char;
            }
            state = A2(func, _Utils_chr(char), state);
        }
        return state;
    }, _String_foldr_fn_unwrapped = function (func, state, string) {
        var i = string.length;
        while (i--) {
            var char = string[i];
            var word = string.charCodeAt(i);
            if (56320 <= word && word <= 57343) {
                i--;
                char = string[i] + char;
            }
            state = func(_Utils_chr(char), state);
        }
        return state;
    }, _String_foldr = F3(_String_foldr_fn);
    var _String_split_fn = function (sep, str) {
        return str.split(sep);
    }, _String_split = F2(_String_split_fn);
    var _String_join_fn = function (sep, strs) {
        return strs.join(sep);
    }, _String_join = F2(_String_join_fn);
    var _String_slice_fn = function (start, end, str) {
        return str.slice(start, end);
    }, _String_slice = F3(_String_slice_fn);
    function _String_trim(str) {
        return str.trim();
    }
    function _String_trimLeft(str) {
        return str.replace(/^\s+/, "");
    }
    function _String_trimRight(str) {
        return str.replace(/\s+$/, "");
    }
    function _String_words(str) {
        return _List_fromArray(str.trim().split(/\s+/g));
    }
    function _String_lines(str) {
        return _List_fromArray(str.split(/\r\n|\r|\n/g));
    }
    function _String_toUpper(str) {
        return str.toUpperCase();
    }
    function _String_toLower(str) {
        return str.toLowerCase();
    }
    var _String_any_fn = function (isGood, string) {
        var i = string.length;
        while (i--) {
            var char = string[i];
            var word = string.charCodeAt(i);
            if (56320 <= word && word <= 57343) {
                i--;
                char = string[i] + char;
            }
            if (isGood(_Utils_chr(char))) {
                return true;
            }
        }
        return false;
    }, _String_any = F2(_String_any_fn);
    var _String_all_fn = function (isGood, string) {
        var i = string.length;
        while (i--) {
            var char = string[i];
            var word = string.charCodeAt(i);
            if (56320 <= word && word <= 57343) {
                i--;
                char = string[i] + char;
            }
            if (!isGood(_Utils_chr(char))) {
                return false;
            }
        }
        return true;
    }, _String_all = F2(_String_all_fn);
    var _String_contains_fn = function (sub, str) {
        return str.indexOf(sub) > -1;
    }, _String_contains = F2(_String_contains_fn);
    var _String_startsWith_fn = function (sub, str) {
        return str.indexOf(sub) === 0;
    }, _String_startsWith = F2(_String_startsWith_fn);
    var _String_endsWith_fn = function (sub, str) {
        return str.length >= sub.length &&
            str.lastIndexOf(sub) === str.length - sub.length;
    }, _String_endsWith = F2(_String_endsWith_fn);
    var _String_indexes_fn = function (sub, str) {
        var subLen = sub.length;
        if (subLen < 1) {
            return _List_Nil;
        }
        var i = 0;
        var is = [];
        while ((i = str.indexOf(sub, i)) > -1) {
            is.push(i);
            i = i + subLen;
        }
        return _List_fromArray(is);
    }, _String_indexes = F2(_String_indexes_fn);
    function _String_fromNumber(number) {
        return number + "";
    }
    function _String_toInt(str) {
        var total = 0;
        var code0 = str.charCodeAt(0);
        var start = code0 == 43 || code0 == 45 ? 1 : 0;
        for (var i = start; i < str.length; ++i) {
            var code = str.charCodeAt(i);
            if (code < 48 || 57 < code) {
                return $elm$core$Maybe$Nothing;
            }
            total = 10 * total + code - 48;
        }
        return i == start
            ? $elm$core$Maybe$Nothing
            : $elm$core$Maybe$Just(code0 == 45 ? -total : total);
    }
    function _String_toFloat(s) {
        if (s.length === 0 || /[\sxbo]/.test(s)) {
            return $elm$core$Maybe$Nothing;
        }
        var n = +s;
        return n === n ? $elm$core$Maybe$Just(n) : $elm$core$Maybe$Nothing;
    }
    function _String_fromList(chars) {
        return _List_toArray(chars).join("");
    }
    function _Char_toCode(char) {
        var code = char.charCodeAt(0);
        if (55296 <= code && code <= 56319) {
            return (code - 55296) * 1024 + char.charCodeAt(1) - 56320 + 65536;
        }
        return code;
    }
    function _Char_fromCode(code) {
        return _Utils_chr((code < 0 || 1114111 < code)
            ? "\uFFFD"
            :
                (code <= 65535)
                    ? String.fromCharCode(code)
                    :
                        (code -= 65536,
                            String.fromCharCode(Math.floor(code / 1024) + 55296, code % 1024 + 56320)));
    }
    function _Char_toUpper(char) {
        return _Utils_chr(char.toUpperCase());
    }
    function _Char_toLower(char) {
        return _Utils_chr(char.toLowerCase());
    }
    function _Char_toLocaleUpper(char) {
        return _Utils_chr(char.toLocaleUpperCase());
    }
    function _Char_toLocaleLower(char) {
        return _Utils_chr(char.toLocaleLowerCase());
    }
    function _Json_succeed(msg) {
        return {
            $: 0,
            a: msg
        };
    }
    function _Json_fail(msg) {
        return {
            $: 1,
            a: msg
        };
    }
    function _Json_decodePrim(decoder) {
        return { $: 2, b: decoder };
    }
    var _Json_decodeInt = _Json_decodePrim(function (value) {
        return (typeof value !== "number")
            ? _Json_expecting("an INT", value)
            :
                (-2147483647 < value && value < 2147483647 && (value | 0) === value)
                    ? $elm$core$Result$Ok(value)
                    :
                        (isFinite(value) && !(value % 1))
                            ? $elm$core$Result$Ok(value)
                            : _Json_expecting("an INT", value);
    });
    var _Json_decodeBool = _Json_decodePrim(function (value) {
        return (typeof value === "boolean")
            ? $elm$core$Result$Ok(value)
            : _Json_expecting("a BOOL", value);
    });
    var _Json_decodeFloat = _Json_decodePrim(function (value) {
        return (typeof value === "number")
            ? $elm$core$Result$Ok(value)
            : _Json_expecting("a FLOAT", value);
    });
    var _Json_decodeValue = _Json_decodePrim(function (value) {
        return $elm$core$Result$Ok(_Json_wrap(value));
    });
    var _Json_decodeString = _Json_decodePrim(function (value) {
        return (typeof value === "string")
            ? $elm$core$Result$Ok(value)
            : (value instanceof String)
                ? $elm$core$Result$Ok(value + "")
                : _Json_expecting("a STRING", value);
    });
    function _Json_decodeList(decoder) { return { $: 3, b: decoder }; }
    function _Json_decodeArray(decoder) { return { $: 4, b: decoder }; }
    function _Json_decodeNull(value) { return { $: 5, c: value }; }
    var _Json_decodeField_fn = function (field, decoder) {
        return {
            $: 6,
            d: field,
            b: decoder
        };
    }, _Json_decodeField = F2(_Json_decodeField_fn);
    var _Json_decodeIndex_fn = function (index, decoder) {
        return {
            $: 7,
            e: index,
            b: decoder
        };
    }, _Json_decodeIndex = F2(_Json_decodeIndex_fn);
    function _Json_decodeKeyValuePairs(decoder) {
        return {
            $: 8,
            b: decoder
        };
    }
    function _Json_mapMany(f, decoders) {
        return {
            $: 9,
            f: f,
            g: decoders
        };
    }
    var _Json_andThen_fn = function (callback, decoder) {
        return {
            $: 10,
            b: decoder,
            h: callback
        };
    }, _Json_andThen = F2(_Json_andThen_fn);
    function _Json_oneOf(decoders) {
        return {
            $: 11,
            g: decoders
        };
    }
    var _Json_map1_fn = function (f, d1) {
        return _Json_mapMany(f, [d1]);
    }, _Json_map1 = F2(_Json_map1_fn);
    var _Json_map2_fn = function (f, d1, d2) {
        return _Json_mapMany(f, [d1, d2]);
    }, _Json_map2 = F3(_Json_map2_fn);
    var _Json_map3_fn = function (f, d1, d2, d3) {
        return _Json_mapMany(f, [d1, d2, d3]);
    }, _Json_map3 = F4(_Json_map3_fn);
    var _Json_map4_fn = function (f, d1, d2, d3, d4) {
        return _Json_mapMany(f, [d1, d2, d3, d4]);
    }, _Json_map4 = F5(_Json_map4_fn);
    var _Json_map5_fn = function (f, d1, d2, d3, d4, d5) {
        return _Json_mapMany(f, [d1, d2, d3, d4, d5]);
    }, _Json_map5 = F6(_Json_map5_fn);
    var _Json_map6_fn = function (f, d1, d2, d3, d4, d5, d6) {
        return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6]);
    }, _Json_map6 = F7(_Json_map6_fn);
    var _Json_map7_fn = function (f, d1, d2, d3, d4, d5, d6, d7) {
        return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7]);
    }, _Json_map7 = F8(_Json_map7_fn);
    var _Json_map8_fn = function (f, d1, d2, d3, d4, d5, d6, d7, d8) {
        return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7, d8]);
    }, _Json_map8 = F9(_Json_map8_fn);
    var _Json_runOnString_fn = function (decoder, string) {
        try {
            var value = JSON.parse(string);
            return _Json_runHelp(decoder, value);
        }
        catch (e) {
            return $elm$core$Result$Err($elm$json$Json$Decode$Failure_fn("This is not valid JSON! " + e.message, _Json_wrap(string)));
        }
    }, _Json_runOnString = F2(_Json_runOnString_fn);
    var _Json_run_fn = function (decoder, value) {
        return _Json_runHelp(decoder, _Json_unwrap(value));
    }, _Json_run = F2(_Json_run_fn);
    function _Json_runHelp(decoder, value) {
        switch (decoder.$) {
            case 2:
                return decoder.b(value);
            case 5:
                return (value === null)
                    ? $elm$core$Result$Ok(decoder.c)
                    : _Json_expecting("null", value);
            case 3:
                if (!_Json_isArray(value)) {
                    return _Json_expecting("a LIST", value);
                }
                return _Json_runArrayDecoder(decoder.b, value, _List_fromArray);
            case 4:
                if (!_Json_isArray(value)) {
                    return _Json_expecting("an ARRAY", value);
                }
                return _Json_runArrayDecoder(decoder.b, value, _Json_toElmArray);
            case 6:
                var field = decoder.d;
                if (typeof value !== "object" || value === null || !(field in value)) {
                    return _Json_expecting("an OBJECT with a field named `" + field + "`", value);
                }
                var result = _Json_runHelp(decoder.b, value[field]);
                return ($elm$core$Result$isOk(result)) ? result : $elm$core$Result$Err($elm$json$Json$Decode$Field_fn(field, result.a));
            case 7:
                var index = decoder.e;
                if (!_Json_isArray(value)) {
                    return _Json_expecting("an ARRAY", value);
                }
                if (index >= value.length) {
                    return _Json_expecting("a LONGER array. Need index " + index + " but only see " + value.length + " entries", value);
                }
                var result = _Json_runHelp(decoder.b, value[index]);
                return ($elm$core$Result$isOk(result)) ? result : $elm$core$Result$Err($elm$json$Json$Decode$Index_fn(index, result.a));
            case 8:
                if (typeof value !== "object" || value === null || _Json_isArray(value)) {
                    return _Json_expecting("an OBJECT", value);
                }
                var keyValuePairs = _List_Nil;
                for (var key in value) {
                    if (value.hasOwnProperty(key)) {
                        var result = _Json_runHelp(decoder.b, value[key]);
                        if (!$elm$core$Result$isOk(result)) {
                            return $elm$core$Result$Err($elm$json$Json$Decode$Field_fn(key, result.a));
                        }
                        keyValuePairs = _List_Cons(_Utils_Tuple2(key, result.a), keyValuePairs);
                    }
                }
                return $elm$core$Result$Ok($elm$core$List$reverse(keyValuePairs));
            case 9:
                var answer = decoder.f;
                var decoders = decoder.g;
                for (var i = 0; i < decoders.length; i++) {
                    var result = _Json_runHelp(decoders[i], value);
                    if (!$elm$core$Result$isOk(result)) {
                        return result;
                    }
                    answer = answer(result.a);
                }
                return $elm$core$Result$Ok(answer);
            case 10:
                var result = _Json_runHelp(decoder.b, value);
                return (!$elm$core$Result$isOk(result))
                    ? result
                    : _Json_runHelp(decoder.h(result.a), value);
            case 11:
                var errors = _List_Nil;
                for (var temp = decoder.g; temp.b; temp = temp.b) {
                    var result = _Json_runHelp(temp.a, value);
                    if ($elm$core$Result$isOk(result)) {
                        return result;
                    }
                    errors = _List_Cons(result.a, errors);
                }
                return $elm$core$Result$Err($elm$json$Json$Decode$OneOf($elm$core$List$reverse(errors)));
            case 1:
                return $elm$core$Result$Err($elm$json$Json$Decode$Failure_fn(decoder.a, _Json_wrap(value)));
            case 0:
                return $elm$core$Result$Ok(decoder.a);
        }
    }
    function _Json_runArrayDecoder(decoder, value, toElmValue) {
        var len = value.length;
        var array = new Array(len);
        for (var i = 0; i < len; i++) {
            var result = _Json_runHelp(decoder, value[i]);
            if (!$elm$core$Result$isOk(result)) {
                return $elm$core$Result$Err($elm$json$Json$Decode$Index_fn(i, result.a));
            }
            array[i] = result.a;
        }
        return $elm$core$Result$Ok(toElmValue(array));
    }
    function _Json_isArray(value) {
        return Array.isArray(value) || (typeof FileList !== "undefined" && value instanceof FileList);
    }
    function _Json_toElmArray(array) {
        return $elm$core$Array$initialize_fn(array.length, function (i) { return array[i]; });
    }
    function _Json_expecting(type, value) {
        return $elm$core$Result$Err($elm$json$Json$Decode$Failure_fn("Expecting " + type, _Json_wrap(value)));
    }
    function _Json_equality(x, y) {
        if (x === y) {
            return true;
        }
        if (x.$ !== y.$) {
            return false;
        }
        switch (x.$) {
            case 0:
            case 1:
                return x.a === y.a;
            case 2:
                return x.b === y.b;
            case 5:
                return x.c === y.c;
            case 3:
            case 4:
            case 8:
                return _Json_equality(x.b, y.b);
            case 6:
                return x.d === y.d && _Json_equality(x.b, y.b);
            case 7:
                return x.e === y.e && _Json_equality(x.b, y.b);
            case 9:
                return x.f === y.f && _Json_listEquality(x.g, y.g);
            case 10:
                return x.h === y.h && _Json_equality(x.b, y.b);
            case 11:
                return _Json_listEquality(x.g, y.g);
        }
    }
    function _Json_listEquality(aDecoders, bDecoders) {
        var len = aDecoders.length;
        if (len !== bDecoders.length) {
            return false;
        }
        for (var i = 0; i < len; i++) {
            if (!_Json_equality(aDecoders[i], bDecoders[i])) {
                return false;
            }
        }
        return true;
    }
    var _Json_encode_fn = function (indentLevel, value) {
        return JSON.stringify(_Json_unwrap(value), null, indentLevel) + "";
    }, _Json_encode = F2(_Json_encode_fn);
    function _Json_wrap_UNUSED(value) { return { $: 0, a: value }; }
    function _Json_unwrap_UNUSED(value) { return value.a; }
    function _Json_wrap(value) { return value; }
    function _Json_unwrap(value) { return value; }
    function _Json_emptyArray() { return []; }
    function _Json_emptyObject() { return {}; }
    var _Json_addField_fn = function (key, value, object) {
        object[key] = _Json_unwrap(value);
        return object;
    }, _Json_addField = F3(_Json_addField_fn);
    function _Json_addEntry(func) {
        return F2(function (entry, array) {
            array.push(_Json_unwrap(func(entry)));
            return array;
        });
    }
    var _Json_encodeNull = _Json_wrap(null);
    function _Scheduler_succeed(value) {
        return {
            $: 0,
            a: value
        };
    }
    function _Scheduler_fail(error) {
        return {
            $: 1,
            a: error
        };
    }
    function _Scheduler_binding(callback) {
        return {
            $: 2,
            b: callback,
            c: null
        };
    }
    var _Scheduler_andThen_fn = function (callback, task) {
        return {
            $: 3,
            b: callback,
            d: task
        };
    }, _Scheduler_andThen = F2(_Scheduler_andThen_fn);
    var _Scheduler_onError_fn = function (callback, task) {
        return {
            $: 4,
            b: callback,
            d: task
        };
    }, _Scheduler_onError = F2(_Scheduler_onError_fn);
    function _Scheduler_receive(callback) {
        return {
            $: 5,
            b: callback
        };
    }
    var _Scheduler_guid = 0;
    function _Scheduler_rawSpawn(task) {
        var proc = {
            $: 0,
            e: _Scheduler_guid++,
            f: task,
            g: null,
            h: []
        };
        _Scheduler_enqueue(proc);
        return proc;
    }
    function _Scheduler_spawn(task) {
        return _Scheduler_binding(function (callback) {
            callback(_Scheduler_succeed(_Scheduler_rawSpawn(task)));
        });
    }
    function _Scheduler_rawSend(proc, msg) {
        proc.h.push(msg);
        _Scheduler_enqueue(proc);
    }
    var _Scheduler_send_fn = function (proc, msg) {
        return _Scheduler_binding(function (callback) {
            _Scheduler_rawSend(proc, msg);
            callback(_Scheduler_succeed(_Utils_Tuple0));
        });
    }, _Scheduler_send = F2(_Scheduler_send_fn);
    function _Scheduler_kill(proc) {
        return _Scheduler_binding(function (callback) {
            var task = proc.f;
            if (task.$ === 2 && task.c) {
                task.c();
            }
            proc.f = null;
            callback(_Scheduler_succeed(_Utils_Tuple0));
        });
    }
    var _Scheduler_working = false;
    var _Scheduler_queue = [];
    function _Scheduler_enqueue(proc) {
        _Scheduler_queue.push(proc);
        if (_Scheduler_working) {
            return;
        }
        _Scheduler_working = true;
        while (proc = _Scheduler_queue.shift()) {
            _Scheduler_step(proc);
        }
        _Scheduler_working = false;
    }
    function _Scheduler_step(proc) {
        while (proc.f) {
            var rootTag = proc.f.$;
            if (rootTag === 0 || rootTag === 1) {
                while (proc.g && proc.g.$ !== rootTag) {
                    proc.g = proc.g.i;
                }
                if (!proc.g) {
                    return;
                }
                proc.f = proc.g.b(proc.f.a);
                proc.g = proc.g.i;
            }
            else if (rootTag === 2) {
                proc.f.c = proc.f.b(function (newRoot) {
                    proc.f = newRoot;
                    _Scheduler_enqueue(proc);
                });
                return;
            }
            else if (rootTag === 5) {
                if (proc.h.length === 0) {
                    return;
                }
                proc.f = proc.f.b(proc.h.shift());
            }
            else {
                proc.g = {
                    $: rootTag === 3 ? 0 : 1,
                    b: proc.f.b,
                    i: proc.g
                };
                proc.f = proc.f.d;
            }
        }
    }
    function _Process_sleep(time) {
        return _Scheduler_binding(function (callback) {
            var id = setTimeout(function () {
                callback(_Scheduler_succeed(_Utils_Tuple0));
            }, time);
            return function () { clearTimeout(id); };
        });
    }
    var _Platform_worker_fn = function (impl, flagDecoder, debugMetadata, args) {
        return _Platform_initialize(flagDecoder, args, impl.dI, impl.cF, impl.dW, function () { return function () { }; });
    }, _Platform_worker = F4(_Platform_worker_fn);
    function _Platform_initialize(flagDecoder, args, init, update, subscriptions, stepperBuilder) {
        var result = _Json_run_fn(flagDecoder, _Json_wrap(args ? args["flags"] : undefined));
        $elm$core$Result$isOk(result) || _Debug_crash(2);
        var managers = {};
        var initPair = init(result.a);
        var model = initPair.a;
        var stepper = stepperBuilder(sendToApp, model);
        var ports = _Platform_setupEffects(managers, sendToApp);
        function sendToApp(msg, viewMetadata) {
            var pair = A2(update, msg, model);
            stepper(model = pair.a, viewMetadata);
            _Platform_enqueueEffects(managers, pair.b, subscriptions(model));
        }
        _Platform_enqueueEffects(managers, initPair.b, subscriptions(model));
        return ports ? { ports: ports } : {};
    }
    var _Platform_preload;
    function _Platform_registerPreload(url) {
        _Platform_preload.add(url);
    }
    var _Platform_effectManagers = {};
    function _Platform_setupEffects(managers, sendToApp) {
        var ports;
        for (var key in _Platform_effectManagers) {
            var manager = _Platform_effectManagers[key];
            if (manager.a) {
                ports = ports || {};
                ports[key] = manager.a(key, sendToApp);
            }
            managers[key] = _Platform_instantiateManager(manager, sendToApp);
        }
        return ports;
    }
    function _Platform_createManager(init, onEffects, onSelfMsg, cmdMap, subMap) {
        return {
            b: init,
            c: onEffects,
            d: onSelfMsg,
            e: cmdMap,
            f: subMap
        };
    }
    function _Platform_instantiateManager(info, sendToApp) {
        var router = {
            g: sendToApp,
            h: undefined
        };
        var onEffects = info.c;
        var onSelfMsg = info.d;
        var cmdMap = info.e;
        var subMap = info.f;
        function loop(state) {
            return _Scheduler_andThen_fn(loop, _Scheduler_receive(function (msg) {
                var value = msg.a;
                if (msg.$ === 0) {
                    return A3(onSelfMsg, router, value, state);
                }
                return cmdMap && subMap
                    ? A4(onEffects, router, value.i, value.j, state)
                    : A3(onEffects, router, cmdMap ? value.i : value.j, state);
            }));
        }
        return router.h = _Scheduler_rawSpawn(_Scheduler_andThen_fn(loop, info.b));
    }
    var _Platform_sendToApp_fn = function (router, msg) {
        return _Scheduler_binding(function (callback) {
            router.g(msg);
            callback(_Scheduler_succeed(_Utils_Tuple0));
        });
    }, _Platform_sendToApp = F2(_Platform_sendToApp_fn);
    var _Platform_sendToSelf_fn = function (router, msg) {
        return _Scheduler_send_fn(router.h, {
            $: 0,
            a: msg
        });
    }, _Platform_sendToSelf = F2(_Platform_sendToSelf_fn);
    function _Platform_leaf(home) {
        return function (value) {
            return {
                $: 1,
                k: home,
                l: value
            };
        };
    }
    function _Platform_batch(list) {
        return {
            $: 2,
            m: list
        };
    }
    var _Platform_map_fn = function (tagger, bag) {
        return {
            $: 3,
            n: tagger,
            o: bag
        };
    }, _Platform_map = F2(_Platform_map_fn);
    var _Platform_effectsQueue = [];
    var _Platform_effectsActive = false;
    function _Platform_enqueueEffects(managers, cmdBag, subBag) {
        _Platform_effectsQueue.push({ p: managers, q: cmdBag, r: subBag });
        if (_Platform_effectsActive)
            return;
        _Platform_effectsActive = true;
        for (var fx; fx = _Platform_effectsQueue.shift();) {
            _Platform_dispatchEffects(fx.p, fx.q, fx.r);
        }
        _Platform_effectsActive = false;
    }
    function _Platform_dispatchEffects(managers, cmdBag, subBag) {
        var effectsDict = {};
        _Platform_gatherEffects(true, cmdBag, effectsDict, null);
        _Platform_gatherEffects(false, subBag, effectsDict, null);
        for (var home in managers) {
            _Scheduler_rawSend(managers[home], {
                $: "fx",
                a: effectsDict[home] || { i: _List_Nil, j: _List_Nil }
            });
        }
    }
    function _Platform_gatherEffects(isCmd, bag, effectsDict, taggers) {
        switch (bag.$) {
            case 1:
                var home = bag.k;
                var effect = _Platform_toEffect(isCmd, home, taggers, bag.l);
                effectsDict[home] = _Platform_insert(isCmd, effect, effectsDict[home]);
                return;
            case 2:
                for (var list = bag.m; list.b; list = list.b) {
                    _Platform_gatherEffects(isCmd, list.a, effectsDict, taggers);
                }
                return;
            case 3:
                _Platform_gatherEffects(isCmd, bag.o, effectsDict, {
                    s: bag.n,
                    t: taggers
                });
                return;
        }
    }
    function _Platform_toEffect(isCmd, home, taggers, value) {
        function applyTaggers(x) {
            for (var temp = taggers; temp; temp = temp.t) {
                x = temp.s(x);
            }
            return x;
        }
        var map = isCmd
            ? _Platform_effectManagers[home].e
            : _Platform_effectManagers[home].f;
        return A2(map, applyTaggers, value);
    }
    function _Platform_insert(isCmd, newEffect, effects) {
        effects = effects || { i: _List_Nil, j: _List_Nil };
        isCmd
            ? (effects.i = _List_Cons(newEffect, effects.i))
            : (effects.j = _List_Cons(newEffect, effects.j));
        return effects;
    }
    function _Platform_checkPortName(name) {
        if (_Platform_effectManagers[name]) {
            _Debug_crash(3, name);
        }
    }
    function _Platform_outgoingPort(name, converter) {
        _Platform_checkPortName(name);
        _Platform_effectManagers[name] = {
            e: _Platform_outgoingPortMap,
            u: converter,
            a: _Platform_setupOutgoingPort
        };
        return _Platform_leaf(name);
    }
    var _Platform_outgoingPortMap_fn = function (tagger, value) { return value; }, _Platform_outgoingPortMap = F2(_Platform_outgoingPortMap_fn);
    function _Platform_setupOutgoingPort(name) {
        var subs = [];
        var converter = _Platform_effectManagers[name].u;
        var init = _Process_sleep(0);
        _Platform_effectManagers[name].b = init;
        _Platform_effectManagers[name].c = F3(function (router, cmdList, state) {
            for (; cmdList.b; cmdList = cmdList.b) {
                var currentSubs = subs;
                var value = _Json_unwrap(converter(cmdList.a));
                for (var i = 0; i < currentSubs.length; i++) {
                    currentSubs[i](value);
                }
            }
            return init;
        });
        function subscribe(callback) {
            subs.push(callback);
        }
        function unsubscribe(callback) {
            subs = subs.slice();
            var index = subs.indexOf(callback);
            if (index >= 0) {
                subs.splice(index, 1);
            }
        }
        return {
            subscribe: subscribe,
            unsubscribe: unsubscribe
        };
    }
    function _Platform_incomingPort(name, converter) {
        _Platform_checkPortName(name);
        _Platform_effectManagers[name] = {
            f: _Platform_incomingPortMap,
            u: converter,
            a: _Platform_setupIncomingPort
        };
        return _Platform_leaf(name);
    }
    var _Platform_incomingPortMap_fn = function (tagger, finalTagger) {
        return function (value) {
            return tagger(finalTagger(value));
        };
    }, _Platform_incomingPortMap = F2(_Platform_incomingPortMap_fn);
    function _Platform_setupIncomingPort(name, sendToApp) {
        var subs = _List_Nil;
        var converter = _Platform_effectManagers[name].u;
        var init = _Scheduler_succeed(null);
        _Platform_effectManagers[name].b = init;
        _Platform_effectManagers[name].c = F3(function (router, subList, state) {
            subs = subList;
            return init;
        });
        function send(incomingValue) {
            var result = _Json_run_fn(converter, _Json_wrap(incomingValue));
            $elm$core$Result$isOk(result) || _Debug_crash(4, name, result.a);
            var value = result.a;
            for (var temp = subs; temp.b; temp = temp.b) {
                sendToApp(temp.a(value));
            }
        }
        return { send: send };
    }
    function _Platform_export(exports) {
        scope["Elm"]
            ? _Platform_mergeExportsProd(scope["Elm"], exports)
            : scope["Elm"] = exports;
    }
    function _Platform_mergeExportsProd(obj, exports) {
        for (var name in exports) {
            (name in obj)
                ? (name == "init")
                    ? _Debug_crash(6)
                    : _Platform_mergeExportsProd(obj[name], exports[name])
                : (obj[name] = exports[name]);
        }
    }
    function _Platform_export_UNUSED(exports) {
        scope["Elm"]
            ? _Platform_mergeExportsDebug("Elm", scope["Elm"], exports)
            : scope["Elm"] = exports;
    }
    function _Platform_mergeExportsDebug(moduleName, obj, exports) {
        for (var name in exports) {
            (name in obj)
                ? (name == "init")
                    ? _Debug_crash(6, moduleName)
                    : _Platform_mergeExportsDebug(moduleName + "." + name, obj[name], exports[name])
                : (obj[name] = exports[name]);
        }
    }
    var _VirtualDom_divertHrefToApp;
    var _VirtualDom_doc = typeof document !== "undefined" ? document : {};
    function _VirtualDom_appendChild(parent, child) {
        parent.appendChild(child);
    }
    var _VirtualDom_init_fn = function (virtualNode, flagDecoder, debugMetadata, args) {
        var node = args["node"];
        node.parentNode.replaceChild(_VirtualDom_render(virtualNode, function () { }), node);
        return {};
    }, _VirtualDom_init = F4(_VirtualDom_init_fn);
    function _VirtualDom_text(string) {
        return {
            $: 0,
            a: string
        };
    }
    var _VirtualDom_nodeNS_fn = function (namespace, tag) {
        return F2(function (factList, kidList) {
            for (var kids = [], descendantsCount = 0; kidList.b; kidList = kidList.b) {
                var kid = kidList.a;
                descendantsCount += (kid.b || 0);
                kids.push(kid);
            }
            descendantsCount += kids.length;
            return {
                $: 1,
                c: tag,
                d: _VirtualDom_organizeFacts(factList),
                e: kids,
                f: namespace,
                b: descendantsCount
            };
        });
    }, _VirtualDom_nodeNS = F2(_VirtualDom_nodeNS_fn);
    var _VirtualDom_node_a0 = undefined, _VirtualDom_node = _VirtualDom_nodeNS(_VirtualDom_node_a0);
    var _VirtualDom_keyedNodeNS_fn = function (namespace, tag) {
        return F2(function (factList, kidList) {
            for (var kids = [], descendantsCount = 0; kidList.b; kidList = kidList.b) {
                var kid = kidList.a;
                descendantsCount += (kid.b.b || 0);
                kids.push(kid);
            }
            descendantsCount += kids.length;
            return {
                $: 2,
                c: tag,
                d: _VirtualDom_organizeFacts(factList),
                e: kids,
                f: namespace,
                b: descendantsCount
            };
        });
    }, _VirtualDom_keyedNodeNS = F2(_VirtualDom_keyedNodeNS_fn);
    var _VirtualDom_keyedNode_a0 = undefined, _VirtualDom_keyedNode = _VirtualDom_keyedNodeNS(_VirtualDom_keyedNode_a0);
    function _VirtualDom_custom(factList, model, render, diff) {
        return {
            $: 3,
            d: _VirtualDom_organizeFacts(factList),
            g: model,
            h: render,
            i: diff
        };
    }
    var _VirtualDom_map_fn = function (tagger, node) {
        return {
            $: 4,
            j: tagger,
            k: node,
            b: 1 + (node.b || 0)
        };
    }, _VirtualDom_map = F2(_VirtualDom_map_fn);
    function _VirtualDom_thunk(refs, thunk) {
        return {
            $: 5,
            l: refs,
            m: thunk,
            k: undefined
        };
    }
    var _VirtualDom_lazy_fn = function (func, a) {
        return _VirtualDom_thunk([func, a], function () {
            return func(a);
        });
    }, _VirtualDom_lazy = F2(_VirtualDom_lazy_fn);
    var _VirtualDom_lazy2_fn = function (func, a, b) {
        return _VirtualDom_thunk([func, a, b], function () {
            return A2(func, a, b);
        });
    }, _VirtualDom_lazy2_fn_unwrapped = function (func, a, b) {
        return _VirtualDom_thunk([func, a, b], function () {
            return func(a, b);
        });
    }, _VirtualDom_lazy2 = F3(_VirtualDom_lazy2_fn);
    var _VirtualDom_lazy3_fn = function (func, a, b, c) {
        return _VirtualDom_thunk([func, a, b, c], function () {
            return A3(func, a, b, c);
        });
    }, _VirtualDom_lazy3_fn_unwrapped = function (func, a, b, c) {
        return _VirtualDom_thunk([func, a, b, c], function () {
            return func(a, b, c);
        });
    }, _VirtualDom_lazy3 = F4(_VirtualDom_lazy3_fn);
    var _VirtualDom_lazy4_fn = function (func, a, b, c, d) {
        return _VirtualDom_thunk([func, a, b, c, d], function () {
            return A4(func, a, b, c, d);
        });
    }, _VirtualDom_lazy4_fn_unwrapped = function (func, a, b, c, d) {
        return _VirtualDom_thunk([func, a, b, c, d], function () {
            return func(a, b, c, d);
        });
    }, _VirtualDom_lazy4 = F5(_VirtualDom_lazy4_fn);
    var _VirtualDom_lazy5_fn = function (func, a, b, c, d, e) {
        return _VirtualDom_thunk([func, a, b, c, d, e], function () {
            return A5(func, a, b, c, d, e);
        });
    }, _VirtualDom_lazy5_fn_unwrapped = function (func, a, b, c, d, e) {
        return _VirtualDom_thunk([func, a, b, c, d, e], function () {
            return func(a, b, c, d, e);
        });
    }, _VirtualDom_lazy5 = F6(_VirtualDom_lazy5_fn);
    var _VirtualDom_lazy6_fn = function (func, a, b, c, d, e, f) {
        return _VirtualDom_thunk([func, a, b, c, d, e, f], function () {
            return A6(func, a, b, c, d, e, f);
        });
    }, _VirtualDom_lazy6_fn_unwrapped = function (func, a, b, c, d, e, f) {
        return _VirtualDom_thunk([func, a, b, c, d, e, f], function () {
            return func(a, b, c, d, e, f);
        });
    }, _VirtualDom_lazy6 = F7(_VirtualDom_lazy6_fn);
    var _VirtualDom_lazy7_fn = function (func, a, b, c, d, e, f, g) {
        return _VirtualDom_thunk([func, a, b, c, d, e, f, g], function () {
            return A7(func, a, b, c, d, e, f, g);
        });
    }, _VirtualDom_lazy7_fn_unwrapped = function (func, a, b, c, d, e, f, g) {
        return _VirtualDom_thunk([func, a, b, c, d, e, f, g], function () {
            return func(a, b, c, d, e, f, g);
        });
    }, _VirtualDom_lazy7 = F8(_VirtualDom_lazy7_fn);
    var _VirtualDom_lazy8_fn = function (func, a, b, c, d, e, f, g, h) {
        return _VirtualDom_thunk([func, a, b, c, d, e, f, g, h], function () {
            return A8(func, a, b, c, d, e, f, g, h);
        });
    }, _VirtualDom_lazy8_fn_unwrapped = function (func, a, b, c, d, e, f, g, h) {
        return _VirtualDom_thunk([func, a, b, c, d, e, f, g, h], function () {
            return func(a, b, c, d, e, f, g, h);
        });
    }, _VirtualDom_lazy8 = F9(_VirtualDom_lazy8_fn);
    var _VirtualDom_on_fn = function (key, handler) {
        return {
            $: "a0",
            n: key,
            o: handler
        };
    }, _VirtualDom_on = F2(_VirtualDom_on_fn);
    var _VirtualDom_style_fn = function (key, value) {
        return {
            $: "a1",
            n: key,
            o: value
        };
    }, _VirtualDom_style = F2(_VirtualDom_style_fn);
    var _VirtualDom_property_fn = function (key, value) {
        return {
            $: "a2",
            n: key,
            o: value
        };
    }, _VirtualDom_property = F2(_VirtualDom_property_fn);
    var _VirtualDom_attribute_fn = function (key, value) {
        return {
            $: "a3",
            n: key,
            o: value
        };
    }, _VirtualDom_attribute = F2(_VirtualDom_attribute_fn);
    var _VirtualDom_attributeNS_fn = function (namespace, key, value) {
        return {
            $: "a4",
            n: key,
            o: { f: namespace, o: value }
        };
    }, _VirtualDom_attributeNS = F3(_VirtualDom_attributeNS_fn);
    var _VirtualDom_RE_script = /^script$/i;
    var _VirtualDom_RE_on_formAction = /^(on|formAction$)/i;
    var _VirtualDom_RE_js = /^\s*j\s*a\s*v\s*a\s*s\s*c\s*r\s*i\s*p\s*t\s*:/i;
    var _VirtualDom_RE_js_html = /^\s*(j\s*a\s*v\s*a\s*s\s*c\s*r\s*i\s*p\s*t\s*:|d\s*a\s*t\s*a\s*:\s*t\s*e\s*x\s*t\s*\/\s*h\s*t\s*m\s*l\s*(,|;))/i;
    function _VirtualDom_noScript(tag) {
        return _VirtualDom_RE_script.test(tag) ? "p" : tag;
    }
    function _VirtualDom_noOnOrFormAction(key) {
        return _VirtualDom_RE_on_formAction.test(key) ? "data-" + key : key;
    }
    function _VirtualDom_noInnerHtmlOrFormAction(key) {
        return key == "innerHTML" || key == "formAction" ? "data-" + key : key;
    }
    function _VirtualDom_noJavaScriptUri(value) {
        return _VirtualDom_RE_js.test(value)
            ? ""
            : value;
    }
    function _VirtualDom_noJavaScriptOrHtmlUri(value) {
        return _VirtualDom_RE_js_html.test(value)
            ? ""
            : value;
    }
    function _VirtualDom_noJavaScriptOrHtmlJson(value) {
        return (typeof _Json_unwrap(value) === "string" && _VirtualDom_RE_js_html.test(_Json_unwrap(value)))
            ? _Json_wrap("") : value;
    }
    var _VirtualDom_mapAttribute_fn = function (func, attr) {
        return (attr.$ === "a0")
            ? _VirtualDom_on_fn(attr.n, _VirtualDom_mapHandler(func, attr.o)) : attr;
    }, _VirtualDom_mapAttribute = F2(_VirtualDom_mapAttribute_fn);
    function _VirtualDom_mapHandler(func, handler) {
        var tag = $elm$virtual_dom$VirtualDom$toHandlerInt(handler);
        return {
            $: handler.$,
            a: !tag
                ? _Json_map1_fn(func, handler.a) : _Json_map2_fn(tag < 3
                ? _VirtualDom_mapEventTuple
                : _VirtualDom_mapEventRecord, $elm$json$Json$Decode$succeed(func), handler.a)
        };
    }
    var _VirtualDom_mapEventTuple_fn = function (func, tuple) {
        return _Utils_Tuple2(func(tuple.a), tuple.b);
    }, _VirtualDom_mapEventTuple = F2(_VirtualDom_mapEventTuple_fn);
    var _VirtualDom_mapEventRecord_fn = function (func, record) {
        return {
            eI: func(record.eI),
            iw: record.iw,
            im: record.im
        };
    }, _VirtualDom_mapEventRecord = F2(_VirtualDom_mapEventRecord_fn);
    function _VirtualDom_organizeFacts(factList) {
        for (var facts = {}; factList.b; factList = factList.b) {
            var entry = factList.a;
            var tag = entry.$;
            var key = entry.n;
            var value = entry.o;
            if (tag === "a2") {
                (key === "className")
                    ? _VirtualDom_addClass(facts, key, _Json_unwrap(value))
                    : facts[key] = _Json_unwrap(value);
                continue;
            }
            var subFacts = facts[tag] || (facts[tag] = {});
            (tag === "a3" && key === "class")
                ? _VirtualDom_addClass(subFacts, key, value)
                : subFacts[key] = value;
        }
        return facts;
    }
    function _VirtualDom_addClass(object, key, newClass) {
        var classes = object[key];
        object[key] = classes ? classes + " " + newClass : newClass;
    }
    function _VirtualDom_render(vNode, eventNode) {
        var tag = vNode.$;
        if (tag === 5) {
            return _VirtualDom_render(vNode.k || (vNode.k = vNode.m()), eventNode);
        }
        if (tag === 0) {
            return _VirtualDom_doc.createTextNode(vNode.a);
        }
        if (tag === 4) {
            var subNode = vNode.k;
            var tagger = vNode.j;
            while (subNode.$ === 4) {
                typeof tagger !== "object"
                    ? tagger = [tagger, subNode.j]
                    : tagger.push(subNode.j);
                subNode = subNode.k;
            }
            var subEventRoot = { j: tagger, p: eventNode };
            var domNode = _VirtualDom_render(subNode, subEventRoot);
            domNode.elm_event_node_ref = subEventRoot;
            return domNode;
        }
        if (tag === 3) {
            var domNode = vNode.h(vNode.g);
            _VirtualDom_applyFacts(domNode, eventNode, vNode.d);
            return domNode;
        }
        var domNode = vNode.f
            ? _VirtualDom_doc.createElementNS(vNode.f, vNode.c)
            : _VirtualDom_doc.createElement(vNode.c);
        if (_VirtualDom_divertHrefToApp && vNode.c == "a") {
            domNode.addEventListener("click", _VirtualDom_divertHrefToApp(domNode));
        }
        _VirtualDom_applyFacts(domNode, eventNode, vNode.d);
        for (var kids = vNode.e, i = 0; i < kids.length; i++) {
            _VirtualDom_appendChild(domNode, _VirtualDom_render(tag === 1 ? kids[i] : kids[i].b, eventNode));
        }
        return domNode;
    }
    function _VirtualDom_applyFacts(domNode, eventNode, facts) {
        for (var key in facts) {
            var value = facts[key];
            key === "a1"
                ? _VirtualDom_applyStyles(domNode, value)
                :
                    key === "a0"
                        ? _VirtualDom_applyEvents(domNode, eventNode, value)
                        :
                            key === "a3"
                                ? _VirtualDom_applyAttrs(domNode, value)
                                :
                                    key === "a4"
                                        ? _VirtualDom_applyAttrsNS(domNode, value)
                                        :
                                            ((key !== "value" && key !== "checked") || domNode[key] !== value) && (domNode[key] = value);
        }
    }
    function _VirtualDom_applyStyles(domNode, styles) {
        var domNodeStyle = domNode.style;
        for (var key in styles) {
            domNodeStyle[key] = styles[key];
        }
    }
    function _VirtualDom_applyAttrs(domNode, attrs) {
        for (var key in attrs) {
            var value = attrs[key];
            typeof value !== "undefined"
                ? domNode.setAttribute(key, value)
                : domNode.removeAttribute(key);
        }
    }
    function _VirtualDom_applyAttrsNS(domNode, nsAttrs) {
        for (var key in nsAttrs) {
            var pair = nsAttrs[key];
            var namespace = pair.f;
            var value = pair.o;
            typeof value !== "undefined"
                ? domNode.setAttributeNS(namespace, key, value)
                : domNode.removeAttributeNS(namespace, key);
        }
    }
    function _VirtualDom_applyEvents(domNode, eventNode, events) {
        var allCallbacks = domNode.elmFs || (domNode.elmFs = {});
        for (var key in events) {
            var newHandler = events[key];
            var oldCallback = allCallbacks[key];
            if (!newHandler) {
                domNode.removeEventListener(key, oldCallback);
                allCallbacks[key] = undefined;
                continue;
            }
            if (oldCallback) {
                var oldHandler = oldCallback.q;
                if (oldHandler.$ === newHandler.$) {
                    oldCallback.q = newHandler;
                    continue;
                }
                domNode.removeEventListener(key, oldCallback);
            }
            oldCallback = _VirtualDom_makeCallback(eventNode, newHandler);
            domNode.addEventListener(key, oldCallback, _VirtualDom_passiveSupported
                && { passive: $elm$virtual_dom$VirtualDom$toHandlerInt(newHandler) < 2 });
            allCallbacks[key] = oldCallback;
        }
    }
    var _VirtualDom_passiveSupported;
    try {
        window.addEventListener("t", null, Object.defineProperty({}, "passive", {
            get: function () { _VirtualDom_passiveSupported = true; }
        }));
    }
    catch (e) { }
    function _VirtualDom_makeCallback(eventNode, initialHandler) {
        function callback(event) {
            var handler = callback.q;
            var result = _Json_runHelp(handler.a, event);
            if (!$elm$core$Result$isOk(result)) {
                return;
            }
            var tag = $elm$virtual_dom$VirtualDom$toHandlerInt(handler);
            var value = result.a;
            var message = !tag ? value : tag < 3 ? value.a : value.eI;
            var stopPropagation = tag == 1 ? value.b : tag == 3 && value.iw;
            var currentEventNode = (stopPropagation && event.stopPropagation(),
                (tag == 2 ? value.b : tag == 3 && value.im) && event.preventDefault(),
                eventNode);
            var tagger;
            var i;
            while (tagger = currentEventNode.j) {
                if (typeof tagger == "function") {
                    message = tagger(message);
                }
                else {
                    for (var i = tagger.length; i--;) {
                        message = tagger[i](message);
                    }
                }
                currentEventNode = currentEventNode.p;
            }
            currentEventNode(message, stopPropagation);
        }
        callback.q = initialHandler;
        return callback;
    }
    function _VirtualDom_equalEvents(x, y) {
        return x.$ == y.$ && _Json_equality(x.a, y.a);
    }
    function _VirtualDom_diff(x, y) {
        var patches = [];
        _VirtualDom_diffHelp(x, y, patches, 0);
        return patches;
    }
    function _VirtualDom_pushPatch(patches, type, index, data) {
        var patch = {
            $: type,
            r: index,
            s: data,
            t: undefined,
            u: undefined
        };
        patches.push(patch);
        return patch;
    }
    function _VirtualDom_diffHelp(x, y, patches, index) {
        if (x === y) {
            return;
        }
        var xType = x.$;
        var yType = y.$;
        if (xType !== yType) {
            if (xType === 1 && yType === 2) {
                y = _VirtualDom_dekey(y);
                yType = 1;
            }
            else {
                _VirtualDom_pushPatch(patches, 0, index, y);
                return;
            }
        }
        switch (yType) {
            case 5:
                var xRefs = x.l;
                var yRefs = y.l;
                var i = xRefs.length;
                var same = i === yRefs.length;
                while (same && i--) {
                    same = xRefs[i] === yRefs[i];
                }
                if (same) {
                    y.k = x.k;
                    return;
                }
                y.k = y.m();
                var subPatches = [];
                _VirtualDom_diffHelp(x.k, y.k, subPatches, 0);
                subPatches.length > 0 && _VirtualDom_pushPatch(patches, 1, index, subPatches);
                return;
            case 4:
                var xTaggers = x.j;
                var yTaggers = y.j;
                var nesting = false;
                var xSubNode = x.k;
                while (xSubNode.$ === 4) {
                    nesting = true;
                    typeof xTaggers !== "object"
                        ? xTaggers = [xTaggers, xSubNode.j]
                        : xTaggers.push(xSubNode.j);
                    xSubNode = xSubNode.k;
                }
                var ySubNode = y.k;
                while (ySubNode.$ === 4) {
                    nesting = true;
                    typeof yTaggers !== "object"
                        ? yTaggers = [yTaggers, ySubNode.j]
                        : yTaggers.push(ySubNode.j);
                    ySubNode = ySubNode.k;
                }
                if (nesting && xTaggers.length !== yTaggers.length) {
                    _VirtualDom_pushPatch(patches, 0, index, y);
                    return;
                }
                if (nesting ? !_VirtualDom_pairwiseRefEqual(xTaggers, yTaggers) : xTaggers !== yTaggers) {
                    _VirtualDom_pushPatch(patches, 2, index, yTaggers);
                }
                _VirtualDom_diffHelp(xSubNode, ySubNode, patches, index + 1);
                return;
            case 0:
                if (x.a !== y.a) {
                    _VirtualDom_pushPatch(patches, 3, index, y.a);
                }
                return;
            case 1:
                _VirtualDom_diffNodes(x, y, patches, index, _VirtualDom_diffKids);
                return;
            case 2:
                _VirtualDom_diffNodes(x, y, patches, index, _VirtualDom_diffKeyedKids);
                return;
            case 3:
                if (x.h !== y.h) {
                    _VirtualDom_pushPatch(patches, 0, index, y);
                    return;
                }
                var factsDiff = _VirtualDom_diffFacts(x.d, y.d);
                factsDiff && _VirtualDom_pushPatch(patches, 4, index, factsDiff);
                var patch = y.i(x.g, y.g);
                patch && _VirtualDom_pushPatch(patches, 5, index, patch);
                return;
        }
    }
    function _VirtualDom_pairwiseRefEqual(as, bs) {
        for (var i = 0; i < as.length; i++) {
            if (as[i] !== bs[i]) {
                return false;
            }
        }
        return true;
    }
    function _VirtualDom_diffNodes(x, y, patches, index, diffKids) {
        if (x.c !== y.c || x.f !== y.f) {
            _VirtualDom_pushPatch(patches, 0, index, y);
            return;
        }
        var factsDiff = _VirtualDom_diffFacts(x.d, y.d);
        factsDiff && _VirtualDom_pushPatch(patches, 4, index, factsDiff);
        diffKids(x, y, patches, index);
    }
    function _VirtualDom_diffFacts(x, y, category) {
        var diff;
        for (var xKey in x) {
            if (xKey === "a1" || xKey === "a0" || xKey === "a3" || xKey === "a4") {
                var subDiff = _VirtualDom_diffFacts(x[xKey], y[xKey] || {}, xKey);
                if (subDiff) {
                    diff = diff || {};
                    diff[xKey] = subDiff;
                }
                continue;
            }
            if (!(xKey in y)) {
                diff = diff || {};
                diff[xKey] =
                    !category
                        ? (typeof x[xKey] === "string" ? "" : null)
                        :
                            (category === "a1")
                                ? ""
                                :
                                    (category === "a0" || category === "a3")
                                        ? undefined
                                        :
                                            { f: x[xKey].f, o: undefined };
                continue;
            }
            var xValue = x[xKey];
            var yValue = y[xKey];
            if (xValue === yValue && xKey !== "value" && xKey !== "checked"
                || category === "a0" && _VirtualDom_equalEvents(xValue, yValue)) {
                continue;
            }
            diff = diff || {};
            diff[xKey] = yValue;
        }
        for (var yKey in y) {
            if (!(yKey in x)) {
                diff = diff || {};
                diff[yKey] = y[yKey];
            }
        }
        return diff;
    }
    function _VirtualDom_diffKids(xParent, yParent, patches, index) {
        var xKids = xParent.e;
        var yKids = yParent.e;
        var xLen = xKids.length;
        var yLen = yKids.length;
        if (xLen > yLen) {
            _VirtualDom_pushPatch(patches, 6, index, {
                v: yLen,
                i: xLen - yLen
            });
        }
        else if (xLen < yLen) {
            _VirtualDom_pushPatch(patches, 7, index, {
                v: xLen,
                e: yKids
            });
        }
        for (var minLen = xLen < yLen ? xLen : yLen, i = 0; i < minLen; i++) {
            var xKid = xKids[i];
            _VirtualDom_diffHelp(xKid, yKids[i], patches, ++index);
            index += xKid.b || 0;
        }
    }
    function _VirtualDom_diffKeyedKids(xParent, yParent, patches, rootIndex) {
        var localPatches = [];
        var changes = {};
        var inserts = [];
        var xKids = xParent.e;
        var yKids = yParent.e;
        var xLen = xKids.length;
        var yLen = yKids.length;
        var xIndex = 0;
        var yIndex = 0;
        var index = rootIndex;
        while (xIndex < xLen && yIndex < yLen) {
            var x = xKids[xIndex];
            var y = yKids[yIndex];
            var xKey = x.a;
            var yKey = y.a;
            var xNode = x.b;
            var yNode = y.b;
            var newMatch = undefined;
            var oldMatch = undefined;
            if (xKey === yKey) {
                index++;
                _VirtualDom_diffHelp(xNode, yNode, localPatches, index);
                index += xNode.b || 0;
                xIndex++;
                yIndex++;
                continue;
            }
            var xNext = xKids[xIndex + 1];
            var yNext = yKids[yIndex + 1];
            if (xNext) {
                var xNextKey = xNext.a;
                var xNextNode = xNext.b;
                oldMatch = yKey === xNextKey;
            }
            if (yNext) {
                var yNextKey = yNext.a;
                var yNextNode = yNext.b;
                newMatch = xKey === yNextKey;
            }
            if (newMatch && oldMatch) {
                index++;
                _VirtualDom_diffHelp(xNode, yNextNode, localPatches, index);
                _VirtualDom_insertNode(changes, localPatches, xKey, yNode, yIndex, inserts);
                index += xNode.b || 0;
                index++;
                _VirtualDom_removeNode(changes, localPatches, xKey, xNextNode, index);
                index += xNextNode.b || 0;
                xIndex += 2;
                yIndex += 2;
                continue;
            }
            if (newMatch) {
                index++;
                _VirtualDom_insertNode(changes, localPatches, yKey, yNode, yIndex, inserts);
                _VirtualDom_diffHelp(xNode, yNextNode, localPatches, index);
                index += xNode.b || 0;
                xIndex += 1;
                yIndex += 2;
                continue;
            }
            if (oldMatch) {
                index++;
                _VirtualDom_removeNode(changes, localPatches, xKey, xNode, index);
                index += xNode.b || 0;
                index++;
                _VirtualDom_diffHelp(xNextNode, yNode, localPatches, index);
                index += xNextNode.b || 0;
                xIndex += 2;
                yIndex += 1;
                continue;
            }
            if (xNext && xNextKey === yNextKey) {
                index++;
                _VirtualDom_removeNode(changes, localPatches, xKey, xNode, index);
                _VirtualDom_insertNode(changes, localPatches, yKey, yNode, yIndex, inserts);
                index += xNode.b || 0;
                index++;
                _VirtualDom_diffHelp(xNextNode, yNextNode, localPatches, index);
                index += xNextNode.b || 0;
                xIndex += 2;
                yIndex += 2;
                continue;
            }
            break;
        }
        while (xIndex < xLen) {
            index++;
            var x = xKids[xIndex];
            var xNode = x.b;
            _VirtualDom_removeNode(changes, localPatches, x.a, xNode, index);
            index += xNode.b || 0;
            xIndex++;
        }
        while (yIndex < yLen) {
            var endInserts = endInserts || [];
            var y = yKids[yIndex];
            _VirtualDom_insertNode(changes, localPatches, y.a, y.b, undefined, endInserts);
            yIndex++;
        }
        if (localPatches.length > 0 || inserts.length > 0 || endInserts) {
            _VirtualDom_pushPatch(patches, 8, rootIndex, {
                w: localPatches,
                x: inserts,
                y: endInserts
            });
        }
    }
    var _VirtualDom_POSTFIX = "_elmW6BL";
    function _VirtualDom_insertNode(changes, localPatches, key, vnode, yIndex, inserts) {
        var entry = changes[key];
        if (!entry) {
            entry = {
                c: 0,
                z: vnode,
                r: yIndex,
                s: undefined
            };
            inserts.push({ r: yIndex, A: entry });
            changes[key] = entry;
            return;
        }
        if (entry.c === 1) {
            inserts.push({ r: yIndex, A: entry });
            entry.c = 2;
            var subPatches = [];
            _VirtualDom_diffHelp(entry.z, vnode, subPatches, entry.r);
            entry.r = yIndex;
            entry.s.s = {
                w: subPatches,
                A: entry
            };
            return;
        }
        _VirtualDom_insertNode(changes, localPatches, key + _VirtualDom_POSTFIX, vnode, yIndex, inserts);
    }
    function _VirtualDom_removeNode(changes, localPatches, key, vnode, index) {
        var entry = changes[key];
        if (!entry) {
            var patch = _VirtualDom_pushPatch(localPatches, 9, index, undefined);
            changes[key] = {
                c: 1,
                z: vnode,
                r: index,
                s: patch
            };
            return;
        }
        if (entry.c === 0) {
            entry.c = 2;
            var subPatches = [];
            _VirtualDom_diffHelp(vnode, entry.z, subPatches, index);
            _VirtualDom_pushPatch(localPatches, 9, index, {
                w: subPatches,
                A: entry
            });
            return;
        }
        _VirtualDom_removeNode(changes, localPatches, key + _VirtualDom_POSTFIX, vnode, index);
    }
    function _VirtualDom_addDomNodes(domNode, vNode, patches, eventNode) {
        _VirtualDom_addDomNodesHelp(domNode, vNode, patches, 0, 0, vNode.b, eventNode);
    }
    function _VirtualDom_addDomNodesHelp(domNode, vNode, patches, i, low, high, eventNode) {
        var patch = patches[i];
        var index = patch.r;
        while (index === low) {
            var patchType = patch.$;
            if (patchType === 1) {
                _VirtualDom_addDomNodes(domNode, vNode.k, patch.s, eventNode);
            }
            else if (patchType === 8) {
                patch.t = domNode;
                patch.u = eventNode;
                var subPatches = patch.s.w;
                if (subPatches.length > 0) {
                    _VirtualDom_addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
                }
            }
            else if (patchType === 9) {
                patch.t = domNode;
                patch.u = eventNode;
                var data = patch.s;
                if (data) {
                    data.A.s = domNode;
                    var subPatches = data.w;
                    if (subPatches.length > 0) {
                        _VirtualDom_addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
                    }
                }
            }
            else {
                patch.t = domNode;
                patch.u = eventNode;
            }
            i++;
            if (!(patch = patches[i]) || (index = patch.r) > high) {
                return i;
            }
        }
        var tag = vNode.$;
        if (tag === 4) {
            var subNode = vNode.k;
            while (subNode.$ === 4) {
                subNode = subNode.k;
            }
            return _VirtualDom_addDomNodesHelp(domNode, subNode, patches, i, low + 1, high, domNode.elm_event_node_ref);
        }
        var vKids = vNode.e;
        var childNodes = domNode.childNodes;
        for (var j = 0; j < vKids.length; j++) {
            low++;
            var vKid = tag === 1 ? vKids[j] : vKids[j].b;
            var nextLow = low + (vKid.b || 0);
            if (low <= index && index <= nextLow) {
                i = _VirtualDom_addDomNodesHelp(childNodes[j], vKid, patches, i, low, nextLow, eventNode);
                if (!(patch = patches[i]) || (index = patch.r) > high) {
                    return i;
                }
            }
            low = nextLow;
        }
        return i;
    }
    function _VirtualDom_applyPatches(rootDomNode, oldVirtualNode, patches, eventNode) {
        if (patches.length === 0) {
            return rootDomNode;
        }
        _VirtualDom_addDomNodes(rootDomNode, oldVirtualNode, patches, eventNode);
        return _VirtualDom_applyPatchesHelp(rootDomNode, patches);
    }
    function _VirtualDom_applyPatchesHelp(rootDomNode, patches) {
        for (var i = 0; i < patches.length; i++) {
            var patch = patches[i];
            var localDomNode = patch.t;
            var newNode = _VirtualDom_applyPatch(localDomNode, patch);
            if (localDomNode === rootDomNode) {
                rootDomNode = newNode;
            }
        }
        return rootDomNode;
    }
    function _VirtualDom_applyPatch(domNode, patch) {
        switch (patch.$) {
            case 0:
                return _VirtualDom_applyPatchRedraw(domNode, patch.s, patch.u);
            case 4:
                _VirtualDom_applyFacts(domNode, patch.u, patch.s);
                return domNode;
            case 3:
                domNode.replaceData(0, domNode.length, patch.s);
                return domNode;
            case 1:
                return _VirtualDom_applyPatchesHelp(domNode, patch.s);
            case 2:
                if (domNode.elm_event_node_ref) {
                    domNode.elm_event_node_ref.j = patch.s;
                }
                else {
                    domNode.elm_event_node_ref = { j: patch.s, p: patch.u };
                }
                return domNode;
            case 6:
                var data = patch.s;
                for (var i = 0; i < data.i; i++) {
                    domNode.removeChild(domNode.childNodes[data.v]);
                }
                return domNode;
            case 7:
                var data = patch.s;
                var kids = data.e;
                var i = data.v;
                var theEnd = domNode.childNodes[i];
                for (; i < kids.length; i++) {
                    domNode.insertBefore(_VirtualDom_render(kids[i], patch.u), theEnd);
                }
                return domNode;
            case 9:
                var data = patch.s;
                if (!data) {
                    domNode.parentNode.removeChild(domNode);
                    return domNode;
                }
                var entry = data.A;
                if (typeof entry.r !== "undefined") {
                    domNode.parentNode.removeChild(domNode);
                }
                entry.s = _VirtualDom_applyPatchesHelp(domNode, data.w);
                return domNode;
            case 8:
                return _VirtualDom_applyPatchReorder(domNode, patch);
            case 5:
                return patch.s(domNode);
            default:
                _Debug_crash(10);
        }
    }
    function _VirtualDom_applyPatchRedraw(domNode, vNode, eventNode) {
        var parentNode = domNode.parentNode;
        var newNode = _VirtualDom_render(vNode, eventNode);
        if (!newNode.elm_event_node_ref) {
            newNode.elm_event_node_ref = domNode.elm_event_node_ref;
        }
        if (parentNode && newNode !== domNode) {
            parentNode.replaceChild(newNode, domNode);
        }
        return newNode;
    }
    function _VirtualDom_applyPatchReorder(domNode, patch) {
        var data = patch.s;
        var frag = _VirtualDom_applyPatchReorderEndInsertsHelp(data.y, patch);
        domNode = _VirtualDom_applyPatchesHelp(domNode, data.w);
        var inserts = data.x;
        for (var i = 0; i < inserts.length; i++) {
            var insert = inserts[i];
            var entry = insert.A;
            var node = entry.c === 2
                ? entry.s
                : _VirtualDom_render(entry.z, patch.u);
            domNode.insertBefore(node, domNode.childNodes[insert.r]);
        }
        if (frag) {
            _VirtualDom_appendChild(domNode, frag);
        }
        return domNode;
    }
    function _VirtualDom_applyPatchReorderEndInsertsHelp(endInserts, patch) {
        if (!endInserts) {
            return;
        }
        var frag = _VirtualDom_doc.createDocumentFragment();
        for (var i = 0; i < endInserts.length; i++) {
            var insert = endInserts[i];
            var entry = insert.A;
            _VirtualDom_appendChild(frag, entry.c === 2
                ? entry.s
                : _VirtualDom_render(entry.z, patch.u));
        }
        return frag;
    }
    function _VirtualDom_virtualize(node) {
        if (node.nodeType === 3) {
            return _VirtualDom_text(node.textContent);
        }
        if (node.nodeType !== 1) {
            return _VirtualDom_text("");
        }
        var attrList = _List_Nil;
        var attrs = node.attributes;
        for (var i = attrs.length; i--;) {
            var attr = attrs[i];
            var name = attr.name;
            var value = attr.value;
            attrList = _List_Cons(_VirtualDom_attribute_fn(name, value), attrList);
        }
        var tag = node.tagName.toLowerCase();
        var kidList = _List_Nil;
        var kids = node.childNodes;
        for (var i = kids.length; i--;) {
            kidList = _List_Cons(_VirtualDom_virtualize(kids[i]), kidList);
        }
        return A3(_VirtualDom_node, tag, attrList, kidList);
    }
    function _VirtualDom_dekey(keyedNode) {
        var keyedKids = keyedNode.e;
        var len = keyedKids.length;
        var kids = new Array(len);
        for (var i = 0; i < len; i++) {
            kids[i] = keyedKids[i].b;
        }
        return {
            $: 1,
            c: keyedNode.c,
            d: keyedNode.d,
            e: kids,
            f: keyedNode.f,
            b: keyedNode.b
        };
    }
    var _Bitwise_and_fn = function (a, b) {
        return a & b;
    }, _Bitwise_and = F2(_Bitwise_and_fn);
    var _Bitwise_or_fn = function (a, b) {
        return a | b;
    }, _Bitwise_or = F2(_Bitwise_or_fn);
    var _Bitwise_xor_fn = function (a, b) {
        return a ^ b;
    }, _Bitwise_xor = F2(_Bitwise_xor_fn);
    function _Bitwise_complement(a) {
        return ~a;
    }
    ;
    var _Bitwise_shiftLeftBy_fn = function (offset, a) {
        return a << offset;
    }, _Bitwise_shiftLeftBy = F2(_Bitwise_shiftLeftBy_fn);
    var _Bitwise_shiftRightBy_fn = function (offset, a) {
        return a >> offset;
    }, _Bitwise_shiftRightBy = F2(_Bitwise_shiftRightBy_fn);
    var _Bitwise_shiftRightZfBy_fn = function (offset, a) {
        return a >>> offset;
    }, _Bitwise_shiftRightZfBy = F2(_Bitwise_shiftRightZfBy_fn);
    var _Parser_isSubString_fn = function (smallString, offset, row, col, bigString) {
        var smallLength = smallString.length;
        var isGood = offset + smallLength <= bigString.length;
        for (var i = 0; isGood && i < smallLength;) {
            var code = bigString.charCodeAt(offset);
            isGood =
                smallString[i++] === bigString[offset++]
                    && (code === 10
                        ? (row++, col = 1)
                        : (col++, (code & 63488) === 55296 ? smallString[i++] === bigString[offset++] : 1));
        }
        return _Utils_Tuple3(isGood ? offset : -1, row, col);
    }, _Parser_isSubString = F5(_Parser_isSubString_fn);
    var _Parser_isSubChar_fn = function (predicate, offset, string) {
        return (string.length <= offset
            ? -1
            :
                (string.charCodeAt(offset) & 63488) === 55296
                    ? (predicate(_Utils_chr(string.substr(offset, 2))) ? offset + 2 : -1)
                    :
                        (predicate(_Utils_chr(string[offset]))
                            ? ((string[offset] === "\n") ? -2 : (offset + 1))
                            : -1));
    }, _Parser_isSubChar = F3(_Parser_isSubChar_fn);
    var _Parser_isAsciiCode_fn = function (code, offset, string) {
        return string.charCodeAt(offset) === code;
    }, _Parser_isAsciiCode = F3(_Parser_isAsciiCode_fn);
    var _Parser_chompBase10_fn = function (offset, string) {
        for (; offset < string.length; offset++) {
            var code = string.charCodeAt(offset);
            if (code < 48 || 57 < code) {
                return offset;
            }
        }
        return offset;
    }, _Parser_chompBase10 = F2(_Parser_chompBase10_fn);
    var _Parser_consumeBase_fn = function (base, offset, string) {
        for (var total = 0; offset < string.length; offset++) {
            var digit = string.charCodeAt(offset) - 48;
            if (digit < 0 || base <= digit)
                break;
            total = base * total + digit;
        }
        return _Utils_Tuple2(offset, total);
    }, _Parser_consumeBase = F3(_Parser_consumeBase_fn);
    var _Parser_consumeBase16_fn = function (offset, string) {
        for (var total = 0; offset < string.length; offset++) {
            var code = string.charCodeAt(offset);
            if (48 <= code && code <= 57) {
                total = 16 * total + code - 48;
            }
            else if (65 <= code && code <= 70) {
                total = 16 * total + code - 55;
            }
            else if (97 <= code && code <= 102) {
                total = 16 * total + code - 87;
            }
            else {
                break;
            }
        }
        return _Utils_Tuple2(offset, total);
    }, _Parser_consumeBase16 = F2(_Parser_consumeBase16_fn);
    var _Parser_findSubString_fn = function (smallString, offset, row, col, bigString) {
        var newOffset = bigString.indexOf(smallString, offset);
        var target = newOffset < 0 ? bigString.length : newOffset + smallString.length;
        while (offset < target) {
            var code = bigString.charCodeAt(offset++);
            code === 10
                ? (col = 1, row++)
                : (col++, (code & 63488) === 55296 && offset++);
        }
        return _Utils_Tuple3(newOffset, row, col);
    }, _Parser_findSubString = F5(_Parser_findSubString_fn);
    var _Regex_never = /.^/;
    var _Regex_fromStringWith_fn = function (options, string) {
        var flags = "g";
        if (options.np) {
            flags += "m";
        }
        if (options.mb) {
            flags += "i";
        }
        try {
            return $elm$core$Maybe$Just(new RegExp(string, flags));
        }
        catch (error) {
            return $elm$core$Maybe$Nothing;
        }
    }, _Regex_fromStringWith = F2(_Regex_fromStringWith_fn);
    var _Regex_contains_fn = function (re, string) {
        return string.match(re) !== null;
    }, _Regex_contains = F2(_Regex_contains_fn);
    var _Regex_findAtMost_fn = function (n, re, str) {
        var out = [];
        var number = 0;
        var string = str;
        var lastIndex = re.lastIndex;
        var prevLastIndex = -1;
        var result;
        while (number++ < n && (result = re.exec(string))) {
            if (prevLastIndex == re.lastIndex)
                break;
            var i = result.length - 1;
            var subs = new Array(i);
            while (i > 0) {
                var submatch = result[i];
                subs[--i] = submatch
                    ? $elm$core$Maybe$Just(submatch)
                    : $elm$core$Maybe$Nothing;
            }
            out.push($elm$regex$Regex$Match_fn(result[0], result.index, number, _List_fromArray(subs)));
            prevLastIndex = re.lastIndex;
        }
        re.lastIndex = lastIndex;
        return _List_fromArray(out);
    }, _Regex_findAtMost = F3(_Regex_findAtMost_fn);
    var _Regex_replaceAtMost_fn = function (n, re, replacer, string) {
        var count = 0;
        function jsReplacer(match) {
            if (count++ >= n) {
                return match;
            }
            var i = arguments.length - 3;
            var submatches = new Array(i);
            while (i > 0) {
                var submatch = arguments[i];
                submatches[--i] = submatch
                    ? $elm$core$Maybe$Just(submatch)
                    : $elm$core$Maybe$Nothing;
            }
            return replacer($elm$regex$Regex$Match_fn(match, arguments[arguments.length - 2], count, _List_fromArray(submatches)));
        }
        return string.replace(re, jsReplacer);
    }, _Regex_replaceAtMost = F4(_Regex_replaceAtMost_fn);
    var _Regex_splitAtMost_fn = function (n, re, str) {
        var string = str;
        var out = [];
        var start = re.lastIndex;
        var restoreLastIndex = re.lastIndex;
        while (n--) {
            var result = re.exec(string);
            if (!result)
                break;
            out.push(string.slice(start, result.index));
            start = re.lastIndex;
        }
        out.push(string.slice(start));
        re.lastIndex = restoreLastIndex;
        return _List_fromArray(out);
    }, _Regex_splitAtMost = F3(_Regex_splitAtMost_fn);
    var _Regex_infinity = Infinity;
    function _Bytes_width(bytes) {
        return bytes.byteLength;
    }
    var _Bytes_getHostEndianness_fn = function (le, be) {
        return _Scheduler_binding(function (callback) {
            callback(_Scheduler_succeed(new Uint8Array(new Uint32Array([1]))[0] === 1 ? le : be));
        });
    }, _Bytes_getHostEndianness = F2(_Bytes_getHostEndianness_fn);
    function _Bytes_encode(encoder) {
        var mutableBytes = new DataView(new ArrayBuffer($elm$bytes$Bytes$Encode$getWidth(encoder)));
        $elm$bytes$Bytes$Encode$write(encoder)(mutableBytes)(0);
        return mutableBytes;
    }
    var _Bytes_write_i8_fn = function (mb, i, n) { mb.setInt8(i, n); return i + 1; }, _Bytes_write_i8 = F3(_Bytes_write_i8_fn);
    var _Bytes_write_i16_fn = function (mb, i, n, isLE) { mb.setInt16(i, n, isLE); return i + 2; }, _Bytes_write_i16 = F4(_Bytes_write_i16_fn);
    var _Bytes_write_i32_fn = function (mb, i, n, isLE) { mb.setInt32(i, n, isLE); return i + 4; }, _Bytes_write_i32 = F4(_Bytes_write_i32_fn);
    var _Bytes_write_u8_fn = function (mb, i, n) { mb.setUint8(i, n); return i + 1; }, _Bytes_write_u8 = F3(_Bytes_write_u8_fn);
    var _Bytes_write_u16_fn = function (mb, i, n, isLE) { mb.setUint16(i, n, isLE); return i + 2; }, _Bytes_write_u16 = F4(_Bytes_write_u16_fn);
    var _Bytes_write_u32_fn = function (mb, i, n, isLE) { mb.setUint32(i, n, isLE); return i + 4; }, _Bytes_write_u32 = F4(_Bytes_write_u32_fn);
    var _Bytes_write_f32_fn = function (mb, i, n, isLE) { mb.setFloat32(i, n, isLE); return i + 4; }, _Bytes_write_f32 = F4(_Bytes_write_f32_fn);
    var _Bytes_write_f64_fn = function (mb, i, n, isLE) { mb.setFloat64(i, n, isLE); return i + 8; }, _Bytes_write_f64 = F4(_Bytes_write_f64_fn);
    var _Bytes_write_bytes_fn = function (mb, offset, bytes) {
        for (var i = 0, len = bytes.byteLength, limit = len - 4; i <= limit; i += 4) {
            mb.setUint32(offset + i, bytes.getUint32(i));
        }
        for (; i < len; i++) {
            mb.setUint8(offset + i, bytes.getUint8(i));
        }
        return offset + len;
    }, _Bytes_write_bytes = F3(_Bytes_write_bytes_fn);
    function _Bytes_getStringWidth(string) {
        for (var width = 0, i = 0; i < string.length; i++) {
            var code = string.charCodeAt(i);
            width +=
                (code < 128) ? 1 :
                    (code < 2048) ? 2 :
                        (code < 55296 || 56319 < code) ? 3 : (i++, 4);
        }
        return width;
    }
    var _Bytes_write_string_fn = function (mb, offset, string) {
        for (var i = 0; i < string.length; i++) {
            var code = string.charCodeAt(i);
            offset +=
                (code < 128)
                    ? (mb.setUint8(offset, code)
                        , 1)
                    :
                        (code < 2048)
                            ? (mb.setUint16(offset, 49280
                                | (code >>> 6 & 31) << 8
                                | code & 63)
                                , 2)
                            :
                                (code < 55296 || 56319 < code)
                                    ? (mb.setUint16(offset, 57472
                                        | (code >>> 12 & 15) << 8
                                        | code >>> 6 & 63)
                                        , mb.setUint8(offset + 2, 128
                                            | code & 63)
                                        , 3)
                                    :
                                        (code = (code - 55296) * 1024 + string.charCodeAt(++i) - 56320 + 65536
                                            , mb.setUint32(offset, 4034953344
                                                | (code >>> 18 & 7) << 24
                                                | (code >>> 12 & 63) << 16
                                                | (code >>> 6 & 63) << 8
                                                | code & 63)
                                            , 4);
        }
        return offset;
    }, _Bytes_write_string = F3(_Bytes_write_string_fn);
    var _Bytes_decode_fn = function (decoder, bytes) {
        try {
            return $elm$core$Maybe$Just(A2(decoder, bytes, 0).b);
        }
        catch (e) {
            return $elm$core$Maybe$Nothing;
        }
    }, _Bytes_decode_fn_unwrapped = function (decoder, bytes) {
        try {
            return $elm$core$Maybe$Just(decoder(bytes, 0).b);
        }
        catch (e) {
            return $elm$core$Maybe$Nothing;
        }
    }, _Bytes_decode = F2(_Bytes_decode_fn);
    var _Bytes_read_i8_fn = function (bytes, offset) { return _Utils_Tuple2(offset + 1, bytes.getInt8(offset)); }, _Bytes_read_i8 = F2(_Bytes_read_i8_fn);
    var _Bytes_read_i16_fn = function (isLE, bytes, offset) { return _Utils_Tuple2(offset + 2, bytes.getInt16(offset, isLE)); }, _Bytes_read_i16 = F3(_Bytes_read_i16_fn);
    var _Bytes_read_i32_fn = function (isLE, bytes, offset) { return _Utils_Tuple2(offset + 4, bytes.getInt32(offset, isLE)); }, _Bytes_read_i32 = F3(_Bytes_read_i32_fn);
    var _Bytes_read_u8_fn = function (bytes, offset) { return _Utils_Tuple2(offset + 1, bytes.getUint8(offset)); }, _Bytes_read_u8 = F2(_Bytes_read_u8_fn);
    var _Bytes_read_u16_fn = function (isLE, bytes, offset) { return _Utils_Tuple2(offset + 2, bytes.getUint16(offset, isLE)); }, _Bytes_read_u16 = F3(_Bytes_read_u16_fn);
    var _Bytes_read_u32_fn = function (isLE, bytes, offset) { return _Utils_Tuple2(offset + 4, bytes.getUint32(offset, isLE)); }, _Bytes_read_u32 = F3(_Bytes_read_u32_fn);
    var _Bytes_read_f32_fn = function (isLE, bytes, offset) { return _Utils_Tuple2(offset + 4, bytes.getFloat32(offset, isLE)); }, _Bytes_read_f32 = F3(_Bytes_read_f32_fn);
    var _Bytes_read_f64_fn = function (isLE, bytes, offset) { return _Utils_Tuple2(offset + 8, bytes.getFloat64(offset, isLE)); }, _Bytes_read_f64 = F3(_Bytes_read_f64_fn);
    var _Bytes_read_bytes_fn = function (len, bytes, offset) {
        return _Utils_Tuple2(offset + len, new DataView(bytes.buffer, bytes.byteOffset + offset, len));
    }, _Bytes_read_bytes = F3(_Bytes_read_bytes_fn);
    var _Bytes_read_string_fn = function (len, bytes, offset) {
        var string = "";
        var end = offset + len;
        for (; offset < end;) {
            var byte = bytes.getUint8(offset++);
            string +=
                (byte < 128)
                    ? String.fromCharCode(byte)
                    :
                        ((byte & 224) === 192)
                            ? String.fromCharCode((byte & 31) << 6 | bytes.getUint8(offset++) & 63)
                            :
                                ((byte & 240) === 224)
                                    ? String.fromCharCode((byte & 15) << 12
                                        | (bytes.getUint8(offset++) & 63) << 6
                                        | bytes.getUint8(offset++) & 63)
                                    :
                                        (byte =
                                            ((byte & 7) << 18
                                                | (bytes.getUint8(offset++) & 63) << 12
                                                | (bytes.getUint8(offset++) & 63) << 6
                                                | bytes.getUint8(offset++) & 63) - 65536
                                            , String.fromCharCode(Math.floor(byte / 1024) + 55296, byte % 1024 + 56320));
        }
        return _Utils_Tuple2(offset, string);
    }, _Bytes_read_string = F3(_Bytes_read_string_fn);
    var _Bytes_decodeFailure_fn = function () { throw 0; }, _Bytes_decodeFailure = F2(_Bytes_decodeFailure_fn);
    var wireRefs = (function () {
        var refs = new Map();
        var counter = 0;
        var f = {};
        f.add = function (obj) {
            counter++;
            refs.set(counter, obj);
            return counter;
        };
        f.getFinal = function (k) {
            let v = refs.get(k);
            refs.delete(k);
            return v;
        };
        f.clear = function () {
            refs = new Map();
        };
        f.all = function () {
            return [refs.keys(), refs];
        };
        return f;
    })();
    var _LamderaCodecs_encodeWithRef = function (a) {
        return wireRefs.add(a);
    };
    var _LamderaCodecs_decodeWithRef = function (ref) {
        return wireRefs.getFinal(ref);
    };
    var _LamderaCodecs_encodeBytes = function (s) { return _Lamdera_Json_wrap(s); };
    function _Lamdera_Json_wrap_UNUSED(value) { return { $: 0, a: value }; }
    function _Lamdera_Json_wrap(value) { return value; }
    function _LamderaCodecs_Json_decodePrim(decoder) {
        return { $: 0, a: decoder };
    }
    var _LamderaCodecs_decodeBytes = _Json_decodePrim(function (value) {
        return (typeof value === "object" && value instanceof DataView)
            ? $elm$core$Result$Ok(value)
            : _Json_expecting("a DataView", value);
    });
    var _LamderaCodecs_debug = function (s) {
        console.log(s);
        return _Utils_Tuple0;
    };
    var _LamderaCodecs_bytesDecodeStrict_fn = function (decoder, bytes) {
        try {
            var res = A2(decoder, bytes, 0);
            const w = bytes.byteLength;
            if (w !== res.a) {
                console.log(`❌ bytesDecodeStrict did not consume all bytes: length:${w}, consumed:${res.a}`, res.b, new Uint8Array(bytes.buffer));
            }
            return $elm$core$Maybe$Just(res.b);
        }
        catch (e) {
            console.log("\u274C bytesDecodeStrict unexpected error:", e);
            return $elm$core$Maybe$Nothing;
        }
    }, _LamderaCodecs_bytesDecodeStrict_fn_unwrapped = function (decoder, bytes) {
        try {
            var res = decoder(bytes, 0);
            const w = bytes.byteLength;
            if (w !== res.a) {
                console.log(`❌ bytesDecodeStrict did not consume all bytes: length:${w}, consumed:${res.a}`, res.b, new Uint8Array(bytes.buffer));
            }
            return $elm$core$Maybe$Just(res.b);
        }
        catch (e) {
            console.log("\u274C bytesDecodeStrict unexpected error:", e);
            return $elm$core$Maybe$Nothing;
        }
    }, _LamderaCodecs_bytesDecodeStrict = F2(_LamderaCodecs_bytesDecodeStrict_fn);
    var _Http_toTask_fn = function (router, toTask, request) {
        return _Scheduler_binding(function (callback) {
            function done(response) {
                callback(toTask(request.kW.a(response)));
            }
            var xhr = new XMLHttpRequest();
            xhr.addEventListener("error", function () { done($elm$http$Http$NetworkError_); });
            xhr.addEventListener("timeout", function () { done($elm$http$Http$Timeout_); });
            xhr.addEventListener("load", function () { done(_Http_toResponse(request.kW.b, xhr)); });
            $elm$core$Maybe$isJust(request.kt) && _Http_track(router, xhr, request.kt.a);
            try {
                xhr.open(request.nh, request.lO, true);
            }
            catch (e) {
                return done($elm$http$Http$BadUrl_(request.lO));
            }
            _Http_configureRequest(xhr, request);
            request.hJ.a && xhr.setRequestHeader("Content-Type", request.hJ.a);
            xhr.send(request.hJ.b);
            return function () { xhr.c = true; xhr.abort(); };
        });
    }, _Http_toTask = F3(_Http_toTask_fn);
    function _Http_configureRequest(xhr, request) {
        for (var headers = request.mS; headers.b; headers = headers.b) {
            xhr.setRequestHeader(headers.a.a, headers.a.b);
        }
        xhr.timeout = request.oq.a || 0;
        xhr.responseType = request.kW.d;
        xhr.withCredentials = request.lW;
    }
    function _Http_toResponse(toBody, xhr) {
        return A2(200 <= xhr.status && xhr.status < 300 ? $elm$http$Http$GoodStatus_ : $elm$http$Http$BadStatus_, _Http_toMetadata(xhr), toBody(xhr.response));
    }
    function _Http_toMetadata(xhr) {
        return {
            lO: xhr.responseURL,
            aF: xhr.status,
            a4: xhr.statusText,
            mS: _Http_parseHeaders(xhr.getAllResponseHeaders())
        };
    }
    function _Http_parseHeaders(rawHeaders) {
        if (!rawHeaders) {
            return $elm$core$Dict$empty;
        }
        var headers = $elm$core$Dict$empty;
        var headerPairs = rawHeaders.split("\r\n");
        for (var i = headerPairs.length; i--;) {
            var headerPair = headerPairs[i];
            var index = headerPair.indexOf(": ");
            if (index > 0) {
                var key = headerPair.substring(0, index);
                var value = headerPair.substring(index + 2);
                headers = $elm$core$Dict$update_fn(key, function (oldValue) {
                    return $elm$core$Maybe$Just($elm$core$Maybe$isJust(oldValue)
                        ? value + ", " + oldValue.a
                        : value);
                }, headers);
            }
        }
        return headers;
    }
    var _Http_expect_fn = function (type, toBody, toValue) {
        return {
            $: 0,
            d: type,
            b: toBody,
            a: toValue
        };
    }, _Http_expect = F3(_Http_expect_fn);
    var _Http_mapExpect_fn = function (func, expect) {
        return {
            $: 0,
            d: expect.d,
            b: expect.b,
            a: function (x) { return func(expect.a(x)); }
        };
    }, _Http_mapExpect = F2(_Http_mapExpect_fn);
    function _Http_toDataView(arrayBuffer) {
        return new DataView(arrayBuffer);
    }
    var _Http_emptyBody = { $: 0 };
    var _Http_pair_fn = function (a, b) { return { $: 0, a: a, b: b }; }, _Http_pair = F2(_Http_pair_fn);
    function _Http_toFormData(parts) {
        for (var formData = new FormData(); parts.b; parts = parts.b) {
            var part = parts.a;
            formData.append(part.a, part.b);
        }
        return formData;
    }
    var _Http_bytesToBlob_fn = function (mime, bytes) {
        return new Blob([bytes], { type: mime });
    }, _Http_bytesToBlob = F2(_Http_bytesToBlob_fn);
    function _Http_track(router, xhr, tracker) {
        xhr.upload.addEventListener("progress", function (event) {
            if (xhr.c) {
                return;
            }
            _Scheduler_rawSpawn(_Platform_sendToSelf_fn(router, _Utils_Tuple2(tracker, $elm$http$Http$Sending({
                od: event.loaded,
                og: event.total
            }))));
        });
        xhr.addEventListener("progress", function (event) {
            if (xhr.c) {
                return;
            }
            _Scheduler_rawSpawn(_Platform_sendToSelf_fn(router, _Utils_Tuple2(tracker, $elm$http$Http$Receiving({
                nY: event.loaded,
                og: event.lengthComputable ? $elm$core$Maybe$Just(event.total) : $elm$core$Maybe$Nothing
            }))));
        });
    }
    function _Url_percentEncode(string) {
        return encodeURIComponent(string);
    }
    function _Url_percentDecode(string) {
        try {
            return $elm$core$Maybe$Just(decodeURIComponent(string));
        }
        catch (e) {
            return $elm$core$Maybe$Nothing;
        }
    }
    var $elm$core$List$cons = _List_cons;
    var $elm$core$Elm$JsArray$foldr = _JsArray_foldr;
    var $elm$core$Array$foldr_fn = function (func, baseCase, _v0) {
        var tree = _v0.c;
        var tail = _v0.d;
        var helper = F2(function (node, acc) {
            if (!node.$) {
                var subTree = node.a;
                return _JsArray_foldr_fn(helper, acc, subTree);
            }
            else {
                var values = node.a;
                return _JsArray_foldr_fn(func, acc, values);
            }
        });
        return _JsArray_foldr_fn(helper, _JsArray_foldr_fn(func, baseCase, tail), tree);
    }, $elm$core$Array$foldr = F3($elm$core$Array$foldr_fn);
    var $elm$core$Array$toList = function (array) {
        return $elm$core$Array$foldr_fn($elm$core$List$cons, _List_Nil, array);
    };
    var $elm$core$Dict$foldr_fn = function (func, acc, t) {
        foldr: while (true) {
            if (t.$ === -2) {
                return acc;
            }
            else {
                var key = t.b;
                var value = t.c;
                var left = t.d;
                var right = t.e;
                var $temp$func = func, $temp$acc = A3(func, key, value, $elm$core$Dict$foldr_fn(func, acc, right)), $temp$t = left;
                func = $temp$func;
                acc = $temp$acc;
                t = $temp$t;
                continue foldr;
            }
        }
    }, $elm$core$Dict$foldr_fn_unwrapped = function (func, acc, t) {
        foldr: while (true) {
            if (t.$ === -2) {
                return acc;
            }
            else {
                var key = t.b;
                var value = t.c;
                var left = t.d;
                var right = t.e;
                var $temp$func = func, $temp$acc = func(key, value, $elm$core$Dict$foldr_fn_unwrapped(func, acc, right)), $temp$t = left;
                func = $temp$func;
                acc = $temp$acc;
                t = $temp$t;
                continue foldr;
            }
        }
    }, $elm$core$Dict$foldr = F3($elm$core$Dict$foldr_fn);
    var $elm$core$Dict$toList = function (dict) {
        return $elm$core$Dict$foldr_fn_unwrapped(function (key, value, list) {
            return _List_Cons(_Utils_Tuple2(key, value), list);
        }, _List_Nil, dict);
    };
    var $elm$core$Dict$keys = function (dict) {
        return $elm$core$Dict$foldr_fn_unwrapped(function (key, value, keyList) {
            return _List_Cons(key, keyList);
        }, _List_Nil, dict);
    };
    var $elm$core$Set$toList = function (_v0) {
        var dict = _v0;
        return $elm$core$Dict$keys(dict);
    };
    var $elm$core$Basics$EQ = 1;
    var $elm$core$Basics$GT = 2;
    var $elm$core$Basics$LT = 0;
    var $author$project$Main$DataErrorPage____ = function (a) {
        return { $: 8, a: a };
    };
    var $elm$core$Maybe$Just = function (a) { return { $: 0, a: a }; };
    var $elm$core$Maybe$Nothing = { $: 1, a: null };
    var $author$project$Main$OnPageChange = function (a) {
        return { $: 8, a: a };
    };
    var $author$project$Main$ActionDataAbout = function (a) {
        return { $: 3, a: a };
    };
    var $author$project$Main$ActionDataArticles = function (a) {
        return { $: 4, a: a };
    };
    var $author$project$Main$ActionDataArticles__ArticleId_ = function (a) {
        return { $: 1, a: a };
    };
    var $author$project$Main$ActionDataArticles__Draft = function (a) {
        return { $: 0, a: a };
    };
    var $author$project$Main$ActionDataIndex = function (a) {
        return { $: 6, a: a };
    };
    var $author$project$Main$ActionDataTwilogs = function (a) {
        return { $: 5, a: a };
    };
    var $author$project$Main$ActionDataTwilogs__Day_ = function (a) {
        return { $: 2, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$StaticHttpRequest$ApiRoute = function (a) {
        return { $: 1, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$StaticHttpRequest$Request_fn = function (a, b) {
        return { $: 0, a: a, b: b };
    }, $dillonkearns$elm_pages_v3_beta$Pages$StaticHttpRequest$Request = F2($dillonkearns$elm_pages_v3_beta$Pages$StaticHttpRequest$Request_fn);
    var $elm$core$Result$Err = function (a) {
        return { $: 1, a: a };
    };
    var $elm$core$Result$Ok = function (a) {
        return { $: 0, a: a };
    };
    var $elm$core$Result$map_fn = function (func, ra) {
        if (!ra.$) {
            var a = ra.a;
            return $elm$core$Result$Ok(func(a));
        }
        else {
            var e = ra.a;
            return $elm$core$Result$Err(e);
        }
    }, $elm$core$Result$map = F2($elm$core$Result$map_fn);
    var $dillonkearns$elm_pages_v3_beta$BackendTask$map_fn = function (fn, requestInfo) {
        if (requestInfo.$ === 1) {
            var value = requestInfo.a;
            return $dillonkearns$elm_pages_v3_beta$Pages$StaticHttpRequest$ApiRoute($elm$core$Result$map_fn(fn, value));
        }
        else {
            var urls = requestInfo.a;
            var lookupFn = requestInfo.b;
            return $dillonkearns$elm_pages_v3_beta$Pages$StaticHttpRequest$Request_fn(urls, A2($dillonkearns$elm_pages_v3_beta$BackendTask$mapLookupFn, fn, lookupFn));
        }
    }, $dillonkearns$elm_pages_v3_beta$BackendTask$map = F2($dillonkearns$elm_pages_v3_beta$BackendTask$map_fn);
    var $dillonkearns$elm_pages_v3_beta$BackendTask$mapLookupFn_fn = function (fn, lookupFn, maybeMock, requests) {
        return $dillonkearns$elm_pages_v3_beta$BackendTask$map_fn(fn, A2(lookupFn, maybeMock, requests));
    }, $dillonkearns$elm_pages_v3_beta$BackendTask$mapLookupFn_fn_unwrapped = function (fn, lookupFn, maybeMock, requests) {
        return $dillonkearns$elm_pages_v3_beta$BackendTask$map_fn(fn, lookupFn(maybeMock, requests));
    }, $dillonkearns$elm_pages_v3_beta$BackendTask$mapLookupFn = F4($dillonkearns$elm_pages_v3_beta$BackendTask$mapLookupFn_fn);
    var $dillonkearns$elm_pages_v3_beta$PageServerResponse$ErrorPage_fn = function (a, b) {
        return { $: 2, a: a, b: b };
    }, $dillonkearns$elm_pages_v3_beta$PageServerResponse$ErrorPage = F2($dillonkearns$elm_pages_v3_beta$PageServerResponse$ErrorPage_fn);
    var $dillonkearns$elm_pages_v3_beta$PageServerResponse$RenderPage_fn = function (a, b) {
        return { $: 0, a: a, b: b };
    }, $dillonkearns$elm_pages_v3_beta$PageServerResponse$RenderPage = F2($dillonkearns$elm_pages_v3_beta$PageServerResponse$RenderPage_fn);
    var $dillonkearns$elm_pages_v3_beta$PageServerResponse$ServerResponse = function (a) {
        return { $: 1, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$Server$Response$map_fn = function (mapFn, pageServerResponse) {
        switch (pageServerResponse.$) {
            case 0:
                var response = pageServerResponse.a;
                var data = pageServerResponse.b;
                return $dillonkearns$elm_pages_v3_beta$PageServerResponse$RenderPage_fn(response, mapFn(data));
            case 1:
                var serverResponse = pageServerResponse.a;
                return $dillonkearns$elm_pages_v3_beta$PageServerResponse$ServerResponse(serverResponse);
            default:
                var error = pageServerResponse.a;
                var response = pageServerResponse.b;
                return $dillonkearns$elm_pages_v3_beta$PageServerResponse$ErrorPage_fn(error, response);
        }
    }, $dillonkearns$elm_pages_v3_beta$Server$Response$map = F2($dillonkearns$elm_pages_v3_beta$Server$Response$map_fn);
    var $elm$core$Basics$False = 1;
    var $elm$core$Basics$apR_fn = function (x, f) {
        return f(x);
    }, $elm$core$Basics$apR = F2($elm$core$Basics$apR_fn);
    var $dillonkearns$elm_pages_v3_beta$Server$Response$plainText = function (string) {
        return $dillonkearns$elm_pages_v3_beta$PageServerResponse$ServerResponse({
            hJ: $elm$core$Maybe$Just(string),
            mS: _List_fromArray([
                _Utils_Tuple2("Content-Type", "text/plain")
            ]),
            gD: false,
            aF: 200
        });
    };
    var $dillonkearns$elm_pages_v3_beta$Server$Response$render = function (data) {
        return $dillonkearns$elm_pages_v3_beta$PageServerResponse$RenderPage_fn({ mS: _List_Nil, aF: 200 }, data);
    };
    var $dillonkearns$elm_pages_v3_beta$BackendTask$succeed = function (value) {
        return $dillonkearns$elm_pages_v3_beta$Pages$StaticHttpRequest$ApiRoute($elm$core$Result$Ok(value));
    };
    var $elm$core$Basics$identity = function (x) {
        return x;
    };
    var $dillonkearns$elm_pages_v3_beta$Internal$Request$Parser = $elm$core$Basics$identity;
    var $elm$json$Json$Decode$Failure_fn = function (a, b) {
        return { $: 3, a: a, b: b };
    }, $elm$json$Json$Decode$Failure = F2($elm$json$Json$Decode$Failure_fn);
    var $elm$json$Json$Decode$Field_fn = function (a, b) {
        return { $: 0, a: a, b: b };
    }, $elm$json$Json$Decode$Field = F2($elm$json$Json$Decode$Field_fn);
    var $elm$json$Json$Decode$Index_fn = function (a, b) {
        return { $: 1, a: a, b: b };
    }, $elm$json$Json$Decode$Index = F2($elm$json$Json$Decode$Index_fn);
    var $elm$json$Json$Decode$OneOf = function (a) {
        return { $: 2, a: a };
    };
    var $elm$core$Basics$add = _Basics_add;
    var $elm$core$String$all = _String_all;
    var $elm$core$Basics$and = _Basics_and;
    var $elm$core$Basics$append = _Utils_append;
    var $elm$json$Json$Encode$encode = _Json_encode;
    var $elm$core$String$fromInt = _String_fromNumber;
    var $elm$core$String$join_fn = function (sep, chunks) {
        return _String_join_fn(sep, _List_toArray(chunks));
    }, $elm$core$String$join = F2($elm$core$String$join_fn);
    var $elm$core$String$split_fn = function (sep, string) {
        return _List_fromArray(_String_split_fn(sep, string));
    }, $elm$core$String$split = F2($elm$core$String$split_fn);
    var $elm$json$Json$Decode$indent = function (str) {
        return $elm$core$String$join_fn("\n    ", $elm$core$String$split_fn("\n", str));
    };
    var $elm$core$List$foldl_fn = function (func, acc, list) {
        foldl: while (true) {
            if (!list.b) {
                return acc;
            }
            else {
                var x = list.a;
                var xs = list.b;
                var $temp$func = func, $temp$acc = A2(func, x, acc), $temp$list = xs;
                func = $temp$func;
                acc = $temp$acc;
                list = $temp$list;
                continue foldl;
            }
        }
    }, $elm$core$List$foldl_fn_unwrapped = function (func, acc, list) {
        foldl: while (true) {
            if (!list.b) {
                return acc;
            }
            else {
                var x = list.a;
                var xs = list.b;
                var $temp$func = func, $temp$acc = func(x, acc), $temp$list = xs;
                func = $temp$func;
                acc = $temp$acc;
                list = $temp$list;
                continue foldl;
            }
        }
    }, $elm$core$List$foldl = F3($elm$core$List$foldl_fn);
    var $elm$core$List$length = function (xs) {
        return $elm$core$List$foldl_fn_unwrapped(function (_v0, i) {
            return i + 1;
        }, 0, xs);
    };
    var $elm$core$List$map2 = _List_map2;
    var $elm$core$Basics$le = _Utils_le;
    var $elm$core$Basics$sub = _Basics_sub;
    var $elm$core$List$rangeHelp_fn = function (lo, hi, list) {
        rangeHelp: while (true) {
            if (_Utils_cmp(lo, hi) < 1) {
                var $temp$lo = lo, $temp$hi = hi - 1, $temp$list = _List_Cons(hi, list);
                lo = $temp$lo;
                hi = $temp$hi;
                list = $temp$list;
                continue rangeHelp;
            }
            else {
                return list;
            }
        }
    }, $elm$core$List$rangeHelp = F3($elm$core$List$rangeHelp_fn);
    var $elm$core$List$range_fn = function (lo, hi) {
        return $elm$core$List$rangeHelp_fn(lo, hi, _List_Nil);
    }, $elm$core$List$range = F2($elm$core$List$range_fn);
    var $elm$core$List$indexedMap_fn = function (f, xs) {
        var tmp = _List_Cons(undefined, _List_Nil);
        var end = tmp;
        for (var i = 0; xs.b; i++, xs = xs.b) {
            var next = _List_Cons(A2(f, i, xs.a), _List_Nil);
            end.b = next;
            end = next;
        }
        return tmp.b;
    }, $elm$core$List$indexedMap_fn_unwrapped = function (f, xs) {
        var tmp = _List_Cons(undefined, _List_Nil);
        var end = tmp;
        for (var i = 0; xs.b; i++, xs = xs.b) {
            var next = _List_Cons(f(i, xs.a), _List_Nil);
            end.b = next;
            end = next;
        }
        return tmp.b;
    }, $elm$core$List$indexedMap = F2($elm$core$List$indexedMap_fn);
    var $elm$core$Char$toCode = _Char_toCode;
    var $elm$core$Char$isLower = function (_char) {
        var code = $elm$core$Char$toCode(_char);
        return (97 <= code) && (code <= 122);
    };
    var $elm$core$Char$isUpper = function (_char) {
        var code = $elm$core$Char$toCode(_char);
        return (code <= 90) && (65 <= code);
    };
    var $elm$core$Basics$or = _Basics_or;
    var $elm$core$Char$isAlpha = function (_char) {
        return $elm$core$Char$isLower(_char) || $elm$core$Char$isUpper(_char);
    };
    var $elm$core$Char$isDigit = function (_char) {
        var code = $elm$core$Char$toCode(_char);
        return (code <= 57) && (48 <= code);
    };
    var $elm$core$Char$isAlphaNum = function (_char) {
        return $elm$core$Char$isLower(_char) || ($elm$core$Char$isUpper(_char) || $elm$core$Char$isDigit(_char));
    };
    var $elm$core$List$reverse = function (list) {
        return $elm$core$List$foldl_fn($elm$core$List$cons, _List_Nil, list);
    };
    var $elm$core$String$uncons = _String_uncons;
    var $elm$json$Json$Decode$errorOneOf_fn = function (i, error) {
        return "\n\n(" + ($elm$core$String$fromInt(i + 1) + (") " + $elm$json$Json$Decode$indent($elm$json$Json$Decode$errorToString(error))));
    }, $elm$json$Json$Decode$errorOneOf = F2($elm$json$Json$Decode$errorOneOf_fn);
    var $elm$json$Json$Decode$errorToString = function (error) {
        return $elm$json$Json$Decode$errorToStringHelp_fn(error, _List_Nil);
    };
    var $elm$json$Json$Decode$errorToStringHelp_fn = function (error, context) {
        errorToStringHelp: while (true) {
            switch (error.$) {
                case 0:
                    var f = error.a;
                    var err = error.b;
                    var isSimple = function () {
                        var _v1 = $elm$core$String$uncons(f);
                        if (_v1.$ === 1) {
                            return false;
                        }
                        else {
                            var _v2 = _v1.a;
                            var _char = _v2.a;
                            var rest = _v2.b;
                            return $elm$core$Char$isAlpha(_char) && _String_all_fn($elm$core$Char$isAlphaNum, rest);
                        }
                    }();
                    var fieldName = isSimple ? ("." + f) : ("['" + (f + "']"));
                    var $temp$error = err, $temp$context = _List_Cons(fieldName, context);
                    error = $temp$error;
                    context = $temp$context;
                    continue errorToStringHelp;
                case 1:
                    var i = error.a;
                    var err = error.b;
                    var indexName = "[" + ($elm$core$String$fromInt(i) + "]");
                    var $temp$error = err, $temp$context = _List_Cons(indexName, context);
                    error = $temp$error;
                    context = $temp$context;
                    continue errorToStringHelp;
                case 2:
                    var errors = error.a;
                    if (!errors.b) {
                        return "Ran into a Json.Decode.oneOf with no possibilities" + function () {
                            if (!context.b) {
                                return "!";
                            }
                            else {
                                return " at json" + $elm$core$String$join_fn("", $elm$core$List$reverse(context));
                            }
                        }();
                    }
                    else {
                        if (!errors.b.b) {
                            var err = errors.a;
                            var $temp$error = err, $temp$context = context;
                            error = $temp$error;
                            context = $temp$context;
                            continue errorToStringHelp;
                        }
                        else {
                            var starter = function () {
                                if (!context.b) {
                                    return "Json.Decode.oneOf";
                                }
                                else {
                                    return "The Json.Decode.oneOf at json" + $elm$core$String$join_fn("", $elm$core$List$reverse(context));
                                }
                            }();
                            var introduction = starter + (" failed in the following " + ($elm$core$String$fromInt($elm$core$List$length(errors)) + " ways:"));
                            return $elm$core$String$join_fn("\n\n", _List_Cons(introduction, $elm$core$List$indexedMap_fn($elm$json$Json$Decode$errorOneOf, errors)));
                        }
                    }
                default:
                    var msg = error.a;
                    var json = error.b;
                    var introduction = function () {
                        if (!context.b) {
                            return "Problem with the given value:\n\n";
                        }
                        else {
                            return "Problem with the value at json" + ($elm$core$String$join_fn("", $elm$core$List$reverse(context)) + ":\n\n    ");
                        }
                    }();
                    return introduction + ($elm$json$Json$Decode$indent(_Json_encode_fn(4, json)) + ("\n\n" + msg));
            }
        }
    }, $elm$json$Json$Decode$errorToStringHelp = F2($elm$json$Json$Decode$errorToStringHelp_fn);
    var $elm$core$Array$branchFactor = 32;
    var $elm$core$Array$Array_elm_builtin_fn = function (a, b, c, d) {
        return { $: 0, a: a, b: b, c: c, d: d };
    }, $elm$core$Array$Array_elm_builtin = F4($elm$core$Array$Array_elm_builtin_fn);
    var $elm$core$Elm$JsArray$empty = _JsArray_empty;
    var $elm$core$Basics$ceiling = _Basics_ceiling;
    var $elm$core$Basics$fdiv = _Basics_fdiv;
    var $elm$core$Basics$logBase_fn = function (base, number) {
        return _Basics_log(number) / _Basics_log(base);
    }, $elm$core$Basics$logBase = F2($elm$core$Basics$logBase_fn);
    var $elm$core$Basics$toFloat = _Basics_toFloat;
    var $elm$core$Array$shiftStep = $elm$core$Basics$ceiling($elm$core$Basics$logBase_fn(2, $elm$core$Array$branchFactor));
    var $elm$core$Array$empty = $elm$core$Array$Array_elm_builtin_fn(0, $elm$core$Array$shiftStep, $elm$core$Elm$JsArray$empty, $elm$core$Elm$JsArray$empty);
    var $elm$core$Elm$JsArray$initialize = _JsArray_initialize;
    var $elm$core$Array$Leaf = function (a) {
        return { $: 1, a: a };
    };
    var $elm$core$Basics$apL_fn = function (f, x) {
        return f(x);
    }, $elm$core$Basics$apL = F2($elm$core$Basics$apL_fn);
    var $elm$core$Basics$eq = _Utils_equal;
    var $elm$core$Basics$floor = _Basics_floor;
    var $elm$core$Elm$JsArray$length = _JsArray_length;
    var $elm$core$Basics$gt = _Utils_gt;
    var $elm$core$Basics$max_fn = function (x, y) {
        return (_Utils_cmp(x, y) > 0) ? x : y;
    }, $elm$core$Basics$max = F2($elm$core$Basics$max_fn);
    var $elm$core$Basics$mul = _Basics_mul;
    var $elm$core$Array$SubTree = function (a) {
        return { $: 0, a: a };
    };
    var $elm$core$Elm$JsArray$initializeFromList = _JsArray_initializeFromList;
    var $elm$core$Array$compressNodes_fn = function (nodes, acc) {
        compressNodes: while (true) {
            var _v0 = _JsArray_initializeFromList_fn($elm$core$Array$branchFactor, nodes);
            var node = _v0.a;
            var remainingNodes = _v0.b;
            var newAcc = _List_Cons($elm$core$Array$SubTree(node), acc);
            if (!remainingNodes.b) {
                return $elm$core$List$reverse(newAcc);
            }
            else {
                var $temp$nodes = remainingNodes, $temp$acc = newAcc;
                nodes = $temp$nodes;
                acc = $temp$acc;
                continue compressNodes;
            }
        }
    }, $elm$core$Array$compressNodes = F2($elm$core$Array$compressNodes_fn);
    var $elm$core$Tuple$first = function (_v0) {
        var x = _v0.a;
        return x;
    };
    var $elm$core$Array$treeFromBuilder_fn = function (nodeList, nodeListSize) {
        treeFromBuilder: while (true) {
            var newNodeSize = $elm$core$Basics$ceiling(nodeListSize / $elm$core$Array$branchFactor);
            if (newNodeSize === 1) {
                return _JsArray_initializeFromList_fn($elm$core$Array$branchFactor, nodeList).a;
            }
            else {
                var $temp$nodeList = $elm$core$Array$compressNodes_fn(nodeList, _List_Nil), $temp$nodeListSize = newNodeSize;
                nodeList = $temp$nodeList;
                nodeListSize = $temp$nodeListSize;
                continue treeFromBuilder;
            }
        }
    }, $elm$core$Array$treeFromBuilder = F2($elm$core$Array$treeFromBuilder_fn);
    var $elm$core$Array$builderToArray_fn = function (reverseNodeList, builder) {
        if (!builder.aw) {
            return $elm$core$Array$Array_elm_builtin_fn($elm$core$Elm$JsArray$length(builder.aG), $elm$core$Array$shiftStep, $elm$core$Elm$JsArray$empty, builder.aG);
        }
        else {
            var treeLen = builder.aw * $elm$core$Array$branchFactor;
            var depth = $elm$core$Basics$floor($elm$core$Basics$logBase_fn($elm$core$Array$branchFactor, treeLen - 1));
            var correctNodeList = reverseNodeList ? $elm$core$List$reverse(builder.aN) : builder.aN;
            var tree = $elm$core$Array$treeFromBuilder_fn(correctNodeList, builder.aw);
            return $elm$core$Array$Array_elm_builtin_fn($elm$core$Elm$JsArray$length(builder.aG) + treeLen, $elm$core$Basics$max_fn(5, depth * $elm$core$Array$shiftStep), tree, builder.aG);
        }
    }, $elm$core$Array$builderToArray = F2($elm$core$Array$builderToArray_fn);
    var $elm$core$Basics$idiv = _Basics_idiv;
    var $elm$core$Basics$lt = _Utils_lt;
    var $elm$core$Array$initializeHelp_fn = function (fn, fromIndex, len, nodeList, tail) {
        initializeHelp: while (true) {
            if (fromIndex < 0) {
                return $elm$core$Array$builderToArray_fn(false, { aN: nodeList, aw: (len / $elm$core$Array$branchFactor) | 0, aG: tail });
            }
            else {
                var leaf = $elm$core$Array$Leaf(_JsArray_initialize_fn($elm$core$Array$branchFactor, fromIndex, fn));
                var $temp$fn = fn, $temp$fromIndex = fromIndex - $elm$core$Array$branchFactor, $temp$len = len, $temp$nodeList = _List_Cons(leaf, nodeList), $temp$tail = tail;
                fn = $temp$fn;
                fromIndex = $temp$fromIndex;
                len = $temp$len;
                nodeList = $temp$nodeList;
                tail = $temp$tail;
                continue initializeHelp;
            }
        }
    }, $elm$core$Array$initializeHelp = F5($elm$core$Array$initializeHelp_fn);
    var $elm$core$Basics$remainderBy = _Basics_remainderBy;
    var $elm$core$Array$initialize_fn = function (len, fn) {
        if (len <= 0) {
            return $elm$core$Array$empty;
        }
        else {
            var tailLen = len % $elm$core$Array$branchFactor;
            var tail = _JsArray_initialize_fn(tailLen, len - tailLen, fn);
            var initialFromIndex = (len - tailLen) - $elm$core$Array$branchFactor;
            return $elm$core$Array$initializeHelp_fn(fn, initialFromIndex, len, _List_Nil, tail);
        }
    }, $elm$core$Array$initialize = F2($elm$core$Array$initialize_fn);
    var $elm$core$Basics$True = 0;
    var $elm$core$Result$isOk = function (result) {
        if (!result.$) {
            return true;
        }
        else {
            return false;
        }
    };
    var $elm$json$Json$Decode$succeed = _Json_succeed;
    var $dillonkearns$elm_pages_v3_beta$Server$Request$succeed = function (value) {
        return $elm$json$Json$Decode$succeed(_Utils_Tuple2($elm$core$Result$Ok(value), _List_Nil));
    };
    var $author$project$Route$About$action = function (routeParams) {
        return $dillonkearns$elm_pages_v3_beta$Server$Request$succeed($dillonkearns$elm_pages_v3_beta$BackendTask$succeed($dillonkearns$elm_pages_v3_beta$Server$Response$render({})));
    };
    var $author$project$RouteBuilder$buildWithLocalState_fn = function (config, builderState) {
        var record = builderState;
        return {
            r: record.r,
            iW: record.iW,
            et: record.et,
            aL: record.aL,
            dI: F2(function (shared, app) {
                return A2(config.dI, app, shared);
            }),
            a8: record.a8,
            fJ: $elm$core$Maybe$Nothing,
            om: record.om,
            dW: F4(function (routeParams, path, model, sharedModel) {
                return A4(config.dW, routeParams, path, sharedModel, model);
            }),
            cF: F4(function (app, msg, model, sharedModel) {
                var _v1 = A4(config.cF, app, sharedModel, msg, model);
                var updatedModel = _v1.a;
                var cmd = _v1.b;
                return _Utils_Tuple3(updatedModel, cmd, $elm$core$Maybe$Nothing);
            }),
            X: F3(function (model, sharedModel, app) {
                return A3(config.X, app, model, sharedModel);
            })
        };
    }, $author$project$RouteBuilder$buildWithLocalState = F2($author$project$RouteBuilder$buildWithLocalState_fn);
    var $author$project$Route$About$data = function (routeParams) {
        return $dillonkearns$elm_pages_v3_beta$Server$Request$succeed($dillonkearns$elm_pages_v3_beta$BackendTask$succeed($dillonkearns$elm_pages_v3_beta$Server$Response$render({})));
    };
    var $author$project$Route$About$head = function (app) {
        return _List_Nil;
    };
    var $author$project$Effect$None = { $: 0 };
    var $author$project$Effect$none = $author$project$Effect$None;
    var $author$project$Route$About$init_fn = function (app, shared) {
        return _Utils_Tuple2({}, $author$project$Effect$none);
    }, $author$project$Route$About$init = F2($author$project$Route$About$init_fn);
    var $author$project$RouteBuilder$WithData = $elm$core$Basics$identity;
    var $dillonkearns$elm_pages_v3_beta$BackendTask$fail = function (error) {
        return $dillonkearns$elm_pages_v3_beta$Pages$StaticHttpRequest$ApiRoute($elm$core$Result$Err(error));
    };
    var $elm$core$List$isEmpty = function (xs) {
        if (!xs.b) {
            return true;
        }
        else {
            return false;
        }
    };
    var $elm$json$Json$Encode$object = function (pairs) {
        return _Json_wrap($elm$core$List$foldl_fn_unwrapped(function (_v0, obj) {
            var k = _v0.a;
            var v = _v0.b;
            return _Json_addField_fn(k, v, obj);
        }, _Json_emptyObject(0), pairs));
    };
    var $dillonkearns$elm_pages_v3_beta$BackendTask$andThen_fn = function (fn, requestInfo) {
        andThen: while (true) {
            if (requestInfo.$ === 1) {
                var a = requestInfo.a;
                if (!a.$) {
                    var okA = a.a;
                    return fn(okA);
                }
                else {
                    var errA = a.a;
                    return $dillonkearns$elm_pages_v3_beta$BackendTask$fail(errA);
                }
            }
            else {
                var urls = requestInfo.a;
                var lookupFn = requestInfo.b;
                if ($elm$core$List$isEmpty(urls)) {
                    var $temp$fn = fn, $temp$requestInfo = A2(lookupFn, $elm$core$Maybe$Nothing, $elm$json$Json$Encode$object(_List_Nil));
                    fn = $temp$fn;
                    requestInfo = $temp$requestInfo;
                    continue andThen;
                }
                else {
                    return $dillonkearns$elm_pages_v3_beta$Pages$StaticHttpRequest$Request_fn(urls, F2(function (maybeMockResolver, responses) {
                        return $dillonkearns$elm_pages_v3_beta$BackendTask$andThen_fn(fn, A2(lookupFn, maybeMockResolver, responses));
                    }));
                }
            }
        }
    }, $dillonkearns$elm_pages_v3_beta$BackendTask$andThen = F2($dillonkearns$elm_pages_v3_beta$BackendTask$andThen_fn);
    var $elm$json$Json$Decode$decodeValue = _Json_run;
    var $dillonkearns$elm_pages_v3_beta$Server$Request$errorToString = function (validationError_) {
        switch (validationError_.$) {
            case 0:
                var message = validationError_.a;
                return message;
            case 1:
                var validationErrors = validationError_.a;
                return "Server.Request.oneOf failed in the following " + ($elm$core$String$fromInt($elm$core$List$length(validationErrors)) + (" ways:\n\n" + $elm$core$String$join_fn("\n\n", $elm$core$List$indexedMap_fn_unwrapped(function (index, error) {
                    return "(" + ($elm$core$String$fromInt(index + 1) + (") " + $dillonkearns$elm_pages_v3_beta$Server$Request$errorToString(error)));
                }, validationErrors))));
            default:
                var record = validationError_.a;
                return "Missing query param \"" + (record.gK + ("\". Query string was `" + (record.fX + "`")));
        }
    };
    var $elm$core$List$foldrHelper_fn = function (fn, acc, ctr, ls) {
        if (!ls.b) {
            return acc;
        }
        else {
            var a = ls.a;
            var r1 = ls.b;
            if (!r1.b) {
                return A2(fn, a, acc);
            }
            else {
                var b = r1.a;
                var r2 = r1.b;
                if (!r2.b) {
                    return A2(fn, a, A2(fn, b, acc));
                }
                else {
                    var c = r2.a;
                    var r3 = r2.b;
                    if (!r3.b) {
                        return A2(fn, a, A2(fn, b, A2(fn, c, acc)));
                    }
                    else {
                        var d = r3.a;
                        var r4 = r3.b;
                        var res = (ctr > 500) ? $elm$core$List$foldl_fn(fn, acc, $elm$core$List$reverse(r4)) : $elm$core$List$foldrHelper_fn(fn, acc, ctr + 1, r4);
                        return A2(fn, a, A2(fn, b, A2(fn, c, A2(fn, d, res))));
                    }
                }
            }
        }
    }, $elm$core$List$foldrHelper_fn_unwrapped = function (fn, acc, ctr, ls) {
        if (!ls.b) {
            return acc;
        }
        else {
            var a = ls.a;
            var r1 = ls.b;
            if (!r1.b) {
                return fn(a, acc);
            }
            else {
                var b = r1.a;
                var r2 = r1.b;
                if (!r2.b) {
                    return fn(a, fn(b, acc));
                }
                else {
                    var c = r2.a;
                    var r3 = r2.b;
                    if (!r3.b) {
                        return fn(a, fn(b, fn(c, acc)));
                    }
                    else {
                        var d = r3.a;
                        var r4 = r3.b;
                        var res = (ctr > 500) ? $elm$core$List$foldl_fn_unwrapped(fn, acc, $elm$core$List$reverse(r4)) : $elm$core$List$foldrHelper_fn_unwrapped(fn, acc, ctr + 1, r4);
                        return fn(a, fn(b, fn(c, fn(d, res))));
                    }
                }
            }
        }
    }, $elm$core$List$foldrHelper = F4($elm$core$List$foldrHelper_fn);
    var $elm$core$List$foldr_fn = function (fn, acc, ls) {
        return $elm$core$List$foldrHelper_fn(fn, acc, 0, ls);
    }, $elm$core$List$foldr = F3($elm$core$List$foldr_fn);
    var $elm$core$List$map_fn = function (f, xs) {
        var tmp = _List_Cons(undefined, _List_Nil);
        var end = tmp;
        for (; xs.b; xs
            = xs.b) {
            var next = _List_Cons(f(xs.a), _List_Nil);
            end.b = next;
            end = next;
        }
        return tmp.b;
    }, $elm$core$List$map = F2($elm$core$List$map_fn);
    var $turboMaCk$non_empty_list_alias$List$NonEmpty$toList = function (_v0) {
        var h = _v0.a;
        var t = _v0.b;
        return _List_Cons(h, t);
    };
    var $dillonkearns$elm_pages_v3_beta$Server$Request$errorsToString = function (validationErrors) {
        return $elm$core$String$join_fn("\n", $elm$core$List$map_fn($dillonkearns$elm_pages_v3_beta$Server$Request$errorToString, $turboMaCk$non_empty_list_alias$List$NonEmpty$toList(validationErrors)));
    };
    var $dillonkearns$elm_pages_v3_beta$BackendTask$fromResult = function (result) {
        if (!result.$) {
            var okValue = result.a;
            return $dillonkearns$elm_pages_v3_beta$BackendTask$succeed(okValue);
        }
        else {
            var error = result.a;
            return $dillonkearns$elm_pages_v3_beta$BackendTask$fail(error);
        }
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$FatalError$FatalError = $elm$core$Basics$identity;
    var $dillonkearns$elm_pages_v3_beta$FatalError$build = function (info) {
        return info;
    };
    var $dillonkearns$elm_pages_v3_beta$FatalError$fromString = function (string) {
        return $dillonkearns$elm_pages_v3_beta$FatalError$build({ hJ: string, jE: "Custom Error" });
    };
    var $elm$json$Json$Decode$map = _Json_map1;
    var $dillonkearns$elm_pages_v3_beta$Server$Request$getDecoder = function (_v0) {
        var decoder = _v0;
        return _Json_map1_fn(function (_v1) {
            var result = _v1.a;
            var validationErrors = _v1.b;
            var _v2 = _Utils_Tuple2(result, validationErrors);
            if (!_v2.a.$) {
                if (!_v2.b.b) {
                    var value = _v2.a.a;
                    return $elm$core$Result$Ok(value);
                }
                else {
                    var _v3 = _v2.b;
                    var firstError = _v3.a;
                    var rest = _v3.b;
                    return $elm$core$Result$Err(_Utils_Tuple2(firstError, rest));
                }
            }
            else {
                var fatalError = _v2.a.a;
                var errors = _v2.b;
                return $elm$core$Result$Err(_Utils_Tuple2(fatalError, errors));
            }
        }, decoder);
    };
    var $elm$core$Result$mapError_fn = function (f, result) {
        if (!result.$) {
            var v = result.a;
            return $elm$core$Result$Ok(v);
        }
        else {
            var e = result.a;
            return $elm$core$Result$Err(f(e));
        }
    }, $elm$core$Result$mapError = F2($elm$core$Result$mapError_fn);
    var $dillonkearns$elm_pages_v3_beta$BackendTask$onError_fn = function (fromError, backendTask) {
        onError: while (true) {
            if (backendTask.$ === 1) {
                var a = backendTask.a;
                if (!a.$) {
                    var okA = a.a;
                    return $dillonkearns$elm_pages_v3_beta$BackendTask$succeed(okA);
                }
                else {
                    var errA = a.a;
                    return fromError(errA);
                }
            }
            else {
                var urls = backendTask.a;
                var lookupFn = backendTask.b;
                if ($elm$core$List$isEmpty(urls)) {
                    var $temp$fromError = fromError, $temp$backendTask = A2(lookupFn, $elm$core$Maybe$Nothing, $elm$json$Json$Encode$object(_List_Nil));
                    fromError = $temp$fromError;
                    backendTask = $temp$backendTask;
                    continue onError;
                }
                else {
                    return $dillonkearns$elm_pages_v3_beta$Pages$StaticHttpRequest$Request_fn(urls, F2(function (maybeMockResolver, responses) {
                        return $dillonkearns$elm_pages_v3_beta$BackendTask$onError_fn(fromError, A2(lookupFn, maybeMockResolver, responses));
                    }));
                }
            }
        }
    }, $dillonkearns$elm_pages_v3_beta$BackendTask$onError = F2($dillonkearns$elm_pages_v3_beta$BackendTask$onError_fn);
    var $author$project$RouteBuilder$serverRender = function (_v0) {
        var head = _v0.aL;
        var action = _v0.r;
        var data = _v0.iW;
        return {
            r: F2(function (requestPayload, routeParams) {
                return $dillonkearns$elm_pages_v3_beta$BackendTask$andThen_fn(function (rendered) {
                    if (!rendered.$) {
                        var okRendered = rendered.a;
                        return okRendered;
                    }
                    else {
                        var error = rendered.a;
                        return $dillonkearns$elm_pages_v3_beta$BackendTask$fail($dillonkearns$elm_pages_v3_beta$FatalError$fromString($dillonkearns$elm_pages_v3_beta$Server$Request$errorsToString(error)));
                    }
                }, function (decoder) {
                    return $dillonkearns$elm_pages_v3_beta$BackendTask$onError_fn(function (error) {
                        return $dillonkearns$elm_pages_v3_beta$BackendTask$fail($dillonkearns$elm_pages_v3_beta$FatalError$fromString(error));
                    }, $dillonkearns$elm_pages_v3_beta$BackendTask$fromResult($elm$core$Result$mapError_fn($elm$json$Json$Decode$errorToString, _Json_run_fn(decoder, requestPayload))));
                }($dillonkearns$elm_pages_v3_beta$Server$Request$getDecoder(action(routeParams))));
            }),
            iW: F2(function (requestPayload, routeParams) {
                return $dillonkearns$elm_pages_v3_beta$BackendTask$andThen_fn(function (rendered) {
                    if (!rendered.$) {
                        var okRendered = rendered.a;
                        return okRendered;
                    }
                    else {
                        var error = rendered.a;
                        return $dillonkearns$elm_pages_v3_beta$BackendTask$fail($dillonkearns$elm_pages_v3_beta$FatalError$fromString($dillonkearns$elm_pages_v3_beta$Server$Request$errorsToString(error)));
                    }
                }, function (decoder) {
                    return $dillonkearns$elm_pages_v3_beta$BackendTask$onError_fn(function (error) {
                        return $dillonkearns$elm_pages_v3_beta$BackendTask$fail($dillonkearns$elm_pages_v3_beta$FatalError$fromString(error));
                    }, $dillonkearns$elm_pages_v3_beta$BackendTask$fromResult($elm$core$Result$mapError_fn($elm$json$Json$Decode$errorToString, _Json_run_fn(decoder, requestPayload))));
                }($dillonkearns$elm_pages_v3_beta$Server$Request$getDecoder(data(routeParams))));
            }),
            et: F3(function (moduleContext, toRecord, routeParams) {
                return $dillonkearns$elm_pages_v3_beta$BackendTask$succeed($elm$core$Maybe$Nothing);
            }),
            aL: head,
            a8: "serverless",
            g8: true,
            om: $dillonkearns$elm_pages_v3_beta$BackendTask$succeed(_List_Nil)
        };
    };
    var $elm$core$Platform$Sub$batch = _Platform_batch;
    var $elm$core$Platform$Sub$none = $elm$core$Platform$Sub$batch(_List_Nil);
    var $author$project$Route$About$subscriptions_fn = function (routeParams, path, shared, model) {
        return $elm$core$Platform$Sub$none;
    }, $author$project$Route$About$subscriptions = F4($author$project$Route$About$subscriptions_fn);
    var $author$project$Route$About$update_fn = function (app, shared, msg, model) {
        return _Utils_Tuple2(model, $author$project$Effect$none);
    }, $author$project$Route$About$update = F4($author$project$Route$About$update_fn);
    var $elm$json$Json$Decode$map2 = _Json_map2;
    var $elm$virtual_dom$VirtualDom$toHandlerInt = function (handler) {
        switch (handler.$) {
            case 0:
                return 0;
            case 1:
                return 1;
            case 2:
                return 2;
            default:
                return 3;
        }
    };
    var $elm$html$Html$h2 = _VirtualDom_nodeNS_fn(_VirtualDom_node_a0, "h2"), $elm$html$Html$h2_fn = $elm$html$Html$h2.a2;
    var $elm$virtual_dom$VirtualDom$text = _VirtualDom_text;
    var $elm$html$Html$text = $elm$virtual_dom$VirtualDom$text;
    var $author$project$Route$About$view_fn = function (app, shared, model) {
        return {
            hJ: _List_fromArray([
                $elm$html$Html$h2_fn(_List_Nil, _List_fromArray([
                    $elm$html$Html$text("New Page")
                ]))
            ]),
            jE: "About"
        };
    }, $author$project$Route$About$view = F3($author$project$Route$About$view_fn);
    var $author$project$Route$About$route = $author$project$RouteBuilder$buildWithLocalState_fn({ dI: $author$project$Route$About$init, dW: $author$project$Route$About$subscriptions, cF: $author$project$Route$About$update, X: $author$project$Route$About$view }, $author$project$RouteBuilder$serverRender({ r: $author$project$Route$About$action, iW: $author$project$Route$About$data, aL: $author$project$Route$About$head }));
    var $author$project$Route$Articles$action = function (routeParams) {
        return $dillonkearns$elm_pages_v3_beta$Server$Request$succeed($dillonkearns$elm_pages_v3_beta$BackendTask$succeed($dillonkearns$elm_pages_v3_beta$Server$Response$render({})));
    };
    var $author$project$Route$Articles$data = function (routeParams) {
        return $dillonkearns$elm_pages_v3_beta$Server$Request$succeed($dillonkearns$elm_pages_v3_beta$BackendTask$succeed($dillonkearns$elm_pages_v3_beta$Server$Response$render({})));
    };
    var $author$project$Route$Articles$head = function (app) {
        return _List_Nil;
    };
    var $author$project$Route$Articles$init_fn = function (app, shared) {
        return _Utils_Tuple2({}, $author$project$Effect$none);
    }, $author$project$Route$Articles$init = F2($author$project$Route$Articles$init_fn);
    var $author$project$Route$Articles$subscriptions_fn = function (routeParams, path, shared, model) {
        return $elm$core$Platform$Sub$none;
    }, $author$project$Route$Articles$subscriptions = F4($author$project$Route$Articles$subscriptions_fn);
    var $author$project$Route$Articles$update_fn = function (app, shared, msg, model) {
        return _Utils_Tuple2(model, $author$project$Effect$none);
    }, $author$project$Route$Articles$update = F4($author$project$Route$Articles$update_fn);
    var $author$project$Route$Articles$view_fn = function (app, shared, model) {
        return {
            hJ: _List_fromArray([
                $elm$html$Html$h2_fn(_List_Nil, _List_fromArray([
                    $elm$html$Html$text("New Page")
                ]))
            ]),
            jE: "Articles"
        };
    }, $author$project$Route$Articles$view = F3($author$project$Route$Articles$view_fn);
    var $author$project$Route$Articles$route = $author$project$RouteBuilder$buildWithLocalState_fn({ dI: $author$project$Route$Articles$init, dW: $author$project$Route$Articles$subscriptions, cF: $author$project$Route$Articles$update, X: $author$project$Route$Articles$view }, $author$project$RouteBuilder$serverRender({ r: $author$project$Route$Articles$action, iW: $author$project$Route$Articles$data, aL: $author$project$Route$Articles$head }));
    var $author$project$Route$Articles$ArticleId_$action = function (routeParams) {
        return $dillonkearns$elm_pages_v3_beta$Server$Request$succeed($dillonkearns$elm_pages_v3_beta$BackendTask$succeed($dillonkearns$elm_pages_v3_beta$Server$Response$render({})));
    };
    var $author$project$Route$Articles$ArticleId_$data = function (routeParams) {
        return $dillonkearns$elm_pages_v3_beta$Server$Request$succeed($dillonkearns$elm_pages_v3_beta$BackendTask$succeed($dillonkearns$elm_pages_v3_beta$Server$Response$render({})));
    };
    var $author$project$Route$Articles$ArticleId_$head = function (app) {
        return _List_Nil;
    };
    var $author$project$Route$Articles$ArticleId_$init_fn = function (app, shared) {
        return _Utils_Tuple2({}, $author$project$Effect$none);
    }, $author$project$Route$Articles$ArticleId_$init = F2($author$project$Route$Articles$ArticleId_$init_fn);
    var $author$project$Route$Articles$ArticleId_$subscriptions_fn = function (routeParams, path, shared, model) {
        return $elm$core$Platform$Sub$none;
    }, $author$project$Route$Articles$ArticleId_$subscriptions = F4($author$project$Route$Articles$ArticleId_$subscriptions_fn);
    var $author$project$Route$Articles$ArticleId_$update_fn = function (app, shared, msg, model) {
        return _Utils_Tuple2(model, $author$project$Effect$none);
    }, $author$project$Route$Articles$ArticleId_$update = F4($author$project$Route$Articles$ArticleId_$update_fn);
    var $author$project$Route$Articles$ArticleId_$view_fn = function (app, shared, model) {
        return {
            hJ: _List_fromArray([
                $elm$html$Html$h2_fn(_List_Nil, _List_fromArray([
                    $elm$html$Html$text("New Page")
                ]))
            ]),
            jE: "Articles.ArticleId_"
        };
    }, $author$project$Route$Articles$ArticleId_$view = F3($author$project$Route$Articles$ArticleId_$view_fn);
    var $author$project$Route$Articles$ArticleId_$route = $author$project$RouteBuilder$buildWithLocalState_fn({ dI: $author$project$Route$Articles$ArticleId_$init, dW: $author$project$Route$Articles$ArticleId_$subscriptions, cF: $author$project$Route$Articles$ArticleId_$update, X: $author$project$Route$Articles$ArticleId_$view }, $author$project$RouteBuilder$serverRender({ r: $author$project$Route$Articles$ArticleId_$action, iW: $author$project$Route$Articles$ArticleId_$data, aL: $author$project$Route$Articles$ArticleId_$head }));
    var $author$project$Route$Articles$Draft$action = function (routeParams) {
        return $dillonkearns$elm_pages_v3_beta$Server$Request$succeed($dillonkearns$elm_pages_v3_beta$BackendTask$succeed($dillonkearns$elm_pages_v3_beta$Server$Response$render({})));
    };
    var $author$project$Route$Articles$Draft$data = function (routeParams) {
        return $dillonkearns$elm_pages_v3_beta$Server$Request$succeed($dillonkearns$elm_pages_v3_beta$BackendTask$succeed($dillonkearns$elm_pages_v3_beta$Server$Response$render({})));
    };
    var $author$project$Route$Articles$Draft$head = function (app) {
        return _List_Nil;
    };
    var $author$project$Route$Articles$Draft$init_fn = function (app, shared) {
        return _Utils_Tuple2({}, $author$project$Effect$none);
    }, $author$project$Route$Articles$Draft$init = F2($author$project$Route$Articles$Draft$init_fn);
    var $author$project$Route$Articles$Draft$subscriptions_fn = function (routeParams, path, shared, model) {
        return $elm$core$Platform$Sub$none;
    }, $author$project$Route$Articles$Draft$subscriptions = F4($author$project$Route$Articles$Draft$subscriptions_fn);
    var $author$project$Route$Articles$Draft$update_fn = function (app, shared, msg, model) {
        return _Utils_Tuple2(model, $author$project$Effect$none);
    }, $author$project$Route$Articles$Draft$update = F4($author$project$Route$Articles$Draft$update_fn);
    var $author$project$Route$Articles$Draft$view_fn = function (app, shared, model) {
        return {
            hJ: _List_fromArray([
                $elm$html$Html$h2_fn(_List_Nil, _List_fromArray([
                    $elm$html$Html$text("New Page")
                ]))
            ]),
            jE: "Articles.Draft"
        };
    }, $author$project$Route$Articles$Draft$view = F3($author$project$Route$Articles$Draft$view_fn);
    var $author$project$Route$Articles$Draft$route = $author$project$RouteBuilder$buildWithLocalState_fn({ dI: $author$project$Route$Articles$Draft$init, dW: $author$project$Route$Articles$Draft$subscriptions, cF: $author$project$Route$Articles$Draft$update, X: $author$project$Route$Articles$Draft$view }, $author$project$RouteBuilder$serverRender({ r: $author$project$Route$Articles$Draft$action, iW: $author$project$Route$Articles$Draft$data, aL: $author$project$Route$Articles$Draft$head }));
    var $author$project$Route$Index$action = function (routeParams) {
        return $dillonkearns$elm_pages_v3_beta$Server$Request$succeed($dillonkearns$elm_pages_v3_beta$BackendTask$succeed($dillonkearns$elm_pages_v3_beta$Server$Response$render({})));
    };
    var $author$project$Route$Index$data = function (routeParams) {
        return $dillonkearns$elm_pages_v3_beta$Server$Request$succeed($dillonkearns$elm_pages_v3_beta$BackendTask$succeed($dillonkearns$elm_pages_v3_beta$Server$Response$render({})));
    };
    var $author$project$Route$Index$head = function (app) {
        return _List_Nil;
    };
    var $author$project$Route$Index$init_fn = function (app, shared) {
        return _Utils_Tuple2({}, $author$project$Effect$none);
    }, $author$project$Route$Index$init = F2($author$project$Route$Index$init_fn);
    var $author$project$Route$Index$subscriptions_fn = function (routeParams, path, shared, model) {
        return $elm$core$Platform$Sub$none;
    }, $author$project$Route$Index$subscriptions = F4($author$project$Route$Index$subscriptions_fn);
    var $author$project$Route$Index$update_fn = function (app, shared, msg, model) {
        return _Utils_Tuple2(model, $author$project$Effect$none);
    }, $author$project$Route$Index$update = F4($author$project$Route$Index$update_fn);
    var $author$project$Route$Index$view_fn = function (app, shared, model) {
        return {
            hJ: _List_fromArray([
                $elm$html$Html$h2_fn(_List_Nil, _List_fromArray([
                    $elm$html$Html$text("New Page")
                ]))
            ]),
            jE: "Index"
        };
    }, $author$project$Route$Index$view = F3($author$project$Route$Index$view_fn);
    var $author$project$Route$Index$route = $author$project$RouteBuilder$buildWithLocalState_fn({ dI: $author$project$Route$Index$init, dW: $author$project$Route$Index$subscriptions, cF: $author$project$Route$Index$update, X: $author$project$Route$Index$view }, $author$project$RouteBuilder$serverRender({ r: $author$project$Route$Index$action, iW: $author$project$Route$Index$data, aL: $author$project$Route$Index$head }));
    var $author$project$Route$Twilogs$action = function (routeParams) {
        return $dillonkearns$elm_pages_v3_beta$Server$Request$succeed($dillonkearns$elm_pages_v3_beta$BackendTask$succeed($dillonkearns$elm_pages_v3_beta$Server$Response$render({})));
    };
    var $author$project$Route$Twilogs$data = function (routeParams) {
        return $dillonkearns$elm_pages_v3_beta$Server$Request$succeed($dillonkearns$elm_pages_v3_beta$BackendTask$succeed($dillonkearns$elm_pages_v3_beta$Server$Response$render({})));
    };
    var $author$project$Route$Twilogs$head = function (app) {
        return _List_Nil;
    };
    var $author$project$Route$Twilogs$init_fn = function (app, shared) {
        return _Utils_Tuple2({}, $author$project$Effect$none);
    }, $author$project$Route$Twilogs$init = F2($author$project$Route$Twilogs$init_fn);
    var $author$project$Route$Twilogs$subscriptions_fn = function (routeParams, path, shared, model) {
        return $elm$core$Platform$Sub$none;
    }, $author$project$Route$Twilogs$subscriptions = F4($author$project$Route$Twilogs$subscriptions_fn);
    var $author$project$Route$Twilogs$update_fn = function (app, shared, msg, model) {
        return _Utils_Tuple2(model, $author$project$Effect$none);
    }, $author$project$Route$Twilogs$update = F4($author$project$Route$Twilogs$update_fn);
    var $author$project$Route$Twilogs$view_fn = function (app, shared, model) {
        return {
            hJ: _List_fromArray([
                $elm$html$Html$h2_fn(_List_Nil, _List_fromArray([
                    $elm$html$Html$text("New Page")
                ]))
            ]),
            jE: "Twilogs"
        };
    }, $author$project$Route$Twilogs$view = F3($author$project$Route$Twilogs$view_fn);
    var $author$project$Route$Twilogs$route = $author$project$RouteBuilder$buildWithLocalState_fn({ dI: $author$project$Route$Twilogs$init, dW: $author$project$Route$Twilogs$subscriptions, cF: $author$project$Route$Twilogs$update, X: $author$project$Route$Twilogs$view }, $author$project$RouteBuilder$serverRender({ r: $author$project$Route$Twilogs$action, iW: $author$project$Route$Twilogs$data, aL: $author$project$Route$Twilogs$head }));
    var $author$project$Route$Twilogs$Day_$action = function (routeParams) {
        return $dillonkearns$elm_pages_v3_beta$Server$Request$succeed($dillonkearns$elm_pages_v3_beta$BackendTask$succeed($dillonkearns$elm_pages_v3_beta$Server$Response$render({})));
    };
    var $author$project$Route$Twilogs$Day_$data = function (routeParams) {
        return $dillonkearns$elm_pages_v3_beta$Server$Request$succeed($dillonkearns$elm_pages_v3_beta$BackendTask$succeed($dillonkearns$elm_pages_v3_beta$Server$Response$render({})));
    };
    var $author$project$Route$Twilogs$Day_$head = function (app) {
        return _List_Nil;
    };
    var $author$project$Route$Twilogs$Day_$init_fn = function (app, shared) {
        return _Utils_Tuple2({}, $author$project$Effect$none);
    }, $author$project$Route$Twilogs$Day_$init = F2($author$project$Route$Twilogs$Day_$init_fn);
    var $author$project$Route$Twilogs$Day_$subscriptions_fn = function (routeParams, path, shared, model) {
        return $elm$core$Platform$Sub$none;
    }, $author$project$Route$Twilogs$Day_$subscriptions = F4($author$project$Route$Twilogs$Day_$subscriptions_fn);
    var $author$project$Route$Twilogs$Day_$update_fn = function (app, shared, msg, model) {
        return _Utils_Tuple2(model, $author$project$Effect$none);
    }, $author$project$Route$Twilogs$Day_$update = F4($author$project$Route$Twilogs$Day_$update_fn);
    var $author$project$Route$Twilogs$Day_$view_fn = function (app, shared, model) {
        return {
            hJ: _List_fromArray([
                $elm$html$Html$h2_fn(_List_Nil, _List_fromArray([
                    $elm$html$Html$text("New Page")
                ]))
            ]),
            jE: "Twilogs.Day_"
        };
    }, $author$project$Route$Twilogs$Day_$view = F3($author$project$Route$Twilogs$Day_$view_fn);
    var $author$project$Route$Twilogs$Day_$route = $author$project$RouteBuilder$buildWithLocalState_fn({ dI: $author$project$Route$Twilogs$Day_$init, dW: $author$project$Route$Twilogs$Day_$subscriptions, cF: $author$project$Route$Twilogs$Day_$update, X: $author$project$Route$Twilogs$Day_$view }, $author$project$RouteBuilder$serverRender({ r: $author$project$Route$Twilogs$Day_$action, iW: $author$project$Route$Twilogs$Day_$data, aL: $author$project$Route$Twilogs$Day_$head }));
    var $author$project$Main$action_fn = function (requestPayload, maybeRoute) {
        if (maybeRoute.$ === 1) {
            return $dillonkearns$elm_pages_v3_beta$BackendTask$succeed($dillonkearns$elm_pages_v3_beta$Server$Response$plainText("TODO"));
        }
        else {
            var justRoute_1_0 = maybeRoute.a;
            switch (justRoute_1_0.$) {
                case 0:
                    return $dillonkearns$elm_pages_v3_beta$BackendTask$map_fn($dillonkearns$elm_pages_v3_beta$Server$Response$map($author$project$Main$ActionDataArticles__Draft), A2($author$project$Route$Articles$Draft$route.r, requestPayload, {}));
                case 1:
                    var routeParams = justRoute_1_0.a;
                    return $dillonkearns$elm_pages_v3_beta$BackendTask$map_fn($dillonkearns$elm_pages_v3_beta$Server$Response$map($author$project$Main$ActionDataArticles__ArticleId_), A2($author$project$Route$Articles$ArticleId_$route.r, requestPayload, routeParams));
                case 2:
                    var routeParams = justRoute_1_0.a;
                    return $dillonkearns$elm_pages_v3_beta$BackendTask$map_fn($dillonkearns$elm_pages_v3_beta$Server$Response$map($author$project$Main$ActionDataTwilogs__Day_), A2($author$project$Route$Twilogs$Day_$route.r, requestPayload, routeParams));
                case 3:
                    return $dillonkearns$elm_pages_v3_beta$BackendTask$map_fn($dillonkearns$elm_pages_v3_beta$Server$Response$map($author$project$Main$ActionDataAbout), A2($author$project$Route$About$route.r, requestPayload, {}));
                case 4:
                    return $dillonkearns$elm_pages_v3_beta$BackendTask$map_fn($dillonkearns$elm_pages_v3_beta$Server$Response$map($author$project$Main$ActionDataArticles), A2($author$project$Route$Articles$route.r, requestPayload, {}));
                case 5:
                    return $dillonkearns$elm_pages_v3_beta$BackendTask$map_fn($dillonkearns$elm_pages_v3_beta$Server$Response$map($author$project$Main$ActionDataTwilogs), A2($author$project$Route$Twilogs$route.r, requestPayload, {}));
                default:
                    return $dillonkearns$elm_pages_v3_beta$BackendTask$map_fn($dillonkearns$elm_pages_v3_beta$Server$Response$map($author$project$Main$ActionDataIndex), A2($author$project$Route$Index$route.r, requestPayload, {}));
            }
        }
    }, $author$project$Main$action = F2($author$project$Main$action_fn);
    var $author$project$Route$About = { $: 3 };
    var $author$project$Route$Articles = { $: 4 };
    var $author$project$Route$Articles__ArticleId_ = function (a) {
        return { $: 1, a: a };
    };
    var $author$project$Route$Articles__Draft = { $: 0 };
    var $author$project$Route$Index = { $: 6 };
    var $author$project$Route$Twilogs = { $: 5 };
    var $author$project$Route$Twilogs__Day_ = function (a) {
        return { $: 2, a: a };
    };
    var $elm$core$Result$map2_fn = function (func, ra, rb) {
        if (ra.$ === 1) {
            var x = ra.a;
            return $elm$core$Result$Err(x);
        }
        else {
            var a = ra.a;
            if (rb.$ === 1) {
                var x = rb.a;
                return $elm$core$Result$Err(x);
            }
            else {
                var b = rb.a;
                return $elm$core$Result$Ok(A2(func, a, b));
            }
        }
    }, $elm$core$Result$map2_fn_unwrapped = function (func, ra, rb) {
        if (ra.$ === 1) {
            var x = ra.a;
            return $elm$core$Result$Err(x);
        }
        else {
            var a = ra.a;
            if (rb.$ === 1) {
                var x = rb.a;
                return $elm$core$Result$Err(x);
            }
            else {
                var b = rb.a;
                return $elm$core$Result$Ok(func(a, b));
            }
        }
    }, $elm$core$Result$map2 = F3($elm$core$Result$map2_fn);
    var $dillonkearns$elm_pages_v3_beta$BackendTask$map2_fn = function (fn, request1, request2) {
        var _v0 = _Utils_Tuple2(request1, request2);
        if (!_v0.a.$) {
            if (!_v0.b.$) {
                var _v1 = _v0.a;
                var urls1 = _v1.a;
                var lookupFn1 = _v1.b;
                var _v2 = _v0.b;
                var urls2 = _v2.a;
                var lookupFn2 = _v2.b;
                return $dillonkearns$elm_pages_v3_beta$Pages$StaticHttpRequest$Request_fn(_Utils_ap(urls1, urls2), F2(function (resolver, responses) {
                    return $dillonkearns$elm_pages_v3_beta$BackendTask$map2_fn(fn, A2(lookupFn1, resolver, responses), A2(lookupFn2, resolver, responses));
                }));
            }
            else {
                var _v3 = _v0.a;
                var urls1 = _v3.a;
                var lookupFn1 = _v3.b;
                var value2 = _v0.b.a;
                return $dillonkearns$elm_pages_v3_beta$Pages$StaticHttpRequest$Request_fn(urls1, F2(function (resolver, responses) {
                    return $dillonkearns$elm_pages_v3_beta$BackendTask$map2_fn(fn, A2(lookupFn1, resolver, responses), $dillonkearns$elm_pages_v3_beta$Pages$StaticHttpRequest$ApiRoute(value2));
                }));
            }
        }
        else {
            if (_v0.b.$ === 1) {
                var value1 = _v0.a.a;
                var value2 = _v0.b.a;
                return $dillonkearns$elm_pages_v3_beta$Pages$StaticHttpRequest$ApiRoute($elm$core$Result$map2_fn(fn, value1, value2));
            }
            else {
                var value2 = _v0.a.a;
                var _v4 = _v0.b;
                var urls1 = _v4.a;
                var lookupFn1 = _v4.b;
                return $dillonkearns$elm_pages_v3_beta$Pages$StaticHttpRequest$Request_fn(urls1, F2(function (resolver, responses) {
                    return $dillonkearns$elm_pages_v3_beta$BackendTask$map2_fn(fn, $dillonkearns$elm_pages_v3_beta$Pages$StaticHttpRequest$ApiRoute(value2), A2(lookupFn1, resolver, responses));
                }));
            }
        }
    }, $dillonkearns$elm_pages_v3_beta$BackendTask$map2 = F3($dillonkearns$elm_pages_v3_beta$BackendTask$map2_fn);
    var $dillonkearns$elm_pages_v3_beta$BackendTask$combine = function (items) {
        return $dillonkearns$elm_pages_v3_beta$BackendTask$map_fn($elm$core$List$reverse, $elm$core$List$foldl_fn($dillonkearns$elm_pages_v3_beta$BackendTask$map2($elm$core$List$cons), $dillonkearns$elm_pages_v3_beta$BackendTask$succeed(_List_Nil), items));
    };
    var $elm$core$List$append_fn = function (xs, ys) {
        var tmp = _List_Cons(undefined, _List_Nil);
        var end = tmp;
        for (; xs.b; xs = xs.b) {
            var next = _List_Cons(xs.a, _List_Nil);
            end.b = next;
            end = next;
        }
        end.b = ys;
        return tmp.b;
    }, $elm$core$List$append = F2($elm$core$List$append_fn);
    var $elm$core$List$concat = function (lists) {
        if (!lists.b) {
            return _List_Nil;
        }
        var tmp = _List_Cons(undefined, _List_Nil);
        var end = tmp;
        for (; lists.b.b; lists = lists.b) {
            var xs = lists.a;
            for (; xs.b; xs = xs.b) {
                var next = _List_Cons(xs.a, _List_Nil);
                end.b = next;
                end = next;
            }
        }
        end.b = lists.a;
        return tmp.b;
    };
    var $author$project$Main$getStaticRoutes = $dillonkearns$elm_pages_v3_beta$BackendTask$map_fn($elm$core$List$concat, $dillonkearns$elm_pages_v3_beta$BackendTask$combine(_List_fromArray([
        $dillonkearns$elm_pages_v3_beta$BackendTask$map_fn($elm$core$List$map(function (_v0) {
            return $author$project$Route$Articles__Draft;
        }), $author$project$Route$Articles$Draft$route.om),
        $dillonkearns$elm_pages_v3_beta$BackendTask$map_fn($elm$core$List$map($author$project$Route$Articles__ArticleId_), $author$project$Route$Articles$ArticleId_$route.om),
        $dillonkearns$elm_pages_v3_beta$BackendTask$map_fn($elm$core$List$map($author$project$Route$Twilogs__Day_), $author$project$Route$Twilogs$Day_$route.om),
        $dillonkearns$elm_pages_v3_beta$BackendTask$map_fn($elm$core$List$map(function (_v1) {
            return $author$project$Route$About;
        }), $author$project$Route$About$route.om),
        $dillonkearns$elm_pages_v3_beta$BackendTask$map_fn($elm$core$List$map(function (_v2) {
            return $author$project$Route$Articles;
        }), $author$project$Route$Articles$route.om),
        $dillonkearns$elm_pages_v3_beta$BackendTask$map_fn($elm$core$List$map(function (_v3) {
            return $author$project$Route$Twilogs;
        }), $author$project$Route$Twilogs$route.om),
        $dillonkearns$elm_pages_v3_beta$BackendTask$map_fn($elm$core$List$map(function (_v4) {
            return $author$project$Route$Index;
        }), $author$project$Route$Index$route.om)
    ])));
    var $elm$json$Json$Encode$list_fn = function (func, entries) {
        return _Json_wrap($elm$core$List$foldl_fn(_Json_addEntry(func), _Json_emptyArray(0), entries));
    }, $elm$json$Json$Encode$list = F2($elm$json$Json$Encode$list_fn);
    var $dillonkearns$elm_pages_v3_beta$Internal$ApiRoute$ApiRouteBuilder_fn = function (a, b, c, d, e) {
        return { $: 0, a: a, b: b, c: c, d: d, e: e };
    }, $dillonkearns$elm_pages_v3_beta$Internal$ApiRoute$ApiRouteBuilder = F5($dillonkearns$elm_pages_v3_beta$Internal$ApiRoute$ApiRouteBuilder_fn);
    var $dillonkearns$elm_pages_v3_beta$Pattern$HybridSegment = function (a) {
        return { $: 2, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$Pattern$Literal = function (a) {
        return { $: 0, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$Pattern$NoPendingSlash = 1;
    var $dillonkearns$elm_pages_v3_beta$Pattern$Pattern_fn = function (a, b) {
        return { $: 0, a: a, b: b };
    }, $dillonkearns$elm_pages_v3_beta$Pattern$Pattern = F2($dillonkearns$elm_pages_v3_beta$Pattern$Pattern_fn);
    var $dillonkearns$elm_pages_v3_beta$Pattern$addLiteral_fn = function (newLiteral, _v0) {
        var segments = _v0.a;
        var state = _v0.b;
        if (!state) {
            return $dillonkearns$elm_pages_v3_beta$Pattern$Pattern_fn(_Utils_ap(segments, _List_fromArray([
                $dillonkearns$elm_pages_v3_beta$Pattern$Literal(newLiteral)
            ])), 1);
        }
        else {
            var _v2 = $elm$core$List$reverse(segments);
            if (_v2.b) {
                if (!_v2.a.$) {
                    var literalSegment = _v2.a.a;
                    var rest = _v2.b;
                    return $dillonkearns$elm_pages_v3_beta$Pattern$Pattern_fn(_Utils_ap($elm$core$List$reverse(rest), _List_fromArray([
                        $dillonkearns$elm_pages_v3_beta$Pattern$Literal(_Utils_ap(literalSegment, newLiteral))
                    ])), 1);
                }
                else {
                    var last = _v2.a;
                    var rest = _v2.b;
                    return $dillonkearns$elm_pages_v3_beta$Pattern$Pattern_fn(_Utils_ap($elm$core$List$reverse(rest), _List_fromArray([
                        $dillonkearns$elm_pages_v3_beta$Pattern$HybridSegment(_Utils_Tuple3(last, $dillonkearns$elm_pages_v3_beta$Pattern$Literal(newLiteral), _List_Nil))
                    ])), 1);
                }
            }
            else {
                return $dillonkearns$elm_pages_v3_beta$Pattern$Pattern_fn(_Utils_ap(segments, _List_fromArray([
                    $dillonkearns$elm_pages_v3_beta$Pattern$Literal(newLiteral)
                ])), state);
            }
        }
    }, $dillonkearns$elm_pages_v3_beta$Pattern$addLiteral = F2($dillonkearns$elm_pages_v3_beta$Pattern$addLiteral_fn);
    var $dillonkearns$elm_pages_v3_beta$ApiRoute$literal_fn = function (segment, _v0) {
        var patterns = _v0.a;
        var pattern = _v0.b;
        var handler = _v0.c;
        var toString = _v0.d;
        var constructor = _v0.e;
        return $dillonkearns$elm_pages_v3_beta$Internal$ApiRoute$ApiRouteBuilder_fn($dillonkearns$elm_pages_v3_beta$Pattern$addLiteral_fn(segment, patterns), _Utils_ap(pattern, segment), handler, function (values) {
            return _Utils_ap(toString(values), segment);
        }, constructor);
    }, $dillonkearns$elm_pages_v3_beta$ApiRoute$literal = F2($dillonkearns$elm_pages_v3_beta$ApiRoute$literal_fn);
    var $elm$core$Tuple$pair_fn = function (a, b) {
        return _Utils_Tuple2(a, b);
    }, $elm$core$Tuple$pair = F2($elm$core$Tuple$pair_fn);
    var $dillonkearns$elm_pages_v3_beta$BackendTask$resolve_a0 = $dillonkearns$elm_pages_v3_beta$BackendTask$combine, $dillonkearns$elm_pages_v3_beta$BackendTask$resolve = $dillonkearns$elm_pages_v3_beta$BackendTask$andThen($dillonkearns$elm_pages_v3_beta$BackendTask$resolve_a0);
    var $author$project$Api$builtArticles = function () {
        var build = function (routeParam) {
            return $dillonkearns$elm_pages_v3_beta$BackendTask$map_fn($elm$core$Tuple$pair($author$project$Route$Articles__ArticleId_(routeParam)), $dillonkearns$elm_pages_v3_beta$BackendTask$succeed({}));
        };
        return $dillonkearns$elm_pages_v3_beta$BackendTask$andThen_fn($dillonkearns$elm_pages_v3_beta$BackendTask$resolve_a0, $dillonkearns$elm_pages_v3_beta$BackendTask$map_fn($elm$core$List$map(build), $author$project$Route$Articles$ArticleId_$route.om));
    }();
    var $elm$time$Time$Posix = $elm$core$Basics$identity;
    var $elm$time$Time$millisToPosix = $elm$core$Basics$identity;
    var $author$project$Pages$builtAt = $elm$time$Time$millisToPosix(1680893063124);
    var $danyx23$elm_mimetype$MimeType$Jpeg = { $: 0 };
    var $elm$core$List$maybeCons_fn = function (f, mx, xs) {
        var _v0 = f(mx);
        if (!_v0.$) {
            var x = _v0.a;
            return _List_Cons(x, xs);
        }
        else {
            return xs;
        }
    }, $elm$core$List$maybeCons = F3($elm$core$List$maybeCons_fn);
    var $elm$core$List$filterMap_fn = function (f, xs) {
        return $elm$core$List$foldr_fn($elm$core$List$maybeCons(f), _List_Nil, xs);
    }, $elm$core$List$filterMap = F2($elm$core$List$filterMap_fn);
    var $dillonkearns$elm_pages_v3_beta$Head$filterMaybeValues = function (list) {
        return $elm$core$List$filterMap_fn(function (_v0) {
            var key = _v0.a;
            var maybeValue = _v0.b;
            if (!maybeValue.$) {
                var value = maybeValue.a;
                return $elm$core$Maybe$Just(_Utils_Tuple2(key, value));
            }
            else {
                return $elm$core$Maybe$Nothing;
            }
        }, list);
    };
    var $elm$core$Maybe$map_fn = function (f, maybe) {
        if (!maybe.$) {
            var value = maybe.a;
            return $elm$core$Maybe$Just(f(value));
        }
        else {
            return $elm$core$Maybe$Nothing;
        }
    }, $elm$core$Maybe$map = F2($elm$core$Maybe$map_fn);
    var $dillonkearns$elm_pages_v3_beta$Head$Tag = function (a) {
        return { $: 0, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$Head$node_fn = function (name, attributes) {
        return $dillonkearns$elm_pages_v3_beta$Head$Tag({ fb: attributes, nq: name });
    }, $dillonkearns$elm_pages_v3_beta$Head$node = F2($dillonkearns$elm_pages_v3_beta$Head$node_fn);
    var $dillonkearns$elm_pages_v3_beta$Head$Raw = function (a) {
        return { $: 0, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$Head$raw = function (value) {
        return $dillonkearns$elm_pages_v3_beta$Head$Raw(value);
    };
    var $dillonkearns$elm_pages_v3_beta$Head$sizesToString = function (sizes) {
        return $elm$core$String$join_fn(" ", $elm$core$List$map_fn(function (_v0) {
            var x = _v0.a;
            var y = _v0.b;
            return $elm$core$String$fromInt(x) + ("x" + $elm$core$String$fromInt(y));
        }, sizes));
    };
    var $dillonkearns$elm_pages_v3_beta$Head$FullUrl = function (a) {
        return { $: 1, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$Head$urlAttribute = function (value) {
        return $dillonkearns$elm_pages_v3_beta$Head$FullUrl(value);
    };
    var $dillonkearns$elm_pages_v3_beta$Head$appleTouchIcon_fn = function (maybeSize, imageUrl) {
        return $dillonkearns$elm_pages_v3_beta$Head$node_fn("link", $dillonkearns$elm_pages_v3_beta$Head$filterMaybeValues(_List_fromArray([
            _Utils_Tuple2("rel", $elm$core$Maybe$Just($dillonkearns$elm_pages_v3_beta$Head$raw("apple-touch-icon"))),
            _Utils_Tuple2("sizes", $elm$core$Maybe$map_fn($dillonkearns$elm_pages_v3_beta$Head$raw, $elm$core$Maybe$map_fn(function (size) {
                return $dillonkearns$elm_pages_v3_beta$Head$sizesToString(_List_fromArray([
                    _Utils_Tuple2(size, size)
                ]));
            }, maybeSize))),
            _Utils_Tuple2("href", $elm$core$Maybe$Just($dillonkearns$elm_pages_v3_beta$Head$urlAttribute(imageUrl)))
        ])));
    }, $dillonkearns$elm_pages_v3_beta$Head$appleTouchIcon = F2($dillonkearns$elm_pages_v3_beta$Head$appleTouchIcon_fn);
    var $dillonkearns$elm_pages_v3_beta$Pages$Url$External = function (a) {
        return { $: 1, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$Url$external = function (externalUrl) {
        return $dillonkearns$elm_pages_v3_beta$Pages$Url$External(externalUrl);
    };
    var $danyx23$elm_mimetype$MimeType$Image = function (a) {
        return { $: 0, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$Head$nonEmptyList = function (list) {
        return $elm$core$List$isEmpty(list) ? $elm$core$Maybe$Nothing : $elm$core$Maybe$Just(list);
    };
    var $danyx23$elm_mimetype$MimeType$toString = function (mimeType) {
        switch (mimeType.$) {
            case 0:
                var img = mimeType.a;
                switch (img.$) {
                    case 0:
                        return "image/jpeg";
                    case 1:
                        return "image/png";
                    case 2:
                        return "image/gif";
                    default:
                        var type_ = img.a;
                        return "image/" + type_;
                }
            case 1:
                var audio = mimeType.a;
                switch (audio.$) {
                    case 0:
                        return "audio/mp3";
                    case 2:
                        return "audio/wav";
                    case 1:
                        return "audio/ogg";
                    default:
                        var type_ = audio.a;
                        return "audio/" + type_;
                }
            case 2:
                var video = mimeType.a;
                switch (video.$) {
                    case 0:
                        return "video/mp4";
                    case 1:
                        return "video/mpeg";
                    case 2:
                        return "video/quicktime";
                    case 3:
                        return "video/avi";
                    case 4:
                        return "video/webm";
                    default:
                        var type_ = video.a;
                        return "video/" + type_;
                }
            case 3:
                var text = mimeType.a;
                switch (text.$) {
                    case 0:
                        return "text/plain";
                    case 1:
                        return "text/html";
                    case 2:
                        return "text/css";
                    case 3:
                        return "text/xml";
                    case 4:
                        return "application/json";
                    default:
                        var type_ = text.a;
                        return "text/" + type_;
                }
            case 4:
                var app = mimeType.a;
                switch (app.$) {
                    case 0:
                        return "application/msword";
                    case 1:
                        return "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
                    case 2:
                        return "application/vnd.ms-excel";
                    case 3:
                        return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
                    case 4:
                        return "application/vnd.ms-powerpoint";
                    case 5:
                        return "application/vnd.openxmlformats-officedocument.presentationml.presentation";
                    case 6:
                        return "application/pdf";
                    default:
                        var type_ = app.a;
                        return "application/" + type_;
                }
            default:
                var type_ = mimeType.a;
                return type_;
        }
    };
    var $dillonkearns$elm_pages_v3_beta$Head$icon_fn = function (sizes, imageMimeType, imageUrl) {
        return $dillonkearns$elm_pages_v3_beta$Head$node_fn("link", $dillonkearns$elm_pages_v3_beta$Head$filterMaybeValues(_List_fromArray([
            _Utils_Tuple2("rel", $elm$core$Maybe$Just($dillonkearns$elm_pages_v3_beta$Head$raw("icon"))),
            _Utils_Tuple2("sizes", $elm$core$Maybe$map_fn($dillonkearns$elm_pages_v3_beta$Head$raw, $elm$core$Maybe$map_fn($dillonkearns$elm_pages_v3_beta$Head$sizesToString, $dillonkearns$elm_pages_v3_beta$Head$nonEmptyList(sizes)))),
            _Utils_Tuple2("type", $elm$core$Maybe$Just($dillonkearns$elm_pages_v3_beta$Head$raw($danyx23$elm_mimetype$MimeType$toString($danyx23$elm_mimetype$MimeType$Image(imageMimeType))))),
            _Utils_Tuple2("href", $elm$core$Maybe$Just($dillonkearns$elm_pages_v3_beta$Head$urlAttribute(imageUrl)))
        ])));
    }, $dillonkearns$elm_pages_v3_beta$Head$icon = F3($dillonkearns$elm_pages_v3_beta$Head$icon_fn);
    var $dillonkearns$elm_pages_v3_beta$Head$metaName_fn = function (name, content) {
        return $dillonkearns$elm_pages_v3_beta$Head$node_fn("meta", _List_fromArray([
            _Utils_Tuple2("name", $dillonkearns$elm_pages_v3_beta$Head$Raw(name)),
            _Utils_Tuple2("content", content)
        ]));
    }, $dillonkearns$elm_pages_v3_beta$Head$metaName = F2($dillonkearns$elm_pages_v3_beta$Head$metaName_fn);
    var $dillonkearns$elm_pages_v3_beta$Head$rssLink = function (url) {
        return $dillonkearns$elm_pages_v3_beta$Head$node_fn("link", _List_fromArray([
            _Utils_Tuple2("rel", $dillonkearns$elm_pages_v3_beta$Head$raw("alternate")),
            _Utils_Tuple2("type", $dillonkearns$elm_pages_v3_beta$Head$raw("application/rss+xml")),
            _Utils_Tuple2("href", $dillonkearns$elm_pages_v3_beta$Head$raw(url))
        ]));
    };
    var $dillonkearns$elm_pages_v3_beta$Head$sitemapLink = function (url) {
        return $dillonkearns$elm_pages_v3_beta$Head$node_fn("link", _List_fromArray([
            _Utils_Tuple2("rel", $dillonkearns$elm_pages_v3_beta$Head$raw("sitemap")),
            _Utils_Tuple2("type", $dillonkearns$elm_pages_v3_beta$Head$raw("application/xml")),
            _Utils_Tuple2("href", $dillonkearns$elm_pages_v3_beta$Head$raw(url))
        ]));
    };
    var $author$project$Site$head = $dillonkearns$elm_pages_v3_beta$BackendTask$succeed(_List_fromArray([
        $dillonkearns$elm_pages_v3_beta$Head$metaName_fn("viewport", $dillonkearns$elm_pages_v3_beta$Head$raw("width=device-width,initial-scale=1")),
        $dillonkearns$elm_pages_v3_beta$Head$icon_fn(_List_fromArray([
            _Utils_Tuple2(100, 100)
        ]), $danyx23$elm_mimetype$MimeType$Jpeg, $dillonkearns$elm_pages_v3_beta$Pages$Url$external("https://images.microcms-assets.io/assets/032d3ec87506420baf0093fac244c29b/4a220ee277a54bd4a7cf59a2c423b096/header1500x500.jpg?fit=crop&h=100&w=100")),
        $dillonkearns$elm_pages_v3_beta$Head$appleTouchIcon_fn($elm$core$Maybe$Just(192), $dillonkearns$elm_pages_v3_beta$Pages$Url$external("https://images.microcms-assets.io/assets/032d3ec87506420baf0093fac244c29b/4a220ee277a54bd4a7cf59a2c423b096/header1500x500.jpg?fit=crop&h=192&w=192")),
        $dillonkearns$elm_pages_v3_beta$Head$metaName_fn("google-site-verification", $dillonkearns$elm_pages_v3_beta$Head$raw("Bby4JbWa2r4u77WnDC7sWGQbmIWji1Z5cQwCTAXr0Sg")),
        $dillonkearns$elm_pages_v3_beta$Head$sitemapLink("/sitemap.xml"),
        $dillonkearns$elm_pages_v3_beta$Head$rssLink("/articles/feed.xml")
    ]));
    var $author$project$Site$config = { kK: "https://ymtszw.github.io", aL: $author$project$Site$head };
    var $dillonkearns$elm_rss$Rss$DateTime = function (a) {
        return { $: 1, a: a };
    };
    var $author$project$Route$routeToPath = function (route) {
        return $elm$core$List$concat(function () {
            switch (route.$) {
                case 0:
                    return _List_fromArray([
                        _List_fromArray(["articles", "draft"])
                    ]);
                case 1:
                    var params = route.a;
                    return _List_fromArray([
                        _List_fromArray(["articles"]),
                        _List_fromArray([params.l$])
                    ]);
                case 2:
                    var params = route.a;
                    return _List_fromArray([
                        _List_fromArray(["twilogs"]),
                        _List_fromArray([params.ml])
                    ]);
                case 3:
                    return _List_fromArray([
                        _List_fromArray(["about"])
                    ]);
                case 4:
                    return _List_fromArray([
                        _List_fromArray(["articles"])
                    ]);
                case 5:
                    return _List_fromArray([
                        _List_fromArray(["twilogs"])
                    ]);
                default:
                    return _List_fromArray([_List_Nil]);
            }
        }());
    };
    var $author$project$Api$makeArticleRssItem = function (_v0) {
        var route = _v0.a;
        var data = _v0.b;
        return {
            l2: "ymtszw (Yu Matsuzawa)",
            mc: _List_Nil,
            mh: $elm$core$Maybe$Nothing,
            mi: $elm$core$Maybe$Nothing,
            jX: "",
            mu: $elm$core$Maybe$Nothing,
            nU: $dillonkearns$elm_rss$Rss$DateTime($author$project$Pages$builtAt),
            jE: "",
            lO: $elm$core$String$join_fn("/", $author$project$Route$routeToPath(route))
        };
    };
    var $rtfeldman$elm_iso8601_date_strings$Iso8601$fromMonth = function (month) {
        switch (month) {
            case 0:
                return 1;
            case 1:
                return 2;
            case 2:
                return 3;
            case 3:
                return 4;
            case 4:
                return 5;
            case 5:
                return 6;
            case 6:
                return 7;
            case 7:
                return 8;
            case 8:
                return 9;
            case 9:
                return 10;
            case 10:
                return 11;
            default:
                return 12;
        }
    };
    var $elm$time$Time$flooredDiv_fn = function (numerator, denominator) {
        return $elm$core$Basics$floor(numerator / denominator);
    }, $elm$time$Time$flooredDiv = F2($elm$time$Time$flooredDiv_fn);
    var $elm$time$Time$posixToMillis = function (_v0) {
        var millis = _v0;
        return millis;
    };
    var $elm$time$Time$toAdjustedMinutesHelp_fn = function (defaultOffset, posixMinutes, eras) {
        toAdjustedMinutesHelp: while (true) {
            if (!eras.b) {
                return posixMinutes + defaultOffset;
            }
            else {
                var era = eras.a;
                var olderEras = eras.b;
                if (_Utils_cmp(era.B, posixMinutes) < 0) {
                    return posixMinutes + era.gO;
                }
                else {
                    var $temp$defaultOffset = defaultOffset, $temp$posixMinutes = posixMinutes, $temp$eras = olderEras;
                    defaultOffset = $temp$defaultOffset;
                    posixMinutes = $temp$posixMinutes;
                    eras = $temp$eras;
                    continue toAdjustedMinutesHelp;
                }
            }
        }
    }, $elm$time$Time$toAdjustedMinutesHelp = F3($elm$time$Time$toAdjustedMinutesHelp_fn);
    var $elm$time$Time$toAdjustedMinutes_fn = function (_v0, time) {
        var defaultOffset = _v0.a;
        var eras = _v0.b;
        return $elm$time$Time$toAdjustedMinutesHelp_fn(defaultOffset, $elm$time$Time$flooredDiv_fn($elm$time$Time$posixToMillis(time), 60000), eras);
    }, $elm$time$Time$toAdjustedMinutes = F2($elm$time$Time$toAdjustedMinutes_fn);
    var $elm$core$Basics$ge = _Utils_ge;
    var $elm$core$Basics$negate = function (n) {
        return -n;
    };
    var $elm$time$Time$toCivil = function (minutes) {
        var rawDay = $elm$time$Time$flooredDiv_fn(minutes, 60 * 24) + 719468;
        var era = (((rawDay >= 0) ? rawDay : (rawDay - 146096)) / 146097) | 0;
        var dayOfEra = rawDay - (era * 146097);
        var yearOfEra = ((((dayOfEra - ((dayOfEra / 1460) | 0)) + ((dayOfEra / 36524) | 0)) - ((dayOfEra / 146096) | 0)) / 365) | 0;
        var dayOfYear = dayOfEra - (((365 * yearOfEra) + ((yearOfEra / 4) | 0)) - ((yearOfEra / 100) | 0));
        var mp = (((5 * dayOfYear) + 2) / 153) | 0;
        var month = mp + ((mp < 10) ? 3 : (-9));
        var year = yearOfEra + (era * 400);
        return {
            ml: (dayOfYear - ((((153 * mp) + 2) / 5) | 0)) + 1,
            fF: month,
            fT: year + ((month <= 2) ? 1 : 0)
        };
    };
    var $elm$time$Time$toDay_fn = function (zone, time) {
        return $elm$time$Time$toCivil($elm$time$Time$toAdjustedMinutes_fn(zone, time)).ml;
    }, $elm$time$Time$toDay = F2($elm$time$Time$toDay_fn);
    var $elm$core$Basics$modBy = _Basics_modBy;
    var $elm$time$Time$toHour_fn = function (zone, time) {
        return _Basics_modBy_fn(24, $elm$time$Time$flooredDiv_fn($elm$time$Time$toAdjustedMinutes_fn(zone, time), 60));
    }, $elm$time$Time$toHour = F2($elm$time$Time$toHour_fn);
    var $elm$time$Time$toMillis_fn = function (_v0, time) {
        return _Basics_modBy_fn(1000, $elm$time$Time$posixToMillis(time));
    }, $elm$time$Time$toMillis = F2($elm$time$Time$toMillis_fn);
    var $elm$time$Time$toMinute_fn = function (zone, time) {
        return _Basics_modBy_fn(60, $elm$time$Time$toAdjustedMinutes_fn(zone, time));
    }, $elm$time$Time$toMinute = F2($elm$time$Time$toMinute_fn);
    var $elm$time$Time$Apr = 3;
    var $elm$time$Time$Aug = 7;
    var $elm$time$Time$Dec = 11;
    var $elm$time$Time$Feb = 1;
    var $elm$time$Time$Jan = 0;
    var $elm$time$Time$Jul = 6;
    var $elm$time$Time$Jun = 5;
    var $elm$time$Time$Mar = 2;
    var $elm$time$Time$May = 4;
    var $elm$time$Time$Nov = 10;
    var $elm$time$Time$Oct = 9;
    var $elm$time$Time$Sep = 8;
    var $elm$time$Time$toMonth_fn = function (zone, time) {
        var _v0 = $elm$time$Time$toCivil($elm$time$Time$toAdjustedMinutes_fn(zone, time)).fF;
        switch (_v0) {
            case 1:
                return 0;
            case 2:
                return 1;
            case 3:
                return 2;
            case 4:
                return 3;
            case 5:
                return 4;
            case 6:
                return 5;
            case 7:
                return 6;
            case 8:
                return 7;
            case 9:
                return 8;
            case 10:
                return 9;
            case 11:
                return 10;
            default:
                return 11;
        }
    }, $elm$time$Time$toMonth = F2($elm$time$Time$toMonth_fn);
    var $elm$core$String$cons = _String_cons;
    var $elm$core$String$fromChar = function (_char) {
        return _String_cons_fn(_char, "");
    };
    var $elm$core$String$length = _String_length;
    var $elm$core$Bitwise$and = _Bitwise_and;
    var $elm$core$Bitwise$shiftRightBy = _Bitwise_shiftRightBy;
    var $elm$core$String$repeatHelp_fn = function (n, chunk, result) {
        return (n <= 0) ? result : $elm$core$String$repeatHelp_fn(n >> 1, _Utils_ap(chunk, chunk), (!(n & 1)) ? result : _Utils_ap(result, chunk));
    }, $elm$core$String$repeatHelp = F3($elm$core$String$repeatHelp_fn);
    var $elm$core$String$repeat_fn = function (n, chunk) {
        return $elm$core$String$repeatHelp_fn(n, chunk, "");
    }, $elm$core$String$repeat = F2($elm$core$String$repeat_fn);
    var $elm$core$String$padLeft_fn = function (n, _char, string) {
        return _Utils_ap($elm$core$String$repeat_fn(n - $elm$core$String$length(string), $elm$core$String$fromChar(_char)), string);
    }, $elm$core$String$padLeft = F3($elm$core$String$padLeft_fn);
    var $rtfeldman$elm_iso8601_date_strings$Iso8601$toPaddedString_fn = function (digits, time) {
        return $elm$core$String$padLeft_fn(digits, "0", $elm$core$String$fromInt(time));
    }, $rtfeldman$elm_iso8601_date_strings$Iso8601$toPaddedString = F2($rtfeldman$elm_iso8601_date_strings$Iso8601$toPaddedString_fn);
    var $elm$time$Time$toSecond_fn = function (_v0, time) {
        return _Basics_modBy_fn(60, $elm$time$Time$flooredDiv_fn($elm$time$Time$posixToMillis(time), 1000));
    }, $elm$time$Time$toSecond = F2($elm$time$Time$toSecond_fn);
    var $elm$time$Time$toYear_fn = function (zone, time) {
        return $elm$time$Time$toCivil($elm$time$Time$toAdjustedMinutes_fn(zone, time)).fT;
    }, $elm$time$Time$toYear = F2($elm$time$Time$toYear_fn);
    var $elm$time$Time$Zone_fn = function (a, b) {
        return { $: 0, a: a, b: b };
    }, $elm$time$Time$Zone = F2($elm$time$Time$Zone_fn);
    var $elm$time$Time$utc = $elm$time$Time$Zone_fn(0, _List_Nil);
    var $rtfeldman$elm_iso8601_date_strings$Iso8601$fromTime = function (time) {
        return $rtfeldman$elm_iso8601_date_strings$Iso8601$toPaddedString_fn(4, $elm$time$Time$toYear_fn($elm$time$Time$utc, time)) + ("-" + ($rtfeldman$elm_iso8601_date_strings$Iso8601$toPaddedString_fn(2, $rtfeldman$elm_iso8601_date_strings$Iso8601$fromMonth($elm$time$Time$toMonth_fn($elm$time$Time$utc, time))) + ("-" + ($rtfeldman$elm_iso8601_date_strings$Iso8601$toPaddedString_fn(2, $elm$time$Time$toDay_fn($elm$time$Time$utc, time)) + ("T" + ($rtfeldman$elm_iso8601_date_strings$Iso8601$toPaddedString_fn(2, $elm$time$Time$toHour_fn($elm$time$Time$utc, time)) + (":" + ($rtfeldman$elm_iso8601_date_strings$Iso8601$toPaddedString_fn(2, $elm$time$Time$toMinute_fn($elm$time$Time$utc, time)) + (":" + ($rtfeldman$elm_iso8601_date_strings$Iso8601$toPaddedString_fn(2, $elm$time$Time$toSecond_fn($elm$time$Time$utc, time)) + ("." + ($rtfeldman$elm_iso8601_date_strings$Iso8601$toPaddedString_fn(3, $elm$time$Time$toMillis_fn($elm$time$Time$utc, time)) + "Z"))))))))))));
    };
    var $author$project$Api$makeSitemapEntries = function (getStaticRoutes) {
        var build = function (route) {
            var routeSource = function (lastMod) {
                return $dillonkearns$elm_pages_v3_beta$BackendTask$succeed({
                    m8: $elm$core$Maybe$Just(lastMod),
                    nM: $elm$core$String$join_fn("/", $author$project$Route$routeToPath(route))
                });
            };
            switch (route.$) {
                case 3:
                    return $elm$core$Maybe$Just(routeSource($rtfeldman$elm_iso8601_date_strings$Iso8601$fromTime($author$project$Pages$builtAt)));
                case 4:
                    return $elm$core$Maybe$Just(routeSource($rtfeldman$elm_iso8601_date_strings$Iso8601$fromTime($author$project$Pages$builtAt)));
                case 0:
                    return $elm$core$Maybe$Nothing;
                case 1:
                    var routeParam = route.a;
                    return $elm$core$Maybe$Nothing;
                case 5:
                    return $elm$core$Maybe$Just(routeSource($rtfeldman$elm_iso8601_date_strings$Iso8601$fromTime($author$project$Pages$builtAt)));
                case 2:
                    var routeParam = route.a;
                    return $elm$core$Maybe$Just(routeSource(routeParam.ml));
                default:
                    return $elm$core$Maybe$Just(routeSource($rtfeldman$elm_iso8601_date_strings$Iso8601$fromTime($author$project$Pages$builtAt)));
            }
        };
        return $dillonkearns$elm_pages_v3_beta$BackendTask$andThen_fn($dillonkearns$elm_pages_v3_beta$BackendTask$resolve_a0, $dillonkearns$elm_pages_v3_beta$BackendTask$map_fn($elm$core$List$filterMap(build), getStaticRoutes));
    };
    var $elm$core$Dict$RBEmpty_elm_builtin = { $: -2 };
    var $elm$core$Dict$empty = $elm$core$Dict$RBEmpty_elm_builtin;
    var $billstclair$elm_xml_eeue56$Xml$Encode$boolToString = function (b) {
        return b ? "true" : "false";
    };
    var $billstclair$elm_xml_eeue56$Xml$predefinedEntities = _List_fromArray([
        _Utils_Tuple2("\"", "quot"),
        _Utils_Tuple2("'", "apos"),
        _Utils_Tuple2("<", "lt"),
        _Utils_Tuple2(">", "gt"),
        _Utils_Tuple2("&", "amp")
    ]);
    var $elm$core$String$replace_fn = function (before, after, string) {
        return $elm$core$String$join_fn(after, $elm$core$String$split_fn(before, string));
    }, $elm$core$String$replace = F3($elm$core$String$replace_fn);
    var $billstclair$elm_xml_eeue56$Xml$encodeXmlEntities = function (s) {
        return $elm$core$List$foldr_fn(F2(function (_v0, z) {
            var x = _v0.a;
            var y = _v0.b;
            return $elm$core$String$replace_fn($elm$core$String$fromChar(x), "&" + (y + ";"), z);
        }), s, $billstclair$elm_xml_eeue56$Xml$predefinedEntities);
    };
    var $elm$core$String$fromFloat = _String_fromNumber;
    var $billstclair$elm_xml_eeue56$Xml$Encode$needsIndent = function (nextValue) {
        switch (nextValue.$) {
            case 5:
                if (!nextValue.a.b) {
                    return false;
                }
                else {
                    return true;
                }
            case 0:
                return true;
            default:
                return false;
        }
    };
    var $billstclair$elm_xml_eeue56$Xml$Encode$propToString = function (value) {
        switch (value.$) {
            case 1:
                var str = value.a;
                return $billstclair$elm_xml_eeue56$Xml$encodeXmlEntities(str);
            case 2:
                var n = value.a;
                return $elm$core$String$fromInt(n);
            case 4:
                var b = value.a;
                return $billstclair$elm_xml_eeue56$Xml$Encode$boolToString(b);
            case 3:
                var f = value.a;
                return $elm$core$String$fromFloat(f);
            default:
                return "";
        }
    };
    var $billstclair$elm_xml_eeue56$Xml$Encode$propsToString = function (props) {
        return function (x) {
            return ($elm$core$String$length(x) > 0) ? (" " + x) : "";
        }($elm$core$String$join_fn(" ", $elm$core$List$map_fn(function (_v0) {
            var key = _v0.a;
            var value = _v0.b;
            return key + ("=\"" + ($billstclair$elm_xml_eeue56$Xml$Encode$propToString(value) + "\""));
        }, $elm$core$Dict$toList(props))));
    };
    var $billstclair$elm_xml_eeue56$Xml$Encode$valueToString_fn = function (level, indent, value) {
        switch (value.$) {
            case 0:
                var name = value.a;
                var props = value.b;
                var nextValue = value.c;
                var indentString = $billstclair$elm_xml_eeue56$Xml$Encode$needsIndent(nextValue) ? "\n" : "";
                var indentClosing = $billstclair$elm_xml_eeue56$Xml$Encode$needsIndent(nextValue) ? $elm$core$String$repeat_fn(level * indent, " ") : "";
                return $elm$core$String$repeat_fn(level * indent, " ") + ("<" + (name + ($billstclair$elm_xml_eeue56$Xml$Encode$propsToString(props) + (">" + (indentString + ($billstclair$elm_xml_eeue56$Xml$Encode$valueToString_fn(level, indent, nextValue) + (indentString + (indentClosing + ("</" + (name + ">"))))))))));
            case 1:
                var str = value.a;
                return $billstclair$elm_xml_eeue56$Xml$encodeXmlEntities(str);
            case 2:
                var n = value.a;
                return $elm$core$String$fromInt(n);
            case 3:
                var n = value.a;
                return $elm$core$String$fromFloat(n);
            case 4:
                var b = value.a;
                return $billstclair$elm_xml_eeue56$Xml$Encode$boolToString(b);
            case 5:
                var xs = value.a;
                return $elm$core$String$join_fn("\n", $elm$core$List$map_fn(A2($billstclair$elm_xml_eeue56$Xml$Encode$valueToString, level + 1, indent), xs));
            default:
                var name = value.a;
                var props = value.b;
                return "<?" + (name + ($billstclair$elm_xml_eeue56$Xml$Encode$propsToString(props) + "?>"));
        }
    }, $billstclair$elm_xml_eeue56$Xml$Encode$valueToString = F3($billstclair$elm_xml_eeue56$Xml$Encode$valueToString_fn);
    var $billstclair$elm_xml_eeue56$Xml$Encode$encode_fn = function (indent, value) {
        return $billstclair$elm_xml_eeue56$Xml$Encode$valueToString_fn(-1, indent, value);
    }, $billstclair$elm_xml_eeue56$Xml$Encode$encode = F2($billstclair$elm_xml_eeue56$Xml$Encode$encode_fn);
    var $elm$core$Dict$Black = 1;
    var $elm$core$Dict$RBNode_elm_builtin_fn = function (a, b, c, d, e) {
        return { $: -1, a: a, b: b, c: c, d: d, e: e };
    }, $elm$core$Dict$RBNode_elm_builtin = F5($elm$core$Dict$RBNode_elm_builtin_fn);
    var $elm$core$Dict$Red = 0;
    var $elm$core$Dict$balance_fn = function (color, key, value, left, right) {
        if ((right.$ === -1) && (!right.a)) {
            var _v1 = right.a;
            var rK = right.b;
            var rV = right.c;
            var rLeft = right.d;
            var rRight = right.e;
            if ((left.$ === -1) && (!left.a)) {
                var _v3 = left.a;
                var lK = left.b;
                var lV = left.c;
                var lLeft = left.d;
                var lRight = left.e;
                return $elm$core$Dict$RBNode_elm_builtin_fn(0, key, value, $elm$core$Dict$RBNode_elm_builtin_fn(1, lK, lV, lLeft, lRight), $elm$core$Dict$RBNode_elm_builtin_fn(1, rK, rV, rLeft, rRight));
            }
            else {
                return $elm$core$Dict$RBNode_elm_builtin_fn(color, rK, rV, $elm$core$Dict$RBNode_elm_builtin_fn(0, key, value, left, rLeft), rRight);
            }
        }
        else {
            if ((((left.$ === -1) && (!left.a)) && (left.d.$ === -1)) && (!left.d.a)) {
                var _v5 = left.a;
                var lK = left.b;
                var lV = left.c;
                var _v6 = left.d;
                var _v7 = _v6.a;
                var llK = _v6.b;
                var llV = _v6.c;
                var llLeft = _v6.d;
                var llRight = _v6.e;
                var lRight = left.e;
                return $elm$core$Dict$RBNode_elm_builtin_fn(0, lK, lV, $elm$core$Dict$RBNode_elm_builtin_fn(1, llK, llV, llLeft, llRight), $elm$core$Dict$RBNode_elm_builtin_fn(1, key, value, lRight, right));
            }
            else {
                return $elm$core$Dict$RBNode_elm_builtin_fn(color, key, value, left, right);
            }
        }
    }, $elm$core$Dict$balance = F5($elm$core$Dict$balance_fn);
    var $elm$core$Basics$compare = _Utils_compare;
    var $elm$core$Dict$insertHelp_fn = function (key, value, dict) {
        if (dict.$ === -2) {
            return $elm$core$Dict$RBNode_elm_builtin_fn(0, key, value, $elm$core$Dict$RBEmpty_elm_builtin, $elm$core$Dict$RBEmpty_elm_builtin);
        }
        else {
            var nColor = dict.a;
            var nKey = dict.b;
            var nValue = dict.c;
            var nLeft = dict.d;
            var nRight = dict.e;
            var _v1 = _Utils_compare_fn(key, nKey);
            switch (_v1) {
                case 0:
                    return $elm$core$Dict$balance_fn(nColor, nKey, nValue, $elm$core$Dict$insertHelp_fn(key, value, nLeft), nRight);
                case 1:
                    return $elm$core$Dict$RBNode_elm_builtin_fn(nColor, nKey, value, nLeft, nRight);
                default:
                    return $elm$core$Dict$balance_fn(nColor, nKey, nValue, nLeft, $elm$core$Dict$insertHelp_fn(key, value, nRight));
            }
        }
    }, $elm$core$Dict$insertHelp = F3($elm$core$Dict$insertHelp_fn);
    var $elm$core$Dict$insert_fn = function (key, value, dict) {
        var _v0 = $elm$core$Dict$insertHelp_fn(key, value, dict);
        if ((_v0.$ === -1) && (!_v0.a)) {
            var _v1 = _v0.a;
            var k = _v0.b;
            var v = _v0.c;
            var l = _v0.d;
            var r = _v0.e;
            return $elm$core$Dict$RBNode_elm_builtin_fn(1, k, v, l, r);
        }
        else {
            var x = _v0;
            return x;
        }
    }, $elm$core$Dict$insert = F3($elm$core$Dict$insert_fn);
    var $elm$core$Dict$fromList = function (assocs) {
        return $elm$core$List$foldl_fn_unwrapped(function (_v0, dict) {
            var key = _v0.a;
            var value = _v0.b;
            return $elm$core$Dict$insert_fn(key, value, dict);
        }, $elm$core$Dict$empty, assocs);
    };
    var $ryannhg$date_format$DateFormat$DayOfMonthFixed = { $: 7 };
    var $ryannhg$date_format$DateFormat$dayOfMonthFixed = $ryannhg$date_format$DateFormat$DayOfMonthFixed;
    var $ryannhg$date_format$DateFormat$Language$Language_fn = function (toMonthName, toMonthAbbreviation, toWeekdayName, toWeekdayAbbreviation, toAmPm, toOrdinalSuffix) {
        return { os: toAmPm, ou: toMonthAbbreviation, ov: toMonthName, ho: toOrdinalSuffix, ow: toWeekdayAbbreviation, ox: toWeekdayName };
    }, $ryannhg$date_format$DateFormat$Language$Language = F6($ryannhg$date_format$DateFormat$Language$Language_fn);
    var $elm$core$Basics$composeR_fn = function (f, g, x) {
        return g(f(x));
    }, $elm$core$Basics$composeR = F3($elm$core$Basics$composeR_fn);
    var $elm$core$String$slice = _String_slice;
    var $elm$core$String$left_fn = function (n, string) {
        return (n < 1) ? "" : _String_slice_fn(0, n, string);
    }, $elm$core$String$left = F2($elm$core$String$left_fn);
    var $ryannhg$date_format$DateFormat$Language$toEnglishAmPm = function (hour) {
        return (hour > 11) ? "pm" : "am";
    };
    var $ryannhg$date_format$DateFormat$Language$toEnglishMonthName = function (month) {
        switch (month) {
            case 0:
                return "January";
            case 1:
                return "February";
            case 2:
                return "March";
            case 3:
                return "April";
            case 4:
                return "May";
            case 5:
                return "June";
            case 6:
                return "July";
            case 7:
                return "August";
            case 8:
                return "September";
            case 9:
                return "October";
            case 10:
                return "November";
            default:
                return "December";
        }
    };
    var $ryannhg$date_format$DateFormat$Language$toEnglishSuffix = function (num) {
        var _v0 = _Basics_modBy_fn(100, num);
        switch (_v0) {
            case 11:
                return "th";
            case 12:
                return "th";
            case 13:
                return "th";
            default:
                var _v1 = _Basics_modBy_fn(10, num);
                switch (_v1) {
                    case 1:
                        return "st";
                    case 2:
                        return "nd";
                    case 3:
                        return "rd";
                    default:
                        return "th";
                }
        }
    };
    var $ryannhg$date_format$DateFormat$Language$toEnglishWeekdayName = function (weekday) {
        switch (weekday) {
            case 0:
                return "Monday";
            case 1:
                return "Tuesday";
            case 2:
                return "Wednesday";
            case 3:
                return "Thursday";
            case 4:
                return "Friday";
            case 5:
                return "Saturday";
            default:
                return "Sunday";
        }
    };
    var $ryannhg$date_format$DateFormat$Language$english = $ryannhg$date_format$DateFormat$Language$Language_fn($ryannhg$date_format$DateFormat$Language$toEnglishMonthName, A2($elm$core$Basics$composeR, $ryannhg$date_format$DateFormat$Language$toEnglishMonthName, $elm$core$String$left(3)), $ryannhg$date_format$DateFormat$Language$toEnglishWeekdayName, A2($elm$core$Basics$composeR, $ryannhg$date_format$DateFormat$Language$toEnglishWeekdayName, $elm$core$String$left(3)), $ryannhg$date_format$DateFormat$Language$toEnglishAmPm, $ryannhg$date_format$DateFormat$Language$toEnglishSuffix);
    var $ryannhg$date_format$DateFormat$amPm_fn = function (language, zone, posix) {
        return language.os($elm$time$Time$toHour_fn(zone, posix));
    }, $ryannhg$date_format$DateFormat$amPm = F3($ryannhg$date_format$DateFormat$amPm_fn);
    var $ryannhg$date_format$DateFormat$dayOfMonth = $elm$time$Time$toDay;
    var $elm$time$Time$Sun = 6;
    var $elm$time$Time$Fri = 4;
    var $elm$time$Time$Mon = 0;
    var $elm$time$Time$Sat = 5;
    var $elm$time$Time$Thu = 3;
    var $elm$time$Time$Tue = 1;
    var $elm$time$Time$Wed = 2;
    var $ryannhg$date_format$DateFormat$days = _List_fromArray([6, 0, 1, 2, 3, 4, 5]);
    var $elm$core$List$filter_fn = function (f, xs) {
        var tmp = _List_Cons(undefined, _List_Nil);
        var end = tmp;
        for (; xs.b; xs = xs.b) {
            if (f(xs.a)) {
                var next = _List_Cons(xs.a, _List_Nil);
                end.b = next;
                end = next;
            }
        }
        return tmp.
            b;
    }, $elm$core$List$filter = F2($elm$core$List$filter_fn);
    var $elm$core$List$head = function (list) {
        if (list.b) {
            var x = list.a;
            var xs = list.b;
            return $elm$core$Maybe$Just(x);
        }
        else {
            return $elm$core$Maybe$Nothing;
        }
    };
    var $elm$time$Time$toWeekday_fn = function (zone, time) {
        var _v0 = _Basics_modBy_fn(7, $elm$time$Time$flooredDiv_fn($elm$time$Time$toAdjustedMinutes_fn(zone, time), 60 * 24));
        switch (_v0) {
            case 0:
                return 3;
            case 1:
                return 4;
            case 2:
                return 5;
            case 3:
                return 6;
            case 4:
                return 0;
            case 5:
                return 1;
            default:
                return 2;
        }
    }, $elm$time$Time$toWeekday = F2($elm$time$Time$toWeekday_fn);
    var $elm$core$Maybe$withDefault_fn = function (_default, maybe) {
        if (!maybe.$) {
            var value = maybe.a;
            return value;
        }
        else {
            return _default;
        }
    }, $elm$core$Maybe$withDefault = F2($elm$core$Maybe$withDefault_fn);
    var $ryannhg$date_format$DateFormat$dayOfWeek_fn = function (zone, posix) {
        return function (_v1) {
            var i = _v1.a;
            return i;
        }($elm$core$Maybe$withDefault_fn(_Utils_Tuple2(0, 6), $elm$core$List$head($elm$core$List$filter_fn(function (_v0) {
            var day = _v0.b;
            return _Utils_eq(day, $elm$time$Time$toWeekday_fn(zone, posix));
        }, $elm$core$List$indexedMap_fn_unwrapped(function (i, day) {
            return _Utils_Tuple2(i, day);
        }, $ryannhg$date_format$DateFormat$days)))));
    }, $ryannhg$date_format$DateFormat$dayOfWeek = F2($ryannhg$date_format$DateFormat$dayOfWeek_fn);
    var $elm$core$Basics$neq = _Utils_notEqual;
    var $ryannhg$date_format$DateFormat$isLeapYear = function (year_) {
        return (!(!_Basics_modBy_fn(4, year_))) ? false : ((!(!_Basics_modBy_fn(100, year_))) ? true : ((!(!_Basics_modBy_fn(400, year_))) ? false : true));
    };
    var $ryannhg$date_format$DateFormat$daysInMonth_fn = function (year_, month) {
        switch (month) {
            case 0:
                return 31;
            case 1:
                return $ryannhg$date_format$DateFormat$isLeapYear(year_) ? 29 : 28;
            case 2:
                return 31;
            case 3:
                return 30;
            case 4:
                return 31;
            case 5:
                return 30;
            case 6:
                return 31;
            case 7:
                return 31;
            case 8:
                return 30;
            case 9:
                return 31;
            case 10:
                return 30;
            default:
                return 31;
        }
    }, $ryannhg$date_format$DateFormat$daysInMonth = F2($ryannhg$date_format$DateFormat$daysInMonth_fn);
    var $ryannhg$date_format$DateFormat$months = _List_fromArray([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]);
    var $ryannhg$date_format$DateFormat$monthPair_fn = function (zone, posix) {
        return $elm$core$Maybe$withDefault_fn(_Utils_Tuple2(0, 0), $elm$core$List$head($elm$core$List$filter_fn(function (_v0) {
            var i = _v0.a;
            var m = _v0.b;
            return _Utils_eq(m, $elm$time$Time$toMonth_fn(zone, posix));
        }, $elm$core$List$indexedMap_fn_unwrapped(function (a, b) {
            return _Utils_Tuple2(a, b);
        }, $ryannhg$date_format$DateFormat$months))));
    }, $ryannhg$date_format$DateFormat$monthPair = F2($ryannhg$date_format$DateFormat$monthPair_fn);
    var $ryannhg$date_format$DateFormat$monthNumber__fn = function (zone, posix) {
        return 1 + function (_v0) {
            var i = _v0.a;
            var m = _v0.b;
            return i;
        }($ryannhg$date_format$DateFormat$monthPair_fn(zone, posix));
    }, $ryannhg$date_format$DateFormat$monthNumber_ = F2($ryannhg$date_format$DateFormat$monthNumber__fn);
    var $elm$core$List$sum = function (numbers) {
        return $elm$core$List$foldl_fn($elm$core$Basics$add, 0, numbers);
    };
    var $elm$core$List$takeReverse_fn = function (n, list, kept) {
        takeReverse: while (true) {
            if (n <= 0) {
                return kept;
            }
            else {
                if (!list.b) {
                    return kept;
                }
                else {
                    var x = list.a;
                    var xs = list.b;
                    var $temp$n = n - 1, $temp$list = xs, $temp$kept = _List_Cons(x, kept);
                    n = $temp$n;
                    list = $temp$list;
                    kept = $temp$kept;
                    continue takeReverse;
                }
            }
        }
    }, $elm$core$List$takeReverse = F3($elm$core$List$takeReverse_fn);
    var $elm$core$List$takeTailRec_fn = function (n, list) {
        return $elm$core$List$reverse($elm$core$List$takeReverse_fn(n, list, _List_Nil));
    }, $elm$core$List$takeTailRec = F2($elm$core$List$takeTailRec_fn);
    var $elm$core$List$takeFast_fn = function (ctr, n, list) {
        if (n <= 0) {
            return _List_Nil;
        }
        else {
            var _v0 = _Utils_Tuple2(n, list);
            _v0$1: while (true) {
                _v0$5: while (true) {
                    if (!_v0.b.b) {
                        return list;
                    }
                    else {
                        if (_v0.b.b.b) {
                            switch (_v0.a) {
                                case 1:
                                    break _v0$1;
                                case 2:
                                    var _v2 = _v0.b;
                                    var x = _v2.a;
                                    var _v3 = _v2.b;
                                    var y = _v3.a;
                                    return _List_fromArray([x, y]);
                                case 3:
                                    if (_v0.b.b.b.b) {
                                        var _v4 = _v0.b;
                                        var x = _v4.a;
                                        var _v5 = _v4.b;
                                        var y = _v5.a;
                                        var _v6 = _v5.b;
                                        var z = _v6.a;
                                        return _List_fromArray([x, y, z]);
                                    }
                                    else {
                                        break _v0$5;
                                    }
                                default:
                                    if (_v0.b.b.b.b && _v0.b.b.b.b.b) {
                                        var _v7 = _v0.b;
                                        var x = _v7.a;
                                        var _v8 = _v7.b;
                                        var y = _v8.a;
                                        var _v9 = _v8.b;
                                        var z = _v9.a;
                                        var _v10 = _v9.b;
                                        var w = _v10.a;
                                        var tl = _v10.b;
                                        return (ctr > 1000) ? _List_Cons(x, _List_Cons(y, _List_Cons(z, _List_Cons(w, $elm$core$List$takeTailRec_fn(n - 4, tl))))) : _List_Cons(x, _List_Cons(y, _List_Cons(z, _List_Cons(w, $elm$core$List$takeFast_fn(ctr + 1, n - 4, tl)))));
                                    }
                                    else {
                                        break _v0$5;
                                    }
                            }
                        }
                        else {
                            if (_v0.a === 1) {
                                break _v0$1;
                            }
                            else {
                                break _v0$5;
                            }
                        }
                    }
                }
                return list;
            }
            var _v1 = _v0.b;
            var x = _v1.a;
            return _List_fromArray([x]);
        }
    }, $elm$core$List$takeFast = F3($elm$core$List$takeFast_fn);
    var $elm$core$List$take_fn = function (n, xs) {
        var tmp = _List_Cons(undefined, _List_Nil);
        var end = tmp;
        for (var i = 0; i < n && xs.b; xs = xs.
            b, i++) {
            var next = _List_Cons(xs.a, _List_Nil);
            end.b = next;
            end = next;
        }
        return tmp.b;
    }, $elm$core$List$take = F2($elm$core$List$take_fn);
    var $ryannhg$date_format$DateFormat$dayOfYear_fn = function (zone, posix) {
        var monthsBeforeThisOne = $elm$core$List$take_fn($ryannhg$date_format$DateFormat$monthNumber__fn(zone, posix) - 1, $ryannhg$date_format$DateFormat$months);
        var daysBeforeThisMonth = $elm$core$List$sum($elm$core$List$map_fn($ryannhg$date_format$DateFormat$daysInMonth($elm$time$Time$toYear_fn(zone, posix)), monthsBeforeThisOne));
        return daysBeforeThisMonth + $elm$time$Time$toDay_fn(zone, posix);
    }, $ryannhg$date_format$DateFormat$dayOfYear = F2($ryannhg$date_format$DateFormat$dayOfYear_fn);
    var $ryannhg$date_format$DateFormat$quarter_fn = function (zone, posix) {
        return ($ryannhg$date_format$DateFormat$monthNumber__fn(zone, posix) / 4) | 0;
    }, $ryannhg$date_format$DateFormat$quarter = F2($ryannhg$date_format$DateFormat$quarter_fn);
    var $elm$core$String$right_fn = function (n, string) {
        return (n < 1) ? "" : _String_slice_fn(-n, $elm$core$String$length(string), string);
    }, $elm$core$String$right = F2($elm$core$String$right_fn);
    var $ryannhg$date_format$DateFormat$toFixedLength_fn = function (totalChars, num) {
        var numStr = $elm$core$String$fromInt(num);
        var numZerosNeeded = totalChars - $elm$core$String$length(numStr);
        var zeros = $elm$core$String$join_fn("", $elm$core$List$map_fn(function (_v0) {
            return "0";
        }, $elm$core$List$range_fn(1, numZerosNeeded)));
        return _Utils_ap(zeros, numStr);
    }, $ryannhg$date_format$DateFormat$toFixedLength = F2($ryannhg$date_format$DateFormat$toFixedLength_fn);
    var $elm$core$String$toLower = _String_toLower;
    var $ryannhg$date_format$DateFormat$toNonMilitary = function (num) {
        return (!num) ? 12 : ((num <= 12) ? num : (num - 12));
    };
    var $elm$core$String$toUpper = _String_toUpper;
    var $elm$core$Basics$round = _Basics_round;
    var $ryannhg$date_format$DateFormat$millisecondsPerYear = $elm$core$Basics$round((((1000 * 60) * 60) * 24) * 365.25);
    var $ryannhg$date_format$DateFormat$firstDayOfYear_fn = function (zone, time) {
        return $elm$time$Time$millisToPosix($ryannhg$date_format$DateFormat$millisecondsPerYear * $elm$time$Time$toYear_fn(zone, time));
    }, $ryannhg$date_format$DateFormat$firstDayOfYear = F2($ryannhg$date_format$DateFormat$firstDayOfYear_fn);
    var $ryannhg$date_format$DateFormat$weekOfYear_fn = function (zone, posix) {
        var firstDay = $ryannhg$date_format$DateFormat$firstDayOfYear_fn(zone, posix);
        var firstDayOffset = $ryannhg$date_format$DateFormat$dayOfWeek_fn(zone, firstDay);
        var daysSoFar = $ryannhg$date_format$DateFormat$dayOfYear_fn(zone, posix);
        return (((daysSoFar + firstDayOffset) / 7) | 0) + 1;
    }, $ryannhg$date_format$DateFormat$weekOfYear = F2($ryannhg$date_format$DateFormat$weekOfYear_fn);
    var $ryannhg$date_format$DateFormat$year_fn = function (zone, time) {
        return $elm$core$String$fromInt($elm$time$Time$toYear_fn(zone, time));
    }, $ryannhg$date_format$DateFormat$year = F2($ryannhg$date_format$DateFormat$year_fn);
    var $ryannhg$date_format$DateFormat$piece_fn = function (language, zone, posix, token) {
        switch (token.$) {
            case 0:
                return $elm$core$String$fromInt($ryannhg$date_format$DateFormat$monthNumber__fn(zone, posix));
            case 1:
                return function (num) {
                    return _Utils_ap($elm$core$String$fromInt(num), language.ho(num));
                }($ryannhg$date_format$DateFormat$monthNumber__fn(zone, posix));
            case 2:
                return $ryannhg$date_format$DateFormat$toFixedLength_fn(2, $ryannhg$date_format$DateFormat$monthNumber__fn(zone, posix));
            case 3:
                return language.ou($elm$time$Time$toMonth_fn(zone, posix));
            case 4:
                return language.ov($elm$time$Time$toMonth_fn(zone, posix));
            case 17:
                return $elm$core$String$fromInt(1 + $ryannhg$date_format$DateFormat$quarter_fn(zone, posix));
            case 18:
                return function (num) {
                    return _Utils_ap($elm$core$String$fromInt(num), language.ho(num));
                }(1 + $ryannhg$date_format$DateFormat$quarter_fn(zone, posix));
            case 5:
                return $elm$core$String$fromInt($elm$time$Time$toDay_fn(zone, posix));
            case 6:
                return function (num) {
                    return _Utils_ap($elm$core$String$fromInt(num), language.ho(num));
                }($elm$time$Time$toDay_fn(zone, posix));
            case 7:
                return $ryannhg$date_format$DateFormat$toFixedLength_fn(2, $elm$time$Time$toDay_fn(zone, posix));
            case 8:
                return $elm$core$String$fromInt($ryannhg$date_format$DateFormat$dayOfYear_fn(zone, posix));
            case 9:
                return function (num) {
                    return _Utils_ap($elm$core$String$fromInt(num), language.ho(num));
                }($ryannhg$date_format$DateFormat$dayOfYear_fn(zone, posix));
            case 10:
                return $ryannhg$date_format$DateFormat$toFixedLength_fn(3, $ryannhg$date_format$DateFormat$dayOfYear_fn(zone, posix));
            case 11:
                return $elm$core$String$fromInt($ryannhg$date_format$DateFormat$dayOfWeek_fn(zone, posix));
            case 12:
                return function (num) {
                    return _Utils_ap($elm$core$String$fromInt(num), language.ho(num));
                }($ryannhg$date_format$DateFormat$dayOfWeek_fn(zone, posix));
            case 13:
                return language.ow($elm$time$Time$toWeekday_fn(zone, posix));
            case 14:
                return language.ox($elm$time$Time$toWeekday_fn(zone, posix));
            case 19:
                return $elm$core$String$fromInt($ryannhg$date_format$DateFormat$weekOfYear_fn(zone, posix));
            case 20:
                return function (num) {
                    return _Utils_ap($elm$core$String$fromInt(num), language.ho(num));
                }($ryannhg$date_format$DateFormat$weekOfYear_fn(zone, posix));
            case 21:
                return $ryannhg$date_format$DateFormat$toFixedLength_fn(2, $ryannhg$date_format$DateFormat$weekOfYear_fn(zone, posix));
            case 15:
                return $elm$core$String$right_fn(2, $ryannhg$date_format$DateFormat$year_fn(zone, posix));
            case 16:
                return $ryannhg$date_format$DateFormat$year_fn(zone, posix);
            case 22:
                return $elm$core$String$toUpper($ryannhg$date_format$DateFormat$amPm_fn(language, zone, posix));
            case 23:
                return $elm$core$String$toLower($ryannhg$date_format$DateFormat$amPm_fn(language, zone, posix));
            case 24:
                return $elm$core$String$fromInt($elm$time$Time$toHour_fn(zone, posix));
            case 25:
                return $ryannhg$date_format$DateFormat$toFixedLength_fn(2, $elm$time$Time$toHour_fn(zone, posix));
            case 26:
                return $elm$core$String$fromInt($ryannhg$date_format$DateFormat$toNonMilitary($elm$time$Time$toHour_fn(zone, posix)));
            case 27:
                return $ryannhg$date_format$DateFormat$toFixedLength_fn(2, $ryannhg$date_format$DateFormat$toNonMilitary($elm$time$Time$toHour_fn(zone, posix)));
            case 28:
                return $elm$core$String$fromInt(1 + $elm$time$Time$toHour_fn(zone, posix));
            case 29:
                return $ryannhg$date_format$DateFormat$toFixedLength_fn(2, 1 + $elm$time$Time$toHour_fn(zone, posix));
            case 30:
                return $elm$core$String$fromInt($elm$time$Time$toMinute_fn(zone, posix));
            case 31:
                return $ryannhg$date_format$DateFormat$toFixedLength_fn(2, $elm$time$Time$toMinute_fn(zone, posix));
            case 32:
                return $elm$core$String$fromInt($elm$time$Time$toSecond_fn(zone, posix));
            case 33:
                return $ryannhg$date_format$DateFormat$toFixedLength_fn(2, $elm$time$Time$toSecond_fn(zone, posix));
            case 34:
                return $elm$core$String$fromInt($elm$time$Time$toMillis_fn(zone, posix));
            case 35:
                return $ryannhg$date_format$DateFormat$toFixedLength_fn(3, $elm$time$Time$toMillis_fn(zone, posix));
            default:
                var string = token.a;
                return string;
        }
    }, $ryannhg$date_format$DateFormat$piece = F4($ryannhg$date_format$DateFormat$piece_fn);
    var $ryannhg$date_format$DateFormat$formatWithLanguage_fn = function (language, tokens, zone, time) {
        return $elm$core$String$join_fn("", $elm$core$List$map_fn(A3($ryannhg$date_format$DateFormat$piece, language, zone, time), tokens));
    }, $ryannhg$date_format$DateFormat$formatWithLanguage = F4($ryannhg$date_format$DateFormat$formatWithLanguage_fn);
    var $ryannhg$date_format$DateFormat$format_a0 = $ryannhg$date_format$DateFormat$Language$english, $ryannhg$date_format$DateFormat$format = $ryannhg$date_format$DateFormat$formatWithLanguage($ryannhg$date_format$DateFormat$format_a0);
    var $ryannhg$date_format$DateFormat$DayOfWeekNameFull = { $: 14 };
    var $ryannhg$date_format$DateFormat$dayOfWeekNameFull = $ryannhg$date_format$DateFormat$DayOfWeekNameFull;
    var $dmy$elm_imf_date_time$Imf$DateTime$formatDay_fn = function (tz, posix) {
        return $elm$core$String$left_fn(3, $ryannhg$date_format$DateFormat$formatWithLanguage_fn($ryannhg$date_format$DateFormat$format_a0, _List_fromArray([$ryannhg$date_format$DateFormat$dayOfWeekNameFull]), tz, posix));
    }, $dmy$elm_imf_date_time$Imf$DateTime$formatDay = F2($dmy$elm_imf_date_time$Imf$DateTime$formatDay_fn);
    var $elm$core$Basics$abs = function (n) {
        return (n < 0) ? (-n) : n;
    };
    var $elm$core$String$concat = function (strings) {
        return $elm$core$String$join_fn("", strings);
    };
    var $justinmimbs$date$Date$toRataDie = function (_v0) {
        var rd = _v0;
        return rd;
    };
    var $justinmimbs$time_extra$Time$Extra$dateToMillis = function (date) {
        var daysSinceEpoch = $justinmimbs$date$Date$toRataDie(date) - 719163;
        return daysSinceEpoch * 86400000;
    };
    var $justinmimbs$date$Date$RD = $elm$core$Basics$identity;
    var $elm$core$Basics$clamp_fn = function (low, high, number) {
        return (_Utils_cmp(number, low) < 0) ? low : ((_Utils_cmp(number, high) > 0) ? high : number);
    }, $elm$core$Basics$clamp = F3($elm$core$Basics$clamp_fn);
    var $justinmimbs$date$Date$isLeapYear = function (y) {
        return ((!_Basics_modBy_fn(4, y)) && (!(!_Basics_modBy_fn(100, y)))) || (!_Basics_modBy_fn(400, y));
    };
    var $justinmimbs$date$Date$daysBeforeMonth_fn = function (y, m) {
        var leapDays = $justinmimbs$date$Date$isLeapYear(y) ? 1 : 0;
        switch (m) {
            case 0:
                return 0;
            case 1:
                return 31;
            case 2:
                return 59 + leapDays;
            case 3:
                return 90 + leapDays;
            case 4:
                return 120 + leapDays;
            case 5:
                return 151 + leapDays;
            case 6:
                return 181 + leapDays;
            case 7:
                return 212 + leapDays;
            case 8:
                return 243 + leapDays;
            case 9:
                return 273 + leapDays;
            case 10:
                return 304 + leapDays;
            default:
                return 334 + leapDays;
        }
    }, $justinmimbs$date$Date$daysBeforeMonth = F2($justinmimbs$date$Date$daysBeforeMonth_fn);
    var $justinmimbs$date$Date$floorDiv_fn = function (a, b) {
        return $elm$core$Basics$floor(a / b);
    }, $justinmimbs$date$Date$floorDiv = F2($justinmimbs$date$Date$floorDiv_fn);
    var $justinmimbs$date$Date$daysBeforeYear = function (y1) {
        var y = y1 - 1;
        var leapYears = ($justinmimbs$date$Date$floorDiv_fn(y, 4) - $justinmimbs$date$Date$floorDiv_fn(y, 100)) + $justinmimbs$date$Date$floorDiv_fn(y, 400);
        return (365 * y) + leapYears;
    };
    var $justinmimbs$date$Date$daysInMonth_fn = function (y, m) {
        switch (m) {
            case 0:
                return 31;
            case 1:
                return $justinmimbs$date$Date$isLeapYear(y) ? 29 : 28;
            case 2:
                return 31;
            case 3:
                return 30;
            case 4:
                return 31;
            case 5:
                return 30;
            case 6:
                return 31;
            case 7:
                return 31;
            case 8:
                return 30;
            case 9:
                return 31;
            case 10:
                return 30;
            default:
                return 31;
        }
    }, $justinmimbs$date$Date$daysInMonth = F2($justinmimbs$date$Date$daysInMonth_fn);
    var $justinmimbs$date$Date$fromCalendarDate_fn = function (y, m, d) {
        return ($justinmimbs$date$Date$daysBeforeYear(y) + $justinmimbs$date$Date$daysBeforeMonth_fn(y, m)) + $elm$core$Basics$clamp_fn(1, $justinmimbs$date$Date$daysInMonth_fn(y, m), d);
    }, $justinmimbs$date$Date$fromCalendarDate = F3($justinmimbs$date$Date$fromCalendarDate_fn);
    var $justinmimbs$date$Date$fromPosix_fn = function (zone, posix) {
        return $justinmimbs$date$Date$fromCalendarDate_fn($elm$time$Time$toYear_fn(zone, posix), $elm$time$Time$toMonth_fn(zone, posix), $elm$time$Time$toDay_fn(zone, posix));
    }, $justinmimbs$date$Date$fromPosix = F2($justinmimbs$date$Date$fromPosix_fn);
    var $justinmimbs$time_extra$Time$Extra$timeFromClock_fn = function (hour, minute, second, millisecond) {
        return (((hour * 3600000) + (minute * 60000)) + (second * 1000)) + millisecond;
    }, $justinmimbs$time_extra$Time$Extra$timeFromClock = F4($justinmimbs$time_extra$Time$Extra$timeFromClock_fn);
    var $justinmimbs$time_extra$Time$Extra$timeFromPosix_fn = function (zone, posix) {
        return $justinmimbs$time_extra$Time$Extra$timeFromClock_fn($elm$time$Time$toHour_fn(zone, posix), $elm$time$Time$toMinute_fn(zone, posix), $elm$time$Time$toSecond_fn(zone, posix), $elm$time$Time$toMillis_fn(zone, posix));
    }, $justinmimbs$time_extra$Time$Extra$timeFromPosix = F2($justinmimbs$time_extra$Time$Extra$timeFromPosix_fn);
    var $justinmimbs$time_extra$Time$Extra$toOffset_fn = function (zone, posix) {
        var millis = $elm$time$Time$posixToMillis(posix);
        var localMillis = $justinmimbs$time_extra$Time$Extra$dateToMillis($justinmimbs$date$Date$fromPosix_fn(zone, posix)) + $justinmimbs$time_extra$Time$Extra$timeFromPosix_fn(zone, posix);
        return ((localMillis - millis) / 60000) | 0;
    }, $justinmimbs$time_extra$Time$Extra$toOffset = F2($justinmimbs$time_extra$Time$Extra$toOffset_fn);
    var $dmy$elm_imf_date_time$Imf$DateTime$formatZone_fn = function (tz, posix) {
        var minuteOffset = $justinmimbs$time_extra$Time$Extra$toOffset_fn(tz, posix);
        var minute = $elm$core$String$padLeft_fn(2, "0", $elm$core$String$fromInt(_Basics_modBy_fn(60, $elm$core$Basics$abs(minuteOffset))));
        var hour = $elm$core$String$padLeft_fn(2, "0", $elm$core$String$fromInt(($elm$core$Basics$abs(minuteOffset) / 60) | 0));
        return $elm$core$String$concat(_List_fromArray([
            (minuteOffset >= 0) ? "+" : "-",
            hour,
            minute
        ]));
    }, $dmy$elm_imf_date_time$Imf$DateTime$formatZone = F2($dmy$elm_imf_date_time$Imf$DateTime$formatZone_fn);
    var $ryannhg$date_format$DateFormat$HourMilitaryFixed = { $: 25 };
    var $ryannhg$date_format$DateFormat$hourMilitaryFixed = $ryannhg$date_format$DateFormat$HourMilitaryFixed;
    var $ryannhg$date_format$DateFormat$MinuteFixed = { $: 31 };
    var $ryannhg$date_format$DateFormat$minuteFixed = $ryannhg$date_format$DateFormat$MinuteFixed;
    var $ryannhg$date_format$DateFormat$MonthNameAbbreviated = { $: 3 };
    var $ryannhg$date_format$DateFormat$monthNameAbbreviated = $ryannhg$date_format$DateFormat$MonthNameAbbreviated;
    var $ryannhg$date_format$DateFormat$SecondFixed = { $: 33 };
    var $ryannhg$date_format$DateFormat$secondFixed = $ryannhg$date_format$DateFormat$SecondFixed;
    var $ryannhg$date_format$DateFormat$Text = function (a) {
        return { $: 36, a: a };
    };
    var $ryannhg$date_format$DateFormat$text = $ryannhg$date_format$DateFormat$Text;
    var $ryannhg$date_format$DateFormat$YearNumber = { $: 16 };
    var $ryannhg$date_format$DateFormat$yearNumber = $ryannhg$date_format$DateFormat$YearNumber;
    var $dmy$elm_imf_date_time$Imf$DateTime$fromPosix_fn = function (tz, posix) {
        return $ryannhg$date_format$DateFormat$formatWithLanguage_fn($ryannhg$date_format$DateFormat$format_a0, _List_fromArray([
            $ryannhg$date_format$DateFormat$text($dmy$elm_imf_date_time$Imf$DateTime$formatDay_fn(tz, posix)),
            $ryannhg$date_format$DateFormat$text(", "),
            $ryannhg$date_format$DateFormat$dayOfMonthFixed,
            $ryannhg$date_format$DateFormat$text(" "),
            $ryannhg$date_format$DateFormat$monthNameAbbreviated,
            $ryannhg$date_format$DateFormat$text(" "),
            $ryannhg$date_format$DateFormat$yearNumber,
            $ryannhg$date_format$DateFormat$text(" "),
            $ryannhg$date_format$DateFormat$hourMilitaryFixed,
            $ryannhg$date_format$DateFormat$text(":"),
            $ryannhg$date_format$DateFormat$minuteFixed,
            $ryannhg$date_format$DateFormat$text(":"),
            $ryannhg$date_format$DateFormat$secondFixed,
            $ryannhg$date_format$DateFormat$text(" "),
            $ryannhg$date_format$DateFormat$text($dmy$elm_imf_date_time$Imf$DateTime$formatZone_fn(tz, posix))
        ]), tz, posix);
    }, $dmy$elm_imf_date_time$Imf$DateTime$fromPosix = F2($dmy$elm_imf_date_time$Imf$DateTime$fromPosix_fn);
    var $billstclair$elm_xml_eeue56$Xml$Object = function (a) {
        return { $: 5, a: a };
    };
    var $billstclair$elm_xml_eeue56$Xml$Tag_fn = function (a, b, c) {
        return { $: 0, a: a, b: b, c: c };
    }, $billstclair$elm_xml_eeue56$Xml$Tag = F3($billstclair$elm_xml_eeue56$Xml$Tag_fn);
    var $billstclair$elm_xml_eeue56$Xml$Encode$object = function (values) {
        return $billstclair$elm_xml_eeue56$Xml$Object($elm$core$List$map_fn(function (_v0) {
            var name = _v0.a;
            var props = _v0.b;
            var value = _v0.c;
            return $billstclair$elm_xml_eeue56$Xml$Tag_fn(name, props, value);
        }, values));
    };
    var $billstclair$elm_xml_eeue56$Xml$StrNode = function (a) {
        return { $: 1, a: a };
    };
    var $billstclair$elm_xml_eeue56$Xml$Encode$string = $billstclair$elm_xml_eeue56$Xml$StrNode;
    var $dillonkearns$elm_rss$Rss$encodeCategory = function (category) {
        return $billstclair$elm_xml_eeue56$Xml$Encode$object(_List_fromArray([
            _Utils_Tuple3("category", $elm$core$Dict$empty, $billstclair$elm_xml_eeue56$Xml$Encode$string(category))
        ]));
    };
    var $billstclair$elm_xml_eeue56$Xml$Encode$null = $billstclair$elm_xml_eeue56$Xml$Encode$object(_List_Nil);
    var $dillonkearns$elm_rss$Rss$encodeEnclosure = function (enclosure) {
        return $billstclair$elm_xml_eeue56$Xml$Encode$object(_List_fromArray([
            _Utils_Tuple3("enclosure", $elm$core$Dict$fromList(_List_fromArray([
                _Utils_Tuple2("url", $billstclair$elm_xml_eeue56$Xml$Encode$string(enclosure.lO)),
                _Utils_Tuple2("length", $billstclair$elm_xml_eeue56$Xml$Encode$string("0")),
                _Utils_Tuple2("type", $billstclair$elm_xml_eeue56$Xml$Encode$string(enclosure.nj))
            ])), $billstclair$elm_xml_eeue56$Xml$Encode$null)
        ]));
    };
    var $justinmimbs$date$Date$monthToNumber = function (m) {
        switch (m) {
            case 0:
                return 1;
            case 1:
                return 2;
            case 2:
                return 3;
            case 3:
                return 4;
            case 4:
                return 5;
            case 5:
                return 6;
            case 6:
                return 7;
            case 7:
                return 8;
            case 8:
                return 9;
            case 9:
                return 10;
            case 10:
                return 11;
            default:
                return 12;
        }
    };
    var $justinmimbs$date$Date$numberToMonth = function (mn) {
        var _v0 = $elm$core$Basics$max_fn(1, mn);
        switch (_v0) {
            case 1:
                return 0;
            case 2:
                return 1;
            case 3:
                return 2;
            case 4:
                return 3;
            case 5:
                return 4;
            case 6:
                return 5;
            case 7:
                return 6;
            case 8:
                return 7;
            case 9:
                return 8;
            case 10:
                return 9;
            case 11:
                return 10;
            default:
                return 11;
        }
    };
    var $justinmimbs$date$Date$toCalendarDateHelp_fn = function (y, m, d) {
        toCalendarDateHelp: while (true) {
            var monthDays = $justinmimbs$date$Date$daysInMonth_fn(y, m);
            var mn = $justinmimbs$date$Date$monthToNumber(m);
            if ((mn < 12) && (_Utils_cmp(d, monthDays) > 0)) {
                var $temp$y = y, $temp$m = $justinmimbs$date$Date$numberToMonth(mn + 1), $temp$d = d - monthDays;
                y = $temp$y;
                m = $temp$m;
                d = $temp$d;
                continue toCalendarDateHelp;
            }
            else {
                return { ml: d, fF: m, fT: y };
            }
        }
    }, $justinmimbs$date$Date$toCalendarDateHelp = F3($justinmimbs$date$Date$toCalendarDateHelp_fn);
    var $justinmimbs$date$Date$divWithRemainder_fn = function (a, b) {
        return _Utils_Tuple2($justinmimbs$date$Date$floorDiv_fn(a, b), _Basics_modBy_fn(b, a));
    }, $justinmimbs$date$Date$divWithRemainder = F2($justinmimbs$date$Date$divWithRemainder_fn);
    var $justinmimbs$date$Date$year = function (_v0) {
        var rd = _v0;
        var _v1 = $justinmimbs$date$Date$divWithRemainder_fn(rd, 146097);
        var n400 = _v1.a;
        var r400 = _v1.b;
        var _v2 = $justinmimbs$date$Date$divWithRemainder_fn(r400, 36524);
        var n100 = _v2.a;
        var r100 = _v2.b;
        var _v3 = $justinmimbs$date$Date$divWithRemainder_fn(r100, 1461);
        var n4 = _v3.a;
        var r4 = _v3.b;
        var _v4 = $justinmimbs$date$Date$divWithRemainder_fn(r4, 365);
        var n1 = _v4.a;
        var r1 = _v4.b;
        var n = (!r1) ? 0 : 1;
        return ((((n400 * 400) + (n100 * 100)) + (n4 * 4)) + n1) + n;
    };
    var $justinmimbs$date$Date$toOrdinalDate = function (_v0) {
        var rd = _v0;
        var y = $justinmimbs$date$Date$year(rd);
        return {
            j9: rd - $justinmimbs$date$Date$daysBeforeYear(y),
            fT: y
        };
    };
    var $justinmimbs$date$Date$toCalendarDate = function (_v0) {
        var rd = _v0;
        var date = $justinmimbs$date$Date$toOrdinalDate(rd);
        return $justinmimbs$date$Date$toCalendarDateHelp_fn(date.fT, 0, date.j9);
    };
    var $justinmimbs$date$Date$day_a0 = $justinmimbs$date$Date$toCalendarDate, $justinmimbs$date$Date$day_a1 = function ($) {
        return $.ml;
    }, $justinmimbs$date$Date$day = A2($elm$core$Basics$composeR, $justinmimbs$date$Date$day_a0, $justinmimbs$date$Date$day_a1);
    var $justinmimbs$date$Date$month_a0 = $justinmimbs$date$Date$toCalendarDate, $justinmimbs$date$Date$month_a1 = function ($) {
        return $.fF;
    }, $justinmimbs$date$Date$month = A2($elm$core$Basics$composeR, $justinmimbs$date$Date$month_a0, $justinmimbs$date$Date$month_a1);
    var $justinmimbs$date$Date$monthNumber_a0 = $justinmimbs$date$Date$month, $justinmimbs$date$Date$monthNumber_a1 = $justinmimbs$date$Date$monthToNumber, $justinmimbs$date$Date$monthNumber = A2($elm$core$Basics$composeR, $justinmimbs$date$Date$monthNumber_a0, $justinmimbs$date$Date$monthNumber_a1);
    var $justinmimbs$date$Date$ordinalDay_a0 = $justinmimbs$date$Date$toOrdinalDate, $justinmimbs$date$Date$ordinalDay_a1 = function ($) {
        return $.j9;
    }, $justinmimbs$date$Date$ordinalDay = A2($elm$core$Basics$composeR, $justinmimbs$date$Date$ordinalDay_a0, $justinmimbs$date$Date$ordinalDay_a1);
    var $justinmimbs$date$Date$padSignedInt_fn = function (length, _int) {
        return _Utils_ap((_int < 0) ? "-" : "", $elm$core$String$padLeft_fn(length, "0", $elm$core$String$fromInt($elm$core$Basics$abs(_int))));
    }, $justinmimbs$date$Date$padSignedInt = F2($justinmimbs$date$Date$padSignedInt_fn);
    var $justinmimbs$date$Date$monthToQuarter = function (m) {
        return (($justinmimbs$date$Date$monthToNumber(m) + 2) / 3) | 0;
    };
    var $justinmimbs$date$Date$quarter_a0 = $justinmimbs$date$Date$month, $justinmimbs$date$Date$quarter_a1 = $justinmimbs$date$Date$monthToQuarter, $justinmimbs$date$Date$quarter = A2($elm$core$Basics$composeR, $justinmimbs$date$Date$quarter_a0, $justinmimbs$date$Date$quarter_a1);
    var $justinmimbs$date$Date$weekdayNumber = function (_v0) {
        var rd = _v0;
        var _v1 = _Basics_modBy_fn(7, rd);
        if (!_v1) {
            return 7;
        }
        else {
            var n = _v1;
            return n;
        }
    };
    var $justinmimbs$date$Date$daysBeforeWeekYear = function (y) {
        var jan4 = $justinmimbs$date$Date$daysBeforeYear(y) + 4;
        return jan4 - $justinmimbs$date$Date$weekdayNumber(jan4);
    };
    var $justinmimbs$date$Date$numberToWeekday = function (wdn) {
        var _v0 = $elm$core$Basics$max_fn(1, wdn);
        switch (_v0) {
            case 1:
                return 0;
            case 2:
                return 1;
            case 3:
                return 2;
            case 4:
                return 3;
            case 5:
                return 4;
            case 6:
                return 5;
            default:
                return 6;
        }
    };
    var $justinmimbs$date$Date$toWeekDate = function (_v0) {
        var rd = _v0;
        var wdn = $justinmimbs$date$Date$weekdayNumber(rd);
        var wy = $justinmimbs$date$Date$year(rd + (4 - wdn));
        var week1Day1 = $justinmimbs$date$Date$daysBeforeWeekYear(wy) + 1;
        return {
            lR: 1 + (((rd - week1Day1) / 7) | 0),
            lS: wy,
            oC: $justinmimbs$date$Date$numberToWeekday(wdn)
        };
    };
    var $justinmimbs$date$Date$weekNumber_a0 = $justinmimbs$date$Date$toWeekDate, $justinmimbs$date$Date$weekNumber_a1 = function ($) {
        return $.lR;
    }, $justinmimbs$date$Date$weekNumber = A2($elm$core$Basics$composeR, $justinmimbs$date$Date$weekNumber_a0, $justinmimbs$date$Date$weekNumber_a1);
    var $justinmimbs$date$Date$weekYear_a0 = $justinmimbs$date$Date$toWeekDate, $justinmimbs$date$Date$weekYear_a1 = function ($) {
        return $.lS;
    }, $justinmimbs$date$Date$weekYear = A2($elm$core$Basics$composeR, $justinmimbs$date$Date$weekYear_a0, $justinmimbs$date$Date$weekYear_a1);
    var $justinmimbs$date$Date$weekday_a0 = $justinmimbs$date$Date$weekdayNumber, $justinmimbs$date$Date$weekday_a1 = $justinmimbs$date$Date$numberToWeekday, $justinmimbs$date$Date$weekday = A2($elm$core$Basics$composeR, $justinmimbs$date$Date$weekday_a0, $justinmimbs$date$Date$weekday_a1);
    var $elm$core$Basics$min_fn = function (x, y) {
        return (_Utils_cmp(x, y) < 0) ? x : y;
    }, $elm$core$Basics$min = F2($elm$core$Basics$min_fn);
    var $justinmimbs$date$Date$ordinalSuffix = function (n) {
        var nn = _Basics_modBy_fn(100, n);
        var _v0 = $elm$core$Basics$min_fn((nn < 20) ? nn : _Basics_modBy_fn(10, nn), 4);
        switch (_v0) {
            case 1:
                return "st";
            case 2:
                return "nd";
            case 3:
                return "rd";
            default:
                return "th";
        }
    };
    var $justinmimbs$date$Date$withOrdinalSuffix = function (n) {
        return _Utils_ap($elm$core$String$fromInt(n), $justinmimbs$date$Date$ordinalSuffix(n));
    };
    var $justinmimbs$date$Date$formatField_fn = function (language, _char, length, date) {
        switch (_char) {
            case "y":
                if (length === 2) {
                    return $elm$core$String$right_fn(2, $elm$core$String$padLeft_fn(2, "0", $elm$core$String$fromInt($justinmimbs$date$Date$year(date))));
                }
                else {
                    return $justinmimbs$date$Date$padSignedInt_fn(length, $justinmimbs$date$Date$year(date));
                }
            case "Y":
                if (length === 2) {
                    return $elm$core$String$right_fn(2, $elm$core$String$padLeft_fn(2, "0", $elm$core$String$fromInt($elm$core$Basics$composeR_fn($justinmimbs$date$Date$weekYear_a0, $justinmimbs$date$Date$weekYear_a1, date))));
                }
                else {
                    return $justinmimbs$date$Date$padSignedInt_fn(length, $elm$core$Basics$composeR_fn($justinmimbs$date$Date$weekYear_a0, $justinmimbs$date$Date$weekYear_a1, date));
                }
            case "Q":
                switch (length) {
                    case 1:
                        return $elm$core$String$fromInt($elm$core$Basics$composeR_fn($justinmimbs$date$Date$quarter_a0, $justinmimbs$date$Date$quarter_a1, date));
                    case 2:
                        return $elm$core$String$fromInt($elm$core$Basics$composeR_fn($justinmimbs$date$Date$quarter_a0, $justinmimbs$date$Date$quarter_a1, date));
                    case 3:
                        return "Q" + $elm$core$String$fromInt($elm$core$Basics$composeR_fn($justinmimbs$date$Date$quarter_a0, $justinmimbs$date$Date$quarter_a1, date));
                    case 4:
                        return $justinmimbs$date$Date$withOrdinalSuffix($elm$core$Basics$composeR_fn($justinmimbs$date$Date$quarter_a0, $justinmimbs$date$Date$quarter_a1, date));
                    case 5:
                        return $elm$core$String$fromInt($elm$core$Basics$composeR_fn($justinmimbs$date$Date$quarter_a0, $justinmimbs$date$Date$quarter_a1, date));
                    default:
                        return "";
                }
            case "M":
                switch (length) {
                    case 1:
                        return $elm$core$String$fromInt($elm$core$Basics$composeR_fn($justinmimbs$date$Date$monthNumber_a0, $justinmimbs$date$Date$monthNumber_a1, date));
                    case 2:
                        return $elm$core$String$padLeft_fn(2, "0", $elm$core$String$fromInt($elm$core$Basics$composeR_fn($justinmimbs$date$Date$monthNumber_a0, $justinmimbs$date$Date$monthNumber_a1, date)));
                    case 3:
                        return language.id($elm$core$Basics$composeR_fn($justinmimbs$date$Date$month_a0, $justinmimbs$date$Date$month_a1, date));
                    case 4:
                        return language.jf($elm$core$Basics$composeR_fn($justinmimbs$date$Date$month_a0, $justinmimbs$date$Date$month_a1, date));
                    case 5:
                        return $elm$core$String$left_fn(1, language.id($elm$core$Basics$composeR_fn($justinmimbs$date$Date$month_a0, $justinmimbs$date$Date$month_a1, date)));
                    default:
                        return "";
                }
            case "w":
                switch (length) {
                    case 1:
                        return $elm$core$String$fromInt($elm$core$Basics$composeR_fn($justinmimbs$date$Date$weekNumber_a0, $justinmimbs$date$Date$weekNumber_a1, date));
                    case 2:
                        return $elm$core$String$padLeft_fn(2, "0", $elm$core$String$fromInt($elm$core$Basics$composeR_fn($justinmimbs$date$Date$weekNumber_a0, $justinmimbs$date$Date$weekNumber_a1, date)));
                    default:
                        return "";
                }
            case "d":
                switch (length) {
                    case 1:
                        return $elm$core$String$fromInt($elm$core$Basics$composeR_fn($justinmimbs$date$Date$day_a0, $justinmimbs$date$Date$day_a1, date));
                    case 2:
                        return $elm$core$String$padLeft_fn(2, "0", $elm$core$String$fromInt($elm$core$Basics$composeR_fn($justinmimbs$date$Date$day_a0, $justinmimbs$date$Date$day_a1, date)));
                    case 3:
                        return language.iX($elm$core$Basics$composeR_fn($justinmimbs$date$Date$day_a0, $justinmimbs$date$Date$day_a1, date));
                    default:
                        return "";
                }
            case "D":
                switch (length) {
                    case 1:
                        return $elm$core$String$fromInt($elm$core$Basics$composeR_fn($justinmimbs$date$Date$ordinalDay_a0, $justinmimbs$date$Date$ordinalDay_a1, date));
                    case 2:
                        return $elm$core$String$padLeft_fn(2, "0", $elm$core$String$fromInt($elm$core$Basics$composeR_fn($justinmimbs$date$Date$ordinalDay_a0, $justinmimbs$date$Date$ordinalDay_a1, date)));
                    case 3:
                        return $elm$core$String$padLeft_fn(3, "0", $elm$core$String$fromInt($elm$core$Basics$composeR_fn($justinmimbs$date$Date$ordinalDay_a0, $justinmimbs$date$Date$ordinalDay_a1, date)));
                    default:
                        return "";
                }
            case "E":
                switch (length) {
                    case 1:
                        return language.e8($elm$core$Basics$composeR_fn($justinmimbs$date$Date$weekday_a0, $justinmimbs$date$Date$weekday_a1, date));
                    case 2:
                        return language.e8($elm$core$Basics$composeR_fn($justinmimbs$date$Date$weekday_a0, $justinmimbs$date$Date$weekday_a1, date));
                    case 3:
                        return language.e8($elm$core$Basics$composeR_fn($justinmimbs$date$Date$weekday_a0, $justinmimbs$date$Date$weekday_a1, date));
                    case 4:
                        return language.jL($elm$core$Basics$composeR_fn($justinmimbs$date$Date$weekday_a0, $justinmimbs$date$Date$weekday_a1, date));
                    case 5:
                        return $elm$core$String$left_fn(1, language.e8($elm$core$Basics$composeR_fn($justinmimbs$date$Date$weekday_a0, $justinmimbs$date$Date$weekday_a1, date)));
                    case 6:
                        return $elm$core$String$left_fn(2, language.e8($elm$core$Basics$composeR_fn($justinmimbs$date$Date$weekday_a0, $justinmimbs$date$Date$weekday_a1, date)));
                    default:
                        return "";
                }
            case "e":
                switch (length) {
                    case 1:
                        return $elm$core$String$fromInt($justinmimbs$date$Date$weekdayNumber(date));
                    case 2:
                        return $elm$core$String$fromInt($justinmimbs$date$Date$weekdayNumber(date));
                    default:
                        return $justinmimbs$date$Date$formatField_fn(language, "E", length, date);
                }
            default:
                return "";
        }
    }, $justinmimbs$date$Date$formatField = F4($justinmimbs$date$Date$formatField_fn);
    var $justinmimbs$date$Date$formatWithTokens_fn = function (language, tokens, date) {
        return $elm$core$List$foldl_fn_unwrapped(function (token, formatted) {
            if (!token.$) {
                var _char = token.a;
                var length = token.b;
                return _Utils_ap($justinmimbs$date$Date$formatField_fn(language, _char, length, date), formatted);
            }
            else {
                var str = token.a;
                return _Utils_ap(str, formatted);
            }
        }, "", tokens);
    }, $justinmimbs$date$Date$formatWithTokens = F3($justinmimbs$date$Date$formatWithTokens_fn);
    var $justinmimbs$date$Pattern$Literal = function (a) {
        return { $: 1, a: a };
    };
    var $elm$parser$Parser$Advanced$Bad_fn = function (a, b) {
        return { $: 1, a: a, b: b };
    }, $elm$parser$Parser$Advanced$Bad = F2($elm$parser$Parser$Advanced$Bad_fn);
    var $elm$parser$Parser$Advanced$Good_fn = function (a, b, c) {
        return { $: 0, a: a, b: b, c: c };
    }, $elm$parser$Parser$Advanced$Good = F3($elm$parser$Parser$Advanced$Good_fn);
    var $elm$parser$Parser$Advanced$Parser = $elm$core$Basics$identity;
    var $elm$parser$Parser$Advanced$andThen_fn = function (callback, _v0) {
        var parseA = _v0;
        return function (s0) {
            var _v1 = parseA(s0);
            if (_v1.$ === 1) {
                var p = _v1.a;
                var x = _v1.b;
                return $elm$parser$Parser$Advanced$Bad_fn(p, x);
            }
            else {
                var p1 = _v1.a;
                var a = _v1.b;
                var s1 = _v1.c;
                var _v2 = callback(a);
                var parseB = _v2;
                var _v3 = parseB(s1);
                if (_v3.$ === 1) {
                    var p2 = _v3.a;
                    var x = _v3.b;
                    return $elm$parser$Parser$Advanced$Bad_fn(p1 || p2, x);
                }
                else {
                    var p2 = _v3.a;
                    var b = _v3.b;
                    var s2 = _v3.c;
                    return $elm$parser$Parser$Advanced$Good_fn(p1 || p2, b, s2);
                }
            }
        };
    }, $elm$parser$Parser$Advanced$andThen = F2($elm$parser$Parser$Advanced$andThen_fn);
    var $elm$parser$Parser$andThen = $elm$parser$Parser$Advanced$andThen;
    var $elm$core$Basics$always_fn = function (a, _v0) {
        return a;
    }, $elm$core$Basics$always = F2($elm$core$Basics$always_fn);
    var $elm$parser$Parser$Advanced$map2_fn = function (func, _v0, _v1) {
        var parseA = _v0;
        var parseB = _v1;
        return function (s0) {
            var _v2 = parseA(s0);
            if (_v2.$ === 1) {
                var p = _v2.a;
                var x = _v2.b;
                return $elm$parser$Parser$Advanced$Bad_fn(p, x);
            }
            else {
                var p1 = _v2.a;
                var a = _v2.b;
                var s1 = _v2.c;
                var _v3 = parseB(s1);
                if (_v3.$ === 1) {
                    var p2 = _v3.a;
                    var x = _v3.b;
                    return $elm$parser$Parser$Advanced$Bad_fn(p1 || p2, x);
                }
                else {
                    var p2 = _v3.a;
                    var b = _v3.b;
                    var s2 = _v3.c;
                    return $elm$parser$Parser$Advanced$Good_fn(p1 || p2, A2(func, a, b), s2);
                }
            }
        };
    }, $elm$parser$Parser$Advanced$map2_fn_unwrapped = function (func, _v0, _v1) {
        var parseA = _v0;
        var parseB = _v1;
        return function (s0) {
            var _v2 = parseA(s0);
            if (_v2.$ === 1) {
                var p = _v2.a;
                var x = _v2.b;
                return $elm$parser$Parser$Advanced$Bad_fn(p, x);
            }
            else {
                var p1 = _v2.a;
                var a = _v2.b;
                var s1 = _v2.c;
                var _v3 = parseB(s1);
                if (_v3.$ === 1) {
                    var p2 = _v3.a;
                    var x = _v3.b;
                    return $elm$parser$Parser$Advanced$Bad_fn(p1 || p2, x);
                }
                else {
                    var p2 = _v3.a;
                    var b = _v3.b;
                    var s2 = _v3.c;
                    return $elm$parser$Parser$Advanced$Good_fn(p1 || p2, func(a, b), s2);
                }
            }
        };
    }, $elm$parser$Parser$Advanced$map2 = F3($elm$parser$Parser$Advanced$map2_fn);
    var $elm$parser$Parser$Advanced$ignorer_fn = function (keepParser, ignoreParser) {
        return $elm$parser$Parser$Advanced$map2_fn($elm$core$Basics$always, keepParser, ignoreParser);
    }, $elm$parser$Parser$Advanced$ignorer = F2($elm$parser$Parser$Advanced$ignorer_fn);
    var $elm$parser$Parser$ignorer = $elm$parser$Parser$Advanced$ignorer;
    var $elm$parser$Parser$Advanced$succeed = function (a) {
        return function (s) {
            return $elm$parser$Parser$Advanced$Good_fn(false, a, s);
        };
    };
    var $elm$parser$Parser$succeed = $elm$parser$Parser$Advanced$succeed;
    var $elm$parser$Parser$Expecting = function (a) {
        return { $: 0, a: a };
    };
    var $elm$parser$Parser$Advanced$Token_fn = function (a, b) {
        return { $: 0, a: a, b: b };
    }, $elm$parser$Parser$Advanced$Token = F2($elm$parser$Parser$Advanced$Token_fn);
    var $elm$parser$Parser$toToken = function (str) {
        return $elm$parser$Parser$Advanced$Token_fn(str, $elm$parser$Parser$Expecting(str));
    };
    var $elm$parser$Parser$Advanced$AddRight_fn = function (a, b) {
        return { $: 1, a: a, b: b };
    }, $elm$parser$Parser$Advanced$AddRight = F2($elm$parser$Parser$Advanced$AddRight_fn);
    var $elm$parser$Parser$Advanced$DeadEnd_fn = function (row, col, problem, contextStack) {
        return { mf: col, hO: contextStack, nS: problem, n6: row };
    }, $elm$parser$Parser$Advanced$DeadEnd = F4($elm$parser$Parser$Advanced$DeadEnd_fn);
    var $elm$parser$Parser$Advanced$Empty = { $: 0 };
    var $elm$parser$Parser$Advanced$fromState_fn = function (s, x) {
        return $elm$parser$Parser$Advanced$AddRight_fn($elm$parser$Parser$Advanced$Empty, $elm$parser$Parser$Advanced$DeadEnd_fn(s.n6, s.mf, x, s.h));
    }, $elm$parser$Parser$Advanced$fromState = F2($elm$parser$Parser$Advanced$fromState_fn);
    var $elm$core$String$isEmpty = function (string) {
        return string === "";
    };
    var $elm$parser$Parser$Advanced$isSubString = _Parser_isSubString;
    var $elm$core$Basics$not = _Basics_not;
    var $elm$parser$Parser$Advanced$token = function (_v0) {
        var str = _v0.a;
        var expecting = _v0.b;
        var progress = !$elm$core$String$isEmpty(str);
        return function (s) {
            var _v1 = _Parser_isSubString_fn(str, s.gO, s.n6, s.mf, s.ok);
            var newOffset = _v1.a;
            var newRow = _v1.b;
            var newCol = _v1.c;
            return newOffset === -1 ? $elm$parser$Parser$Advanced$Bad_fn(false, $elm$parser$Parser$Advanced$fromState_fn(s, expecting)) : $elm$parser$Parser$Advanced$Good_fn(progress, 0, { mf: newCol, h: s.h, fu: s.fu, gO: newOffset, n6: newRow, ok: s.ok });
        };
    };
    var $elm$parser$Parser$token = function (str) {
        return $elm$parser$Parser$Advanced$token($elm$parser$Parser$toToken(str));
    };
    var $justinmimbs$date$Pattern$escapedQuote = $elm$parser$Parser$Advanced$ignorer_fn($elm$parser$Parser$succeed($justinmimbs$date$Pattern$Literal("'")), $elm$parser$Parser$token("''"));
    var $elm$parser$Parser$UnexpectedChar = { $: 11 };
    var $elm$parser$Parser$Advanced$isSubChar = _Parser_isSubChar;
    var $elm$parser$Parser$Advanced$chompIf_fn = function (isGood, expecting) {
        return function (s) {
            var newOffset = _Parser_isSubChar_fn(isGood, s.gO, s.ok);
            return newOffset === -1 ? $elm$parser$Parser$Advanced$Bad_fn(false, $elm$parser$Parser$Advanced$fromState_fn(s, expecting)) : (newOffset === -2 ? $elm$parser$Parser$Advanced$Good_fn(true, 0, { mf: 1, h: s.h, fu: s.fu, gO: s.gO + 1, n6: s.n6 + 1, ok: s.ok }) : $elm$parser$Parser$Advanced$Good_fn(true, 0, { mf: s.mf + 1, h: s.h, fu: s.fu, gO: newOffset, n6: s.n6, ok: s.ok }));
        };
    }, $elm$parser$Parser$Advanced$chompIf = F2($elm$parser$Parser$Advanced$chompIf_fn);
    var $elm$parser$Parser$chompIf = function (isGood) {
        return $elm$parser$Parser$Advanced$chompIf_fn(isGood, $elm$parser$Parser$UnexpectedChar);
    };
    var $justinmimbs$date$Pattern$Field_fn = function (a, b) {
        return { $: 0, a: a, b: b };
    }, $justinmimbs$date$Pattern$Field = F2($justinmimbs$date$Pattern$Field_fn);
    var $elm$parser$Parser$Advanced$chompWhileHelp_fn = function (isGood, offset, row, col, s0) {
        chompWhileHelp: while (true) {
            var newOffset = _Parser_isSubChar_fn(isGood, offset, s0.ok);
            if (newOffset === -1) {
                return $elm$parser$Parser$Advanced$Good_fn(_Utils_cmp(s0.gO, offset) < 0, 0, { mf: col, h: s0.h, fu: s0.fu, gO: offset, n6: row, ok: s0.ok });
            }
            else {
                if (newOffset === -2) {
                    var $temp$isGood = isGood, $temp$offset = offset + 1, $temp$row = row + 1, $temp$col = 1, $temp$s0 = s0;
                    isGood = $temp$isGood;
                    offset = $temp$offset;
                    row = $temp$row;
                    col = $temp$col;
                    s0 = $temp$s0;
                    continue chompWhileHelp;
                }
                else {
                    var $temp$isGood = isGood, $temp$offset = newOffset, $temp$row = row, $temp$col = col + 1, $temp$s0 = s0;
                    isGood = $temp$isGood;
                    offset = $temp$offset;
                    row = $temp$row;
                    col = $temp$col;
                    s0 = $temp$s0;
                    continue chompWhileHelp;
                }
            }
        }
    }, $elm$parser$Parser$Advanced$chompWhileHelp = F5($elm$parser$Parser$Advanced$chompWhileHelp_fn);
    var $elm$parser$Parser$Advanced$chompWhile = function (isGood) {
        return function (s) {
            return $elm$parser$Parser$Advanced$chompWhileHelp_fn(isGood, s.gO, s.n6, s.mf, s);
        };
    };
    var $elm$parser$Parser$chompWhile = $elm$parser$Parser$Advanced$chompWhile;
    var $elm$parser$Parser$Advanced$getOffset = function (s) {
        return $elm$parser$Parser$Advanced$Good_fn(false, s.gO, s);
    };
    var $elm$parser$Parser$getOffset = $elm$parser$Parser$Advanced$getOffset;
    var $elm$parser$Parser$Advanced$keeper_fn = function (parseFunc, parseArg) {
        return $elm$parser$Parser$Advanced$map2_fn($elm$core$Basics$apL, parseFunc, parseArg);
    }, $elm$parser$Parser$Advanced$keeper = F2($elm$parser$Parser$Advanced$keeper_fn);
    var $elm$parser$Parser$keeper = $elm$parser$Parser$Advanced$keeper;
    var $elm$parser$Parser$Problem = function (a) {
        return { $: 12, a: a };
    };
    var $elm$parser$Parser$Advanced$problem = function (x) {
        return function (s) {
            return $elm$parser$Parser$Advanced$Bad_fn(false, $elm$parser$Parser$Advanced$fromState_fn(s, x));
        };
    };
    var $elm$parser$Parser$problem = function (msg) {
        return $elm$parser$Parser$Advanced$problem($elm$parser$Parser$Problem(msg));
    };
    var $elm$core$String$foldr = _String_foldr;
    var $elm$core$String$toList = function (string) {
        return _String_foldr_fn($elm$core$List$cons, _List_Nil, string);
    };
    var $justinmimbs$date$Pattern$fieldRepeats = function (str) {
        var _v0 = $elm$core$String$toList(str);
        if (_v0.b && (!_v0.b.b)) {
            var _char = _v0.a;
            return $elm$parser$Parser$Advanced$keeper_fn($elm$parser$Parser$Advanced$keeper_fn($elm$parser$Parser$succeed(F2(function (x, y) {
                return $justinmimbs$date$Pattern$Field_fn(_char, 1 + (y - x));
            })), $elm$parser$Parser$Advanced$ignorer_fn($elm$parser$Parser$getOffset, $elm$parser$Parser$chompWhile($elm$core$Basics$eq(_char)))), $elm$parser$Parser$getOffset);
        }
        else {
            return $elm$parser$Parser$problem("expected exactly one char");
        }
    };
    var $elm$parser$Parser$Advanced$mapChompedString_fn = function (func, _v0) {
        var parse = _v0;
        return function (s0) {
            var _v1 = parse(s0);
            if (_v1.$ === 1) {
                var p = _v1.a;
                var x = _v1.b;
                return $elm$parser$Parser$Advanced$Bad_fn(p, x);
            }
            else {
                var p = _v1.a;
                var a = _v1.b;
                var s1 = _v1.c;
                return $elm$parser$Parser$Advanced$Good_fn(p, A2(func, _String_slice_fn(s0.gO, s1.gO, s0.ok), a), s1);
            }
        };
    }, $elm$parser$Parser$Advanced$mapChompedString_fn_unwrapped = function (func, _v0) {
        var parse = _v0;
        return function (s0) {
            var _v1 = parse(s0);
            if (_v1.$ === 1) {
                var p = _v1.a;
                var x = _v1.b;
                return $elm$parser$Parser$Advanced$Bad_fn(p, x);
            }
            else {
                var p = _v1.a;
                var a = _v1.b;
                var s1 = _v1.c;
                return $elm$parser$Parser$Advanced$Good_fn(p, func(_String_slice_fn(s0.gO, s1.gO, s0.ok), a), s1);
            }
        };
    }, $elm$parser$Parser$Advanced$mapChompedString = F2($elm$parser$Parser$Advanced$mapChompedString_fn);
    var $elm$parser$Parser$Advanced$getChompedString = function (parser) {
        return $elm$parser$Parser$Advanced$mapChompedString_fn($elm$core$Basics$always, parser);
    };
    var $elm$parser$Parser$getChompedString = $elm$parser$Parser$Advanced$getChompedString;
    var $justinmimbs$date$Pattern$field = $elm$parser$Parser$Advanced$andThen_fn($justinmimbs$date$Pattern$fieldRepeats, $elm$parser$Parser$getChompedString($elm$parser$Parser$chompIf($elm$core$Char$isAlpha)));
    var $justinmimbs$date$Pattern$finalize_a0 = F2(function (token, tokens) {
        var _v0 = _Utils_Tuple2(token, tokens);
        if (((_v0.a.$ === 1) && _v0.b.b) && (_v0.b.a.$ === 1)) {
            var x = _v0.a.a;
            var _v1 = _v0.b;
            var y = _v1.a.a;
            var rest = _v1.b;
            return _List_Cons($justinmimbs$date$Pattern$Literal(_Utils_ap(x, y)), rest);
        }
        else {
            return _List_Cons(token, tokens);
        }
    }), $justinmimbs$date$Pattern$finalize_a1 = _List_Nil, $justinmimbs$date$Pattern$finalize = A2($elm$core$List$foldl, $justinmimbs$date$Pattern$finalize_a0, $justinmimbs$date$Pattern$finalize_a1);
    var $elm$parser$Parser$Advanced$lazy = function (thunk) {
        return function (s) {
            var _v0 = thunk(0);
            var parse = _v0;
            return parse(s);
        };
    };
    var $elm$parser$Parser$lazy = $elm$parser$Parser$Advanced$lazy;
    var $justinmimbs$date$Pattern$isLiteralChar = function (_char) {
        return (_char !== "'") && (!$elm$core$Char$isAlpha(_char));
    };
    var $elm$parser$Parser$Advanced$map_fn = function (func, _v0) {
        var parse = _v0;
        return function (s0) {
            var _v1 = parse(s0);
            if (!_v1.$) {
                var p = _v1.a;
                var a = _v1.b;
                var s1 = _v1.c;
                return $elm$parser$Parser$Advanced$Good_fn(p, func(a), s1);
            }
            else {
                var p = _v1.a;
                var x = _v1.b;
                return $elm$parser$Parser$Advanced$Bad_fn(p, x);
            }
        };
    }, $elm$parser$Parser$Advanced$map = F2($elm$parser$Parser$Advanced$map_fn);
    var $elm$parser$Parser$map = $elm$parser$Parser$Advanced$map;
    var $justinmimbs$date$Pattern$literal = $elm$parser$Parser$Advanced$map_fn($justinmimbs$date$Pattern$Literal, $elm$parser$Parser$getChompedString($elm$parser$Parser$Advanced$ignorer_fn($elm$parser$Parser$Advanced$ignorer_fn($elm$parser$Parser$succeed(0), $elm$parser$Parser$chompIf($justinmimbs$date$Pattern$isLiteralChar)), $elm$parser$Parser$chompWhile($justinmimbs$date$Pattern$isLiteralChar))));
    var $elm$parser$Parser$Advanced$Append_fn = function (a, b) {
        return { $: 2, a: a, b: b };
    }, $elm$parser$Parser$Advanced$Append = F2($elm$parser$Parser$Advanced$Append_fn);
    var $elm$parser$Parser$Advanced$oneOfHelp_fn = function (s0, bag, parsers) {
        oneOfHelp: while (true) {
            if (!parsers.b) {
                return $elm$parser$Parser$Advanced$Bad_fn(false, bag);
            }
            else {
                var parse = parsers.a;
                var remainingParsers = parsers.b;
                var _v1 = parse(s0);
                if (!_v1.$) {
                    var step = _v1;
                    return step;
                }
                else {
                    var step = _v1;
                    var p = step.a;
                    var x = step.b;
                    if (p) {
                        return step;
                    }
                    else {
                        var $temp$s0 = s0, $temp$bag = $elm$parser$Parser$Advanced$Append_fn(bag, x), $temp$parsers = remainingParsers;
                        s0 = $temp$s0;
                        bag = $temp$bag;
                        parsers = $temp$parsers;
                        continue oneOfHelp;
                    }
                }
            }
        }
    }, $elm$parser$Parser$Advanced$oneOfHelp = F3($elm$parser$Parser$Advanced$oneOfHelp_fn);
    var $elm$parser$Parser$Advanced$oneOf = function (parsers) {
        return function (s) {
            return $elm$parser$Parser$Advanced$oneOfHelp_fn(s, $elm$parser$Parser$Advanced$Empty, parsers);
        };
    };
    var $elm$parser$Parser$oneOf = $elm$parser$Parser$Advanced$oneOf;
    var $elm$parser$Parser$ExpectingEnd = { $: 10 };
    var $elm$parser$Parser$Advanced$end = function (x) {
        return function (s) {
            return _Utils_eq($elm$core$String$length(s.ok), s.gO) ? $elm$parser$Parser$Advanced$Good_fn(false, 0, s) : $elm$parser$Parser$Advanced$Bad_fn(false, $elm$parser$Parser$Advanced$fromState_fn(s, x));
        };
    };
    var $elm$parser$Parser$end = $elm$parser$Parser$Advanced$end($elm$parser$Parser$ExpectingEnd);
    var $justinmimbs$date$Pattern$quotedHelp = function (result) {
        return $elm$parser$Parser$oneOf(_List_fromArray([
            $elm$parser$Parser$Advanced$andThen_fn(function (str) {
                return $justinmimbs$date$Pattern$quotedHelp(_Utils_ap(result, str));
            }, $elm$parser$Parser$getChompedString($elm$parser$Parser$Advanced$ignorer_fn($elm$parser$Parser$Advanced$ignorer_fn($elm$parser$Parser$succeed(0), $elm$parser$Parser$chompIf($elm$core$Basics$neq("'"))), $elm$parser$Parser$chompWhile($elm$core$Basics$neq("'"))))),
            $elm$parser$Parser$Advanced$andThen_fn(function (_v0) {
                return $justinmimbs$date$Pattern$quotedHelp(result + "'");
            }, $elm$parser$Parser$token("''")),
            $elm$parser$Parser$succeed(result)
        ]));
    };
    var $justinmimbs$date$Pattern$quoted = $elm$parser$Parser$Advanced$keeper_fn($elm$parser$Parser$Advanced$ignorer_fn($elm$parser$Parser$succeed($justinmimbs$date$Pattern$Literal), $elm$parser$Parser$chompIf($elm$core$Basics$eq("'"))), $elm$parser$Parser$Advanced$ignorer_fn($justinmimbs$date$Pattern$quotedHelp(""), $elm$parser$Parser$oneOf(_List_fromArray([
        $elm$parser$Parser$chompIf($elm$core$Basics$eq("'")),
        $elm$parser$Parser$end
    ]))));
    var $justinmimbs$date$Pattern$patternHelp = function (tokens) {
        return $elm$parser$Parser$oneOf(_List_fromArray([
            $elm$parser$Parser$Advanced$andThen_fn(function (token) {
                return $justinmimbs$date$Pattern$patternHelp(_List_Cons(token, tokens));
            }, $elm$parser$Parser$oneOf(_List_fromArray([$justinmimbs$date$Pattern$field, $justinmimbs$date$Pattern$literal, $justinmimbs$date$Pattern$escapedQuote, $justinmimbs$date$Pattern$quoted]))),
            $elm$parser$Parser$lazy(function (_v0) {
                return $elm$parser$Parser$succeed($elm$core$List$foldl_fn($justinmimbs$date$Pattern$finalize_a0, $justinmimbs$date$Pattern$finalize_a1, tokens));
            })
        ]));
    };
    var $elm$parser$Parser$DeadEnd_fn = function (row, col, problem) {
        return { mf: col, nS: problem, n6: row };
    }, $elm$parser$Parser$DeadEnd = F3($elm$parser$Parser$DeadEnd_fn);
    var $elm$parser$Parser$problemToDeadEnd = function (p) {
        return $elm$parser$Parser$DeadEnd_fn(p.n6, p.mf, p.nS);
    };
    var $elm$parser$Parser$Advanced$bagToList_fn = function (bag, list) {
        bagToList: while (true) {
            switch (bag.$) {
                case 0:
                    return list;
                case 1:
                    var bag1 = bag.a;
                    var x = bag.b;
                    var $temp$bag = bag1, $temp$list = _List_Cons(x, list);
                    bag = $temp$bag;
                    list = $temp$list;
                    continue bagToList;
                default:
                    var bag1 = bag.a;
                    var bag2 = bag.b;
                    var $temp$bag = bag1, $temp$list = $elm$parser$Parser$Advanced$bagToList_fn(bag2, list);
                    bag = $temp$bag;
                    list = $temp$list;
                    continue bagToList;
            }
        }
    }, $elm$parser$Parser$Advanced$bagToList = F2($elm$parser$Parser$Advanced$bagToList_fn);
    var $elm$parser$Parser$Advanced$run_fn = function (_v0, src) {
        var parse = _v0;
        var _v1 = parse({ mf: 1, h: _List_Nil, fu: 1, gO: 0, n6: 1, ok: src });
        if (!_v1.$) {
            var value = _v1.b;
            return $elm$core$Result$Ok(value);
        }
        else {
            var bag = _v1.b;
            return $elm$core$Result$Err($elm$parser$Parser$Advanced$bagToList_fn(bag, _List_Nil));
        }
    }, $elm$parser$Parser$Advanced$run = F2($elm$parser$Parser$Advanced$run_fn);
    var $elm$parser$Parser$run_fn = function (parser, source) {
        var _v0 = $elm$parser$Parser$Advanced$run_fn(parser, source);
        if (!_v0.$) {
            var a = _v0.a;
            return $elm$core$Result$Ok(a);
        }
        else {
            var problems = _v0.a;
            return $elm$core$Result$Err($elm$core$List$map_fn($elm$parser$Parser$problemToDeadEnd, problems));
        }
    }, $elm$parser$Parser$run = F2($elm$parser$Parser$run_fn);
    var $elm$core$Result$withDefault_fn = function (def, result) {
        if (!result.$) {
            var a = result.a;
            return a;
        }
        else {
            return def;
        }
    }, $elm$core$Result$withDefault = F2($elm$core$Result$withDefault_fn);
    var $justinmimbs$date$Pattern$fromString = function (str) {
        return $elm$core$Result$withDefault_fn(_List_fromArray([
            $justinmimbs$date$Pattern$Literal(str)
        ]), $elm$parser$Parser$run_fn($justinmimbs$date$Pattern$patternHelp(_List_Nil), str));
    };
    var $justinmimbs$date$Date$formatWithLanguage_fn = function (language, pattern) {
        var tokens = $elm$core$List$reverse($justinmimbs$date$Pattern$fromString(pattern));
        return A2($justinmimbs$date$Date$formatWithTokens, language, tokens);
    }, $justinmimbs$date$Date$formatWithLanguage = F2($justinmimbs$date$Date$formatWithLanguage_fn);
    var $justinmimbs$date$Date$monthToName = function (m) {
        switch (m) {
            case 0:
                return "January";
            case 1:
                return "February";
            case 2:
                return "March";
            case 3:
                return "April";
            case 4:
                return "May";
            case 5:
                return "June";
            case 6:
                return "July";
            case 7:
                return "August";
            case 8:
                return "September";
            case 9:
                return "October";
            case 10:
                return "November";
            default:
                return "December";
        }
    };
    var $justinmimbs$date$Date$weekdayToName = function (wd) {
        switch (wd) {
            case 0:
                return "Monday";
            case 1:
                return "Tuesday";
            case 2:
                return "Wednesday";
            case 3:
                return "Thursday";
            case 4:
                return "Friday";
            case 5:
                return "Saturday";
            default:
                return "Sunday";
        }
    };
    var $justinmimbs$date$Date$language_en = {
        iX: $justinmimbs$date$Date$withOrdinalSuffix,
        jf: $justinmimbs$date$Date$monthToName,
        id: A2($elm$core$Basics$composeR, $justinmimbs$date$Date$monthToName, $elm$core$String$left(3)),
        jL: $justinmimbs$date$Date$weekdayToName,
        e8: A2($elm$core$Basics$composeR, $justinmimbs$date$Date$weekdayToName, $elm$core$String$left(3))
    };
    var $justinmimbs$date$Date$format = function (pattern) {
        return $justinmimbs$date$Date$formatWithLanguage_fn($justinmimbs$date$Date$language_en, pattern);
    };
    var $dillonkearns$elm_rss$Rss$formatDate = function (date) {
        return A2($justinmimbs$date$Date$format, "EEE, dd MMM yyyy", date) + " 00:00:00 GMT";
    };
    var $dillonkearns$elm_rss$Rss$formatDateOrTime = function (dateOrTime) {
        if (!dateOrTime.$) {
            var date = dateOrTime.a;
            return $dillonkearns$elm_rss$Rss$formatDate(date);
        }
        else {
            var posix = dateOrTime.a;
            return $dmy$elm_imf_date_time$Imf$DateTime$fromPosix_fn($elm$time$Time$utc, posix);
        }
    };
    var $elm$core$String$dropLeft_fn = function (n, string) {
        return (n < 1) ? string : _String_slice_fn(n, $elm$core$String$length(string), string);
    }, $elm$core$String$dropLeft = F2($elm$core$String$dropLeft_fn);
    var $elm$core$String$startsWith = _String_startsWith;
    var $dillonkearns$elm_rss$Path$dropLeading = function (url) {
        return _String_startsWith_fn("/", url) ? $elm$core$String$dropLeft_fn(1, url) : url;
    };
    var $elm$core$String$dropRight_fn = function (n, string) {
        return (n < 1) ? string : _String_slice_fn(0, -n, string);
    }, $elm$core$String$dropRight = F2($elm$core$String$dropRight_fn);
    var $elm$core$String$endsWith = _String_endsWith;
    var $dillonkearns$elm_rss$Path$dropTrailing = function (url) {
        return _String_endsWith_fn("/", url) ? $elm$core$String$dropRight_fn(1, url) : url;
    };
    var $dillonkearns$elm_rss$Path$dropBoth = function (url) {
        return $dillonkearns$elm_rss$Path$dropTrailing($dillonkearns$elm_rss$Path$dropLeading(url));
    };
    var $dillonkearns$elm_rss$Path$join = function (urls) {
        return $elm$core$String$join_fn("/", $elm$core$List$map_fn($dillonkearns$elm_rss$Path$dropBoth, urls));
    };
    var $dillonkearns$elm_rss$Rss$keyValue_fn = function (key, value) {
        return $billstclair$elm_xml_eeue56$Xml$Encode$object(_List_fromArray([
            _Utils_Tuple3(key, $elm$core$Dict$empty, $billstclair$elm_xml_eeue56$Xml$Encode$string(value))
        ]));
    }, $dillonkearns$elm_rss$Rss$keyValue = F2($dillonkearns$elm_rss$Rss$keyValue_fn);
    var $billstclair$elm_xml_eeue56$Xml$Encode$list = function (values) {
        return $billstclair$elm_xml_eeue56$Xml$Object(values);
    };
    var $dillonkearns$elm_rss$Rss$wrapInCdata = function (content) {
        return "<![CDATA[" + (content + "]]>");
    };
    var $dillonkearns$elm_rss$Rss$itemXml_fn = function (siteUrl, item) {
        return $billstclair$elm_xml_eeue56$Xml$Encode$object(_List_fromArray([
            _Utils_Tuple3("item", $elm$core$Dict$empty, $billstclair$elm_xml_eeue56$Xml$Encode$list(_Utils_ap(_List_fromArray([
                $dillonkearns$elm_rss$Rss$keyValue_fn("title", item.jE),
                $dillonkearns$elm_rss$Rss$keyValue_fn("description", item.jX),
                $dillonkearns$elm_rss$Rss$keyValue_fn("link", $dillonkearns$elm_rss$Path$join(_List_fromArray([siteUrl, item.lO]))),
                $dillonkearns$elm_rss$Rss$keyValue_fn("guid", $dillonkearns$elm_rss$Path$join(_List_fromArray([siteUrl, item.lO]))),
                $dillonkearns$elm_rss$Rss$keyValue_fn("pubDate", $dillonkearns$elm_rss$Rss$formatDateOrTime(item.nU))
            ]), _Utils_ap($elm$core$List$map_fn($dillonkearns$elm_rss$Rss$encodeCategory, item.mc), $elm$core$List$filterMap_fn($elm$core$Basics$identity, _List_fromArray([
                $elm$core$Maybe$map_fn(function (content) {
                    return $dillonkearns$elm_rss$Rss$keyValue_fn("content", content);
                }, item.mh),
                $elm$core$Maybe$map_fn(function (content) {
                    return $dillonkearns$elm_rss$Rss$keyValue_fn("content:encoded", $dillonkearns$elm_rss$Rss$wrapInCdata(content));
                }, item.mi),
                $elm$core$Maybe$map_fn($dillonkearns$elm_rss$Rss$encodeEnclosure, item.mu)
            ]))))))
        ]));
    }, $dillonkearns$elm_rss$Rss$itemXml = F2($dillonkearns$elm_rss$Rss$itemXml_fn);
    var $dillonkearns$elm_rss$Rss$generate = function (feed) {
        return $billstclair$elm_xml_eeue56$Xml$Encode$encode_fn(0, $billstclair$elm_xml_eeue56$Xml$Encode$object(_List_fromArray([
            _Utils_Tuple3("rss", $elm$core$Dict$fromList(_List_fromArray([
                _Utils_Tuple2("xmlns:dc", $billstclair$elm_xml_eeue56$Xml$Encode$string("http://purl.org/dc/elements/1.1/")),
                _Utils_Tuple2("xmlns:content", $billstclair$elm_xml_eeue56$Xml$Encode$string("http://purl.org/rss/1.0/modules/content/")),
                _Utils_Tuple2("xmlns:atom", $billstclair$elm_xml_eeue56$Xml$Encode$string("http://www.w3.org/2005/Atom")),
                _Utils_Tuple2("version", $billstclair$elm_xml_eeue56$Xml$Encode$string("2.0"))
            ])), $billstclair$elm_xml_eeue56$Xml$Encode$object(_List_fromArray([
                _Utils_Tuple3("channel", $elm$core$Dict$empty, $billstclair$elm_xml_eeue56$Xml$Encode$list($elm$core$List$concat(_List_fromArray([
                    _List_fromArray([
                        $dillonkearns$elm_rss$Rss$keyValue_fn("title", feed.jE),
                        $dillonkearns$elm_rss$Rss$keyValue_fn("description", feed.jX),
                        $dillonkearns$elm_rss$Rss$keyValue_fn("link", feed.lO),
                        $dillonkearns$elm_rss$Rss$keyValue_fn("lastBuildDate", $dmy$elm_imf_date_time$Imf$DateTime$fromPosix_fn($elm$time$Time$utc, feed.m7))
                    ]),
                    $elm$core$List$filterMap_fn($elm$core$Basics$identity, _List_fromArray([
                        $elm$core$Maybe$map_fn($dillonkearns$elm_rss$Rss$keyValue("generator"), feed.mN)
                    ])),
                    $elm$core$List$map_fn($dillonkearns$elm_rss$Rss$itemXml(feed.iv), feed.m2)
                ]))))
            ])))
        ])));
    };
    var $dillonkearns$elm_pages_v3_beta$Internal$ApiRoute$ApiRoute = $elm$core$Basics$identity;
    var $elm$json$Json$Encode$string = _Json_wrap;
    var $dillonkearns$elm_pages_v3_beta$ApiRoute$encodeStaticFileBody = function (fileBody) {
        return $elm$json$Json$Encode$object(_List_fromArray([
            _Utils_Tuple2("body", $elm$json$Json$Encode$string(fileBody)),
            _Utils_Tuple2("kind", $elm$json$Json$Encode$string("static-file"))
        ]));
    };
    var $elm$regex$Regex$Match_fn = function (match, index, number, submatches) {
        return { e: index, li: match, ig: number, kn: submatches };
    }, $elm$regex$Regex$Match = F4($elm$regex$Regex$Match_fn);
    var $elm$regex$Regex$fromStringWith = _Regex_fromStringWith;
    var $elm$regex$Regex$fromString = function (string) {
        return _Regex_fromStringWith_fn({ mb: false, np: false }, string);
    };
    var $elm$core$List$any_fn = function (isOkay, list) {
        any: while (true) {
            if (!list.b) {
                return false;
            }
            else {
                var x = list.a;
                var xs = list.b;
                if (isOkay(x)) {
                    return true;
                }
                else {
                    var $temp$isOkay = isOkay, $temp$list = xs;
                    isOkay = $temp$isOkay;
                    list = $temp$list;
                    continue any;
                }
            }
        }
    }, $elm$core$List$any = F2($elm$core$List$any_fn);
    var $elm$core$List$member_fn = function (x, xs) {
        return $elm$core$List$any_fn(function (a) {
            return _Utils_eq(a, x);
        }, xs);
    }, $elm$core$List$member = F2($elm$core$List$member_fn);
    var $elm$regex$Regex$never = _Regex_never;
    var $elm$core$List$concatMap_fn = function (f, lists) {
        if (!lists.b) {
            return _List_Nil;
        }
        var tmp = _List_Cons(undefined, _List_Nil);
        var end = tmp;
        for (; lists.b.
            b; lists = lists.b) {
            var xs = f(lists.a);
            for (; xs.b; xs = xs.b) {
                var next = _List_Cons(xs.a, _List_Nil);
                end.b = next;
                end = next;
            }
        }
        end.b = f(lists.a);
        return tmp.b;
    }, $elm$core$List$concatMap = F2($elm$core$List$concatMap_fn);
    var $elm$regex$Regex$find_a0 = _Regex_infinity, $elm$regex$Regex$find = _Regex_findAtMost($elm$regex$Regex$find_a0);
    var $dillonkearns$elm_pages_v3_beta$Internal$ApiRoute$pathToMatches_fn = function (path, _v0) {
        var pattern = _v0.b;
        return $elm$core$List$reverse($elm$core$List$filterMap_fn($elm$core$Basics$identity, $elm$core$List$concatMap_fn(function ($) {
            return $.kn;
        }, _Regex_findAtMost_fn($elm$regex$Regex$find_a0, $elm$core$Maybe$withDefault_fn($elm$regex$Regex$never, $elm$regex$Regex$fromString(pattern)), path))));
    }, $dillonkearns$elm_pages_v3_beta$Internal$ApiRoute$pathToMatches = F2($dillonkearns$elm_pages_v3_beta$Internal$ApiRoute$pathToMatches_fn);
    var $dillonkearns$elm_pages_v3_beta$Internal$ApiRoute$tryMatch_fn = function (path, _v0) {
        var pattern = _v0.b;
        var handler = _v0.c;
        var matches = $elm$core$List$reverse($elm$core$List$filterMap_fn($elm$core$Basics$identity, $elm$core$List$concatMap_fn(function ($) {
            return $.kn;
        }, _Regex_findAtMost_fn($elm$regex$Regex$find_a0, $elm$core$Maybe$withDefault_fn($elm$regex$Regex$never, $elm$regex$Regex$fromString(pattern)), path))));
        return $elm$core$Maybe$Just(handler(matches));
    }, $dillonkearns$elm_pages_v3_beta$Internal$ApiRoute$tryMatch = F2($dillonkearns$elm_pages_v3_beta$Internal$ApiRoute$tryMatch_fn);
    var $dillonkearns$elm_pages_v3_beta$ApiRoute$preRender_fn = function (buildUrls, fullHandler) {
        var patterns = fullHandler.a;
        var pattern = fullHandler.b;
        var toString = fullHandler.d;
        var constructor = fullHandler.e;
        var preBuiltMatches = buildUrls(constructor(_List_Nil));
        var buildTimeRoutes__ = $dillonkearns$elm_pages_v3_beta$BackendTask$map_fn($elm$core$List$map(toString), buildUrls(constructor(_List_Nil)));
        return {
            iP: buildTimeRoutes__,
            mP: $elm$core$Maybe$Nothing,
            et: function (path) {
                var matches = $dillonkearns$elm_pages_v3_beta$Internal$ApiRoute$pathToMatches_fn(path, fullHandler);
                return $dillonkearns$elm_pages_v3_beta$BackendTask$map_fn($elm$core$List$member(matches), preBuiltMatches);
            },
            a8: "prerender",
            j7: F2(function (_v0, path) {
                var matches = $dillonkearns$elm_pages_v3_beta$Internal$ApiRoute$pathToMatches_fn(path, fullHandler);
                var routeFound = $dillonkearns$elm_pages_v3_beta$BackendTask$map_fn($elm$core$List$member(matches), preBuiltMatches);
                return $dillonkearns$elm_pages_v3_beta$BackendTask$andThen_fn(function (found) {
                    return found ? $elm$core$Maybe$withDefault_fn($dillonkearns$elm_pages_v3_beta$BackendTask$succeed($elm$core$Maybe$Nothing), $elm$core$Maybe$map_fn($dillonkearns$elm_pages_v3_beta$BackendTask$map(A2($elm$core$Basics$composeR, $dillonkearns$elm_pages_v3_beta$ApiRoute$encodeStaticFileBody, $elm$core$Maybe$Just)), $dillonkearns$elm_pages_v3_beta$Internal$ApiRoute$tryMatch_fn(path, fullHandler))) : $dillonkearns$elm_pages_v3_beta$BackendTask$succeed($elm$core$Maybe$Nothing);
                }, routeFound);
            }),
            kc: patterns,
            kg: $elm$core$Maybe$withDefault_fn($elm$regex$Regex$never, $elm$regex$Regex$fromString("^" + (pattern + "$")))
        };
    }, $dillonkearns$elm_pages_v3_beta$ApiRoute$preRender = F2($dillonkearns$elm_pages_v3_beta$ApiRoute$preRender_fn);
    var $dillonkearns$elm_pages_v3_beta$ApiRoute$single = function (handler) {
        return $dillonkearns$elm_pages_v3_beta$ApiRoute$preRender_fn(function (constructor) {
            return $dillonkearns$elm_pages_v3_beta$BackendTask$succeed(_List_fromArray([constructor]));
        }, handler);
    };
    var $dillonkearns$elm_pages_v3_beta$Pattern$empty = $dillonkearns$elm_pages_v3_beta$Pattern$Pattern_fn(_List_Nil, 1);
    var $dillonkearns$elm_pages_v3_beta$ApiRoute$succeed = function (a) {
        return $dillonkearns$elm_pages_v3_beta$Internal$ApiRoute$ApiRouteBuilder_fn($dillonkearns$elm_pages_v3_beta$Pattern$empty, "", function (_v0) {
            return a;
        }, function (_v1) {
            return "";
        }, function (list) {
            return list;
        });
    };
    var $author$project$Api$rss_fn = function (options, itemsSource) {
        return $dillonkearns$elm_pages_v3_beta$ApiRoute$single($dillonkearns$elm_pages_v3_beta$ApiRoute$literal_fn("articles/feed.xml", $dillonkearns$elm_pages_v3_beta$ApiRoute$succeed($dillonkearns$elm_pages_v3_beta$BackendTask$map_fn(function (items) {
            return $dillonkearns$elm_rss$Rss$generate({
                jX: options.lF,
                mN: $elm$core$Maybe$Just("elm-pages"),
                m2: items,
                m7: options.kI,
                iv: options.iv,
                jE: options.jE,
                lO: options.iv + ("/" + $elm$core$String$join_fn("/", options.k8))
            });
        }, itemsSource))));
    }, $author$project$Api$rss = F2($author$project$Api$rss_fn);
    var $dillonkearns$elm_sitemap$Path$dropLeading = function (url) {
        return _String_startsWith_fn("/", url) ? $elm$core$String$dropLeft_fn(1, url) : url;
    };
    var $dillonkearns$elm_sitemap$Path$dropTrailing = function (url) {
        return _String_endsWith_fn("/", url) ? $elm$core$String$dropRight_fn(1, url) : url;
    };
    var $dillonkearns$elm_sitemap$Path$dropBoth = function (url) {
        return $dillonkearns$elm_sitemap$Path$dropTrailing($dillonkearns$elm_sitemap$Path$dropLeading(url));
    };
    var $dillonkearns$elm_sitemap$Path$join = function (urls) {
        return $elm$core$String$join_fn("/", $elm$core$List$map_fn($dillonkearns$elm_sitemap$Path$dropBoth, urls));
    };
    var $dillonkearns$elm_sitemap$Sitemap$keyValue_fn = function (key, value) {
        return $billstclair$elm_xml_eeue56$Xml$Encode$object(_List_fromArray([
            _Utils_Tuple3(key, $elm$core$Dict$empty, value)
        ]));
    }, $dillonkearns$elm_sitemap$Sitemap$keyValue = F2($dillonkearns$elm_sitemap$Sitemap$keyValue_fn);
    var $dillonkearns$elm_sitemap$Sitemap$urlXml_fn = function (siteUrl, entry) {
        return $billstclair$elm_xml_eeue56$Xml$Encode$object(_List_fromArray([
            _Utils_Tuple3("url", $elm$core$Dict$empty, $billstclair$elm_xml_eeue56$Xml$Encode$list($elm$core$List$filterMap_fn($elm$core$Basics$identity, _List_fromArray([
                $elm$core$Maybe$Just($dillonkearns$elm_sitemap$Sitemap$keyValue_fn("loc", $billstclair$elm_xml_eeue56$Xml$Encode$string($dillonkearns$elm_sitemap$Path$join(_List_fromArray([siteUrl, entry.nM]))))),
                $elm$core$Maybe$map_fn($dillonkearns$elm_sitemap$Sitemap$keyValue("lastmod"), $elm$core$Maybe$map_fn($billstclair$elm_xml_eeue56$Xml$Encode$string, entry.m8))
            ]))))
        ]));
    }, $dillonkearns$elm_sitemap$Sitemap$urlXml = F2($dillonkearns$elm_sitemap$Sitemap$urlXml_fn);
    var $dillonkearns$elm_sitemap$Sitemap$build_fn = function (_v0, urls) {
        var siteUrl = _v0.iv;
        return $billstclair$elm_xml_eeue56$Xml$Encode$encode_fn(0, $billstclair$elm_xml_eeue56$Xml$Encode$object(_List_fromArray([
            _Utils_Tuple3("urlset", $elm$core$Dict$fromList(_List_fromArray([
                _Utils_Tuple2("xmlns", $billstclair$elm_xml_eeue56$Xml$Encode$string("http://www.sitemaps.org/schemas/sitemap/0.9"))
            ])), $billstclair$elm_xml_eeue56$Xml$Encode$list($elm$core$List$map_fn($dillonkearns$elm_sitemap$Sitemap$urlXml(siteUrl), urls)))
        ])));
    }, $dillonkearns$elm_sitemap$Sitemap$build = F2($dillonkearns$elm_sitemap$Sitemap$build_fn);
    var $author$project$Api$sitemap = function (entriesSource) {
        return $dillonkearns$elm_pages_v3_beta$ApiRoute$single($dillonkearns$elm_pages_v3_beta$ApiRoute$literal_fn("sitemap.xml", $dillonkearns$elm_pages_v3_beta$ApiRoute$succeed($dillonkearns$elm_pages_v3_beta$BackendTask$map_fn(function (entries) {
            return "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" + $dillonkearns$elm_sitemap$Sitemap$build_fn({ iv: $author$project$Site$config.kK }, entries);
        }, entriesSource))));
    };
    var $author$project$Site$tagline = "ymtszw's personal page";
    var $author$project$Site$title = "ymtszw's page";
    var $author$project$Api$routes_fn = function (getStaticRoutes, htmlToString) {
        return _List_fromArray([
            $author$project$Api$rss_fn({ kI: $author$project$Pages$builtAt, k8: _List_Nil, lF: $author$project$Site$tagline, iv: $author$project$Site$config.kK, jE: $author$project$Site$title }, $dillonkearns$elm_pages_v3_beta$BackendTask$map_fn($elm$core$List$map($author$project$Api$makeArticleRssItem), $author$project$Api$builtArticles)),
            $author$project$Api$sitemap($author$project$Api$makeSitemapEntries(getStaticRoutes))
        ]);
    }, $author$project$Api$routes = F2($author$project$Api$routes_fn);
    var $dillonkearns$elm_pages_v3_beta$Pattern$segmentToJson = function (segment) {
        switch (segment.$) {
            case 0:
                var literalString = segment.a;
                return $elm$json$Json$Encode$object(_List_fromArray([
                    _Utils_Tuple2("kind", $elm$json$Json$Encode$string("literal")),
                    _Utils_Tuple2("value", $elm$json$Json$Encode$string(literalString))
                ]));
            case 1:
                return $elm$json$Json$Encode$object(_List_fromArray([
                    _Utils_Tuple2("kind", $elm$json$Json$Encode$string("dynamic"))
                ]));
            default:
                var _v1 = segment.a;
                var first = _v1.a;
                var second = _v1.b;
                var rest = _v1.c;
                return $elm$json$Json$Encode$object(_List_fromArray([
                    _Utils_Tuple2("kind", $elm$json$Json$Encode$string("hybrid")),
                    _Utils_Tuple2("value", $elm$json$Json$Encode$list_fn($dillonkearns$elm_pages_v3_beta$Pattern$segmentToJson, _List_Cons(first, _List_Cons(second, rest))))
                ]));
        }
    };
    var $dillonkearns$elm_pages_v3_beta$Pattern$toJson = function (_v0) {
        var segments = _v0.a;
        return $elm$json$Json$Encode$list_fn($dillonkearns$elm_pages_v3_beta$Pattern$segmentToJson, segments);
    };
    var $dillonkearns$elm_pages_v3_beta$Internal$ApiRoute$toPattern = function (_v0) {
        var pattern = _v0.kc;
        return pattern;
    };
    var $dillonkearns$elm_pages_v3_beta$ApiRoute$toJson = function (apiRoute) {
        var kind = apiRoute.a8;
        return $elm$json$Json$Encode$object(_List_fromArray([
            _Utils_Tuple2("pathPattern", $dillonkearns$elm_pages_v3_beta$Pattern$toJson($dillonkearns$elm_pages_v3_beta$Internal$ApiRoute$toPattern(apiRoute))),
            _Utils_Tuple2("kind", $elm$json$Json$Encode$string(kind))
        ]));
    };
    var $author$project$Main$apiPatterns = $dillonkearns$elm_pages_v3_beta$ApiRoute$single($dillonkearns$elm_pages_v3_beta$ApiRoute$literal_fn("api-patterns.json", $dillonkearns$elm_pages_v3_beta$ApiRoute$succeed($dillonkearns$elm_pages_v3_beta$BackendTask$succeed(_Json_encode_fn(0, $elm$json$Json$Encode$list_fn($elm$core$Basics$identity, $elm$core$List$map_fn($dillonkearns$elm_pages_v3_beta$ApiRoute$toJson, $author$project$Api$routes_fn($author$project$Main$getStaticRoutes, F2(function (a, b) {
        return "";
    })))))))));
    var $author$project$Route$baseUrl = "/";
    var $author$project$Route$baseUrlAsPath = $elm$core$List$filter_fn(function (item) {
        return !$elm$core$String$isEmpty(item);
    }, $elm$core$String$split_fn("/", $author$project$Route$baseUrl));
    var $author$project$Main$DataAbout = function (a) {
        return { $: 3, a: a };
    };
    var $author$project$Main$DataArticles = function (a) {
        return { $: 4, a: a };
    };
    var $author$project$Main$DataArticles__ArticleId_ = function (a) {
        return { $: 1, a: a };
    };
    var $author$project$Main$DataArticles__Draft = function (a) {
        return { $: 0, a: a };
    };
    var $author$project$Main$DataIndex = function (a) {
        return { $: 6, a: a };
    };
    var $author$project$Main$DataTwilogs = function (a) {
        return { $: 5, a: a };
    };
    var $author$project$Main$DataTwilogs__Day_ = function (a) {
        return { $: 2, a: a };
    };
    var $elm$bytes$Bytes$Encode$getWidth = function (builder) {
        switch (builder.$) {
            case 0:
                return 1;
            case 1:
                return 2;
            case 2:
                return 4;
            case 3:
                return 1;
            case 4:
                return 2;
            case 5:
                return 4;
            case 6:
                return 4;
            case 7:
                return 8;
            case 8:
                var w = builder.a;
                return w;
            case 9:
                var w = builder.a;
                return w;
            default:
                var bs = builder.a;
                return _Bytes_width(bs);
        }
    };
    var $elm$bytes$Bytes$LE = 0;
    var $elm$bytes$Bytes$Encode$write_fn = function (builder, mb, offset) {
        switch (builder.$) {
            case 0:
                var n = builder.a;
                return _Bytes_write_i8_fn(mb, offset, n);
            case 1:
                var e = builder.a;
                var n = builder.b;
                return _Bytes_write_i16_fn(mb, offset, n, !e);
            case 2:
                var e = builder.a;
                var n = builder.b;
                return _Bytes_write_i32_fn(mb, offset, n, !e);
            case 3:
                var n = builder.a;
                return _Bytes_write_u8_fn(mb, offset, n);
            case 4:
                var e = builder.a;
                var n = builder.b;
                return _Bytes_write_u16_fn(mb, offset, n, !e);
            case 5:
                var e = builder.a;
                var n = builder.b;
                return _Bytes_write_u32_fn(mb, offset, n, !e);
            case 6:
                var e = builder.a;
                var n = builder.b;
                return _Bytes_write_f32_fn(mb, offset, n, !e);
            case 7:
                var e = builder.a;
                var n = builder.b;
                return _Bytes_write_f64_fn(mb, offset, n, !e);
            case 8:
                var bs = builder.b;
                return $elm$bytes$Bytes$Encode$writeSequence_fn(bs, mb, offset);
            case 9:
                var s = builder.b;
                return _Bytes_write_string_fn(mb, offset, s);
            default:
                var bs = builder.a;
                return _Bytes_write_bytes_fn(mb, offset, bs);
        }
    }, $elm$bytes$Bytes$Encode$write = F3($elm$bytes$Bytes$Encode$write_fn);
    var $elm$bytes$Bytes$Encode$writeSequence_fn = function (builders, mb, offset) {
        writeSequence: while (true) {
            if (!builders.b) {
                return offset;
            }
            else {
                var b = builders.a;
                var bs = builders.b;
                var $temp$builders = bs, $temp$mb = mb, $temp$offset = $elm$bytes$Bytes$Encode$write_fn(b, mb, offset);
                builders = $temp$builders;
                mb = $temp$mb;
                offset = $temp$offset;
                continue writeSequence;
            }
        }
    }, $elm$bytes$Bytes$Encode$writeSequence = F3($elm$bytes$Bytes$Encode$writeSequence_fn);
    var $elm$bytes$Bytes$Decode$Decoder = $elm$core$Basics$identity;
    var $elm$bytes$Bytes$Decode$fail = _Bytes_decodeFailure;
    var $elm$bytes$Bytes$Decode$map_fn = function (func, _v0) {
        var decodeA = _v0;
        return F2(function (bites, offset) {
            var _v1 = A2(decodeA, bites, offset);
            var aOffset = _v1.a;
            var a = _v1.b;
            return _Utils_Tuple2(aOffset, func(a));
        });
    }, $elm$bytes$Bytes$Decode$map = F2($elm$bytes$Bytes$Decode$map_fn);
    var $elm$bytes$Bytes$Decode$succeed = function (a) {
        return F2(function (_v0, offset) {
            return _Utils_Tuple2(offset, a);
        });
    };
    var $lamdera$codecs$Lamdera$Wire3$succeedDecode = $elm$bytes$Bytes$Decode$succeed;
    var $author$project$Route$About$w3_decode_Data = $lamdera$codecs$Lamdera$Wire3$succeedDecode({});
    var $author$project$Route$Articles$w3_decode_Data = $lamdera$codecs$Lamdera$Wire3$succeedDecode({});
    var $author$project$Route$Articles$ArticleId_$w3_decode_Data = $lamdera$codecs$Lamdera$Wire3$succeedDecode({});
    var $author$project$Route$Articles$Draft$w3_decode_Data = $lamdera$codecs$Lamdera$Wire3$succeedDecode({});
    var $author$project$Route$Index$w3_decode_Data = $lamdera$codecs$Lamdera$Wire3$succeedDecode({});
    var $author$project$Route$Twilogs$w3_decode_Data = $lamdera$codecs$Lamdera$Wire3$succeedDecode({});
    var $author$project$Route$Twilogs$Day_$w3_decode_Data = $lamdera$codecs$Lamdera$Wire3$succeedDecode({});
    var $author$project$Main$byteDecodePageData = function (route) {
        if (route.$ === 1) {
            return $elm$bytes$Bytes$Decode$fail;
        }
        else {
            var route_1_0 = route.a;
            switch (route_1_0.$) {
                case 0:
                    return $elm$bytes$Bytes$Decode$map_fn($author$project$Main$DataArticles__Draft, $author$project$Route$Articles$Draft$w3_decode_Data);
                case 1:
                    return $elm$bytes$Bytes$Decode$map_fn($author$project$Main$DataArticles__ArticleId_, $author$project$Route$Articles$ArticleId_$w3_decode_Data);
                case 2:
                    return $elm$bytes$Bytes$Decode$map_fn($author$project$Main$DataTwilogs__Day_, $author$project$Route$Twilogs$Day_$w3_decode_Data);
                case 3:
                    return $elm$bytes$Bytes$Decode$map_fn($author$project$Main$DataAbout, $author$project$Route$About$w3_decode_Data);
                case 4:
                    return $elm$bytes$Bytes$Decode$map_fn($author$project$Main$DataArticles, $author$project$Route$Articles$w3_decode_Data);
                case 5:
                    return $elm$bytes$Bytes$Decode$map_fn($author$project$Main$DataTwilogs, $author$project$Route$Twilogs$w3_decode_Data);
                default:
                    return $elm$bytes$Bytes$Decode$map_fn($author$project$Main$DataIndex, $author$project$Route$Index$w3_decode_Data);
            }
        }
    };
    var $elm$bytes$Bytes$Encode$U8 = function (a) {
        return { $: 3, a: a };
    };
    var $elm$bytes$Bytes$Encode$unsignedInt8 = $elm$bytes$Bytes$Encode$U8;
    var $elm$bytes$Bytes$Encode$Seq_fn = function (a, b) {
        return { $: 8, a: a, b: b };
    }, $elm$bytes$Bytes$Encode$Seq = F2($elm$bytes$Bytes$Encode$Seq_fn);
    var $elm$bytes$Bytes$Encode$getWidths_fn = function (width, builders) {
        getWidths: while (true) {
            if (!builders.b) {
                return width;
            }
            else {
                var b = builders.a;
                var bs = builders.b;
                var $temp$width = width + $elm$bytes$Bytes$Encode$getWidth(b), $temp$builders = bs;
                width = $temp$width;
                builders = $temp$builders;
                continue getWidths;
            }
        }
    }, $elm$bytes$Bytes$Encode$getWidths = F2($elm$bytes$Bytes$Encode$getWidths_fn);
    var $elm$bytes$Bytes$Encode$sequence = function (builders) {
        return $elm$bytes$Bytes$Encode$Seq_fn($elm$bytes$Bytes$Encode$getWidths_fn(0, builders), builders);
    };
    var $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength = function (s) {
        return $elm$bytes$Bytes$Encode$sequence(s);
    };
    var $author$project$Route$About$w3_encode_Data = function (w3_rec_var0) {
        return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_Nil);
    };
    var $author$project$Route$Articles$w3_encode_Data = function (w3_rec_var0) {
        return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_Nil);
    };
    var $author$project$Route$Articles$ArticleId_$w3_encode_Data = function (w3_rec_var0) {
        return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_Nil);
    };
    var $author$project$Route$Articles$Draft$w3_encode_Data = function (w3_rec_var0) {
        return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_Nil);
    };
    var $author$project$Route$Index$w3_encode_Data = function (w3_rec_var0) {
        return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_Nil);
    };
    var $author$project$Route$Twilogs$w3_encode_Data = function (w3_rec_var0) {
        return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_Nil);
    };
    var $author$project$Route$Twilogs$Day_$w3_encode_Data = function (w3_rec_var0) {
        return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_Nil);
    };
    var $lamdera$codecs$Lamdera$Wire3$endianness = 0;
    var $elm$bytes$Bytes$Encode$F64_fn = function (a, b) {
        return { $: 7, a: a, b: b };
    }, $elm$bytes$Bytes$Encode$F64 = F2($elm$bytes$Bytes$Encode$F64_fn);
    var $elm$bytes$Bytes$Encode$float64 = $elm$bytes$Bytes$Encode$F64;
    var $lamdera$codecs$Lamdera$Wire3$encodeFloat64 = function (f) {
        return $elm$bytes$Bytes$Encode$F64_fn($lamdera$codecs$Lamdera$Wire3$endianness, f);
    };
    var $lamdera$codecs$Lamdera$Wire3$intDivBy_fn = function (b, a) {
        var v = a / b;
        return (v < 0) ? (-$elm$core$Basics$floor(-v)) : $elm$core$Basics$floor(v);
    }, $lamdera$codecs$Lamdera$Wire3$intDivBy = F2($lamdera$codecs$Lamdera$Wire3$intDivBy_fn);
    var $lamdera$codecs$Lamdera$Wire3$signedToUnsigned = function (i) {
        return (i < 0) ? (((-2) * i) - 1) : (2 * i);
    };
    var $lamdera$codecs$Lamdera$Wire3$encodeInt64 = function (i) {
        var n = $lamdera$codecs$Lamdera$Wire3$signedToUnsigned(i);
        var n0 = _Basics_modBy_fn(256, n);
        var n1 = _Basics_modBy_fn(256, $lamdera$codecs$Lamdera$Wire3$intDivBy_fn(256, n));
        var n2 = _Basics_modBy_fn(256, $lamdera$codecs$Lamdera$Wire3$intDivBy_fn(256, $lamdera$codecs$Lamdera$Wire3$intDivBy_fn(256, n)));
        var n3 = _Basics_modBy_fn(256, $lamdera$codecs$Lamdera$Wire3$intDivBy_fn(256, $lamdera$codecs$Lamdera$Wire3$intDivBy_fn(256, $lamdera$codecs$Lamdera$Wire3$intDivBy_fn(256, n))));
        var ei = function (e) {
            return $elm$bytes$Bytes$Encode$sequence($elm$core$List$map_fn($elm$bytes$Bytes$Encode$unsignedInt8, e));
        };
        return (n <= 215) ? ei(_List_fromArray([n])) : ((n <= 9431) ? ei(_List_fromArray([
            216 + $lamdera$codecs$Lamdera$Wire3$intDivBy_fn(256, n - 216),
            _Basics_modBy_fn(256, n - 216)
        ])) : ((_Utils_cmp(n, 256 * 256) < 0) ? ei(_List_fromArray([252, n1, n0])) : ((_Utils_cmp(n, (256 * 256) * 256) < 0) ? ei(_List_fromArray([253, n2, n1, n0])) : ((_Utils_cmp(n, ((256 * 256) * 256) * 256) < 0) ? ei(_List_fromArray([254, n3, n2, n1, n0])) : $elm$bytes$Bytes$Encode$sequence(_List_fromArray([
            $elm$bytes$Bytes$Encode$unsignedInt8(255),
            $lamdera$codecs$Lamdera$Wire3$encodeFloat64(i)
        ]))))));
    };
    var $elm$bytes$Bytes$Encode$getStringWidth = _Bytes_getStringWidth;
    var $elm$bytes$Bytes$Encode$Utf8_fn = function (a, b) {
        return { $: 9, a: a, b: b };
    }, $elm$bytes$Bytes$Encode$Utf8 = F2($elm$bytes$Bytes$Encode$Utf8_fn);
    var $elm$bytes$Bytes$Encode$string = function (str) {
        return $elm$bytes$Bytes$Encode$Utf8_fn(_Bytes_getStringWidth(str), str);
    };
    var $lamdera$codecs$Lamdera$Wire3$encodeString = function (s) {
        return $elm$bytes$Bytes$Encode$sequence(_List_fromArray([
            $lamdera$codecs$Lamdera$Wire3$encodeInt64($elm$bytes$Bytes$Encode$getStringWidth(s)),
            $elm$bytes$Bytes$Encode$string(s)
        ]));
    };
    var $lamdera$codecs$Lamdera$Wire3$encodeUnsignedInt8 = $elm$bytes$Bytes$Encode$unsignedInt8;
    var $author$project$ErrorPage$w3_encode_ErrorPage = function (w3v) {
        if (w3v.$ === 1) {
            var v0 = w3v.a;
            return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
                $lamdera$codecs$Lamdera$Wire3$encodeUnsignedInt8(0),
                $lamdera$codecs$Lamdera$Wire3$encodeString(v0)
            ]));
        }
        else {
            return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
                $lamdera$codecs$Lamdera$Wire3$encodeUnsignedInt8(1)
            ]));
        }
    };
    var $author$project$Main$byteEncodePageData = function (pageData) {
        switch (pageData.$) {
            case 8:
                var thisPageData = pageData.a;
                return $author$project$ErrorPage$w3_encode_ErrorPage(thisPageData);
            case 7:
                return $elm$bytes$Bytes$Encode$unsignedInt8(0);
            case 0:
                var thisPageData = pageData.a;
                return $author$project$Route$Articles$Draft$w3_encode_Data(thisPageData);
            case 1:
                var thisPageData = pageData.a;
                return $author$project$Route$Articles$ArticleId_$w3_encode_Data(thisPageData);
            case 2:
                var thisPageData = pageData.a;
                return $author$project$Route$Twilogs$Day_$w3_encode_Data(thisPageData);
            case 3:
                var thisPageData = pageData.a;
                return $author$project$Route$About$w3_encode_Data(thisPageData);
            case 4:
                var thisPageData = pageData.a;
                return $author$project$Route$Articles$w3_encode_Data(thisPageData);
            case 5:
                var thisPageData = pageData.a;
                return $author$project$Route$Twilogs$w3_encode_Data(thisPageData);
            default:
                var thisPageData = pageData.a;
                return $author$project$Route$Index$w3_encode_Data(thisPageData);
        }
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$GotBuildError = function (a) {
        return { $: 1, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$GotDataBatch = function (a) {
        return { $: 0, a: a };
    };
    var $elm$json$Json$Decode$andThen = _Json_andThen;
    var $dillonkearns$elm_pages_v3_beta$RenderRequest$HtmlAndJson = 0;
    var $dillonkearns$elm_pages_v3_beta$RenderRequest$OnlyJson = 1;
    var $dillonkearns$elm_pages_v3_beta$RenderRequest$SinglePage_fn = function (a, b, c) {
        return { $: 0, a: a, b: b, c: c };
    }, $dillonkearns$elm_pages_v3_beta$RenderRequest$SinglePage = F3($dillonkearns$elm_pages_v3_beta$RenderRequest$SinglePage_fn);
    var $elm$json$Json$Decode$bool = _Json_decodeBool;
    var $elm$json$Json$Decode$fail = _Json_fail;
    var $elm$json$Json$Decode$field = _Json_decodeField;
    var $elm$json$Json$Decode$map3 = _Json_map3;
    var $dillonkearns$elm_pages_v3_beta$RenderRequest$Api = function (a) {
        return { $: 1, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$RenderRequest$NotFound = function (a) {
        return { $: 2, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$RenderRequest$Page = function (a) {
        return { $: 0, a: a };
    };
    var $elm$regex$Regex$replace_a0 = _Regex_infinity, $elm$regex$Regex$replace = _Regex_replaceAtMost($elm$regex$Regex$replace_a0);
    var $dillonkearns$elm_pages_v3_beta$RenderRequest$dropTrailingIndexHtml = A2($elm$regex$Regex$replace, $elm$core$Maybe$withDefault_fn($elm$regex$Regex$never, $elm$regex$Regex$fromString("/index\\.html$")), function (_v0) {
        return "";
    });
    var $elm$regex$Regex$contains = _Regex_contains;
    var $dillonkearns$elm_pages_v3_beta$Internal$ApiRoute$tryMatchDone_fn = function (path, _v0) {
        var handler = _v0;
        return _Regex_contains_fn(handler.kg, path) ? $elm$core$Maybe$Just(handler) : $elm$core$Maybe$Nothing;
    }, $dillonkearns$elm_pages_v3_beta$Internal$ApiRoute$tryMatchDone = F2($dillonkearns$elm_pages_v3_beta$Internal$ApiRoute$tryMatchDone_fn);
    var $dillonkearns$elm_pages_v3_beta$Internal$ApiRoute$firstMatch_fn = function (path, handlers) {
        firstMatch: while (true) {
            if (!handlers.b) {
                return $elm$core$Maybe$Nothing;
            }
            else {
                var first = handlers.a;
                var rest = handlers.b;
                var _v1 = $dillonkearns$elm_pages_v3_beta$Internal$ApiRoute$tryMatchDone_fn(path, first);
                if (!_v1.$) {
                    var response = _v1.a;
                    return $elm$core$Maybe$Just(response);
                }
                else {
                    var $temp$path = path, $temp$handlers = rest;
                    path = $temp$path;
                    handlers = $temp$handlers;
                    continue firstMatch;
                }
            }
        }
    }, $dillonkearns$elm_pages_v3_beta$Internal$ApiRoute$firstMatch = F2($dillonkearns$elm_pages_v3_beta$Internal$ApiRoute$firstMatch_fn);
    var $dillonkearns$elm_pages_v3_beta$Path$toSegments = function (path) {
        return $elm$core$List$filter_fn($elm$core$Basics$neq(""), $elm$core$String$split_fn("/", path));
    };
    var $dillonkearns$elm_pages_v3_beta$Path$fromString = function (path) {
        return $dillonkearns$elm_pages_v3_beta$Path$toSegments(path);
    };
    var $elm$virtual_dom$VirtualDom$Normal = function (a) {
        return { $: 0, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$HtmlPrinter$asJsonView = function (x) {
        return  _HtmlAsJson_toJson(x)
}

              var virtualDomKernelConstants =
  {
    nodeTypeTagger: 4,
    nodeTypeThunk: 5,
    kids: "e",
    refs: "l",
    thunk: "m",
    node: "k",
    value: "a"
  }

function forceThunks(vNode) {
if ( (typeof vNode !== "undefined" && vNode.$ === "#2") // normal/debug mode
     || (typeof vNode !== "undefined" && typeof vNode.$ === "undefined" && typeof vNode.a == "string" && typeof vNode.b == "object" ) // optimize mode
   ) {
    // This is a tuple (the kids : List (String, Html) field of a Keyed node); recurse into the right side of the tuple
    vNode.b = forceThunks(vNode.b);
  }
  if (typeof vNode !== 'undefined' && vNode.$ === virtualDomKernelConstants.nodeTypeThunk && !vNode[virtualDomKernelConstants.node]) {
    // This is a lazy node; evaluate it
    var args = vNode[virtualDomKernelConstants.thunk];
    vNode[virtualDomKernelConstants.node] = vNode[virtualDomKernelConstants.thunk].apply(args);
    // And then recurse into the evaluated node
    vNode[virtualDomKernelConstants.node] = forceThunks(vNode[virtualDomKernelConstants.node]);
  }
  if (typeof vNode !== 'undefined' && vNode.$ === virtualDomKernelConstants.nodeTypeTagger) {
    // This is an Html.map; recurse into the node it is wrapping
    vNode[virtualDomKernelConstants.node] = forceThunks(vNode[virtualDomKernelConstants.node]);
  }
  if (typeof vNode !== 'undefined' && typeof vNode[virtualDomKernelConstants.kids] !== 'undefined') {
    // This is something with children (either a node with kids : List Html, or keyed with kids : List (String, Html));
    // recurse into the children
    vNode[virtualDomKernelConstants.kids] = vNode[virtualDomKernelConstants.kids].map(forceThunks);
  }
  return vNode;
}

function _HtmlAsJson_toJson(html) {

  return _Json_wrap(forceThunks(html));
;
    };
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$HtmlContext_fn = function (a, b) {
        return { $: 0, a: a, b: b };
    }, $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$HtmlContext = F2($dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$HtmlContext_fn);
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$NodeEntry = function (a) {
        return { $: 1, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$NodeRecord_fn = function (tag, children, facts, descendantsCount) {
        return { kN: children, fg: descendantsCount, aK: facts, fQ: tag };
    }, $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$NodeRecord = F4($dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$NodeRecord_fn);
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$TextTag = function (a) {
        return { $: 0, a: a };
    };
    var $elm$json$Json$Decode$at_fn = function (fields, decoder) {
        return $elm$core$List$foldr_fn($elm$json$Json$Decode$field, decoder, fields);
    }, $elm$json$Json$Decode$at = F2($elm$json$Json$Decode$at_fn);
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$CustomNode = function (a) {
        return { $: 2, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$MarkdownNode = function (a) {
        return { $: 3, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$CustomNodeRecord_fn = function (facts, model) {
        return { aK: facts, ac: model };
    }, $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$CustomNodeRecord = F2($dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$CustomNodeRecord_fn);
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$Facts_fn = function (styles, events, attributeNamespace, stringAttributes, boolAttributes) {
        return { fZ: attributeNamespace, f1: boolAttributes, gj: events, hc: stringAttributes, hd: styles };
    }, $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$Facts = F5($dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$Facts_fn);
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$Constants$attributeNamespaceKey = "a4";
    var $elm$json$Json$Decode$keyValuePairs = _Json_decodeKeyValuePairs;
    var $elm$json$Json$Decode$dict = function (decoder) {
        return _Json_map1_fn($elm$core$Dict$fromList, $elm$json$Json$Decode$keyValuePairs(decoder));
    };
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$Constants$eventKey = "a0";
    var $elm$json$Json$Decode$oneOf = _Json_oneOf;
    var $elm$json$Json$Decode$value = _Json_decodeValue;
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$decodeEvents = function (taggedEventDecoder) {
        return $elm$json$Json$Decode$oneOf(_List_fromArray([
            _Json_decodeField_fn($dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$Constants$eventKey, $elm$json$Json$Decode$dict(_Json_map1_fn(taggedEventDecoder, $elm$json$Json$Decode$value))),
            $elm$json$Json$Decode$succeed($elm$core$Dict$empty)
        ]));
    };
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$Constants$attributeKey = "a3";
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$decodeDictFilterMap = function (decoder) {
        return _Json_map1_fn(A2($elm$core$Basics$composeR, $elm$core$Dict$toList, A2($elm$core$Basics$composeR, $elm$core$List$filterMap(function (_v0) {
            var key = _v0.a;
            var value = _v0.b;
            var _v1 = _Json_run_fn(decoder, value);
            if (_v1.$ === 1) {
                return $elm$core$Maybe$Nothing;
            }
            else {
                var v = _v1.a;
                return $elm$core$Maybe$Just(_Utils_Tuple2(key, v));
            }
        }), $elm$core$Dict$fromList)), $elm$json$Json$Decode$dict($elm$json$Json$Decode$value));
    };
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$decodeAttributes = function (decoder) {
        return $elm$json$Json$Decode$oneOf(_List_fromArray([
            _Json_decodeField_fn($dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$Constants$attributeKey, $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$decodeDictFilterMap(decoder)),
            $elm$json$Json$Decode$succeed($elm$core$Dict$empty)
        ]));
    };
    var $elm$core$Dict$foldl_fn = function (func, acc, dict) {
        foldl: while (true) {
            if (dict.$ === -2) {
                return acc;
            }
            else {
                var key = dict.b;
                var value = dict.c;
                var left = dict.d;
                var right = dict.e;
                var $temp$func = func, $temp$acc = A3(func, key, value, $elm$core$Dict$foldl_fn(func, acc, left)), $temp$dict = right;
                func = $temp$func;
                acc = $temp$acc;
                dict = $temp$dict;
                continue foldl;
            }
        }
    }, $elm$core$Dict$foldl_fn_unwrapped = function (func, acc, dict) {
        foldl: while (true) {
            if (dict.$ === -2) {
                return acc;
            }
            else {
                var key = dict.b;
                var value = dict.c;
                var left = dict.d;
                var right = dict.e;
                var $temp$func = func, $temp$acc = func(key, value, $elm$core$Dict$foldl_fn_unwrapped(func, acc, left)), $temp$dict = right;
                func = $temp$func;
                acc = $temp$acc;
                dict = $temp$dict;
                continue foldl;
            }
        }
    }, $elm$core$Dict$foldl = F3($elm$core$Dict$foldl_fn);
    var $elm$core$Dict$filter_fn = function (isGood, dict) {
        return $elm$core$Dict$foldl_fn_unwrapped(function (k, v, d) {
            return A2(isGood, k, v) ? $elm$core$Dict$insert_fn(k, v, d) : d;
        }, $elm$core$Dict$empty, dict);
    }, $elm$core$Dict$filter_fn_unwrapped = function (isGood, dict) {
        return $elm$core$Dict$foldl_fn_unwrapped(function (k, v, d) {
            return isGood(k, v) ? $elm$core$Dict$insert_fn(k, v, d) : d;
        }, $elm$core$Dict$empty, dict);
    }, $elm$core$Dict$filter = F2($elm$core$Dict$filter_fn);
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$Constants$styleKey = "a1";
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$Constants$knownKeys = _List_fromArray([$dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$Constants$styleKey, $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$Constants$eventKey, $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$Constants$attributeKey, $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$Constants$attributeNamespaceKey]);
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$Helpers$filterKnownKeys_a0 = F2(function (key, _v0) {
        return !$elm$core$List$member_fn(key, $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$Constants$knownKeys);
    }), $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$Helpers$filterKnownKeys = $elm$core$Dict$filter($dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$Helpers$filterKnownKeys_a0);
    var $elm$core$Dict$union_fn = function (t1, t2) {
        return $elm$core$Dict$foldl_fn($elm$core$Dict$insert, t2, t1);
    }, $elm$core$Dict$union = F2($elm$core$Dict$union_fn);
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$decodeOthers = function (otherDecoder) {
        return _Json_andThen_fn(function (attributes) {
            return _Json_map1_fn(A2($elm$core$Basics$composeR, $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$Helpers$filterKnownKeys, $elm$core$Dict$union(attributes)), $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$decodeDictFilterMap(otherDecoder));
        }, $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$decodeAttributes(otherDecoder));
    };
    var $elm$json$Json$Decode$string = _Json_decodeString;
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$decodeStyles = $elm$json$Json$Decode$oneOf(_List_fromArray([
        _Json_decodeField_fn($dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$Constants$styleKey, $elm$json$Json$Decode$dict($elm$json$Json$Decode$string)),
        $elm$json$Json$Decode$succeed($elm$core$Dict$empty)
    ]));
    var $elm$json$Json$Decode$map5 = _Json_map5;
    var $elm$json$Json$Decode$maybe = function (decoder) {
        return $elm$json$Json$Decode$oneOf(_List_fromArray([
            _Json_map1_fn($elm$core$Maybe$Just, decoder),
            $elm$json$Json$Decode$succeed($elm$core$Maybe$Nothing)
        ]));
    };
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$decodeFacts = function (_v0) {
        var taggers = _v0.a;
        var eventDecoder = _v0.b;
        return _Json_map5_fn($dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$Facts, $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$decodeStyles, $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$decodeEvents(eventDecoder(taggers)), $elm$json$Json$Decode$maybe(_Json_decodeField_fn($dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$Constants$attributeNamespaceKey, $elm$json$Json$Decode$value)), $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$decodeOthers($elm$json$Json$Decode$string), $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$decodeOthers($elm$json$Json$Decode$bool));
    };
    var $dillonkearns$elm_pages_v3_beta$Test$Internal$KernelConstants$kernelConstants = {
        eG: { eG: "b", jg: "a" },
        ad: { fg: "b", aK: "d", le: "e", ac: "g", lp: "k", nr: "$", ns: 3, nt: 2, nu: 1, nv: 4, nw: 0, nx: 5, n_: "l", fQ: "c", op: "j", hl: "a" }
    };
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$decodeCustomNodeRecord = function (context) {
        return _Json_map2_fn($dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$CustomNodeRecord, _Json_decodeField_fn($dillonkearns$elm_pages_v3_beta$Test$Internal$KernelConstants$kernelConstants.ad.aK, $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$decodeFacts(context)), _Json_decodeField_fn($dillonkearns$elm_pages_v3_beta$Test$Internal$KernelConstants$kernelConstants.ad.ac, $elm$json$Json$Decode$value));
    };
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$MarkdownNodeRecord_fn = function (facts, model) {
        return { aK: facts, ac: model };
    }, $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$MarkdownNodeRecord = F2($dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$MarkdownNodeRecord_fn);
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$Markdown$MarkdownModel_fn = function (options, markdown) {
        return { eG: markdown, jg: options };
    }, $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$Markdown$MarkdownModel = F2($dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$Markdown$MarkdownModel_fn);
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$Markdown$baseMarkdownModel = {
        eG: "",
        jg: {
            gb: $elm$core$Maybe$Nothing,
            gr: $elm$core$Maybe$Just({ hL: false, iy: false }),
            g7: false,
            g9: false
        }
    };
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$Markdown$decodeMarkdownModel = _Json_map1_fn($dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$Markdown$MarkdownModel($dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$Markdown$baseMarkdownModel.jg), _Json_decodeField_fn($dillonkearns$elm_pages_v3_beta$Test$Internal$KernelConstants$kernelConstants.eG.eG, $elm$json$Json$Decode$string));
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$decodeMarkdownNodeRecord = function (context) {
        return _Json_map2_fn($dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$MarkdownNodeRecord, _Json_decodeField_fn($dillonkearns$elm_pages_v3_beta$Test$Internal$KernelConstants$kernelConstants.ad.aK, $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$decodeFacts(context)), _Json_decodeField_fn($dillonkearns$elm_pages_v3_beta$Test$Internal$KernelConstants$kernelConstants.ad.ac, $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$Markdown$decodeMarkdownModel));
    };
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$decodeCustomNode = function (context) {
        return $elm$json$Json$Decode$oneOf(_List_fromArray([
            _Json_map1_fn($dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$MarkdownNode, $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$decodeMarkdownNodeRecord(context)),
            _Json_map1_fn($dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$CustomNode, $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$decodeCustomNodeRecord(context))
        ]));
    };
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$decodeTextTag = _Json_decodeField_fn($dillonkearns$elm_pages_v3_beta$Test$Internal$KernelConstants$kernelConstants.ad.hl, _Json_andThen_fn(function (text) {
        return $elm$json$Json$Decode$succeed({ hl: text });
    }, $elm$json$Json$Decode$string));
    var $elm$json$Json$Decode$int = _Json_decodeInt;
    var $elm$json$Json$Decode$list = _Json_decodeList;
    var $elm$json$Json$Decode$map4 = _Json_map4;
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$contextDecodeElmHtml = function (context) {
        return _Json_andThen_fn(function (nodeType) {
            return _Utils_eq(nodeType, $dillonkearns$elm_pages_v3_beta$Test$Internal$KernelConstants$kernelConstants.ad.nw) ? _Json_map1_fn($dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$TextTag, $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$decodeTextTag) : (_Utils_eq(nodeType, $dillonkearns$elm_pages_v3_beta$Test$Internal$KernelConstants$kernelConstants.ad.nt) ? _Json_map1_fn($dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$NodeEntry, $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$decodeKeyedNode(context)) : (_Utils_eq(nodeType, $dillonkearns$elm_pages_v3_beta$Test$Internal$KernelConstants$kernelConstants.ad.nu) ? _Json_map1_fn($dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$NodeEntry, $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$decodeNode(context)) : (_Utils_eq(nodeType, $dillonkearns$elm_pages_v3_beta$Test$Internal$KernelConstants$kernelConstants.ad.ns) ? $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$decodeCustomNode(context) : (_Utils_eq(nodeType, $dillonkearns$elm_pages_v3_beta$Test$Internal$KernelConstants$kernelConstants.ad.nv) ? $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$decodeTagger(context) : (_Utils_eq(nodeType, $dillonkearns$elm_pages_v3_beta$Test$Internal$KernelConstants$kernelConstants.ad.nx) ? _Json_decodeField_fn($dillonkearns$elm_pages_v3_beta$Test$Internal$KernelConstants$kernelConstants.ad.lp, $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$contextDecodeElmHtml(context)) : $elm$json$Json$Decode$fail("No such type as " + $elm$core$String$fromInt(nodeType)))))));
        }, _Json_decodeField_fn($dillonkearns$elm_pages_v3_beta$Test$Internal$KernelConstants$kernelConstants.ad.nr, $elm$json$Json$Decode$int));
    };
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$decodeKeyedNode = function (context) {
        var decodeSecondNode = _Json_decodeField_fn("b", $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$contextDecodeElmHtml(context));
        return _Json_map4_fn($dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$NodeRecord, _Json_decodeField_fn($dillonkearns$elm_pages_v3_beta$Test$Internal$KernelConstants$kernelConstants.ad.fQ, $elm$json$Json$Decode$string), _Json_decodeField_fn($dillonkearns$elm_pages_v3_beta$Test$Internal$KernelConstants$kernelConstants.ad.le, $elm$json$Json$Decode$list(decodeSecondNode)), _Json_decodeField_fn($dillonkearns$elm_pages_v3_beta$Test$Internal$KernelConstants$kernelConstants.ad.aK, $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$decodeFacts(context)), _Json_decodeField_fn($dillonkearns$elm_pages_v3_beta$Test$Internal$KernelConstants$kernelConstants.ad.fg, $elm$json$Json$Decode$int));
    };
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$decodeNode = function (context) {
        return _Json_map4_fn($dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$NodeRecord, _Json_decodeField_fn($dillonkearns$elm_pages_v3_beta$Test$Internal$KernelConstants$kernelConstants.ad.fQ, $elm$json$Json$Decode$string), _Json_decodeField_fn($dillonkearns$elm_pages_v3_beta$Test$Internal$KernelConstants$kernelConstants.ad.le, $elm$json$Json$Decode$list($dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$contextDecodeElmHtml(context))), _Json_decodeField_fn($dillonkearns$elm_pages_v3_beta$Test$Internal$KernelConstants$kernelConstants.ad.aK, $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$decodeFacts(context)), _Json_decodeField_fn($dillonkearns$elm_pages_v3_beta$Test$Internal$KernelConstants$kernelConstants.ad.fg, $elm$json$Json$Decode$int));
    };
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$decodeTagger = function (_v0) {
        var taggers = _v0.a;
        var eventDecoder = _v0.b;
        return _Json_andThen_fn(function (tagger) {
            var nodeDecoder = $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$contextDecodeElmHtml($dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$HtmlContext_fn(_Utils_ap(taggers, _List_fromArray([tagger])), eventDecoder));
            return $elm$json$Json$Decode$at_fn(_List_fromArray([$dillonkearns$elm_pages_v3_beta$Test$Internal$KernelConstants$kernelConstants.ad.lp]), nodeDecoder);
        }, _Json_decodeField_fn($dillonkearns$elm_pages_v3_beta$Test$Internal$KernelConstants$kernelConstants.ad.op, $elm$json$Json$Decode$value));
    };
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$decodeElmHtml = function (eventDecoder) {
        return $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$contextDecodeElmHtml($dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$HtmlContext_fn(_List_Nil, eventDecoder));
    };
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$ToString$defaultFormatOptions = { fu: 0, fG: false };
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$RawTextElements = 1;
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$ToString$escapeRawText_fn = function (kind, rawText) {
        switch (kind) {
            case 0:
                return rawText;
            case 1:
                return rawText;
            default:
                return $elm$core$String$replace_fn("'", "&#039;", $elm$core$String$replace_fn("\"", "&quot;", $elm$core$String$replace_fn(">", "&gt;", $elm$core$String$replace_fn("<", "&lt;", $elm$core$String$replace_fn("&", "&amp;", rawText)))));
        }
    }, $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$ToString$escapeRawText = F2($dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$ToString$escapeRawText_fn);
    var $elm$core$Dict$get_fn = function (targetKey, dict) {
        get: while (true) {
            if (dict.$ === -2) {
                return $elm$core$Maybe$Nothing;
            }
            else {
                var key = dict.b;
                var value = dict.c;
                var left = dict.d;
                var right = dict.e;
                var _v1 = _Utils_compare_fn(targetKey, key);
                switch (_v1) {
                    case 0:
                        var $temp$targetKey = targetKey, $temp$dict = left;
                        targetKey = $temp$targetKey;
                        dict = $temp$dict;
                        continue get;
                    case 1:
                        return $elm$core$Maybe$Just(value);
                    default:
                        var $temp$targetKey = targetKey, $temp$dict = right;
                        targetKey = $temp$targetKey;
                        dict = $temp$dict;
                        continue get;
                }
            }
        }
    }, $elm$core$Dict$get = F2($elm$core$Dict$get_fn);
    var $elm$core$Tuple$mapFirst_fn = function (func, _v0) {
        var x = _v0.a;
        var y = _v0.b;
        return _Utils_Tuple2(func(x), y);
    }, $elm$core$Tuple$mapFirst = F2($elm$core$Tuple$mapFirst_fn);
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$ToString$propertyToAttributeName = function (propertyName) {
        switch (propertyName) {
            case "className":
                return "class";
            case "htmlFor":
                return "for";
            case "httpEquiv":
                return "http-equiv";
            case "acceptCharset":
                return "accept-charset";
            default:
                return propertyName;
        }
    };
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$EscapableRawTextElements = 2;
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$NormalElements = 4;
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$VoidElements = 0;
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$escapableRawTextElements = _List_fromArray(["textarea", "title"]);
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$rawTextElements = _List_fromArray(["script", "style"]);
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$voidElements = _List_fromArray(["area", "base", "br", "col", "embed", "hr", "img", "input", "link", "meta", "param", "source", "track", "wbr"]);
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$toElementKind = function (element) {
        return $elm$core$List$member_fn(element, $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$voidElements) ? 0 : ($elm$core$List$member_fn(element, $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$rawTextElements) ? 1 : ($elm$core$List$member_fn(element, $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$escapableRawTextElements) ? 2 : 4));
    };
    var $elm$core$String$trim = _String_trim;
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$ToString$nodeRecordToString_fn = function (options, _v1) {
        var facts = _v1.aK;
        var children = _v1.kN;
        var tag = _v1.fQ;
        var styles = function () {
            var _v6 = $elm$core$Dict$toList(facts.hd);
            if (!_v6.b) {
                return $elm$core$Maybe$Nothing;
            }
            else {
                var styleValues = _v6;
                return $elm$core$Maybe$Just(function (styleString) {
                    return "style=\"" + (styleString + "\"");
                }($elm$core$String$join_fn("", $elm$core$List$map_fn(function (_v7) {
                    var key = _v7.a;
                    var value = _v7.b;
                    return key + (":" + (value + ";"));
                }, styleValues))));
            }
        }();
        var stringAttributes = $elm$core$Maybe$Just($elm$core$String$join_fn(" ", $elm$core$List$map_fn(function (_v5) {
            var k = _v5.a;
            var v = _v5.b;
            return k + ("=\"" + (v + "\""));
        }, $elm$core$List$map_fn($elm$core$Tuple$mapFirst($dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$ToString$propertyToAttributeName), $elm$core$Dict$toList($elm$core$Dict$filter_fn_unwrapped(function (k, v) {
            return k !== "className";
        }, facts.hc))))));
        var openTag = function (extras) {
            var trimmedExtras = $elm$core$List$filter_fn($elm$core$Basics$neq(""), $elm$core$List$map_fn($elm$core$String$trim, $elm$core$List$filterMap_fn(function (x) {
                return x;
            }, extras)));
            var filling = function () {
                if (!trimmedExtras.b) {
                    return "";
                }
                else {
                    var more = trimmedExtras;
                    return " " + $elm$core$String$join_fn(" ", more);
                }
            }();
            return "<" + (tag + (filling + ">"));
        };
        var closeTag = "</" + (tag + ">");
        var classes = $elm$core$Maybe$map_fn(function (name) {
            return "class=\"" + (name + "\"");
        }, $elm$core$Dict$get_fn("className", facts.hc));
        var childrenStrings = $elm$core$List$map_fn($elm$core$Basics$append($elm$core$String$repeat_fn(options.fu, " ")), $elm$core$List$concat($elm$core$List$map_fn(A2($dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$ToString$nodeToLines, $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$toElementKind(tag), options), children)));
        var boolAttributes = $elm$core$Maybe$Just($elm$core$String$join_fn(" ", $elm$core$List$filterMap_fn(function (_v3) {
            var k = _v3.a;
            var v = _v3.b;
            return v ? $elm$core$Maybe$Just(k) : $elm$core$Maybe$Nothing;
        }, $elm$core$Dict$toList(facts.f1))));
        var _v2 = $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$toElementKind(tag);
        if (!_v2) {
            return _List_fromArray([
                openTag(_List_fromArray([classes, styles, stringAttributes, boolAttributes]))
            ]);
        }
        else {
            return _Utils_ap(_List_fromArray([
                openTag(_List_fromArray([classes, styles, stringAttributes, boolAttributes]))
            ]), _Utils_ap(childrenStrings, _List_fromArray([closeTag])));
        }
    }, $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$ToString$nodeRecordToString = F2($dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$ToString$nodeRecordToString_fn);
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$ToString$nodeToLines_fn = function (kind, options, nodeType) {
        switch (nodeType.$) {
            case 0:
                var text = nodeType.a.hl;
                return _List_fromArray([
                    $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$ToString$escapeRawText_fn(kind, text)
                ]);
            case 1:
                var record = nodeType.a;
                return $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$ToString$nodeRecordToString_fn(options, record);
            case 2:
                var record = nodeType.a;
                return _List_Nil;
            case 3:
                var record = nodeType.a;
                return _List_fromArray([record.ac.eG]);
            default:
                return _List_Nil;
        }
    }, $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$ToString$nodeToLines = F3($dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$ToString$nodeToLines_fn);
    var $dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$ToString$nodeToStringWithOptions = function (options) {
        return A2($elm$core$Basics$composeR, A2($dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$ToString$nodeToLines, 1, options), $elm$core$String$join(options.fG ? "\n" : ""));
    };
    var $dillonkearns$elm_pages_v3_beta$HtmlPrinter$htmlToString_fn = function (formatOptions, viewHtml) {
        var _v0 = _Json_run_fn($dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$InternalTypes$decodeElmHtml(F2(function (_v1, _v2) {
            return $elm$virtual_dom$VirtualDom$Normal($elm$json$Json$Decode$succeed(0));
        })), $dillonkearns$elm_pages_v3_beta$HtmlPrinter$asJsonView(viewHtml));
        if (!_v0.$) {
            var str = _v0.a;
            return A2($dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$ToString$nodeToStringWithOptions, $elm$core$Maybe$withDefault_fn($dillonkearns$elm_pages_v3_beta$Test$Html$Internal$ElmHtml$ToString$defaultFormatOptions, formatOptions), str);
        }
        else {
            var err = _v0.a;
            return "Error pre-rendering HTML in HtmlPrinter.elm: " + $elm$json$Json$Decode$errorToString(err);
        }
    }, $dillonkearns$elm_pages_v3_beta$HtmlPrinter$htmlToString = F2($dillonkearns$elm_pages_v3_beta$HtmlPrinter$htmlToString_fn);
    var $elm$core$String$contains = _String_contains;
    var $dillonkearns$elm_pages_v3_beta$RenderRequest$isFile = function (rawPath) {
        return _String_contains_fn(".", rawPath);
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$String$chopEnd_fn = function (needle, string) {
        chopEnd: while (true) {
            if (_String_endsWith_fn(needle, string)) {
                var $temp$needle = needle, $temp$string = $elm$core$String$dropRight_fn($elm$core$String$length(needle), string);
                needle = $temp$needle;
                string = $temp$string;
                continue chopEnd;
            }
            else {
                return string;
            }
        }
    }, $dillonkearns$elm_pages_v3_beta$Pages$Internal$String$chopEnd = F2($dillonkearns$elm_pages_v3_beta$Pages$Internal$String$chopEnd_fn);
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$String$chopStart_fn = function (needle, string) {
        chopStart: while (true) {
            if (_String_startsWith_fn(needle, string)) {
                var $temp$needle = needle, $temp$string = $elm$core$String$dropLeft_fn($elm$core$String$length(needle), string);
                needle = $temp$needle;
                string = $temp$string;
                continue chopStart;
            }
            else {
                return string;
            }
        }
    }, $dillonkearns$elm_pages_v3_beta$Pages$Internal$String$chopStart = F2($dillonkearns$elm_pages_v3_beta$Pages$Internal$String$chopStart_fn);
    var $dillonkearns$elm_pages_v3_beta$Path$normalize = function (pathPart) {
        return $dillonkearns$elm_pages_v3_beta$Pages$Internal$String$chopStart_fn("/", $dillonkearns$elm_pages_v3_beta$Pages$Internal$String$chopEnd_fn("/", pathPart));
    };
    var $dillonkearns$elm_pages_v3_beta$Path$join = function (parts) {
        return $elm$core$List$map_fn($dillonkearns$elm_pages_v3_beta$Path$normalize, $elm$core$List$filter_fn(function (segment) {
            return segment !== "/";
        }, parts));
    };
    var $elm$url$Url$Https = 1;
    var $dillonkearns$elm_pages_v3_beta$RenderRequest$pathToUrl = function (path) {
        return { bq: $elm$core$Maybe$Nothing, gu: "TODO", nM: path, gS: $elm$core$Maybe$Nothing, gZ: 1, bG: $elm$core$Maybe$Nothing };
    };
    var $dillonkearns$elm_pages_v3_beta$RenderRequest$requestPayloadDecoder = function (config) {
        return _Json_decodeField_fn("payload", _Json_decodeField_fn("path", _Json_map1_fn(function (rawPath) {
            var path = $dillonkearns$elm_pages_v3_beta$RenderRequest$dropTrailingIndexHtml(rawPath);
            var route = config.oA($dillonkearns$elm_pages_v3_beta$RenderRequest$pathToUrl(path));
            var apiRoute = $dillonkearns$elm_pages_v3_beta$Internal$ApiRoute$firstMatch_fn($elm$core$String$dropLeft_fn(1, path), config.lY($dillonkearns$elm_pages_v3_beta$HtmlPrinter$htmlToString));
            if (!route.$) {
                if ($dillonkearns$elm_pages_v3_beta$RenderRequest$isFile(rawPath)) {
                    if (!apiRoute.$) {
                        var justApi = apiRoute.a;
                        return $dillonkearns$elm_pages_v3_beta$RenderRequest$Api(_Utils_Tuple2(path, justApi));
                    }
                    else {
                        return $dillonkearns$elm_pages_v3_beta$RenderRequest$NotFound($dillonkearns$elm_pages_v3_beta$Path$fromString(path));
                    }
                }
                else {
                    return $dillonkearns$elm_pages_v3_beta$RenderRequest$Page({
                        j_: route,
                        nM: $dillonkearns$elm_pages_v3_beta$Path$join(config.n5(route))
                    });
                }
            }
            else {
                if (!apiRoute.$) {
                    var justApi = apiRoute.a;
                    return $dillonkearns$elm_pages_v3_beta$RenderRequest$Api(_Utils_Tuple2(path, justApi));
                }
                else {
                    return $dillonkearns$elm_pages_v3_beta$RenderRequest$NotFound($dillonkearns$elm_pages_v3_beta$Path$fromString(path));
                }
            }
        }, $elm$json$Json$Decode$string)));
    };
    var $dillonkearns$elm_pages_v3_beta$RenderRequest$decoder = function (config) {
        return _Json_decodeField_fn("request", _Json_map3_fn(F3(function (includeHtml, requestThing, payload) {
            return $dillonkearns$elm_pages_v3_beta$RenderRequest$SinglePage_fn(includeHtml, requestThing, payload);
        }), _Json_andThen_fn(function (kind) {
            if (kind === "single-page") {
                return _Json_map1_fn(function (jsonOnly) {
                    return jsonOnly ? 1 : 0;
                }, _Json_decodeField_fn("jsonOnly", $elm$json$Json$Decode$bool));
            }
            else {
                return $elm$json$Json$Decode$fail("Unhandled");
            }
        }, _Json_decodeField_fn("kind", $elm$json$Json$Decode$string)), $dillonkearns$elm_pages_v3_beta$RenderRequest$requestPayloadDecoder(config), _Json_decodeField_fn("payload", $elm$json$Json$Decode$value)));
    };
    var $elm$json$Json$Encode$null = _Json_encodeNull;
    var $dillonkearns$elm_pages_v3_beta$RenderRequest$default = $dillonkearns$elm_pages_v3_beta$RenderRequest$SinglePage_fn(0, $dillonkearns$elm_pages_v3_beta$RenderRequest$NotFound($dillonkearns$elm_pages_v3_beta$Path$fromString("/error")), $elm$json$Json$Encode$null);
    var $dillonkearns$elm_pages_v3_beta$TerminalText$blankStyle = { d7: false, bi: $elm$core$Maybe$Nothing, e5: false };
    var $vito$elm_ansi$Ansi$Print = function (a) {
        return { $: 0, a: a };
    };
    var $vito$elm_ansi$Ansi$Remainder = function (a) {
        return { $: 1, a: a };
    };
    var $vito$elm_ansi$Ansi$encodeCode = function (code) {
        if (code.$ === 1) {
            return "";
        }
        else {
            var num = code.a;
            return $elm$core$String$fromInt(num);
        }
    };
    var $vito$elm_ansi$Ansi$encodeCodes = function (codes) {
        return $elm$core$String$join_fn(";", $elm$core$List$map_fn($vito$elm_ansi$Ansi$encodeCode, codes));
    };
    var $vito$elm_ansi$Ansi$completeParsing = function (parser) {
        switch (parser.a.$) {
            case 0:
                var _v1 = parser.a;
                var model = parser.b;
                var update = parser.c;
                return A2(update, $vito$elm_ansi$Ansi$Remainder("\u001B"), model);
            case 1:
                var _v2 = parser.a;
                var codes = _v2.a;
                var currentCode = _v2.b;
                var model = parser.b;
                var update = parser.c;
                return A2(update, $vito$elm_ansi$Ansi$Remainder("\u001B[" + $vito$elm_ansi$Ansi$encodeCodes(_Utils_ap(codes, _List_fromArray([currentCode])))), model);
            default:
                if (parser.a.a === "") {
                    var model = parser.b;
                    return model;
                }
                else {
                    var str = parser.a.a;
                    var model = parser.b;
                    var update = parser.c;
                    return A2(update, $vito$elm_ansi$Ansi$Print(str), model);
                }
        }
    };
    var $vito$elm_ansi$Ansi$Parser_fn = function (a, b, c) {
        return { $: 0, a: a, b: b, c: c };
    }, $vito$elm_ansi$Ansi$Parser = F3($vito$elm_ansi$Ansi$Parser_fn);
    var $vito$elm_ansi$Ansi$Unescaped = function (a) {
        return { $: 2, a: a };
    };
    var $vito$elm_ansi$Ansi$emptyParser_a0 = $vito$elm_ansi$Ansi$Unescaped(""), $vito$elm_ansi$Ansi$emptyParser = $vito$elm_ansi$Ansi$Parser($vito$elm_ansi$Ansi$emptyParser_a0);
    var $vito$elm_ansi$Ansi$CSI_fn = function (a, b) {
        return { $: 1, a: a, b: b };
    }, $vito$elm_ansi$Ansi$CSI = F2($vito$elm_ansi$Ansi$CSI_fn);
    var $vito$elm_ansi$Ansi$CarriageReturn = { $: 13 };
    var $vito$elm_ansi$Ansi$CursorBack = function (a) {
        return { $: 17, a: a };
    };
    var $vito$elm_ansi$Ansi$CursorColumn = function (a) {
        return { $: 19, a: a };
    };
    var $vito$elm_ansi$Ansi$CursorDown = function (a) {
        return { $: 15, a: a };
    };
    var $vito$elm_ansi$Ansi$CursorForward = function (a) {
        return { $: 16, a: a };
    };
    var $vito$elm_ansi$Ansi$CursorUp = function (a) {
        return { $: 14, a: a };
    };
    var $vito$elm_ansi$Ansi$EraseDisplay = function (a) {
        return { $: 20, a: a };
    };
    var $vito$elm_ansi$Ansi$EraseLine = function (a) {
        return { $: 21, a: a };
    };
    var $vito$elm_ansi$Ansi$Escaped = { $: 0 };
    var $vito$elm_ansi$Ansi$Linebreak = { $: 12 };
    var $vito$elm_ansi$Ansi$RestoreCursorPosition = { $: 23 };
    var $vito$elm_ansi$Ansi$SaveCursorPosition = { $: 22 };
    var $vito$elm_ansi$Ansi$Custom_fn = function (a, b, c) {
        return { $: 16, a: a, b: b, c: c };
    }, $vito$elm_ansi$Ansi$Custom = F3($vito$elm_ansi$Ansi$Custom_fn);
    var $vito$elm_ansi$Ansi$SetBackground = function (a) {
        return { $: 3, a: a };
    };
    var $vito$elm_ansi$Ansi$SetForeground = function (a) {
        return { $: 2, a: a };
    };
    var $vito$elm_ansi$Ansi$Black = { $: 0 };
    var $vito$elm_ansi$Ansi$Blue = { $: 4 };
    var $vito$elm_ansi$Ansi$BrightBlack = { $: 8 };
    var $vito$elm_ansi$Ansi$BrightBlue = { $: 12 };
    var $vito$elm_ansi$Ansi$BrightCyan = { $: 14 };
    var $vito$elm_ansi$Ansi$BrightGreen = { $: 10 };
    var $vito$elm_ansi$Ansi$BrightMagenta = { $: 13 };
    var $vito$elm_ansi$Ansi$BrightRed = { $: 9 };
    var $vito$elm_ansi$Ansi$BrightWhite = { $: 15 };
    var $vito$elm_ansi$Ansi$BrightYellow = { $: 11 };
    var $vito$elm_ansi$Ansi$Cyan = { $: 6 };
    var $vito$elm_ansi$Ansi$Green = { $: 2 };
    var $vito$elm_ansi$Ansi$Magenta = { $: 5 };
    var $vito$elm_ansi$Ansi$Red = { $: 1 };
    var $vito$elm_ansi$Ansi$SetBlink = function (a) {
        return { $: 8, a: a };
    };
    var $vito$elm_ansi$Ansi$SetBold = function (a) {
        return { $: 4, a: a };
    };
    var $vito$elm_ansi$Ansi$SetFaint = function (a) {
        return { $: 5, a: a };
    };
    var $vito$elm_ansi$Ansi$SetFraktur = function (a) {
        return { $: 10, a: a };
    };
    var $vito$elm_ansi$Ansi$SetFramed = function (a) {
        return { $: 11, a: a };
    };
    var $vito$elm_ansi$Ansi$SetInverted = function (a) {
        return { $: 9, a: a };
    };
    var $vito$elm_ansi$Ansi$SetItalic = function (a) {
        return { $: 6, a: a };
    };
    var $vito$elm_ansi$Ansi$SetUnderline = function (a) {
        return { $: 7, a: a };
    };
    var $vito$elm_ansi$Ansi$White = { $: 7 };
    var $vito$elm_ansi$Ansi$Yellow = { $: 3 };
    var $vito$elm_ansi$Ansi$reset = _List_fromArray([
        $vito$elm_ansi$Ansi$SetForeground($elm$core$Maybe$Nothing),
        $vito$elm_ansi$Ansi$SetBackground($elm$core$Maybe$Nothing),
        $vito$elm_ansi$Ansi$SetBold(false),
        $vito$elm_ansi$Ansi$SetFaint(false),
        $vito$elm_ansi$Ansi$SetItalic(false),
        $vito$elm_ansi$Ansi$SetUnderline(false),
        $vito$elm_ansi$Ansi$SetBlink(false),
        $vito$elm_ansi$Ansi$SetInverted(false),
        $vito$elm_ansi$Ansi$SetFraktur(false),
        $vito$elm_ansi$Ansi$SetFramed(false)
    ]);
    var $vito$elm_ansi$Ansi$codeActions = function (code) {
        switch (code) {
            case 0:
                return $vito$elm_ansi$Ansi$reset;
            case 1:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetBold(true)
                ]);
            case 2:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetFaint(true)
                ]);
            case 3:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetItalic(true)
                ]);
            case 4:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetUnderline(true)
                ]);
            case 5:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetBlink(true)
                ]);
            case 7:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetInverted(true)
                ]);
            case 20:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetFraktur(true)
                ]);
            case 21:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetBold(false)
                ]);
            case 22:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetFaint(false),
                    $vito$elm_ansi$Ansi$SetBold(false)
                ]);
            case 23:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetItalic(false),
                    $vito$elm_ansi$Ansi$SetFraktur(false)
                ]);
            case 24:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetUnderline(false)
                ]);
            case 25:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetBlink(false)
                ]);
            case 27:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetInverted(false)
                ]);
            case 30:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetForeground($elm$core$Maybe$Just($vito$elm_ansi$Ansi$Black))
                ]);
            case 31:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetForeground($elm$core$Maybe$Just($vito$elm_ansi$Ansi$Red))
                ]);
            case 32:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetForeground($elm$core$Maybe$Just($vito$elm_ansi$Ansi$Green))
                ]);
            case 33:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetForeground($elm$core$Maybe$Just($vito$elm_ansi$Ansi$Yellow))
                ]);
            case 34:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetForeground($elm$core$Maybe$Just($vito$elm_ansi$Ansi$Blue))
                ]);
            case 35:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetForeground($elm$core$Maybe$Just($vito$elm_ansi$Ansi$Magenta))
                ]);
            case 36:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetForeground($elm$core$Maybe$Just($vito$elm_ansi$Ansi$Cyan))
                ]);
            case 37:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetForeground($elm$core$Maybe$Just($vito$elm_ansi$Ansi$White))
                ]);
            case 39:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetForeground($elm$core$Maybe$Nothing)
                ]);
            case 40:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetBackground($elm$core$Maybe$Just($vito$elm_ansi$Ansi$Black))
                ]);
            case 41:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetBackground($elm$core$Maybe$Just($vito$elm_ansi$Ansi$Red))
                ]);
            case 42:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetBackground($elm$core$Maybe$Just($vito$elm_ansi$Ansi$Green))
                ]);
            case 43:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetBackground($elm$core$Maybe$Just($vito$elm_ansi$Ansi$Yellow))
                ]);
            case 44:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetBackground($elm$core$Maybe$Just($vito$elm_ansi$Ansi$Blue))
                ]);
            case 45:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetBackground($elm$core$Maybe$Just($vito$elm_ansi$Ansi$Magenta))
                ]);
            case 46:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetBackground($elm$core$Maybe$Just($vito$elm_ansi$Ansi$Cyan))
                ]);
            case 47:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetBackground($elm$core$Maybe$Just($vito$elm_ansi$Ansi$White))
                ]);
            case 49:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetBackground($elm$core$Maybe$Nothing)
                ]);
            case 51:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetFramed(true)
                ]);
            case 54:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetFramed(false)
                ]);
            case 90:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetForeground($elm$core$Maybe$Just($vito$elm_ansi$Ansi$BrightBlack))
                ]);
            case 91:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetForeground($elm$core$Maybe$Just($vito$elm_ansi$Ansi$BrightRed))
                ]);
            case 92:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetForeground($elm$core$Maybe$Just($vito$elm_ansi$Ansi$BrightGreen))
                ]);
            case 93:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetForeground($elm$core$Maybe$Just($vito$elm_ansi$Ansi$BrightYellow))
                ]);
            case 94:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetForeground($elm$core$Maybe$Just($vito$elm_ansi$Ansi$BrightBlue))
                ]);
            case 95:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetForeground($elm$core$Maybe$Just($vito$elm_ansi$Ansi$BrightMagenta))
                ]);
            case 96:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetForeground($elm$core$Maybe$Just($vito$elm_ansi$Ansi$BrightCyan))
                ]);
            case 97:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetForeground($elm$core$Maybe$Just($vito$elm_ansi$Ansi$BrightWhite))
                ]);
            case 100:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetBackground($elm$core$Maybe$Just($vito$elm_ansi$Ansi$BrightBlack))
                ]);
            case 101:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetBackground($elm$core$Maybe$Just($vito$elm_ansi$Ansi$BrightRed))
                ]);
            case 102:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetBackground($elm$core$Maybe$Just($vito$elm_ansi$Ansi$BrightGreen))
                ]);
            case 103:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetBackground($elm$core$Maybe$Just($vito$elm_ansi$Ansi$BrightYellow))
                ]);
            case 104:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetBackground($elm$core$Maybe$Just($vito$elm_ansi$Ansi$BrightBlue))
                ]);
            case 105:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetBackground($elm$core$Maybe$Just($vito$elm_ansi$Ansi$BrightMagenta))
                ]);
            case 106:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetBackground($elm$core$Maybe$Just($vito$elm_ansi$Ansi$BrightCyan))
                ]);
            case 107:
                return _List_fromArray([
                    $vito$elm_ansi$Ansi$SetBackground($elm$core$Maybe$Just($vito$elm_ansi$Ansi$BrightWhite))
                ]);
            default:
                return _List_Nil;
        }
    };
    var $vito$elm_ansi$Ansi$colorCode = function (code) {
        switch (code) {
            case 0:
                return $elm$core$Maybe$Just($vito$elm_ansi$Ansi$Black);
            case 1:
                return $elm$core$Maybe$Just($vito$elm_ansi$Ansi$Red);
            case 2:
                return $elm$core$Maybe$Just($vito$elm_ansi$Ansi$Green);
            case 3:
                return $elm$core$Maybe$Just($vito$elm_ansi$Ansi$Yellow);
            case 4:
                return $elm$core$Maybe$Just($vito$elm_ansi$Ansi$Blue);
            case 5:
                return $elm$core$Maybe$Just($vito$elm_ansi$Ansi$Magenta);
            case 6:
                return $elm$core$Maybe$Just($vito$elm_ansi$Ansi$Cyan);
            case 7:
                return $elm$core$Maybe$Just($vito$elm_ansi$Ansi$White);
            case 8:
                return $elm$core$Maybe$Just($vito$elm_ansi$Ansi$BrightBlack);
            case 9:
                return $elm$core$Maybe$Just($vito$elm_ansi$Ansi$BrightRed);
            case 10:
                return $elm$core$Maybe$Just($vito$elm_ansi$Ansi$BrightGreen);
            case 11:
                return $elm$core$Maybe$Just($vito$elm_ansi$Ansi$BrightYellow);
            case 12:
                return $elm$core$Maybe$Just($vito$elm_ansi$Ansi$BrightBlue);
            case 13:
                return $elm$core$Maybe$Just($vito$elm_ansi$Ansi$BrightMagenta);
            case 14:
                return $elm$core$Maybe$Just($vito$elm_ansi$Ansi$BrightCyan);
            case 15:
                return $elm$core$Maybe$Just($vito$elm_ansi$Ansi$BrightWhite);
            default:
                if ((code >= 16) && (code < 232)) {
                    var scale = function (n) {
                        return (!n) ? 0 : (55 + (n * 40));
                    };
                    var c = code - 16;
                    var g = _Basics_modBy_fn(6, (c / 6) | 0);
                    var r = _Basics_modBy_fn(6, (((c / 6) | 0) / 6) | 0);
                    var b = _Basics_modBy_fn(6, c);
                    return $elm$core$Maybe$Just($vito$elm_ansi$Ansi$Custom_fn(scale(r), scale(g), scale(b)));
                }
                else {
                    if ((code >= 232) && (code < 256)) {
                        var c = ((code - 232) * 10) + 8;
                        return $elm$core$Maybe$Just($vito$elm_ansi$Ansi$Custom_fn(c, c, c));
                    }
                    else {
                        return $elm$core$Maybe$Nothing;
                    }
                }
        }
    };
    var $vito$elm_ansi$Ansi$captureArguments = function (list) {
        _v0$4: while (true) {
            if (list.b) {
                if (list.b.b && list.b.b.b) {
                    switch (list.a) {
                        case 38:
                            switch (list.b.a) {
                                case 5:
                                    var _v1 = list.b;
                                    var _v2 = _v1.b;
                                    var n = _v2.a;
                                    var xs = _v2.b;
                                    return _List_Cons($vito$elm_ansi$Ansi$SetForeground($vito$elm_ansi$Ansi$colorCode(n)), $vito$elm_ansi$Ansi$captureArguments(xs));
                                case 2:
                                    if (list.b.b.b.b && list.b.b.b.b.b) {
                                        var _v5 = list.b;
                                        var _v6 = _v5.b;
                                        var r = _v6.a;
                                        var _v7 = _v6.b;
                                        var g = _v7.a;
                                        var _v8 = _v7.b;
                                        var b = _v8.a;
                                        var xs = _v8.b;
                                        var c = A2($elm$core$Basics$clamp, 0, 255);
                                        return _List_Cons($vito$elm_ansi$Ansi$SetForeground($elm$core$Maybe$Just($vito$elm_ansi$Ansi$Custom_fn(c(r), c(g), c(b)))), $vito$elm_ansi$Ansi$captureArguments(xs));
                                    }
                                    else {
                                        break _v0$4;
                                    }
                                default:
                                    break _v0$4;
                            }
                        case 48:
                            switch (list.b.a) {
                                case 5:
                                    var _v3 = list.b;
                                    var _v4 = _v3.b;
                                    var n = _v4.a;
                                    var xs = _v4.b;
                                    return _List_Cons($vito$elm_ansi$Ansi$SetBackground($vito$elm_ansi$Ansi$colorCode(n)), $vito$elm_ansi$Ansi$captureArguments(xs));
                                case 2:
                                    if (list.b.b.b.b && list.b.b.b.b.b) {
                                        var _v9 = list.b;
                                        var _v10 = _v9.b;
                                        var r = _v10.a;
                                        var _v11 = _v10.b;
                                        var g = _v11.a;
                                        var _v12 = _v11.b;
                                        var b = _v12.a;
                                        var xs = _v12.b;
                                        var c = A2($elm$core$Basics$clamp, 0, 255);
                                        return _List_Cons($vito$elm_ansi$Ansi$SetBackground($elm$core$Maybe$Just($vito$elm_ansi$Ansi$Custom_fn(c(r), c(g), c(b)))), $vito$elm_ansi$Ansi$captureArguments(xs));
                                    }
                                    else {
                                        break _v0$4;
                                    }
                                default:
                                    break _v0$4;
                            }
                        default:
                            break _v0$4;
                    }
                }
                else {
                    break _v0$4;
                }
            }
            else {
                return _List_Nil;
            }
        }
        var n = list.a;
        var xs = list.b;
        return _Utils_ap($vito$elm_ansi$Ansi$codeActions(n), $vito$elm_ansi$Ansi$captureArguments(xs));
    };
    var $vito$elm_ansi$Ansi$completeBracketed_fn = function (_v0, actions) {
        var model = _v0.b;
        var update = _v0.c;
        return $vito$elm_ansi$Ansi$Parser_fn($vito$elm_ansi$Ansi$Unescaped(""), $elm$core$List$foldl_fn(update, model, actions), update);
    }, $vito$elm_ansi$Ansi$completeBracketed = F2($vito$elm_ansi$Ansi$completeBracketed_fn);
    var $vito$elm_ansi$Ansi$completeUnescaped = function (parser) {
        if (parser.a.$ === 2) {
            if (parser.a.a === "") {
                var model = parser.b;
                var update = parser.c;
                return model;
            }
            else {
                var str = parser.a.a;
                var model = parser.b;
                var update = parser.c;
                return A2(update, $vito$elm_ansi$Ansi$Print(str), model);
            }
        }
        else {
            var model = parser.b;
            return model;
        }
    };
    var $vito$elm_ansi$Ansi$CursorPosition_fn = function (a, b) {
        return { $: 18, a: a, b: b };
    }, $vito$elm_ansi$Ansi$CursorPosition = F2($vito$elm_ansi$Ansi$CursorPosition_fn);
    var $vito$elm_ansi$Ansi$cursorPosition = function (codes) {
        _v0$5: while (true) {
            if (codes.b) {
                if (codes.a.$ === 1) {
                    if (!codes.b.b) {
                        var _v4 = codes.a;
                        return _List_fromArray([
                            $vito$elm_ansi$Ansi$CursorPosition_fn(1, 1)
                        ]);
                    }
                    else {
                        if (codes.b.a.$ === 1) {
                            if (!codes.b.b.b) {
                                var _v1 = codes.a;
                                var _v2 = codes.b;
                                var _v3 = _v2.a;
                                return _List_fromArray([
                                    $vito$elm_ansi$Ansi$CursorPosition_fn(1, 1)
                                ]);
                            }
                            else {
                                break _v0$5;
                            }
                        }
                        else {
                            if (!codes.b.b.b) {
                                var _v7 = codes.a;
                                var _v8 = codes.b;
                                var col = _v8.a.a;
                                return _List_fromArray([
                                    $vito$elm_ansi$Ansi$CursorPosition_fn(1, col)
                                ]);
                            }
                            else {
                                break _v0$5;
                            }
                        }
                    }
                }
                else {
                    if (codes.b.b) {
                        if (codes.b.a.$ === 1) {
                            if (!codes.b.b.b) {
                                var row = codes.a.a;
                                var _v5 = codes.b;
                                var _v6 = _v5.a;
                                return _List_fromArray([
                                    $vito$elm_ansi$Ansi$CursorPosition_fn(row, 1)
                                ]);
                            }
                            else {
                                break _v0$5;
                            }
                        }
                        else {
                            if (!codes.b.b.b) {
                                var row = codes.a.a;
                                var _v9 = codes.b;
                                var col = _v9.a.a;
                                return _List_fromArray([
                                    $vito$elm_ansi$Ansi$CursorPosition_fn(row, col)
                                ]);
                            }
                            else {
                                break _v0$5;
                            }
                        }
                    }
                    else {
                        break _v0$5;
                    }
                }
            }
            else {
                break _v0$5;
            }
        }
        return _List_Nil;
    };
    var $vito$elm_ansi$Ansi$EraseAll = 2;
    var $vito$elm_ansi$Ansi$EraseToBeginning = 0;
    var $vito$elm_ansi$Ansi$EraseToEnd = 1;
    var $vito$elm_ansi$Ansi$eraseMode = function (code) {
        switch (code) {
            case 0:
                return 1;
            case 1:
                return 0;
            default:
                return 2;
        }
    };
    var $elm$core$String$toInt = _String_toInt;
    var $vito$elm_ansi$Ansi$parseChar_fn = function (_char, parser) {
        switch (parser.a.$) {
            case 2:
                var str = parser.a.a;
                var model = parser.b;
                var update = parser.c;
                switch (_char) {
                    case "\r":
                        return $vito$elm_ansi$Ansi$Parser_fn($vito$elm_ansi$Ansi$Unescaped(""), A2(update, $vito$elm_ansi$Ansi$CarriageReturn, $vito$elm_ansi$Ansi$completeUnescaped(parser)), update);
                    case "\n":
                        return $vito$elm_ansi$Ansi$Parser_fn($vito$elm_ansi$Ansi$Unescaped(""), A2(update, $vito$elm_ansi$Ansi$Linebreak, $vito$elm_ansi$Ansi$completeUnescaped(parser)), update);
                    case "\u001B":
                        return $vito$elm_ansi$Ansi$Parser_fn($vito$elm_ansi$Ansi$Escaped, $vito$elm_ansi$Ansi$completeUnescaped(parser), update);
                    default:
                        return $vito$elm_ansi$Ansi$Parser_fn($vito$elm_ansi$Ansi$Unescaped(_Utils_ap(str, _char)), model, update);
                }
            case 0:
                var _v2 = parser.a;
                var model = parser.b;
                var update = parser.c;
                if (_char === "[") {
                    return $vito$elm_ansi$Ansi$Parser_fn($vito$elm_ansi$Ansi$CSI_fn(_List_Nil, $elm$core$Maybe$Nothing), model, update);
                }
                else {
                    return $vito$elm_ansi$Ansi$Parser_fn($vito$elm_ansi$Ansi$Unescaped(_char), model, update);
                }
            default:
                var _v4 = parser.a;
                var codes = _v4.a;
                var currentCode = _v4.b;
                var model = parser.b;
                var update = parser.c;
                switch (_char) {
                    case "m":
                        return $vito$elm_ansi$Ansi$completeBracketed_fn(parser, $vito$elm_ansi$Ansi$captureArguments($elm$core$List$map_fn($elm$core$Maybe$withDefault(0), _Utils_ap(codes, _List_fromArray([currentCode])))));
                    case "A":
                        return $vito$elm_ansi$Ansi$completeBracketed_fn(parser, _List_fromArray([
                            $vito$elm_ansi$Ansi$CursorUp($elm$core$Maybe$withDefault_fn(1, currentCode))
                        ]));
                    case "B":
                        return $vito$elm_ansi$Ansi$completeBracketed_fn(parser, _List_fromArray([
                            $vito$elm_ansi$Ansi$CursorDown($elm$core$Maybe$withDefault_fn(1, currentCode))
                        ]));
                    case "C":
                        return $vito$elm_ansi$Ansi$completeBracketed_fn(parser, _List_fromArray([
                            $vito$elm_ansi$Ansi$CursorForward($elm$core$Maybe$withDefault_fn(1, currentCode))
                        ]));
                    case "D":
                        return $vito$elm_ansi$Ansi$completeBracketed_fn(parser, _List_fromArray([
                            $vito$elm_ansi$Ansi$CursorBack($elm$core$Maybe$withDefault_fn(1, currentCode))
                        ]));
                    case "E":
                        return $vito$elm_ansi$Ansi$completeBracketed_fn(parser, _List_fromArray([
                            $vito$elm_ansi$Ansi$CursorDown($elm$core$Maybe$withDefault_fn(1, currentCode)),
                            $vito$elm_ansi$Ansi$CursorColumn(0)
                        ]));
                    case "F":
                        return $vito$elm_ansi$Ansi$completeBracketed_fn(parser, _List_fromArray([
                            $vito$elm_ansi$Ansi$CursorUp($elm$core$Maybe$withDefault_fn(1, currentCode)),
                            $vito$elm_ansi$Ansi$CursorColumn(0)
                        ]));
                    case "G":
                        return $vito$elm_ansi$Ansi$completeBracketed_fn(parser, _List_fromArray([
                            $vito$elm_ansi$Ansi$CursorColumn($elm$core$Maybe$withDefault_fn(0, currentCode))
                        ]));
                    case "H":
                        return $vito$elm_ansi$Ansi$completeBracketed_fn(parser, $vito$elm_ansi$Ansi$cursorPosition(_Utils_ap(codes, _List_fromArray([currentCode]))));
                    case "J":
                        return $vito$elm_ansi$Ansi$completeBracketed_fn(parser, _List_fromArray([
                            $vito$elm_ansi$Ansi$EraseDisplay($vito$elm_ansi$Ansi$eraseMode($elm$core$Maybe$withDefault_fn(0, currentCode)))
                        ]));
                    case "K":
                        return $vito$elm_ansi$Ansi$completeBracketed_fn(parser, _List_fromArray([
                            $vito$elm_ansi$Ansi$EraseLine($vito$elm_ansi$Ansi$eraseMode($elm$core$Maybe$withDefault_fn(0, currentCode)))
                        ]));
                    case "f":
                        return $vito$elm_ansi$Ansi$completeBracketed_fn(parser, $vito$elm_ansi$Ansi$cursorPosition(_Utils_ap(codes, _List_fromArray([currentCode]))));
                    case "s":
                        return $vito$elm_ansi$Ansi$completeBracketed_fn(parser, _List_fromArray([$vito$elm_ansi$Ansi$SaveCursorPosition]));
                    case "u":
                        return $vito$elm_ansi$Ansi$completeBracketed_fn(parser, _List_fromArray([$vito$elm_ansi$Ansi$RestoreCursorPosition]));
                    case ";":
                        return $vito$elm_ansi$Ansi$Parser_fn($vito$elm_ansi$Ansi$CSI_fn(_Utils_ap(codes, _List_fromArray([currentCode])), $elm$core$Maybe$Nothing), model, update);
                    default:
                        var c = _char;
                        var _v6 = $elm$core$String$toInt(c);
                        if (!_v6.$) {
                            var num = _v6.a;
                            return $vito$elm_ansi$Ansi$Parser_fn($vito$elm_ansi$Ansi$CSI_fn(codes, $elm$core$Maybe$Just(($elm$core$Maybe$withDefault_fn(0, currentCode) * 10) + num)), model, update);
                        }
                        else {
                            return $vito$elm_ansi$Ansi$completeBracketed_fn(parser, _List_Nil);
                        }
                }
        }
    }, $vito$elm_ansi$Ansi$parseChar = F2($vito$elm_ansi$Ansi$parseChar_fn);
    var $vito$elm_ansi$Ansi$parseInto_fn = function (model, update, ansi) {
        return $vito$elm_ansi$Ansi$completeParsing($elm$core$List$foldl_fn($vito$elm_ansi$Ansi$parseChar, $vito$elm_ansi$Ansi$Parser_fn($vito$elm_ansi$Ansi$emptyParser_a0, model, update), $elm$core$String$split_fn("", ansi)));
    }, $vito$elm_ansi$Ansi$parseInto = F3($vito$elm_ansi$Ansi$parseInto_fn);
    var $dillonkearns$elm_pages_v3_beta$TerminalText$Style_fn = function (a, b) {
        return { $: 0, a: a, b: b };
    }, $dillonkearns$elm_pages_v3_beta$TerminalText$Style = F2($dillonkearns$elm_pages_v3_beta$TerminalText$Style_fn);
    var $dillonkearns$elm_pages_v3_beta$TerminalText$parseInto_fn = function (action, _v0) {
        var pendingStyle = _v0.a;
        var soFar = _v0.b;
        switch (action.$) {
            case 0:
                var string = action.a;
                return _Utils_Tuple2($dillonkearns$elm_pages_v3_beta$TerminalText$blankStyle, _List_Cons($dillonkearns$elm_pages_v3_beta$TerminalText$Style_fn(pendingStyle, string), soFar));
            case 1:
                return _Utils_Tuple2(pendingStyle, soFar);
            case 2:
                var maybeColor = action.a;
                if (!maybeColor.$) {
                    var newColor = maybeColor.a;
                    return _Utils_Tuple2(_Utils_update(pendingStyle, {
                        bi: $elm$core$Maybe$Just(newColor)
                    }), soFar);
                }
                else {
                    return _Utils_Tuple2($dillonkearns$elm_pages_v3_beta$TerminalText$blankStyle, soFar);
                }
            case 4:
                var bool = action.a;
                return _Utils_Tuple2(_Utils_update(pendingStyle, { d7: bool }), soFar);
            case 5:
                return _Utils_Tuple2(pendingStyle, soFar);
            case 6:
                return _Utils_Tuple2(pendingStyle, soFar);
            case 7:
                var bool = action.a;
                return _Utils_Tuple2(_Utils_update(pendingStyle, { e5: bool }), soFar);
            case 3:
                return _Utils_Tuple2(pendingStyle, soFar);
            case 12:
                if (soFar.b) {
                    var next = soFar.a;
                    var rest = soFar.b;
                    return _Utils_Tuple2(pendingStyle, _List_Cons($dillonkearns$elm_pages_v3_beta$TerminalText$Style_fn($dillonkearns$elm_pages_v3_beta$TerminalText$blankStyle, "\n"), _List_Cons(next, rest)));
                }
                else {
                    return _Utils_Tuple2(pendingStyle, soFar);
                }
            default:
                return _Utils_Tuple2(pendingStyle, soFar);
        }
    }, $dillonkearns$elm_pages_v3_beta$TerminalText$parseInto = F2($dillonkearns$elm_pages_v3_beta$TerminalText$parseInto_fn);
    var $elm$core$Tuple$second = function (_v0) {
        var y = _v0.b;
        return y;
    };
    var $dillonkearns$elm_pages_v3_beta$TerminalText$fromAnsiString = function (ansiString) {
        return $elm$core$List$reverse($vito$elm_ansi$Ansi$parseInto_fn(_Utils_Tuple2($dillonkearns$elm_pages_v3_beta$TerminalText$blankStyle, _List_Nil), $dillonkearns$elm_pages_v3_beta$TerminalText$parseInto, ansiString).b);
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Effect$NoEffect = { $: 0 };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$CompatibilityKey$currentCompatibilityKey = 13;
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$currentCompatibilityKey = $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$CompatibilityKey$currentCompatibilityKey;
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$StaticResponses$empty = function (a) {
        return $dillonkearns$elm_pages_v3_beta$BackendTask$succeed(a);
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$flagsDecoder = _Json_map3_fn(F3(function (staticHttpCache, isDevServer, compatibilityKey) {
        return { kP: compatibilityKey, b2: isDevServer, dU: staticHttpCache };
    }), $elm$json$Json$Decode$succeed($elm$json$Json$Encode$object(_List_Nil)), _Json_map1_fn(function (mode) {
        return mode === "dev-server";
    }, _Json_decodeField_fn("mode", $elm$json$Json$Decode$string)), _Json_decodeField_fn("compatibilityKey", $elm$json$Json$Decode$int));
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$ResponseSketch$HotUpdate_fn = function (a, b, c) {
        return { $: 1, a: a, b: b, c: c };
    }, $dillonkearns$elm_pages_v3_beta$Pages$Internal$ResponseSketch$HotUpdate = F3($dillonkearns$elm_pages_v3_beta$Pages$Internal$ResponseSketch$HotUpdate_fn);
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$NoMatchingRoute = { $: 0 };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$PageProgress = function (a) {
        return { $: 0, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$Flags$PreRenderFlags = { $: 1 };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$ResponseSketch$Redirect = function (a) {
        return { $: 2, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$SendApiResponse = function (a) {
        return { $: 1, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Effect$SendSinglePage = function (a) {
        return { $: 3, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Effect$SendSinglePageNew_fn = function (a, b) {
        return { $: 4, a: a, b: b };
    }, $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Effect$SendSinglePageNew = F2($dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Effect$SendSinglePageNew_fn);
    var $elm$core$Maybe$andThen_fn = function (callback, maybeValue) {
        if (!maybeValue.$) {
            var value = maybeValue.a;
            return callback(value);
        }
        else {
            return $elm$core$Maybe$Nothing;
        }
    }, $elm$core$Maybe$andThen = F2($elm$core$Maybe$andThen_fn);
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$bodyToString = function (body) {
        return $elm$core$String$join_fn("\n", $elm$core$List$map_fn($dillonkearns$elm_pages_v3_beta$HtmlPrinter$htmlToString($elm$core$Maybe$Nothing), body));
    };
    var $elm$bytes$Bytes$Encode$encode = _Bytes_encode;
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$ActionOnlyRequest = 1;
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$ActionResponseRequest = 0;
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$isActionDecoder = _Json_map1_fn(function (_v0) {
        var method = _v0.a;
        var headers = _v0.b;
        var _v1 = $elm$core$String$toUpper(method);
        switch (_v1) {
            case "GET":
                return $elm$core$Maybe$Nothing;
            case "OPTIONS":
                return $elm$core$Maybe$Nothing;
            default:
                var actionOnly = function () {
                    var _v2 = $elm$core$Dict$get_fn("elm-pages-action-only", headers);
                    if (!_v2.$) {
                        return true;
                    }
                    else {
                        return false;
                    }
                }();
                return $elm$core$Maybe$Just(actionOnly ? 1 : 0);
        }
    }, _Json_map2_fn($elm$core$Tuple$pair, _Json_decodeField_fn("method", $elm$json$Json$Decode$string), _Json_decodeField_fn("headers", $elm$json$Json$Decode$dict($elm$json$Json$Decode$string))));
    var $dillonkearns$elm_pages_v3_beta$BackendTask$map3_fn = function (combineFn, request1, request2, request3) {
        return $dillonkearns$elm_pages_v3_beta$BackendTask$map2_fn($elm$core$Basics$apR, request3, $dillonkearns$elm_pages_v3_beta$BackendTask$map2_fn($elm$core$Basics$apR, request2, $dillonkearns$elm_pages_v3_beta$BackendTask$map2_fn($elm$core$Basics$apR, request1, $dillonkearns$elm_pages_v3_beta$BackendTask$succeed(combineFn))));
    }, $dillonkearns$elm_pages_v3_beta$BackendTask$map3 = F4($dillonkearns$elm_pages_v3_beta$BackendTask$map3_fn);
    var $dillonkearns$elm_pages_v3_beta$RenderRequest$maybeRequestPayload = function (renderRequest) {
        var rawJson = renderRequest.c;
        return $elm$core$Maybe$Just(rawJson);
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$StaticResponses$Continue_fn = function (a, b) {
        return { $: 0, a: a, b: b };
    }, $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$StaticResponses$Continue = F2($dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$StaticResponses$Continue_fn);
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$StaticResponses$Finish = function (a) {
        return { $: 1, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$StaticResponses$FinishedWithErrors = function (a) {
        return { $: 2, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$StaticHttpRequest$Complete = function (a) {
        return { $: 2, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$StaticHttpRequest$Incomplete_fn = function (a, b) {
        return { $: 0, a: a, b: b };
    }, $dillonkearns$elm_pages_v3_beta$Pages$StaticHttpRequest$Incomplete = F2($dillonkearns$elm_pages_v3_beta$Pages$StaticHttpRequest$Incomplete_fn);
    var $dillonkearns$elm_pages_v3_beta$Pages$StaticHttpRequest$cacheRequestResolution_fn = function (request, rawResponses) {
        cacheRequestResolution: while (true) {
            if (!request.$) {
                var urlList = request.a;
                var lookupFn = request.b;
                if ($elm$core$List$isEmpty(urlList)) {
                    var $temp$request = A2(lookupFn, $elm$core$Maybe$Nothing, rawResponses), $temp$rawResponses = rawResponses;
                    request = $temp$request;
                    rawResponses = $temp$rawResponses;
                    continue cacheRequestResolution;
                }
                else {
                    return $dillonkearns$elm_pages_v3_beta$Pages$StaticHttpRequest$Incomplete_fn(urlList, $dillonkearns$elm_pages_v3_beta$Pages$StaticHttpRequest$Request_fn(_List_Nil, lookupFn));
                }
            }
            else {
                var value = request.a;
                return $dillonkearns$elm_pages_v3_beta$Pages$StaticHttpRequest$Complete(value);
            }
        }
    }, $dillonkearns$elm_pages_v3_beta$Pages$StaticHttpRequest$cacheRequestResolution = F2($dillonkearns$elm_pages_v3_beta$Pages$StaticHttpRequest$cacheRequestResolution_fn);
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$StaticHttpBody$encodeWithType_fn = function (typeName, otherFields) {
        return $elm$json$Json$Encode$object(_List_Cons(_Utils_Tuple2("type", $elm$json$Json$Encode$string(typeName)), otherFields));
    }, $dillonkearns$elm_pages_v3_beta$Pages$Internal$StaticHttpBody$encodeWithType = F2($dillonkearns$elm_pages_v3_beta$Pages$Internal$StaticHttpBody$encodeWithType_fn);
    var $elm$bytes$Bytes$Decode$decode_fn = function (_v0, bs) {
        var decoder = _v0;
        return _Bytes_decode_fn(decoder, bs);
    }, $elm$bytes$Bytes$Decode$decode = F2($elm$bytes$Bytes$Decode$decode_fn);
    var $elm$bytes$Bytes$Decode$loopHelp_fn = function (state, callback, bites, offset) {
        loopHelp: while (true) {
            var _v0 = callback(state);
            var decoder = _v0;
            var _v1 = A2(decoder, bites, offset);
            var newOffset = _v1.a;
            var step = _v1.b;
            if (!step.$) {
                var newState = step.a;
                var $temp$state = newState, $temp$callback = callback, $temp$bites = bites, $temp$offset = newOffset;
                state = $temp$state;
                callback = $temp$callback;
                bites = $temp$bites;
                offset = $temp$offset;
                continue loopHelp;
            }
            else {
                var result = step.a;
                return _Utils_Tuple2(newOffset, result);
            }
        }
    }, $elm$bytes$Bytes$Decode$loopHelp = F4($elm$bytes$Bytes$Decode$loopHelp_fn);
    var $elm$bytes$Bytes$Decode$loop_fn = function (state, callback) {
        return A2($elm$bytes$Bytes$Decode$loopHelp, state, callback);
    }, $elm$bytes$Bytes$Decode$loop = F2($elm$bytes$Bytes$Decode$loop_fn);
    var $elm$bytes$Bytes$Decode$Done = function (a) {
        return { $: 1, a: a };
    };
    var $elm$bytes$Bytes$Decode$Loop = function (a) {
        return { $: 0, a: a };
    };
    var $danfishgold$base64_bytes$Decode$lowest6BitsMask = 63;
    var $elm$core$Bitwise$shiftRightZfBy = _Bitwise_shiftRightZfBy;
    var $elm$core$Char$fromCode = _Char_fromCode;
    var $danfishgold$base64_bytes$Decode$unsafeToChar = function (n) {
        if (n <= 25) {
            return $elm$core$Char$fromCode(65 + n);
        }
        else {
            if (n <= 51) {
                return $elm$core$Char$fromCode(97 + (n - 26));
            }
            else {
                if (n <= 61) {
                    return $elm$core$Char$fromCode(48 + (n - 52));
                }
                else {
                    switch (n) {
                        case 62:
                            return "+";
                        case 63:
                            return "/";
                        default:
                            return "\0";
                    }
                }
            }
        }
    };
    var $danfishgold$base64_bytes$Decode$bitsToChars_fn = function (bits, missing) {
        var s = $danfishgold$base64_bytes$Decode$unsafeToChar(bits & $danfishgold$base64_bytes$Decode$lowest6BitsMask);
        var r = $danfishgold$base64_bytes$Decode$unsafeToChar((bits >>> 6) & $danfishgold$base64_bytes$Decode$lowest6BitsMask);
        var q = $danfishgold$base64_bytes$Decode$unsafeToChar((bits >>> 12) & $danfishgold$base64_bytes$Decode$lowest6BitsMask);
        var p = $danfishgold$base64_bytes$Decode$unsafeToChar(bits >>> 18);
        switch (missing) {
            case 0:
                return _String_cons_fn(p, _String_cons_fn(q, _String_cons_fn(r, $elm$core$String$fromChar(s))));
            case 1:
                return _String_cons_fn(p, _String_cons_fn(q, _String_cons_fn(r, "=")));
            case 2:
                return _String_cons_fn(p, _String_cons_fn(q, "=="));
            default:
                return "";
        }
    }, $danfishgold$base64_bytes$Decode$bitsToChars = F2($danfishgold$base64_bytes$Decode$bitsToChars_fn);
    var $danfishgold$base64_bytes$Decode$bitsToCharSpecialized_fn = function (bits1, bits2, bits3, accum) {
        var z = $danfishgold$base64_bytes$Decode$unsafeToChar((bits3 >>> 6) & $danfishgold$base64_bytes$Decode$lowest6BitsMask);
        var y = $danfishgold$base64_bytes$Decode$unsafeToChar((bits3 >>> 12) & $danfishgold$base64_bytes$Decode$lowest6BitsMask);
        var x = $danfishgold$base64_bytes$Decode$unsafeToChar(bits3 >>> 18);
        var w = $danfishgold$base64_bytes$Decode$unsafeToChar(bits3 & $danfishgold$base64_bytes$Decode$lowest6BitsMask);
        var s = $danfishgold$base64_bytes$Decode$unsafeToChar(bits1 & $danfishgold$base64_bytes$Decode$lowest6BitsMask);
        var r = $danfishgold$base64_bytes$Decode$unsafeToChar((bits1 >>> 6) & $danfishgold$base64_bytes$Decode$lowest6BitsMask);
        var q = $danfishgold$base64_bytes$Decode$unsafeToChar((bits1 >>> 12) & $danfishgold$base64_bytes$Decode$lowest6BitsMask);
        var p = $danfishgold$base64_bytes$Decode$unsafeToChar(bits1 >>> 18);
        var d = $danfishgold$base64_bytes$Decode$unsafeToChar(bits2 & $danfishgold$base64_bytes$Decode$lowest6BitsMask);
        var c = $danfishgold$base64_bytes$Decode$unsafeToChar((bits2 >>> 6) & $danfishgold$base64_bytes$Decode$lowest6BitsMask);
        var b = $danfishgold$base64_bytes$Decode$unsafeToChar((bits2 >>> 12) & $danfishgold$base64_bytes$Decode$lowest6BitsMask);
        var a = $danfishgold$base64_bytes$Decode$unsafeToChar(bits2 >>> 18);
        return _String_cons_fn(x, _String_cons_fn(y, _String_cons_fn(z, _String_cons_fn(w, _String_cons_fn(a, _String_cons_fn(b, _String_cons_fn(c, _String_cons_fn(d, _String_cons_fn(p, _String_cons_fn(q, _String_cons_fn(r, _String_cons_fn(s, accum))))))))))));
    }, $danfishgold$base64_bytes$Decode$bitsToCharSpecialized = F4($danfishgold$base64_bytes$Decode$bitsToCharSpecialized_fn);
    var $elm$core$Bitwise$or = _Bitwise_or;
    var $elm$core$Bitwise$shiftLeftBy = _Bitwise_shiftLeftBy;
    var $danfishgold$base64_bytes$Decode$decode18Help_fn = function (a, b, c, d, e) {
        var combined6 = ((255 & d) << 16) | e;
        var combined5 = d >>> 8;
        var combined4 = 16777215 & c;
        var combined3 = ((65535 & b) << 8) | (c >>> 24);
        var combined2 = ((255 & a) << 16) | (b >>> 16);
        var combined1 = a >>> 8;
        return $danfishgold$base64_bytes$Decode$bitsToCharSpecialized_fn(combined3, combined2, combined1, $danfishgold$base64_bytes$Decode$bitsToCharSpecialized_fn(combined6, combined5, combined4, ""));
    }, $danfishgold$base64_bytes$Decode$decode18Help = F5($danfishgold$base64_bytes$Decode$decode18Help_fn);
    var $elm$bytes$Bytes$Decode$map5_fn = function (func, _v0, _v1, _v2, _v3, _v4) {
        var decodeA = _v0;
        var decodeB = _v1;
        var decodeC = _v2;
        var decodeD = _v3;
        var decodeE = _v4;
        return F2(function (bites, offset) {
            var _v5 = A2(decodeA, bites, offset);
            var aOffset = _v5.a;
            var a = _v5.b;
            var _v6 = A2(decodeB, bites, aOffset);
            var bOffset = _v6.a;
            var b = _v6.b;
            var _v7 = A2(decodeC, bites, bOffset);
            var cOffset = _v7.a;
            var c = _v7.b;
            var _v8 = A2(decodeD, bites, cOffset);
            var dOffset = _v8.a;
            var d = _v8.b;
            var _v9 = A2(decodeE, bites, dOffset);
            var eOffset = _v9.a;
            var e = _v9.b;
            return _Utils_Tuple2(eOffset, A5(func, a, b, c, d, e));
        });
    }, $elm$bytes$Bytes$Decode$map5_fn_unwrapped = function (func, _v0, _v1, _v2, _v3, _v4) {
        var decodeA = _v0;
        var decodeB = _v1;
        var decodeC = _v2;
        var decodeD = _v3;
        var decodeE = _v4;
        return F2(function (bites, offset) {
            var _v5 = A2(decodeA, bites, offset);
            var aOffset = _v5.a;
            var a = _v5.b;
            var _v6 = A2(decodeB, bites, aOffset);
            var bOffset = _v6.a;
            var b = _v6.b;
            var _v7 = A2(decodeC, bites, bOffset);
            var cOffset = _v7.a;
            var c = _v7.b;
            var _v8 = A2(decodeD, bites, cOffset);
            var dOffset = _v8.a;
            var d = _v8.b;
            var _v9 = A2(decodeE, bites, dOffset);
            var eOffset = _v9.a;
            var e = _v9.b;
            return _Utils_Tuple2(eOffset, func(a, b, c, d, e));
        });
    }, $elm$bytes$Bytes$Decode$map5 = F6($elm$bytes$Bytes$Decode$map5_fn);
    var $elm$bytes$Bytes$BE = 1;
    var $elm$bytes$Bytes$Decode$unsignedInt16 = function (endianness) {
        return _Bytes_read_u16(!endianness);
    };
    var $danfishgold$base64_bytes$Decode$u16BE = $elm$bytes$Bytes$Decode$unsignedInt16(1);
    var $elm$bytes$Bytes$Decode$unsignedInt32 = function (endianness) {
        return _Bytes_read_u32(!endianness);
    };
    var $danfishgold$base64_bytes$Decode$u32BE = $elm$bytes$Bytes$Decode$unsignedInt32(1);
    var $danfishgold$base64_bytes$Decode$decode18Bytes = $elm$bytes$Bytes$Decode$map5_fn($danfishgold$base64_bytes$Decode$decode18Help, $danfishgold$base64_bytes$Decode$u32BE, $danfishgold$base64_bytes$Decode$u32BE, $danfishgold$base64_bytes$Decode$u32BE, $danfishgold$base64_bytes$Decode$u32BE, $danfishgold$base64_bytes$Decode$u16BE);
    var $elm$bytes$Bytes$Decode$map2_fn = function (func, _v0, _v1) {
        var decodeA = _v0;
        var decodeB = _v1;
        return F2(function (bites, offset) {
            var _v2 = A2(decodeA, bites, offset);
            var aOffset = _v2.a;
            var a = _v2.b;
            var _v3 = A2(decodeB, bites, aOffset);
            var bOffset = _v3.a;
            var b = _v3.b;
            return _Utils_Tuple2(bOffset, A2(func, a, b));
        });
    }, $elm$bytes$Bytes$Decode$map2_fn_unwrapped = function (func, _v0, _v1) {
        var decodeA = _v0;
        var decodeB = _v1;
        return F2(function (bites, offset) {
            var _v2 = A2(decodeA, bites, offset);
            var aOffset = _v2.a;
            var a = _v2.b;
            var _v3 = A2(decodeB, bites, aOffset);
            var bOffset = _v3.a;
            var b = _v3.b;
            return _Utils_Tuple2(bOffset, func(a, b));
        });
    }, $elm$bytes$Bytes$Decode$map2 = F3($elm$bytes$Bytes$Decode$map2_fn);
    var $elm$bytes$Bytes$Decode$map3_fn = function (func, _v0, _v1, _v2) {
        var decodeA = _v0;
        var decodeB = _v1;
        var decodeC = _v2;
        return F2(function (bites, offset) {
            var _v3 = A2(decodeA, bites, offset);
            var aOffset = _v3.a;
            var a = _v3.b;
            var _v4 = A2(decodeB, bites, aOffset);
            var bOffset = _v4.a;
            var b = _v4.b;
            var _v5 = A2(decodeC, bites, bOffset);
            var cOffset = _v5.a;
            var c = _v5.b;
            return _Utils_Tuple2(cOffset, A3(func, a, b, c));
        });
    }, $elm$bytes$Bytes$Decode$map3_fn_unwrapped = function (func, _v0, _v1, _v2) {
        var decodeA = _v0;
        var decodeB = _v1;
        var decodeC = _v2;
        return F2(function (bites, offset) {
            var _v3 = A2(decodeA, bites, offset);
            var aOffset = _v3.a;
            var a = _v3.b;
            var _v4 = A2(decodeB, bites, aOffset);
            var bOffset = _v4.a;
            var b = _v4.b;
            var _v5 = A2(decodeC, bites, bOffset);
            var cOffset = _v5.a;
            var c = _v5.b;
            return _Utils_Tuple2(cOffset, func(a, b, c));
        });
    }, $elm$bytes$Bytes$Decode$map3 = F4($elm$bytes$Bytes$Decode$map3_fn);
    var $elm$bytes$Bytes$Decode$unsignedInt8 = _Bytes_read_u8;
    var $danfishgold$base64_bytes$Decode$loopHelp = function (_v0) {
        var string = _v0.jx;
        var remaining = _v0.jm;
        if (remaining >= 18) {
            return $elm$bytes$Bytes$Decode$map_fn(function (result) {
                return $elm$bytes$Bytes$Decode$Loop({
                    jm: remaining - 18,
                    jx: _Utils_ap(string, result)
                });
            }, $danfishgold$base64_bytes$Decode$decode18Bytes);
        }
        else {
            if (remaining >= 3) {
                var helper = F3(function (a, b, c) {
                    var combined = ((a << 16) | (b << 8)) | c;
                    return $elm$bytes$Bytes$Decode$Loop({
                        jm: remaining - 3,
                        jx: _Utils_ap(string, $danfishgold$base64_bytes$Decode$bitsToChars_fn(combined, 0))
                    });
                });
                return $elm$bytes$Bytes$Decode$map3_fn(helper, $elm$bytes$Bytes$Decode$unsignedInt8, $elm$bytes$Bytes$Decode$unsignedInt8, $elm$bytes$Bytes$Decode$unsignedInt8);
            }
            else {
                if (!remaining) {
                    return $elm$bytes$Bytes$Decode$succeed($elm$bytes$Bytes$Decode$Done(string));
                }
                else {
                    if (remaining === 2) {
                        var helper = F2(function (a, b) {
                            var combined = (a << 16) | (b << 8);
                            return $elm$bytes$Bytes$Decode$Done(_Utils_ap(string, $danfishgold$base64_bytes$Decode$bitsToChars_fn(combined, 1)));
                        });
                        return $elm$bytes$Bytes$Decode$map2_fn(helper, $elm$bytes$Bytes$Decode$unsignedInt8, $elm$bytes$Bytes$Decode$unsignedInt8);
                    }
                    else {
                        return $elm$bytes$Bytes$Decode$map_fn(function (a) {
                            return $elm$bytes$Bytes$Decode$Done(_Utils_ap(string, $danfishgold$base64_bytes$Decode$bitsToChars_fn(a << 16, 2)));
                        }, $elm$bytes$Bytes$Decode$unsignedInt8);
                    }
                }
            }
        }
    };
    var $danfishgold$base64_bytes$Decode$decoder = function (width) {
        return $elm$bytes$Bytes$Decode$loop_fn({ jm: width, jx: "" }, $danfishgold$base64_bytes$Decode$loopHelp);
    };
    var $elm$bytes$Bytes$width = _Bytes_width;
    var $danfishgold$base64_bytes$Decode$fromBytes = function (bytes) {
        return $elm$bytes$Bytes$Decode$decode_fn($danfishgold$base64_bytes$Decode$decoder($elm$bytes$Bytes$width(bytes)), bytes);
    };
    var $danfishgold$base64_bytes$Base64$fromBytes = $danfishgold$base64_bytes$Decode$fromBytes;
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$StaticHttpBody$encode = function (body) {
        switch (body.$) {
            case 0:
                return $dillonkearns$elm_pages_v3_beta$Pages$Internal$StaticHttpBody$encodeWithType_fn("empty", _List_Nil);
            case 1:
                var content = body.b;
                return $dillonkearns$elm_pages_v3_beta$Pages$Internal$StaticHttpBody$encodeWithType_fn("string", _List_fromArray([
                    _Utils_Tuple2("content", $elm$json$Json$Encode$string(content))
                ]));
            case 2:
                var content = body.a;
                return $dillonkearns$elm_pages_v3_beta$Pages$Internal$StaticHttpBody$encodeWithType_fn("json", _List_fromArray([
                    _Utils_Tuple2("content", content)
                ]));
            default:
                var content = body.b;
                return $dillonkearns$elm_pages_v3_beta$Pages$Internal$StaticHttpBody$encodeWithType_fn("bytes", _List_fromArray([
                    _Utils_Tuple2("content", $elm$json$Json$Encode$string($elm$core$Maybe$withDefault_fn("", $danfishgold$base64_bytes$Base64$fromBytes(content))))
                ]));
        }
    };
    var $elm$core$String$foldl = _String_foldl;
    var $elm$core$Bitwise$xor = _Bitwise_xor;
    var $robinheghan$fnv1a$FNV1a$hasher_fn = function (_byte, hashValue) {
        var mixed = _byte ^ hashValue;
        return ((((mixed + (mixed << 1)) + (mixed << 4)) + (mixed << 7)) + (mixed << 8)) + (mixed << 24);
    }, $robinheghan$fnv1a$FNV1a$hasher = F2($robinheghan$fnv1a$FNV1a$hasher_fn);
    var $robinheghan$fnv1a$FNV1a$utf32ToUtf8_fn = function (_char, acc) {
        var _byte = $elm$core$Char$toCode(_char);
        return (_byte < 128) ? $robinheghan$fnv1a$FNV1a$hasher_fn(_byte, acc) : ((_byte < 2048) ? $robinheghan$fnv1a$FNV1a$hasher_fn(128 | (63 & _byte), $robinheghan$fnv1a$FNV1a$hasher_fn(192 | (_byte >>> 6), acc)) : ((_byte < 65536) ? $robinheghan$fnv1a$FNV1a$hasher_fn(128 | (63 & _byte), $robinheghan$fnv1a$FNV1a$hasher_fn(128 | (63 & (_byte >>> 6)), $robinheghan$fnv1a$FNV1a$hasher_fn(224 | (_byte >>> 12), acc))) : $robinheghan$fnv1a$FNV1a$hasher_fn(128 | (63 & _byte), $robinheghan$fnv1a$FNV1a$hasher_fn(128 | (63 & (_byte >>> 6)), $robinheghan$fnv1a$FNV1a$hasher_fn(128 | (63 & (_byte >>> 12)), $robinheghan$fnv1a$FNV1a$hasher_fn(240 | (_byte >>> 18), acc))))));
    }, $robinheghan$fnv1a$FNV1a$utf32ToUtf8 = F2($robinheghan$fnv1a$FNV1a$utf32ToUtf8_fn);
    var $robinheghan$fnv1a$FNV1a$hashWithSeed_fn = function (str, seed) {
        return _String_foldl_fn($robinheghan$fnv1a$FNV1a$utf32ToUtf8, seed, str) >>> 0;
    }, $robinheghan$fnv1a$FNV1a$hashWithSeed = F2($robinheghan$fnv1a$FNV1a$hashWithSeed_fn);
    var $robinheghan$fnv1a$FNV1a$initialSeed = 2166136261;
    var $robinheghan$fnv1a$FNV1a$hash = function (str) {
        return $robinheghan$fnv1a$FNV1a$hashWithSeed_fn(str, $robinheghan$fnv1a$FNV1a$initialSeed);
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$StaticHttp$Request$hashHeader = function (_v0) {
        var name = _v0.a;
        var value = _v0.b;
        return $elm$json$Json$Encode$string(name + (": " + value));
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$StaticHttp$Request$hash = function (requestDetails) {
        return $elm$core$String$fromInt($robinheghan$fnv1a$FNV1a$hash(_Json_encode_fn(0, $elm$json$Json$Encode$object(_List_fromArray([
            _Utils_Tuple2("method", $elm$json$Json$Encode$string(requestDetails.nh)),
            _Utils_Tuple2("url", $elm$json$Json$Encode$string(requestDetails.lO)),
            _Utils_Tuple2("headers", $elm$json$Json$Encode$list_fn($dillonkearns$elm_pages_v3_beta$Pages$StaticHttp$Request$hashHeader, requestDetails.mS)),
            _Utils_Tuple2("body", $dillonkearns$elm_pages_v3_beta$Pages$Internal$StaticHttpBody$encode(requestDetails.hJ))
        ])))));
    };
    var $dillonkearns$elm_pages_v3_beta$TerminalText$text = function (value) {
        return $dillonkearns$elm_pages_v3_beta$TerminalText$Style_fn($dillonkearns$elm_pages_v3_beta$TerminalText$blankStyle, value);
    };
    var $dillonkearns$elm_pages_v3_beta$BuildError$internal = function (string) {
        return {
            mE: true,
            eI: _List_fromArray([
                $dillonkearns$elm_pages_v3_beta$TerminalText$text(string)
            ]),
            nM: "",
            jE: "Internal Error"
        };
    };
    var $elm$core$List$singleton = function (value) {
        return _List_fromArray([value]);
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$StaticHttpRequest$toBuildError_fn = function (path, error) {
        if (!error.$) {
            var decodeErrorMessage = error.a;
            return {
                mE: true,
                eI: _List_fromArray([
                    $dillonkearns$elm_pages_v3_beta$TerminalText$text(decodeErrorMessage)
                ]),
                nM: path,
                jE: "Static Http Decoding Error"
            };
        }
        else {
            var decodeErrorMessage = error.a;
            return {
                mE: true,
                eI: _List_fromArray([
                    $dillonkearns$elm_pages_v3_beta$TerminalText$text("I ran into a call to `BackendTask.fail` with message: " + decodeErrorMessage)
                ]),
                nM: path,
                jE: "Called Static Http Fail"
            };
        }
    }, $dillonkearns$elm_pages_v3_beta$Pages$StaticHttpRequest$toBuildError = F2($dillonkearns$elm_pages_v3_beta$Pages$StaticHttpRequest$toBuildError_fn);
    var $elm_community$list_extra$List$Extra$uniqueHelp_fn = function (f, existing, remaining, accumulator) {
        uniqueHelp: while (true) {
            if (!remaining.b) {
                return $elm$core$List$reverse(accumulator);
            }
            else {
                var first = remaining.a;
                var rest = remaining.b;
                var computedFirst = f(first);
                if ($elm$core$List$member_fn(computedFirst, existing)) {
                    var $temp$f = f, $temp$existing = existing, $temp$remaining = rest, $temp$accumulator = accumulator;
                    f = $temp$f;
                    existing = $temp$existing;
                    remaining = $temp$remaining;
                    accumulator = $temp$accumulator;
                    continue uniqueHelp;
                }
                else {
                    var $temp$f = f, $temp$existing = _List_Cons(computedFirst, existing), $temp$remaining = rest, $temp$accumulator = _List_Cons(first, accumulator);
                    f = $temp$f;
                    existing = $temp$existing;
                    remaining = $temp$remaining;
                    accumulator = $temp$accumulator;
                    continue uniqueHelp;
                }
            }
        }
    }, $elm_community$list_extra$List$Extra$uniqueHelp = F4($elm_community$list_extra$List$Extra$uniqueHelp_fn);
    var $elm_community$list_extra$List$Extra$uniqueBy_fn = function (f, list) {
        return $elm_community$list_extra$List$Extra$uniqueHelp_fn(f, _List_Nil, list, _List_Nil);
    }, $elm_community$list_extra$List$Extra$uniqueBy = F2($elm_community$list_extra$List$Extra$uniqueBy_fn);
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$StaticResponses$nextStep_fn = function (allRawResponses, staticResponses, _v0) {
        var errors = _v0.fk;
        var staticRequestsStatus = $dillonkearns$elm_pages_v3_beta$Pages$StaticHttpRequest$cacheRequestResolution_fn(staticResponses, allRawResponses);
        var _v1 = function () {
            switch (staticRequestsStatus.$) {
                case 0:
                    var newUrlsToFetch = staticRequestsStatus.a;
                    var nextReq = staticRequestsStatus.b;
                    return _Utils_Tuple3(_Utils_Tuple2(true, $elm$core$Maybe$Nothing), newUrlsToFetch, nextReq);
                case 2:
                    if (staticRequestsStatus.a.$ === 1) {
                        var error = staticRequestsStatus.a.a;
                        return _Utils_Tuple3(_Utils_Tuple2(false, $elm$core$Maybe$Just($elm$core$Result$Err(error))), _List_Nil, $dillonkearns$elm_pages_v3_beta$BackendTask$fail(error));
                    }
                    else {
                        var value = staticRequestsStatus.a.a;
                        return _Utils_Tuple3(_Utils_Tuple2(false, $elm$core$Maybe$Just($elm$core$Result$Ok(value))), _List_Nil, $dillonkearns$elm_pages_v3_beta$BackendTask$succeed(value));
                    }
                default:
                    return _Utils_Tuple3(_Utils_Tuple2(false, $elm$core$Maybe$Nothing), _List_Nil, $dillonkearns$elm_pages_v3_beta$BackendTask$fail($dillonkearns$elm_pages_v3_beta$FatalError$fromString("TODO this shouldn't happen")));
            }
        }();
        var _v2 = _v1.a;
        var pendingRequests = _v2.a;
        var completedValue = _v2.b;
        var urlsToPerform = _v1.b;
        var progressedBackendTask = _v1.c;
        if (pendingRequests) {
            var newThing = $elm_community$list_extra$List$Extra$uniqueBy_fn($dillonkearns$elm_pages_v3_beta$Pages$StaticHttp$Request$hash, urlsToPerform);
            return $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$StaticResponses$Continue_fn(newThing, progressedBackendTask);
        }
        else {
            var allErrors = function () {
                var failedRequests = function () {
                    var maybePermanentError = function () {
                        if (staticRequestsStatus.$ === 1) {
                            var theError = staticRequestsStatus.a;
                            return $elm$core$Maybe$Just(theError);
                        }
                        else {
                            return $elm$core$Maybe$Nothing;
                        }
                    }();
                    var decoderErrors = $elm$core$Maybe$withDefault_fn(_List_Nil, $elm$core$Maybe$map_fn($elm$core$List$singleton, $elm$core$Maybe$map_fn($dillonkearns$elm_pages_v3_beta$Pages$StaticHttpRequest$toBuildError("TODO PATH"), maybePermanentError)));
                    return decoderErrors;
                }();
                return _Utils_ap(errors, failedRequests);
            }();
            if ($elm$core$List$length(allErrors) > 0) {
                return $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$StaticResponses$FinishedWithErrors(allErrors);
            }
            else {
                if (!completedValue.$) {
                    if (!completedValue.a.$) {
                        var completed = completedValue.a.a;
                        return $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$StaticResponses$Finish(completed);
                    }
                    else {
                        var buildError = completedValue.a.a;
                        return $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$StaticResponses$FinishedWithErrors(_List_fromArray([
                            {
                                mE: true,
                                eI: $dillonkearns$elm_pages_v3_beta$TerminalText$fromAnsiString(buildError.hJ),
                                nM: "",
                                jE: $elm$core$String$toUpper(buildError.jE)
                            }
                        ]));
                    }
                }
                else {
                    return $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$StaticResponses$FinishedWithErrors(_List_fromArray([
                        $dillonkearns$elm_pages_v3_beta$BuildError$internal("TODO error message")
                    ]));
                }
            }
        }
    }, $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$StaticResponses$nextStep = F3($dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$StaticResponses$nextStep_fn);
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$Errors = function (a) {
        return { $: 4, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Effect$FetchHttp = function (a) {
        return { $: 1, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$nextStepToEffect_fn = function (model, nextStep) {
        switch (nextStep.$) {
            case 0:
                var httpRequests = nextStep.a;
                var updatedStaticResponsesModel = nextStep.b;
                return _Utils_Tuple2(_Utils_update(model, { bR: updatedStaticResponsesModel }), $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Effect$FetchHttp(httpRequests));
            case 2:
                var errors = nextStep.a;
                return _Utils_Tuple2(model, $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Effect$SendSinglePage($dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$Errors(errors)));
            default:
                var finalValue = nextStep.a;
                return _Utils_Tuple2(model, finalValue);
        }
    }, $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$nextStepToEffect = F2($dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$nextStepToEffect_fn);
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$ResponseSketch$NotFound = function (a) {
        return { $: 3, a: a };
    };
    var $elm$html$Html$br = _VirtualDom_nodeNS_fn(_VirtualDom_node_a0, "br"), $elm$html$Html$br_fn = $elm$html$Html$br.a2;
    var $elm$html$Html$code = _VirtualDom_nodeNS_fn(_VirtualDom_node_a0, "code"), $elm$html$Html$code_fn = $elm$html$Html$code.a2;
    var $elm$html$Html$div = _VirtualDom_nodeNS_fn(_VirtualDom_node_a0, "div"), $elm$html$Html$div_fn = $elm$html$Html$div.a2;
    var $elm$html$Html$h1 = _VirtualDom_nodeNS_fn(_VirtualDom_node_a0, "h1"), $elm$html$Html$h1_fn = $elm$html$Html$h1.a2;
    var $elm$html$Html$Attributes$stringProperty_fn = function (key, string) {
        return _VirtualDom_property_fn(key, $elm$json$Json$Encode$string(string));
    }, $elm$html$Html$Attributes$stringProperty = F2($elm$html$Html$Attributes$stringProperty_fn);
    var $elm$html$Html$Attributes$id_a0 = "id", $elm$html$Html$Attributes$id = $elm$html$Html$Attributes$stringProperty($elm$html$Html$Attributes$id_a0);
    var $elm$html$Html$li = _VirtualDom_nodeNS_fn(_VirtualDom_node_a0, "li"), $elm$html$Html$li_fn = $elm$html$Html$li.a2;
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$moduleName = function (moduleContext) {
        return $elm$core$String$join_fn("/", _List_Cons("src", moduleContext.fC)) + ".elm";
    };
    var $elm$html$Html$p = _VirtualDom_nodeNS_fn(_VirtualDom_node_a0, "p"), $elm$html$Html$p_fn = $elm$html$Html$p.a2;
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$recordToString = function (fields) {
        return "{ " + ($elm$core$String$join_fn(", ", $elm$core$List$map_fn(function (_v0) {
            var key = _v0.a;
            var value = _v0.b;
            return key + (" = " + value);
        }, fields)) + " }");
    };
    var $elm$virtual_dom$VirtualDom$style = _VirtualDom_style;
    var $elm$html$Html$Attributes$style = $elm$virtual_dom$VirtualDom$style;
    var $elm$html$Html$ul = _VirtualDom_nodeNS_fn(_VirtualDom_node_a0, "ul"), $elm$html$Html$ul_fn = $elm$html$Html$ul.a2;
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$prerenderedOptionsView_fn = function (moduleContext, routes) {
        if (!routes.b) {
            return $elm$html$Html$div_fn(_List_Nil, _List_fromArray([
                $elm$html$Html$br_fn(_List_Nil, _List_Nil),
                $elm$html$Html$text("But this Page module has no pre-rendered routes! If you want to pre-render this page, add these "),
                $elm$html$Html$code_fn(_List_Nil, _List_fromArray([
                    $elm$html$Html$text("RouteParams")
                ])),
                $elm$html$Html$text(" to the module's "),
                $elm$html$Html$code_fn(_List_Nil, _List_fromArray([
                    $elm$html$Html$text("routes")
                ])),
                $elm$html$Html$br_fn(_List_Nil, _List_Nil),
                $elm$html$Html$br_fn(_List_Nil, _List_Nil),
                $elm$html$Html$code_fn(_List_fromArray([
                    _VirtualDom_style_fn("border-bottom", "dotted 2px"),
                    _VirtualDom_style_fn("font-weight", "bold")
                ]), _List_fromArray([
                    $elm$html$Html$text($dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$recordToString(moduleContext.nf))
                ]))
            ]));
        }
        else {
            return $elm$html$Html$div_fn(_List_Nil, _List_fromArray([
                $elm$html$Html$br_fn(_List_Nil, _List_Nil),
                $elm$html$Html$br_fn(_List_Nil, _List_Nil),
                $elm$html$Html$text(" but these RouteParams were not present "),
                $elm$html$Html$br_fn(_List_Nil, _List_Nil),
                $elm$html$Html$br_fn(_List_Nil, _List_Nil),
                $elm$html$Html$code_fn(_List_fromArray([
                    _VirtualDom_style_fn("border-bottom", "dotted 2px"),
                    _VirtualDom_style_fn("font-weight", "bold")
                ]), _List_fromArray([
                    $elm$html$Html$text($dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$recordToString(moduleContext.nf))
                ])),
                $elm$html$Html$br_fn(_List_Nil, _List_Nil),
                $elm$html$Html$br_fn(_List_Nil, _List_Nil),
                $elm$html$Html$text("The following RouteParams are pre-rendered:"),
                $elm$html$Html$ul_fn(_List_fromArray([
                    _VirtualDom_style_fn("padding-top", "30px")
                ]), $elm$core$List$map_fn(function (record) {
                    return $elm$html$Html$li_fn(_List_fromArray([
                        _VirtualDom_style_fn("list-style", "inside")
                    ]), _List_fromArray([
                        $elm$html$Html$code_fn(_List_Nil, _List_fromArray([
                            $elm$html$Html$text($dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$recordToString(record))
                        ]))
                    ]));
                }, routes)),
                $elm$html$Html$br_fn(_List_Nil, _List_Nil),
                $elm$html$Html$br_fn(_List_Nil, _List_Nil),
                $elm$html$Html$p_fn(_List_Nil, _List_fromArray([
                    $elm$html$Html$text("Try changing "),
                    $elm$html$Html$code_fn(_List_Nil, _List_fromArray([
                        $elm$html$Html$text("routes")
                    ])),
                    $elm$html$Html$text(" in "),
                    $elm$html$Html$code_fn(_List_Nil, _List_fromArray([
                        $elm$html$Html$text($dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$moduleName(moduleContext))
                    ])),
                    $elm$html$Html$text(" to make sure it includes these "),
                    $elm$html$Html$code_fn(_List_Nil, _List_fromArray([
                        $elm$html$Html$text("RouteParams")
                    ])),
                    $elm$html$Html$text(".")
                ]))
            ]));
        }
    }, $dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$prerenderedOptionsView = F2($dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$prerenderedOptionsView_fn);
    var $dillonkearns$elm_pages_v3_beta$Path$toRelative = function (parts) {
        return $elm$core$String$join_fn("/", $dillonkearns$elm_pages_v3_beta$Path$join(parts));
    };
    var $dillonkearns$elm_pages_v3_beta$Path$toAbsolute = function (path) {
        return "/" + $dillonkearns$elm_pages_v3_beta$Path$toRelative(path);
    };
    var $elm$html$Html$span = _VirtualDom_nodeNS_fn(_VirtualDom_node_a0, "span"), $elm$html$Html$span_fn = $elm$html$Html$span.a2;
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$segmentToString = function (segment) {
        if (!segment.$) {
            var string = segment.a;
            return string;
        }
        else {
            var name = segment.a;
            return ":" + name;
        }
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$toString_ = function (segments) {
        return "/" + $elm$core$String$join_fn("/", $elm$core$List$map_fn($dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$segmentToString, segments));
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$view = function (routePattern) {
        return $elm$html$Html$span_fn(_List_Nil, function () {
            var _v0 = routePattern.bn;
            if (_v0.$ === 1) {
                return _List_fromArray([
                    $elm$html$Html$code_fn(_List_Nil, _List_fromArray([
                        $elm$html$Html$text($dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$toString_(routePattern.bI))
                    ]))
                ]);
            }
            else {
                switch (_v0.a.$) {
                    case 0:
                        var optionalName = _v0.a.a;
                        return _List_fromArray([
                            $elm$html$Html$code_fn(_List_Nil, _List_fromArray([
                                $elm$html$Html$text($dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$toString_(routePattern.bI))
                            ])),
                            $elm$html$Html$text(" or "),
                            $elm$html$Html$code_fn(_List_Nil, _List_fromArray([
                                $elm$html$Html$text($dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$toString_(routePattern.bI) + ("/:" + optionalName))
                            ]))
                        ]);
                    case 1:
                        var _v1 = _v0.a;
                        return _List_fromArray([
                            $elm$html$Html$code_fn(_List_Nil, _List_fromArray([
                                $elm$html$Html$text($dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$toString_(routePattern.bI))
                            ]))
                        ]);
                    default:
                        var _v2 = _v0.a;
                        return _List_fromArray([
                            $elm$html$Html$code_fn(_List_Nil, _List_fromArray([
                                $elm$html$Html$text($dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$toString_(routePattern.bI))
                            ]))
                        ]);
                }
            }
        }());
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$document_fn = function (pathPatterns, payload) {
        return {
            hJ: _List_fromArray([
                $elm$html$Html$div_fn(_List_fromArray([
                    $elm$html$Html$Attributes$stringProperty_fn($elm$html$Html$Attributes$id_a0, "not-found-reason"),
                    _VirtualDom_style_fn("padding", "30px")
                ]), function () {
                    var _v0 = payload.g0;
                    switch (_v0.$) {
                        case 0:
                            return _List_fromArray([
                                $elm$html$Html$text("No route found for "),
                                $elm$html$Html$code_fn(_List_Nil, _List_fromArray([
                                    $elm$html$Html$text($dillonkearns$elm_pages_v3_beta$Path$toAbsolute(payload.nM))
                                ])),
                                $elm$html$Html$text(" Did you mean to go to one of these routes:"),
                                $elm$html$Html$ul_fn(_List_fromArray([
                                    _VirtualDom_style_fn("padding-top", "30px")
                                ]), $elm$core$List$map_fn(function (route) {
                                    return $elm$html$Html$li_fn(_List_fromArray([
                                        _VirtualDom_style_fn("list-style", "inside")
                                    ]), _List_fromArray([
                                        $dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$view(route)
                                    ]));
                                }, pathPatterns))
                            ]);
                        case 1:
                            var moduleContext = _v0.a;
                            var routes = _v0.b;
                            return _List_fromArray([
                                $elm$html$Html$h1_fn(_List_Nil, _List_fromArray([
                                    $elm$html$Html$text("Page Not Found")
                                ])),
                                $elm$html$Html$code_fn(_List_Nil, _List_fromArray([
                                    $elm$html$Html$text($dillonkearns$elm_pages_v3_beta$Path$toAbsolute(payload.nM))
                                ])),
                                $elm$html$Html$text(" successfully matched the route "),
                                $elm$html$Html$br_fn(_List_Nil, _List_Nil),
                                $elm$html$Html$br_fn(_List_Nil, _List_Nil),
                                $elm$html$Html$code_fn(_List_Nil, _List_fromArray([
                                    $dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$view(moduleContext.fM)
                                ])),
                                $elm$html$Html$br_fn(_List_Nil, _List_Nil),
                                $elm$html$Html$br_fn(_List_Nil, _List_Nil),
                                $elm$html$Html$text(" from the Route Module "),
                                $elm$html$Html$br_fn(_List_Nil, _List_Nil),
                                $elm$html$Html$br_fn(_List_Nil, _List_Nil),
                                $elm$html$Html$code_fn(_List_Nil, _List_fromArray([
                                    $elm$html$Html$text($dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$moduleName(moduleContext))
                                ])),
                                $dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$prerenderedOptionsView_fn(moduleContext, routes)
                            ]);
                        default:
                            return _List_fromArray([
                                $elm$html$Html$text("Page not found"),
                                $elm$html$Html$text("TODO")
                            ]);
                    }
                }())
            ]),
            jE: "Page not found"
        };
    }, $dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$document = F2($dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$document_fn);
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$render404Page_fn = function (config, sharedData, isDevServer, path, notFoundReason) {
        var _v0 = _Utils_Tuple2(isDevServer, sharedData);
        if ((!_v0.a) && (!_v0.b.$)) {
            var justSharedData = _v0.b.a;
            var pathAndRoute = { nM: path, n4: config.nA };
            var pageData = config.my(config.nz);
            var pageModel = A5(config.dI, $dillonkearns$elm_pages_v3_beta$Pages$Flags$PreRenderFlags, justSharedData, pageData, $elm$core$Maybe$Nothing, $elm$core$Maybe$Nothing).a;
            var viewValue = A8(config.X, $elm$core$Dict$empty, $elm$core$Dict$empty, $elm$core$Maybe$Nothing, pathAndRoute, $elm$core$Maybe$Nothing, justSharedData, pageData, $elm$core$Maybe$Nothing).X(pageModel);
            var byteEncodedPageData = $elm$bytes$Bytes$Encode$encode(config.mw($dillonkearns$elm_pages_v3_beta$Pages$Internal$ResponseSketch$HotUpdate_fn(config.my(config.nz), justSharedData, $elm$core$Maybe$Nothing)));
            return $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Effect$SendSinglePageNew_fn(byteEncodedPageData, $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$PageProgress({
                f9: $elm$core$Dict$empty,
                fk: _List_Nil,
                aL: A8(config.X, $elm$core$Dict$empty, $elm$core$Dict$empty, $elm$core$Maybe$Nothing, pathAndRoute, $elm$core$Maybe$Nothing, justSharedData, pageData, $elm$core$Maybe$Nothing).aL,
                mS: _List_Nil,
                gw: $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$bodyToString(viewValue.hJ),
                gC: true,
                n4: $dillonkearns$elm_pages_v3_beta$Path$toAbsolute(path),
                dU: $elm$core$Dict$empty,
                aF: 404,
                jE: viewValue.jE
            }));
        }
        else {
            var notFoundDocument = $dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$document_fn(config.nN, { nM: path, g0: notFoundReason });
            var byteEncodedPageData = $elm$bytes$Bytes$Encode$encode(config.mw($dillonkearns$elm_pages_v3_beta$Pages$Internal$ResponseSketch$NotFound({ nM: path, g0: notFoundReason })));
            return $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Effect$SendSinglePageNew_fn(byteEncodedPageData, $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$PageProgress({
                f9: $elm$core$Dict$empty,
                fk: _List_Nil,
                aL: _List_Nil,
                mS: _List_Nil,
                gw: $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$bodyToString(notFoundDocument.hJ),
                gC: true,
                n4: $dillonkearns$elm_pages_v3_beta$Path$toAbsolute(path),
                dU: $elm$core$Dict$empty,
                aF: 404,
                jE: notFoundDocument.jE
            }));
        }
    }, $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$render404Page = F5($dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$render404Page_fn);
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$StaticResponses$renderApiRequest = function (request) {
        return request;
    };
    var $elm$json$Json$Encode$bool = _Json_wrap;
    var $elm_community$list_extra$List$Extra$groupWhile_fn = function (isSameGroup, items) {
        return $elm$core$List$foldr_fn(F2(function (x, acc) {
            if (!acc.b) {
                return _List_fromArray([
                    _Utils_Tuple2(x, _List_Nil)
                ]);
            }
            else {
                var _v1 = acc.a;
                var y = _v1.a;
                var restOfGroup = _v1.b;
                var groups = acc.b;
                return A2(isSameGroup, x, y) ? _List_Cons(_Utils_Tuple2(x, _List_Cons(y, restOfGroup)), groups) : _List_Cons(_Utils_Tuple2(x, _List_Nil), acc);
            }
        }), _List_Nil, items);
    }, $elm_community$list_extra$List$Extra$groupWhile_fn_unwrapped = function (isSameGroup, items) {
        return $elm$core$List$foldr_fn(F2(function (x, acc) {
            if (!acc.b) {
                return _List_fromArray([
                    _Utils_Tuple2(x, _List_Nil)
                ]);
            }
            else {
                var _v1 = acc.a;
                var y = _v1.a;
                var restOfGroup = _v1.b;
                var groups = acc.b;
                return isSameGroup(x, y) ? _List_Cons(_Utils_Tuple2(x, _List_Cons(y, restOfGroup)), groups) : _List_Cons(_Utils_Tuple2(x, _List_Nil), acc);
            }
        }), _List_Nil, items);
    }, $elm_community$list_extra$List$Extra$groupWhile = F2($elm_community$list_extra$List$Extra$groupWhile_fn);
    var $dillonkearns$elm_pages_v3_beta$PageServerResponse$collectMultiValueHeaders = function (headers) {
        return $elm$core$List$map_fn(function (_v2) {
            var _v3 = _v2.a;
            var key = _v3.a;
            var firstValue = _v3.b;
            var otherValues = _v2.b;
            return _Utils_Tuple2(key, _List_Cons(firstValue, $elm$core$List$map_fn($elm$core$Tuple$second, otherValues)));
        }, $elm_community$list_extra$List$Extra$groupWhile_fn_unwrapped(function (_v0, _v1) {
            var key1 = _v0.a;
            var key2 = _v1.a;
            return _Utils_eq(key1, key2);
        }, headers));
    };
    var $elm$json$Json$Encode$int = _Json_wrap;
    var $elm$core$Tuple$mapSecond_fn = function (func, _v0) {
        var x = _v0.a;
        var y = _v0.b;
        return _Utils_Tuple2(x, func(y));
    }, $elm$core$Tuple$mapSecond = F2($elm$core$Tuple$mapSecond_fn);
    var $dillonkearns$elm_pages_v3_beta$PageServerResponse$toJson = function (serverResponse) {
        return $elm$json$Json$Encode$object(_List_fromArray([
            _Utils_Tuple2("body", $elm$core$Maybe$withDefault_fn($elm$json$Json$Encode$null, $elm$core$Maybe$map_fn($elm$json$Json$Encode$string, serverResponse.hJ))),
            _Utils_Tuple2("statusCode", $elm$json$Json$Encode$int(serverResponse.aF)),
            _Utils_Tuple2("headers", $elm$json$Json$Encode$object($elm$core$List$map_fn($elm$core$Tuple$mapSecond($elm$json$Json$Encode$list($elm$json$Json$Encode$string)), $dillonkearns$elm_pages_v3_beta$PageServerResponse$collectMultiValueHeaders(serverResponse.mS)))),
            _Utils_Tuple2("kind", $elm$json$Json$Encode$string("server-response")),
            _Utils_Tuple2("isBase64Encoded", $elm$json$Json$Encode$bool(serverResponse.gD))
        ]));
    };
    var $dillonkearns$elm_pages_v3_beta$PageServerResponse$toRedirect = function (response) {
        return $elm$core$Maybe$andThen_fn(function (location) {
            return (response.aF === 302) ? $elm$core$Maybe$Just({ ne: location, aF: 302 }) : $elm$core$Maybe$Nothing;
        }, $elm$core$Dict$get_fn("Location", $elm$core$Dict$fromList(response.mS)));
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$toRedirectResponse_fn = function (config, serverRequestPayload, includeHtml, serverResponse, responseMetadata) {
        return $elm$core$Maybe$map_fn(function (_v0) {
            var _v1 = _Utils_Tuple2(serverResponse.mS, $elm$bytes$Bytes$Encode$encode($elm$core$Maybe$withDefault_fn($elm$bytes$Bytes$Encode$unsignedInt8(0), $elm$core$Maybe$map_fn(function (_v2) {
                var location = _v2.ne;
                return config.mw($dillonkearns$elm_pages_v3_beta$Pages$Internal$ResponseSketch$Redirect(location));
            }, $dillonkearns$elm_pages_v3_beta$PageServerResponse$toRedirect(serverResponse)))));
            var byteEncodedPageData = _v1.b;
            return $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Effect$SendSinglePageNew_fn(byteEncodedPageData, $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$PageProgress({
                f9: $elm$core$Dict$empty,
                fk: _List_Nil,
                aL: _List_Nil,
                mS: responseMetadata.mS,
                gw: "This is intentionally blank HTML",
                gC: false,
                n4: $dillonkearns$elm_pages_v3_beta$Path$toRelative(serverRequestPayload.nM),
                dU: $elm$core$Dict$empty,
                aF: function () {
                    if (includeHtml === 1) {
                        return 200;
                    }
                    else {
                        return responseMetadata.aF;
                    }
                }(),
                jE: "This is an intentionally blank title"
            }));
        }, $dillonkearns$elm_pages_v3_beta$PageServerResponse$toRedirect(responseMetadata));
    }, $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$toRedirectResponse = F5($dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$toRedirectResponse_fn);
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$urlToRoute_fn = function (config, url) {
        return _String_startsWith_fn("/____elm-pages-internal____", url.nM) ? config.nA : config.oA(url);
    }, $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$urlToRoute = F2($dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$urlToRoute_fn);
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$initLegacy_fn = function (site, renderRequest, _v0, config) {
        var includeHtml = renderRequest.a;
        var singleRequest = renderRequest.b;
        var isDevServer = _v0.b2;
        var globalHeadTags = $elm$core$Maybe$withDefault_fn(function (_v24) {
            return $dillonkearns$elm_pages_v3_beta$BackendTask$succeed(_List_Nil);
        }, config.mP)($dillonkearns$elm_pages_v3_beta$HtmlPrinter$htmlToString);
        var staticResponsesNew = $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$StaticResponses$renderApiRequest(function () {
            switch (singleRequest.$) {
                case 0:
                    var serverRequestPayload = singleRequest.a;
                    var isAction = $elm$core$Maybe$andThen_fn(A2($elm$core$Basics$composeR, $elm$json$Json$Decode$decodeValue($dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$isActionDecoder), $elm$core$Result$withDefault($elm$core$Maybe$Nothing)), $dillonkearns$elm_pages_v3_beta$RenderRequest$maybeRequestPayload(renderRequest));
                    var currentUrl = {
                        bq: $elm$core$Maybe$Nothing,
                        gu: site.kK,
                        nM: $dillonkearns$elm_pages_v3_beta$Path$toRelative(serverRequestPayload.nM),
                        gS: $elm$core$Maybe$Nothing,
                        gZ: 1,
                        bG: $elm$core$Maybe$Nothing
                    };
                    return $dillonkearns$elm_pages_v3_beta$BackendTask$andThen_fn(function (pageFound) {
                        if (pageFound.$ === 1) {
                            return $dillonkearns$elm_pages_v3_beta$BackendTask$onError_fn(function (error) {
                                var fatalError = error;
                                var isPreRendered = function () {
                                    var keys = $elm$core$List$length($elm$core$List$map_fn($elm$core$Tuple$first, $elm$core$Result$withDefault_fn(_List_Nil, $elm$core$Maybe$withDefault_fn($elm$core$Result$Ok(_List_Nil), $elm$core$Maybe$map_fn($elm$json$Json$Decode$decodeValue($elm$json$Json$Decode$keyValuePairs($elm$json$Json$Decode$value)), $dillonkearns$elm_pages_v3_beta$RenderRequest$maybeRequestPayload(renderRequest))))));
                                    return keys <= 1;
                                }();
                                return (isDevServer || isPreRendered) ? $dillonkearns$elm_pages_v3_beta$BackendTask$fail(error) : $dillonkearns$elm_pages_v3_beta$BackendTask$andThen_fn(function (justSharedData) {
                                    var errorPage = config.m1(fatalError.hJ);
                                    var statusCode = config.mz(errorPage);
                                    var dataThing = config.my(errorPage);
                                    var currentPage = {
                                        nM: serverRequestPayload.nM,
                                        n4: $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$urlToRoute_fn(config, currentUrl)
                                    };
                                    var pageModel = A5(config.dI, $dillonkearns$elm_pages_v3_beta$Pages$Flags$PreRenderFlags, justSharedData, dataThing, $elm$core$Maybe$Nothing, $elm$core$Maybe$Just({
                                        aC: currentPage.n4,
                                        ay: $elm$core$Maybe$Nothing,
                                        nM: { bq: $elm$core$Maybe$Nothing, nM: currentPage.nM, bG: $elm$core$Maybe$Nothing }
                                    })).a;
                                    var viewValue = A8(config.X, $elm$core$Dict$empty, $elm$core$Dict$empty, $elm$core$Maybe$Nothing, currentPage, $elm$core$Maybe$Nothing, justSharedData, dataThing, $elm$core$Maybe$Nothing).X(pageModel);
                                    var byteEncodedPageData = $elm$bytes$Bytes$Encode$encode(config.mw($dillonkearns$elm_pages_v3_beta$Pages$Internal$ResponseSketch$HotUpdate_fn(dataThing, justSharedData, $elm$core$Maybe$Nothing)));
                                    return $dillonkearns$elm_pages_v3_beta$BackendTask$succeed($dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Effect$SendSinglePageNew_fn(byteEncodedPageData, $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$PageProgress({
                                        f9: $elm$core$Dict$empty,
                                        fk: _List_Nil,
                                        aL: _List_Nil,
                                        mS: _List_Nil,
                                        gw: $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$bodyToString(viewValue.hJ),
                                        gC: false,
                                        n4: $dillonkearns$elm_pages_v3_beta$Path$toAbsolute(currentPage.nM),
                                        dU: $elm$core$Dict$empty,
                                        aF: statusCode,
                                        jE: viewValue.jE
                                    })));
                                }, config.A);
                            }, $dillonkearns$elm_pages_v3_beta$BackendTask$andThen_fn(function (something) {
                                var actionHeaders2 = function () {
                                    _v17$2: while (true) {
                                        if (!something.$) {
                                            switch (something.a.$) {
                                                case 0:
                                                    var _v18 = something.a;
                                                    var responseThing = _v18.a;
                                                    return $elm$core$Maybe$Just(responseThing);
                                                case 1:
                                                    var responseThing = something.a.a;
                                                    return $elm$core$Maybe$Just({ mS: responseThing.mS, aF: responseThing.aF });
                                                default:
                                                    break _v17$2;
                                            }
                                        }
                                        else {
                                            break _v17$2;
                                        }
                                    }
                                    return $elm$core$Maybe$Nothing;
                                }();
                                var maybeRedirectResponse = $elm$core$Maybe$andThen_fn(function (responseMetadata) {
                                    return $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$toRedirectResponse_fn(config, serverRequestPayload, includeHtml, responseMetadata, responseMetadata);
                                }, actionHeaders2);
                                if (!maybeRedirectResponse.$) {
                                    var redirectResponse = maybeRedirectResponse.a;
                                    return $dillonkearns$elm_pages_v3_beta$BackendTask$succeed(redirectResponse);
                                }
                                else {
                                    return $dillonkearns$elm_pages_v3_beta$BackendTask$map3_fn(F3(function (pageData, sharedData, tags) {
                                        var renderedResult = function () {
                                            switch (pageData.$) {
                                                case 0:
                                                    var responseInfo = pageData.a;
                                                    var pageData_ = pageData.b;
                                                    var responseMetadata = $elm$core$Maybe$withDefault_fn(responseInfo, actionHeaders2);
                                                    var maybeActionData = function () {
                                                        if ((!something.$) && (!something.a.$)) {
                                                            var _v14 = something.a;
                                                            var actionThing = _v14.b;
                                                            return $elm$core$Maybe$Just(actionThing);
                                                        }
                                                        else {
                                                            return $elm$core$Maybe$Nothing;
                                                        }
                                                    }();
                                                    var currentPage = {
                                                        nM: serverRequestPayload.nM,
                                                        n4: $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$urlToRoute_fn(config, currentUrl)
                                                    };
                                                    var pageModel = A5(config.dI, $dillonkearns$elm_pages_v3_beta$Pages$Flags$PreRenderFlags, sharedData, pageData_, maybeActionData, $elm$core$Maybe$Just({
                                                        aC: currentPage.n4,
                                                        ay: $elm$core$Maybe$Nothing,
                                                        nM: { bq: $elm$core$Maybe$Nothing, nM: currentPage.nM, bG: $elm$core$Maybe$Nothing }
                                                    })).a;
                                                    var viewValue = A8(config.X, $elm$core$Dict$empty, $elm$core$Dict$empty, $elm$core$Maybe$Nothing, currentPage, $elm$core$Maybe$Nothing, sharedData, pageData_, maybeActionData).X(pageModel);
                                                    return function (_v10) {
                                                        var actionHeaders = _v10.a;
                                                        var byteEncodedPageData = _v10.b;
                                                        var rendered = A8(config.X, $elm$core$Dict$empty, $elm$core$Dict$empty, $elm$core$Maybe$Nothing, currentPage, $elm$core$Maybe$Nothing, sharedData, pageData_, maybeActionData);
                                                        return function (encodedData) {
                                                            return $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Effect$SendSinglePageNew_fn(encodedData, $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$PageProgress({
                                                                f9: $elm$core$Dict$empty,
                                                                fk: _List_Nil,
                                                                aL: _Utils_ap(rendered.aL, tags),
                                                                mS: actionHeaders,
                                                                gw: $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$bodyToString(viewValue.hJ),
                                                                gC: false,
                                                                n4: $dillonkearns$elm_pages_v3_beta$Path$toRelative(currentPage.nM),
                                                                dU: $elm$core$Dict$empty,
                                                                aF: function () {
                                                                    if (includeHtml === 1) {
                                                                        return 200;
                                                                    }
                                                                    else {
                                                                        return responseMetadata.aF;
                                                                    }
                                                                }(),
                                                                jE: viewValue.jE
                                                            }));
                                                        }($elm$core$Maybe$withDefault_fn(byteEncodedPageData, $elm$core$Maybe$map_fn(function (_v11) {
                                                            var location = _v11.ne;
                                                            return $elm$bytes$Bytes$Encode$encode(config.mw($dillonkearns$elm_pages_v3_beta$Pages$Internal$ResponseSketch$Redirect(location)));
                                                        }, $dillonkearns$elm_pages_v3_beta$PageServerResponse$toRedirect(responseMetadata))));
                                                    }(function () {
                                                        if (!isAction.$) {
                                                            var actionRequestKind = isAction.a;
                                                            var actionDataResult = something;
                                                            if ((!actionDataResult.$) && (!actionDataResult.a.$)) {
                                                                var _v8 = actionDataResult.a;
                                                                var ignored2 = _v8.a;
                                                                var actionData_ = _v8.b;
                                                                if (!actionRequestKind) {
                                                                    return _Utils_Tuple2(ignored2.mS, $elm$bytes$Bytes$Encode$encode(config.mw($dillonkearns$elm_pages_v3_beta$Pages$Internal$ResponseSketch$HotUpdate_fn(pageData_, sharedData, $elm$core$Maybe$Just(actionData_)))));
                                                                }
                                                                else {
                                                                    return _Utils_Tuple2(ignored2.mS, $elm$bytes$Bytes$Encode$encode(config.mv(actionData_)));
                                                                }
                                                            }
                                                            else {
                                                                return _Utils_Tuple2(responseMetadata.mS, $elm$bytes$Bytes$Encode$encode($elm$bytes$Bytes$Encode$unsignedInt8(0)));
                                                            }
                                                        }
                                                        else {
                                                            return _Utils_Tuple2(responseMetadata.mS, $elm$bytes$Bytes$Encode$encode(config.mw($dillonkearns$elm_pages_v3_beta$Pages$Internal$ResponseSketch$HotUpdate_fn(pageData_, sharedData, $elm$core$Maybe$Nothing))));
                                                        }
                                                    }());
                                                case 1:
                                                    var serverResponse = pageData.a;
                                                    var responseMetadata = function () {
                                                        if ((!something.$) && (something.a.$ === 1)) {
                                                            var responseThing = something.a.a;
                                                            return responseThing;
                                                        }
                                                        else {
                                                            return serverResponse;
                                                        }
                                                    }();
                                                    return $elm$core$Maybe$withDefault_fn($dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Effect$SendSinglePage($dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$SendApiResponse({
                                                        hJ: $dillonkearns$elm_pages_v3_beta$PageServerResponse$toJson(serverResponse),
                                                        dU: $elm$core$Dict$empty,
                                                        aF: serverResponse.aF
                                                    })), $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$toRedirectResponse_fn(config, serverRequestPayload, includeHtml, serverResponse, responseMetadata));
                                                default:
                                                    var error = pageData.a;
                                                    var record = pageData.b;
                                                    var pageData2 = config.my(error);
                                                    var currentPage = {
                                                        nM: serverRequestPayload.nM,
                                                        n4: $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$urlToRoute_fn(config, currentUrl)
                                                    };
                                                    var pageModel = A5(config.dI, $dillonkearns$elm_pages_v3_beta$Pages$Flags$PreRenderFlags, sharedData, pageData2, $elm$core$Maybe$Nothing, $elm$core$Maybe$Just({
                                                        aC: currentPage.n4,
                                                        ay: $elm$core$Maybe$Nothing,
                                                        nM: { bq: $elm$core$Maybe$Nothing, nM: currentPage.nM, bG: $elm$core$Maybe$Nothing }
                                                    })).a;
                                                    var viewValue = A8(config.X, $elm$core$Dict$empty, $elm$core$Dict$empty, $elm$core$Maybe$Nothing, currentPage, $elm$core$Maybe$Nothing, sharedData, pageData2, $elm$core$Maybe$Nothing).X(pageModel);
                                                    return function (encodedData) {
                                                        return $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Effect$SendSinglePageNew_fn(encodedData, $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$PageProgress({
                                                            f9: $elm$core$Dict$empty,
                                                            fk: _List_Nil,
                                                            aL: tags,
                                                            mS: record.mS,
                                                            gw: $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$bodyToString(viewValue.hJ),
                                                            gC: false,
                                                            n4: $dillonkearns$elm_pages_v3_beta$Path$toRelative(currentPage.nM),
                                                            dU: $elm$core$Dict$empty,
                                                            aF: function () {
                                                                if (includeHtml === 1) {
                                                                    return 200;
                                                                }
                                                                else {
                                                                    return config.mz(error);
                                                                }
                                                            }(),
                                                            jE: viewValue.jE
                                                        }));
                                                    }($elm$bytes$Bytes$Encode$encode(config.mw($dillonkearns$elm_pages_v3_beta$Pages$Internal$ResponseSketch$HotUpdate_fn(pageData2, sharedData, $elm$core$Maybe$Nothing))));
                                            }
                                        }();
                                        return renderedResult;
                                    }), A2(config.iW, $elm$core$Maybe$withDefault_fn($elm$json$Json$Encode$null, $dillonkearns$elm_pages_v3_beta$RenderRequest$maybeRequestPayload(renderRequest)), serverRequestPayload.j_), config.A, globalHeadTags);
                                }
                            }, function () {
                                if (!isAction.$) {
                                    return $dillonkearns$elm_pages_v3_beta$BackendTask$map_fn($elm$core$Maybe$Just, A2(config.r, $elm$core$Maybe$withDefault_fn($elm$json$Json$Encode$null, $dillonkearns$elm_pages_v3_beta$RenderRequest$maybeRequestPayload(renderRequest)), serverRequestPayload.j_));
                                }
                                else {
                                    return $dillonkearns$elm_pages_v3_beta$BackendTask$succeed($elm$core$Maybe$Nothing);
                                }
                            }()));
                        }
                        else {
                            var notFoundReason = pageFound.a;
                            return $dillonkearns$elm_pages_v3_beta$BackendTask$succeed($dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$render404Page_fn(config, $elm$core$Maybe$Nothing, isDevServer, serverRequestPayload.nM, notFoundReason));
                        }
                    }, isDevServer ? config.et(serverRequestPayload.j_) : $dillonkearns$elm_pages_v3_beta$BackendTask$succeed($elm$core$Maybe$Nothing));
                case 1:
                    var _v19 = singleRequest.a;
                    var path = _v19.a;
                    var apiHandler = _v19.b;
                    return $dillonkearns$elm_pages_v3_beta$BackendTask$map2_fn(F2(function (response, _v20) {
                        if (!response.$) {
                            var okResponse = response.a;
                            return $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Effect$SendSinglePage($dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$SendApiResponse({ hJ: okResponse, dU: $elm$core$Dict$empty, aF: 200 }));
                        }
                        else {
                            return $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$render404Page_fn(config, $elm$core$Maybe$Nothing, isDevServer, $dillonkearns$elm_pages_v3_beta$Path$fromString(path), $dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$NoMatchingRoute);
                        }
                    }), A2(apiHandler.j7, $elm$core$Maybe$withDefault_fn($elm$json$Json$Encode$null, $dillonkearns$elm_pages_v3_beta$RenderRequest$maybeRequestPayload(renderRequest)), path), globalHeadTags);
                default:
                    var notFoundPath = singleRequest.a;
                    return $dillonkearns$elm_pages_v3_beta$BackendTask$map2_fn(F2(function (_v22, _v23) {
                        return $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$render404Page_fn(config, $elm$core$Maybe$Nothing, isDevServer, notFoundPath, $dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$NoMatchingRoute);
                    }), $dillonkearns$elm_pages_v3_beta$BackendTask$succeed(_List_Nil), globalHeadTags);
            }
        }());
        var initialModel = { fk: _List_Nil, b2: isDevServer, dM: renderRequest, bR: staticResponsesNew };
        return $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$nextStepToEffect_fn(initialModel, $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$StaticResponses$nextStep_fn($elm$json$Json$Encode$object(_List_Nil), initialModel.bR, initialModel));
    }, $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$initLegacy = F4($dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$initLegacy_fn);
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$updateAndSendPortIfDone = function (model) {
        return $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$nextStepToEffect_fn(model, $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$StaticResponses$nextStep_fn($elm$json$Json$Encode$object(_List_Nil), model.bR, model));
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$init_fn = function (site, renderRequest, config, flags) {
        var _v0 = _Json_run_fn($dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$flagsDecoder, flags);
        if (!_v0.$) {
            var compatibilityKey = _v0.a.kP;
            var isDevServer = _v0.a.b2;
            if (_Utils_eq(compatibilityKey, $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$currentCompatibilityKey)) {
                return $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$initLegacy_fn(site, renderRequest, { b2: isDevServer }, config);
            }
            else {
                var elmPackageAheadOfNpmPackage = _Utils_cmp($dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$currentCompatibilityKey, compatibilityKey) > 0;
                var message = "The NPM package and Elm package you have installed are incompatible. If you are updating versions, be sure to update both the elm-pages Elm and NPM package.\n\n" + (elmPackageAheadOfNpmPackage ? "The elm-pages Elm package is ahead of the elm-pages NPM package. Try updating the elm-pages NPM package?" : "The elm-pages NPM package is ahead of the elm-pages Elm package. Try updating the elm-pages Elm package?");
                return $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$updateAndSendPortIfDone({
                    fk: _List_fromArray([
                        {
                            mE: true,
                            eI: _List_fromArray([
                                $dillonkearns$elm_pages_v3_beta$TerminalText$text(message)
                            ]),
                            nM: "",
                            jE: "Incompatible NPM and Elm package versions"
                        }
                    ]),
                    b2: false,
                    dM: renderRequest,
                    bR: $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$StaticResponses$empty($dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Effect$NoEffect)
                });
            }
        }
        else {
            var error = _v0.a;
            return $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$updateAndSendPortIfDone({
                fk: _List_fromArray([
                    {
                        mE: true,
                        eI: _List_fromArray([
                            $dillonkearns$elm_pages_v3_beta$TerminalText$text("Failed to parse flags: " + $elm$json$Json$Decode$errorToString(error))
                        ]),
                        nM: "",
                        jE: "Internal Error"
                    }
                ]),
                b2: false,
                dM: renderRequest,
                bR: $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$StaticResponses$empty($dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Effect$NoEffect)
            });
        }
    }, $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$init = F4($dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$init_fn);
    var $elm$core$Platform$Sub$map = _Platform_map;
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$mergeResult = function (r) {
        if (!r.$) {
            var rr = r.a;
            return rr;
        }
        else {
            var rr = r.a;
            return rr;
        }
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$DoHttp = function (a) {
        return { $: 2, a: a };
    };
    var $elm$core$Platform$Cmd$batch = _Platform_batch;
    var $miniBill$elm_codec$Codec$encoder = function (_v0) {
        var m = _v0;
        return m.dy;
    };
    var $elm$core$Platform$Cmd$map = _Platform_map;
    var $elm$core$Basics$never = function (_v0) {
        never: while (true) {
            var nvr = _v0;
            var $temp$_v0 = nvr;
            _v0 = $temp$_v0;
            continue never;
        }
    };
    var $elm$core$Platform$Cmd$none = $elm$core$Platform$Cmd$batch(_List_Nil);
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$ApiResponse = { $: 5 };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$Port = function (a) {
        return { $: 3, a: a };
    };
    var $miniBill$elm_codec$Codec$Codec = $elm$core$Basics$identity;
    var $miniBill$elm_codec$Codec$buildCustom = function (_v0) {
        var am = _v0;
        return {
            bm: _Json_andThen_fn(function (tag) {
                var _v1 = $elm$core$Dict$get_fn(tag, am.bm);
                if (_v1.$ === 1) {
                    return $elm$json$Json$Decode$fail("tag " + (tag + "did not match"));
                }
                else {
                    var dec = _v1.a;
                    return _Json_decodeField_fn("args", dec);
                }
            }, _Json_decodeField_fn("tag", $elm$json$Json$Decode$string)),
            dy: function (v) {
                return am.li(v);
            }
        };
    };
    var $miniBill$elm_codec$Codec$buildObject = function (_v0) {
        var om = _v0;
        return {
            bm: om.bm,
            dy: function (v) {
                return $elm$json$Json$Encode$object(om.dy(v));
            }
        };
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$StaticHttp$Request$Request_fn = function (url, method, headers, body, cacheOptions) {
        return { hJ: body, iQ: cacheOptions, mS: headers, nh: method, lO: url };
    }, $dillonkearns$elm_pages_v3_beta$Pages$StaticHttp$Request$Request = F5($dillonkearns$elm_pages_v3_beta$Pages$StaticHttp$Request$Request_fn);
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$StaticHttpBody$BytesBody_fn = function (a, b) {
        return { $: 3, a: a, b: b };
    }, $dillonkearns$elm_pages_v3_beta$Pages$Internal$StaticHttpBody$BytesBody = F2($dillonkearns$elm_pages_v3_beta$Pages$Internal$StaticHttpBody$BytesBody_fn);
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$StaticHttpBody$EmptyBody = { $: 0 };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$StaticHttpBody$JsonBody = function (a) {
        return { $: 2, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$StaticHttpBody$StringBody_fn = function (a, b) {
        return { $: 1, a: a, b: b };
    }, $dillonkearns$elm_pages_v3_beta$Pages$Internal$StaticHttpBody$StringBody = F2($dillonkearns$elm_pages_v3_beta$Pages$Internal$StaticHttpBody$StringBody_fn);
    var $miniBill$elm_codec$Codec$build_fn = function (encoder_, decoder_) {
        return { bm: decoder_, dy: encoder_ };
    }, $miniBill$elm_codec$Codec$build = F2($miniBill$elm_codec$Codec$build_fn);
    var $danfishgold$base64_bytes$Encode$isValidChar = function (c) {
        if ($elm$core$Char$isAlphaNum(c)) {
            return true;
        }
        else {
            switch (c) {
                case "+":
                    return true;
                case "/":
                    return true;
                default:
                    return false;
            }
        }
    };
    var $danfishgold$base64_bytes$Encode$unsafeConvertChar = function (_char) {
        var key = $elm$core$Char$toCode(_char);
        if ((key >= 65) && (key <= 90)) {
            return key - 65;
        }
        else {
            if ((key >= 97) && (key <= 122)) {
                return (key - 97) + 26;
            }
            else {
                if ((key >= 48) && (key <= 57)) {
                    return ((key - 48) + 26) + 26;
                }
                else {
                    switch (_char) {
                        case "+":
                            return 62;
                        case "/":
                            return 63;
                        default:
                            return -1;
                    }
                }
            }
        }
    };
    var $elm$bytes$Bytes$Encode$U16_fn = function (a, b) {
        return { $: 4, a: a, b: b };
    }, $elm$bytes$Bytes$Encode$U16 = F2($elm$bytes$Bytes$Encode$U16_fn);
    var $elm$bytes$Bytes$Encode$unsignedInt16 = $elm$bytes$Bytes$Encode$U16;
    var $danfishgold$base64_bytes$Encode$encodeCharacters_fn = function (a, b, c, d) {
        if ($danfishgold$base64_bytes$Encode$isValidChar(a) && $danfishgold$base64_bytes$Encode$isValidChar(b)) {
            var n2 = $danfishgold$base64_bytes$Encode$unsafeConvertChar(b);
            var n1 = $danfishgold$base64_bytes$Encode$unsafeConvertChar(a);
            if ("=" === d) {
                if ("=" === c) {
                    var n = (n1 << 18) | (n2 << 12);
                    var b1 = n >> 16;
                    return $elm$core$Maybe$Just($elm$bytes$Bytes$Encode$unsignedInt8(b1));
                }
                else {
                    if ($danfishgold$base64_bytes$Encode$isValidChar(c)) {
                        var n3 = $danfishgold$base64_bytes$Encode$unsafeConvertChar(c);
                        var n = ((n1 << 18) | (n2 << 12)) | (n3 << 6);
                        var combined = n >> 8;
                        return $elm$core$Maybe$Just($elm$bytes$Bytes$Encode$U16_fn(1, combined));
                    }
                    else {
                        return $elm$core$Maybe$Nothing;
                    }
                }
            }
            else {
                if ($danfishgold$base64_bytes$Encode$isValidChar(c) && $danfishgold$base64_bytes$Encode$isValidChar(d)) {
                    var n4 = $danfishgold$base64_bytes$Encode$unsafeConvertChar(d);
                    var n3 = $danfishgold$base64_bytes$Encode$unsafeConvertChar(c);
                    var n = ((n1 << 18) | (n2 << 12)) | ((n3 << 6) | n4);
                    var combined = n >> 8;
                    var b3 = n;
                    return $elm$core$Maybe$Just($elm$bytes$Bytes$Encode$sequence(_List_fromArray([
                        $elm$bytes$Bytes$Encode$U16_fn(1, combined),
                        $elm$bytes$Bytes$Encode$unsignedInt8(b3)
                    ])));
                }
                else {
                    return $elm$core$Maybe$Nothing;
                }
            }
        }
        else {
            return $elm$core$Maybe$Nothing;
        }
    }, $danfishgold$base64_bytes$Encode$encodeCharacters = F4($danfishgold$base64_bytes$Encode$encodeCharacters_fn);
    var $danfishgold$base64_bytes$Encode$encodeChunks_fn = function (input, accum) {
        encodeChunks: while (true) {
            var _v0 = $elm$core$String$toList($elm$core$String$left_fn(4, input));
            _v0$4: while (true) {
                if (!_v0.b) {
                    return $elm$core$Maybe$Just(accum);
                }
                else {
                    if (_v0.b.b) {
                        if (_v0.b.b.b) {
                            if (_v0.b.b.b.b) {
                                if (!_v0.b.b.b.b.b) {
                                    var a = _v0.a;
                                    var _v1 = _v0.b;
                                    var b = _v1.a;
                                    var _v2 = _v1.b;
                                    var c = _v2.a;
                                    var _v3 = _v2.b;
                                    var d = _v3.a;
                                    var _v4 = $danfishgold$base64_bytes$Encode$encodeCharacters_fn(a, b, c, d);
                                    if (!_v4.$) {
                                        var enc = _v4.a;
                                        var $temp$input = $elm$core$String$dropLeft_fn(4, input), $temp$accum = _List_Cons(enc, accum);
                                        input = $temp$input;
                                        accum = $temp$accum;
                                        continue encodeChunks;
                                    }
                                    else {
                                        return $elm$core$Maybe$Nothing;
                                    }
                                }
                                else {
                                    break _v0$4;
                                }
                            }
                            else {
                                var a = _v0.a;
                                var _v5 = _v0.b;
                                var b = _v5.a;
                                var _v6 = _v5.b;
                                var c = _v6.a;
                                var _v7 = $danfishgold$base64_bytes$Encode$encodeCharacters_fn(a, b, c, "=");
                                if (_v7.$ === 1) {
                                    return $elm$core$Maybe$Nothing;
                                }
                                else {
                                    var enc = _v7.a;
                                    return $elm$core$Maybe$Just(_List_Cons(enc, accum));
                                }
                            }
                        }
                        else {
                            var a = _v0.a;
                            var _v8 = _v0.b;
                            var b = _v8.a;
                            var _v9 = $danfishgold$base64_bytes$Encode$encodeCharacters_fn(a, b, "=", "=");
                            if (_v9.$ === 1) {
                                return $elm$core$Maybe$Nothing;
                            }
                            else {
                                var enc = _v9.a;
                                return $elm$core$Maybe$Just(_List_Cons(enc, accum));
                            }
                        }
                    }
                    else {
                        break _v0$4;
                    }
                }
            }
            return $elm$core$Maybe$Nothing;
        }
    }, $danfishgold$base64_bytes$Encode$encodeChunks = F2($danfishgold$base64_bytes$Encode$encodeChunks_fn);
    var $danfishgold$base64_bytes$Encode$encoder = function (string) {
        return $elm$core$Maybe$map_fn(A2($elm$core$Basics$composeR, $elm$core$List$reverse, $elm$bytes$Bytes$Encode$sequence), $danfishgold$base64_bytes$Encode$encodeChunks_fn(string, _List_Nil));
    };
    var $danfishgold$base64_bytes$Encode$toBytes = function (string) {
        return $elm$core$Maybe$map_fn($elm$bytes$Bytes$Encode$encode, $danfishgold$base64_bytes$Encode$encoder(string));
    };
    var $danfishgold$base64_bytes$Base64$toBytes = $danfishgold$base64_bytes$Encode$toBytes;
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$StaticHttpBody$bytesCodec = $miniBill$elm_codec$Codec$build_fn(A2($elm$core$Basics$composeR, $danfishgold$base64_bytes$Base64$fromBytes, A2($elm$core$Basics$composeR, $elm$core$Maybe$withDefault(""), $elm$json$Json$Encode$string)), _Json_andThen_fn(function (decodedBytes) {
        if (!decodedBytes.$) {
            var bytes = decodedBytes.a;
            return $elm$json$Json$Decode$succeed(bytes);
        }
        else {
            return $elm$json$Json$Decode$fail("Couldn't parse bytes.");
        }
    }, _Json_map1_fn($danfishgold$base64_bytes$Base64$toBytes, $elm$json$Json$Decode$string)));
    var $miniBill$elm_codec$Codec$CustomCodec = $elm$core$Basics$identity;
    var $miniBill$elm_codec$Codec$custom = function (match) {
        return { bm: $elm$core$Dict$empty, li: match };
    };
    var $miniBill$elm_codec$Codec$string = $miniBill$elm_codec$Codec$build_fn($elm$json$Json$Encode$string, $elm$json$Json$Decode$string);
    var $miniBill$elm_codec$Codec$value = { bm: $elm$json$Json$Decode$value, dy: $elm$core$Basics$identity };
    var $miniBill$elm_codec$Codec$variant_fn = function (name, matchPiece, decoderPiece, _v0) {
        var am = _v0;
        var enc = function (v) {
            return $elm$json$Json$Encode$object(_List_fromArray([
                _Utils_Tuple2("tag", $elm$json$Json$Encode$string(name)),
                _Utils_Tuple2("args", $elm$json$Json$Encode$list_fn($elm$core$Basics$identity, v))
            ]));
        };
        return {
            bm: $elm$core$Dict$insert_fn(name, decoderPiece, am.bm),
            li: am.li(matchPiece(enc))
        };
    }, $miniBill$elm_codec$Codec$variant = F4($miniBill$elm_codec$Codec$variant_fn);
    var $miniBill$elm_codec$Codec$variant0_fn = function (name, ctor) {
        return A3($miniBill$elm_codec$Codec$variant, name, function (c) {
            return c(_List_Nil);
        }, $elm$json$Json$Decode$succeed(ctor));
    }, $miniBill$elm_codec$Codec$variant0 = F2($miniBill$elm_codec$Codec$variant0_fn);
    var $miniBill$elm_codec$Codec$decoder = function (_v0) {
        var m = _v0;
        return m.bm;
    };
    var $elm$json$Json$Decode$index = _Json_decodeIndex;
    var $miniBill$elm_codec$Codec$variant1_fn = function (name, ctor, m1) {
        return A3($miniBill$elm_codec$Codec$variant, name, F2(function (c, v) {
            return c(_List_fromArray([
                A2($miniBill$elm_codec$Codec$encoder, m1, v)
            ]));
        }), _Json_map1_fn(ctor, _Json_decodeIndex_fn(0, $miniBill$elm_codec$Codec$decoder(m1))));
    }, $miniBill$elm_codec$Codec$variant1 = F3($miniBill$elm_codec$Codec$variant1_fn);
    var $miniBill$elm_codec$Codec$variant2_fn = function (name, ctor, m1, m2) {
        return A3($miniBill$elm_codec$Codec$variant, name, F3(function (c, v1, v2) {
            return c(_List_fromArray([
                A2($miniBill$elm_codec$Codec$encoder, m1, v1),
                A2($miniBill$elm_codec$Codec$encoder, m2, v2)
            ]));
        }), _Json_map2_fn(ctor, _Json_decodeIndex_fn(0, $miniBill$elm_codec$Codec$decoder(m1)), _Json_decodeIndex_fn(1, $miniBill$elm_codec$Codec$decoder(m2))));
    }, $miniBill$elm_codec$Codec$variant2 = F4($miniBill$elm_codec$Codec$variant2_fn);
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$StaticHttpBody$codec = $miniBill$elm_codec$Codec$buildCustom(A5($miniBill$elm_codec$Codec$variant2, "BytesBody", $dillonkearns$elm_pages_v3_beta$Pages$Internal$StaticHttpBody$BytesBody, $miniBill$elm_codec$Codec$string, $dillonkearns$elm_pages_v3_beta$Pages$Internal$StaticHttpBody$bytesCodec, A4($miniBill$elm_codec$Codec$variant1, "JsonBody", $dillonkearns$elm_pages_v3_beta$Pages$Internal$StaticHttpBody$JsonBody, $miniBill$elm_codec$Codec$value, A5($miniBill$elm_codec$Codec$variant2, "StringBody", $dillonkearns$elm_pages_v3_beta$Pages$Internal$StaticHttpBody$StringBody, $miniBill$elm_codec$Codec$string, $miniBill$elm_codec$Codec$string, A3($miniBill$elm_codec$Codec$variant0, "EmptyBody", $dillonkearns$elm_pages_v3_beta$Pages$Internal$StaticHttpBody$EmptyBody, $miniBill$elm_codec$Codec$custom(F5(function (vEmpty, vString, vJson, vBytes, value) {
        switch (value.$) {
            case 0:
                return vEmpty;
            case 1:
                var a = value.a;
                var b = value.b;
                return A2(vString, a, b);
            case 2:
                var body = value.a;
                return vJson(body);
            default:
                var contentType = value.a;
                var body = value.b;
                return A2(vBytes, contentType, body);
        }
    })))))));
    var $miniBill$elm_codec$Codec$ObjectCodec = $elm$core$Basics$identity;
    var $miniBill$elm_codec$Codec$field_fn = function (name, getter, codec, _v0) {
        var ocodec = _v0;
        return {
            bm: _Json_map2_fn(F2(function (f, x) {
                return f(x);
            }), ocodec.bm, _Json_decodeField_fn(name, $miniBill$elm_codec$Codec$decoder(codec))),
            dy: function (v) {
                return _List_Cons(_Utils_Tuple2(name, A2($miniBill$elm_codec$Codec$encoder, codec, getter(v))), ocodec.dy(v));
            }
        };
    }, $miniBill$elm_codec$Codec$field = F4($miniBill$elm_codec$Codec$field_fn);
    var $miniBill$elm_codec$Codec$composite_fn = function (enc, dec, _v0) {
        var codec = _v0;
        return {
            bm: dec(codec.bm),
            dy: enc(codec.dy)
        };
    }, $miniBill$elm_codec$Codec$composite = F3($miniBill$elm_codec$Codec$composite_fn);
    var $miniBill$elm_codec$Codec$list_a0 = $elm$json$Json$Encode$list, $miniBill$elm_codec$Codec$list_a1 = $elm$json$Json$Decode$list, $miniBill$elm_codec$Codec$list = A2($miniBill$elm_codec$Codec$composite, $miniBill$elm_codec$Codec$list_a0, $miniBill$elm_codec$Codec$list_a1);
    var $miniBill$elm_codec$Codec$maybe = function (codec) {
        return {
            bm: $elm$json$Json$Decode$maybe($miniBill$elm_codec$Codec$decoder(codec)),
            dy: function (v) {
                if (v.$ === 1) {
                    return $elm$json$Json$Encode$null;
                }
                else {
                    var x = v.a;
                    return A2($miniBill$elm_codec$Codec$encoder, codec, x);
                }
            }
        };
    };
    var $miniBill$elm_codec$Codec$nullableField_fn = function (name, getter, codec, ocodec) {
        return $miniBill$elm_codec$Codec$field_fn(name, getter, $miniBill$elm_codec$Codec$maybe(codec), ocodec);
    }, $miniBill$elm_codec$Codec$nullableField = F4($miniBill$elm_codec$Codec$nullableField_fn);
    var $miniBill$elm_codec$Codec$object = function (ctor) {
        return {
            bm: $elm$json$Json$Decode$succeed(ctor),
            dy: function (_v0) {
                return _List_Nil;
            }
        };
    };
    var $miniBill$elm_codec$Codec$tuple_fn = function (m1, m2) {
        return {
            bm: _Json_map2_fn(F2(function (a, b) {
                return _Utils_Tuple2(a, b);
            }), _Json_decodeIndex_fn(0, $miniBill$elm_codec$Codec$decoder(m1)), _Json_decodeIndex_fn(1, $miniBill$elm_codec$Codec$decoder(m2))),
            dy: function (_v0) {
                var v1 = _v0.a;
                var v2 = _v0.b;
                return $elm$json$Json$Encode$list_fn($elm$core$Basics$identity, _List_fromArray([
                    A2($miniBill$elm_codec$Codec$encoder, m1, v1),
                    A2($miniBill$elm_codec$Codec$encoder, m2, v2)
                ]));
            }
        };
    }, $miniBill$elm_codec$Codec$tuple = F2($miniBill$elm_codec$Codec$tuple_fn);
    var $dillonkearns$elm_pages_v3_beta$Pages$StaticHttp$Request$codec = $miniBill$elm_codec$Codec$buildObject($miniBill$elm_codec$Codec$nullableField_fn("cacheOptions", function ($) {
        return $.iQ;
    }, $miniBill$elm_codec$Codec$value, $miniBill$elm_codec$Codec$field_fn("body", function ($) {
        return $.hJ;
    }, $dillonkearns$elm_pages_v3_beta$Pages$Internal$StaticHttpBody$codec, $miniBill$elm_codec$Codec$field_fn("headers", function ($) {
        return $.mS;
    }, $miniBill$elm_codec$Codec$composite_fn($miniBill$elm_codec$Codec$list_a0, $miniBill$elm_codec$Codec$list_a1, $miniBill$elm_codec$Codec$tuple_fn($miniBill$elm_codec$Codec$string, $miniBill$elm_codec$Codec$string)), $miniBill$elm_codec$Codec$field_fn("method", function ($) {
        return $.nh;
    }, $miniBill$elm_codec$Codec$string, $miniBill$elm_codec$Codec$field_fn("url", function ($) {
        return $.lO;
    }, $miniBill$elm_codec$Codec$string, $miniBill$elm_codec$Codec$object($dillonkearns$elm_pages_v3_beta$Pages$StaticHttp$Request$Request)))))));
    var $elm$core$Basics$composeL_fn = function (g, f, x) {
        return g(f(x));
    }, $elm$core$Basics$composeL = F3($elm$core$Basics$composeL_fn);
    var $elm$core$Dict$map_fn = function (func, dict) {
        if (dict.$ === -2) {
            return $elm$core$Dict$RBEmpty_elm_builtin;
        }
        else {
            var color = dict.a;
            var key = dict.b;
            var value = dict.c;
            var left = dict.d;
            var right = dict.e;
            return $elm$core$Dict$RBNode_elm_builtin_fn(color, key, A2(func, key, value), $elm$core$Dict$map_fn(func, left), $elm$core$Dict$map_fn(func, right));
        }
    }, $elm$core$Dict$map_fn_unwrapped = function (func, dict) {
        if (dict.$ === -2) {
            return $elm$core$Dict$RBEmpty_elm_builtin;
        }
        else {
            var color = dict.a;
            var key = dict.b;
            var value = dict.c;
            var left = dict.d;
            var right = dict.e;
            return $elm$core$Dict$RBNode_elm_builtin_fn(color, key, func(key, value), $elm$core$Dict$map_fn_unwrapped(func, left), $elm$core$Dict$map_fn_unwrapped(func, right));
        }
    }, $elm$core$Dict$map = F2($elm$core$Dict$map_fn);
    var $miniBill$elm_codec$Codec$dict_a0 = function (e) {
        return A2($elm$core$Basics$composeL, A2($elm$core$Basics$composeL, $elm$json$Json$Encode$object, $elm$core$Dict$toList), $elm$core$Dict$map(function (_v0) {
            return e;
        }));
    }, $miniBill$elm_codec$Codec$dict_a1 = $elm$json$Json$Decode$dict, $miniBill$elm_codec$Codec$dict = A2($miniBill$elm_codec$Codec$composite, $miniBill$elm_codec$Codec$dict_a0, $miniBill$elm_codec$Codec$dict_a1);
    var $dillonkearns$elm_pages_v3_beta$TerminalText$encoder = function (_v0) {
        var ansiStyle = _v0.a;
        var string = _v0.b;
        return $elm$json$Json$Encode$object(_List_fromArray([
            _Utils_Tuple2("bold", $elm$json$Json$Encode$bool(ansiStyle.d7)),
            _Utils_Tuple2("underline", $elm$json$Json$Encode$bool(ansiStyle.e5)),
            _Utils_Tuple2("color", $elm$json$Json$Encode$string(function () {
                var _v1 = $elm$core$Maybe$withDefault_fn($vito$elm_ansi$Ansi$White, ansiStyle.bi);
                switch (_v1.$) {
                    case 1:
                        return "red";
                    case 4:
                        return "blue";
                    case 2:
                        return "green";
                    case 3:
                        return "yellow";
                    case 6:
                        return "cyan";
                    case 0:
                        return "black";
                    case 5:
                        return "magenta";
                    case 7:
                        return "white";
                    case 8:
                        return "BLACK";
                    case 9:
                        return "RED";
                    case 10:
                        return "GREEN";
                    case 11:
                        return "YELLOW";
                    case 12:
                        return "BLUE";
                    case 13:
                        return "MAGENTA";
                    case 14:
                        return "CYAN";
                    case 15:
                        return "WHITE";
                    default:
                        return "";
                }
            }())),
            _Utils_Tuple2("string", $elm$json$Json$Encode$string(string))
        ]));
    };
    var $dillonkearns$elm_pages_v3_beta$BuildError$messagesEncoder_fn = function (title, messages) {
        return $elm$json$Json$Encode$object(_List_fromArray([
            _Utils_Tuple2("title", $elm$json$Json$Encode$string(title)),
            _Utils_Tuple2("message", $elm$json$Json$Encode$list_fn($dillonkearns$elm_pages_v3_beta$TerminalText$encoder, messages))
        ]));
    }, $dillonkearns$elm_pages_v3_beta$BuildError$messagesEncoder = F2($dillonkearns$elm_pages_v3_beta$BuildError$messagesEncoder_fn);
    var $dillonkearns$elm_pages_v3_beta$BuildError$encode = function (buildErrors) {
        return $elm$json$Json$Encode$object(_List_fromArray([
            _Utils_Tuple2("type", $elm$json$Json$Encode$string("compile-errors")),
            _Utils_Tuple2("errors", $elm$json$Json$Encode$list_fn(function (buildError) {
                return $elm$json$Json$Encode$object(_List_fromArray([
                    _Utils_Tuple2("path", $elm$json$Json$Encode$string(buildError.nM)),
                    _Utils_Tuple2("name", $elm$json$Json$Encode$string(buildError.jE)),
                    _Utils_Tuple2("problems", $elm$json$Json$Encode$list_fn($dillonkearns$elm_pages_v3_beta$BuildError$messagesEncoder(buildError.jE), _List_fromArray([buildError.eI])))
                ]));
            }, buildErrors))
        ]));
    };
    var $dillonkearns$elm_pages_v3_beta$TerminalText$cyan = function (inner) {
        return $dillonkearns$elm_pages_v3_beta$TerminalText$Style_fn(_Utils_update($dillonkearns$elm_pages_v3_beta$TerminalText$blankStyle, {
            bi: $elm$core$Maybe$Just($vito$elm_ansi$Ansi$Cyan)
        }), inner);
    };
    var $dillonkearns$elm_pages_v3_beta$BuildError$banner = function (title) {
        return _List_fromArray([
            $dillonkearns$elm_pages_v3_beta$TerminalText$cyan("-- " + ($elm$core$String$toUpper(title) + " ----------------------------------------------------- elm-pages")),
            $dillonkearns$elm_pages_v3_beta$TerminalText$text("\n\n")
        ]);
    };
    var $dillonkearns$elm_pages_v3_beta$TerminalText$ansiPrefix = "\u001B";
    var $dillonkearns$elm_pages_v3_beta$TerminalText$ansi = function (code) {
        return _Utils_ap($dillonkearns$elm_pages_v3_beta$TerminalText$ansiPrefix, code);
    };
    var $dillonkearns$elm_pages_v3_beta$TerminalText$colorToString = function (color) {
        return $dillonkearns$elm_pages_v3_beta$TerminalText$ansi(function () {
            switch (color.$) {
                case 1:
                    return "[31m";
                case 4:
                    return "[34m";
                case 2:
                    return "[32m";
                case 3:
                    return "[33m";
                case 6:
                    return "[36m";
                default:
                    return "";
            }
        }());
    };
    var $dillonkearns$elm_pages_v3_beta$TerminalText$resetColors = $dillonkearns$elm_pages_v3_beta$TerminalText$ansi("[0m");
    var $dillonkearns$elm_pages_v3_beta$TerminalText$toString_ = function (_v0) {
        var ansiStyle = _v0.a;
        var innerText = _v0.b;
        return $elm$core$String$concat(_List_fromArray([
            $dillonkearns$elm_pages_v3_beta$TerminalText$colorToString($elm$core$Maybe$withDefault_fn($vito$elm_ansi$Ansi$White, ansiStyle.bi)),
            innerText,
            $dillonkearns$elm_pages_v3_beta$TerminalText$resetColors
        ]));
    };
    var $dillonkearns$elm_pages_v3_beta$TerminalText$toString = function (list) {
        return $elm$core$String$concat($elm$core$List$map_fn($dillonkearns$elm_pages_v3_beta$TerminalText$toString_, list));
    };
    var $dillonkearns$elm_pages_v3_beta$BuildError$errorToString = function (error) {
        return $dillonkearns$elm_pages_v3_beta$TerminalText$toString(_Utils_ap($dillonkearns$elm_pages_v3_beta$BuildError$banner(error.jE), error.eI));
    };
    var $dillonkearns$elm_pages_v3_beta$BuildError$errorsToString = function (errors) {
        return $elm$core$String$join_fn("\n\n", $elm$core$List$map_fn($dillonkearns$elm_pages_v3_beta$BuildError$errorToString, errors));
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$errorCodec = $miniBill$elm_codec$Codec$buildObject($miniBill$elm_codec$Codec$field_fn("errorsJson", $elm$core$Basics$identity, $miniBill$elm_codec$Codec$build_fn($dillonkearns$elm_pages_v3_beta$BuildError$encode, $elm$json$Json$Decode$succeed(_List_fromArray([
        { mE: true, eI: _List_Nil, nM: "", jE: "TODO" }
    ]))), $miniBill$elm_codec$Codec$field_fn("errorString", $elm$core$Basics$identity, $miniBill$elm_codec$Codec$build_fn(A2($elm$core$Basics$composeR, $dillonkearns$elm_pages_v3_beta$BuildError$errorsToString, $elm$json$Json$Encode$string), _Json_map1_fn(function (value) {
        return _List_fromArray([
            { mE: false, eI: _List_Nil, nM: "Intentionally empty", jE: value }
        ]);
    }, $elm$json$Json$Decode$string)), $miniBill$elm_codec$Codec$object(F2(function (errorString, _v0) {
        return errorString;
    })))));
    var $miniBill$elm_codec$Codec$int = $miniBill$elm_codec$Codec$build_fn($elm$json$Json$Encode$int, $elm$json$Json$Decode$int);
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$ToJsSuccessPayloadNew = function (route) {
        return function (html) {
            return function (contentJson) {
                return function (errors) {
                    return function (head) {
                        return function (title) {
                            return function (staticHttpCache) {
                                return function (is404) {
                                    return function (statusCode) {
                                        return function (headers) {
                                            return { f9: contentJson, fk: errors, aL: head, mS: headers, gw: html, gC: is404, n4: route, dU: staticHttpCache, aF: statusCode, jE: title };
                                        };
                                    };
                                };
                            };
                        };
                    };
                };
            };
        };
    };
    var $miniBill$elm_codec$Codec$bool = $miniBill$elm_codec$Codec$build_fn($elm$json$Json$Encode$bool, $elm$json$Json$Decode$bool);
    var $dillonkearns$elm_pages_v3_beta$Head$FullUrlToCurrentPage = { $: 2 };
    var $dillonkearns$elm_pages_v3_beta$Head$currentPageFullUrl = $dillonkearns$elm_pages_v3_beta$Head$FullUrlToCurrentPage;
    var $dillonkearns$elm_pages_v3_beta$Head$canonicalLink = function (maybePath) {
        return $dillonkearns$elm_pages_v3_beta$Head$node_fn("link", _List_fromArray([
            _Utils_Tuple2("rel", $dillonkearns$elm_pages_v3_beta$Head$raw("canonical")),
            _Utils_Tuple2("href", $elm$core$Maybe$withDefault_fn($dillonkearns$elm_pages_v3_beta$Head$currentPageFullUrl, $elm$core$Maybe$map_fn($dillonkearns$elm_pages_v3_beta$Head$raw, maybePath)))
        ]));
    };
    var $dillonkearns$elm_pages_v3_beta$Head$joinPaths_fn = function (base, path) {
        return $dillonkearns$elm_pages_v3_beta$Pages$Internal$String$chopEnd_fn("/", base) + ("/" + $dillonkearns$elm_pages_v3_beta$Pages$Internal$String$chopStart_fn("/", path));
    }, $dillonkearns$elm_pages_v3_beta$Head$joinPaths = F2($dillonkearns$elm_pages_v3_beta$Head$joinPaths_fn);
    var $dillonkearns$elm_pages_v3_beta$Pages$Url$join_fn = function (base, path) {
        return $dillonkearns$elm_pages_v3_beta$Pages$Internal$String$chopEnd_fn("/", base) + ("/" + $dillonkearns$elm_pages_v3_beta$Pages$Internal$String$chopStart_fn("/", path));
    }, $dillonkearns$elm_pages_v3_beta$Pages$Url$join = F2($dillonkearns$elm_pages_v3_beta$Pages$Url$join_fn);
    var $dillonkearns$elm_pages_v3_beta$Pages$Url$toAbsoluteUrl_fn = function (canonicalSiteUrl, url) {
        if (url.$ === 1) {
            var externalUrl = url.a;
            return externalUrl;
        }
        else {
            var internalUrl = url.a;
            return $dillonkearns$elm_pages_v3_beta$Pages$Url$join_fn(canonicalSiteUrl, internalUrl);
        }
    }, $dillonkearns$elm_pages_v3_beta$Pages$Url$toAbsoluteUrl = F2($dillonkearns$elm_pages_v3_beta$Pages$Url$toAbsoluteUrl_fn);
    var $dillonkearns$elm_pages_v3_beta$Head$encodeProperty_fn = function (canonicalSiteUrl, currentPagePath, _v0) {
        var name = _v0.a;
        var value = _v0.b;
        switch (value.$) {
            case 0:
                var rawValue = value.a;
                return $elm$json$Json$Encode$list_fn($elm$json$Json$Encode$string, _List_fromArray([name, rawValue]));
            case 2:
                return $elm$json$Json$Encode$list_fn($elm$json$Json$Encode$string, _List_fromArray([
                    name,
                    $dillonkearns$elm_pages_v3_beta$Head$joinPaths_fn(canonicalSiteUrl, currentPagePath)
                ]));
            default:
                var url = value.a;
                return $elm$json$Json$Encode$list_fn($elm$json$Json$Encode$string, _List_fromArray([
                    name,
                    $dillonkearns$elm_pages_v3_beta$Pages$Url$toAbsoluteUrl_fn(canonicalSiteUrl, url)
                ]));
        }
    }, $dillonkearns$elm_pages_v3_beta$Head$encodeProperty = F3($dillonkearns$elm_pages_v3_beta$Head$encodeProperty_fn);
    var $dillonkearns$elm_pages_v3_beta$Head$toJson_fn = function (canonicalSiteUrl, currentPagePath, tag) {
        switch (tag.$) {
            case 0:
                var headTag = tag.a;
                return $elm$json$Json$Encode$object(_List_fromArray([
                    _Utils_Tuple2("name", $elm$json$Json$Encode$string(headTag.nq)),
                    _Utils_Tuple2("attributes", $elm$json$Json$Encode$list_fn(A2($dillonkearns$elm_pages_v3_beta$Head$encodeProperty, canonicalSiteUrl, currentPagePath), headTag.fb)),
                    _Utils_Tuple2("type", $elm$json$Json$Encode$string("head"))
                ]));
            case 1:
                var value = tag.a;
                return $elm$json$Json$Encode$object(_List_fromArray([
                    _Utils_Tuple2("contents", value),
                    _Utils_Tuple2("type", $elm$json$Json$Encode$string("json-ld"))
                ]));
            case 2:
                var key = tag.a;
                var value = tag.b;
                return $elm$json$Json$Encode$object(_List_fromArray([
                    _Utils_Tuple2("type", $elm$json$Json$Encode$string("root")),
                    _Utils_Tuple2("keyValuePair", $elm$json$Json$Encode$list_fn($elm$json$Json$Encode$string, _List_fromArray([key, value])))
                ]));
            default:
                var message = tag.a;
                return $elm$json$Json$Encode$object(_List_fromArray([
                    _Utils_Tuple2("type", $elm$json$Json$Encode$string("stripped")),
                    _Utils_Tuple2("message", $elm$json$Json$Encode$string(message))
                ]));
        }
    }, $dillonkearns$elm_pages_v3_beta$Head$toJson = F3($dillonkearns$elm_pages_v3_beta$Head$toJson_fn);
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$headCodec_fn = function (canonicalSiteUrl, currentPagePath) {
        return $miniBill$elm_codec$Codec$build_fn(A2($dillonkearns$elm_pages_v3_beta$Head$toJson, canonicalSiteUrl, currentPagePath), $elm$json$Json$Decode$succeed($dillonkearns$elm_pages_v3_beta$Head$canonicalLink($elm$core$Maybe$Nothing)));
    }, $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$headCodec = F2($dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$headCodec_fn);
    var $miniBill$elm_codec$Codec$map_fn = function (go, back, codec) {
        return {
            bm: _Json_map1_fn(go, $miniBill$elm_codec$Codec$decoder(codec)),
            dy: function (v) {
                return A2($miniBill$elm_codec$Codec$encoder, codec, back(v));
            }
        };
    }, $miniBill$elm_codec$Codec$map = F3($miniBill$elm_codec$Codec$map_fn);
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$successCodecNew_fn = function (canonicalSiteUrl, currentPagePath) {
        return $miniBill$elm_codec$Codec$buildObject($miniBill$elm_codec$Codec$field_fn("headers", function ($) {
            return $.mS;
        }, $miniBill$elm_codec$Codec$map_fn($elm$core$Dict$toList, $elm$core$Dict$fromList, $miniBill$elm_codec$Codec$composite_fn($miniBill$elm_codec$Codec$dict_a0, $miniBill$elm_codec$Codec$dict_a1, $miniBill$elm_codec$Codec$string)), $miniBill$elm_codec$Codec$field_fn("statusCode", function ($) {
            return $.aF;
        }, $miniBill$elm_codec$Codec$int, $miniBill$elm_codec$Codec$field_fn("is404", function ($) {
            return $.gC;
        }, $miniBill$elm_codec$Codec$bool, $miniBill$elm_codec$Codec$field_fn("staticHttpCache", function ($) {
            return $.dU;
        }, $miniBill$elm_codec$Codec$composite_fn($miniBill$elm_codec$Codec$dict_a0, $miniBill$elm_codec$Codec$dict_a1, $miniBill$elm_codec$Codec$string), $miniBill$elm_codec$Codec$field_fn("title", function ($) {
            return $.jE;
        }, $miniBill$elm_codec$Codec$string, $miniBill$elm_codec$Codec$field_fn("head", function ($) {
            return $.aL;
        }, $miniBill$elm_codec$Codec$composite_fn($miniBill$elm_codec$Codec$list_a0, $miniBill$elm_codec$Codec$list_a1, $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$headCodec_fn(canonicalSiteUrl, currentPagePath)), $miniBill$elm_codec$Codec$field_fn("errors", function ($) {
            return $.fk;
        }, $miniBill$elm_codec$Codec$composite_fn($miniBill$elm_codec$Codec$list_a0, $miniBill$elm_codec$Codec$list_a1, $miniBill$elm_codec$Codec$string), $miniBill$elm_codec$Codec$field_fn("contentJson", function ($) {
            return $.f9;
        }, $miniBill$elm_codec$Codec$composite_fn($miniBill$elm_codec$Codec$dict_a0, $miniBill$elm_codec$Codec$dict_a1, $miniBill$elm_codec$Codec$string), $miniBill$elm_codec$Codec$field_fn("html", function ($) {
            return $.gw;
        }, $miniBill$elm_codec$Codec$string, $miniBill$elm_codec$Codec$field_fn("route", function ($) {
            return $.n4;
        }, $miniBill$elm_codec$Codec$string, $miniBill$elm_codec$Codec$object($dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$ToJsSuccessPayloadNew))))))))))));
    }, $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$successCodecNew = F2($dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$successCodecNew_fn);
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$successCodecNew2_fn = function (canonicalSiteUrl, currentPagePath) {
        return $miniBill$elm_codec$Codec$buildCustom(A4($miniBill$elm_codec$Codec$variant1, "Port", $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$Port, $miniBill$elm_codec$Codec$string, A4($miniBill$elm_codec$Codec$variant1, "ApiResponse", $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$SendApiResponse, $miniBill$elm_codec$Codec$buildObject($miniBill$elm_codec$Codec$field_fn("statusCode", function ($) {
            return $.aF;
        }, $miniBill$elm_codec$Codec$int, $miniBill$elm_codec$Codec$field_fn("staticHttpCache", function ($) {
            return $.dU;
        }, $miniBill$elm_codec$Codec$composite_fn($miniBill$elm_codec$Codec$dict_a0, $miniBill$elm_codec$Codec$dict_a1, $miniBill$elm_codec$Codec$string), $miniBill$elm_codec$Codec$field_fn("body", function ($) {
            return $.hJ;
        }, $miniBill$elm_codec$Codec$value, $miniBill$elm_codec$Codec$object(F3(function (body, staticHttpCache, statusCode) {
            return { hJ: body, dU: staticHttpCache, aF: statusCode };
        })))))), A4($miniBill$elm_codec$Codec$variant1, "DoHttp", $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$DoHttp, $miniBill$elm_codec$Codec$composite_fn($miniBill$elm_codec$Codec$list_a0, $miniBill$elm_codec$Codec$list_a1, $miniBill$elm_codec$Codec$tuple_fn($miniBill$elm_codec$Codec$string, $dillonkearns$elm_pages_v3_beta$Pages$StaticHttp$Request$codec)), A4($miniBill$elm_codec$Codec$variant1, "PageProgress", $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$PageProgress, $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$successCodecNew_fn(canonicalSiteUrl, currentPagePath), A3($miniBill$elm_codec$Codec$variant0, "ApiResponse", $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$ApiResponse, A4($miniBill$elm_codec$Codec$variant1, "Errors", $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$Errors, $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$errorCodec, $miniBill$elm_codec$Codec$custom(F7(function (errorsTag, vApiResponse, success, vDoHttp, vSendApiResponse, vPort, value) {
            switch (value.$) {
                case 5:
                    return vApiResponse;
                case 4:
                    var errorList = value.a;
                    return errorsTag(errorList);
                case 0:
                    var payload = value.a;
                    return success(payload);
                case 2:
                    var hashRequestPairs = value.a;
                    return vDoHttp(hashRequestPairs);
                case 1:
                    var record = value.a;
                    return vSendApiResponse(record);
                default:
                    var string = value.a;
                    return vPort(string);
            }
        })))))))));
    }, $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$successCodecNew2 = F2($dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$successCodecNew2_fn);
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$flatten_fn = function (site, renderRequest, config, list) {
        return $elm$core$Platform$Cmd$batch($dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$flattenHelp_fn(_List_Nil, site, renderRequest, config, list));
    }, $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$flatten = F4($dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$flatten_fn);
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$flattenHelp_fn = function (soFar, site, renderRequest, config, list) {
        flattenHelp: while (true) {
            if (list.b) {
                var first = list.a;
                var rest = list.b;
                var $temp$soFar = _List_Cons($dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$perform_fn(site, renderRequest, config, first), soFar), $temp$site = site, $temp$renderRequest = renderRequest, $temp$config = config, $temp$list = rest;
                soFar = $temp$soFar;
                site = $temp$site;
                renderRequest = $temp$renderRequest;
                config = $temp$config;
                list = $temp$list;
                continue flattenHelp;
            }
            else {
                return soFar;
            }
        }
    }, $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$flattenHelp = F5($dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$flattenHelp_fn);
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$perform_fn = function (site, renderRequest, config, effect) {
        var canonicalSiteUrl = site.kK;
        switch (effect.$) {
            case 0:
                return $elm$core$Platform$Cmd$none;
            case 2:
                var list = effect.a;
                return $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$flatten_fn(site, renderRequest, config, list);
            case 1:
                var requests = effect.a;
                return _Platform_map_fn($elm$core$Basics$never, config.ot(A2($miniBill$elm_codec$Codec$encoder, $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$successCodecNew2_fn(canonicalSiteUrl, ""), $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$DoHttp($elm$core$List$map_fn(function (request) {
                    return _Utils_Tuple2($dillonkearns$elm_pages_v3_beta$Pages$StaticHttp$Request$hash(request), request);
                }, requests)))));
            case 3:
                var info = effect.a;
                var currentPagePath = function () {
                    if (!info.$) {
                        var toJsSuccessPayloadNew = info.a;
                        return toJsSuccessPayloadNew.n4;
                    }
                    else {
                        return "";
                    }
                }();
                return _Platform_map_fn($elm$core$Basics$never, config.ot(A2($miniBill$elm_codec$Codec$encoder, $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$successCodecNew2_fn(canonicalSiteUrl, currentPagePath), info)));
            default:
                var rawBytes = effect.a;
                var info = effect.b;
                var currentPagePath = function () {
                    if (!info.$) {
                        var toJsSuccessPayloadNew = info.a;
                        return toJsSuccessPayloadNew.n4;
                    }
                    else {
                        return "";
                    }
                }();
                return _Platform_map_fn($elm$core$Basics$never, config.oc({
                    l4: rawBytes,
                    nD: A2($miniBill$elm_codec$Codec$encoder, $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$ToJsPayload$successCodecNew2_fn(canonicalSiteUrl, currentPagePath), info)
                }));
        }
    }, $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$perform = F4($dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$perform_fn);
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$update_fn = function (msg, model) {
        if (!msg.$) {
            var batch = msg.a;
            return $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$nextStepToEffect_fn(model, $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$StaticResponses$nextStep_fn(batch, model.bR, model));
        }
        else {
            var buildError = msg.a;
            var updatedModel = _Utils_update(model, {
                fk: _List_Cons(buildError, model.fk)
            });
            return $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$nextStepToEffect_fn(updatedModel, $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$StaticResponses$nextStep_fn($elm$json$Json$Encode$object(_List_Nil), updatedModel.bR, updatedModel));
        }
    }, $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$update = F2($dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$update_fn);
    var $elm$core$Platform$worker = _Platform_worker;
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$cliApplication = function (config) {
        var getSiteConfig = function (fullConfig) {
            getSiteConfig: while (true) {
                var _v0 = fullConfig.of;
                if (!_v0.$) {
                    var mySite = _v0.a;
                    return mySite;
                }
                else {
                    var $temp$fullConfig = fullConfig;
                    fullConfig = $temp$fullConfig;
                    continue getSiteConfig;
                }
            }
        };
        var site = getSiteConfig(config);
        return $elm$core$Platform$worker({
            dI: function (flags) {
                var renderRequest = $elm$core$Result$withDefault_fn($dillonkearns$elm_pages_v3_beta$RenderRequest$default, _Json_run_fn($dillonkearns$elm_pages_v3_beta$RenderRequest$decoder(config), flags));
                return $elm$core$Tuple$mapSecond_fn(A3($dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$perform, site, renderRequest, config), $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$init_fn(site, renderRequest, config, flags));
            },
            dW: function (_v1) {
                return $elm$core$Platform$Sub$batch(_List_fromArray([
                    _Platform_map_fn(function (jsonValue) {
                        var decoder = _Json_andThen_fn(function (tag) {
                            if (tag === "BuildError") {
                                return _Json_map1_fn($dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$GotBuildError, _Json_decodeField_fn("data", _Json_map2_fn(F2(function (message, title) {
                                    return { mE: true, eI: message, nM: "", jE: title };
                                }), _Json_map1_fn($dillonkearns$elm_pages_v3_beta$TerminalText$fromAnsiString, _Json_decodeField_fn("message", $elm$json$Json$Decode$string)), _Json_decodeField_fn("title", $elm$json$Json$Decode$string))));
                            }
                            else {
                                return $elm$json$Json$Decode$fail("Unhandled msg");
                            }
                        }, _Json_decodeField_fn("tag", $elm$json$Json$Decode$string));
                        return $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$mergeResult($elm$core$Result$mapError_fn(function (error) {
                            return $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$GotBuildError($dillonkearns$elm_pages_v3_beta$BuildError$internal("From location 1: " + $elm$json$Json$Decode$errorToString(error)));
                        }, _Json_run_fn(decoder, jsonValue)));
                    }, config.mL),
                    _Platform_map_fn($dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$GotDataBatch, config.mQ)
                ]));
            },
            cF: F2(function (msg, model) {
                return $elm$core$Tuple$mapSecond_fn(A3($dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$perform, site, model.dM, config), $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$update_fn(msg, model));
            })
        });
    };
    var $author$project$Main$Data404NotFoundPage____ = { $: 7 };
    var $dillonkearns$elm_pages_v3_beta$Server$Response$mapError_fn = function (mapFn, pageServerResponse) {
        switch (pageServerResponse.$) {
            case 0:
                var response = pageServerResponse.a;
                var data = pageServerResponse.b;
                return $dillonkearns$elm_pages_v3_beta$PageServerResponse$RenderPage_fn(response, data);
            case 1:
                var serverResponse = pageServerResponse.a;
                return $dillonkearns$elm_pages_v3_beta$PageServerResponse$ServerResponse(serverResponse);
            default:
                var error = pageServerResponse.a;
                var response = pageServerResponse.b;
                return $dillonkearns$elm_pages_v3_beta$PageServerResponse$ErrorPage_fn(mapFn(error), response);
        }
    }, $dillonkearns$elm_pages_v3_beta$Server$Response$mapError = F2($dillonkearns$elm_pages_v3_beta$Server$Response$mapError_fn);
    var $dillonkearns$elm_pages_v3_beta$Server$Response$withStatusCode_fn = function (statusCode, serverResponse) {
        switch (serverResponse.$) {
            case 0:
                var response = serverResponse.a;
                var data = serverResponse.b;
                return $dillonkearns$elm_pages_v3_beta$PageServerResponse$RenderPage_fn(_Utils_update(response, { aF: statusCode }), data);
            case 1:
                var response = serverResponse.a;
                return $dillonkearns$elm_pages_v3_beta$PageServerResponse$ServerResponse(_Utils_update(response, { aF: statusCode }));
            default:
                var error = serverResponse.a;
                return $elm$core$Basics$never(error);
        }
    }, $dillonkearns$elm_pages_v3_beta$Server$Response$withStatusCode = F2($dillonkearns$elm_pages_v3_beta$Server$Response$withStatusCode_fn);
    var $author$project$Main$dataForRoute_fn = function (requestPayload, maybeRoute) {
        if (maybeRoute.$ === 1) {
            return $dillonkearns$elm_pages_v3_beta$BackendTask$succeed($dillonkearns$elm_pages_v3_beta$Server$Response$mapError_fn($elm$core$Basics$never, $dillonkearns$elm_pages_v3_beta$Server$Response$withStatusCode_fn(404, $dillonkearns$elm_pages_v3_beta$Server$Response$render($author$project$Main$Data404NotFoundPage____))));
        }
        else {
            var justRoute_1_0 = maybeRoute.a;
            switch (justRoute_1_0.$) {
                case 0:
                    return $dillonkearns$elm_pages_v3_beta$BackendTask$map_fn($dillonkearns$elm_pages_v3_beta$Server$Response$map($author$project$Main$DataArticles__Draft), A2($author$project$Route$Articles$Draft$route.iW, requestPayload, {}));
                case 1:
                    var routeParams = justRoute_1_0.a;
                    return $dillonkearns$elm_pages_v3_beta$BackendTask$map_fn($dillonkearns$elm_pages_v3_beta$Server$Response$map($author$project$Main$DataArticles__ArticleId_), A2($author$project$Route$Articles$ArticleId_$route.iW, requestPayload, routeParams));
                case 2:
                    var routeParams = justRoute_1_0.a;
                    return $dillonkearns$elm_pages_v3_beta$BackendTask$map_fn($dillonkearns$elm_pages_v3_beta$Server$Response$map($author$project$Main$DataTwilogs__Day_), A2($author$project$Route$Twilogs$Day_$route.iW, requestPayload, routeParams));
                case 3:
                    return $dillonkearns$elm_pages_v3_beta$BackendTask$map_fn($dillonkearns$elm_pages_v3_beta$Server$Response$map($author$project$Main$DataAbout), A2($author$project$Route$About$route.iW, requestPayload, {}));
                case 4:
                    return $dillonkearns$elm_pages_v3_beta$BackendTask$map_fn($dillonkearns$elm_pages_v3_beta$Server$Response$map($author$project$Main$DataArticles), A2($author$project$Route$Articles$route.iW, requestPayload, {}));
                case 5:
                    return $dillonkearns$elm_pages_v3_beta$BackendTask$map_fn($dillonkearns$elm_pages_v3_beta$Server$Response$map($author$project$Main$DataTwilogs), A2($author$project$Route$Twilogs$route.iW, requestPayload, {}));
                default:
                    return $dillonkearns$elm_pages_v3_beta$BackendTask$map_fn($dillonkearns$elm_pages_v3_beta$Server$Response$map($author$project$Main$DataIndex), A2($author$project$Route$Index$route.iW, requestPayload, {}));
            }
        }
    }, $author$project$Main$dataForRoute = F2($author$project$Main$dataForRoute_fn);
    var $elm$bytes$Bytes$Decode$andThen_fn = function (callback, _v0) {
        var decodeA = _v0;
        return F2(function (bites, offset) {
            var _v1 = A2(decodeA, bites, offset);
            var newOffset = _v1.a;
            var a = _v1.b;
            var _v2 = callback(a);
            var decodeB = _v2;
            return A2(decodeB, bites, newOffset);
        });
    }, $elm$bytes$Bytes$Decode$andThen = F2($elm$bytes$Bytes$Decode$andThen_fn);
    var $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn = function (d, d2) {
        return $elm$bytes$Bytes$Decode$andThen_fn(function (v) {
            return $elm$bytes$Bytes$Decode$map_fn(v, d);
        }, d2);
    }, $lamdera$codecs$Lamdera$Wire3$andMapDecode = F2($lamdera$codecs$Lamdera$Wire3$andMapDecode_fn);
    var $lamdera$codecs$Lamdera$Wire3$andThenDecode = $elm$bytes$Bytes$Decode$andThen;
    var $lamdera$codecs$Lamdera$Wire3$decodeUnsignedInt8 = $elm$bytes$Bytes$Decode$unsignedInt8;
    var $lamdera$codecs$Lamdera$Wire3$failDecode = $elm$bytes$Bytes$Decode$fail;
    var $author$project$Route$About$w3_decode_ActionData = $lamdera$codecs$Lamdera$Wire3$succeedDecode({});
    var $author$project$Route$Articles$w3_decode_ActionData = $lamdera$codecs$Lamdera$Wire3$succeedDecode({});
    var $author$project$Route$Articles$ArticleId_$w3_decode_ActionData = $lamdera$codecs$Lamdera$Wire3$succeedDecode({});
    var $author$project$Route$Articles$Draft$w3_decode_ActionData = $lamdera$codecs$Lamdera$Wire3$succeedDecode({});
    var $author$project$Route$Index$w3_decode_ActionData = $lamdera$codecs$Lamdera$Wire3$succeedDecode({});
    var $author$project$Route$Twilogs$w3_decode_ActionData = $lamdera$codecs$Lamdera$Wire3$succeedDecode({});
    var $author$project$Route$Twilogs$Day_$w3_decode_ActionData = $lamdera$codecs$Lamdera$Wire3$succeedDecode({});
    var $author$project$Main$w3_decode_ActionData = $elm$bytes$Bytes$Decode$andThen_fn(function (w3v) {
        switch (w3v) {
            case 0:
                return $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($author$project$Route$About$w3_decode_ActionData, $lamdera$codecs$Lamdera$Wire3$succeedDecode($author$project$Main$ActionDataAbout));
            case 1:
                return $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($author$project$Route$Articles$w3_decode_ActionData, $lamdera$codecs$Lamdera$Wire3$succeedDecode($author$project$Main$ActionDataArticles));
            case 2:
                return $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($author$project$Route$Articles$ArticleId_$w3_decode_ActionData, $lamdera$codecs$Lamdera$Wire3$succeedDecode($author$project$Main$ActionDataArticles__ArticleId_));
            case 3:
                return $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($author$project$Route$Articles$Draft$w3_decode_ActionData, $lamdera$codecs$Lamdera$Wire3$succeedDecode($author$project$Main$ActionDataArticles__Draft));
            case 4:
                return $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($author$project$Route$Index$w3_decode_ActionData, $lamdera$codecs$Lamdera$Wire3$succeedDecode($author$project$Main$ActionDataIndex));
            case 5:
                return $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($author$project$Route$Twilogs$w3_decode_ActionData, $lamdera$codecs$Lamdera$Wire3$succeedDecode($author$project$Main$ActionDataTwilogs));
            case 6:
                return $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($author$project$Route$Twilogs$Day_$w3_decode_ActionData, $lamdera$codecs$Lamdera$Wire3$succeedDecode($author$project$Main$ActionDataTwilogs__Day_));
            default:
                return $lamdera$codecs$Lamdera$Wire3$failDecode;
        }
    }, $lamdera$codecs$Lamdera$Wire3$decodeUnsignedInt8);
    var $elm$bytes$Bytes$Decode$float64 = function (endianness) {
        return _Bytes_read_f64(!endianness);
    };
    var $lamdera$codecs$Lamdera$Wire3$decodeFloat64 = $elm$bytes$Bytes$Decode$float64($lamdera$codecs$Lamdera$Wire3$endianness);
    var $lamdera$codecs$Lamdera$Wire3$identityFloatToInt = $elm$core$Basics$floor;
    var $lamdera$codecs$Lamdera$Wire3$unsignedToSigned = function (i) {
        return (_Basics_modBy_fn(2, i) === 1) ? $lamdera$codecs$Lamdera$Wire3$intDivBy_fn(-2, i + 1) : $lamdera$codecs$Lamdera$Wire3$intDivBy_fn(2, i);
    };
    var $lamdera$codecs$Lamdera$Wire3$decodeInt64 = function () {
        var d = $lamdera$codecs$Lamdera$Wire3$andMapDecode($elm$bytes$Bytes$Decode$unsignedInt8);
        return $elm$bytes$Bytes$Decode$andThen_fn(function (n0) {
            return (n0 <= 215) ? $elm$bytes$Bytes$Decode$map_fn($lamdera$codecs$Lamdera$Wire3$unsignedToSigned, $elm$bytes$Bytes$Decode$succeed(n0)) : ((n0 < 252) ? $elm$bytes$Bytes$Decode$map_fn($lamdera$codecs$Lamdera$Wire3$unsignedToSigned, d($elm$bytes$Bytes$Decode$succeed(function (b0) {
                return (((n0 - 216) * 256) + b0) + 216;
            }))) : ((n0 === 252) ? $elm$bytes$Bytes$Decode$map_fn($lamdera$codecs$Lamdera$Wire3$unsignedToSigned, d(d($elm$bytes$Bytes$Decode$succeed(F2(function (b0, b1) {
                return (b0 * 256) + b1;
            }))))) : ((n0 === 253) ? $elm$bytes$Bytes$Decode$map_fn($lamdera$codecs$Lamdera$Wire3$unsignedToSigned, d(d(d($elm$bytes$Bytes$Decode$succeed(F3(function (b0, b1, b2) {
                return (((b0 * 256) + b1) * 256) + b2;
            })))))) : ((n0 === 254) ? $elm$bytes$Bytes$Decode$map_fn($lamdera$codecs$Lamdera$Wire3$unsignedToSigned, d(d(d(d($elm$bytes$Bytes$Decode$succeed(F4(function (b0, b1, b2, b3) {
                return (((((b0 * 256) + b1) * 256) + b2) * 256) + b3;
            }))))))) : $elm$bytes$Bytes$Decode$map_fn($lamdera$codecs$Lamdera$Wire3$identityFloatToInt, $lamdera$codecs$Lamdera$Wire3$decodeFloat64)))));
        }, $elm$bytes$Bytes$Decode$unsignedInt8);
    }();
    var $lamdera$codecs$Lamdera$Wire3$decodeList = function (decoder) {
        var listStep = function (_v0) {
            var n = _v0.a;
            var xs = _v0.b;
            return (n <= 0) ? $elm$bytes$Bytes$Decode$succeed($elm$bytes$Bytes$Decode$Done(xs)) : $elm$bytes$Bytes$Decode$map_fn(function (x) {
                return $elm$bytes$Bytes$Decode$Loop(_Utils_Tuple2(n - 1, _List_Cons(x, xs)));
            }, decoder);
        };
        return $elm$bytes$Bytes$Decode$andThen_fn(function (len) {
            return $elm$bytes$Bytes$Decode$map_fn($elm$core$List$reverse, $elm$bytes$Bytes$Decode$loop_fn(_Utils_Tuple2(len, _List_Nil), listStep));
        }, $lamdera$codecs$Lamdera$Wire3$decodeInt64);
    };
    var $elm$bytes$Bytes$Decode$string = function (n) {
        return _Bytes_read_string(n);
    };
    var $lamdera$codecs$Lamdera$Wire3$decodeString = $elm$bytes$Bytes$Decode$andThen_fn($elm$bytes$Bytes$Decode$string, $lamdera$codecs$Lamdera$Wire3$decodeInt64);
    var $lamdera$codecs$Lamdera$Wire3$decodeInt = $lamdera$codecs$Lamdera$Wire3$decodeInt64;
    var $lamdera$codecs$Lamdera$Wire3$decodeMaybe = function (decVal) {
        return $elm$bytes$Bytes$Decode$andThen_fn(function (c) {
            switch (c) {
                case 0:
                    return $lamdera$codecs$Lamdera$Wire3$succeedDecode($elm$core$Maybe$Nothing);
                case 1:
                    return $elm$bytes$Bytes$Decode$map_fn($elm$core$Maybe$Just, decVal);
                default:
                    return $lamdera$codecs$Lamdera$Wire3$failDecode;
            }
        }, $elm$bytes$Bytes$Decode$unsignedInt8);
    };
    var $author$project$Shared$w3_decode_CmsImage = $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($lamdera$codecs$Lamdera$Wire3$decodeInt, $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($lamdera$codecs$Lamdera$Wire3$decodeString, $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($lamdera$codecs$Lamdera$Wire3$decodeInt, $lamdera$codecs$Lamdera$Wire3$succeedDecode(F3(function (height0, url0, width0) {
        return { eu: height0, lO: url0, e9: width0 };
    })))));
    var $author$project$Shared$w3_decode_CmsArticleMetadata = $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($lamdera$codecs$Lamdera$Wire3$decodeString, $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($elm$bytes$Bytes$Decode$andThen_fn(function (t) {
        return $lamdera$codecs$Lamdera$Wire3$succeedDecode($elm$time$Time$millisToPosix(t));
    }, $lamdera$codecs$Lamdera$Wire3$decodeInt), $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($elm$bytes$Bytes$Decode$andThen_fn(function (t) {
        return $lamdera$codecs$Lamdera$Wire3$succeedDecode($elm$time$Time$millisToPosix(t));
    }, $lamdera$codecs$Lamdera$Wire3$decodeInt), $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($lamdera$codecs$Lamdera$Wire3$decodeMaybe($author$project$Shared$w3_decode_CmsImage), $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($lamdera$codecs$Lamdera$Wire3$decodeString, $lamdera$codecs$Lamdera$Wire3$succeedDecode(F5(function (contentId0, image0, publishedAt0, revisedAt0, title0) {
        return { f8: contentId0, gy: image0, c6: publishedAt0, ir: revisedAt0, jE: title0 };
    })))))));
    var $author$project$Shared$w3_decode_QiitaArticleMetadata = $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($lamdera$codecs$Lamdera$Wire3$decodeString, $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($elm$bytes$Bytes$Decode$andThen_fn(function (t) {
        return $lamdera$codecs$Lamdera$Wire3$succeedDecode($elm$time$Time$millisToPosix(t));
    }, $lamdera$codecs$Lamdera$Wire3$decodeInt), $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($lamdera$codecs$Lamdera$Wire3$decodeString, $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($lamdera$codecs$Lamdera$Wire3$decodeList($lamdera$codecs$Lamdera$Wire3$decodeString), $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($lamdera$codecs$Lamdera$Wire3$decodeInt, $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($elm$bytes$Bytes$Decode$andThen_fn(function (t) {
        return $lamdera$codecs$Lamdera$Wire3$succeedDecode($elm$time$Time$millisToPosix(t));
    }, $lamdera$codecs$Lamdera$Wire3$decodeInt), $lamdera$codecs$Lamdera$Wire3$succeedDecode(F6(function (createdAt0, likesCount0, tags0, title0, updatedAt0, url0) {
        return { cf: createdAt0, h7: likesCount0, iz: tags0, jE: title0, iF: updatedAt0, lO: url0 };
    }))))))));
    var $justinmimbs$date$Date$w3_decode_RataDie = $lamdera$codecs$Lamdera$Wire3$decodeInt;
    var $justinmimbs$date$Date$w3_decode_Date = $elm$bytes$Bytes$Decode$andThen_fn(function (w3v) {
        if (!w3v) {
            return $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($justinmimbs$date$Date$w3_decode_RataDie, $lamdera$codecs$Lamdera$Wire3$succeedDecode($elm$core$Basics$identity));
        }
        else {
            return $lamdera$codecs$Lamdera$Wire3$failDecode;
        }
    }, $lamdera$codecs$Lamdera$Wire3$decodeUnsignedInt8);
    var $author$project$Shared$w3_decode_RataDie = $lamdera$codecs$Lamdera$Wire3$decodeInt;
    var $author$project$Shared$w3_decode_TwilogArchiveMetadata = $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($author$project$Shared$w3_decode_RataDie, $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($lamdera$codecs$Lamdera$Wire3$decodeString, $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($lamdera$codecs$Lamdera$Wire3$decodeString, $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($justinmimbs$date$Date$w3_decode_Date, $lamdera$codecs$Lamdera$Wire3$succeedDecode(F4(function (date0, isoDate0, path0, rataDie0) {
        return { ga: date0, gF: isoDate0, nM: path0, fK: rataDie0 };
    }))))));
    var $author$project$Shared$w3_decode_ZennArticleMetadata = $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($lamdera$codecs$Lamdera$Wire3$decodeString, $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($lamdera$codecs$Lamdera$Wire3$decodeString, $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($elm$bytes$Bytes$Decode$andThen_fn(function (t) {
        return $lamdera$codecs$Lamdera$Wire3$succeedDecode($elm$time$Time$millisToPosix(t));
    }, $lamdera$codecs$Lamdera$Wire3$decodeInt), $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($lamdera$codecs$Lamdera$Wire3$decodeInt, $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($elm$bytes$Bytes$Decode$andThen_fn(function (t) {
        return $lamdera$codecs$Lamdera$Wire3$succeedDecode($elm$time$Time$millisToPosix(t));
    }, $lamdera$codecs$Lamdera$Wire3$decodeInt), $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($lamdera$codecs$Lamdera$Wire3$decodeString, $lamdera$codecs$Lamdera$Wire3$succeedDecode(F6(function (articleType0, bodyUpdatedAt0, likedCount0, publishedAt0, title0, url0) {
        return { hH: articleType0, hK: bodyUpdatedAt0, h6: likedCount0, c6: publishedAt0, jE: title0, lO: url0 };
    }))))))));
    var $author$project$Shared$w3_decode_Data = $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($lamdera$codecs$Lamdera$Wire3$decodeList($author$project$Shared$w3_decode_ZennArticleMetadata), $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($lamdera$codecs$Lamdera$Wire3$decodeList($author$project$Shared$w3_decode_TwilogArchiveMetadata), $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($lamdera$codecs$Lamdera$Wire3$decodeList($lamdera$codecs$Lamdera$Wire3$decodeString), $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($lamdera$codecs$Lamdera$Wire3$decodeList($author$project$Shared$w3_decode_QiitaArticleMetadata), $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($lamdera$codecs$Lamdera$Wire3$decodeList($author$project$Shared$w3_decode_CmsArticleMetadata), $lamdera$codecs$Lamdera$Wire3$succeedDecode(F5(function (cmsArticles0, qiitaArticles0, repos0, twilogArchives0, zennArticles0) {
        return { f6: cmsArticles0, io: qiitaArticles0, iq: repos0, iD: twilogArchives0, iI: zennArticles0 };
    })))))));
    var $author$project$ErrorPage$InternalError = function (a) {
        return { $: 1, a: a };
    };
    var $author$project$ErrorPage$NotFound = { $: 0 };
    var $author$project$ErrorPage$w3_decode_ErrorPage = $elm$bytes$Bytes$Decode$andThen_fn(function (w3v) {
        switch (w3v) {
            case 0:
                return $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($lamdera$codecs$Lamdera$Wire3$decodeString, $lamdera$codecs$Lamdera$Wire3$succeedDecode($author$project$ErrorPage$InternalError));
            case 1:
                return $lamdera$codecs$Lamdera$Wire3$succeedDecode($author$project$ErrorPage$NotFound);
            default:
                return $lamdera$codecs$Lamdera$Wire3$failDecode;
        }
    }, $lamdera$codecs$Lamdera$Wire3$decodeUnsignedInt8);
    var $author$project$Main$w3_decode_PageData = $elm$bytes$Bytes$Decode$andThen_fn(function (w3v) {
        switch (w3v) {
            case 0:
                return $lamdera$codecs$Lamdera$Wire3$succeedDecode($author$project$Main$Data404NotFoundPage____);
            case 1:
                return $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($author$project$Route$About$w3_decode_Data, $lamdera$codecs$Lamdera$Wire3$succeedDecode($author$project$Main$DataAbout));
            case 2:
                return $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($author$project$Route$Articles$w3_decode_Data, $lamdera$codecs$Lamdera$Wire3$succeedDecode($author$project$Main$DataArticles));
            case 3:
                return $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($author$project$Route$Articles$ArticleId_$w3_decode_Data, $lamdera$codecs$Lamdera$Wire3$succeedDecode($author$project$Main$DataArticles__ArticleId_));
            case 4:
                return $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($author$project$Route$Articles$Draft$w3_decode_Data, $lamdera$codecs$Lamdera$Wire3$succeedDecode($author$project$Main$DataArticles__Draft));
            case 5:
                return $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($author$project$ErrorPage$w3_decode_ErrorPage, $lamdera$codecs$Lamdera$Wire3$succeedDecode($author$project$Main$DataErrorPage____));
            case 6:
                return $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($author$project$Route$Index$w3_decode_Data, $lamdera$codecs$Lamdera$Wire3$succeedDecode($author$project$Main$DataIndex));
            case 7:
                return $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($author$project$Route$Twilogs$w3_decode_Data, $lamdera$codecs$Lamdera$Wire3$succeedDecode($author$project$Main$DataTwilogs));
            case 8:
                return $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($author$project$Route$Twilogs$Day_$w3_decode_Data, $lamdera$codecs$Lamdera$Wire3$succeedDecode($author$project$Main$DataTwilogs__Day_));
            default:
                return $lamdera$codecs$Lamdera$Wire3$failDecode;
        }
    }, $lamdera$codecs$Lamdera$Wire3$decodeUnsignedInt8);
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$ResponseSketch$Action = function (a) {
        return { $: 4, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$ResponseSketch$RenderPage_fn = function (a, b) {
        return { $: 0, a: a, b: b };
    }, $dillonkearns$elm_pages_v3_beta$Pages$Internal$ResponseSketch$RenderPage = F2($dillonkearns$elm_pages_v3_beta$Pages$Internal$ResponseSketch$RenderPage_fn);
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$NotPrerendered_fn = function (a, b) {
        return { $: 1, a: a, b: b };
    }, $dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$NotPrerendered = F2($dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$NotPrerendered_fn);
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$NotPrerenderedOrHandledByFallback_fn = function (a, b) {
        return { $: 2, a: a, b: b };
    }, $dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$NotPrerenderedOrHandledByFallback = F2($dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$NotPrerenderedOrHandledByFallback_fn);
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$UnhandledServerRoute = function (a) {
        return { $: 3, a: a };
    };
    var $lamdera$codecs$Lamdera$Wire3$decodePair_fn = function (c_a, c_b) {
        return $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn(c_b, $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn(c_a, $elm$bytes$Bytes$Decode$succeed(F2(function (a, b) {
            return _Utils_Tuple2(a, b);
        }))));
    }, $lamdera$codecs$Lamdera$Wire3$decodePair = F2($lamdera$codecs$Lamdera$Wire3$decodePair_fn);
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$w3_decode_Record = $lamdera$codecs$Lamdera$Wire3$decodeList($lamdera$codecs$Lamdera$Wire3$decodePair_fn($lamdera$codecs$Lamdera$Wire3$decodeString, $lamdera$codecs$Lamdera$Wire3$decodeString));
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$Optional = function (a) {
        return { $: 0, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$OptionalSplat = { $: 2 };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$RequiredSplat = { $: 1 };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$w3_decode_Ending = $elm$bytes$Bytes$Decode$andThen_fn(function (w3v) {
        switch (w3v) {
            case 0:
                return $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($lamdera$codecs$Lamdera$Wire3$decodeString, $lamdera$codecs$Lamdera$Wire3$succeedDecode($dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$Optional));
            case 1:
                return $lamdera$codecs$Lamdera$Wire3$succeedDecode($dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$OptionalSplat);
            case 2:
                return $lamdera$codecs$Lamdera$Wire3$succeedDecode($dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$RequiredSplat);
            default:
                return $lamdera$codecs$Lamdera$Wire3$failDecode;
        }
    }, $lamdera$codecs$Lamdera$Wire3$decodeUnsignedInt8);
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$DynamicSegment = function (a) {
        return { $: 1, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$StaticSegment = function (a) {
        return { $: 0, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$w3_decode_Segment = $elm$bytes$Bytes$Decode$andThen_fn(function (w3v) {
        switch (w3v) {
            case 0:
                return $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($lamdera$codecs$Lamdera$Wire3$decodeString, $lamdera$codecs$Lamdera$Wire3$succeedDecode($dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$DynamicSegment));
            case 1:
                return $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($lamdera$codecs$Lamdera$Wire3$decodeString, $lamdera$codecs$Lamdera$Wire3$succeedDecode($dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$StaticSegment));
            default:
                return $lamdera$codecs$Lamdera$Wire3$failDecode;
        }
    }, $lamdera$codecs$Lamdera$Wire3$decodeUnsignedInt8);
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$w3_decode_RoutePattern = $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($lamdera$codecs$Lamdera$Wire3$decodeList($dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$w3_decode_Segment), $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($lamdera$codecs$Lamdera$Wire3$decodeMaybe($dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$w3_decode_Ending), $lamdera$codecs$Lamdera$Wire3$succeedDecode(F2(function (ending0, segments0) {
        return { bn: ending0, bI: segments0 };
    }))));
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$w3_decode_ModuleContext = $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$w3_decode_RoutePattern, $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($lamdera$codecs$Lamdera$Wire3$decodeList($lamdera$codecs$Lamdera$Wire3$decodeString), $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$w3_decode_Record, $lamdera$codecs$Lamdera$Wire3$succeedDecode(F3(function (matchedRouteParams0, moduleName0, routePattern0) {
        return { nf: matchedRouteParams0, fC: moduleName0, fM: routePattern0 };
    })))));
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$w3_decode_NotFoundReason = $elm$bytes$Bytes$Decode$andThen_fn(function (w3v) {
        switch (w3v) {
            case 0:
                return $lamdera$codecs$Lamdera$Wire3$succeedDecode($dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$NoMatchingRoute);
            case 1:
                return $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($lamdera$codecs$Lamdera$Wire3$decodeList($dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$w3_decode_Record), $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$w3_decode_ModuleContext, $lamdera$codecs$Lamdera$Wire3$succeedDecode($dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$NotPrerendered)));
            case 2:
                return $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($lamdera$codecs$Lamdera$Wire3$decodeList($dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$w3_decode_Record), $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$w3_decode_ModuleContext, $lamdera$codecs$Lamdera$Wire3$succeedDecode($dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$NotPrerenderedOrHandledByFallback)));
            case 3:
                return $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$w3_decode_ModuleContext, $lamdera$codecs$Lamdera$Wire3$succeedDecode($dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$UnhandledServerRoute));
            default:
                return $lamdera$codecs$Lamdera$Wire3$failDecode;
        }
    }, $lamdera$codecs$Lamdera$Wire3$decodeUnsignedInt8);
    var $dillonkearns$elm_pages_v3_beta$Path$w3_decode_Path = $lamdera$codecs$Lamdera$Wire3$decodeList($lamdera$codecs$Lamdera$Wire3$decodeString);
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$ResponseSketch$w3_decode_ResponseSketch_fn = function (w3_x_c_data, w3_x_c_action, w3_x_c_shared) {
        return $elm$bytes$Bytes$Decode$andThen_fn(function (w3v) {
            switch (w3v) {
                case 0:
                    return $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn(w3_x_c_action, $lamdera$codecs$Lamdera$Wire3$succeedDecode($dillonkearns$elm_pages_v3_beta$Pages$Internal$ResponseSketch$Action));
                case 1:
                    return $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($lamdera$codecs$Lamdera$Wire3$decodeMaybe(w3_x_c_action), $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn(w3_x_c_shared, $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn(w3_x_c_data, $lamdera$codecs$Lamdera$Wire3$succeedDecode($dillonkearns$elm_pages_v3_beta$Pages$Internal$ResponseSketch$HotUpdate))));
                case 2:
                    return $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$w3_decode_NotFoundReason, $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($dillonkearns$elm_pages_v3_beta$Path$w3_decode_Path, $lamdera$codecs$Lamdera$Wire3$succeedDecode(F2(function (path0, reason0) {
                        return { nM: path0, g0: reason0 };
                    })))), $lamdera$codecs$Lamdera$Wire3$succeedDecode($dillonkearns$elm_pages_v3_beta$Pages$Internal$ResponseSketch$NotFound));
                case 3:
                    return $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($lamdera$codecs$Lamdera$Wire3$decodeString, $lamdera$codecs$Lamdera$Wire3$succeedDecode($dillonkearns$elm_pages_v3_beta$Pages$Internal$ResponseSketch$Redirect));
                case 4:
                    return $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn($lamdera$codecs$Lamdera$Wire3$decodeMaybe(w3_x_c_action), $lamdera$codecs$Lamdera$Wire3$andMapDecode_fn(w3_x_c_data, $lamdera$codecs$Lamdera$Wire3$succeedDecode($dillonkearns$elm_pages_v3_beta$Pages$Internal$ResponseSketch$RenderPage)));
                default:
                    return $lamdera$codecs$Lamdera$Wire3$failDecode;
            }
        }, $lamdera$codecs$Lamdera$Wire3$decodeUnsignedInt8);
    }, $dillonkearns$elm_pages_v3_beta$Pages$Internal$ResponseSketch$w3_decode_ResponseSketch = F3($dillonkearns$elm_pages_v3_beta$Pages$Internal$ResponseSketch$w3_decode_ResponseSketch_fn);
    var $author$project$Main$decodeResponse = $dillonkearns$elm_pages_v3_beta$Pages$Internal$ResponseSketch$w3_decode_ResponseSketch_fn($author$project$Main$w3_decode_PageData, $author$project$Main$w3_decode_ActionData, $author$project$Shared$w3_decode_Data);
    var $author$project$Route$About$w3_encode_ActionData = function (w3_rec_var0) {
        return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_Nil);
    };
    var $author$project$Route$Articles$w3_encode_ActionData = function (w3_rec_var0) {
        return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_Nil);
    };
    var $author$project$Route$Articles$ArticleId_$w3_encode_ActionData = function (w3_rec_var0) {
        return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_Nil);
    };
    var $author$project$Route$Articles$Draft$w3_encode_ActionData = function (w3_rec_var0) {
        return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_Nil);
    };
    var $author$project$Route$Index$w3_encode_ActionData = function (w3_rec_var0) {
        return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_Nil);
    };
    var $author$project$Route$Twilogs$w3_encode_ActionData = function (w3_rec_var0) {
        return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_Nil);
    };
    var $author$project$Route$Twilogs$Day_$w3_encode_ActionData = function (w3_rec_var0) {
        return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_Nil);
    };
    var $author$project$Main$encodeActionData = function (actionData) {
        switch (actionData.$) {
            case 0:
                var thisActionData = actionData.a;
                return $author$project$Route$Articles$Draft$w3_encode_ActionData(thisActionData);
            case 1:
                var thisActionData = actionData.a;
                return $author$project$Route$Articles$ArticleId_$w3_encode_ActionData(thisActionData);
            case 2:
                var thisActionData = actionData.a;
                return $author$project$Route$Twilogs$Day_$w3_encode_ActionData(thisActionData);
            case 3:
                var thisActionData = actionData.a;
                return $author$project$Route$About$w3_encode_ActionData(thisActionData);
            case 4:
                var thisActionData = actionData.a;
                return $author$project$Route$Articles$w3_encode_ActionData(thisActionData);
            case 5:
                var thisActionData = actionData.a;
                return $author$project$Route$Twilogs$w3_encode_ActionData(thisActionData);
            default:
                var thisActionData = actionData.a;
                return $author$project$Route$Index$w3_encode_ActionData(thisActionData);
        }
    };
    var $author$project$Main$w3_encode_ActionData = function (w3v) {
        switch (w3v.$) {
            case 3:
                var v0 = w3v.a;
                return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
                    $lamdera$codecs$Lamdera$Wire3$encodeUnsignedInt8(0),
                    $author$project$Route$About$w3_encode_ActionData(v0)
                ]));
            case 4:
                var v0 = w3v.a;
                return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
                    $lamdera$codecs$Lamdera$Wire3$encodeUnsignedInt8(1),
                    $author$project$Route$Articles$w3_encode_ActionData(v0)
                ]));
            case 1:
                var v0 = w3v.a;
                return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
                    $lamdera$codecs$Lamdera$Wire3$encodeUnsignedInt8(2),
                    $author$project$Route$Articles$ArticleId_$w3_encode_ActionData(v0)
                ]));
            case 0:
                var v0 = w3v.a;
                return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
                    $lamdera$codecs$Lamdera$Wire3$encodeUnsignedInt8(3),
                    $author$project$Route$Articles$Draft$w3_encode_ActionData(v0)
                ]));
            case 6:
                var v0 = w3v.a;
                return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
                    $lamdera$codecs$Lamdera$Wire3$encodeUnsignedInt8(4),
                    $author$project$Route$Index$w3_encode_ActionData(v0)
                ]));
            case 5:
                var v0 = w3v.a;
                return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
                    $lamdera$codecs$Lamdera$Wire3$encodeUnsignedInt8(5),
                    $author$project$Route$Twilogs$w3_encode_ActionData(v0)
                ]));
            default:
                var v0 = w3v.a;
                return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
                    $lamdera$codecs$Lamdera$Wire3$encodeUnsignedInt8(6),
                    $author$project$Route$Twilogs$Day_$w3_encode_ActionData(v0)
                ]));
        }
    };
    var $lamdera$codecs$Lamdera$Wire3$encodeList_fn = function (enc, s) {
        return $elm$bytes$Bytes$Encode$sequence(_List_Cons($lamdera$codecs$Lamdera$Wire3$encodeInt64($elm$core$List$length(s)), $elm$core$List$map_fn(enc, s)));
    }, $lamdera$codecs$Lamdera$Wire3$encodeList = F2($lamdera$codecs$Lamdera$Wire3$encodeList_fn);
    var $lamdera$codecs$Lamdera$Wire3$encodeInt = $lamdera$codecs$Lamdera$Wire3$encodeInt64;
    var $lamdera$codecs$Lamdera$Wire3$encodeMaybe_fn = function (encVal, s) {
        if (s.$ === 1) {
            return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
                $elm$bytes$Bytes$Encode$unsignedInt8(0)
            ]));
        }
        else {
            var v = s.a;
            return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
                $elm$bytes$Bytes$Encode$unsignedInt8(1),
                encVal(v)
            ]));
        }
    }, $lamdera$codecs$Lamdera$Wire3$encodeMaybe = F2($lamdera$codecs$Lamdera$Wire3$encodeMaybe_fn);
    var $author$project$Shared$w3_encode_CmsImage = function (w3_rec_var0) {
        return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
            $lamdera$codecs$Lamdera$Wire3$encodeInt(w3_rec_var0.eu),
            $lamdera$codecs$Lamdera$Wire3$encodeString(w3_rec_var0.lO),
            $lamdera$codecs$Lamdera$Wire3$encodeInt(w3_rec_var0.e9)
        ]));
    };
    var $author$project$Shared$w3_encode_CmsArticleMetadata = function (w3_rec_var0) {
        return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
            $lamdera$codecs$Lamdera$Wire3$encodeString(w3_rec_var0.f8),
            $lamdera$codecs$Lamdera$Wire3$encodeMaybe_fn($author$project$Shared$w3_encode_CmsImage, w3_rec_var0.gy),
            function (t) {
                return $lamdera$codecs$Lamdera$Wire3$encodeInt($elm$time$Time$posixToMillis(t));
            }(w3_rec_var0.c6),
            function (t) {
                return $lamdera$codecs$Lamdera$Wire3$encodeInt($elm$time$Time$posixToMillis(t));
            }(w3_rec_var0.ir),
            $lamdera$codecs$Lamdera$Wire3$encodeString(w3_rec_var0.jE)
        ]));
    };
    var $author$project$Shared$w3_encode_QiitaArticleMetadata = function (w3_rec_var0) {
        return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
            function (t) {
                return $lamdera$codecs$Lamdera$Wire3$encodeInt($elm$time$Time$posixToMillis(t));
            }(w3_rec_var0.cf),
            $lamdera$codecs$Lamdera$Wire3$encodeInt(w3_rec_var0.h7),
            $lamdera$codecs$Lamdera$Wire3$encodeList_fn($lamdera$codecs$Lamdera$Wire3$encodeString, w3_rec_var0.iz),
            $lamdera$codecs$Lamdera$Wire3$encodeString(w3_rec_var0.jE),
            function (t) {
                return $lamdera$codecs$Lamdera$Wire3$encodeInt($elm$time$Time$posixToMillis(t));
            }(w3_rec_var0.iF),
            $lamdera$codecs$Lamdera$Wire3$encodeString(w3_rec_var0.lO)
        ]));
    };
    var $justinmimbs$date$Date$w3_encode_RataDie = $lamdera$codecs$Lamdera$Wire3$encodeInt;
    var $justinmimbs$date$Date$w3_encode_Date = function (w3v) {
        var v0 = w3v;
        return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
            $lamdera$codecs$Lamdera$Wire3$encodeUnsignedInt8(0),
            $justinmimbs$date$Date$w3_encode_RataDie(v0)
        ]));
    };
    var $author$project$Shared$w3_encode_RataDie = $lamdera$codecs$Lamdera$Wire3$encodeInt;
    var $author$project$Shared$w3_encode_TwilogArchiveMetadata = function (w3_rec_var0) {
        return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
            $justinmimbs$date$Date$w3_encode_Date(w3_rec_var0.ga),
            $lamdera$codecs$Lamdera$Wire3$encodeString(w3_rec_var0.gF),
            $lamdera$codecs$Lamdera$Wire3$encodeString(w3_rec_var0.nM),
            $author$project$Shared$w3_encode_RataDie(w3_rec_var0.fK)
        ]));
    };
    var $author$project$Shared$w3_encode_ZennArticleMetadata = function (w3_rec_var0) {
        return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
            $lamdera$codecs$Lamdera$Wire3$encodeString(w3_rec_var0.hH),
            function (t) {
                return $lamdera$codecs$Lamdera$Wire3$encodeInt($elm$time$Time$posixToMillis(t));
            }(w3_rec_var0.hK),
            $lamdera$codecs$Lamdera$Wire3$encodeInt(w3_rec_var0.h6),
            function (t) {
                return $lamdera$codecs$Lamdera$Wire3$encodeInt($elm$time$Time$posixToMillis(t));
            }(w3_rec_var0.c6),
            $lamdera$codecs$Lamdera$Wire3$encodeString(w3_rec_var0.jE),
            $lamdera$codecs$Lamdera$Wire3$encodeString(w3_rec_var0.lO)
        ]));
    };
    var $author$project$Shared$w3_encode_Data = function (w3_rec_var0) {
        return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
            $lamdera$codecs$Lamdera$Wire3$encodeList_fn($author$project$Shared$w3_encode_CmsArticleMetadata, w3_rec_var0.f6),
            $lamdera$codecs$Lamdera$Wire3$encodeList_fn($author$project$Shared$w3_encode_QiitaArticleMetadata, w3_rec_var0.io),
            $lamdera$codecs$Lamdera$Wire3$encodeList_fn($lamdera$codecs$Lamdera$Wire3$encodeString, w3_rec_var0.iq),
            $lamdera$codecs$Lamdera$Wire3$encodeList_fn($author$project$Shared$w3_encode_TwilogArchiveMetadata, w3_rec_var0.iD),
            $lamdera$codecs$Lamdera$Wire3$encodeList_fn($author$project$Shared$w3_encode_ZennArticleMetadata, w3_rec_var0.iI)
        ]));
    };
    var $author$project$Main$w3_encode_PageData = function (w3v) {
        switch (w3v.$) {
            case 7:
                return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
                    $lamdera$codecs$Lamdera$Wire3$encodeUnsignedInt8(0)
                ]));
            case 3:
                var v0 = w3v.a;
                return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
                    $lamdera$codecs$Lamdera$Wire3$encodeUnsignedInt8(1),
                    $author$project$Route$About$w3_encode_Data(v0)
                ]));
            case 4:
                var v0 = w3v.a;
                return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
                    $lamdera$codecs$Lamdera$Wire3$encodeUnsignedInt8(2),
                    $author$project$Route$Articles$w3_encode_Data(v0)
                ]));
            case 1:
                var v0 = w3v.a;
                return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
                    $lamdera$codecs$Lamdera$Wire3$encodeUnsignedInt8(3),
                    $author$project$Route$Articles$ArticleId_$w3_encode_Data(v0)
                ]));
            case 0:
                var v0 = w3v.a;
                return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
                    $lamdera$codecs$Lamdera$Wire3$encodeUnsignedInt8(4),
                    $author$project$Route$Articles$Draft$w3_encode_Data(v0)
                ]));
            case 8:
                var v0 = w3v.a;
                return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
                    $lamdera$codecs$Lamdera$Wire3$encodeUnsignedInt8(5),
                    $author$project$ErrorPage$w3_encode_ErrorPage(v0)
                ]));
            case 6:
                var v0 = w3v.a;
                return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
                    $lamdera$codecs$Lamdera$Wire3$encodeUnsignedInt8(6),
                    $author$project$Route$Index$w3_encode_Data(v0)
                ]));
            case 5:
                var v0 = w3v.a;
                return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
                    $lamdera$codecs$Lamdera$Wire3$encodeUnsignedInt8(7),
                    $author$project$Route$Twilogs$w3_encode_Data(v0)
                ]));
            default:
                var v0 = w3v.a;
                return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
                    $lamdera$codecs$Lamdera$Wire3$encodeUnsignedInt8(8),
                    $author$project$Route$Twilogs$Day_$w3_encode_Data(v0)
                ]));
        }
    };
    var $lamdera$codecs$Lamdera$Wire3$encodePair_fn = function (c_a, c_b, _v0) {
        var a = _v0.a;
        var b = _v0.b;
        return $elm$bytes$Bytes$Encode$sequence(_List_fromArray([
            c_a(a),
            c_b(b)
        ]));
    }, $lamdera$codecs$Lamdera$Wire3$encodePair = F3($lamdera$codecs$Lamdera$Wire3$encodePair_fn);
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$w3_encode_Record_a0 = A2($lamdera$codecs$Lamdera$Wire3$encodePair, $lamdera$codecs$Lamdera$Wire3$encodeString, $lamdera$codecs$Lamdera$Wire3$encodeString), $dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$w3_encode_Record = $lamdera$codecs$Lamdera$Wire3$encodeList($dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$w3_encode_Record_a0);
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$w3_encode_Ending = function (w3v) {
        switch (w3v.$) {
            case 0:
                var v0 = w3v.a;
                return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
                    $lamdera$codecs$Lamdera$Wire3$encodeUnsignedInt8(0),
                    $lamdera$codecs$Lamdera$Wire3$encodeString(v0)
                ]));
            case 2:
                return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
                    $lamdera$codecs$Lamdera$Wire3$encodeUnsignedInt8(1)
                ]));
            default:
                return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
                    $lamdera$codecs$Lamdera$Wire3$encodeUnsignedInt8(2)
                ]));
        }
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$w3_encode_Segment = function (w3v) {
        if (w3v.$ === 1) {
            var v0 = w3v.a;
            return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
                $lamdera$codecs$Lamdera$Wire3$encodeUnsignedInt8(0),
                $lamdera$codecs$Lamdera$Wire3$encodeString(v0)
            ]));
        }
        else {
            var v0 = w3v.a;
            return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
                $lamdera$codecs$Lamdera$Wire3$encodeUnsignedInt8(1),
                $lamdera$codecs$Lamdera$Wire3$encodeString(v0)
            ]));
        }
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$w3_encode_RoutePattern = function (w3_rec_var0) {
        return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
            $lamdera$codecs$Lamdera$Wire3$encodeMaybe_fn($dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$w3_encode_Ending, w3_rec_var0.bn),
            $lamdera$codecs$Lamdera$Wire3$encodeList_fn($dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$w3_encode_Segment, w3_rec_var0.bI)
        ]));
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$w3_encode_ModuleContext = function (w3_rec_var0) {
        return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
            $lamdera$codecs$Lamdera$Wire3$encodeList_fn($dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$w3_encode_Record_a0, w3_rec_var0.nf),
            $lamdera$codecs$Lamdera$Wire3$encodeList_fn($lamdera$codecs$Lamdera$Wire3$encodeString, w3_rec_var0.fC),
            $dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$w3_encode_RoutePattern(w3_rec_var0.fM)
        ]));
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$w3_encode_NotFoundReason = function (w3v) {
        switch (w3v.$) {
            case 0:
                return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
                    $lamdera$codecs$Lamdera$Wire3$encodeUnsignedInt8(0)
                ]));
            case 1:
                var v0 = w3v.a;
                var v1 = w3v.b;
                return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
                    $lamdera$codecs$Lamdera$Wire3$encodeUnsignedInt8(1),
                    $dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$w3_encode_ModuleContext(v0),
                    $lamdera$codecs$Lamdera$Wire3$encodeList_fn($dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$w3_encode_Record, v1)
                ]));
            case 2:
                var v0 = w3v.a;
                var v1 = w3v.b;
                return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
                    $lamdera$codecs$Lamdera$Wire3$encodeUnsignedInt8(2),
                    $dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$w3_encode_ModuleContext(v0),
                    $lamdera$codecs$Lamdera$Wire3$encodeList_fn($dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$w3_encode_Record, v1)
                ]));
            default:
                var v0 = w3v.a;
                return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
                    $lamdera$codecs$Lamdera$Wire3$encodeUnsignedInt8(3),
                    $dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$w3_encode_ModuleContext(v0)
                ]));
        }
    };
    var $dillonkearns$elm_pages_v3_beta$Path$w3_encode_Path_a0 = $lamdera$codecs$Lamdera$Wire3$encodeString, $dillonkearns$elm_pages_v3_beta$Path$w3_encode_Path = $lamdera$codecs$Lamdera$Wire3$encodeList($dillonkearns$elm_pages_v3_beta$Path$w3_encode_Path_a0);
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$ResponseSketch$w3_encode_ResponseSketch_fn = function (w3_x_c_data, w3_x_c_action, w3_x_c_shared, w3v) {
        switch (w3v.$) {
            case 4:
                var v0 = w3v.a;
                return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
                    $lamdera$codecs$Lamdera$Wire3$encodeUnsignedInt8(0),
                    w3_x_c_action(v0)
                ]));
            case 1:
                var v0 = w3v.a;
                var v1 = w3v.b;
                var v2 = w3v.c;
                return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
                    $lamdera$codecs$Lamdera$Wire3$encodeUnsignedInt8(1),
                    w3_x_c_data(v0),
                    w3_x_c_shared(v1),
                    $lamdera$codecs$Lamdera$Wire3$encodeMaybe_fn(w3_x_c_action, v2)
                ]));
            case 3:
                var v0 = w3v.a;
                return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
                    $lamdera$codecs$Lamdera$Wire3$encodeUnsignedInt8(2),
                    function (w3_rec_var0) {
                        return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
                            $lamdera$codecs$Lamdera$Wire3$encodeList_fn($dillonkearns$elm_pages_v3_beta$Path$w3_encode_Path_a0, w3_rec_var0.nM),
                            $dillonkearns$elm_pages_v3_beta$Pages$Internal$NotFoundReason$w3_encode_NotFoundReason(w3_rec_var0.g0)
                        ]));
                    }(v0)
                ]));
            case 2:
                var v0 = w3v.a;
                return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
                    $lamdera$codecs$Lamdera$Wire3$encodeUnsignedInt8(3),
                    $lamdera$codecs$Lamdera$Wire3$encodeString(v0)
                ]));
            default:
                var v0 = w3v.a;
                var v1 = w3v.b;
                return $lamdera$codecs$Lamdera$Wire3$encodeSequenceWithoutLength(_List_fromArray([
                    $lamdera$codecs$Lamdera$Wire3$encodeUnsignedInt8(4),
                    w3_x_c_data(v0),
                    $lamdera$codecs$Lamdera$Wire3$encodeMaybe_fn(w3_x_c_action, v1)
                ]));
        }
    }, $dillonkearns$elm_pages_v3_beta$Pages$Internal$ResponseSketch$w3_encode_ResponseSketch = F4($dillonkearns$elm_pages_v3_beta$Pages$Internal$ResponseSketch$w3_encode_ResponseSketch_fn);
    var $author$project$Main$encodeResponse_a0 = $author$project$Main$w3_encode_PageData, $author$project$Main$encodeResponse_a1 = $author$project$Main$w3_encode_ActionData, $author$project$Main$encodeResponse_a2 = $author$project$Shared$w3_encode_Data, $author$project$Main$encodeResponse = A3($dillonkearns$elm_pages_v3_beta$Pages$Internal$ResponseSketch$w3_encode_ResponseSketch, $author$project$Main$encodeResponse_a0, $author$project$Main$encodeResponse_a1, $author$project$Main$encodeResponse_a2);
    var $author$project$Effect$Cmd = function (a) {
        return { $: 1, a: a };
    };
    var $author$project$Effect$fromCmd = $author$project$Effect$Cmd;
    var $author$project$Main$fromJsPort = _Platform_incomingPort("fromJsPort", $elm$json$Json$Decode$value);
    var $dillonkearns$elm_pages_v3_beta$ApiRoute$getGlobalHeadTagsBackendTask = function (_v0) {
        var handler = _v0;
        return handler.mP;
    };
    var $author$project$Main$globalHeadTags = function (htmlToString) {
        return $dillonkearns$elm_pages_v3_beta$BackendTask$map_fn($elm$core$List$concat, $dillonkearns$elm_pages_v3_beta$BackendTask$combine(_List_Cons($author$project$Site$config.aL, $elm$core$List$filterMap_fn($dillonkearns$elm_pages_v3_beta$ApiRoute$getGlobalHeadTagsBackendTask, $author$project$Api$routes_fn($author$project$Main$getStaticRoutes, htmlToString)))));
    };
    var $author$project$Main$gotBatchSub = _Platform_incomingPort("gotBatchSub", $elm$json$Json$Decode$value);
    var $author$project$Main$stringToString = function (string) {
        return "\"" + (string + "\"");
    };
    var $author$project$Main$handleRoute = function (maybeRoute) {
        if (maybeRoute.$ === 1) {
            return $dillonkearns$elm_pages_v3_beta$BackendTask$succeed($elm$core$Maybe$Nothing);
        }
        else {
            var route_1_0 = maybeRoute.a;
            switch (route_1_0.$) {
                case 0:
                    return A3($author$project$Route$Articles$Draft$route.et, {
                        fC: _List_fromArray(["Articles", "Draft"]),
                        fM: {
                            bn: $elm$core$Maybe$Nothing,
                            bI: _List_fromArray([
                                $dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$StaticSegment("articles"),
                                $dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$StaticSegment("draft")
                            ])
                        }
                    }, function (param) {
                        return _List_Nil;
                    }, {});
                case 1:
                    var routeParams = route_1_0.a;
                    return A3($author$project$Route$Articles$ArticleId_$route.et, {
                        fC: _List_fromArray(["Articles", "ArticleId_"]),
                        fM: {
                            bn: $elm$core$Maybe$Nothing,
                            bI: _List_fromArray([
                                $dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$StaticSegment("articles"),
                                $dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$DynamicSegment("articleId")
                            ])
                        }
                    }, function (param) {
                        return _List_fromArray([
                            _Utils_Tuple2("articleId", $author$project$Main$stringToString(param.l$))
                        ]);
                    }, routeParams);
                case 2:
                    var routeParams = route_1_0.a;
                    return A3($author$project$Route$Twilogs$Day_$route.et, {
                        fC: _List_fromArray(["Twilogs", "Day_"]),
                        fM: {
                            bn: $elm$core$Maybe$Nothing,
                            bI: _List_fromArray([
                                $dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$StaticSegment("twilogs"),
                                $dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$DynamicSegment("day")
                            ])
                        }
                    }, function (param) {
                        return _List_fromArray([
                            _Utils_Tuple2("day", $author$project$Main$stringToString(param.ml))
                        ]);
                    }, routeParams);
                case 3:
                    return A3($author$project$Route$About$route.et, {
                        fC: _List_fromArray(["About"]),
                        fM: {
                            bn: $elm$core$Maybe$Nothing,
                            bI: _List_fromArray([
                                $dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$StaticSegment("about")
                            ])
                        }
                    }, function (param) {
                        return _List_Nil;
                    }, {});
                case 4:
                    return A3($author$project$Route$Articles$route.et, {
                        fC: _List_fromArray(["Articles"]),
                        fM: {
                            bn: $elm$core$Maybe$Nothing,
                            bI: _List_fromArray([
                                $dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$StaticSegment("articles")
                            ])
                        }
                    }, function (param) {
                        return _List_Nil;
                    }, {});
                case 5:
                    return A3($author$project$Route$Twilogs$route.et, {
                        fC: _List_fromArray(["Twilogs"]),
                        fM: {
                            bn: $elm$core$Maybe$Nothing,
                            bI: _List_fromArray([
                                $dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$StaticSegment("twilogs")
                            ])
                        }
                    }, function (param) {
                        return _List_Nil;
                    }, {});
                default:
                    return A3($author$project$Route$Index$route.et, {
                        fC: _List_fromArray(["Index"]),
                        fM: {
                            bn: $elm$core$Maybe$Nothing,
                            bI: _List_fromArray([
                                $dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$StaticSegment("index")
                            ])
                        }
                    }, function (param) {
                        return _List_Nil;
                    }, {});
            }
        }
    };
    var $lamdera$codecs$Lamdera$Wire3$decodeBytes_ = _LamderaCodecs_decodeBytes;
    var $author$project$Main$hotReloadData = _Platform_incomingPort("hotReloadData", $lamdera$codecs$Lamdera$Wire3$decodeBytes_);
    var $author$project$Main$ModelAbout = function (a) {
        return { $: 3, a: a };
    };
    var $author$project$Main$ModelArticles = function (a) {
        return { $: 4, a: a };
    };
    var $author$project$Main$ModelArticles__ArticleId_ = function (a) {
        return { $: 1, a: a };
    };
    var $author$project$Main$ModelArticles__Draft = function (a) {
        return { $: 0, a: a };
    };
    var $author$project$Main$ModelIndex = function (a) {
        return { $: 6, a: a };
    };
    var $author$project$Main$ModelTwilogs = function (a) {
        return { $: 5, a: a };
    };
    var $author$project$Main$ModelTwilogs__Day_ = function (a) {
        return { $: 2, a: a };
    };
    var $author$project$Main$MsgAbout = function (a) {
        return { $: 3, a: a };
    };
    var $author$project$Main$MsgArticles = function (a) {
        return { $: 4, a: a };
    };
    var $author$project$Main$MsgArticles__ArticleId_ = function (a) {
        return { $: 1, a: a };
    };
    var $author$project$Main$MsgArticles__Draft = function (a) {
        return { $: 0, a: a };
    };
    var $author$project$Main$MsgGlobal = function (a) {
        return { $: 7, a: a };
    };
    var $author$project$Main$MsgIndex = function (a) {
        return { $: 6, a: a };
    };
    var $author$project$Main$MsgTwilogs = function (a) {
        return { $: 5, a: a };
    };
    var $author$project$Main$MsgTwilogs__Day_ = function (a) {
        return { $: 2, a: a };
    };
    var $author$project$Effect$Batch = function (a) {
        return { $: 2, a: a };
    };
    var $author$project$Effect$batch = $author$project$Effect$Batch;
    var $author$project$Main$ModelErrorPage____ = function (a) {
        return { $: 7, a: a };
    };
    var $author$project$Main$MsgErrorPage____ = function (a) {
        return { $: 9, a: a };
    };
    var $author$project$ErrorPage$init = function (errorPage) {
        return _Utils_Tuple2({ dt: 0 }, $author$project$Effect$none);
    };
    var $author$project$Effect$FetchRouteData = function (a) {
        return { $: 4, a: a };
    };
    var $author$project$Effect$SetField = function (a) {
        return { $: 3, a: a };
    };
    var $author$project$Effect$Submit = function (a) {
        return { $: 5, a: a };
    };
    var $author$project$Effect$SubmitFetcher = function (a) {
        return { $: 6, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$Fetcher$Fetcher = $elm$core$Basics$identity;
    var $dillonkearns$elm_pages_v3_beta$Pages$Fetcher$map_fn = function (mapFn, _v0) {
        var fetcher = _v0;
        return {
            bm: A2($elm$core$Basics$composeR, fetcher.bm, mapFn),
            ci: fetcher.ci,
            mS: fetcher.mS,
            lO: fetcher.lO
        };
    }, $dillonkearns$elm_pages_v3_beta$Pages$Fetcher$map = F2($dillonkearns$elm_pages_v3_beta$Pages$Fetcher$map_fn);
    var $author$project$Effect$map_fn = function (fn, effect) {
        switch (effect.$) {
            case 0:
                return $author$project$Effect$None;
            case 1:
                var cmd = effect.a;
                return $author$project$Effect$Cmd(_Platform_map_fn(fn, cmd));
            case 2:
                var list = effect.a;
                return $author$project$Effect$Batch($elm$core$List$map_fn($author$project$Effect$map(fn), list));
            case 4:
                var fetchInfo = effect.a;
                return $author$project$Effect$FetchRouteData({
                    iW: fetchInfo.iW,
                    hn: A2($elm$core$Basics$composeR, fetchInfo.hn, fn)
                });
            case 5:
                var fetchInfo = effect.a;
                return $author$project$Effect$Submit({
                    hn: A2($elm$core$Basics$composeR, fetchInfo.hn, fn),
                    jK: fetchInfo.jK
                });
            case 3:
                var info = effect.a;
                return $author$project$Effect$SetField(info);
            default:
                var fetcher = effect.a;
                return $author$project$Effect$SubmitFetcher($dillonkearns$elm_pages_v3_beta$Pages$Fetcher$map_fn(fn, fetcher));
        }
    }, $author$project$Effect$map = F2($author$project$Effect$map_fn);
    var $elm$core$Tuple$mapBoth_fn = function (funcA, funcB, _v0) {
        var x = _v0.a;
        var y = _v0.b;
        return _Utils_Tuple2(funcA(x), funcB(y));
    }, $elm$core$Tuple$mapBoth = F3($elm$core$Tuple$mapBoth_fn);
    var $author$project$ErrorPage$notFound = $author$project$ErrorPage$NotFound;
    var $author$project$Main$initErrorPage = function (pageData) {
        return $elm$core$Tuple$mapBoth_fn($author$project$Main$ModelErrorPage____, $author$project$Effect$map($author$project$Main$MsgErrorPage____), $author$project$ErrorPage$init(function () {
            if (pageData.$ === 8) {
                var errorPage = pageData.a;
                return errorPage;
            }
            else {
                var otherwise_1_1_3_0_0 = pageData;
                return $author$project$ErrorPage$notFound;
            }
        }()));
    };
    var $elm$core$Maybe$map2_fn = function (func, ma, mb) {
        if (ma.$ === 1) {
            return $elm$core$Maybe$Nothing;
        }
        else {
            var a = ma.a;
            if (mb.$ === 1) {
                return $elm$core$Maybe$Nothing;
            }
            else {
                var b = mb.a;
                return $elm$core$Maybe$Just(A2(func, a, b));
            }
        }
    }, $elm$core$Maybe$map2_fn_unwrapped = function (func, ma, mb) {
        if (ma.$ === 1) {
            return $elm$core$Maybe$Nothing;
        }
        else {
            var a = ma.a;
            if (mb.$ === 1) {
                return $elm$core$Maybe$Nothing;
            }
            else {
                var b = mb.a;
                return $elm$core$Maybe$Just(func(a, b));
            }
        }
    }, $elm$core$Maybe$map2 = F3($elm$core$Maybe$map2_fn);
    var $elm$http$Http$BadBody = function (a) {
        return { $: 4, a: a };
    };
    var $elm$core$Result$andThen_fn = function (callback, result) {
        if (!result.$) {
            var value = result.a;
            return callback(value);
        }
        else {
            var msg = result.a;
            return $elm$core$Result$Err(msg);
        }
    }, $elm$core$Result$andThen = F2($elm$core$Result$andThen_fn);
    var $elm$core$Result$fromMaybe_fn = function (err, maybe) {
        if (!maybe.$) {
            var v = maybe.a;
            return $elm$core$Result$Ok(v);
        }
        else {
            return $elm$core$Result$Err(err);
        }
    }, $elm$core$Result$fromMaybe = F2($elm$core$Result$fromMaybe_fn);
    var $dillonkearns$elm_pages_v3_beta$Pages$Fetcher$submit_fn = function (byteDecoder, options) {
        return {
            bm: function (bytesResult) {
                return $elm$core$Result$andThen_fn(function (okBytes) {
                    return $elm$core$Result$fromMaybe_fn($elm$http$Http$BadBody("Couldn't decode bytes."), $elm$bytes$Bytes$Decode$decode_fn(byteDecoder, okBytes));
                }, bytesResult);
            },
            ci: options.ci,
            mS: _List_Cons(_Utils_Tuple2("elm-pages-action-only", "true"), options.mS),
            lO: $elm$core$Maybe$Nothing
        };
    }, $dillonkearns$elm_pages_v3_beta$Pages$Fetcher$submit = F2($dillonkearns$elm_pages_v3_beta$Pages$Fetcher$submit_fn);
    var $author$project$Shared$OnPageChange = function (a) {
        return { $: 0, a: a };
    };
    var $author$project$Shared$Data_fn = function (repos, cmsArticles, zennArticles, qiitaArticles, twilogArchives) {
        return { f6: cmsArticles, io: qiitaArticles, iq: repos, iD: twilogArchives, iI: zennArticles };
    }, $author$project$Shared$Data = F5($author$project$Shared$Data_fn);
    var $dillonkearns$elm_pages_v3_beta$BackendTask$map5_fn = function (combineFn, request1, request2, request3, request4, request5) {
        return $dillonkearns$elm_pages_v3_beta$BackendTask$map2_fn($elm$core$Basics$apR, request5, $dillonkearns$elm_pages_v3_beta$BackendTask$map2_fn($elm$core$Basics$apR, request4, $dillonkearns$elm_pages_v3_beta$BackendTask$map2_fn($elm$core$Basics$apR, request3, $dillonkearns$elm_pages_v3_beta$BackendTask$map2_fn($elm$core$Basics$apR, request2, $dillonkearns$elm_pages_v3_beta$BackendTask$map2_fn($elm$core$Basics$apR, request1, $dillonkearns$elm_pages_v3_beta$BackendTask$succeed(combineFn))))));
    }, $dillonkearns$elm_pages_v3_beta$BackendTask$map5 = F6($dillonkearns$elm_pages_v3_beta$BackendTask$map5_fn);
    var $author$project$Shared$CmsArticleMetadata_fn = function (contentId, publishedAt, revisedAt, title, image) {
        return { f8: contentId, gy: image, c6: publishedAt, ir: revisedAt, jE: title };
    }, $author$project$Shared$CmsArticleMetadata = F5($author$project$Shared$CmsArticleMetadata_fn);
    var $elm_community$json_extra$Json$Decode$Extra$andMap_a0 = $elm$core$Basics$apR, $elm_community$json_extra$Json$Decode$Extra$andMap = $elm$json$Json$Decode$map2($elm_community$json_extra$Json$Decode$Extra$andMap_a0);
    var $dillonkearns$elm_pages_v3_beta$BackendTask$mapError_fn = function (mapFn, requestInfo) {
        if (requestInfo.$ === 1) {
            var value = requestInfo.a;
            return $dillonkearns$elm_pages_v3_beta$Pages$StaticHttpRequest$ApiRoute($elm$core$Result$mapError_fn(mapFn, value));
        }
        else {
            var urls = requestInfo.a;
            var lookupFn = requestInfo.b;
            return $dillonkearns$elm_pages_v3_beta$Pages$StaticHttpRequest$Request_fn(urls, A2($dillonkearns$elm_pages_v3_beta$BackendTask$mapLookupFnError, mapFn, lookupFn));
        }
    }, $dillonkearns$elm_pages_v3_beta$BackendTask$mapError = F2($dillonkearns$elm_pages_v3_beta$BackendTask$mapError_fn);
    var $dillonkearns$elm_pages_v3_beta$BackendTask$mapLookupFnError_fn = function (fn, lookupFn, maybeMock, requests) {
        return $dillonkearns$elm_pages_v3_beta$BackendTask$mapError_fn(fn, A2(lookupFn, maybeMock, requests));
    }, $dillonkearns$elm_pages_v3_beta$BackendTask$mapLookupFnError_fn_unwrapped = function (fn, lookupFn, maybeMock, requests) {
        return $dillonkearns$elm_pages_v3_beta$BackendTask$mapError_fn(fn, lookupFn(maybeMock, requests));
    }, $dillonkearns$elm_pages_v3_beta$BackendTask$mapLookupFnError = F4($dillonkearns$elm_pages_v3_beta$BackendTask$mapLookupFnError_fn);
    var $dillonkearns$elm_pages_v3_beta$BackendTask$allowFatal = function (backendTask) {
        return $dillonkearns$elm_pages_v3_beta$BackendTask$mapError_fn(function ($) {
            return $.mE;
        }, backendTask);
    };
    var $dillonkearns$elm_pages_v3_beta$BackendTask$Http$emptyBody = $dillonkearns$elm_pages_v3_beta$Pages$Internal$StaticHttpBody$EmptyBody;
    var $dillonkearns$elm_pages_v3_beta$BackendTask$Env$MissingEnvVariable = $elm$core$Basics$identity;
    var $dillonkearns$elm_pages_v3_beta$BackendTask$Http$ExpectJson = function (a) {
        return { $: 0, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$BackendTask$Http$expectJson = $dillonkearns$elm_pages_v3_beta$BackendTask$Http$ExpectJson;
    var $dillonkearns$elm_pages_v3_beta$BackendTask$Http$jsonBody = function (content) {
        return $dillonkearns$elm_pages_v3_beta$Pages$Internal$StaticHttpBody$JsonBody(content);
    };
    var $elm$json$Json$Decode$null = _Json_decodeNull;
    var $elm$json$Json$Decode$nullable = function (decoder) {
        return $elm$json$Json$Decode$oneOf(_List_fromArray([
            $elm$json$Json$Decode$null($elm$core$Maybe$Nothing),
            _Json_map1_fn($elm$core$Maybe$Just, decoder)
        ]));
    };
    var $dillonkearns$elm_pages_v3_beta$BackendTask$Http$encodeOptions = function (options) {
        return $elm$json$Json$Encode$object($elm$core$List$filterMap_fn(function (_v1) {
            var a = _v1.a;
            var b = _v1.b;
            return $elm$core$Maybe$map_fn($elm$core$Tuple$pair(a), b);
        }, _List_fromArray([
            _Utils_Tuple2("cache", $elm$core$Maybe$map_fn($elm$json$Json$Encode$string, $elm$core$Maybe$map_fn(function (cacheStrategy) {
                switch (cacheStrategy) {
                    case 0:
                        return "no-store";
                    case 1:
                        return "no-cache";
                    case 2:
                        return "reload";
                    case 3:
                        return "force-cache";
                    default:
                        return "only-if-cached";
                }
            }, options.f3))),
            _Utils_Tuple2("retry", $elm$core$Maybe$map_fn($elm$json$Json$Encode$int, options.lA)),
            _Utils_Tuple2("timeout", $elm$core$Maybe$map_fn($elm$json$Json$Encode$int, options.lJ)),
            _Utils_Tuple2("cachePath", $elm$core$Maybe$map_fn($elm$json$Json$Encode$string, options.f2))
        ])));
    };
    var $dillonkearns$elm_pages_v3_beta$BackendTask$Http$BadBody_fn = function (a, b) {
        return { $: 4, a: a, b: b };
    }, $dillonkearns$elm_pages_v3_beta$BackendTask$Http$BadBody = F2($dillonkearns$elm_pages_v3_beta$BackendTask$Http$BadBody_fn);
    var $dillonkearns$elm_pages_v3_beta$BackendTask$Http$BadStatus_fn = function (a, b) {
        return { $: 3, a: a, b: b };
    }, $dillonkearns$elm_pages_v3_beta$BackendTask$Http$BadStatus = F2($dillonkearns$elm_pages_v3_beta$BackendTask$Http$BadStatus_fn);
    var $dillonkearns$elm_pages_v3_beta$BackendTask$Http$NetworkError = { $: 2 };
    var $dillonkearns$elm_pages_v3_beta$BackendTask$Http$Timeout = { $: 1 };
    var $dillonkearns$elm_pages_v3_beta$BackendTask$Http$errorToString = function (error) {
        return {
            hJ: $dillonkearns$elm_pages_v3_beta$TerminalText$toString(function () {
                switch (error.$) {
                    case 0:
                        var string = error.a;
                        return _List_fromArray([
                            $dillonkearns$elm_pages_v3_beta$TerminalText$text("BadUrl " + string)
                        ]);
                    case 1:
                        return _List_fromArray([
                            $dillonkearns$elm_pages_v3_beta$TerminalText$text("Timeout")
                        ]);
                    case 2:
                        return _List_fromArray([
                            $dillonkearns$elm_pages_v3_beta$TerminalText$text("NetworkError")
                        ]);
                    case 3:
                        var string = error.b;
                        return _List_fromArray([
                            $dillonkearns$elm_pages_v3_beta$TerminalText$text("BadStatus: " + string)
                        ]);
                    default:
                        var string = error.b;
                        return _List_fromArray([
                            $dillonkearns$elm_pages_v3_beta$TerminalText$text("BadBody: " + string)
                        ]);
                }
            }()),
            jE: "HTTP Error"
        };
    };
    var $dillonkearns$elm_pages_v3_beta$BackendTask$Http$expectToString = function (expect) {
        switch (expect.$) {
            case 0:
                return "ExpectJson";
            case 1:
                return "ExpectString";
            case 2:
                return "ExpectBytes";
            case 3:
                return "ExpectWhatever";
            default:
                var toExpect = expect.a;
                return $dillonkearns$elm_pages_v3_beta$BackendTask$Http$expectToString(toExpect({ mS: $elm$core$Dict$empty, aF: 123, a4: "", lO: "" }));
        }
    };
    var $dillonkearns$elm_pages_v3_beta$RequestsAndPending$Response_fn = function (a, b) {
        return { $: 0, a: a, b: b };
    }, $dillonkearns$elm_pages_v3_beta$RequestsAndPending$Response = F2($dillonkearns$elm_pages_v3_beta$RequestsAndPending$Response_fn);
    var $dillonkearns$elm_pages_v3_beta$RequestsAndPending$BytesBody = function (a) {
        return { $: 0, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$RequestsAndPending$JsonBody = function (a) {
        return { $: 2, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$RequestsAndPending$StringBody = function (a) {
        return { $: 1, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$RequestsAndPending$WhateverBody = { $: 3 };
    var $dillonkearns$elm_pages_v3_beta$RequestsAndPending$bodyDecoder = _Json_andThen_fn(function (bodyKind) {
        return _Json_decodeField_fn("body", function () {
            switch (bodyKind) {
                case "bytes":
                    return _Json_andThen_fn(function (base64String) {
                        return $elm$core$Maybe$withDefault_fn($elm$json$Json$Decode$fail("Couldn't parse base64 string into Bytes."), $elm$core$Maybe$map_fn(A2($elm$core$Basics$composeR, $dillonkearns$elm_pages_v3_beta$RequestsAndPending$BytesBody, $elm$json$Json$Decode$succeed), $danfishgold$base64_bytes$Base64$toBytes(base64String)));
                    }, $elm$json$Json$Decode$string);
                case "string":
                    return _Json_map1_fn($dillonkearns$elm_pages_v3_beta$RequestsAndPending$StringBody, $elm$json$Json$Decode$string);
                case "json":
                    return _Json_map1_fn($dillonkearns$elm_pages_v3_beta$RequestsAndPending$JsonBody, $elm$json$Json$Decode$value);
                case "whatever":
                    return $elm$json$Json$Decode$succeed($dillonkearns$elm_pages_v3_beta$RequestsAndPending$WhateverBody);
                default:
                    return $elm$json$Json$Decode$fail("Unexpected bodyKind.");
            }
        }());
    }, _Json_decodeField_fn("bodyKind", $elm$json$Json$Decode$string));
    var $dillonkearns$elm_pages_v3_beta$RequestsAndPending$RawResponse_fn = function (statusCode, statusText, headers, url) {
        return { mS: headers, aF: statusCode, a4: statusText, lO: url };
    }, $dillonkearns$elm_pages_v3_beta$RequestsAndPending$RawResponse = F4($dillonkearns$elm_pages_v3_beta$RequestsAndPending$RawResponse_fn);
    var $dillonkearns$elm_pages_v3_beta$RequestsAndPending$responseDecoder = _Json_map4_fn($dillonkearns$elm_pages_v3_beta$RequestsAndPending$RawResponse, _Json_decodeField_fn("statusCode", $elm$json$Json$Decode$int), _Json_decodeField_fn("statusText", $elm$json$Json$Decode$string), _Json_decodeField_fn("headers", $elm$json$Json$Decode$dict($elm$json$Json$Decode$string)), _Json_decodeField_fn("url", $elm$json$Json$Decode$string));
    var $dillonkearns$elm_pages_v3_beta$RequestsAndPending$decoder = _Json_map2_fn($dillonkearns$elm_pages_v3_beta$RequestsAndPending$Response, $elm$json$Json$Decode$maybe($dillonkearns$elm_pages_v3_beta$RequestsAndPending$responseDecoder), $dillonkearns$elm_pages_v3_beta$RequestsAndPending$bodyDecoder);
    var $dillonkearns$elm_pages_v3_beta$RequestsAndPending$NetworkError = 0;
    var $dillonkearns$elm_pages_v3_beta$RequestsAndPending$Timeout = 1;
    var $dillonkearns$elm_pages_v3_beta$RequestsAndPending$errorDecoder = _Json_andThen_fn(function (errorCode) {
        switch (errorCode) {
            case "NetworkError":
                return $elm$json$Json$Decode$succeed(0);
            case "Timeout":
                return $elm$json$Json$Decode$succeed(1);
            default:
                return $elm$json$Json$Decode$fail("Unhandled error code.");
        }
    }, $elm$json$Json$Decode$string);
    var $elm$core$Result$toMaybe = function (result) {
        if (!result.$) {
            var v = result.a;
            return $elm$core$Maybe$Just(v);
        }
        else {
            return $elm$core$Maybe$Nothing;
        }
    };
    var $dillonkearns$elm_pages_v3_beta$RequestsAndPending$get_fn = function (key, requestsAndPending) {
        return $elm$core$Result$toMaybe(_Json_run_fn(_Json_decodeField_fn(key, _Json_decodeField_fn("response", $elm$json$Json$Decode$oneOf(_List_fromArray([
            _Json_map1_fn($elm$core$Result$Err, _Json_decodeField_fn("elm-pages-internal-error", $dillonkearns$elm_pages_v3_beta$RequestsAndPending$errorDecoder)),
            _Json_map1_fn($elm$core$Result$Ok, $dillonkearns$elm_pages_v3_beta$RequestsAndPending$decoder)
        ])))), requestsAndPending));
    }, $dillonkearns$elm_pages_v3_beta$RequestsAndPending$get = F2($dillonkearns$elm_pages_v3_beta$RequestsAndPending$get_fn);
    var $dillonkearns$elm_pages_v3_beta$FatalError$recoverable_fn = function (info, value) {
        return {
            mE: $dillonkearns$elm_pages_v3_beta$FatalError$build(info),
            ke: value
        };
    }, $dillonkearns$elm_pages_v3_beta$FatalError$recoverable = F2($dillonkearns$elm_pages_v3_beta$FatalError$recoverable_fn);
    var $dillonkearns$elm_pages_v3_beta$BackendTask$Http$toResultThing = function (_v0) {
        toResultThing: while (true) {
            var expect = _v0.a;
            var body = _v0.b;
            var maybeResponse = _v0.c;
            var _v1 = _Utils_Tuple3(expect, body, maybeResponse);
            _v1$5: while (true) {
                switch (_v1.a.$) {
                    case 4:
                        if (!_v1.c.$) {
                            var toExpect = _v1.a.a;
                            var rawResponse = _v1.c.a;
                            var asMetadata = { mS: rawResponse.mS, aF: rawResponse.aF, a4: rawResponse.a4, lO: rawResponse.lO };
                            var $temp$_v0 = _Utils_Tuple3(toExpect(asMetadata), body, maybeResponse);
                            _v0 = $temp$_v0;
                            continue toResultThing;
                        }
                        else {
                            break _v1$5;
                        }
                    case 0:
                        if (_v1.b.$ === 2) {
                            var decoder = _v1.a.a;
                            var json = _v1.b.a;
                            return $elm$core$Result$mapError_fn(function (error) {
                                return $dillonkearns$elm_pages_v3_beta$BackendTask$Http$BadBody_fn($elm$core$Maybe$Just(error), $elm$json$Json$Decode$errorToString(error));
                            }, _Json_run_fn(decoder, json));
                        }
                        else {
                            break _v1$5;
                        }
                    case 1:
                        if (_v1.b.$ === 1) {
                            var mapStringFn = _v1.a.a;
                            var string = _v1.b.a;
                            return $elm$core$Result$Ok(mapStringFn(string));
                        }
                        else {
                            break _v1$5;
                        }
                    case 2:
                        if (!_v1.b.$) {
                            var bytesDecoder = _v1.a.a;
                            var rawBytes = _v1.b.a;
                            return $elm$core$Result$fromMaybe_fn($dillonkearns$elm_pages_v3_beta$BackendTask$Http$BadBody_fn($elm$core$Maybe$Nothing, "Bytes decoding failed."), $elm$bytes$Bytes$Decode$decode_fn(bytesDecoder, rawBytes));
                        }
                        else {
                            break _v1$5;
                        }
                    default:
                        if (_v1.b.$ === 3) {
                            var whateverValue = _v1.a.a;
                            var _v2 = _v1.b;
                            return $elm$core$Result$Ok(whateverValue);
                        }
                        else {
                            break _v1$5;
                        }
                }
            }
            return $elm$core$Result$Err($dillonkearns$elm_pages_v3_beta$BackendTask$Http$BadBody_fn($elm$core$Maybe$Nothing, "Unexpected combination, internal error"));
        }
    };
    var $dillonkearns$elm_pages_v3_beta$BackendTask$Http$requestRaw_fn = function (request__, expect) {
        var request_ = {
            hJ: request__.hJ,
            iQ: request__.iQ,
            mS: _List_Cons(_Utils_Tuple2("elm-pages-internal", $dillonkearns$elm_pages_v3_beta$BackendTask$Http$expectToString(expect)), request__.mS),
            nh: request__.nh,
            lO: request__.lO
        };
        return $dillonkearns$elm_pages_v3_beta$Pages$StaticHttpRequest$Request_fn(_List_fromArray([request_]), F2(function (maybeMockResolver, rawResponseDict) {
            return $dillonkearns$elm_pages_v3_beta$BackendTask$mapError_fn(function (error) {
                return $dillonkearns$elm_pages_v3_beta$FatalError$recoverable_fn($dillonkearns$elm_pages_v3_beta$BackendTask$Http$errorToString(error), error);
            }, $dillonkearns$elm_pages_v3_beta$BackendTask$fromResult($elm$core$Result$andThen_fn(function (_v4) {
                var maybeResponse = _v4.a;
                var body = _v4.b;
                var maybeBadResponse = function () {
                    if (!maybeResponse.$) {
                        var response = maybeResponse.a;
                        if (!((response.aF >= 200) && (response.aF < 300))) {
                            switch (body.$) {
                                case 1:
                                    var s = body.a;
                                    return $elm$core$Maybe$Just($dillonkearns$elm_pages_v3_beta$BackendTask$Http$BadStatus_fn({ mS: response.mS, aF: response.aF, a4: response.a4, lO: response.lO }, s));
                                case 0:
                                    var bytes = body.a;
                                    return $elm$core$Maybe$Just($dillonkearns$elm_pages_v3_beta$BackendTask$Http$BadStatus_fn({ mS: response.mS, aF: response.aF, a4: response.a4, lO: response.lO }, $elm$core$Maybe$withDefault_fn("", $danfishgold$base64_bytes$Base64$fromBytes(bytes))));
                                case 2:
                                    var value = body.a;
                                    return $elm$core$Maybe$Just($dillonkearns$elm_pages_v3_beta$BackendTask$Http$BadStatus_fn({ mS: response.mS, aF: response.aF, a4: response.a4, lO: response.lO }, _Json_encode_fn(0, value)));
                                default:
                                    return $elm$core$Maybe$Just($dillonkearns$elm_pages_v3_beta$BackendTask$Http$BadStatus_fn({ mS: response.mS, aF: response.aF, a4: response.a4, lO: response.lO }, ""));
                            }
                        }
                        else {
                            return $elm$core$Maybe$Nothing;
                        }
                    }
                    else {
                        return $elm$core$Maybe$Nothing;
                    }
                }();
                if (!maybeBadResponse.$) {
                    var badResponse = maybeBadResponse.a;
                    return $elm$core$Result$Err(badResponse);
                }
                else {
                    return $dillonkearns$elm_pages_v3_beta$BackendTask$Http$toResultThing(_Utils_Tuple3(expect, body, maybeResponse));
                }
            }, function (maybeResponse) {
                if (maybeResponse.$ === 1) {
                    return $elm$core$Result$Err($dillonkearns$elm_pages_v3_beta$BackendTask$Http$BadBody_fn($elm$core$Maybe$Nothing, "INTERNAL ERROR - expected request" + request_.lO));
                }
                else {
                    if (!maybeResponse.a.$) {
                        var rawResponse = maybeResponse.a.a;
                        return $elm$core$Result$Ok(rawResponse);
                    }
                    else {
                        if (!maybeResponse.a.a) {
                            var _v2 = maybeResponse.a.a;
                            return $elm$core$Result$Err($dillonkearns$elm_pages_v3_beta$BackendTask$Http$NetworkError);
                        }
                        else {
                            var _v3 = maybeResponse.a.a;
                            return $elm$core$Result$Err($dillonkearns$elm_pages_v3_beta$BackendTask$Http$Timeout);
                        }
                    }
                }
            }(function () {
                if (!maybeMockResolver.$) {
                    var mockResolver = maybeMockResolver.a;
                    return $elm$core$Maybe$map_fn($elm$core$Result$Ok, mockResolver(request_));
                }
                else {
                    return $dillonkearns$elm_pages_v3_beta$RequestsAndPending$get_fn($dillonkearns$elm_pages_v3_beta$Pages$StaticHttp$Request$hash(request_), rawResponseDict);
                }
            }()))));
        }));
    }, $dillonkearns$elm_pages_v3_beta$BackendTask$Http$requestRaw = F2($dillonkearns$elm_pages_v3_beta$BackendTask$Http$requestRaw_fn);
    var $dillonkearns$elm_pages_v3_beta$BackendTask$Http$request_fn = function (request__, expect) {
        var request_ = {
            hJ: request__.hJ,
            iQ: $elm$core$Maybe$Just($dillonkearns$elm_pages_v3_beta$BackendTask$Http$encodeOptions({ f2: $elm$core$Maybe$Nothing, f3: $elm$core$Maybe$Nothing, lA: request__.lA, lJ: request__.lJ })),
            mS: request__.mS,
            nh: request__.nh,
            lO: request__.lO
        };
        return $dillonkearns$elm_pages_v3_beta$BackendTask$Http$requestRaw_fn(request_, expect);
    }, $dillonkearns$elm_pages_v3_beta$BackendTask$Http$request = F2($dillonkearns$elm_pages_v3_beta$BackendTask$Http$request_fn);
    var $dillonkearns$elm_pages_v3_beta$BackendTask$Internal$Request$request = function (params) {
        var expect = params.kW;
        var body = params.hJ;
        var name = params.nq;
        return $dillonkearns$elm_pages_v3_beta$BackendTask$onError_fn(function (_v0) {
            return $dillonkearns$elm_pages_v3_beta$BackendTask$Internal$Request$request(params);
        }, $dillonkearns$elm_pages_v3_beta$BackendTask$Http$request_fn({ hJ: body, mS: _List_Nil, nh: "GET", lA: $elm$core$Maybe$Nothing, lJ: $elm$core$Maybe$Nothing, lO: "elm-pages-internal://" + name }, expect));
    };
    var $dillonkearns$elm_pages_v3_beta$BackendTask$Env$get = function (envVariableName) {
        return $dillonkearns$elm_pages_v3_beta$BackendTask$Internal$Request$request({
            hJ: $dillonkearns$elm_pages_v3_beta$BackendTask$Http$jsonBody($elm$json$Json$Encode$string(envVariableName)),
            kW: $dillonkearns$elm_pages_v3_beta$BackendTask$Http$expectJson($elm$json$Json$Decode$nullable($elm$json$Json$Decode$string)),
            nq: "env"
        });
    };
    var $dillonkearns$elm_pages_v3_beta$TerminalText$yellow = function (inner) {
        return $dillonkearns$elm_pages_v3_beta$TerminalText$Style_fn(_Utils_update($dillonkearns$elm_pages_v3_beta$TerminalText$blankStyle, {
            bi: $elm$core$Maybe$Just($vito$elm_ansi$Ansi$Yellow)
        }), inner);
    };
    var $dillonkearns$elm_pages_v3_beta$BackendTask$Env$expect = function (envVariableName) {
        return $dillonkearns$elm_pages_v3_beta$BackendTask$andThen_fn(function (maybeValue) {
            return $dillonkearns$elm_pages_v3_beta$BackendTask$fromResult($elm$core$Result$fromMaybe_fn($dillonkearns$elm_pages_v3_beta$FatalError$recoverable_fn({
                hJ: $dillonkearns$elm_pages_v3_beta$TerminalText$toString(_List_fromArray([
                    $dillonkearns$elm_pages_v3_beta$TerminalText$text("BackendTask.Env.expect was expecting a variable `"),
                    $dillonkearns$elm_pages_v3_beta$TerminalText$yellow(envVariableName),
                    $dillonkearns$elm_pages_v3_beta$TerminalText$text("` but couldn't find a variable with that name.")
                ])),
                jE: "Missing Env Variable"
            }, envVariableName), maybeValue));
        }, $dillonkearns$elm_pages_v3_beta$BackendTask$Env$get(envVariableName));
    };
    var $author$project$Shared$cmsGet_fn = function (url, decoder) {
        return $dillonkearns$elm_pages_v3_beta$BackendTask$andThen_fn(function (microCmsApiKey) {
            return $dillonkearns$elm_pages_v3_beta$BackendTask$allowFatal($dillonkearns$elm_pages_v3_beta$BackendTask$Http$request_fn({
                hJ: $dillonkearns$elm_pages_v3_beta$BackendTask$Http$emptyBody,
                mS: _List_fromArray([
                    _Utils_Tuple2("X-MICROCMS-API-KEY", microCmsApiKey)
                ]),
                nh: "GET",
                lA: $elm$core$Maybe$Nothing,
                lJ: $elm$core$Maybe$Just(2000),
                lO: url
            }, $dillonkearns$elm_pages_v3_beta$BackendTask$Http$expectJson(decoder)));
        }, $dillonkearns$elm_pages_v3_beta$BackendTask$allowFatal($dillonkearns$elm_pages_v3_beta$BackendTask$Env$expect("MICROCMS_API_KEY")));
    }, $author$project$Shared$cmsGet = F2($author$project$Shared$cmsGet_fn);
    var $author$project$Shared$CmsImage_fn = function (url, height, width) {
        return { eu: height, lO: url, e9: width };
    }, $author$project$Shared$CmsImage = F3($author$project$Shared$CmsImage_fn);
    var $author$project$Shared$cmsImageDecoder = _Json_map2_fn($elm_community$json_extra$Json$Decode$Extra$andMap_a0, _Json_decodeField_fn("width", $elm$json$Json$Decode$int), _Json_map2_fn($elm_community$json_extra$Json$Decode$Extra$andMap_a0, _Json_decodeField_fn("height", $elm$json$Json$Decode$int), _Json_map2_fn($elm_community$json_extra$Json$Decode$Extra$andMap_a0, _Json_decodeField_fn("url", $elm$json$Json$Decode$string), $elm$json$Json$Decode$succeed($author$project$Shared$CmsImage))));
    var $author$project$Markdown$problemToString = function (problem) {
        switch (problem.$) {
            case 0:
                var string = problem.a;
                return "Expecting " + string;
            case 1:
                return "Expecting int";
            case 2:
                return "Expecting hex";
            case 3:
                return "Expecting octal";
            case 4:
                return "Expecting binary";
            case 5:
                return "Expecting float";
            case 6:
                return "Expecting number";
            case 7:
                return "Expecting variable";
            case 8:
                var string = problem.a;
                return "Expecting symbol " + string;
            case 9:
                var string = problem.a;
                return "Expecting keyword " + string;
            case 10:
                return "Expecting keyword end";
            case 11:
                return "Unexpected char";
            case 12:
                var problemDescription = problem.a;
                return problemDescription;
            default:
                return "Bad repeat";
        }
    };
    var $author$project$Markdown$deadEndToString = function (deadEnd) {
        return "Problem at row " + ($elm$core$String$fromInt(deadEnd.n6) + (", col " + ($elm$core$String$fromInt(deadEnd.mf) + ("\n" + $author$project$Markdown$problemToString(deadEnd.nS)))));
    };
    var $author$project$Markdown$deadEndsToString_a0 = $elm$core$List$map($author$project$Markdown$deadEndToString), $author$project$Markdown$deadEndsToString_a1 = $elm$core$String$join("\n"), $author$project$Markdown$deadEndsToString = A2($elm$core$Basics$composeR, $author$project$Markdown$deadEndsToString_a0, $author$project$Markdown$deadEndsToString_a1);
    var $elm_community$json_extra$Json$Decode$Extra$fromResult = function (result) {
        if (!result.$) {
            var successValue = result.a;
            return $elm$json$Json$Decode$succeed(successValue);
        }
        else {
            var errorMessage = result.a;
            return $elm$json$Json$Decode$fail(errorMessage);
        }
    };
    var $elm$core$String$toFloat = _String_toFloat;
    var $rtfeldman$elm_iso8601_date_strings$Iso8601$fractionsOfASecondInMs = $elm$parser$Parser$Advanced$andThen_fn(function (str) {
        if ($elm$core$String$length(str) <= 9) {
            var _v0 = $elm$core$String$toFloat("0." + str);
            if (!_v0.$) {
                var floatVal = _v0.a;
                return $elm$parser$Parser$succeed($elm$core$Basics$round(floatVal * 1000));
            }
            else {
                return $elm$parser$Parser$problem("Invalid float: \"" + (str + "\""));
            }
        }
        else {
            return $elm$parser$Parser$problem("Expected at most 9 digits, but got " + $elm$core$String$fromInt($elm$core$String$length(str)));
        }
    }, $elm$parser$Parser$getChompedString($elm$parser$Parser$chompWhile($elm$core$Char$isDigit)));
    var $rtfeldman$elm_iso8601_date_strings$Iso8601$fromParts_fn = function (monthYearDayMs, hour, minute, second, ms, utcOffsetMinutes) {
        return $elm$time$Time$millisToPosix((((monthYearDayMs + (((hour * 60) * 60) * 1000)) + (((minute - utcOffsetMinutes) * 60) * 1000)) + (second * 1000)) + ms);
    }, $rtfeldman$elm_iso8601_date_strings$Iso8601$fromParts = F6($rtfeldman$elm_iso8601_date_strings$Iso8601$fromParts_fn);
    var $elm$parser$Parser$Done = function (a) {
        return { $: 1, a: a };
    };
    var $elm$parser$Parser$Loop = function (a) {
        return { $: 0, a: a };
    };
    var $elm$core$String$append = _String_append;
    var $elm$parser$Parser$Advanced$loopHelp_fn = function (p, state, callback, s0) {
        loopHelp: while (true) {
            var _v0 = callback(state);
            var parse = _v0;
            var _v1 = parse(s0);
            if (!_v1.$) {
                var p1 = _v1.a;
                var step = _v1.b;
                var s1 = _v1.c;
                if (!step.$) {
                    var newState = step.a;
                    var $temp$p = p || p1, $temp$state = newState, $temp$callback = callback, $temp$s0 = s1;
                    p = $temp$p;
                    state = $temp$state;
                    callback = $temp$callback;
                    s0 = $temp$s0;
                    continue loopHelp;
                }
                else {
                    var result = step.a;
                    return $elm$parser$Parser$Advanced$Good_fn(p || p1, result, s1);
                }
            }
            else {
                var p1 = _v1.a;
                var x = _v1.b;
                return $elm$parser$Parser$Advanced$Bad_fn(p || p1, x);
            }
        }
    }, $elm$parser$Parser$Advanced$loopHelp = F4($elm$parser$Parser$Advanced$loopHelp_fn);
    var $elm$parser$Parser$Advanced$loop_fn = function (state, callback) {
        return function (s) {
            return $elm$parser$Parser$Advanced$loopHelp_fn(false, state, callback, s);
        };
    }, $elm$parser$Parser$Advanced$loop = F2($elm$parser$Parser$Advanced$loop_fn);
    var $elm$parser$Parser$Advanced$Done = function (a) {
        return { $: 1, a: a };
    };
    var $elm$parser$Parser$Advanced$Loop = function (a) {
        return { $: 0, a: a };
    };
    var $elm$parser$Parser$toAdvancedStep = function (step) {
        if (!step.$) {
            var s = step.a;
            return $elm$parser$Parser$Advanced$Loop(s);
        }
        else {
            var a = step.a;
            return $elm$parser$Parser$Advanced$Done(a);
        }
    };
    var $elm$parser$Parser$loop_fn = function (state, callback) {
        return $elm$parser$Parser$Advanced$loop_fn(state, function (s) {
            return $elm$parser$Parser$Advanced$map_fn($elm$parser$Parser$toAdvancedStep, callback(s));
        });
    }, $elm$parser$Parser$loop = F2($elm$parser$Parser$loop_fn);
    var $rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt = function (quantity) {
        var helper = function (str) {
            if (_Utils_eq($elm$core$String$length(str), quantity)) {
                var _v0 = $elm$core$String$toInt(str);
                if (!_v0.$) {
                    var intVal = _v0.a;
                    return $elm$parser$Parser$Advanced$map_fn($elm$parser$Parser$Done, $elm$parser$Parser$succeed(intVal));
                }
                else {
                    return $elm$parser$Parser$problem("Invalid integer: \"" + (str + "\""));
                }
            }
            else {
                return $elm$parser$Parser$Advanced$map_fn(function (nextChar) {
                    return $elm$parser$Parser$Loop(_String_append_fn(str, nextChar));
                }, $elm$parser$Parser$getChompedString($elm$parser$Parser$chompIf($elm$core$Char$isDigit)));
            }
        };
        return $elm$parser$Parser$loop_fn("", helper);
    };
    var $elm$parser$Parser$ExpectingSymbol = function (a) {
        return { $: 8, a: a };
    };
    var $elm$parser$Parser$Advanced$symbol = $elm$parser$Parser$Advanced$token;
    var $elm$parser$Parser$symbol = function (str) {
        return $elm$parser$Parser$Advanced$symbol($elm$parser$Parser$Advanced$Token_fn(str, $elm$parser$Parser$ExpectingSymbol(str)));
    };
    var $rtfeldman$elm_iso8601_date_strings$Iso8601$epochYear = 1970;
    var $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay = function (day) {
        return $elm$parser$Parser$problem("Invalid day: " + $elm$core$String$fromInt(day));
    };
    var $rtfeldman$elm_iso8601_date_strings$Iso8601$isLeapYear = function (year) {
        return (!_Basics_modBy_fn(4, year)) && ((!(!_Basics_modBy_fn(100, year))) || (!_Basics_modBy_fn(400, year)));
    };
    var $rtfeldman$elm_iso8601_date_strings$Iso8601$leapYearsBefore = function (y1) {
        var y = y1 - 1;
        return (((y / 4) | 0) - ((y / 100) | 0)) + ((y / 400) | 0);
    };
    var $rtfeldman$elm_iso8601_date_strings$Iso8601$msPerDay = 86400000;
    var $rtfeldman$elm_iso8601_date_strings$Iso8601$msPerYear = 31536000000;
    var $rtfeldman$elm_iso8601_date_strings$Iso8601$yearMonthDay = function (_v0) {
        var year = _v0.a;
        var month = _v0.b;
        var dayInMonth = _v0.c;
        if (dayInMonth < 0) {
            return $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay(dayInMonth);
        }
        else {
            var succeedWith = function (extraMs) {
                var yearMs = $rtfeldman$elm_iso8601_date_strings$Iso8601$msPerYear * (year - $rtfeldman$elm_iso8601_date_strings$Iso8601$epochYear);
                var days = ((month < 3) || (!$rtfeldman$elm_iso8601_date_strings$Iso8601$isLeapYear(year))) ? (dayInMonth - 1) : dayInMonth;
                var dayMs = $rtfeldman$elm_iso8601_date_strings$Iso8601$msPerDay * (days + ($rtfeldman$elm_iso8601_date_strings$Iso8601$leapYearsBefore(year) - $rtfeldman$elm_iso8601_date_strings$Iso8601$leapYearsBefore($rtfeldman$elm_iso8601_date_strings$Iso8601$epochYear)));
                return $elm$parser$Parser$succeed((extraMs + yearMs) + dayMs);
            };
            switch (month) {
                case 1:
                    return (dayInMonth > 31) ? $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay(dayInMonth) : succeedWith(0);
                case 2:
                    return ((dayInMonth > 29) || ((dayInMonth === 29) && (!$rtfeldman$elm_iso8601_date_strings$Iso8601$isLeapYear(year)))) ? $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay(dayInMonth) : succeedWith(2678400000);
                case 3:
                    return (dayInMonth > 31) ? $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay(dayInMonth) : succeedWith(5097600000);
                case 4:
                    return (dayInMonth > 30) ? $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay(dayInMonth) : succeedWith(7776000000);
                case 5:
                    return (dayInMonth > 31) ? $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay(dayInMonth) : succeedWith(10368000000);
                case 6:
                    return (dayInMonth > 30) ? $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay(dayInMonth) : succeedWith(13046400000);
                case 7:
                    return (dayInMonth > 31) ? $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay(dayInMonth) : succeedWith(15638400000);
                case 8:
                    return (dayInMonth > 31) ? $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay(dayInMonth) : succeedWith(18316800000);
                case 9:
                    return (dayInMonth > 30) ? $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay(dayInMonth) : succeedWith(20995200000);
                case 10:
                    return (dayInMonth > 31) ? $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay(dayInMonth) : succeedWith(23587200000);
                case 11:
                    return (dayInMonth > 30) ? $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay(dayInMonth) : succeedWith(26265600000);
                case 12:
                    return (dayInMonth > 31) ? $rtfeldman$elm_iso8601_date_strings$Iso8601$invalidDay(dayInMonth) : succeedWith(28857600000);
                default:
                    return $elm$parser$Parser$problem("Invalid month: \"" + ($elm$core$String$fromInt(month) + "\""));
            }
        }
    };
    var $rtfeldman$elm_iso8601_date_strings$Iso8601$monthYearDayInMs = $elm$parser$Parser$Advanced$andThen_fn($rtfeldman$elm_iso8601_date_strings$Iso8601$yearMonthDay, $elm$parser$Parser$Advanced$keeper_fn($elm$parser$Parser$Advanced$keeper_fn($elm$parser$Parser$Advanced$keeper_fn($elm$parser$Parser$succeed(F3(function (year, month, day) {
        return _Utils_Tuple3(year, month, day);
    })), $rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt(4)), $elm$parser$Parser$oneOf(_List_fromArray([
        $elm$parser$Parser$Advanced$keeper_fn($elm$parser$Parser$Advanced$ignorer_fn($elm$parser$Parser$succeed($elm$core$Basics$identity), $elm$parser$Parser$symbol("-")), $rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt(2)),
        $rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt(2)
    ]))), $elm$parser$Parser$oneOf(_List_fromArray([
        $elm$parser$Parser$Advanced$keeper_fn($elm$parser$Parser$Advanced$ignorer_fn($elm$parser$Parser$succeed($elm$core$Basics$identity), $elm$parser$Parser$symbol("-")), $rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt(2)),
        $rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt(2)
    ]))));
    var $rtfeldman$elm_iso8601_date_strings$Iso8601$utcOffsetInMinutes = function () {
        var utcOffsetMinutesFromParts = F3(function (multiplier, hours, minutes) {
            return (multiplier * (hours * 60)) + minutes;
        });
        return $elm$parser$Parser$Advanced$keeper_fn($elm$parser$Parser$succeed($elm$core$Basics$identity), $elm$parser$Parser$oneOf(_List_fromArray([
            $elm$parser$Parser$Advanced$map_fn(function (_v0) {
                return 0;
            }, $elm$parser$Parser$symbol("Z")),
            $elm$parser$Parser$Advanced$keeper_fn($elm$parser$Parser$Advanced$keeper_fn($elm$parser$Parser$Advanced$keeper_fn($elm$parser$Parser$succeed(utcOffsetMinutesFromParts), $elm$parser$Parser$oneOf(_List_fromArray([
                $elm$parser$Parser$Advanced$map_fn(function (_v1) {
                    return 1;
                }, $elm$parser$Parser$symbol("+")),
                $elm$parser$Parser$Advanced$map_fn(function (_v2) {
                    return -1;
                }, $elm$parser$Parser$symbol("-"))
            ]))), $rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt(2)), $elm$parser$Parser$oneOf(_List_fromArray([
                $elm$parser$Parser$Advanced$keeper_fn($elm$parser$Parser$Advanced$ignorer_fn($elm$parser$Parser$succeed($elm$core$Basics$identity), $elm$parser$Parser$symbol(":")), $rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt(2)),
                $rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt(2),
                $elm$parser$Parser$succeed(0)
            ]))),
            $elm$parser$Parser$Advanced$ignorer_fn($elm$parser$Parser$succeed(0), $elm$parser$Parser$end)
        ])));
    }();
    var $rtfeldman$elm_iso8601_date_strings$Iso8601$iso8601 = $elm$parser$Parser$Advanced$andThen_fn(function (datePart) {
        return $elm$parser$Parser$oneOf(_List_fromArray([
            $elm$parser$Parser$Advanced$keeper_fn($elm$parser$Parser$Advanced$keeper_fn($elm$parser$Parser$Advanced$keeper_fn($elm$parser$Parser$Advanced$keeper_fn($elm$parser$Parser$Advanced$keeper_fn($elm$parser$Parser$Advanced$ignorer_fn($elm$parser$Parser$succeed($rtfeldman$elm_iso8601_date_strings$Iso8601$fromParts(datePart)), $elm$parser$Parser$symbol("T")), $rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt(2)), $elm$parser$Parser$oneOf(_List_fromArray([
                $elm$parser$Parser$Advanced$keeper_fn($elm$parser$Parser$Advanced$ignorer_fn($elm$parser$Parser$succeed($elm$core$Basics$identity), $elm$parser$Parser$symbol(":")), $rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt(2)),
                $rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt(2)
            ]))), $elm$parser$Parser$oneOf(_List_fromArray([
                $elm$parser$Parser$Advanced$keeper_fn($elm$parser$Parser$Advanced$ignorer_fn($elm$parser$Parser$succeed($elm$core$Basics$identity), $elm$parser$Parser$symbol(":")), $rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt(2)),
                $rtfeldman$elm_iso8601_date_strings$Iso8601$paddedInt(2),
                $elm$parser$Parser$succeed(0)
            ]))), $elm$parser$Parser$oneOf(_List_fromArray([
                $elm$parser$Parser$Advanced$keeper_fn($elm$parser$Parser$Advanced$ignorer_fn($elm$parser$Parser$succeed($elm$core$Basics$identity), $elm$parser$Parser$symbol(".")), $rtfeldman$elm_iso8601_date_strings$Iso8601$fractionsOfASecondInMs),
                $elm$parser$Parser$succeed(0)
            ]))), $elm$parser$Parser$Advanced$ignorer_fn($rtfeldman$elm_iso8601_date_strings$Iso8601$utcOffsetInMinutes, $elm$parser$Parser$end)),
            $elm$parser$Parser$Advanced$ignorer_fn($elm$parser$Parser$succeed($rtfeldman$elm_iso8601_date_strings$Iso8601$fromParts_fn(datePart, 0, 0, 0, 0, 0)), $elm$parser$Parser$end)
        ]));
    }, $rtfeldman$elm_iso8601_date_strings$Iso8601$monthYearDayInMs);
    var $rtfeldman$elm_iso8601_date_strings$Iso8601$toTime = function (str) {
        return $elm$parser$Parser$run_fn($rtfeldman$elm_iso8601_date_strings$Iso8601$iso8601, str);
    };
    var $author$project$Shared$iso8601Decoder = _Json_andThen_fn(A2($elm$core$Basics$composeR, $rtfeldman$elm_iso8601_date_strings$Iso8601$toTime, A2($elm$core$Basics$composeR, $elm$core$Result$mapError($author$project$Markdown$deadEndsToString), $elm_community$json_extra$Json$Decode$Extra$fromResult)), $elm$json$Json$Decode$string);
    var $author$project$Shared$publicCmsArticles = function () {
        var articleMetadataDecoder = _Json_map2_fn($elm_community$json_extra$Json$Decode$Extra$andMap_a0, $elm$json$Json$Decode$maybe(_Json_decodeField_fn("image", $author$project$Shared$cmsImageDecoder)), _Json_map2_fn($elm_community$json_extra$Json$Decode$Extra$andMap_a0, _Json_decodeField_fn("title", $elm$json$Json$Decode$string), _Json_map2_fn($elm_community$json_extra$Json$Decode$Extra$andMap_a0, _Json_decodeField_fn("revisedAt", $author$project$Shared$iso8601Decoder), _Json_map2_fn($elm_community$json_extra$Json$Decode$Extra$andMap_a0, _Json_decodeField_fn("publishedAt", $author$project$Shared$iso8601Decoder), _Json_map2_fn($elm_community$json_extra$Json$Decode$Extra$andMap_a0, _Json_decodeField_fn("id", $elm$json$Json$Decode$string), $elm$json$Json$Decode$succeed($author$project$Shared$CmsArticleMetadata))))));
        return $author$project$Shared$cmsGet_fn("https://ymtszw.microcms.io/api/v1/articles?limit=10000&orders=-publishedAt&fields=id,title,image,publishedAt,revisedAt", _Json_decodeField_fn("contents", $elm$json$Json$Decode$list(articleMetadataDecoder)));
    }();
    var $author$project$Shared$githubGet_fn = function (url, decoder) {
        return $dillonkearns$elm_pages_v3_beta$BackendTask$andThen_fn(function (githubToken) {
            return $dillonkearns$elm_pages_v3_beta$BackendTask$allowFatal($dillonkearns$elm_pages_v3_beta$BackendTask$Http$request_fn({
                hJ: $dillonkearns$elm_pages_v3_beta$BackendTask$Http$emptyBody,
                mS: _List_fromArray([
                    _Utils_Tuple2("Authorization", "token " + githubToken)
                ]),
                nh: "GET",
                lA: $elm$core$Maybe$Nothing,
                lJ: $elm$core$Maybe$Just(3000),
                lO: url
            }, $dillonkearns$elm_pages_v3_beta$BackendTask$Http$expectJson(decoder)));
        }, $dillonkearns$elm_pages_v3_beta$BackendTask$allowFatal($dillonkearns$elm_pages_v3_beta$BackendTask$Env$expect("GITHUB_TOKEN")));
    }, $author$project$Shared$githubGet = F2($author$project$Shared$githubGet_fn);
    var $author$project$Shared$publicOriginalRepos = $author$project$Shared$githubGet_fn("https://api.github.com/users/ymtszw/repos?per_page=100&direction=desc&sort=created", _Json_map1_fn($elm$core$List$filterMap(function (_v0) {
        var fork = _v0.a;
        var name = _v0.b;
        return fork ? $elm$core$Maybe$Just(name) : $elm$core$Maybe$Nothing;
    }), $elm$json$Json$Decode$list(_Json_map2_fn($elm$core$Tuple$pair, _Json_decodeField_fn("fork", _Json_map1_fn($elm$core$Basics$not, $elm$json$Json$Decode$bool)), _Json_decodeField_fn("name", $elm$json$Json$Decode$string)))));
    var $author$project$Shared$QiitaArticleMetadata_fn = function (url, createdAt, updatedAt, title, likesCount, tags) {
        return { cf: createdAt, h7: likesCount, iz: tags, jE: title, iF: updatedAt, lO: url };
    }, $author$project$Shared$QiitaArticleMetadata = F6($author$project$Shared$QiitaArticleMetadata_fn);
    var $author$project$Shared$publicQiitaArticles = function () {
        var articleMetadataDecoder = _Json_map2_fn($elm_community$json_extra$Json$Decode$Extra$andMap_a0, _Json_decodeField_fn("tags", $elm$json$Json$Decode$list(_Json_decodeField_fn("name", $elm$json$Json$Decode$string))), _Json_map2_fn($elm_community$json_extra$Json$Decode$Extra$andMap_a0, _Json_decodeField_fn("likes_count", $elm$json$Json$Decode$int), _Json_map2_fn($elm_community$json_extra$Json$Decode$Extra$andMap_a0, _Json_decodeField_fn("title", $elm$json$Json$Decode$string), _Json_map2_fn($elm_community$json_extra$Json$Decode$Extra$andMap_a0, _Json_decodeField_fn("updated_at", $author$project$Shared$iso8601Decoder), _Json_map2_fn($elm_community$json_extra$Json$Decode$Extra$andMap_a0, _Json_decodeField_fn("created_at", $author$project$Shared$iso8601Decoder), _Json_map2_fn($elm_community$json_extra$Json$Decode$Extra$andMap_a0, _Json_decodeField_fn("url", $elm$json$Json$Decode$string), $elm$json$Json$Decode$succeed($author$project$Shared$QiitaArticleMetadata)))))));
        return $author$project$Shared$cmsGet_fn("https://qiita.com/api/v2/users/ymtszw/items?per_page=100", $elm$json$Json$Decode$list(articleMetadataDecoder));
    }();
    var $author$project$Shared$ZennArticleMetadata_fn = function (url, bodyUpdatedAt, publishedAt, title, likedCount, articleType) {
        return { hH: articleType, hK: bodyUpdatedAt, h6: likedCount, c6: publishedAt, jE: title, lO: url };
    }, $author$project$Shared$ZennArticleMetadata = F6($author$project$Shared$ZennArticleMetadata_fn);
    var $author$project$Shared$publicZennArticles = function () {
        var baseUrl = "https://zenn.dev/ymtszw/articles/";
        var articleMetadataDecoder = _Json_map2_fn($elm_community$json_extra$Json$Decode$Extra$andMap_a0, _Json_decodeField_fn("article_type", $elm$json$Json$Decode$string), _Json_map2_fn($elm_community$json_extra$Json$Decode$Extra$andMap_a0, _Json_decodeField_fn("liked_count", $elm$json$Json$Decode$int), _Json_map2_fn($elm_community$json_extra$Json$Decode$Extra$andMap_a0, _Json_decodeField_fn("title", $elm$json$Json$Decode$string), _Json_map2_fn($elm_community$json_extra$Json$Decode$Extra$andMap_a0, _Json_decodeField_fn("published_at", $author$project$Shared$iso8601Decoder), _Json_map2_fn($elm_community$json_extra$Json$Decode$Extra$andMap_a0, $elm$json$Json$Decode$oneOf(_List_fromArray([
            _Json_decodeField_fn("body_updated_at", $author$project$Shared$iso8601Decoder),
            _Json_decodeField_fn("published_at", $author$project$Shared$iso8601Decoder)
        ])), _Json_map2_fn($elm_community$json_extra$Json$Decode$Extra$andMap_a0, _Json_decodeField_fn("slug", _Json_map1_fn($elm$core$Basics$append(baseUrl), $elm$json$Json$Decode$string)), $elm$json$Json$Decode$succeed($author$project$Shared$ZennArticleMetadata)))))));
        return $author$project$Shared$cmsGet_fn("https://zenn.dev/api/articles?username=ymtszw&count=500&order=latest", _Json_decodeField_fn("articles", $elm$json$Json$Decode$list(articleMetadataDecoder)));
    }();
    var $dillonkearns$elm_pages_v3_beta$BackendTask$Internal$Glob$Glob_fn = function (a, b) {
        return { $: 0, a: a, b: b };
    }, $dillonkearns$elm_pages_v3_beta$BackendTask$Internal$Glob$Glob = F2($dillonkearns$elm_pages_v3_beta$BackendTask$Internal$Glob$Glob_fn);
    var $dillonkearns$elm_pages_v3_beta$BackendTask$Glob$capture_fn = function (_v0, _v1) {
        var matcherPattern = _v0.a;
        var apply1 = _v0.b;
        var pattern = _v1.a;
        var apply2 = _v1.b;
        return $dillonkearns$elm_pages_v3_beta$BackendTask$Internal$Glob$Glob_fn(_Utils_ap(pattern, matcherPattern), F2(function (fullPath, captures) {
            var _v2 = A2(apply1, fullPath, captures);
            var applied1 = _v2.a;
            var captured1 = _v2.b;
            var _v3 = A2(apply2, fullPath, captured1);
            var applied2 = _v3.a;
            var captured2 = _v3.b;
            return _Utils_Tuple2(applied2(applied1), captured2);
        }));
    }, $dillonkearns$elm_pages_v3_beta$BackendTask$Glob$capture = F2($dillonkearns$elm_pages_v3_beta$BackendTask$Glob$capture_fn);
    var $dillonkearns$elm_pages_v3_beta$BackendTask$Glob$digits = $dillonkearns$elm_pages_v3_beta$BackendTask$Internal$Glob$Glob_fn("([0-9]+)", F2(function (_v0, captures) {
        if (captures.b) {
            var first = captures.a;
            var rest = captures.b;
            return _Utils_Tuple2(first, rest);
        }
        else {
            return _Utils_Tuple2("ERROR", _List_Nil);
        }
    }));
    var $dillonkearns$elm_pages_v3_beta$BackendTask$Glob$map_fn = function (mapFn, _v0) {
        var pattern = _v0.a;
        var applyCapture = _v0.b;
        return $dillonkearns$elm_pages_v3_beta$BackendTask$Internal$Glob$Glob_fn(pattern, F2(function (fullPath, captures) {
            return $elm$core$Tuple$mapFirst_fn(mapFn, A2(applyCapture, fullPath, captures));
        }));
    }, $dillonkearns$elm_pages_v3_beta$BackendTask$Glob$map = F2($dillonkearns$elm_pages_v3_beta$BackendTask$Glob$map_fn);
    var $dillonkearns$elm_pages_v3_beta$BackendTask$Glob$int = $dillonkearns$elm_pages_v3_beta$BackendTask$Glob$map_fn(function (matchedDigits) {
        return $elm$core$Maybe$withDefault_fn(-1, $elm$core$String$toInt(matchedDigits));
    }, $dillonkearns$elm_pages_v3_beta$BackendTask$Glob$digits);
    var $dillonkearns$elm_pages_v3_beta$BackendTask$Glob$literal = function (string) {
        return $dillonkearns$elm_pages_v3_beta$BackendTask$Internal$Glob$Glob_fn(string, F2(function (_v0, captures) {
            return _Utils_Tuple2(string, captures);
        }));
    };
    var $author$project$Shared$makeTwilogsJsonPath = function (date) {
        return "data/" + (A2($justinmimbs$date$Date$format, "yyyy/MM/dd", date) + "-twilogs.json");
    };
    var $justinmimbs$date$Date$toIsoString = $justinmimbs$date$Date$format("yyyy-MM-dd");
    var $author$project$Shared$makeTwilogArchiveMetadata_fn = function (year, month, day) {
        var date = $justinmimbs$date$Date$fromCalendarDate_fn(year, $justinmimbs$date$Date$numberToMonth(month), day);
        return {
            ga: date,
            gF: $justinmimbs$date$Date$toIsoString(date),
            nM: $author$project$Shared$makeTwilogsJsonPath(date),
            fK: $justinmimbs$date$Date$toRataDie(date)
        };
    }, $author$project$Shared$makeTwilogArchiveMetadata = F3($author$project$Shared$makeTwilogArchiveMetadata_fn);
    var $dillonkearns$elm_pages_v3_beta$BackendTask$Glob$match_fn = function (_v0, _v1) {
        var matcherPattern = _v0.a;
        var apply1 = _v0.b;
        var pattern = _v1.a;
        var apply2 = _v1.b;
        return $dillonkearns$elm_pages_v3_beta$BackendTask$Internal$Glob$Glob_fn(_Utils_ap(pattern, matcherPattern), F2(function (fullPath, captures) {
            var _v2 = A2(apply1, fullPath, captures);
            var captured1 = _v2.b;
            var _v3 = A2(apply2, fullPath, captured1);
            var applied2 = _v3.a;
            var captured2 = _v3.b;
            return _Utils_Tuple2(applied2, captured2);
        }));
    }, $dillonkearns$elm_pages_v3_beta$BackendTask$Glob$match = F2($dillonkearns$elm_pages_v3_beta$BackendTask$Glob$match_fn);
    var $elm$core$List$sortBy = _List_sortBy;
    var $dillonkearns$elm_pages_v3_beta$BackendTask$Glob$succeed = function (constructor) {
        return $dillonkearns$elm_pages_v3_beta$BackendTask$Internal$Glob$Glob_fn("", F2(function (_v0, captures) {
            return _Utils_Tuple2(constructor, captures);
        }));
    };
    var $dillonkearns$elm_pages_v3_beta$BackendTask$Glob$OnlyFiles = 0;
    var $dillonkearns$elm_pages_v3_beta$BackendTask$Glob$defaultOptions = { fe: true, fq: true, fr: false, cZ: 0, ft: false, fA: $elm$core$Maybe$Nothing };
    var $dillonkearns$elm_pages_v3_beta$BackendTask$Glob$FilesAndFolders = 2;
    var $dillonkearns$elm_pages_v3_beta$BackendTask$Glob$OnlyFolders = 1;
    var $dillonkearns$elm_pages_v3_beta$BackendTask$Glob$encodeOptions = function (options) {
        return $elm$json$Json$Encode$object($elm$core$List$filterMap_fn($elm$core$Basics$identity, _List_fromArray([
            $elm$core$Maybe$Just(_Utils_Tuple2("dot", $elm$json$Json$Encode$bool(options.ft))),
            $elm$core$Maybe$Just(_Utils_Tuple2("followSymbolicLinks", $elm$json$Json$Encode$bool(options.fq))),
            $elm$core$Maybe$Just(_Utils_Tuple2("caseSensitiveMatch", $elm$json$Json$Encode$bool(options.fe))),
            $elm$core$Maybe$Just(_Utils_Tuple2("gitignore", $elm$json$Json$Encode$bool(options.fr))),
            $elm$core$Maybe$map_fn(function (depth) {
                return _Utils_Tuple2("deep", $elm$json$Json$Encode$int(depth));
            }, options.fA),
            $elm$core$Maybe$Just(_Utils_Tuple2("onlyFiles", $elm$json$Json$Encode$bool((!options.cZ) || (options.cZ === 2)))),
            $elm$core$Maybe$Just(_Utils_Tuple2("onlyDirectories", $elm$json$Json$Encode$bool((options.cZ === 1) || (options.cZ === 2))))
        ])));
    };
    var $dillonkearns$elm_pages_v3_beta$BackendTask$Internal$Glob$run_fn = function (rawInput, captures, _v0) {
        var pattern = _v0.a;
        var applyCapture = _v0.b;
        return {
            li: A2(applyCapture, rawInput, $elm$core$List$reverse(captures)).a,
            kc: pattern
        };
    }, $dillonkearns$elm_pages_v3_beta$BackendTask$Internal$Glob$run = F3($dillonkearns$elm_pages_v3_beta$BackendTask$Internal$Glob$run_fn);
    var $dillonkearns$elm_pages_v3_beta$BackendTask$Internal$Glob$toPattern = function (_v0) {
        var pattern = _v0.a;
        return pattern;
    };
    var $dillonkearns$elm_pages_v3_beta$BackendTask$Glob$toBackendTaskWithOptions_fn = function (options, glob) {
        return $dillonkearns$elm_pages_v3_beta$BackendTask$onError_fn(function (_v1) {
            return $dillonkearns$elm_pages_v3_beta$BackendTask$succeed(_List_Nil);
        }, $dillonkearns$elm_pages_v3_beta$BackendTask$Internal$Request$request({
            hJ: $dillonkearns$elm_pages_v3_beta$BackendTask$Http$jsonBody($elm$json$Json$Encode$object(_List_fromArray([
                _Utils_Tuple2("pattern", $elm$json$Json$Encode$string($dillonkearns$elm_pages_v3_beta$BackendTask$Internal$Glob$toPattern(glob))),
                _Utils_Tuple2("options", $dillonkearns$elm_pages_v3_beta$BackendTask$Glob$encodeOptions(options))
            ]))),
            kW: $dillonkearns$elm_pages_v3_beta$BackendTask$Http$expectJson(_Json_map1_fn(function (rawGlob) {
                return $elm$core$List$map_fn(function (_v0) {
                    var captures = _v0.kL;
                    var fullPath = _v0.k3;
                    return $dillonkearns$elm_pages_v3_beta$BackendTask$Internal$Glob$run_fn(fullPath, captures, glob).li;
                }, rawGlob);
            }, $elm$json$Json$Decode$list(_Json_map2_fn(F2(function (fullPath, captures) {
                return { kL: captures, k3: fullPath };
            }), _Json_decodeField_fn("fullPath", $elm$json$Json$Decode$string), _Json_decodeField_fn("captures", $elm$json$Json$Decode$list($elm$json$Json$Decode$string)))))),
            nq: "glob"
        }));
    }, $dillonkearns$elm_pages_v3_beta$BackendTask$Glob$toBackendTaskWithOptions = F2($dillonkearns$elm_pages_v3_beta$BackendTask$Glob$toBackendTaskWithOptions_fn);
    var $dillonkearns$elm_pages_v3_beta$BackendTask$Glob$toBackendTask = function (glob) {
        return $dillonkearns$elm_pages_v3_beta$BackendTask$Glob$toBackendTaskWithOptions_fn($dillonkearns$elm_pages_v3_beta$BackendTask$Glob$defaultOptions, glob);
    };
    var $author$project$Shared$twilogArchives = $dillonkearns$elm_pages_v3_beta$BackendTask$map_fn(A2($elm$core$Basics$composeR, $elm$core$List$sortBy(function ($) {
        return $.fK;
    }), $elm$core$List$reverse), $dillonkearns$elm_pages_v3_beta$BackendTask$Glob$toBackendTask($dillonkearns$elm_pages_v3_beta$BackendTask$Glob$match_fn($dillonkearns$elm_pages_v3_beta$BackendTask$Glob$literal("-twilogs.json"), $dillonkearns$elm_pages_v3_beta$BackendTask$Glob$capture_fn($dillonkearns$elm_pages_v3_beta$BackendTask$Glob$int, $dillonkearns$elm_pages_v3_beta$BackendTask$Glob$match_fn($dillonkearns$elm_pages_v3_beta$BackendTask$Glob$literal("/"), $dillonkearns$elm_pages_v3_beta$BackendTask$Glob$capture_fn($dillonkearns$elm_pages_v3_beta$BackendTask$Glob$int, $dillonkearns$elm_pages_v3_beta$BackendTask$Glob$match_fn($dillonkearns$elm_pages_v3_beta$BackendTask$Glob$literal("/"), $dillonkearns$elm_pages_v3_beta$BackendTask$Glob$capture_fn($dillonkearns$elm_pages_v3_beta$BackendTask$Glob$int, $dillonkearns$elm_pages_v3_beta$BackendTask$Glob$match_fn($dillonkearns$elm_pages_v3_beta$BackendTask$Glob$literal("data/"), $dillonkearns$elm_pages_v3_beta$BackendTask$Glob$succeed($author$project$Shared$makeTwilogArchiveMetadata))))))))));
    var $author$project$Shared$data = $dillonkearns$elm_pages_v3_beta$BackendTask$map5_fn($author$project$Shared$Data, $author$project$Shared$publicOriginalRepos, $author$project$Shared$publicCmsArticles, $author$project$Shared$publicZennArticles, $author$project$Shared$publicQiitaArticles, $author$project$Shared$twilogArchives);
    var $author$project$Shared$init_fn = function (_v0, _v1) {
        return _Utils_Tuple2({ h9: $elm$core$Dict$empty, fP: false }, $author$project$Effect$none);
    }, $author$project$Shared$init = F2($author$project$Shared$init_fn);
    var $author$project$Shared$subscriptions_fn = function (_v0, _v1) {
        return $elm$core$Platform$Sub$none;
    }, $author$project$Shared$subscriptions = F2($author$project$Shared$subscriptions_fn);
    var $author$project$Shared$Res_LinkPreview_fn = function (a, b) {
        return { $: 2, a: a, b: b };
    }, $author$project$Shared$Res_LinkPreview = F2($author$project$Shared$Res_LinkPreview_fn);
    var $author$project$Shared$SharedMsg = function (a) {
        return { $: 1, a: a };
    };
    var $elm$core$Task$Perform = $elm$core$Basics$identity;
    var $elm$core$Task$andThen = _Scheduler_andThen;
    var $elm$core$Task$succeed = _Scheduler_succeed;
    var $elm$core$Task$init = $elm$core$Task$succeed(0);
    var $elm$core$Task$map_fn = function (func, taskA) {
        return _Scheduler_andThen_fn(function (a) {
            return $elm$core$Task$succeed(func(a));
        }, taskA);
    }, $elm$core$Task$map = F2($elm$core$Task$map_fn);
    var $elm$core$Task$map2_fn = function (func, taskA, taskB) {
        return _Scheduler_andThen_fn(function (a) {
            return _Scheduler_andThen_fn(function (b) {
                return $elm$core$Task$succeed(A2(func, a, b));
            }, taskB);
        }, taskA);
    }, $elm$core$Task$map2_fn_unwrapped = function (func, taskA, taskB) {
        return _Scheduler_andThen_fn(function (a) {
            return _Scheduler_andThen_fn(function (b) {
                return $elm$core$Task$succeed(func(a, b));
            }, taskB);
        }, taskA);
    }, $elm$core$Task$map2 = F3($elm$core$Task$map2_fn);
    var $elm$core$Task$sequence = function (tasks) {
        return $elm$core$List$foldr_fn($elm$core$Task$map2($elm$core$List$cons), $elm$core$Task$succeed(_List_Nil), tasks);
    };
    var $elm$core$Platform$sendToApp = _Platform_sendToApp;
    var $elm$core$Task$spawnCmd_fn = function (router, _v0) {
        var task = _v0;
        return _Scheduler_spawn(_Scheduler_andThen_fn($elm$core$Platform$sendToApp(router), task));
    }, $elm$core$Task$spawnCmd = F2($elm$core$Task$spawnCmd_fn);
    var $elm$core$Task$onEffects_fn = function (router, commands, state) {
        return $elm$core$Task$map_fn(function (_v0) {
            return 0;
        }, $elm$core$Task$sequence($elm$core$List$map_fn($elm$core$Task$spawnCmd(router), commands)));
    }, $elm$core$Task$onEffects = F3($elm$core$Task$onEffects_fn);
    var $elm$core$Task$onSelfMsg_fn = function (_v0, _v1, _v2) {
        return $elm$core$Task$succeed(0);
    }, $elm$core$Task$onSelfMsg = F3($elm$core$Task$onSelfMsg_fn);
    var $elm$core$Task$cmdMap_fn = function (tagger, _v0) {
        var task = _v0;
        return $elm$core$Task$map_fn(tagger, task);
    }, $elm$core$Task$cmdMap = F2($elm$core$Task$cmdMap_fn);
    _Platform_effectManagers["Task"] = _Platform_createManager($elm$core$Task$init, $elm$core$Task$onEffects, $elm$core$Task$onSelfMsg, $elm$core$Task$cmdMap);
    var $elm$core$Task$command = _Platform_leaf("Task");
    var $elm$core$Task$onError = _Scheduler_onError;
    var $elm$core$Task$attempt_fn = function (resultToMessage, task) {
        return $elm$core$Task$command(_Scheduler_onError_fn(A2($elm$core$Basics$composeL, A2($elm$core$Basics$composeL, $elm$core$Task$succeed, resultToMessage), $elm$core$Result$Err), _Scheduler_andThen_fn(A2($elm$core$Basics$composeL, A2($elm$core$Basics$composeL, $elm$core$Task$succeed, resultToMessage), $elm$core$Result$Ok), task)));
    }, $elm$core$Task$attempt = F2($elm$core$Task$attempt_fn);
    var $elm$json$Json$Decode$decodeString = _Json_runOnString;
    var $elm$http$Http$BadStatus__fn = function (a, b) {
        return { $: 3, a: a, b: b };
    }, $elm$http$Http$BadStatus_ = F2($elm$http$Http$BadStatus__fn);
    var $elm$http$Http$BadUrl_ = function (a) {
        return { $: 0, a: a };
    };
    var $elm$http$Http$GoodStatus__fn = function (a, b) {
        return { $: 4, a: a, b: b };
    }, $elm$http$Http$GoodStatus_ = F2($elm$http$Http$GoodStatus__fn);
    var $elm$http$Http$NetworkError_ = { $: 2 };
    var $elm$http$Http$Receiving = function (a) {
        return { $: 1, a: a };
    };
    var $elm$http$Http$Sending = function (a) {
        return { $: 0, a: a };
    };
    var $elm$http$Http$Timeout_ = { $: 1 };
    var $elm$core$Maybe$isJust = function (maybe) {
        if (!maybe.$) {
            return true;
        }
        else {
            return false;
        }
    };
    var $elm$core$Platform$sendToSelf = _Platform_sendToSelf;
    var $elm$core$Dict$getMin = function (dict) {
        getMin: while (true) {
            if ((dict.$ === -1) && (dict.d.$ === -1)) {
                var left = dict.d;
                var $temp$dict = left;
                dict = $temp$dict;
                continue getMin;
            }
            else {
                return dict;
            }
        }
    };
    var $elm$core$Dict$moveRedLeft = function (dict) {
        if (((dict.$ === -1) && (dict.d.$ === -1)) && (dict.e.$ === -1)) {
            if ((dict.e.d.$ === -1) && (!dict.e.d.a)) {
                var clr = dict.a;
                var k = dict.b;
                var v = dict.c;
                var _v1 = dict.d;
                var lClr = _v1.a;
                var lK = _v1.b;
                var lV = _v1.c;
                var lLeft = _v1.d;
                var lRight = _v1.e;
                var _v2 = dict.e;
                var rClr = _v2.a;
                var rK = _v2.b;
                var rV = _v2.c;
                var rLeft = _v2.d;
                var _v3 = rLeft.a;
                var rlK = rLeft.b;
                var rlV = rLeft.c;
                var rlL = rLeft.d;
                var rlR = rLeft.e;
                var rRight = _v2.e;
                return $elm$core$Dict$RBNode_elm_builtin_fn(0, rlK, rlV, $elm$core$Dict$RBNode_elm_builtin_fn(1, k, v, $elm$core$Dict$RBNode_elm_builtin_fn(0, lK, lV, lLeft, lRight), rlL), $elm$core$Dict$RBNode_elm_builtin_fn(1, rK, rV, rlR, rRight));
            }
            else {
                var clr = dict.a;
                var k = dict.b;
                var v = dict.c;
                var _v4 = dict.d;
                var lClr = _v4.a;
                var lK = _v4.b;
                var lV = _v4.c;
                var lLeft = _v4.d;
                var lRight = _v4.e;
                var _v5 = dict.e;
                var rClr = _v5.a;
                var rK = _v5.b;
                var rV = _v5.c;
                var rLeft = _v5.d;
                var rRight = _v5.e;
                if (clr === 1) {
                    return $elm$core$Dict$RBNode_elm_builtin_fn(1, k, v, $elm$core$Dict$RBNode_elm_builtin_fn(0, lK, lV, lLeft, lRight), $elm$core$Dict$RBNode_elm_builtin_fn(0, rK, rV, rLeft, rRight));
                }
                else {
                    return $elm$core$Dict$RBNode_elm_builtin_fn(1, k, v, $elm$core$Dict$RBNode_elm_builtin_fn(0, lK, lV, lLeft, lRight), $elm$core$Dict$RBNode_elm_builtin_fn(0, rK, rV, rLeft, rRight));
                }
            }
        }
        else {
            return dict;
        }
    };
    var $elm$core$Dict$moveRedRight = function (dict) {
        if (((dict.$ === -1) && (dict.d.$ === -1)) && (dict.e.$ === -1)) {
            if ((dict.d.d.$ === -1) && (!dict.d.d.a)) {
                var clr = dict.a;
                var k = dict.b;
                var v = dict.c;
                var _v1 = dict.d;
                var lClr = _v1.a;
                var lK = _v1.b;
                var lV = _v1.c;
                var _v2 = _v1.d;
                var _v3 = _v2.a;
                var llK = _v2.b;
                var llV = _v2.c;
                var llLeft = _v2.d;
                var llRight = _v2.e;
                var lRight = _v1.e;
                var _v4 = dict.e;
                var rClr = _v4.a;
                var rK = _v4.b;
                var rV = _v4.c;
                var rLeft = _v4.d;
                var rRight = _v4.e;
                return $elm$core$Dict$RBNode_elm_builtin_fn(0, lK, lV, $elm$core$Dict$RBNode_elm_builtin_fn(1, llK, llV, llLeft, llRight), $elm$core$Dict$RBNode_elm_builtin_fn(1, k, v, lRight, $elm$core$Dict$RBNode_elm_builtin_fn(0, rK, rV, rLeft, rRight)));
            }
            else {
                var clr = dict.a;
                var k = dict.b;
                var v = dict.c;
                var _v5 = dict.d;
                var lClr = _v5.a;
                var lK = _v5.b;
                var lV = _v5.c;
                var lLeft = _v5.d;
                var lRight = _v5.e;
                var _v6 = dict.e;
                var rClr = _v6.a;
                var rK = _v6.b;
                var rV = _v6.c;
                var rLeft = _v6.d;
                var rRight = _v6.e;
                if (clr === 1) {
                    return $elm$core$Dict$RBNode_elm_builtin_fn(1, k, v, $elm$core$Dict$RBNode_elm_builtin_fn(0, lK, lV, lLeft, lRight), $elm$core$Dict$RBNode_elm_builtin_fn(0, rK, rV, rLeft, rRight));
                }
                else {
                    return $elm$core$Dict$RBNode_elm_builtin_fn(1, k, v, $elm$core$Dict$RBNode_elm_builtin_fn(0, lK, lV, lLeft, lRight), $elm$core$Dict$RBNode_elm_builtin_fn(0, rK, rV, rLeft, rRight));
                }
            }
        }
        else {
            return dict;
        }
    };
    var $elm$core$Dict$removeHelpPrepEQGT_fn = function (targetKey, dict, color, key, value, left, right) {
        if ((left.$ === -1) && (!left.a)) {
            var _v1 = left.a;
            var lK = left.b;
            var lV = left.c;
            var lLeft = left.d;
            var lRight = left.e;
            return $elm$core$Dict$RBNode_elm_builtin_fn(color, lK, lV, lLeft, $elm$core$Dict$RBNode_elm_builtin_fn(0, key, value, lRight, right));
        }
        else {
            _v2$2: while (true) {
                if ((right.$ === -1) && (right.a === 1)) {
                    if (right.d.$ === -1) {
                        if (right.d.a === 1) {
                            var _v3 = right.a;
                            var _v4 = right.d;
                            var _v5 = _v4.a;
                            return $elm$core$Dict$moveRedRight(dict);
                        }
                        else {
                            break _v2$2;
                        }
                    }
                    else {
                        var _v6 = right.a;
                        var _v7 = right.d;
                        return $elm$core$Dict$moveRedRight(dict);
                    }
                }
                else {
                    break _v2$2;
                }
            }
            return dict;
        }
    }, $elm$core$Dict$removeHelpPrepEQGT = F7($elm$core$Dict$removeHelpPrepEQGT_fn);
    var $elm$core$Dict$removeMin = function (dict) {
        if ((dict.$ === -1) && (dict.d.$ === -1)) {
            var color = dict.a;
            var key = dict.b;
            var value = dict.c;
            var left = dict.d;
            var lColor = left.a;
            var lLeft = left.d;
            var right = dict.e;
            if (lColor === 1) {
                if ((lLeft.$ === -1) && (!lLeft.a)) {
                    var _v3 = lLeft.a;
                    return $elm$core$Dict$RBNode_elm_builtin_fn(color, key, value, $elm$core$Dict$removeMin(left), right);
                }
                else {
                    var _v4 = $elm$core$Dict$moveRedLeft(dict);
                    if (_v4.$ === -1) {
                        var nColor = _v4.a;
                        var nKey = _v4.b;
                        var nValue = _v4.c;
                        var nLeft = _v4.d;
                        var nRight = _v4.e;
                        return $elm$core$Dict$balance_fn(nColor, nKey, nValue, $elm$core$Dict$removeMin(nLeft), nRight);
                    }
                    else {
                        return $elm$core$Dict$RBEmpty_elm_builtin;
                    }
                }
            }
            else {
                return $elm$core$Dict$RBNode_elm_builtin_fn(color, key, value, $elm$core$Dict$removeMin(left), right);
            }
        }
        else {
            return $elm$core$Dict$RBEmpty_elm_builtin;
        }
    };
    var $elm$core$Dict$removeHelp_fn = function (targetKey, dict) {
        if (dict.$ === -2) {
            return $elm$core$Dict$RBEmpty_elm_builtin;
        }
        else {
            var color = dict.a;
            var key = dict.b;
            var value = dict.c;
            var left = dict.d;
            var right = dict.e;
            if (_Utils_cmp(targetKey, key) < 0) {
                if ((left.$ === -1) && (left.a === 1)) {
                    var _v4 = left.a;
                    var lLeft = left.d;
                    if ((lLeft.$ === -1) && (!lLeft.a)) {
                        var _v6 = lLeft.a;
                        return $elm$core$Dict$RBNode_elm_builtin_fn(color, key, value, $elm$core$Dict$removeHelp_fn(targetKey, left), right);
                    }
                    else {
                        var _v7 = $elm$core$Dict$moveRedLeft(dict);
                        if (_v7.$ === -1) {
                            var nColor = _v7.a;
                            var nKey = _v7.b;
                            var nValue = _v7.c;
                            var nLeft = _v7.d;
                            var nRight = _v7.e;
                            return $elm$core$Dict$balance_fn(nColor, nKey, nValue, $elm$core$Dict$removeHelp_fn(targetKey, nLeft), nRight);
                        }
                        else {
                            return $elm$core$Dict$RBEmpty_elm_builtin;
                        }
                    }
                }
                else {
                    return $elm$core$Dict$RBNode_elm_builtin_fn(color, key, value, $elm$core$Dict$removeHelp_fn(targetKey, left), right);
                }
            }
            else {
                return $elm$core$Dict$removeHelpEQGT_fn(targetKey, $elm$core$Dict$removeHelpPrepEQGT_fn(targetKey, dict, color, key, value, left, right));
            }
        }
    }, $elm$core$Dict$removeHelp = F2($elm$core$Dict$removeHelp_fn);
    var $elm$core$Dict$removeHelpEQGT_fn = function (targetKey, dict) {
        if (dict.$ === -1) {
            var color = dict.a;
            var key = dict.b;
            var value = dict.c;
            var left = dict.d;
            var right = dict.e;
            if (_Utils_eq(targetKey, key)) {
                var _v1 = $elm$core$Dict$getMin(right);
                if (_v1.$ === -1) {
                    var minKey = _v1.b;
                    var minValue = _v1.c;
                    return $elm$core$Dict$balance_fn(color, minKey, minValue, left, $elm$core$Dict$removeMin(right));
                }
                else {
                    return $elm$core$Dict$RBEmpty_elm_builtin;
                }
            }
            else {
                return $elm$core$Dict$balance_fn(color, key, value, left, $elm$core$Dict$removeHelp_fn(targetKey, right));
            }
        }
        else {
            return $elm$core$Dict$RBEmpty_elm_builtin;
        }
    }, $elm$core$Dict$removeHelpEQGT = F2($elm$core$Dict$removeHelpEQGT_fn);
    var $elm$core$Dict$remove_fn = function (key, dict) {
        var _v0 = $elm$core$Dict$removeHelp_fn(key, dict);
        if ((_v0.$ === -1) && (!_v0.a)) {
            var _v1 = _v0.a;
            var k = _v0.b;
            var v = _v0.c;
            var l = _v0.d;
            var r = _v0.e;
            return $elm$core$Dict$RBNode_elm_builtin_fn(1, k, v, l, r);
        }
        else {
            var x = _v0;
            return x;
        }
    }, $elm$core$Dict$remove = F2($elm$core$Dict$remove_fn);
    var $elm$core$Dict$update_fn = function (targetKey, alter, dictionary) {
        var _v0 = alter($elm$core$Dict$get_fn(targetKey, dictionary));
        if (!_v0.$) {
            var value = _v0.a;
            return $elm$core$Dict$insert_fn(targetKey, value, dictionary);
        }
        else {
            return $elm$core$Dict$remove_fn(targetKey, dictionary);
        }
    }, $elm$core$Dict$update = F3($elm$core$Dict$update_fn);
    var $elm$http$Http$emptyBody = _Http_emptyBody;
    var $elm$url$Url$percentEncode = _Url_percentEncode;
    var $author$project$LinkPreview$linkPreviewApiEndpoint = function (url) {
        return "https://link-preview.ymtszw.workers.dev/?q=" + $elm$url$Url$percentEncode(url);
    };
    var $author$project$LinkPreview$Metadata_fn = function (title, description, imageUrl, canonicalUrl) {
        return { kK: canonicalUrl, jX: description, gz: imageUrl, jE: title };
    }, $author$project$LinkPreview$Metadata = F4($author$project$LinkPreview$Metadata_fn);
    var $author$project$Helper$nonEmptyString = _Json_andThen_fn(function (s) {
        return $elm$core$String$isEmpty(s) ? $elm$json$Json$Decode$fail("String is empty") : $elm$json$Json$Decode$succeed(s);
    }, $elm$json$Json$Decode$string);
    var $elm_community$json_extra$Json$Decode$Extra$optionalField_fn = function (fieldName, decoder) {
        var finishDecoding = function (json) {
            var _v0 = _Json_run_fn(_Json_decodeField_fn(fieldName, $elm$json$Json$Decode$value), json);
            if (!_v0.$) {
                var val = _v0.a;
                return _Json_map1_fn($elm$core$Maybe$Just, _Json_decodeField_fn(fieldName, decoder));
            }
            else {
                return $elm$json$Json$Decode$succeed($elm$core$Maybe$Nothing);
            }
        };
        return _Json_andThen_fn(finishDecoding, $elm$json$Json$Decode$value);
    }, $elm_community$json_extra$Json$Decode$Extra$optionalField = F2($elm_community$json_extra$Json$Decode$Extra$optionalField_fn);
    var $author$project$LinkPreview$resolveUrl_fn = function (baseUrl, pathOrUrl) {
        if (_String_startsWith_fn("http:", pathOrUrl) || (_String_startsWith_fn("https:", pathOrUrl) || _String_startsWith_fn("data:", pathOrUrl))) {
            return pathOrUrl;
        }
        else {
            if (_String_startsWith_fn("//", pathOrUrl)) {
                var _v0 = $elm$core$String$split_fn(":", baseUrl);
                if (_v0.b) {
                    var scheme = _v0.a;
                    return scheme + (":" + pathOrUrl);
                }
                else {
                    return "https:" + pathOrUrl;
                }
            }
            else {
                if (_String_startsWith_fn("/", pathOrUrl)) {
                    return _String_endsWith_fn("/", baseUrl) ? _Utils_ap($elm$core$String$dropRight_fn(1, baseUrl), pathOrUrl) : _Utils_ap(baseUrl, pathOrUrl);
                }
                else {
                    if (_String_endsWith_fn("/", baseUrl)) {
                        return _Utils_ap(baseUrl, pathOrUrl);
                    }
                    else {
                        return _Utils_ap(baseUrl, $elm$core$String$dropLeft_fn(1, pathOrUrl));
                    }
                }
            }
        }
    }, $author$project$LinkPreview$resolveUrl = F2($author$project$LinkPreview$resolveUrl_fn);
    var $author$project$LinkPreview$linkPreviewDecoder = function (requestUrl) {
        return _Json_andThen_fn(function (canonicalUrl) {
            var canonicalUrlWithFragment = function () {
                var _v0 = $elm$core$String$split_fn("#", requestUrl);
                if ((_v0.b && _v0.b.b) && (!_v0.b.b.b)) {
                    var _v1 = _v0.b;
                    var fragment = _v1.a;
                    return canonicalUrl + ("#" + fragment);
                }
                else {
                    return canonicalUrl;
                }
            }();
            return _Json_map2_fn($elm_community$json_extra$Json$Decode$Extra$andMap_a0, $elm$json$Json$Decode$succeed(canonicalUrlWithFragment), _Json_map2_fn($elm_community$json_extra$Json$Decode$Extra$andMap_a0, $elm_community$json_extra$Json$Decode$Extra$optionalField_fn("image", _Json_map1_fn($author$project$LinkPreview$resolveUrl(canonicalUrl), $author$project$Helper$nonEmptyString)), _Json_map2_fn($elm_community$json_extra$Json$Decode$Extra$andMap_a0, $elm_community$json_extra$Json$Decode$Extra$optionalField_fn("description", $author$project$Helper$nonEmptyString), _Json_map2_fn($elm_community$json_extra$Json$Decode$Extra$andMap_a0, _Json_decodeField_fn("title", $author$project$Helper$nonEmptyString), $elm$json$Json$Decode$succeed($author$project$LinkPreview$Metadata)))));
        }, _Json_decodeField_fn("url", $elm$json$Json$Decode$string));
    };
    var $elm$http$Http$stringResolver_a0 = "", $elm$http$Http$stringResolver_a1 = $elm$core$Basics$identity, $elm$http$Http$stringResolver = A2(_Http_expect, $elm$http$Http$stringResolver_a0, $elm$http$Http$stringResolver_a1);
    var $elm$core$Task$fail = _Scheduler_fail;
    var $elm$http$Http$resultToTask = function (result) {
        if (!result.$) {
            var a = result.a;
            return $elm$core$Task$succeed(a);
        }
        else {
            var x = result.a;
            return $elm$core$Task$fail(x);
        }
    };
    var $elm$http$Http$task = function (r) {
        return _Http_toTask_fn(0, $elm$http$Http$resultToTask, { lW: false, hJ: r.hJ, kW: r.n0, mS: r.mS, nh: r.nh, oq: r.oq, kt: $elm$core$Maybe$Nothing, lO: r.lO });
    };
    var $author$project$LinkPreview$getMetadataOnDemand = function (url) {
        return $elm$core$Task$map_fn($elm$core$Tuple$pair(url), $elm$http$Http$task({
            hJ: $elm$http$Http$emptyBody,
            mS: _List_Nil,
            nh: "GET",
            n0: _Http_expect_fn($elm$http$Http$stringResolver_a0, $elm$http$Http$stringResolver_a1, function (response) {
                if (response.$ === 4) {
                    var body = response.b;
                    return $elm$core$Result$mapError_fn($elm$json$Json$Decode$errorToString, _Json_runOnString_fn($author$project$LinkPreview$linkPreviewDecoder(url), body));
                }
                else {
                    return $elm$core$Result$Err("something failed");
                }
            }),
            oq: $elm$core$Maybe$Just(20000),
            lO: $author$project$LinkPreview$linkPreviewApiEndpoint(url)
        }));
    };
    var $author$project$Shared$requestLinkPreviewSequentially_fn = function (urls, url) {
        return $author$project$Effect$fromCmd(_Platform_map_fn($author$project$Shared$SharedMsg, $elm$core$Task$attempt_fn($author$project$Shared$Res_LinkPreview(urls), $author$project$LinkPreview$getMetadataOnDemand(url))));
    }, $author$project$Shared$requestLinkPreviewSequentially = F2($author$project$Shared$requestLinkPreviewSequentially_fn);
    var $author$project$Shared$update_fn = function (msg, model) {
        _v0$3: while (true) {
            if (!msg.$) {
                return _Utils_Tuple2(_Utils_update(model, { fP: false }), $author$project$Effect$none);
            }
            else {
                switch (msg.a.$) {
                    case 1:
                        if (msg.a.a.b) {
                            var _v1 = msg.a.a;
                            var url = _v1.a;
                            var urls = _v1.b;
                            return _Utils_Tuple2(model, $author$project$Shared$requestLinkPreviewSequentially_fn(urls, url));
                        }
                        else {
                            break _v0$3;
                        }
                    case 2:
                        var _v2 = msg.a;
                        var remainingUrls = _v2.a;
                        var result = _v2.b;
                        return _Utils_Tuple2(function () {
                            if (!result.$) {
                                var _v4 = result.a;
                                var url = _v4.a;
                                var metadata = _v4.b;
                                return _Utils_update(model, {
                                    h9: $elm$core$Dict$insert_fn(url, metadata, model.h9)
                                });
                            }
                            else {
                                return model;
                            }
                        }(), function () {
                            if (!remainingUrls.b) {
                                return $author$project$Effect$none;
                            }
                            else {
                                var url = remainingUrls.a;
                                var urls = remainingUrls.b;
                                return $author$project$Shared$requestLinkPreviewSequentially_fn(urls, url);
                            }
                        }());
                    default:
                        break _v0$3;
                }
            }
        }
        return _Utils_Tuple2(model, $author$project$Effect$none);
    }, $author$project$Shared$update = F2($author$project$Shared$update_fn);
    var $elm$html$Html$Attributes$class_a0 = "className", $elm$html$Html$Attributes$class = $elm$html$Html$Attributes$stringProperty($elm$html$Html$Attributes$class_a0);
    var $elm_community$list_extra$List$Extra$find_fn = function (predicate, list) {
        find: while (true) {
            if (!list.b) {
                return $elm$core$Maybe$Nothing;
            }
            else {
                var first = list.a;
                var rest = list.b;
                if (predicate(first)) {
                    return $elm$core$Maybe$Just(first);
                }
                else {
                    var $temp$predicate = predicate, $temp$list = rest;
                    predicate = $temp$predicate;
                    list = $temp$list;
                    continue find;
                }
            }
        }
    }, $elm_community$list_extra$List$Extra$find = F2($elm_community$list_extra$List$Extra$find_fn);
    var $author$project$Shared$cmsArticleShortTitle_fn = function (articleId, cmsArticles) {
        return $elm$core$Maybe$withDefault_fn(articleId, $elm$core$Maybe$map_fn(function (cmsArticle) {
            return ($elm$core$String$length(cmsArticle.jE) > 40) ? ($elm$core$String$left_fn(40, cmsArticle.jE) + "...") : cmsArticle.jE;
        }, $elm_community$list_extra$List$Extra$find_fn(function (cmsArticle) {
            return _Utils_eq(cmsArticle.f8, articleId);
        }, cmsArticles)));
    }, $author$project$Shared$cmsArticleShortTitle = F2($author$project$Shared$cmsArticleShortTitle_fn);
    var $elm$html$Html$footer = _VirtualDom_nodeNS_fn(_VirtualDom_node_a0, "footer"), $elm$html$Html$footer_fn = $elm$html$Html$footer.a2;
    var $elm$html$Html$header = _VirtualDom_nodeNS_fn(_VirtualDom_node_a0, "header"), $elm$html$Html$header_fn = $elm$html$Html$header.a2;
    var $elm$html$Html$hr = _VirtualDom_nodeNS_fn(_VirtualDom_node_a0, "hr"), $elm$html$Html$hr_fn = $elm$html$Html$hr.a2;
    var $elm$core$List$intersperse_fn = function (sep, xs) {
        if (!xs.b) {
            return xs;
        }
        var tmp = _List_Cons(undefined, _List_Nil);
        var end = tmp;
        end.b = _List_Cons(xs.a, _List_Nil);
        end = end.b;
        xs = xs.b;
        for (; xs.b; xs = xs.b) {
            var valNode = _List_Cons(xs.a, _List_Nil);
            var sepNode = _List_Cons(sep, valNode);
            end.b = sepNode;
            end = valNode;
        }
        return tmp.b;
    }, $elm$core$List$intersperse = F2($elm$core$List$intersperse_fn);
    var $elm$html$Html$a = _VirtualDom_nodeNS_fn(_VirtualDom_node_a0, "a"), $elm$html$Html$a_fn = $elm$html$Html$a.a2;
    var $elm$virtual_dom$VirtualDom$attribute_fn = function (key, value) {
        return _VirtualDom_attribute_fn(_VirtualDom_noOnOrFormAction(key), _VirtualDom_noJavaScriptOrHtmlUri(value));
    }, $elm$virtual_dom$VirtualDom$attribute = F2($elm$virtual_dom$VirtualDom$attribute_fn);
    var $elm$html$Html$Attributes$attribute = $elm$virtual_dom$VirtualDom$attribute;
    var $elm$html$Html$Attributes$href = function (url) {
        return $elm$html$Html$Attributes$stringProperty_fn("href", _VirtualDom_noJavaScriptUri(url));
    };
    var $author$project$Route$toPath = function (route) {
        return $dillonkearns$elm_pages_v3_beta$Path$fromString($elm$core$String$join_fn("/", _Utils_ap($author$project$Route$baseUrlAsPath, $author$project$Route$routeToPath(route))));
    };
    var $author$project$Route$toString = function (route) {
        return $dillonkearns$elm_pages_v3_beta$Path$toAbsolute($author$project$Route$toPath(route));
    };
    var $author$project$Route$toLink_fn = function (toAnchorTag, route) {
        return toAnchorTag(_List_fromArray([
            $elm$html$Html$Attributes$href($author$project$Route$toString(route)),
            $elm$virtual_dom$VirtualDom$attribute_fn("elm-pages:prefetch", "")
        ]));
    }, $author$project$Route$toLink = F2($author$project$Route$toLink_fn);
    var $author$project$Route$link_fn = function (attributes, children, route) {
        return $author$project$Route$toLink_fn(function (anchorAttrs) {
            return $elm$html$Html$a_fn(_Utils_ap(anchorAttrs, attributes), children);
        }, route);
    }, $author$project$Route$link = F3($author$project$Route$link_fn);
    var $elm$html$Html$main_ = _VirtualDom_nodeNS_fn(_VirtualDom_node_a0, "main"), $elm$html$Html$main__fn = $elm$html$Html$main_.a2;
    var $author$project$Shared$ogpHeaderImageUrl = "https://images.microcms-assets.io/assets/032d3ec87506420baf0093fac244c29b/4a220ee277a54bd4a7cf59a2c423b096/header1500x500.jpg";
    var $author$project$Shared$seoBase = {
        ma: $elm$core$Maybe$Nothing,
        jX: $author$project$Site$tagline,
        gy: {
            kB: "Mt. Asama Header Image",
            kT: $elm$core$Maybe$Just({ eu: 300, e9: 900 }),
            nj: $elm$core$Maybe$Just($danyx23$elm_mimetype$MimeType$Image($danyx23$elm_mimetype$MimeType$Jpeg)),
            lO: $dillonkearns$elm_pages_v3_beta$Pages$Url$external($author$project$Shared$ogpHeaderImageUrl + "?w=900&h=300")
        },
        nd: $elm$core$Maybe$Just("ja_JP"),
        kk: $author$project$Site$title,
        jE: $author$project$Site$title
    };
    var $author$project$Shared$makeTitle = function (pageTitle) {
        if (pageTitle === "") {
            return $author$project$Shared$seoBase.kk;
        }
        else {
            var nonEmpty = pageTitle;
            return nonEmpty + (" | " + $author$project$Shared$seoBase.kk);
        }
    };
    var $elm$html$Html$nav = _VirtualDom_nodeNS_fn(_VirtualDom_node_a0, "nav"), $elm$html$Html$nav_fn = $elm$html$Html$nav.a2;
    var $elm$html$Html$Attributes$alt_a0 = "alt", $elm$html$Html$Attributes$alt = $elm$html$Html$Attributes$stringProperty($elm$html$Html$Attributes$alt_a0);
    var $elm$html$Html$Attributes$height = function (n) {
        return _VirtualDom_attribute_fn("height", $elm$core$String$fromInt(n));
    };
    var $elm$html$Html$img = _VirtualDom_nodeNS_fn(_VirtualDom_node_a0, "img"), $elm$html$Html$img_fn = $elm$html$Html$img.a2;
    var $author$project$View$imgLazy_fn = function (attrs, kids) {
        return $elm$html$Html$img_fn(_List_Cons($elm$virtual_dom$VirtualDom$attribute_fn("loading", "lazy"), attrs), kids);
    }, $author$project$View$imgLazy = F2($author$project$View$imgLazy_fn);
    var $elm$html$Html$Attributes$src = function (url) {
        return $elm$html$Html$Attributes$stringProperty_fn("src", _VirtualDom_noJavaScriptOrHtmlUri(url));
    };
    var $elm$html$Html$Attributes$target_a0 = "target", $elm$html$Html$Attributes$target = $elm$html$Html$Attributes$stringProperty($elm$html$Html$Attributes$target_a0);
    var $author$project$Shared$siteBuildStatus = $elm$html$Html$a_fn(_List_fromArray([
        $elm$html$Html$Attributes$href("https://github.com/ymtszw/ymtszw.github.io"),
        $elm$html$Html$Attributes$stringProperty_fn($elm$html$Html$Attributes$target_a0, "_blank"),
        $elm$html$Html$Attributes$stringProperty_fn($elm$html$Html$Attributes$class_a0, "has-image")
    ]), _List_fromArray([
        $author$project$View$imgLazy_fn(_List_fromArray([
            $elm$html$Html$Attributes$src("https://github.com/ymtszw/ymtszw.github.io/actions/workflows/gh-pages.yml/badge.svg"),
            $elm$html$Html$Attributes$stringProperty_fn($elm$html$Html$Attributes$alt_a0, "GitHub Pages: ymtszw/ymtszw.github.io"),
            $elm$html$Html$Attributes$height(20)
        ]), _List_Nil)
    ]));
    var $author$project$Shared$sitemap = $elm$html$Html$nav_fn(_List_Nil, $elm$core$List$intersperse_fn($elm$html$Html$text(" | "), _List_fromArray([
        $elm$html$Html$text(""),
        $author$project$Route$link_fn(_List_Nil, _List_fromArray([
            $elm$html$Html$text("\u3053\u306E\u30B5\u30A4\u30C8\u306B\u3064\u3044\u3066")
        ]), $author$project$Route$About),
        $author$project$Route$link_fn(_List_Nil, _List_fromArray([
            $elm$html$Html$text("Twilog")
        ]), $author$project$Route$Twilogs),
        $author$project$Route$link_fn(_List_Nil, _List_fromArray([
            $elm$html$Html$text("\u8A18\u4E8B")
        ]), $author$project$Route$Articles),
        $elm$html$Html$text("")
    ])));
    var $elm$html$Html$strong = _VirtualDom_nodeNS_fn(_VirtualDom_node_a0, "strong"), $elm$html$Html$strong_fn = $elm$html$Html$strong.a2;
    var $author$project$Shared$twitterLink = $elm$html$Html$a_fn(_List_fromArray([
        $elm$html$Html$Attributes$href("https://twitter.com/gada_twt"),
        $elm$html$Html$Attributes$stringProperty_fn($elm$html$Html$Attributes$target_a0, "_blank"),
        $elm$html$Html$Attributes$stringProperty_fn($elm$html$Html$Attributes$class_a0, "has-image")
    ]), _List_fromArray([
        $author$project$View$imgLazy_fn(_List_fromArray([
            $elm$html$Html$Attributes$src("https://img.shields.io/twitter/follow/gada_twt.svg?style=social"),
            $elm$html$Html$Attributes$stringProperty_fn($elm$html$Html$Attributes$alt_a0, "Twitter: gada_twt")
        ]), _List_Nil)
    ]));
    var $author$project$Shared$view_fn = function (sharedData, page, _v0, _v1, pageView) {
        return {
            hJ: _List_fromArray([
                $elm$html$Html$header_fn(_List_Nil, _List_fromArray([
                    $elm$html$Html$nav_fn(_List_Nil, $elm$core$List$intersperse_fn($elm$html$Html$text(" / "), $elm$core$List$concatMap_fn(function (kids) {
                        return $elm$core$List$map_fn(function (kid) {
                            return $elm$html$Html$strong_fn(_List_Nil, _List_fromArray([kid]));
                        }, kids);
                    }, _List_fromArray([
                        _List_fromArray([
                            $author$project$Route$link_fn(_List_Nil, _List_fromArray([
                                $elm$html$Html$text("Index")
                            ]), $author$project$Route$Index)
                        ]),
                        $elm$core$Maybe$withDefault_fn(_List_Nil, $elm$core$Maybe$map_fn(function (route) {
                            switch (route.$) {
                                case 3:
                                    return _List_fromArray([
                                        $elm$html$Html$text("\u3053\u306E\u30B5\u30A4\u30C8\u306B\u3064\u3044\u3066")
                                    ]);
                                case 4:
                                    return _List_fromArray([
                                        $elm$html$Html$text("\u8A18\u4E8B")
                                    ]);
                                case 1:
                                    var articleId = route.a.l$;
                                    return _List_fromArray([
                                        $author$project$Route$link_fn(_List_Nil, _List_fromArray([
                                            $elm$html$Html$text("\u8A18\u4E8B")
                                        ]), $author$project$Route$Articles),
                                        $elm$html$Html$text($author$project$Shared$cmsArticleShortTitle_fn(articleId, sharedData.f6))
                                    ]);
                                case 0:
                                    return _List_fromArray([
                                        $elm$html$Html$text("\u8A18\u4E8B\uFF08\u4E0B\u66F8\u304D\uFF09")
                                    ]);
                                case 5:
                                    return _List_fromArray([
                                        $elm$html$Html$text("Twilog")
                                    ]);
                                case 2:
                                    var day = route.a.ml;
                                    return _List_fromArray([
                                        $author$project$Route$link_fn(_List_Nil, _List_fromArray([
                                            $elm$html$Html$text("Twilog")
                                        ]), $author$project$Route$Twilogs),
                                        $elm$html$Html$text(day)
                                    ]);
                                default:
                                    return _List_Nil;
                            }
                        }, page.n4))
                    ])))),
                    $author$project$Shared$sitemap,
                    $elm$html$Html$nav_fn(_List_fromArray([
                        $elm$html$Html$Attributes$stringProperty_fn($elm$html$Html$Attributes$class_a0, "meta")
                    ]), _List_fromArray([$author$project$Shared$siteBuildStatus, $author$project$Shared$twitterLink]))
                ])),
                $elm$html$Html$hr_fn(_List_Nil, _List_Nil),
                $elm$html$Html$main__fn(_List_Nil, pageView.hJ),
                $elm$html$Html$hr_fn(_List_Nil, _List_Nil),
                $elm$html$Html$footer_fn(_List_Nil, _List_fromArray([
                    $elm$html$Html$text("\u00A9 Yu Matsuzawa (ymtszw, Gada), 2022 "),
                    $author$project$Shared$sitemap,
                    $elm$html$Html$nav_fn(_List_fromArray([
                        $elm$html$Html$Attributes$stringProperty_fn($elm$html$Html$Attributes$class_a0, "meta")
                    ]), _List_fromArray([$author$project$Shared$siteBuildStatus, $author$project$Shared$twitterLink]))
                ]))
            ]),
            jE: $author$project$Shared$makeTitle(pageView.jE)
        };
    }, $author$project$Shared$view = F5($author$project$Shared$view_fn);
    var $author$project$Shared$template = {
        iW: $author$project$Shared$data,
        dI: $author$project$Shared$init,
        lr: $elm$core$Maybe$Just($author$project$Shared$OnPageChange),
        dW: $author$project$Shared$subscriptions,
        cF: $author$project$Shared$update,
        X: $author$project$Shared$view
    };
    var $author$project$Main$init_fn = function (currentGlobalModel, userFlags, sharedData, pageData, actionData, maybePagePath) {
        var _v0 = $elm$core$Maybe$withDefault_fn(A2($author$project$Shared$template.dI, userFlags, maybePagePath), $elm$core$Maybe$map_fn(function (mapUnpack) {
            return _Utils_Tuple2(mapUnpack, $author$project$Effect$none);
        }, currentGlobalModel));
        var sharedModel = _v0.a;
        var globalCmd = _v0.b;
        var _v1 = function () {
            var _v2 = $elm$core$Maybe$map2_fn($elm$core$Tuple$pair, $elm$core$Maybe$andThen_fn(function ($) {
                return $.aC;
            }, maybePagePath), $elm$core$Maybe$map_fn(function ($) {
                return $.nM;
            }, maybePagePath));
            if (_v2.$ === 1) {
                return $author$project$Main$initErrorPage(pageData);
            }
            else {
                var justRouteAndPath_2_0 = _v2.a;
                var _v3 = _Utils_Tuple2(justRouteAndPath_2_0.a, pageData);
                _v3$7: while (true) {
                    switch (_v3.a.$) {
                        case 0:
                            if (!_v3.b.$) {
                                var _v4 = _v3.a;
                                var thisPageData = _v3.b.a;
                                return $elm$core$Tuple$mapBoth_fn($author$project$Main$ModelArticles__Draft, $author$project$Effect$map($author$project$Main$MsgArticles__Draft), A2($author$project$Route$Articles$Draft$route.dI, sharedModel, {
                                    r: $elm$core$Maybe$andThen_fn(function (andThenUnpack) {
                                        if (!andThenUnpack.$) {
                                            var thisActionData = andThenUnpack.a;
                                            return $elm$core$Maybe$Just(thisActionData);
                                        }
                                        else {
                                            return $elm$core$Maybe$Nothing;
                                        }
                                    }, actionData),
                                    iW: thisPageData,
                                    F: $elm$core$Dict$empty,
                                    I: $elm$core$Dict$empty,
                                    nM: function ($) {
                                        return $.nM;
                                    }(justRouteAndPath_2_0.b),
                                    L: {},
                                    A: sharedData,
                                    on: $dillonkearns$elm_pages_v3_beta$Pages$Fetcher$submit($author$project$Route$Articles$Draft$w3_decode_ActionData),
                                    M: $elm$core$Maybe$Nothing,
                                    lO: $elm$core$Maybe$andThen_fn(function ($) {
                                        return $.ay;
                                    }, maybePagePath)
                                }));
                            }
                            else {
                                break _v3$7;
                            }
                        case 1:
                            if (_v3.b.$ === 1) {
                                var routeParams = _v3.a.a;
                                var thisPageData = _v3.b.a;
                                return $elm$core$Tuple$mapBoth_fn($author$project$Main$ModelArticles__ArticleId_, $author$project$Effect$map($author$project$Main$MsgArticles__ArticleId_), A2($author$project$Route$Articles$ArticleId_$route.dI, sharedModel, {
                                    r: $elm$core$Maybe$andThen_fn(function (andThenUnpack) {
                                        if (andThenUnpack.$ === 1) {
                                            var thisActionData = andThenUnpack.a;
                                            return $elm$core$Maybe$Just(thisActionData);
                                        }
                                        else {
                                            return $elm$core$Maybe$Nothing;
                                        }
                                    }, actionData),
                                    iW: thisPageData,
                                    F: $elm$core$Dict$empty,
                                    I: $elm$core$Dict$empty,
                                    nM: function ($) {
                                        return $.nM;
                                    }(justRouteAndPath_2_0.b),
                                    L: routeParams,
                                    A: sharedData,
                                    on: $dillonkearns$elm_pages_v3_beta$Pages$Fetcher$submit($author$project$Route$Articles$ArticleId_$w3_decode_ActionData),
                                    M: $elm$core$Maybe$Nothing,
                                    lO: $elm$core$Maybe$andThen_fn(function ($) {
                                        return $.ay;
                                    }, maybePagePath)
                                }));
                            }
                            else {
                                break _v3$7;
                            }
                        case 2:
                            if (_v3.b.$ === 2) {
                                var routeParams = _v3.a.a;
                                var thisPageData = _v3.b.a;
                                return $elm$core$Tuple$mapBoth_fn($author$project$Main$ModelTwilogs__Day_, $author$project$Effect$map($author$project$Main$MsgTwilogs__Day_), A2($author$project$Route$Twilogs$Day_$route.dI, sharedModel, {
                                    r: $elm$core$Maybe$andThen_fn(function (andThenUnpack) {
                                        if (andThenUnpack.$ === 2) {
                                            var thisActionData = andThenUnpack.a;
                                            return $elm$core$Maybe$Just(thisActionData);
                                        }
                                        else {
                                            return $elm$core$Maybe$Nothing;
                                        }
                                    }, actionData),
                                    iW: thisPageData,
                                    F: $elm$core$Dict$empty,
                                    I: $elm$core$Dict$empty,
                                    nM: function ($) {
                                        return $.nM;
                                    }(justRouteAndPath_2_0.b),
                                    L: routeParams,
                                    A: sharedData,
                                    on: $dillonkearns$elm_pages_v3_beta$Pages$Fetcher$submit($author$project$Route$Twilogs$Day_$w3_decode_ActionData),
                                    M: $elm$core$Maybe$Nothing,
                                    lO: $elm$core$Maybe$andThen_fn(function ($) {
                                        return $.ay;
                                    }, maybePagePath)
                                }));
                            }
                            else {
                                break _v3$7;
                            }
                        case 3:
                            if (_v3.b.$ === 3) {
                                var _v8 = _v3.a;
                                var thisPageData = _v3.b.a;
                                return $elm$core$Tuple$mapBoth_fn($author$project$Main$ModelAbout, $author$project$Effect$map($author$project$Main$MsgAbout), A2($author$project$Route$About$route.dI, sharedModel, {
                                    r: $elm$core$Maybe$andThen_fn(function (andThenUnpack) {
                                        if (andThenUnpack.$ === 3) {
                                            var thisActionData = andThenUnpack.a;
                                            return $elm$core$Maybe$Just(thisActionData);
                                        }
                                        else {
                                            return $elm$core$Maybe$Nothing;
                                        }
                                    }, actionData),
                                    iW: thisPageData,
                                    F: $elm$core$Dict$empty,
                                    I: $elm$core$Dict$empty,
                                    nM: function ($) {
                                        return $.nM;
                                    }(justRouteAndPath_2_0.b),
                                    L: {},
                                    A: sharedData,
                                    on: $dillonkearns$elm_pages_v3_beta$Pages$Fetcher$submit($author$project$Route$About$w3_decode_ActionData),
                                    M: $elm$core$Maybe$Nothing,
                                    lO: $elm$core$Maybe$andThen_fn(function ($) {
                                        return $.ay;
                                    }, maybePagePath)
                                }));
                            }
                            else {
                                break _v3$7;
                            }
                        case 4:
                            if (_v3.b.$ === 4) {
                                var _v10 = _v3.a;
                                var thisPageData = _v3.b.a;
                                return $elm$core$Tuple$mapBoth_fn($author$project$Main$ModelArticles, $author$project$Effect$map($author$project$Main$MsgArticles), A2($author$project$Route$Articles$route.dI, sharedModel, {
                                    r: $elm$core$Maybe$andThen_fn(function (andThenUnpack) {
                                        if (andThenUnpack.$ === 4) {
                                            var thisActionData = andThenUnpack.a;
                                            return $elm$core$Maybe$Just(thisActionData);
                                        }
                                        else {
                                            return $elm$core$Maybe$Nothing;
                                        }
                                    }, actionData),
                                    iW: thisPageData,
                                    F: $elm$core$Dict$empty,
                                    I: $elm$core$Dict$empty,
                                    nM: function ($) {
                                        return $.nM;
                                    }(justRouteAndPath_2_0.b),
                                    L: {},
                                    A: sharedData,
                                    on: $dillonkearns$elm_pages_v3_beta$Pages$Fetcher$submit($author$project$Route$Articles$w3_decode_ActionData),
                                    M: $elm$core$Maybe$Nothing,
                                    lO: $elm$core$Maybe$andThen_fn(function ($) {
                                        return $.ay;
                                    }, maybePagePath)
                                }));
                            }
                            else {
                                break _v3$7;
                            }
                        case 5:
                            if (_v3.b.$ === 5) {
                                var _v12 = _v3.a;
                                var thisPageData = _v3.b.a;
                                return $elm$core$Tuple$mapBoth_fn($author$project$Main$ModelTwilogs, $author$project$Effect$map($author$project$Main$MsgTwilogs), A2($author$project$Route$Twilogs$route.dI, sharedModel, {
                                    r: $elm$core$Maybe$andThen_fn(function (andThenUnpack) {
                                        if (andThenUnpack.$ === 5) {
                                            var thisActionData = andThenUnpack.a;
                                            return $elm$core$Maybe$Just(thisActionData);
                                        }
                                        else {
                                            return $elm$core$Maybe$Nothing;
                                        }
                                    }, actionData),
                                    iW: thisPageData,
                                    F: $elm$core$Dict$empty,
                                    I: $elm$core$Dict$empty,
                                    nM: function ($) {
                                        return $.nM;
                                    }(justRouteAndPath_2_0.b),
                                    L: {},
                                    A: sharedData,
                                    on: $dillonkearns$elm_pages_v3_beta$Pages$Fetcher$submit($author$project$Route$Twilogs$w3_decode_ActionData),
                                    M: $elm$core$Maybe$Nothing,
                                    lO: $elm$core$Maybe$andThen_fn(function ($) {
                                        return $.ay;
                                    }, maybePagePath)
                                }));
                            }
                            else {
                                break _v3$7;
                            }
                        default:
                            if (_v3.b.$ === 6) {
                                var _v14 = _v3.a;
                                var thisPageData = _v3.b.a;
                                return $elm$core$Tuple$mapBoth_fn($author$project$Main$ModelIndex, $author$project$Effect$map($author$project$Main$MsgIndex), A2($author$project$Route$Index$route.dI, sharedModel, {
                                    r: $elm$core$Maybe$andThen_fn(function (andThenUnpack) {
                                        if (andThenUnpack.$ === 6) {
                                            var thisActionData = andThenUnpack.a;
                                            return $elm$core$Maybe$Just(thisActionData);
                                        }
                                        else {
                                            return $elm$core$Maybe$Nothing;
                                        }
                                    }, actionData),
                                    iW: thisPageData,
                                    F: $elm$core$Dict$empty,
                                    I: $elm$core$Dict$empty,
                                    nM: function ($) {
                                        return $.nM;
                                    }(justRouteAndPath_2_0.b),
                                    L: {},
                                    A: sharedData,
                                    on: $dillonkearns$elm_pages_v3_beta$Pages$Fetcher$submit($author$project$Route$Index$w3_decode_ActionData),
                                    M: $elm$core$Maybe$Nothing,
                                    lO: $elm$core$Maybe$andThen_fn(function ($) {
                                        return $.ay;
                                    }, maybePagePath)
                                }));
                            }
                            else {
                                break _v3$7;
                            }
                    }
                }
                return $author$project$Main$initErrorPage(pageData);
            }
        }();
        var templateModel = _v1.a;
        var templateCmd = _v1.b;
        return _Utils_Tuple2({ N: maybePagePath, f: sharedModel, n: templateModel }, $author$project$Effect$batch(_List_fromArray([
            templateCmd,
            $author$project$Effect$map_fn($author$project$Main$MsgGlobal, globalCmd)
        ])));
    }, $author$project$Main$init = F6($author$project$Main$init_fn);
    var $author$project$ErrorPage$internalError = $author$project$ErrorPage$InternalError;
    var $author$project$Main$onActionData = function (actionData) {
        switch (actionData.$) {
            case 0:
                var thisActionData = actionData.a;
                return $elm$core$Maybe$map_fn(function (mapUnpack) {
                    return $author$project$Main$MsgArticles__Draft(mapUnpack(thisActionData));
                }, $author$project$Route$Articles$Draft$route.fJ);
            case 1:
                var thisActionData = actionData.a;
                return $elm$core$Maybe$map_fn(function (mapUnpack) {
                    return $author$project$Main$MsgArticles__ArticleId_(mapUnpack(thisActionData));
                }, $author$project$Route$Articles$ArticleId_$route.fJ);
            case 2:
                var thisActionData = actionData.a;
                return $elm$core$Maybe$map_fn(function (mapUnpack) {
                    return $author$project$Main$MsgTwilogs__Day_(mapUnpack(thisActionData));
                }, $author$project$Route$Twilogs$Day_$route.fJ);
            case 3:
                var thisActionData = actionData.a;
                return $elm$core$Maybe$map_fn(function (mapUnpack) {
                    return $author$project$Main$MsgAbout(mapUnpack(thisActionData));
                }, $author$project$Route$About$route.fJ);
            case 4:
                var thisActionData = actionData.a;
                return $elm$core$Maybe$map_fn(function (mapUnpack) {
                    return $author$project$Main$MsgArticles(mapUnpack(thisActionData));
                }, $author$project$Route$Articles$route.fJ);
            case 5:
                var thisActionData = actionData.a;
                return $elm$core$Maybe$map_fn(function (mapUnpack) {
                    return $author$project$Main$MsgTwilogs(mapUnpack(thisActionData));
                }, $author$project$Route$Twilogs$route.fJ);
            default:
                var thisActionData = actionData.a;
                return $elm$core$Maybe$map_fn(function (mapUnpack) {
                    return $author$project$Main$MsgIndex(mapUnpack(thisActionData));
                }, $author$project$Route$Index$route.fJ);
        }
    };
    var $dillonkearns$elm_pages_v3_beta$ApiRoute$getBuildTimeRoutes = function (_v0) {
        var handler = _v0;
        return handler.iP;
    };
    var $author$project$Main$routePatterns = $dillonkearns$elm_pages_v3_beta$ApiRoute$single($dillonkearns$elm_pages_v3_beta$ApiRoute$literal_fn("route-patterns.json", $dillonkearns$elm_pages_v3_beta$ApiRoute$succeed($dillonkearns$elm_pages_v3_beta$BackendTask$succeed(_Json_encode_fn(0, $elm$json$Json$Encode$list_fn(function (info) {
        return $elm$json$Json$Encode$object(_List_fromArray([
            _Utils_Tuple2("kind", $elm$json$Json$Encode$string(info.a8)),
            _Utils_Tuple2("pathPattern", $elm$json$Json$Encode$string(info.eQ))
        ]));
    }, _List_fromArray([
        { a8: $author$project$Route$Articles$Draft$route.a8, eQ: "/articles/draft" },
        { a8: $author$project$Route$Articles$ArticleId_$route.a8, eQ: "/articles/:articleId" },
        { a8: $author$project$Route$Twilogs$Day_$route.a8, eQ: "/twilogs/:day" },
        { a8: $author$project$Route$About$route.a8, eQ: "/about" },
        { a8: $author$project$Route$Articles$route.a8, eQ: "/articles" },
        { a8: $author$project$Route$Twilogs$route.a8, eQ: "/twilogs" },
        { a8: $author$project$Route$Index$route.a8, eQ: "/" }
    ])))))));
    var $author$project$Main$pathsToGenerateHandler = $dillonkearns$elm_pages_v3_beta$ApiRoute$single($dillonkearns$elm_pages_v3_beta$ApiRoute$literal_fn("all-paths.json", $dillonkearns$elm_pages_v3_beta$ApiRoute$succeed($dillonkearns$elm_pages_v3_beta$BackendTask$map2_fn(function (map2Unpack) {
        return function (unpack) {
            return _Json_encode_fn(0, $elm$json$Json$Encode$list_fn($elm$json$Json$Encode$string, _Utils_ap(map2Unpack, $elm$core$List$map_fn(function (api) {
                return "/" + api;
            }, unpack))));
        };
    }, $dillonkearns$elm_pages_v3_beta$BackendTask$map_fn($elm$core$List$map(function (route) {
        return $dillonkearns$elm_pages_v3_beta$Path$toAbsolute($author$project$Route$toPath(route));
    }), $author$project$Main$getStaticRoutes), $dillonkearns$elm_pages_v3_beta$BackendTask$map_fn($elm$core$List$concat, $dillonkearns$elm_pages_v3_beta$BackendTask$combine($elm$core$List$map_fn($dillonkearns$elm_pages_v3_beta$ApiRoute$getBuildTimeRoutes, _List_Cons($author$project$Main$routePatterns, _List_Cons($author$project$Main$apiPatterns, $author$project$Api$routes_fn($author$project$Main$getStaticRoutes, F2(function (a, b) {
        return "";
    })))))))))));
    var $author$project$Effect$perform_fn = function (helpers, effect) {
        var key = helpers.m5;
        var fromPageMsg = helpers.mM;
        switch (effect.$) {
            case 0:
                return $elm$core$Platform$Cmd$none;
            case 1:
                var cmd = effect.a;
                return _Platform_map_fn(fromPageMsg, cmd);
            case 3:
                var info = effect.a;
                return helpers.oe(info);
            case 2:
                var list = effect.a;
                return $elm$core$Platform$Cmd$batch($elm$core$List$map_fn($author$project$Effect$perform(helpers), list));
            case 4:
                var fetchInfo = effect.a;
                return helpers.mF(fetchInfo);
            case 5:
                var record = effect.a;
                return helpers.on(record);
            default:
                var record = effect.a;
                return helpers.n8(record);
        }
    }, $author$project$Effect$perform = F2($author$project$Effect$perform_fn);
    var $author$project$Main$routePatterns3 = _List_fromArray([
        {
            bn: $elm$core$Maybe$Nothing,
            bI: _List_fromArray([
                $dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$StaticSegment("articles"),
                $dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$StaticSegment("draft")
            ])
        },
        {
            bn: $elm$core$Maybe$Nothing,
            bI: _List_fromArray([
                $dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$StaticSegment("articles"),
                $dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$DynamicSegment("articleId")
            ])
        },
        {
            bn: $elm$core$Maybe$Nothing,
            bI: _List_fromArray([
                $dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$StaticSegment("twilogs"),
                $dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$DynamicSegment("day")
            ])
        },
        {
            bn: $elm$core$Maybe$Nothing,
            bI: _List_fromArray([
                $dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$StaticSegment("about")
            ])
        },
        {
            bn: $elm$core$Maybe$Nothing,
            bI: _List_fromArray([
                $dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$StaticSegment("articles")
            ])
        },
        {
            bn: $elm$core$Maybe$Nothing,
            bI: _List_fromArray([
                $dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$StaticSegment("twilogs")
            ])
        },
        {
            bn: $elm$core$Maybe$Nothing,
            bI: _List_fromArray([
                $dillonkearns$elm_pages_v3_beta$Pages$Internal$RoutePattern$StaticSegment("index")
            ])
        }
    ]);
    var $lamdera$codecs$Lamdera$Wire3$encodeBytes_ = _LamderaCodecs_encodeBytes;
    var $author$project$Main$sendPageData = _Platform_outgoingPort("sendPageData", function ($) {
        return $elm$json$Json$Encode$object(_List_fromArray([
            _Utils_Tuple2("binaryPageData", $lamdera$codecs$Lamdera$Wire3$encodeBytes_($.l4)),
            _Utils_Tuple2("oldThing", $elm$core$Basics$identity($.nD))
        ]));
    });
    var $author$project$ErrorPage$statusCode = function (error) {
        if (!error.$) {
            return 404;
        }
        else {
            return 500;
        }
    };
    var $author$project$Main$templateSubscriptions_fn = function (route, path, model) {
        if (route.$ === 1) {
            return $elm$core$Platform$Sub$none;
        }
        else {
            var justRoute_1_0 = route.a;
            switch (justRoute_1_0.$) {
                case 0:
                    var _v2 = model.n;
                    if (!_v2.$) {
                        var templateModel = _v2.a;
                        return _Platform_map_fn($author$project$Main$MsgArticles__Draft, A4($author$project$Route$Articles$Draft$route.dW, {}, path, templateModel, model.f));
                    }
                    else {
                        var otherwise_1_0_1_1_1_0 = _v2;
                        return $elm$core$Platform$Sub$none;
                    }
                case 1:
                    var routeParams = justRoute_1_0.a;
                    var _v3 = model.n;
                    if (_v3.$ === 1) {
                        var templateModel = _v3.a;
                        return _Platform_map_fn($author$project$Main$MsgArticles__ArticleId_, A4($author$project$Route$Articles$ArticleId_$route.dW, routeParams, path, templateModel, model.f));
                    }
                    else {
                        var otherwise_1_0_1_1_1_0 = _v3;
                        return $elm$core$Platform$Sub$none;
                    }
                case 2:
                    var routeParams = justRoute_1_0.a;
                    var _v4 = model.n;
                    if (_v4.$ === 2) {
                        var templateModel = _v4.a;
                        return _Platform_map_fn($author$project$Main$MsgTwilogs__Day_, A4($author$project$Route$Twilogs$Day_$route.dW, routeParams, path, templateModel, model.f));
                    }
                    else {
                        var otherwise_1_0_1_1_1_0 = _v4;
                        return $elm$core$Platform$Sub$none;
                    }
                case 3:
                    var _v5 = model.n;
                    if (_v5.$ === 3) {
                        var templateModel = _v5.a;
                        return _Platform_map_fn($author$project$Main$MsgAbout, A4($author$project$Route$About$route.dW, {}, path, templateModel, model.f));
                    }
                    else {
                        var otherwise_1_0_1_1_1_0 = _v5;
                        return $elm$core$Platform$Sub$none;
                    }
                case 4:
                    var _v6 = model.n;
                    if (_v6.$ === 4) {
                        var templateModel = _v6.a;
                        return _Platform_map_fn($author$project$Main$MsgArticles, A4($author$project$Route$Articles$route.dW, {}, path, templateModel, model.f));
                    }
                    else {
                        var otherwise_1_0_1_1_1_0 = _v6;
                        return $elm$core$Platform$Sub$none;
                    }
                case 5:
                    var _v7 = model.n;
                    if (_v7.$ === 5) {
                        var templateModel = _v7.a;
                        return _Platform_map_fn($author$project$Main$MsgTwilogs, A4($author$project$Route$Twilogs$route.dW, {}, path, templateModel, model.f));
                    }
                    else {
                        var otherwise_1_0_1_1_1_0 = _v7;
                        return $elm$core$Platform$Sub$none;
                    }
                default:
                    var _v8 = model.n;
                    if (_v8.$ === 6) {
                        var templateModel = _v8.a;
                        return _Platform_map_fn($author$project$Main$MsgIndex, A4($author$project$Route$Index$route.dW, {}, path, templateModel, model.f));
                    }
                    else {
                        var otherwise_1_0_1_1_1_0 = _v8;
                        return $elm$core$Platform$Sub$none;
                    }
            }
        }
    }, $author$project$Main$templateSubscriptions = F3($author$project$Main$templateSubscriptions_fn);
    var $author$project$Main$subscriptions_fn = function (route, path, model) {
        return $elm$core$Platform$Sub$batch(_List_fromArray([
            _Platform_map_fn($author$project$Main$MsgGlobal, A2($author$project$Shared$template.dW, path, model.f)),
            $author$project$Main$templateSubscriptions_fn(route, path, model)
        ]));
    }, $author$project$Main$subscriptions = F3($author$project$Main$subscriptions_fn);
    var $author$project$Main$toJsPort = _Platform_outgoingPort("toJsPort", $elm$core$Basics$identity);
    var $author$project$Main$fooFn_fn = function (wrapModel, wrapMsg, model, triple) {
        var a = triple.a;
        var b = triple.b;
        var c = triple.c;
        return _Utils_Tuple3(wrapModel(a), $author$project$Effect$map_fn(wrapMsg, b), function () {
            if (c.$ === 1) {
                return _Utils_Tuple2(model.f, $author$project$Effect$none);
            }
            else {
                var sharedMsg_3 = c.a;
                return A2($author$project$Shared$template.cF, sharedMsg_3, model.f);
            }
        }());
    }, $author$project$Main$fooFn = F4($author$project$Main$fooFn_fn);
    var $dillonkearns$elm_pages_v3_beta$Pages$Transition$FetcherComplete = function (a) {
        return { $: 2, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$Transition$FetcherReloading = function (a) {
        return { $: 1, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$Transition$FetcherSubmitting = { $: 0 };
    var $dillonkearns$elm_pages_v3_beta$Pages$Transition$mapStatus_fn = function (mapFn, fetcherSubmitStatus) {
        switch (fetcherSubmitStatus.$) {
            case 0:
                return $dillonkearns$elm_pages_v3_beta$Pages$Transition$FetcherSubmitting;
            case 1:
                var value = fetcherSubmitStatus.a;
                return $dillonkearns$elm_pages_v3_beta$Pages$Transition$FetcherReloading(mapFn(value));
            default:
                var value = fetcherSubmitStatus.a;
                return $dillonkearns$elm_pages_v3_beta$Pages$Transition$FetcherComplete(mapFn(value));
        }
    }, $dillonkearns$elm_pages_v3_beta$Pages$Transition$mapStatus = F2($dillonkearns$elm_pages_v3_beta$Pages$Transition$mapStatus_fn);
    var $dillonkearns$elm_pages_v3_beta$Pages$Transition$map_fn = function (mapFn, fetcherState) {
        return {
            m0: fetcherState.m0,
            nO: fetcherState.nO,
            dV: $dillonkearns$elm_pages_v3_beta$Pages$Transition$mapStatus_fn(mapFn, fetcherState.dV)
        };
    }, $dillonkearns$elm_pages_v3_beta$Pages$Transition$map = F2($dillonkearns$elm_pages_v3_beta$Pages$Transition$map_fn);
    var $elm$core$Maybe$map3_fn = function (func, ma, mb, mc) {
        if (ma.$ === 1) {
            return $elm$core$Maybe$Nothing;
        }
        else {
            var a = ma.a;
            if (mb.$ === 1) {
                return $elm$core$Maybe$Nothing;
            }
            else {
                var b = mb.a;
                if (mc.$ === 1) {
                    return $elm$core$Maybe$Nothing;
                }
                else {
                    var c = mc.a;
                    return $elm$core$Maybe$Just(A3(func, a, b, c));
                }
            }
        }
    }, $elm$core$Maybe$map3_fn_unwrapped = function (func, ma, mb, mc) {
        if (ma.$ === 1) {
            return $elm$core$Maybe$Nothing;
        }
        else {
            var a = ma.a;
            if (mb.$ === 1) {
                return $elm$core$Maybe$Nothing;
            }
            else {
                var b = mb.a;
                if (mc.$ === 1) {
                    return $elm$core$Maybe$Nothing;
                }
                else {
                    var c = mc.a;
                    return $elm$core$Maybe$Just(func(a, b, c));
                }
            }
        }
    }, $elm$core$Maybe$map3 = F4($elm$core$Maybe$map3_fn);
    var $dillonkearns$elm_pages_v3_beta$QueryParams$addToParametersHelp_fn = function (value, maybeList) {
        if (maybeList.$ === 1) {
            return $elm$core$Maybe$Just(_List_fromArray([value]));
        }
        else {
            var list = maybeList.a;
            return $elm$core$Maybe$Just(_List_Cons(value, list));
        }
    }, $dillonkearns$elm_pages_v3_beta$QueryParams$addToParametersHelp = F2($dillonkearns$elm_pages_v3_beta$QueryParams$addToParametersHelp_fn);
    var $elm$url$Url$percentDecode = _Url_percentDecode;
    var $dillonkearns$elm_pages_v3_beta$QueryParams$addParam_fn = function (segment, dict) {
        var _v0 = $elm$core$String$split_fn("=", segment);
        if ((_v0.b && _v0.b.b) && (!_v0.b.b.b)) {
            var rawKey = _v0.a;
            var _v1 = _v0.b;
            var rawValue = _v1.a;
            var _v2 = $elm$url$Url$percentDecode(rawKey);
            if (_v2.$ === 1) {
                return dict;
            }
            else {
                var key = _v2.a;
                var _v3 = $elm$url$Url$percentDecode(rawValue);
                if (_v3.$ === 1) {
                    return dict;
                }
                else {
                    var value = _v3.a;
                    return $elm$core$Dict$update_fn(key, $dillonkearns$elm_pages_v3_beta$QueryParams$addToParametersHelp(value), dict);
                }
            }
        }
        else {
            return dict;
        }
    }, $dillonkearns$elm_pages_v3_beta$QueryParams$addParam = F2($dillonkearns$elm_pages_v3_beta$QueryParams$addParam_fn);
    var $dillonkearns$elm_pages_v3_beta$QueryParams$fromString = function (query) {
        return $elm$core$List$foldr_fn($dillonkearns$elm_pages_v3_beta$QueryParams$addParam, $elm$core$Dict$empty, $elm$core$String$split_fn("&", query));
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$PageUrl$parseQueryParams = $dillonkearns$elm_pages_v3_beta$QueryParams$fromString;
    var $author$project$Main$toTriple_fn = function (a, b, c) {
        return _Utils_Tuple3(a, b, c);
    }, $author$project$Main$toTriple = F3($author$project$Main$toTriple_fn);
    var $author$project$ErrorPage$update_fn = function (errorPage, msg, model) {
        return _Utils_Tuple2(_Utils_update(model, { dt: model.dt + 1 }), $author$project$Effect$none);
    }, $author$project$ErrorPage$update = F3($author$project$ErrorPage$update_fn);
    var $author$project$Main$update_fn = function (pageFormState, fetchers, transition, sharedData, pageData, navigationKey, msg, model) {
        switch (msg.$) {
            case 9:
                var msg_ = msg.a;
                var _v1 = function () {
                    var _v2 = _Utils_Tuple2(model.n, pageData);
                    if ((_v2.a.$ === 7) && (_v2.b.$ === 8)) {
                        var pageModel = _v2.a.a;
                        var thisPageData = _v2.b.a;
                        return $elm$core$Tuple$mapBoth_fn($author$project$Main$ModelErrorPage____, $author$project$Effect$map($author$project$Main$MsgErrorPage____), $author$project$ErrorPage$update_fn(thisPageData, msg_, pageModel));
                    }
                    else {
                        return _Utils_Tuple2(model.n, $author$project$Effect$none);
                    }
                }();
                var updatedPageModel = _v1.a;
                var pageCmd = _v1.b;
                return _Utils_Tuple2(_Utils_update(model, { n: updatedPageModel }), pageCmd);
            case 7:
                var msg_ = msg.a;
                var _v3 = A2($author$project$Shared$template.cF, msg_, model.f);
                var sharedModel = _v3.a;
                var globalCmd = _v3.b;
                return _Utils_Tuple2(_Utils_update(model, { f: sharedModel }), $author$project$Effect$map_fn($author$project$Main$MsgGlobal, globalCmd));
            case 8:
                var record = msg.a;
                var _v4 = $author$project$Main$init_fn($elm$core$Maybe$Just(model.f), $dillonkearns$elm_pages_v3_beta$Pages$Flags$PreRenderFlags, sharedData, pageData, $elm$core$Maybe$Nothing, $elm$core$Maybe$Just({
                    aC: record.aC,
                    ay: $elm$core$Maybe$Just({
                        bq: record.bq,
                        gu: record.gu,
                        nM: record.nM,
                        gS: record.gS,
                        gZ: record.gZ,
                        bG: $elm$core$Maybe$withDefault_fn($elm$core$Dict$empty, $elm$core$Maybe$map_fn($dillonkearns$elm_pages_v3_beta$Pages$PageUrl$parseQueryParams, record.bG))
                    }),
                    nM: { bq: record.bq, nM: record.nM, bG: record.bG }
                }));
                var updatedModel = _v4.a;
                var cmd = _v4.b;
                var _v5 = navigationKey;
                var _v6 = $author$project$Shared$template.lr;
                if (_v6.$ === 1) {
                    return _Utils_Tuple2(updatedModel, cmd);
                }
                else {
                    var thingy_3 = _v6.a;
                    var _v7 = A2($author$project$Shared$template.cF, thingy_3({ bq: record.bq, nM: record.nM, bG: record.bG }), model.f);
                    var updatedGlobalModel = _v7.a;
                    var globalCmd = _v7.b;
                    return _Utils_Tuple2(_Utils_update(updatedModel, { f: updatedGlobalModel }), $author$project$Effect$batch(_List_fromArray([
                        cmd,
                        $author$project$Effect$map_fn($author$project$Main$MsgGlobal, globalCmd)
                    ])));
                }
            case 0:
                var msg_ = msg.a;
                var _v8 = _Utils_Tuple3(model.n, pageData, $elm$core$Maybe$map3_fn($author$project$Main$toTriple, $elm$core$Maybe$andThen_fn(function ($) {
                    return $.aC;
                }, model.N), $elm$core$Maybe$andThen_fn(function ($) {
                    return $.ay;
                }, model.N), $elm$core$Maybe$map_fn(function ($) {
                    return $.nM;
                }, model.N)));
                if ((((!_v8.a.$) && (!_v8.b.$)) && (!_v8.c.$)) && (!_v8.c.a.a.$)) {
                    var pageModel = _v8.a.a;
                    var thisPageData = _v8.b.a;
                    var _v9 = _v8.c.a;
                    var _v10 = _v9.a;
                    var pageUrl = _v9.b;
                    var justPage = _v9.c;
                    var _v11 = $author$project$Main$fooFn_fn($author$project$Main$ModelArticles__Draft, $author$project$Main$MsgArticles__Draft, model, A4($author$project$Route$Articles$Draft$route.cF, {
                        r: $elm$core$Maybe$Nothing,
                        iW: thisPageData,
                        F: $elm$core$Dict$map_fn(function (mapUnpack) {
                            return $dillonkearns$elm_pages_v3_beta$Pages$Transition$map(function (mapUnpack0) {
                                if (!mapUnpack0.$) {
                                    var justActionData = mapUnpack0.a;
                                    return $elm$core$Maybe$Just(justActionData);
                                }
                                else {
                                    return $elm$core$Maybe$Nothing;
                                }
                            });
                        }, fetchers),
                        I: pageFormState,
                        nM: justPage.nM,
                        L: {},
                        A: sharedData,
                        on: function (options) {
                            return $dillonkearns$elm_pages_v3_beta$Pages$Fetcher$submit_fn($author$project$Route$Articles$Draft$w3_decode_ActionData, options);
                        },
                        M: transition,
                        lO: $elm$core$Maybe$Just(pageUrl)
                    }, msg_, pageModel, model.f));
                    var updatedPageModel = _v11.a;
                    var pageCmd = _v11.b;
                    var _v12 = _v11.c;
                    var newGlobalModel = _v12.a;
                    var newGlobalCmd = _v12.b;
                    return _Utils_Tuple2(_Utils_update(model, { f: newGlobalModel, n: updatedPageModel }), $author$project$Effect$batch(_List_fromArray([
                        pageCmd,
                        $author$project$Effect$map_fn($author$project$Main$MsgGlobal, newGlobalCmd)
                    ])));
                }
                else {
                    return _Utils_Tuple2(model, $author$project$Effect$none);
                }
            case 1:
                var msg_ = msg.a;
                var _v14 = _Utils_Tuple3(model.n, pageData, $elm$core$Maybe$map3_fn($author$project$Main$toTriple, $elm$core$Maybe$andThen_fn(function ($) {
                    return $.aC;
                }, model.N), $elm$core$Maybe$andThen_fn(function ($) {
                    return $.ay;
                }, model.N), $elm$core$Maybe$map_fn(function ($) {
                    return $.nM;
                }, model.N)));
                if ((((_v14.a.$ === 1) && (_v14.b.$ === 1)) && (!_v14.c.$)) && (_v14.c.a.a.$ === 1)) {
                    var pageModel = _v14.a.a;
                    var thisPageData = _v14.b.a;
                    var _v15 = _v14.c.a;
                    var routeParams = _v15.a.a;
                    var pageUrl = _v15.b;
                    var justPage = _v15.c;
                    var _v16 = $author$project$Main$fooFn_fn($author$project$Main$ModelArticles__ArticleId_, $author$project$Main$MsgArticles__ArticleId_, model, A4($author$project$Route$Articles$ArticleId_$route.cF, {
                        r: $elm$core$Maybe$Nothing,
                        iW: thisPageData,
                        F: $elm$core$Dict$map_fn(function (mapUnpack) {
                            return $dillonkearns$elm_pages_v3_beta$Pages$Transition$map(function (mapUnpack0) {
                                if (mapUnpack0.$ === 1) {
                                    var justActionData = mapUnpack0.a;
                                    return $elm$core$Maybe$Just(justActionData);
                                }
                                else {
                                    return $elm$core$Maybe$Nothing;
                                }
                            });
                        }, fetchers),
                        I: pageFormState,
                        nM: justPage.nM,
                        L: routeParams,
                        A: sharedData,
                        on: function (options) {
                            return $dillonkearns$elm_pages_v3_beta$Pages$Fetcher$submit_fn($author$project$Route$Articles$ArticleId_$w3_decode_ActionData, options);
                        },
                        M: transition,
                        lO: $elm$core$Maybe$Just(pageUrl)
                    }, msg_, pageModel, model.f));
                    var updatedPageModel = _v16.a;
                    var pageCmd = _v16.b;
                    var _v17 = _v16.c;
                    var newGlobalModel = _v17.a;
                    var newGlobalCmd = _v17.b;
                    return _Utils_Tuple2(_Utils_update(model, { f: newGlobalModel, n: updatedPageModel }), $author$project$Effect$batch(_List_fromArray([
                        pageCmd,
                        $author$project$Effect$map_fn($author$project$Main$MsgGlobal, newGlobalCmd)
                    ])));
                }
                else {
                    return _Utils_Tuple2(model, $author$project$Effect$none);
                }
            case 2:
                var msg_ = msg.a;
                var _v19 = _Utils_Tuple3(model.n, pageData, $elm$core$Maybe$map3_fn($author$project$Main$toTriple, $elm$core$Maybe$andThen_fn(function ($) {
                    return $.aC;
                }, model.N), $elm$core$Maybe$andThen_fn(function ($) {
                    return $.ay;
                }, model.N), $elm$core$Maybe$map_fn(function ($) {
                    return $.nM;
                }, model.N)));
                if ((((_v19.a.$ === 2) && (_v19.b.$ === 2)) && (!_v19.c.$)) && (_v19.c.a.a.$ === 2)) {
                    var pageModel = _v19.a.a;
                    var thisPageData = _v19.b.a;
                    var _v20 = _v19.c.a;
                    var routeParams = _v20.a.a;
                    var pageUrl = _v20.b;
                    var justPage = _v20.c;
                    var _v21 = $author$project$Main$fooFn_fn($author$project$Main$ModelTwilogs__Day_, $author$project$Main$MsgTwilogs__Day_, model, A4($author$project$Route$Twilogs$Day_$route.cF, {
                        r: $elm$core$Maybe$Nothing,
                        iW: thisPageData,
                        F: $elm$core$Dict$map_fn(function (mapUnpack) {
                            return $dillonkearns$elm_pages_v3_beta$Pages$Transition$map(function (mapUnpack0) {
                                if (mapUnpack0.$ === 2) {
                                    var justActionData = mapUnpack0.a;
                                    return $elm$core$Maybe$Just(justActionData);
                                }
                                else {
                                    return $elm$core$Maybe$Nothing;
                                }
                            });
                        }, fetchers),
                        I: pageFormState,
                        nM: justPage.nM,
                        L: routeParams,
                        A: sharedData,
                        on: function (options) {
                            return $dillonkearns$elm_pages_v3_beta$Pages$Fetcher$submit_fn($author$project$Route$Twilogs$Day_$w3_decode_ActionData, options);
                        },
                        M: transition,
                        lO: $elm$core$Maybe$Just(pageUrl)
                    }, msg_, pageModel, model.f));
                    var updatedPageModel = _v21.a;
                    var pageCmd = _v21.b;
                    var _v22 = _v21.c;
                    var newGlobalModel = _v22.a;
                    var newGlobalCmd = _v22.b;
                    return _Utils_Tuple2(_Utils_update(model, { f: newGlobalModel, n: updatedPageModel }), $author$project$Effect$batch(_List_fromArray([
                        pageCmd,
                        $author$project$Effect$map_fn($author$project$Main$MsgGlobal, newGlobalCmd)
                    ])));
                }
                else {
                    return _Utils_Tuple2(model, $author$project$Effect$none);
                }
            case 3:
                var msg_ = msg.a;
                var _v24 = _Utils_Tuple3(model.n, pageData, $elm$core$Maybe$map3_fn($author$project$Main$toTriple, $elm$core$Maybe$andThen_fn(function ($) {
                    return $.aC;
                }, model.N), $elm$core$Maybe$andThen_fn(function ($) {
                    return $.ay;
                }, model.N), $elm$core$Maybe$map_fn(function ($) {
                    return $.nM;
                }, model.N)));
                if ((((_v24.a.$ === 3) && (_v24.b.$ === 3)) && (!_v24.c.$)) && (_v24.c.a.a.$ === 3)) {
                    var pageModel = _v24.a.a;
                    var thisPageData = _v24.b.a;
                    var _v25 = _v24.c.a;
                    var _v26 = _v25.a;
                    var pageUrl = _v25.b;
                    var justPage = _v25.c;
                    var _v27 = $author$project$Main$fooFn_fn($author$project$Main$ModelAbout, $author$project$Main$MsgAbout, model, A4($author$project$Route$About$route.cF, {
                        r: $elm$core$Maybe$Nothing,
                        iW: thisPageData,
                        F: $elm$core$Dict$map_fn(function (mapUnpack) {
                            return $dillonkearns$elm_pages_v3_beta$Pages$Transition$map(function (mapUnpack0) {
                                if (mapUnpack0.$ === 3) {
                                    var justActionData = mapUnpack0.a;
                                    return $elm$core$Maybe$Just(justActionData);
                                }
                                else {
                                    return $elm$core$Maybe$Nothing;
                                }
                            });
                        }, fetchers),
                        I: pageFormState,
                        nM: justPage.nM,
                        L: {},
                        A: sharedData,
                        on: function (options) {
                            return $dillonkearns$elm_pages_v3_beta$Pages$Fetcher$submit_fn($author$project$Route$About$w3_decode_ActionData, options);
                        },
                        M: transition,
                        lO: $elm$core$Maybe$Just(pageUrl)
                    }, msg_, pageModel, model.f));
                    var updatedPageModel = _v27.a;
                    var pageCmd = _v27.b;
                    var _v28 = _v27.c;
                    var newGlobalModel = _v28.a;
                    var newGlobalCmd = _v28.b;
                    return _Utils_Tuple2(_Utils_update(model, { f: newGlobalModel, n: updatedPageModel }), $author$project$Effect$batch(_List_fromArray([
                        pageCmd,
                        $author$project$Effect$map_fn($author$project$Main$MsgGlobal, newGlobalCmd)
                    ])));
                }
                else {
                    return _Utils_Tuple2(model, $author$project$Effect$none);
                }
            case 4:
                var msg_ = msg.a;
                var _v30 = _Utils_Tuple3(model.n, pageData, $elm$core$Maybe$map3_fn($author$project$Main$toTriple, $elm$core$Maybe$andThen_fn(function ($) {
                    return $.aC;
                }, model.N), $elm$core$Maybe$andThen_fn(function ($) {
                    return $.ay;
                }, model.N), $elm$core$Maybe$map_fn(function ($) {
                    return $.nM;
                }, model.N)));
                if ((((_v30.a.$ === 4) && (_v30.b.$ === 4)) && (!_v30.c.$)) && (_v30.c.a.a.$ === 4)) {
                    var pageModel = _v30.a.a;
                    var thisPageData = _v30.b.a;
                    var _v31 = _v30.c.a;
                    var _v32 = _v31.a;
                    var pageUrl = _v31.b;
                    var justPage = _v31.c;
                    var _v33 = $author$project$Main$fooFn_fn($author$project$Main$ModelArticles, $author$project$Main$MsgArticles, model, A4($author$project$Route$Articles$route.cF, {
                        r: $elm$core$Maybe$Nothing,
                        iW: thisPageData,
                        F: $elm$core$Dict$map_fn(function (mapUnpack) {
                            return $dillonkearns$elm_pages_v3_beta$Pages$Transition$map(function (mapUnpack0) {
                                if (mapUnpack0.$ === 4) {
                                    var justActionData = mapUnpack0.a;
                                    return $elm$core$Maybe$Just(justActionData);
                                }
                                else {
                                    return $elm$core$Maybe$Nothing;
                                }
                            });
                        }, fetchers),
                        I: pageFormState,
                        nM: justPage.nM,
                        L: {},
                        A: sharedData,
                        on: function (options) {
                            return $dillonkearns$elm_pages_v3_beta$Pages$Fetcher$submit_fn($author$project$Route$Articles$w3_decode_ActionData, options);
                        },
                        M: transition,
                        lO: $elm$core$Maybe$Just(pageUrl)
                    }, msg_, pageModel, model.f));
                    var updatedPageModel = _v33.a;
                    var pageCmd = _v33.b;
                    var _v34 = _v33.c;
                    var newGlobalModel = _v34.a;
                    var newGlobalCmd = _v34.b;
                    return _Utils_Tuple2(_Utils_update(model, { f: newGlobalModel, n: updatedPageModel }), $author$project$Effect$batch(_List_fromArray([
                        pageCmd,
                        $author$project$Effect$map_fn($author$project$Main$MsgGlobal, newGlobalCmd)
                    ])));
                }
                else {
                    return _Utils_Tuple2(model, $author$project$Effect$none);
                }
            case 5:
                var msg_ = msg.a;
                var _v36 = _Utils_Tuple3(model.n, pageData, $elm$core$Maybe$map3_fn($author$project$Main$toTriple, $elm$core$Maybe$andThen_fn(function ($) {
                    return $.aC;
                }, model.N), $elm$core$Maybe$andThen_fn(function ($) {
                    return $.ay;
                }, model.N), $elm$core$Maybe$map_fn(function ($) {
                    return $.nM;
                }, model.N)));
                if ((((_v36.a.$ === 5) && (_v36.b.$ === 5)) && (!_v36.c.$)) && (_v36.c.a.a.$ === 5)) {
                    var pageModel = _v36.a.a;
                    var thisPageData = _v36.b.a;
                    var _v37 = _v36.c.a;
                    var _v38 = _v37.a;
                    var pageUrl = _v37.b;
                    var justPage = _v37.c;
                    var _v39 = $author$project$Main$fooFn_fn($author$project$Main$ModelTwilogs, $author$project$Main$MsgTwilogs, model, A4($author$project$Route$Twilogs$route.cF, {
                        r: $elm$core$Maybe$Nothing,
                        iW: thisPageData,
                        F: $elm$core$Dict$map_fn(function (mapUnpack) {
                            return $dillonkearns$elm_pages_v3_beta$Pages$Transition$map(function (mapUnpack0) {
                                if (mapUnpack0.$ === 5) {
                                    var justActionData = mapUnpack0.a;
                                    return $elm$core$Maybe$Just(justActionData);
                                }
                                else {
                                    return $elm$core$Maybe$Nothing;
                                }
                            });
                        }, fetchers),
                        I: pageFormState,
                        nM: justPage.nM,
                        L: {},
                        A: sharedData,
                        on: function (options) {
                            return $dillonkearns$elm_pages_v3_beta$Pages$Fetcher$submit_fn($author$project$Route$Twilogs$w3_decode_ActionData, options);
                        },
                        M: transition,
                        lO: $elm$core$Maybe$Just(pageUrl)
                    }, msg_, pageModel, model.f));
                    var updatedPageModel = _v39.a;
                    var pageCmd = _v39.b;
                    var _v40 = _v39.c;
                    var newGlobalModel = _v40.a;
                    var newGlobalCmd = _v40.b;
                    return _Utils_Tuple2(_Utils_update(model, { f: newGlobalModel, n: updatedPageModel }), $author$project$Effect$batch(_List_fromArray([
                        pageCmd,
                        $author$project$Effect$map_fn($author$project$Main$MsgGlobal, newGlobalCmd)
                    ])));
                }
                else {
                    return _Utils_Tuple2(model, $author$project$Effect$none);
                }
            default:
                var msg_ = msg.a;
                var _v42 = _Utils_Tuple3(model.n, pageData, $elm$core$Maybe$map3_fn($author$project$Main$toTriple, $elm$core$Maybe$andThen_fn(function ($) {
                    return $.aC;
                }, model.N), $elm$core$Maybe$andThen_fn(function ($) {
                    return $.ay;
                }, model.N), $elm$core$Maybe$map_fn(function ($) {
                    return $.nM;
                }, model.N)));
                if ((((_v42.a.$ === 6) && (_v42.b.$ === 6)) && (!_v42.c.$)) && (_v42.c.a.a.$ === 6)) {
                    var pageModel = _v42.a.a;
                    var thisPageData = _v42.b.a;
                    var _v43 = _v42.c.a;
                    var _v44 = _v43.a;
                    var pageUrl = _v43.b;
                    var justPage = _v43.c;
                    var _v45 = $author$project$Main$fooFn_fn($author$project$Main$ModelIndex, $author$project$Main$MsgIndex, model, A4($author$project$Route$Index$route.cF, {
                        r: $elm$core$Maybe$Nothing,
                        iW: thisPageData,
                        F: $elm$core$Dict$map_fn(function (mapUnpack) {
                            return $dillonkearns$elm_pages_v3_beta$Pages$Transition$map(function (mapUnpack0) {
                                if (mapUnpack0.$ === 6) {
                                    var justActionData = mapUnpack0.a;
                                    return $elm$core$Maybe$Just(justActionData);
                                }
                                else {
                                    return $elm$core$Maybe$Nothing;
                                }
                            });
                        }, fetchers),
                        I: pageFormState,
                        nM: justPage.nM,
                        L: {},
                        A: sharedData,
                        on: function (options) {
                            return $dillonkearns$elm_pages_v3_beta$Pages$Fetcher$submit_fn($author$project$Route$Index$w3_decode_ActionData, options);
                        },
                        M: transition,
                        lO: $elm$core$Maybe$Just(pageUrl)
                    }, msg_, pageModel, model.f));
                    var updatedPageModel = _v45.a;
                    var pageCmd = _v45.b;
                    var _v46 = _v45.c;
                    var newGlobalModel = _v46.a;
                    var newGlobalCmd = _v46.b;
                    return _Utils_Tuple2(_Utils_update(model, { f: newGlobalModel, n: updatedPageModel }), $author$project$Effect$batch(_List_fromArray([
                        pageCmd,
                        $author$project$Effect$map_fn($author$project$Main$MsgGlobal, newGlobalCmd)
                    ])));
                }
                else {
                    return _Utils_Tuple2(model, $author$project$Effect$none);
                }
        }
    }, $author$project$Main$update = F8($author$project$Main$update_fn);
    var $author$project$Route$segmentsToRoute = function (segments) {
        _v0$7: while (true) {
            if (segments.b) {
                if (segments.b.b) {
                    if (!segments.b.b.b) {
                        switch (segments.a) {
                            case "articles":
                                if (segments.b.a === "draft") {
                                    var _v1 = segments.b;
                                    return $elm$core$Maybe$Just($author$project$Route$Articles__Draft);
                                }
                                else {
                                    var _v2 = segments.b;
                                    var articleId = _v2.a;
                                    return $elm$core$Maybe$Just($author$project$Route$Articles__ArticleId_({ l$: articleId }));
                                }
                            case "twilogs":
                                var _v3 = segments.b;
                                var day = _v3.a;
                                return $elm$core$Maybe$Just($author$project$Route$Twilogs__Day_({ ml: day }));
                            default:
                                break _v0$7;
                        }
                    }
                    else {
                        break _v0$7;
                    }
                }
                else {
                    switch (segments.a) {
                        case "about":
                            return $elm$core$Maybe$Just($author$project$Route$About);
                        case "articles":
                            return $elm$core$Maybe$Just($author$project$Route$Articles);
                        case "twilogs":
                            return $elm$core$Maybe$Just($author$project$Route$Twilogs);
                        default:
                            break _v0$7;
                    }
                }
            }
            else {
                return $elm$core$Maybe$Just($author$project$Route$Index);
            }
        }
        return $elm$core$Maybe$Nothing;
    };
    var $author$project$Route$splitPath = function (path) {
        return $elm$core$List$filter_fn(function (item) {
            return item !== "";
        }, $elm$core$String$split_fn("/", path));
    };
    var $author$project$Route$urlToRoute = function (url) {
        return $author$project$Route$segmentsToRoute($author$project$Route$splitPath(url.nM));
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Msg$UserMsg = function (a) {
        return { $: 0, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$PagesMsg$fromMsg = function (userMsg) {
        return $dillonkearns$elm_pages_v3_beta$Pages$Internal$Msg$UserMsg(userMsg);
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Msg$FormFieldEvent = function (a) {
        return { $: 4, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Msg$NoOp = { $: 5 };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Msg$Submit = function (a) {
        return { $: 1, a: a };
    };
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Msg$SubmitFetcher_fn = function (a, b, c, d) {
        return { $: 3, a: a, b: b, c: c, d: d };
    }, $dillonkearns$elm_pages_v3_beta$Pages$Internal$Msg$SubmitFetcher = F4($dillonkearns$elm_pages_v3_beta$Pages$Internal$Msg$SubmitFetcher_fn);
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Msg$SubmitIfValid_fn = function (a, b, c, d) {
        return { $: 2, a: a, b: b, c: c, d: d };
    }, $dillonkearns$elm_pages_v3_beta$Pages$Internal$Msg$SubmitIfValid = F4($dillonkearns$elm_pages_v3_beta$Pages$Internal$Msg$SubmitIfValid_fn);
    var $dillonkearns$elm_pages_v3_beta$Pages$Internal$Msg$map_fn = function (mapFn, msg) {
        switch (msg.$) {
            case 0:
                var userMsg = msg.a;
                return $dillonkearns$elm_pages_v3_beta$Pages$Internal$Msg$UserMsg(mapFn(userMsg));
            case 1:
                var info = msg.a;
                return $dillonkearns$elm_pages_v3_beta$Pages$Internal$Msg$Submit(info);
            case 2:
                var formId = msg.a;
                var info = msg.b;
                var isValid = msg.c;
                var toUserMsg = msg.d;
                return $dillonkearns$elm_pages_v3_beta$Pages$Internal$Msg$SubmitIfValid_fn(formId, info, isValid, $elm$core$Maybe$map_fn(mapFn, toUserMsg));
            case 3:
                var formId = msg.a;
                var info = msg.b;
                var isValid = msg.c;
                var toUserMsg = msg.d;
                return $dillonkearns$elm_pages_v3_beta$Pages$Internal$Msg$SubmitFetcher_fn(formId, info, isValid, $elm$core$Maybe$map_fn(mapFn, toUserMsg));
            case 4:
                var value = msg.a;
                return $dillonkearns$elm_pages_v3_beta$Pages$Internal$Msg$FormFieldEvent(value);
            default:
                return $dillonkearns$elm_pages_v3_beta$Pages$Internal$Msg$NoOp;
        }
    }, $dillonkearns$elm_pages_v3_beta$Pages$Internal$Msg$map = F2($dillonkearns$elm_pages_v3_beta$Pages$Internal$Msg$map_fn);
    var $dillonkearns$elm_pages_v3_beta$PagesMsg$map_fn = function (mapFn, msg) {
        return $dillonkearns$elm_pages_v3_beta$Pages$Internal$Msg$map_fn(mapFn, msg);
    }, $dillonkearns$elm_pages_v3_beta$PagesMsg$map = F2($dillonkearns$elm_pages_v3_beta$PagesMsg$map_fn);
    var $elm$virtual_dom$VirtualDom$map = _VirtualDom_map;
    var $elm$html$Html$map = $elm$virtual_dom$VirtualDom$map;
    var $author$project$View$map_fn = function (fn, doc) {
        return {
            hJ: $elm$core$List$map_fn($elm$html$Html$map(fn), doc.hJ),
            jE: doc.jE
        };
    }, $author$project$View$map = F2($author$project$View$map_fn);
    var $author$project$Main$modelMismatchView = {
        hJ: _List_fromArray([
            $elm$html$Html$text("Model mismatch")
        ]),
        jE: "Model mismatch"
    };
    var $author$project$ErrorPage$Increment = 0;
    var $elm$html$Html$button = _VirtualDom_nodeNS_fn(_VirtualDom_node_a0, "button"), $elm$html$Html$button_fn = $elm$html$Html$button.a2;
    var $elm$virtual_dom$VirtualDom$on = _VirtualDom_on;
    var $elm$html$Html$Events$on_fn = function (event, decoder) {
        return _VirtualDom_on_fn(event, $elm$virtual_dom$VirtualDom$Normal(decoder));
    }, $elm$html$Html$Events$on = F2($elm$html$Html$Events$on_fn);
    var $elm$html$Html$Events$onClick = function (msg) {
        return $elm$html$Html$Events$on_fn("click", $elm$json$Json$Decode$succeed(msg));
    };
    var $author$project$ErrorPage$view_fn = function (error, model) {
        return {
            hJ: _List_fromArray([
                $elm$html$Html$div_fn(_List_Nil, _List_fromArray([
                    $elm$html$Html$p_fn(_List_Nil, _List_fromArray([
                        $elm$html$Html$text("Page not found. Maybe try another URL?")
                    ])),
                    $elm$html$Html$div_fn(_List_Nil, _List_fromArray([
                        $elm$html$Html$button_fn(_List_fromArray([
                            $elm$html$Html$Events$onClick(0)
                        ]), _List_fromArray([
                            $elm$html$Html$text($elm$core$String$fromInt(model.dt))
                        ]))
                    ]))
                ]))
            ]),
            jE: "This is a NotFound Error"
        };
    }, $author$project$ErrorPage$view = F2($author$project$ErrorPage$view_fn);
    var $author$project$Main$view_fn = function (pageFormState, fetchers, transition, page, maybePageUrl, globalData, pageData, actionData) {
        var _v0 = _Utils_Tuple2(page.n4, pageData);
        _v0$8: while (true) {
            switch (_v0.b.$) {
                case 8:
                    var data = _v0.b.a;
                    return {
                        aL: _List_Nil,
                        X: function (model) {
                            var _v1 = model.n;
                            if (_v1.$ === 7) {
                                var subModel = _v1.a;
                                return A5($author$project$Shared$template.X, globalData, page, model.f, function (myMsg) {
                                    return $dillonkearns$elm_pages_v3_beta$PagesMsg$fromMsg($author$project$Main$MsgGlobal(myMsg));
                                }, $author$project$View$map_fn(function (myMsg) {
                                    return $dillonkearns$elm_pages_v3_beta$PagesMsg$fromMsg($author$project$Main$MsgErrorPage____(myMsg));
                                }, $author$project$ErrorPage$view_fn(data, subModel)));
                            }
                            else {
                                return $author$project$Main$modelMismatchView;
                            }
                        }
                    };
                case 0:
                    if ((!_v0.a.$) && (!_v0.a.a.$)) {
                        var _v2 = _v0.a.a;
                        var data = _v0.b.a;
                        var actionDataOrNothing = function (thisActionData) {
                            if (!thisActionData.$) {
                                var justActionData = thisActionData.a;
                                return $elm$core$Maybe$Just(justActionData);
                            }
                            else {
                                return $elm$core$Maybe$Nothing;
                            }
                        };
                        return {
                            aL: $author$project$Route$Articles$Draft$route.aL({
                                r: $elm$core$Maybe$Nothing,
                                iW: data,
                                F: $elm$core$Dict$empty,
                                I: $elm$core$Dict$empty,
                                nM: page.nM,
                                L: {},
                                A: globalData,
                                on: $dillonkearns$elm_pages_v3_beta$Pages$Fetcher$submit($author$project$Route$Articles$Draft$w3_decode_ActionData),
                                M: $elm$core$Maybe$Nothing,
                                lO: $elm$core$Maybe$Nothing
                            }),
                            X: function (model) {
                                var _v3 = model.n;
                                if (!_v3.$) {
                                    var subModel = _v3.a;
                                    return A5($author$project$Shared$template.X, globalData, page, model.f, function (myMsg) {
                                        return $dillonkearns$elm_pages_v3_beta$PagesMsg$fromMsg($author$project$Main$MsgGlobal(myMsg));
                                    }, $author$project$View$map_fn($dillonkearns$elm_pages_v3_beta$PagesMsg$map($author$project$Main$MsgArticles__Draft), A3($author$project$Route$Articles$Draft$route.X, model.f, subModel, {
                                        r: $elm$core$Maybe$andThen_fn(actionDataOrNothing, actionData),
                                        iW: data,
                                        F: $elm$core$Dict$map_fn(function (mapUnpack) {
                                            return $dillonkearns$elm_pages_v3_beta$Pages$Transition$map(actionDataOrNothing);
                                        }, fetchers),
                                        I: pageFormState,
                                        nM: page.nM,
                                        L: {},
                                        A: globalData,
                                        on: $dillonkearns$elm_pages_v3_beta$Pages$Fetcher$submit($author$project$Route$Articles$Draft$w3_decode_ActionData),
                                        M: transition,
                                        lO: maybePageUrl
                                    })));
                                }
                                else {
                                    return $author$project$Main$modelMismatchView;
                                }
                            }
                        };
                    }
                    else {
                        break _v0$8;
                    }
                case 1:
                    if ((!_v0.a.$) && (_v0.a.a.$ === 1)) {
                        var routeParams = _v0.a.a.a;
                        var data = _v0.b.a;
                        var actionDataOrNothing = function (thisActionData) {
                            if (thisActionData.$ === 1) {
                                var justActionData = thisActionData.a;
                                return $elm$core$Maybe$Just(justActionData);
                            }
                            else {
                                return $elm$core$Maybe$Nothing;
                            }
                        };
                        return {
                            aL: $author$project$Route$Articles$ArticleId_$route.aL({
                                r: $elm$core$Maybe$Nothing,
                                iW: data,
                                F: $elm$core$Dict$empty,
                                I: $elm$core$Dict$empty,
                                nM: page.nM,
                                L: routeParams,
                                A: globalData,
                                on: $dillonkearns$elm_pages_v3_beta$Pages$Fetcher$submit($author$project$Route$Articles$ArticleId_$w3_decode_ActionData),
                                M: $elm$core$Maybe$Nothing,
                                lO: $elm$core$Maybe$Nothing
                            }),
                            X: function (model) {
                                var _v5 = model.n;
                                if (_v5.$ === 1) {
                                    var subModel = _v5.a;
                                    return A5($author$project$Shared$template.X, globalData, page, model.f, function (myMsg) {
                                        return $dillonkearns$elm_pages_v3_beta$PagesMsg$fromMsg($author$project$Main$MsgGlobal(myMsg));
                                    }, $author$project$View$map_fn($dillonkearns$elm_pages_v3_beta$PagesMsg$map($author$project$Main$MsgArticles__ArticleId_), A3($author$project$Route$Articles$ArticleId_$route.X, model.f, subModel, {
                                        r: $elm$core$Maybe$andThen_fn(actionDataOrNothing, actionData),
                                        iW: data,
                                        F: $elm$core$Dict$map_fn(function (mapUnpack) {
                                            return $dillonkearns$elm_pages_v3_beta$Pages$Transition$map(actionDataOrNothing);
                                        }, fetchers),
                                        I: pageFormState,
                                        nM: page.nM,
                                        L: routeParams,
                                        A: globalData,
                                        on: $dillonkearns$elm_pages_v3_beta$Pages$Fetcher$submit($author$project$Route$Articles$ArticleId_$w3_decode_ActionData),
                                        M: transition,
                                        lO: maybePageUrl
                                    })));
                                }
                                else {
                                    return $author$project$Main$modelMismatchView;
                                }
                            }
                        };
                    }
                    else {
                        break _v0$8;
                    }
                case 2:
                    if ((!_v0.a.$) && (_v0.a.a.$ === 2)) {
                        var routeParams = _v0.a.a.a;
                        var data = _v0.b.a;
                        var actionDataOrNothing = function (thisActionData) {
                            if (thisActionData.$ === 2) {
                                var justActionData = thisActionData.a;
                                return $elm$core$Maybe$Just(justActionData);
                            }
                            else {
                                return $elm$core$Maybe$Nothing;
                            }
                        };
                        return {
                            aL: $author$project$Route$Twilogs$Day_$route.aL({
                                r: $elm$core$Maybe$Nothing,
                                iW: data,
                                F: $elm$core$Dict$empty,
                                I: $elm$core$Dict$empty,
                                nM: page.nM,
                                L: routeParams,
                                A: globalData,
                                on: $dillonkearns$elm_pages_v3_beta$Pages$Fetcher$submit($author$project$Route$Twilogs$Day_$w3_decode_ActionData),
                                M: $elm$core$Maybe$Nothing,
                                lO: $elm$core$Maybe$Nothing
                            }),
                            X: function (model) {
                                var _v7 = model.n;
                                if (_v7.$ === 2) {
                                    var subModel = _v7.a;
                                    return A5($author$project$Shared$template.X, globalData, page, model.f, function (myMsg) {
                                        return $dillonkearns$elm_pages_v3_beta$PagesMsg$fromMsg($author$project$Main$MsgGlobal(myMsg));
                                    }, $author$project$View$map_fn($dillonkearns$elm_pages_v3_beta$PagesMsg$map($author$project$Main$MsgTwilogs__Day_), A3($author$project$Route$Twilogs$Day_$route.X, model.f, subModel, {
                                        r: $elm$core$Maybe$andThen_fn(actionDataOrNothing, actionData),
                                        iW: data,
                                        F: $elm$core$Dict$map_fn(function (mapUnpack) {
                                            return $dillonkearns$elm_pages_v3_beta$Pages$Transition$map(actionDataOrNothing);
                                        }, fetchers),
                                        I: pageFormState,
                                        nM: page.nM,
                                        L: routeParams,
                                        A: globalData,
                                        on: $dillonkearns$elm_pages_v3_beta$Pages$Fetcher$submit($author$project$Route$Twilogs$Day_$w3_decode_ActionData),
                                        M: transition,
                                        lO: maybePageUrl
                                    })));
                                }
                                else {
                                    return $author$project$Main$modelMismatchView;
                                }
                            }
                        };
                    }
                    else {
                        break _v0$8;
                    }
                case 3:
                    if ((!_v0.a.$) && (_v0.a.a.$ === 3)) {
                        var _v9 = _v0.a.a;
                        var data = _v0.b.a;
                        var actionDataOrNothing = function (thisActionData) {
                            if (thisActionData.$ === 3) {
                                var justActionData = thisActionData.a;
                                return $elm$core$Maybe$Just(justActionData);
                            }
                            else {
                                return $elm$core$Maybe$Nothing;
                            }
                        };
                        return {
                            aL: $author$project$Route$About$route.aL({
                                r: $elm$core$Maybe$Nothing,
                                iW: data,
                                F: $elm$core$Dict$empty,
                                I: $elm$core$Dict$empty,
                                nM: page.nM,
                                L: {},
                                A: globalData,
                                on: $dillonkearns$elm_pages_v3_beta$Pages$Fetcher$submit($author$project$Route$About$w3_decode_ActionData),
                                M: $elm$core$Maybe$Nothing,
                                lO: $elm$core$Maybe$Nothing
                            }),
                            X: function (model) {
                                var _v10 = model.n;
                                if (_v10.$ === 3) {
                                    var subModel = _v10.a;
                                    return A5($author$project$Shared$template.X, globalData, page, model.f, function (myMsg) {
                                        return $dillonkearns$elm_pages_v3_beta$PagesMsg$fromMsg($author$project$Main$MsgGlobal(myMsg));
                                    }, $author$project$View$map_fn($dillonkearns$elm_pages_v3_beta$PagesMsg$map($author$project$Main$MsgAbout), A3($author$project$Route$About$route.X, model.f, subModel, {
                                        r: $elm$core$Maybe$andThen_fn(actionDataOrNothing, actionData),
                                        iW: data,
                                        F: $elm$core$Dict$map_fn(function (mapUnpack) {
                                            return $dillonkearns$elm_pages_v3_beta$Pages$Transition$map(actionDataOrNothing);
                                        }, fetchers),
                                        I: pageFormState,
                                        nM: page.nM,
                                        L: {},
                                        A: globalData,
                                        on: $dillonkearns$elm_pages_v3_beta$Pages$Fetcher$submit($author$project$Route$About$w3_decode_ActionData),
                                        M: transition,
                                        lO: maybePageUrl
                                    })));
                                }
                                else {
                                    return $author$project$Main$modelMismatchView;
                                }
                            }
                        };
                    }
                    else {
                        break _v0$8;
                    }
                case 4:
                    if ((!_v0.a.$) && (_v0.a.a.$ === 4)) {
                        var _v12 = _v0.a.a;
                        var data = _v0.b.a;
                        var actionDataOrNothing = function (thisActionData) {
                            if (thisActionData.$ === 4) {
                                var justActionData = thisActionData.a;
                                return $elm$core$Maybe$Just(justActionData);
                            }
                            else {
                                return $elm$core$Maybe$Nothing;
                            }
                        };
                        return {
                            aL: $author$project$Route$Articles$route.aL({
                                r: $elm$core$Maybe$Nothing,
                                iW: data,
                                F: $elm$core$Dict$empty,
                                I: $elm$core$Dict$empty,
                                nM: page.nM,
                                L: {},
                                A: globalData,
                                on: $dillonkearns$elm_pages_v3_beta$Pages$Fetcher$submit($author$project$Route$Articles$w3_decode_ActionData),
                                M: $elm$core$Maybe$Nothing,
                                lO: $elm$core$Maybe$Nothing
                            }),
                            X: function (model) {
                                var _v13 = model.n;
                                if (_v13.$ === 4) {
                                    var subModel = _v13.a;
                                    return A5($author$project$Shared$template.X, globalData, page, model.f, function (myMsg) {
                                        return $dillonkearns$elm_pages_v3_beta$PagesMsg$fromMsg($author$project$Main$MsgGlobal(myMsg));
                                    }, $author$project$View$map_fn($dillonkearns$elm_pages_v3_beta$PagesMsg$map($author$project$Main$MsgArticles), A3($author$project$Route$Articles$route.X, model.f, subModel, {
                                        r: $elm$core$Maybe$andThen_fn(actionDataOrNothing, actionData),
                                        iW: data,
                                        F: $elm$core$Dict$map_fn(function (mapUnpack) {
                                            return $dillonkearns$elm_pages_v3_beta$Pages$Transition$map(actionDataOrNothing);
                                        }, fetchers),
                                        I: pageFormState,
                                        nM: page.nM,
                                        L: {},
                                        A: globalData,
                                        on: $dillonkearns$elm_pages_v3_beta$Pages$Fetcher$submit($author$project$Route$Articles$w3_decode_ActionData),
                                        M: transition,
                                        lO: maybePageUrl
                                    })));
                                }
                                else {
                                    return $author$project$Main$modelMismatchView;
                                }
                            }
                        };
                    }
                    else {
                        break _v0$8;
                    }
                case 5:
                    if ((!_v0.a.$) && (_v0.a.a.$ === 5)) {
                        var _v15 = _v0.a.a;
                        var data = _v0.b.a;
                        var actionDataOrNothing = function (thisActionData) {
                            if (thisActionData.$ === 5) {
                                var justActionData = thisActionData.a;
                                return $elm$core$Maybe$Just(justActionData);
                            }
                            else {
                                return $elm$core$Maybe$Nothing;
                            }
                        };
                        return {
                            aL: $author$project$Route$Twilogs$route.aL({
                                r: $elm$core$Maybe$Nothing,
                                iW: data,
                                F: $elm$core$Dict$empty,
                                I: $elm$core$Dict$empty,
                                nM: page.nM,
                                L: {},
                                A: globalData,
                                on: $dillonkearns$elm_pages_v3_beta$Pages$Fetcher$submit($author$project$Route$Twilogs$w3_decode_ActionData),
                                M: $elm$core$Maybe$Nothing,
                                lO: $elm$core$Maybe$Nothing
                            }),
                            X: function (model) {
                                var _v16 = model.n;
                                if (_v16.$ === 5) {
                                    var subModel = _v16.a;
                                    return A5($author$project$Shared$template.X, globalData, page, model.f, function (myMsg) {
                                        return $dillonkearns$elm_pages_v3_beta$PagesMsg$fromMsg($author$project$Main$MsgGlobal(myMsg));
                                    }, $author$project$View$map_fn($dillonkearns$elm_pages_v3_beta$PagesMsg$map($author$project$Main$MsgTwilogs), A3($author$project$Route$Twilogs$route.X, model.f, subModel, {
                                        r: $elm$core$Maybe$andThen_fn(actionDataOrNothing, actionData),
                                        iW: data,
                                        F: $elm$core$Dict$map_fn(function (mapUnpack) {
                                            return $dillonkearns$elm_pages_v3_beta$Pages$Transition$map(actionDataOrNothing);
                                        }, fetchers),
                                        I: pageFormState,
                                        nM: page.nM,
                                        L: {},
                                        A: globalData,
                                        on: $dillonkearns$elm_pages_v3_beta$Pages$Fetcher$submit($author$project$Route$Twilogs$w3_decode_ActionData),
                                        M: transition,
                                        lO: maybePageUrl
                                    })));
                                }
                                else {
                                    return $author$project$Main$modelMismatchView;
                                }
                            }
                        };
                    }
                    else {
                        break _v0$8;
                    }
                case 6:
                    if ((!_v0.a.$) && (_v0.a.a.$ === 6)) {
                        var _v18 = _v0.a.a;
                        var data = _v0.b.a;
                        var actionDataOrNothing = function (thisActionData) {
                            if (thisActionData.$ === 6) {
                                var justActionData = thisActionData.a;
                                return $elm$core$Maybe$Just(justActionData);
                            }
                            else {
                                return $elm$core$Maybe$Nothing;
                            }
                        };
                        return {
                            aL: $author$project$Route$Index$route.aL({
                                r: $elm$core$Maybe$Nothing,
                                iW: data,
                                F: $elm$core$Dict$empty,
                                I: $elm$core$Dict$empty,
                                nM: page.nM,
                                L: {},
                                A: globalData,
                                on: $dillonkearns$elm_pages_v3_beta$Pages$Fetcher$submit($author$project$Route$Index$w3_decode_ActionData),
                                M: $elm$core$Maybe$Nothing,
                                lO: $elm$core$Maybe$Nothing
                            }),
                            X: function (model) {
                                var _v19 = model.n;
                                if (_v19.$ === 6) {
                                    var subModel = _v19.a;
                                    return A5($author$project$Shared$template.X, globalData, page, model.f, function (myMsg) {
                                        return $dillonkearns$elm_pages_v3_beta$PagesMsg$fromMsg($author$project$Main$MsgGlobal(myMsg));
                                    }, $author$project$View$map_fn($dillonkearns$elm_pages_v3_beta$PagesMsg$map($author$project$Main$MsgIndex), A3($author$project$Route$Index$route.X, model.f, subModel, {
                                        r: $elm$core$Maybe$andThen_fn(actionDataOrNothing, actionData),
                                        iW: data,
                                        F: $elm$core$Dict$map_fn(function (mapUnpack) {
                                            return $dillonkearns$elm_pages_v3_beta$Pages$Transition$map(actionDataOrNothing);
                                        }, fetchers),
                                        I: pageFormState,
                                        nM: page.nM,
                                        L: {},
                                        A: globalData,
                                        on: $dillonkearns$elm_pages_v3_beta$Pages$Fetcher$submit($author$project$Route$Index$w3_decode_ActionData),
                                        M: transition,
                                        lO: maybePageUrl
                                    })));
                                }
                                else {
                                    return $author$project$Main$modelMismatchView;
                                }
                            }
                        };
                    }
                    else {
                        break _v0$8;
                    }
                default:
                    break _v0$8;
            }
        }
        var otherwise_1_0_0 = _v0;
        return {
            aL: _List_Nil,
            X: function (_v21) {
                return {
                    hJ: _List_fromArray([
                        $elm$html$Html$div_fn(_List_Nil, _List_fromArray([
                            $elm$html$Html$text("This page could not be found.")
                        ]))
                    ]),
                    jE: "Page not found"
                };
            }
        };
    }, $author$project$Main$view = F8($author$project$Main$view_fn);
    var $author$project$Main$main = $dillonkearns$elm_pages_v3_beta$Pages$Internal$Platform$Cli$cliApplication({
        r: $author$project$Main$action,
        lY: function (htmlToString) {
            return _List_Cons($author$project$Main$pathsToGenerateHandler, _List_Cons($author$project$Main$routePatterns, _List_Cons($author$project$Main$apiPatterns, $author$project$Api$routes_fn($author$project$Main$getStaticRoutes, htmlToString))));
        },
        l3: $author$project$Route$baseUrlAsPath,
        l7: $author$project$Main$byteDecodePageData,
        l8: $author$project$Main$byteEncodePageData,
        me: $author$project$Effect$fromCmd,
        iW: $author$project$Main$dataForRoute,
        mn: $author$project$Main$decodeResponse,
        mv: $author$project$Main$encodeActionData,
        mw: $author$project$Main$encodeResponse,
        my: $author$project$Main$DataErrorPage____,
        mz: $author$project$ErrorPage$statusCode,
        mL: $author$project$Main$fromJsPort($elm$core$Basics$identity),
        mO: $dillonkearns$elm_pages_v3_beta$BackendTask$map_fn($elm$core$List$map($elm$core$Maybe$Just), $author$project$Main$getStaticRoutes),
        mP: $elm$core$Maybe$Just($author$project$Main$globalHeadTags),
        mQ: $author$project$Main$gotBatchSub($elm$core$Basics$identity),
        et: $author$project$Main$handleRoute,
        mV: $author$project$Main$hotReloadData($elm$core$Basics$identity),
        dI: $author$project$Main$init($elm$core$Maybe$Nothing),
        m1: $author$project$ErrorPage$internalError,
        nz: $author$project$ErrorPage$notFound,
        nA: $elm$core$Maybe$Nothing,
        nE: $author$project$Main$onActionData,
        lr: $author$project$Main$OnPageChange,
        nN: $author$project$Main$routePatterns3,
        nP: $author$project$Effect$perform,
        n5: function (route) {
            return $elm$core$Maybe$withDefault_fn(_List_Nil, $elm$core$Maybe$map_fn($author$project$Route$routeToPath, route));
        },
        oc: $author$project$Main$sendPageData,
        A: $author$project$Shared$template.iW,
        of: $elm$core$Maybe$Just($author$project$Site$config),
        dW: $author$project$Main$subscriptions,
        ot: $author$project$Main$toJsPort,
        cF: $author$project$Main$update,
        oA: $author$project$Route$urlToRoute,
        X: $author$project$Main$view
    });
    _Platform_export({ "Main": { "init": $author$project$Main$main($elm$json$Json$Decode$value)(0) } });
    var isBackend = false && typeof isLamdera !== "undefined";
    function _Platform_initialize(flagDecoder, args, init, update, subscriptions, stepperBuilder) {
        var result = _Json_run_fn(flagDecoder, _Json_wrap(args ? args["flags"] : undefined));
        $elm$core$Result$isOk(result) || _Debug_crash(2);
        var managers = {};
        var initPair = init(result.a);
        var model = (args && args["model"]) || initPair.a;
        var stepper = stepperBuilder(sendToApp, model);
        var ports = _Platform_setupEffects(managers, sendToApp);
        var pos = 0;
        var dead = false;
        var upgradeMode = false;
        function mtime() {
            if (!isBackend) {
                return 0;
            }
            const hrTime = process.hrtime();
            return Math.floor(hrTime[0] * 1000000 + hrTime[1] / 1000);
        }
        function sendToApp(msg, viewMetadata) {
            if (dead) {
                return;
            }
            if (upgradeMode) {
                _Platform_enqueueEffects(managers, $elm$core$Platform$Cmd$none, $elm$core$Platform$Sub$none);
                return;
            }
            var serializeDuration, logDuration = null;
            var start = mtime();
            try {
                var pair = A2(update, msg, model);
            }
            catch (err) {
                if (isBackend) {
                    bugsnag.notify(err);
                }
                return;
            }
            const updateDuration = mtime() - start;
            start = mtime();
            if (isBackend && loggingEnabled) {
                pos = pos + 1;
                const s = $author$project$LBR$serialize(msg);
                serializeDuration = mtime() - start;
                start = mtime();
                insertEvent(pos, global.config.version, s.a, updateDuration, serializeDuration, $elm$core$Maybe$withDefault_fn(null, s.b));
                logDuration = mtime() - start;
            }
            stepper(model = pair.a, viewMetadata);
            _Platform_enqueueEffects(managers, pair.b, subscriptions(model));
            const stepEnqueueDuration = mtime() - start;
            if (isBackend) {
            }
        }
        if ((args && args["model"]) === undefined) {
            _Platform_enqueueEffects(managers, initPair.b, subscriptions(model));
        }
        var fns = {};
        const die = function () {
            managers = null;
            model = null;
            stepper = null;
            ports = null;
        };
        return ports ? { ports: ports, gm: function () { return model; }, eum: function () { upgradeMode = true; }, die: die, fns: fns } : {};
    }
}(this));
