var Oc = Object.defineProperty;
var $c = (e, r, t) =>
  r in e
    ? Oc(e, r, { enumerable: !0, configurable: !0, writable: !0, value: t })
    : (e[r] = t);
var Qi = (e, r, t) => $c(e, typeof r != "symbol" ? r + "" : r, t);
let ce;
function gr(e) {
  const r = ce.__externref_table_alloc();
  return (ce.__wbindgen_export_2.set(r, e), r);
}
function Yt(e, r) {
  try {
    return e.apply(this, r);
  } catch (t) {
    const n = gr(t);
    ce.__wbindgen_exn_store(n);
  }
}
const Ko =
  typeof TextDecoder < "u"
    ? new TextDecoder("utf-8", { ignoreBOM: !0, fatal: !0 })
    : {
        decode: () => {
          throw Error("TextDecoder not available");
        },
      };
typeof TextDecoder < "u" && Ko.decode();
let yr = null;
function rr() {
  return (
    (yr === null || yr.byteLength === 0) &&
      (yr = new Uint8Array(ce.memory.buffer)),
    yr
  );
}
function Gt(e, r) {
  return ((e = e >>> 0), Ko.decode(rr().subarray(e, e + r)));
}
let Lt = 0;
const ln =
    typeof TextEncoder < "u"
      ? new TextEncoder("utf-8")
      : {
          encode: () => {
            throw Error("TextEncoder not available");
          },
        },
  Lc =
    typeof ln.encodeInto == "function"
      ? function (e, r) {
          return ln.encodeInto(e, r);
        }
      : function (e, r) {
          const t = ln.encode(e);
          return (r.set(t), { read: e.length, written: t.length });
        };
function Mn(e, r, t) {
  if (t === void 0) {
    const h = ln.encode(e),
      g = r(h.length, 1) >>> 0;
    return (
      rr()
        .subarray(g, g + h.length)
        .set(h),
      (Lt = h.length),
      g
    );
  }
  let n = e.length,
    i = r(n, 1) >>> 0;
  const s = rr();
  let l = 0;
  for (; l < n; l++) {
    const h = e.charCodeAt(l);
    if (h > 127) break;
    s[i + l] = h;
  }
  if (l !== n) {
    (l !== 0 && (e = e.slice(l)),
      (i = t(i, n, (n = l + e.length * 3), 1) >>> 0));
    const h = rr().subarray(i + l, i + n),
      g = Lc(e, h);
    ((l += g.written), (i = t(i, n, l, 1) >>> 0));
  }
  return ((Lt = l), i);
}
let Rt = null;
function yt() {
  return (
    (Rt === null ||
      Rt.buffer.detached === !0 ||
      (Rt.buffer.detached === void 0 && Rt.buffer !== ce.memory.buffer)) &&
      (Rt = new DataView(ce.memory.buffer)),
    Rt
  );
}
function Tt(e) {
  return e == null;
}
const ea =
  typeof FinalizationRegistry > "u"
    ? { register: () => {}, unregister: () => {} }
    : new FinalizationRegistry((e) => {
        ce.__wbindgen_export_6.get(e.dtor)(e.a, e.b);
      });
function zc(e, r, t, n) {
  const i = { a: e, b: r, cnt: 1, dtor: t },
    s = (...l) => {
      i.cnt++;
      const h = i.a;
      i.a = 0;
      try {
        return n(h, i.b, ...l);
      } finally {
        --i.cnt === 0
          ? (ce.__wbindgen_export_6.get(i.dtor)(h, i.b), ea.unregister(i))
          : (i.a = h);
      }
    };
  return ((s.original = i), ea.register(s, i, i), s);
}
function wi(e) {
  const r = typeof e;
  if (r == "number" || r == "boolean" || e == null) return `${e}`;
  if (r == "string") return `"${e}"`;
  if (r == "symbol") {
    const i = e.description;
    return i == null ? "Symbol" : `Symbol(${i})`;
  }
  if (r == "function") {
    const i = e.name;
    return typeof i == "string" && i.length > 0 ? `Function(${i})` : "Function";
  }
  if (Array.isArray(e)) {
    const i = e.length;
    let s = "[";
    i > 0 && (s += wi(e[0]));
    for (let l = 1; l < i; l++) s += ", " + wi(e[l]);
    return ((s += "]"), s);
  }
  const t = /\[object ([^\]]+)\]/.exec(toString.call(e));
  let n;
  if (t && t.length > 1) n = t[1];
  else return toString.call(e);
  if (n == "Object")
    try {
      return "Object(" + JSON.stringify(e) + ")";
    } catch {
      return "Object";
    }
  return e instanceof Error
    ? `${e.name}: ${e.message}
${e.stack}`
    : n;
}
function Fc(e) {
  const r = ce.__wbindgen_export_2.get(e);
  return (ce.__externref_table_dealloc(e), r);
}
function Mc(e, r) {
  return ((e = e >>> 0), rr().subarray(e / 1, e / 1 + r));
}
function Pc(e, r) {
  const t = r(e.length * 1, 1) >>> 0;
  return (rr().set(e, t / 1), (Lt = e.length), t);
}
function Zc(e) {
  const r = ce.compressWitnessStack(e);
  if (r[3]) throw Fc(r[2]);
  var t = Mc(r[0], r[1]).slice();
  return (ce.__wbindgen_free(r[0], r[1] * 1, 1), t);
}
function Hc(e, r, t) {
  const n = Pc(e, ce.__wbindgen_malloc),
    i = Lt;
  return ce.executeProgram(n, i, r, t);
}
function Wc(e, r, t) {
  ce.closure646_externref_shim(e, r, t);
}
function Vc(e, r, t, n, i) {
  ce.closure1311_externref_shim(e, r, t, n, i);
}
function ta(e, r, t, n) {
  ce.closure1315_externref_shim(e, r, t, n);
}
async function Yc(e, r) {
  if (typeof Response == "function" && e instanceof Response) {
    if (typeof WebAssembly.instantiateStreaming == "function")
      try {
        return await WebAssembly.instantiateStreaming(e, r);
      } catch (n) {
        if (e.headers.get("Content-Type") != "application/wasm")
          console.warn(
            "`WebAssembly.instantiateStreaming` failed because your server does not serve Wasm with `application/wasm` MIME type. Falling back to `WebAssembly.instantiate` which is slower. Original error:\n",
            n,
          );
        else throw n;
      }
    const t = await e.arrayBuffer();
    return await WebAssembly.instantiate(t, r);
  } else {
    const t = await WebAssembly.instantiate(e, r);
    return t instanceof WebAssembly.Instance ? { instance: t, module: e } : t;
  }
}
function Gc() {
  const e = {};
  return (
    (e.wbg = {}),
    (e.wbg.__wbg_call_672a4d21634d4a24 = function () {
      return Yt(function (r, t) {
        return r.call(t);
      }, arguments);
    }),
    (e.wbg.__wbg_call_7cccdd69e0791ae2 = function () {
      return Yt(function (r, t, n) {
        return r.call(t, n);
      }, arguments);
    }),
    (e.wbg.__wbg_call_833bed5770ea2041 = function () {
      return Yt(function (r, t, n, i) {
        return r.call(t, n, i);
      }, arguments);
    }),
    (e.wbg.__wbg_constructor_485c344f17716fe1 = function (r) {
      return new Error(r);
    }),
    (e.wbg.__wbg_constructor_4d3f186b35aa8368 = function (r) {
      return new Error(r);
    }),
    (e.wbg.__wbg_debug_3cb59063b29f58c1 = function (r) {
      console.debug(r);
    }),
    (e.wbg.__wbg_debug_e17b51583ca6a632 = function (r, t, n, i) {
      console.debug(r, t, n, i);
    }),
    (e.wbg.__wbg_error_524f506f44df1645 = function (r) {
      console.error(r);
    }),
    (e.wbg.__wbg_error_7534b8e9a36f1ab4 = function (r, t) {
      let n, i;
      try {
        ((n = r), (i = t), console.error(Gt(r, t)));
      } finally {
        ce.__wbindgen_free(n, i, 1);
      }
    }),
    (e.wbg.__wbg_error_80de38b3f7cc3c3c = function (r, t, n, i) {
      console.error(r, t, n, i);
    }),
    (e.wbg.__wbg_forEach_d6a05ca96422eff9 = function (r, t, n) {
      try {
        var i = { a: t, b: n },
          s = (l, h, g) => {
            const u = i.a;
            i.a = 0;
            try {
              return Vc(u, i.b, l, h, g);
            } finally {
              i.a = u;
            }
          };
        r.forEach(s);
      } finally {
        i.a = i.b = 0;
      }
    }),
    (e.wbg.__wbg_forEach_e1cf6f7c8ecb7dae = function (r, t, n) {
      try {
        var i = { a: t, b: n },
          s = (l, h) => {
            const g = i.a;
            i.a = 0;
            try {
              return ta(g, i.b, l, h);
            } finally {
              i.a = g;
            }
          };
        r.forEach(s);
      } finally {
        i.a = i.b = 0;
      }
    }),
    (e.wbg.__wbg_fromEntries_524679eecb0bdc2e = function () {
      return Yt(function (r) {
        return Object.fromEntries(r);
      }, arguments);
    }),
    (e.wbg.__wbg_from_2a5d3e218e67aa85 = function (r) {
      return Array.from(r);
    }),
    (e.wbg.__wbg_get_b9b93047fe3cf45b = function (r, t) {
      return r[t >>> 0];
    }),
    (e.wbg.__wbg_info_033d8b8a0838f1d3 = function (r, t, n, i) {
      console.info(r, t, n, i);
    }),
    (e.wbg.__wbg_info_3daf2e093e091b66 = function (r) {
      console.info(r);
    }),
    (e.wbg.__wbg_length_e2d2a49132c1b256 = function (r) {
      return r.length;
    }),
    (e.wbg.__wbg_new_23a2665fac83c611 = function (r, t) {
      try {
        var n = { a: r, b: t },
          i = (l, h) => {
            const g = n.a;
            n.a = 0;
            try {
              return ta(g, n.b, l, h);
            } finally {
              n.a = g;
            }
          };
        return new Promise(i);
      } finally {
        n.a = n.b = 0;
      }
    }),
    (e.wbg.__wbg_new_5e0be73521bc8c17 = function () {
      return new Map();
    }),
    (e.wbg.__wbg_new_5f3ae2f96f8de996 = function () {
      return new Array();
    }),
    (e.wbg.__wbg_new_78feb108b6472713 = function () {
      return new Array();
    }),
    (e.wbg.__wbg_new_8a6f238a6ece86ea = function () {
      return new Error();
    }),
    (e.wbg.__wbg_new_c68d7209be747379 = function (r, t) {
      return new Error(Gt(r, t));
    }),
    (e.wbg.__wbg_new_e48d31efda68db91 = function () {
      return new Map();
    }),
    (e.wbg.__wbg_newnoargs_105ed471475aaf50 = function (r, t) {
      return new Function(Gt(r, t));
    }),
    (e.wbg.__wbg_parse_def2e24ef1252aff = function () {
      return Yt(function (r, t) {
        return JSON.parse(Gt(r, t));
      }, arguments);
    }),
    (e.wbg.__wbg_push_737cfc8c1432c2c6 = function (r, t) {
      return r.push(t);
    }),
    (e.wbg.__wbg_queueMicrotask_97d92b4fcc8a61c5 = function (r) {
      queueMicrotask(r);
    }),
    (e.wbg.__wbg_queueMicrotask_d3219def82552485 = function (r) {
      return r.queueMicrotask;
    }),
    (e.wbg.__wbg_resolve_4851785c9c5f573d = function (r) {
      return Promise.resolve(r);
    }),
    (e.wbg.__wbg_reverse_71c11f9686a5c11b = function (r) {
      return r.reverse();
    }),
    (e.wbg.__wbg_set_8fc6bf8a5b1071d1 = function (r, t, n) {
      return r.set(t, n);
    }),
    (e.wbg.__wbg_set_bb8cecf6a62b9f46 = function () {
      return Yt(function (r, t, n) {
        return Reflect.set(r, t, n);
      }, arguments);
    }),
    (e.wbg.__wbg_setcause_180f5110152d3ce3 = function (r, t) {
      r.cause = t;
    }),
    (e.wbg.__wbg_stack_0ed75d68575b0f3c = function (r, t) {
      const n = t.stack,
        i = Mn(n, ce.__wbindgen_malloc, ce.__wbindgen_realloc),
        s = Lt;
      (yt().setInt32(r + 4, s, !0), yt().setInt32(r + 0, i, !0));
    }),
    (e.wbg.__wbg_static_accessor_GLOBAL_88a902d13a557d07 = function () {
      const r = typeof globalThis > "u" ? null : globalThis;
      return Tt(r) ? 0 : gr(r);
    }),
    (e.wbg.__wbg_static_accessor_GLOBAL_THIS_56578be7e9f832b0 = function () {
      const r = typeof globalThis > "u" ? null : globalThis;
      return Tt(r) ? 0 : gr(r);
    }),
    (e.wbg.__wbg_static_accessor_SELF_37c5d418e4bf5819 = function () {
      const r = typeof self > "u" ? null : self;
      return Tt(r) ? 0 : gr(r);
    }),
    (e.wbg.__wbg_static_accessor_WINDOW_5de37043a91a9c40 = function () {
      const r = typeof window > "u" ? null : window;
      return Tt(r) ? 0 : gr(r);
    }),
    (e.wbg.__wbg_then_44b73946d2fb3e7d = function (r, t) {
      return r.then(t);
    }),
    (e.wbg.__wbg_then_48b406749878a531 = function (r, t, n) {
      return r.then(t, n);
    }),
    (e.wbg.__wbg_values_fcb8ba8c0aad8b58 = function (r) {
      return Object.values(r);
    }),
    (e.wbg.__wbg_warn_4ca3906c248c47c4 = function (r) {
      console.warn(r);
    }),
    (e.wbg.__wbg_warn_aaf1f4664a035bd6 = function (r, t, n, i) {
      console.warn(r, t, n, i);
    }),
    (e.wbg.__wbindgen_cb_drop = function (r) {
      const t = r.original;
      return t.cnt-- == 1 ? ((t.a = 0), !0) : !1;
    }),
    (e.wbg.__wbindgen_closure_wrapper2143 = function (r, t, n) {
      return zc(r, t, 647, Wc);
    }),
    (e.wbg.__wbindgen_debug_string = function (r, t) {
      const n = wi(t),
        i = Mn(n, ce.__wbindgen_malloc, ce.__wbindgen_realloc),
        s = Lt;
      (yt().setInt32(r + 4, s, !0), yt().setInt32(r + 0, i, !0));
    }),
    (e.wbg.__wbindgen_init_externref_table = function () {
      const r = ce.__wbindgen_export_2,
        t = r.grow(4);
      (r.set(0, void 0),
        r.set(t + 0, void 0),
        r.set(t + 1, null),
        r.set(t + 2, !0),
        r.set(t + 3, !1));
    }),
    (e.wbg.__wbindgen_is_array = function (r) {
      return Array.isArray(r);
    }),
    (e.wbg.__wbindgen_is_function = function (r) {
      return typeof r == "function";
    }),
    (e.wbg.__wbindgen_is_string = function (r) {
      return typeof r == "string";
    }),
    (e.wbg.__wbindgen_is_undefined = function (r) {
      return r === void 0;
    }),
    (e.wbg.__wbindgen_number_get = function (r, t) {
      const n = t,
        i = typeof n == "number" ? n : void 0;
      (yt().setFloat64(r + 8, Tt(i) ? 0 : i, !0),
        yt().setInt32(r + 0, !Tt(i), !0));
    }),
    (e.wbg.__wbindgen_number_new = function (r) {
      return r;
    }),
    (e.wbg.__wbindgen_string_get = function (r, t) {
      const n = t,
        i = typeof n == "string" ? n : void 0;
      var s = Tt(i) ? 0 : Mn(i, ce.__wbindgen_malloc, ce.__wbindgen_realloc),
        l = Lt;
      (yt().setInt32(r + 4, l, !0), yt().setInt32(r + 0, s, !0));
    }),
    (e.wbg.__wbindgen_string_new = function (r, t) {
      return Gt(r, t);
    }),
    (e.wbg.__wbindgen_throw = function (r, t) {
      throw new Error(Gt(r, t));
    }),
    e
  );
}
function jc(e, r) {
  return (
    (ce = e.exports),
    ($i.__wbindgen_wasm_module = r),
    (Rt = null),
    (yr = null),
    ce.__wbindgen_start(),
    ce
  );
}
async function $i(e) {
  if (ce !== void 0) return ce;
  (typeof e < "u" &&
    (Object.getPrototypeOf(e) === Object.prototype
      ? ({ module_or_path: e } = e)
      : console.warn(
          "using deprecated parameters for the initialization function; pass a single object instead",
        )),
    typeof e > "u" &&
      (e = new URL("/assets/acvm_js_bg-BvxvrAml.wasm", import.meta.url)));
  const r = Gc();
  (typeof e == "string" ||
    (typeof Request == "function" && e instanceof Request) ||
    (typeof URL == "function" && e instanceof URL)) &&
    (e = fetch(e));
  const { instance: t, module: n } = await Yc(await e, r);
  return jc(t, n);
}
let ye;
const Xo =
  typeof TextDecoder < "u"
    ? new TextDecoder("utf-8", { ignoreBOM: !0, fatal: !0 })
    : {
        decode: () => {
          throw Error("TextDecoder not available");
        },
      };
typeof TextDecoder < "u" && Xo.decode();
let br = null;
function un() {
  return (
    (br === null || br.byteLength === 0) &&
      (br = new Uint8Array(ye.memory.buffer)),
    br
  );
}
function Kr(e, r) {
  return ((e = e >>> 0), Xo.decode(un().subarray(e, e + r)));
}
function qo(e) {
  const r = ye.__externref_table_alloc();
  return (ye.__wbindgen_export_3.set(r, e), r);
}
function ra(e, r) {
  try {
    return e.apply(this, r);
  } catch (t) {
    const n = qo(t);
    ye.__wbindgen_exn_store(n);
  }
}
let gn = 0;
const fn =
    typeof TextEncoder < "u"
      ? new TextEncoder("utf-8")
      : {
          encode: () => {
            throw Error("TextEncoder not available");
          },
        },
  Kc =
    typeof fn.encodeInto == "function"
      ? function (e, r) {
          return fn.encodeInto(e, r);
        }
      : function (e, r) {
          const t = fn.encode(e);
          return (r.set(t), { read: e.length, written: t.length });
        };
function na(e, r, t) {
  if (t === void 0) {
    const h = fn.encode(e),
      g = r(h.length, 1) >>> 0;
    return (
      un()
        .subarray(g, g + h.length)
        .set(h),
      (gn = h.length),
      g
    );
  }
  let n = e.length,
    i = r(n, 1) >>> 0;
  const s = un();
  let l = 0;
  for (; l < n; l++) {
    const h = e.charCodeAt(l);
    if (h > 127) break;
    s[i + l] = h;
  }
  if (l !== n) {
    (l !== 0 && (e = e.slice(l)),
      (i = t(i, n, (n = l + e.length * 3), 1) >>> 0));
    const h = un().subarray(i + l, i + n),
      g = Kc(e, h);
    ((l += g.written), (i = t(i, n, l, 1) >>> 0));
  }
  return ((gn = l), i);
}
let Ct = null;
function jt() {
  return (
    (Ct === null ||
      Ct.buffer.detached === !0 ||
      (Ct.buffer.detached === void 0 && Ct.buffer !== ye.memory.buffer)) &&
      (Ct = new DataView(ye.memory.buffer)),
    Ct
  );
}
function hn(e) {
  return e == null;
}
function or(e) {
  const r = ye.__wbindgen_export_3.get(e);
  return (ye.__externref_table_dealloc(e), r);
}
function Xc(e, r, t) {
  const n = ye.abiEncode(e, r, hn(t) ? 0 : qo(t));
  if (n[2]) throw or(n[1]);
  return or(n[0]);
}
function qc(e, r) {
  const t = ye.abiDecode(e, r);
  if (t[2]) throw or(t[1]);
  return or(t[0]);
}
function Jc(e, r) {
  const t = ye.abiDecodeError(e, r);
  if (t[2]) throw or(t[1]);
  return or(t[0]);
}
function Qc(e, r, t, n) {
  ye.closure245_externref_shim(e, r, t, n);
}
async function el(e, r) {
  if (typeof Response == "function" && e instanceof Response) {
    if (typeof WebAssembly.instantiateStreaming == "function")
      try {
        return await WebAssembly.instantiateStreaming(e, r);
      } catch (n) {
        if (e.headers.get("Content-Type") != "application/wasm")
          console.warn(
            "`WebAssembly.instantiateStreaming` failed because your server does not serve Wasm with `application/wasm` MIME type. Falling back to `WebAssembly.instantiate` which is slower. Original error:\n",
            n,
          );
        else throw n;
      }
    const t = await e.arrayBuffer();
    return await WebAssembly.instantiate(t, r);
  } else {
    const t = await WebAssembly.instantiate(e, r);
    return t instanceof WebAssembly.Instance ? { instance: t, module: e } : t;
  }
}
function tl() {
  const e = {};
  return (
    (e.wbg = {}),
    (e.wbg.__wbg_constructor_55ed424879ec3895 = function (r) {
      return new Error(r);
    }),
    (e.wbg.__wbg_error_7534b8e9a36f1ab4 = function (r, t) {
      let n, i;
      try {
        ((n = r), (i = t), console.error(Kr(r, t)));
      } finally {
        ye.__wbindgen_free(n, i, 1);
      }
    }),
    (e.wbg.__wbg_forEach_e1cf6f7c8ecb7dae = function (r, t, n) {
      try {
        var i = { a: t, b: n },
          s = (l, h) => {
            const g = i.a;
            i.a = 0;
            try {
              return Qc(g, i.b, l, h);
            } finally {
              i.a = g;
            }
          };
        r.forEach(s);
      } finally {
        i.a = i.b = 0;
      }
    }),
    (e.wbg.__wbg_new_0d921e1ff7a37fda = function () {
      return new Map();
    }),
    (e.wbg.__wbg_new_8a6f238a6ece86ea = function () {
      return new Error();
    }),
    (e.wbg.__wbg_parse_def2e24ef1252aff = function () {
      return ra(function (r, t) {
        return JSON.parse(Kr(r, t));
      }, arguments);
    }),
    (e.wbg.__wbg_set_8fc6bf8a5b1071d1 = function (r, t, n) {
      return r.set(t, n);
    }),
    (e.wbg.__wbg_stack_0ed75d68575b0f3c = function (r, t) {
      const n = t.stack,
        i = na(n, ye.__wbindgen_malloc, ye.__wbindgen_realloc),
        s = gn;
      (jt().setInt32(r + 4, s, !0), jt().setInt32(r + 0, i, !0));
    }),
    (e.wbg.__wbg_stringify_f7ed6987935b4a24 = function () {
      return ra(function (r) {
        return JSON.stringify(r);
      }, arguments);
    }),
    (e.wbg.__wbindgen_init_externref_table = function () {
      const r = ye.__wbindgen_export_3,
        t = r.grow(4);
      (r.set(0, void 0),
        r.set(t + 0, void 0),
        r.set(t + 1, null),
        r.set(t + 2, !0),
        r.set(t + 3, !1));
    }),
    (e.wbg.__wbindgen_is_undefined = function (r) {
      return r === void 0;
    }),
    (e.wbg.__wbindgen_number_get = function (r, t) {
      const n = t,
        i = typeof n == "number" ? n : void 0;
      (jt().setFloat64(r + 8, hn(i) ? 0 : i, !0),
        jt().setInt32(r + 0, !hn(i), !0));
    }),
    (e.wbg.__wbindgen_number_new = function (r) {
      return r;
    }),
    (e.wbg.__wbindgen_string_get = function (r, t) {
      const n = t,
        i = typeof n == "string" ? n : void 0;
      var s = hn(i) ? 0 : na(i, ye.__wbindgen_malloc, ye.__wbindgen_realloc),
        l = gn;
      (jt().setInt32(r + 4, l, !0), jt().setInt32(r + 0, s, !0));
    }),
    (e.wbg.__wbindgen_string_new = function (r, t) {
      return Kr(r, t);
    }),
    (e.wbg.__wbindgen_throw = function (r, t) {
      throw new Error(Kr(r, t));
    }),
    e
  );
}
function rl(e, r) {
  return (
    (ye = e.exports),
    (yn.__wbindgen_wasm_module = r),
    (Ct = null),
    (br = null),
    ye.__wbindgen_start(),
    ye
  );
}
async function yn(e) {
  if (ye !== void 0) return ye;
  (typeof e < "u" &&
    (Object.getPrototypeOf(e) === Object.prototype
      ? ({ module_or_path: e } = e)
      : console.warn(
          "using deprecated parameters for the initialization function; pass a single object instead",
        )),
    typeof e > "u" &&
      (e = new URL(
        "/assets/noirc_abi_wasm_bg-DRbWm09M.wasm",
        import.meta.url,
      )));
  const r = tl();
  (typeof e == "string" ||
    (typeof Request == "function" && e instanceof Request) ||
    (typeof URL == "function" && e instanceof URL)) &&
    (e = fetch(e));
  const { instance: t, module: n } = await el(await e, r);
  return rl(t, n);
}
var Jo = {},
  xn = {};
xn.byteLength = al;
xn.toByteArray = sl;
xn.fromByteArray = ul;
var Ke = [],
  Pe = [],
  nl = typeof Uint8Array < "u" ? Uint8Array : Array,
  Pn = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
for (var Kt = 0, il = Pn.length; Kt < il; ++Kt)
  ((Ke[Kt] = Pn[Kt]), (Pe[Pn.charCodeAt(Kt)] = Kt));
Pe[45] = 62;
Pe[95] = 63;
function Qo(e) {
  var r = e.length;
  if (r % 4 > 0)
    throw new Error("Invalid string. Length must be a multiple of 4");
  var t = e.indexOf("=");
  t === -1 && (t = r);
  var n = t === r ? 0 : 4 - (t % 4);
  return [t, n];
}
function al(e) {
  var r = Qo(e),
    t = r[0],
    n = r[1];
  return ((t + n) * 3) / 4 - n;
}
function ol(e, r, t) {
  return ((r + t) * 3) / 4 - t;
}
function sl(e) {
  var r,
    t = Qo(e),
    n = t[0],
    i = t[1],
    s = new nl(ol(e, n, i)),
    l = 0,
    h = i > 0 ? n - 4 : n,
    g;
  for (g = 0; g < h; g += 4)
    ((r =
      (Pe[e.charCodeAt(g)] << 18) |
      (Pe[e.charCodeAt(g + 1)] << 12) |
      (Pe[e.charCodeAt(g + 2)] << 6) |
      Pe[e.charCodeAt(g + 3)]),
      (s[l++] = (r >> 16) & 255),
      (s[l++] = (r >> 8) & 255),
      (s[l++] = r & 255));
  return (
    i === 2 &&
      ((r = (Pe[e.charCodeAt(g)] << 2) | (Pe[e.charCodeAt(g + 1)] >> 4)),
      (s[l++] = r & 255)),
    i === 1 &&
      ((r =
        (Pe[e.charCodeAt(g)] << 10) |
        (Pe[e.charCodeAt(g + 1)] << 4) |
        (Pe[e.charCodeAt(g + 2)] >> 2)),
      (s[l++] = (r >> 8) & 255),
      (s[l++] = r & 255)),
    s
  );
}
function cl(e) {
  return (
    Ke[(e >> 18) & 63] + Ke[(e >> 12) & 63] + Ke[(e >> 6) & 63] + Ke[e & 63]
  );
}
function ll(e, r, t) {
  for (var n, i = [], s = r; s < t; s += 3)
    ((n =
      ((e[s] << 16) & 16711680) + ((e[s + 1] << 8) & 65280) + (e[s + 2] & 255)),
      i.push(cl(n)));
  return i.join("");
}
function ul(e) {
  for (
    var r, t = e.length, n = t % 3, i = [], s = 16383, l = 0, h = t - n;
    l < h;
    l += s
  )
    i.push(ll(e, l, l + s > h ? h : l + s));
  return (
    n === 1
      ? ((r = e[t - 1]), i.push(Ke[r >> 2] + Ke[(r << 4) & 63] + "=="))
      : n === 2 &&
        ((r = (e[t - 2] << 8) + e[t - 1]),
        i.push(Ke[r >> 10] + Ke[(r >> 4) & 63] + Ke[(r << 2) & 63] + "=")),
    i.join("")
  );
}
var Li = {};
/*! ieee754. BSD-3-Clause License. Feross Aboukhadijeh <https://feross.org/opensource> */ Li.read =
  function (e, r, t, n, i) {
    var s,
      l,
      h = i * 8 - n - 1,
      g = (1 << h) - 1,
      u = g >> 1,
      d = -7,
      E = t ? i - 1 : 0,
      b = t ? -1 : 1,
      y = e[r + E];
    for (
      E += b, s = y & ((1 << -d) - 1), y >>= -d, d += h;
      d > 0;
      s = s * 256 + e[r + E], E += b, d -= 8
    );
    for (
      l = s & ((1 << -d) - 1), s >>= -d, d += n;
      d > 0;
      l = l * 256 + e[r + E], E += b, d -= 8
    );
    if (s === 0) s = 1 - u;
    else {
      if (s === g) return l ? NaN : (y ? -1 : 1) * (1 / 0);
      ((l = l + Math.pow(2, n)), (s = s - u));
    }
    return (y ? -1 : 1) * l * Math.pow(2, s - n);
  };
Li.write = function (e, r, t, n, i, s) {
  var l,
    h,
    g,
    u = s * 8 - i - 1,
    d = (1 << u) - 1,
    E = d >> 1,
    b = i === 23 ? Math.pow(2, -24) - Math.pow(2, -77) : 0,
    y = n ? 0 : s - 1,
    I = n ? 1 : -1,
    x = r < 0 || (r === 0 && 1 / r < 0) ? 1 : 0;
  for (
    r = Math.abs(r),
      isNaN(r) || r === 1 / 0
        ? ((h = isNaN(r) ? 1 : 0), (l = d))
        : ((l = Math.floor(Math.log(r) / Math.LN2)),
          r * (g = Math.pow(2, -l)) < 1 && (l--, (g *= 2)),
          l + E >= 1 ? (r += b / g) : (r += b * Math.pow(2, 1 - E)),
          r * g >= 2 && (l++, (g /= 2)),
          l + E >= d
            ? ((h = 0), (l = d))
            : l + E >= 1
              ? ((h = (r * g - 1) * Math.pow(2, i)), (l = l + E))
              : ((h = r * Math.pow(2, E - 1) * Math.pow(2, i)), (l = 0)));
    i >= 8;
    e[t + y] = h & 255, y += I, h /= 256, i -= 8
  );
  for (
    l = (l << i) | h, u += i;
    u > 0;
    e[t + y] = l & 255, y += I, l /= 256, u -= 8
  );
  e[t + y - I] |= x * 128;
};
/*!
 * The buffer module from node.js, for the browser.
 *
 * @author   Feross Aboukhadijeh <https://feross.org>
 * @license  MIT
 */ (function (e) {
  const r = xn,
    t = Li,
    n =
      typeof Symbol == "function" && typeof Symbol.for == "function"
        ? Symbol.for("nodejs.util.inspect.custom")
        : null;
  ((e.Buffer = d), (e.SlowBuffer = z), (e.INSPECT_MAX_BYTES = 50));
  const i = 2147483647;
  e.kMaxLength = i;
  const { Uint8Array: s, ArrayBuffer: l, SharedArrayBuffer: h } = globalThis;
  ((d.TYPED_ARRAY_SUPPORT = g()),
    !d.TYPED_ARRAY_SUPPORT &&
      typeof console < "u" &&
      typeof console.error == "function" &&
      console.error(
        "This browser lacks typed array (Uint8Array) support which is required by `buffer` v5.x. Use `buffer` v4.x if you require old browser support.",
      ));
  function g() {
    try {
      const a = new s(1),
        o = {
          foo: function () {
            return 42;
          },
        };
      return (
        Object.setPrototypeOf(o, s.prototype),
        Object.setPrototypeOf(a, o),
        a.foo() === 42
      );
    } catch {
      return !1;
    }
  }
  (Object.defineProperty(d.prototype, "parent", {
    enumerable: !0,
    get: function () {
      if (d.isBuffer(this)) return this.buffer;
    },
  }),
    Object.defineProperty(d.prototype, "offset", {
      enumerable: !0,
      get: function () {
        if (d.isBuffer(this)) return this.byteOffset;
      },
    }));
  function u(a) {
    if (a > i)
      throw new RangeError(
        'The value "' + a + '" is invalid for option "size"',
      );
    const o = new s(a);
    return (Object.setPrototypeOf(o, d.prototype), o);
  }
  function d(a, o, c) {
    if (typeof a == "number") {
      if (typeof o == "string")
        throw new TypeError(
          'The "string" argument must be of type string. Received type number',
        );
      return I(a);
    }
    return E(a, o, c);
  }
  d.poolSize = 8192;
  function E(a, o, c) {
    if (typeof a == "string") return x(a, o);
    if (l.isView(a)) return R(a);
    if (a == null)
      throw new TypeError(
        "The first argument must be one of type string, Buffer, ArrayBuffer, Array, or Array-like Object. Received type " +
          typeof a,
      );
    if (
      Fe(a, l) ||
      (a && Fe(a.buffer, l)) ||
      (typeof h < "u" && (Fe(a, h) || (a && Fe(a.buffer, h))))
    )
      return $(a, o, c);
    if (typeof a == "number")
      throw new TypeError(
        'The "value" argument must not be of type number. Received type number',
      );
    const _ = a.valueOf && a.valueOf();
    if (_ != null && _ !== a) return d.from(_, o, c);
    const w = D(a);
    if (w) return w;
    if (
      typeof Symbol < "u" &&
      Symbol.toPrimitive != null &&
      typeof a[Symbol.toPrimitive] == "function"
    )
      return d.from(a[Symbol.toPrimitive]("string"), o, c);
    throw new TypeError(
      "The first argument must be one of type string, Buffer, ArrayBuffer, Array, or Array-like Object. Received type " +
        typeof a,
    );
  }
  ((d.from = function (a, o, c) {
    return E(a, o, c);
  }),
    Object.setPrototypeOf(d.prototype, s.prototype),
    Object.setPrototypeOf(d, s));
  function b(a) {
    if (typeof a != "number")
      throw new TypeError('"size" argument must be of type number');
    if (a < 0)
      throw new RangeError(
        'The value "' + a + '" is invalid for option "size"',
      );
  }
  function y(a, o, c) {
    return (
      b(a),
      a <= 0
        ? u(a)
        : o !== void 0
          ? typeof c == "string"
            ? u(a).fill(o, c)
            : u(a).fill(o)
          : u(a)
    );
  }
  d.alloc = function (a, o, c) {
    return y(a, o, c);
  };
  function I(a) {
    return (b(a), u(a < 0 ? 0 : m(a) | 0));
  }
  ((d.allocUnsafe = function (a) {
    return I(a);
  }),
    (d.allocUnsafeSlow = function (a) {
      return I(a);
    }));
  function x(a, o) {
    if (((typeof o != "string" || o === "") && (o = "utf8"), !d.isEncoding(o)))
      throw new TypeError("Unknown encoding: " + o);
    const c = V(a, o) | 0;
    let _ = u(c);
    const w = _.write(a, o);
    return (w !== c && (_ = _.slice(0, w)), _);
  }
  function T(a) {
    const o = a.length < 0 ? 0 : m(a.length) | 0,
      c = u(o);
    for (let _ = 0; _ < o; _ += 1) c[_] = a[_] & 255;
    return c;
  }
  function R(a) {
    if (Fe(a, s)) {
      const o = new s(a);
      return $(o.buffer, o.byteOffset, o.byteLength);
    }
    return T(a);
  }
  function $(a, o, c) {
    if (o < 0 || a.byteLength < o)
      throw new RangeError('"offset" is outside of buffer bounds');
    if (a.byteLength < o + (c || 0))
      throw new RangeError('"length" is outside of buffer bounds');
    let _;
    return (
      o === void 0 && c === void 0
        ? (_ = new s(a))
        : c === void 0
          ? (_ = new s(a, o))
          : (_ = new s(a, o, c)),
      Object.setPrototypeOf(_, d.prototype),
      _
    );
  }
  function D(a) {
    if (d.isBuffer(a)) {
      const o = m(a.length) | 0,
        c = u(o);
      return (c.length === 0 || a.copy(c, 0, 0, o), c);
    }
    if (a.length !== void 0)
      return typeof a.length != "number" || Me(a.length) ? u(0) : T(a);
    if (a.type === "Buffer" && Array.isArray(a.data)) return T(a.data);
  }
  function m(a) {
    if (a >= i)
      throw new RangeError(
        "Attempt to allocate Buffer larger than maximum size: 0x" +
          i.toString(16) +
          " bytes",
      );
    return a | 0;
  }
  function z(a) {
    return (+a != a && (a = 0), d.alloc(+a));
  }
  ((d.isBuffer = function (o) {
    return o != null && o._isBuffer === !0 && o !== d.prototype;
  }),
    (d.compare = function (o, c) {
      if (
        (Fe(o, s) && (o = d.from(o, o.offset, o.byteLength)),
        Fe(c, s) && (c = d.from(c, c.offset, c.byteLength)),
        !d.isBuffer(o) || !d.isBuffer(c))
      )
        throw new TypeError(
          'The "buf1", "buf2" arguments must be one of type Buffer or Uint8Array',
        );
      if (o === c) return 0;
      let _ = o.length,
        w = c.length;
      for (let B = 0, U = Math.min(_, w); B < U; ++B)
        if (o[B] !== c[B]) {
          ((_ = o[B]), (w = c[B]));
          break;
        }
      return _ < w ? -1 : w < _ ? 1 : 0;
    }),
    (d.isEncoding = function (o) {
      switch (String(o).toLowerCase()) {
        case "hex":
        case "utf8":
        case "utf-8":
        case "ascii":
        case "latin1":
        case "binary":
        case "base64":
        case "ucs2":
        case "ucs-2":
        case "utf16le":
        case "utf-16le":
          return !0;
        default:
          return !1;
      }
    }),
    (d.concat = function (o, c) {
      if (!Array.isArray(o))
        throw new TypeError('"list" argument must be an Array of Buffers');
      if (o.length === 0) return d.alloc(0);
      let _;
      if (c === void 0) for (c = 0, _ = 0; _ < o.length; ++_) c += o[_].length;
      const w = d.allocUnsafe(c);
      let B = 0;
      for (_ = 0; _ < o.length; ++_) {
        let U = o[_];
        if (Fe(U, s))
          B + U.length > w.length
            ? (d.isBuffer(U) || (U = d.from(U)), U.copy(w, B))
            : s.prototype.set.call(w, U, B);
        else if (d.isBuffer(U)) U.copy(w, B);
        else throw new TypeError('"list" argument must be an Array of Buffers');
        B += U.length;
      }
      return w;
    }));
  function V(a, o) {
    if (d.isBuffer(a)) return a.length;
    if (l.isView(a) || Fe(a, l)) return a.byteLength;
    if (typeof a != "string")
      throw new TypeError(
        'The "string" argument must be one of type string, Buffer, or ArrayBuffer. Received type ' +
          typeof a,
      );
    const c = a.length,
      _ = arguments.length > 2 && arguments[2] === !0;
    if (!_ && c === 0) return 0;
    let w = !1;
    for (;;)
      switch (o) {
        case "ascii":
        case "latin1":
        case "binary":
          return c;
        case "utf8":
        case "utf-8":
          return _r(a).length;
        case "ucs2":
        case "ucs-2":
        case "utf16le":
        case "utf-16le":
          return c * 2;
        case "hex":
          return c >>> 1;
        case "base64":
          return Ce(a).length;
        default:
          if (w) return _ ? -1 : _r(a).length;
          ((o = ("" + o).toLowerCase()), (w = !0));
      }
  }
  d.byteLength = V;
  function C(a, o, c) {
    let _ = !1;
    if (
      ((o === void 0 || o < 0) && (o = 0),
      o > this.length ||
        ((c === void 0 || c > this.length) && (c = this.length), c <= 0) ||
        ((c >>>= 0), (o >>>= 0), c <= o))
    )
      return "";
    for (a || (a = "utf8"); ; )
      switch (a) {
        case "hex":
          return X(this, o, c);
        case "utf8":
        case "utf-8":
          return Z(this, o, c);
        case "ascii":
          return K(this, o, c);
        case "latin1":
        case "binary":
          return ee(this, o, c);
        case "base64":
          return O(this, o, c);
        case "ucs2":
        case "ucs-2":
        case "utf16le":
        case "utf-16le":
          return ie(this, o, c);
        default:
          if (_) throw new TypeError("Unknown encoding: " + a);
          ((a = (a + "").toLowerCase()), (_ = !0));
      }
  }
  d.prototype._isBuffer = !0;
  function H(a, o, c) {
    const _ = a[o];
    ((a[o] = a[c]), (a[c] = _));
  }
  ((d.prototype.swap16 = function () {
    const o = this.length;
    if (o % 2 !== 0)
      throw new RangeError("Buffer size must be a multiple of 16-bits");
    for (let c = 0; c < o; c += 2) H(this, c, c + 1);
    return this;
  }),
    (d.prototype.swap32 = function () {
      const o = this.length;
      if (o % 4 !== 0)
        throw new RangeError("Buffer size must be a multiple of 32-bits");
      for (let c = 0; c < o; c += 4) (H(this, c, c + 3), H(this, c + 1, c + 2));
      return this;
    }),
    (d.prototype.swap64 = function () {
      const o = this.length;
      if (o % 8 !== 0)
        throw new RangeError("Buffer size must be a multiple of 64-bits");
      for (let c = 0; c < o; c += 8)
        (H(this, c, c + 7),
          H(this, c + 1, c + 6),
          H(this, c + 2, c + 5),
          H(this, c + 3, c + 4));
      return this;
    }),
    (d.prototype.toString = function () {
      const o = this.length;
      return o === 0
        ? ""
        : arguments.length === 0
          ? Z(this, 0, o)
          : C.apply(this, arguments);
    }),
    (d.prototype.toLocaleString = d.prototype.toString),
    (d.prototype.equals = function (o) {
      if (!d.isBuffer(o)) throw new TypeError("Argument must be a Buffer");
      return this === o ? !0 : d.compare(this, o) === 0;
    }),
    (d.prototype.inspect = function () {
      let o = "";
      const c = e.INSPECT_MAX_BYTES;
      return (
        (o = this.toString("hex", 0, c)
          .replace(/(.{2})/g, "$1 ")
          .trim()),
        this.length > c && (o += " ... "),
        "<Buffer " + o + ">"
      );
    }),
    n && (d.prototype[n] = d.prototype.inspect),
    (d.prototype.compare = function (o, c, _, w, B) {
      if ((Fe(o, s) && (o = d.from(o, o.offset, o.byteLength)), !d.isBuffer(o)))
        throw new TypeError(
          'The "target" argument must be one of type Buffer or Uint8Array. Received type ' +
            typeof o,
        );
      if (
        (c === void 0 && (c = 0),
        _ === void 0 && (_ = o ? o.length : 0),
        w === void 0 && (w = 0),
        B === void 0 && (B = this.length),
        c < 0 || _ > o.length || w < 0 || B > this.length)
      )
        throw new RangeError("out of range index");
      if (w >= B && c >= _) return 0;
      if (w >= B) return -1;
      if (c >= _) return 1;
      if (((c >>>= 0), (_ >>>= 0), (w >>>= 0), (B >>>= 0), this === o))
        return 0;
      let U = B - w,
        G = _ - c;
      const Q = Math.min(U, G),
        q = this.slice(w, B),
        be = o.slice(c, _);
      for (let ue = 0; ue < Q; ++ue)
        if (q[ue] !== be[ue]) {
          ((U = q[ue]), (G = be[ue]));
          break;
        }
      return U < G ? -1 : G < U ? 1 : 0;
    }));
  function M(a, o, c, _, w) {
    if (a.length === 0) return -1;
    if (
      (typeof c == "string"
        ? ((_ = c), (c = 0))
        : c > 2147483647
          ? (c = 2147483647)
          : c < -2147483648 && (c = -2147483648),
      (c = +c),
      Me(c) && (c = w ? 0 : a.length - 1),
      c < 0 && (c = a.length + c),
      c >= a.length)
    ) {
      if (w) return -1;
      c = a.length - 1;
    } else if (c < 0)
      if (w) c = 0;
      else return -1;
    if ((typeof o == "string" && (o = d.from(o, _)), d.isBuffer(o)))
      return o.length === 0 ? -1 : N(a, o, c, _, w);
    if (typeof o == "number")
      return (
        (o = o & 255),
        typeof s.prototype.indexOf == "function"
          ? w
            ? s.prototype.indexOf.call(a, o, c)
            : s.prototype.lastIndexOf.call(a, o, c)
          : N(a, [o], c, _, w)
      );
    throw new TypeError("val must be string, number or Buffer");
  }
  function N(a, o, c, _, w) {
    let B = 1,
      U = a.length,
      G = o.length;
    if (
      _ !== void 0 &&
      ((_ = String(_).toLowerCase()),
      _ === "ucs2" || _ === "ucs-2" || _ === "utf16le" || _ === "utf-16le")
    ) {
      if (a.length < 2 || o.length < 2) return -1;
      ((B = 2), (U /= 2), (G /= 2), (c /= 2));
    }
    function Q(be, ue) {
      return B === 1 ? be[ue] : be.readUInt16BE(ue * B);
    }
    let q;
    if (w) {
      let be = -1;
      for (q = c; q < U; q++)
        if (Q(a, q) === Q(o, be === -1 ? 0 : q - be)) {
          if ((be === -1 && (be = q), q - be + 1 === G)) return be * B;
        } else (be !== -1 && (q -= q - be), (be = -1));
    } else
      for (c + G > U && (c = U - G), q = c; q >= 0; q--) {
        let be = !0;
        for (let ue = 0; ue < G; ue++)
          if (Q(a, q + ue) !== Q(o, ue)) {
            be = !1;
            break;
          }
        if (be) return q;
      }
    return -1;
  }
  ((d.prototype.includes = function (o, c, _) {
    return this.indexOf(o, c, _) !== -1;
  }),
    (d.prototype.indexOf = function (o, c, _) {
      return M(this, o, c, _, !0);
    }),
    (d.prototype.lastIndexOf = function (o, c, _) {
      return M(this, o, c, _, !1);
    }));
  function F(a, o, c, _) {
    c = Number(c) || 0;
    const w = a.length - c;
    _ ? ((_ = Number(_)), _ > w && (_ = w)) : (_ = w);
    const B = o.length;
    _ > B / 2 && (_ = B / 2);
    let U;
    for (U = 0; U < _; ++U) {
      const G = parseInt(o.substr(U * 2, 2), 16);
      if (Me(G)) return U;
      a[c + U] = G;
    }
    return U;
  }
  function se(a, o, c, _) {
    return gt(_r(o, a.length - c), a, c, _);
  }
  function A(a, o, c, _) {
    return gt(jr(o), a, c, _);
  }
  function P(a, o, c, _) {
    return gt(Ce(o), a, c, _);
  }
  function L(a, o, c, _) {
    return gt(Vt(o, a.length - c), a, c, _);
  }
  ((d.prototype.write = function (o, c, _, w) {
    if (c === void 0) ((w = "utf8"), (_ = this.length), (c = 0));
    else if (_ === void 0 && typeof c == "string")
      ((w = c), (_ = this.length), (c = 0));
    else if (isFinite(c))
      ((c = c >>> 0),
        isFinite(_)
          ? ((_ = _ >>> 0), w === void 0 && (w = "utf8"))
          : ((w = _), (_ = void 0)));
    else
      throw new Error(
        "Buffer.write(string, encoding, offset[, length]) is no longer supported",
      );
    const B = this.length - c;
    if (
      ((_ === void 0 || _ > B) && (_ = B),
      (o.length > 0 && (_ < 0 || c < 0)) || c > this.length)
    )
      throw new RangeError("Attempt to write outside buffer bounds");
    w || (w = "utf8");
    let U = !1;
    for (;;)
      switch (w) {
        case "hex":
          return F(this, o, c, _);
        case "utf8":
        case "utf-8":
          return se(this, o, c, _);
        case "ascii":
        case "latin1":
        case "binary":
          return A(this, o, c, _);
        case "base64":
          return P(this, o, c, _);
        case "ucs2":
        case "ucs-2":
        case "utf16le":
        case "utf-16le":
          return L(this, o, c, _);
        default:
          if (U) throw new TypeError("Unknown encoding: " + w);
          ((w = ("" + w).toLowerCase()), (U = !0));
      }
  }),
    (d.prototype.toJSON = function () {
      return {
        type: "Buffer",
        data: Array.prototype.slice.call(this._arr || this, 0),
      };
    }));
  function O(a, o, c) {
    return o === 0 && c === a.length
      ? r.fromByteArray(a)
      : r.fromByteArray(a.slice(o, c));
  }
  function Z(a, o, c) {
    c = Math.min(a.length, c);
    const _ = [];
    let w = o;
    for (; w < c; ) {
      const B = a[w];
      let U = null,
        G = B > 239 ? 4 : B > 223 ? 3 : B > 191 ? 2 : 1;
      if (w + G <= c) {
        let Q, q, be, ue;
        switch (G) {
          case 1:
            B < 128 && (U = B);
            break;
          case 2:
            ((Q = a[w + 1]),
              (Q & 192) === 128 &&
                ((ue = ((B & 31) << 6) | (Q & 63)), ue > 127 && (U = ue)));
            break;
          case 3:
            ((Q = a[w + 1]),
              (q = a[w + 2]),
              (Q & 192) === 128 &&
                (q & 192) === 128 &&
                ((ue = ((B & 15) << 12) | ((Q & 63) << 6) | (q & 63)),
                ue > 2047 && (ue < 55296 || ue > 57343) && (U = ue)));
            break;
          case 4:
            ((Q = a[w + 1]),
              (q = a[w + 2]),
              (be = a[w + 3]),
              (Q & 192) === 128 &&
                (q & 192) === 128 &&
                (be & 192) === 128 &&
                ((ue =
                  ((B & 15) << 18) |
                  ((Q & 63) << 12) |
                  ((q & 63) << 6) |
                  (be & 63)),
                ue > 65535 && ue < 1114112 && (U = ue)));
        }
      }
      (U === null
        ? ((U = 65533), (G = 1))
        : U > 65535 &&
          ((U -= 65536),
          _.push(((U >>> 10) & 1023) | 55296),
          (U = 56320 | (U & 1023))),
        _.push(U),
        (w += G));
    }
    return Y(_);
  }
  const j = 4096;
  function Y(a) {
    const o = a.length;
    if (o <= j) return String.fromCharCode.apply(String, a);
    let c = "",
      _ = 0;
    for (; _ < o; )
      c += String.fromCharCode.apply(String, a.slice(_, (_ += j)));
    return c;
  }
  function K(a, o, c) {
    let _ = "";
    c = Math.min(a.length, c);
    for (let w = o; w < c; ++w) _ += String.fromCharCode(a[w] & 127);
    return _;
  }
  function ee(a, o, c) {
    let _ = "";
    c = Math.min(a.length, c);
    for (let w = o; w < c; ++w) _ += String.fromCharCode(a[w]);
    return _;
  }
  function X(a, o, c) {
    const _ = a.length;
    ((!o || o < 0) && (o = 0), (!c || c < 0 || c > _) && (c = _));
    let w = "";
    for (let B = o; B < c; ++B) w += Fn[a[B]];
    return w;
  }
  function ie(a, o, c) {
    const _ = a.slice(o, c);
    let w = "";
    for (let B = 0; B < _.length - 1; B += 2)
      w += String.fromCharCode(_[B] + _[B + 1] * 256);
    return w;
  }
  d.prototype.slice = function (o, c) {
    const _ = this.length;
    ((o = ~~o),
      (c = c === void 0 ? _ : ~~c),
      o < 0 ? ((o += _), o < 0 && (o = 0)) : o > _ && (o = _),
      c < 0 ? ((c += _), c < 0 && (c = 0)) : c > _ && (c = _),
      c < o && (c = o));
    const w = this.subarray(o, c);
    return (Object.setPrototypeOf(w, d.prototype), w);
  };
  function ae(a, o, c) {
    if (a % 1 !== 0 || a < 0) throw new RangeError("offset is not uint");
    if (a + o > c)
      throw new RangeError("Trying to access beyond buffer length");
  }
  ((d.prototype.readUintLE = d.prototype.readUIntLE =
    function (o, c, _) {
      ((o = o >>> 0), (c = c >>> 0), _ || ae(o, c, this.length));
      let w = this[o],
        B = 1,
        U = 0;
      for (; ++U < c && (B *= 256); ) w += this[o + U] * B;
      return w;
    }),
    (d.prototype.readUintBE = d.prototype.readUIntBE =
      function (o, c, _) {
        ((o = o >>> 0), (c = c >>> 0), _ || ae(o, c, this.length));
        let w = this[o + --c],
          B = 1;
        for (; c > 0 && (B *= 256); ) w += this[o + --c] * B;
        return w;
      }),
    (d.prototype.readUint8 = d.prototype.readUInt8 =
      function (o, c) {
        return ((o = o >>> 0), c || ae(o, 1, this.length), this[o]);
      }),
    (d.prototype.readUint16LE = d.prototype.readUInt16LE =
      function (o, c) {
        return (
          (o = o >>> 0),
          c || ae(o, 2, this.length),
          this[o] | (this[o + 1] << 8)
        );
      }),
    (d.prototype.readUint16BE = d.prototype.readUInt16BE =
      function (o, c) {
        return (
          (o = o >>> 0),
          c || ae(o, 2, this.length),
          (this[o] << 8) | this[o + 1]
        );
      }),
    (d.prototype.readUint32LE = d.prototype.readUInt32LE =
      function (o, c) {
        return (
          (o = o >>> 0),
          c || ae(o, 4, this.length),
          (this[o] | (this[o + 1] << 8) | (this[o + 2] << 16)) +
            this[o + 3] * 16777216
        );
      }),
    (d.prototype.readUint32BE = d.prototype.readUInt32BE =
      function (o, c) {
        return (
          (o = o >>> 0),
          c || ae(o, 4, this.length),
          this[o] * 16777216 +
            ((this[o + 1] << 16) | (this[o + 2] << 8) | this[o + 3])
        );
      }),
    (d.prototype.readBigUInt64LE = p(function (o) {
      ((o = o >>> 0), wt(o, "offset"));
      const c = this[o],
        _ = this[o + 7];
      (c === void 0 || _ === void 0) && xt(o, this.length - 8);
      const w =
          c + this[++o] * 2 ** 8 + this[++o] * 2 ** 16 + this[++o] * 2 ** 24,
        B = this[++o] + this[++o] * 2 ** 8 + this[++o] * 2 ** 16 + _ * 2 ** 24;
      return BigInt(w) + (BigInt(B) << BigInt(32));
    })),
    (d.prototype.readBigUInt64BE = p(function (o) {
      ((o = o >>> 0), wt(o, "offset"));
      const c = this[o],
        _ = this[o + 7];
      (c === void 0 || _ === void 0) && xt(o, this.length - 8);
      const w =
          c * 2 ** 24 + this[++o] * 2 ** 16 + this[++o] * 2 ** 8 + this[++o],
        B = this[++o] * 2 ** 24 + this[++o] * 2 ** 16 + this[++o] * 2 ** 8 + _;
      return (BigInt(w) << BigInt(32)) + BigInt(B);
    })),
    (d.prototype.readIntLE = function (o, c, _) {
      ((o = o >>> 0), (c = c >>> 0), _ || ae(o, c, this.length));
      let w = this[o],
        B = 1,
        U = 0;
      for (; ++U < c && (B *= 256); ) w += this[o + U] * B;
      return ((B *= 128), w >= B && (w -= Math.pow(2, 8 * c)), w);
    }),
    (d.prototype.readIntBE = function (o, c, _) {
      ((o = o >>> 0), (c = c >>> 0), _ || ae(o, c, this.length));
      let w = c,
        B = 1,
        U = this[o + --w];
      for (; w > 0 && (B *= 256); ) U += this[o + --w] * B;
      return ((B *= 128), U >= B && (U -= Math.pow(2, 8 * c)), U);
    }),
    (d.prototype.readInt8 = function (o, c) {
      return (
        (o = o >>> 0),
        c || ae(o, 1, this.length),
        this[o] & 128 ? (255 - this[o] + 1) * -1 : this[o]
      );
    }),
    (d.prototype.readInt16LE = function (o, c) {
      ((o = o >>> 0), c || ae(o, 2, this.length));
      const _ = this[o] | (this[o + 1] << 8);
      return _ & 32768 ? _ | 4294901760 : _;
    }),
    (d.prototype.readInt16BE = function (o, c) {
      ((o = o >>> 0), c || ae(o, 2, this.length));
      const _ = this[o + 1] | (this[o] << 8);
      return _ & 32768 ? _ | 4294901760 : _;
    }),
    (d.prototype.readInt32LE = function (o, c) {
      return (
        (o = o >>> 0),
        c || ae(o, 4, this.length),
        this[o] | (this[o + 1] << 8) | (this[o + 2] << 16) | (this[o + 3] << 24)
      );
    }),
    (d.prototype.readInt32BE = function (o, c) {
      return (
        (o = o >>> 0),
        c || ae(o, 4, this.length),
        (this[o] << 24) | (this[o + 1] << 16) | (this[o + 2] << 8) | this[o + 3]
      );
    }),
    (d.prototype.readBigInt64LE = p(function (o) {
      ((o = o >>> 0), wt(o, "offset"));
      const c = this[o],
        _ = this[o + 7];
      (c === void 0 || _ === void 0) && xt(o, this.length - 8);
      const w =
        this[o + 4] + this[o + 5] * 2 ** 8 + this[o + 6] * 2 ** 16 + (_ << 24);
      return (
        (BigInt(w) << BigInt(32)) +
        BigInt(
          c + this[++o] * 2 ** 8 + this[++o] * 2 ** 16 + this[++o] * 2 ** 24,
        )
      );
    })),
    (d.prototype.readBigInt64BE = p(function (o) {
      ((o = o >>> 0), wt(o, "offset"));
      const c = this[o],
        _ = this[o + 7];
      (c === void 0 || _ === void 0) && xt(o, this.length - 8);
      const w =
        (c << 24) + this[++o] * 2 ** 16 + this[++o] * 2 ** 8 + this[++o];
      return (
        (BigInt(w) << BigInt(32)) +
        BigInt(
          this[++o] * 2 ** 24 + this[++o] * 2 ** 16 + this[++o] * 2 ** 8 + _,
        )
      );
    })),
    (d.prototype.readFloatLE = function (o, c) {
      return (
        (o = o >>> 0),
        c || ae(o, 4, this.length),
        t.read(this, o, !0, 23, 4)
      );
    }),
    (d.prototype.readFloatBE = function (o, c) {
      return (
        (o = o >>> 0),
        c || ae(o, 4, this.length),
        t.read(this, o, !1, 23, 4)
      );
    }),
    (d.prototype.readDoubleLE = function (o, c) {
      return (
        (o = o >>> 0),
        c || ae(o, 8, this.length),
        t.read(this, o, !0, 52, 8)
      );
    }),
    (d.prototype.readDoubleBE = function (o, c) {
      return (
        (o = o >>> 0),
        c || ae(o, 8, this.length),
        t.read(this, o, !1, 52, 8)
      );
    }));
  function le(a, o, c, _, w, B) {
    if (!d.isBuffer(a))
      throw new TypeError('"buffer" argument must be a Buffer instance');
    if (o > w || o < B)
      throw new RangeError('"value" argument is out of bounds');
    if (c + _ > a.length) throw new RangeError("Index out of range");
  }
  ((d.prototype.writeUintLE = d.prototype.writeUIntLE =
    function (o, c, _, w) {
      if (((o = +o), (c = c >>> 0), (_ = _ >>> 0), !w)) {
        const G = Math.pow(2, 8 * _) - 1;
        le(this, o, c, _, G, 0);
      }
      let B = 1,
        U = 0;
      for (this[c] = o & 255; ++U < _ && (B *= 256); )
        this[c + U] = (o / B) & 255;
      return c + _;
    }),
    (d.prototype.writeUintBE = d.prototype.writeUIntBE =
      function (o, c, _, w) {
        if (((o = +o), (c = c >>> 0), (_ = _ >>> 0), !w)) {
          const G = Math.pow(2, 8 * _) - 1;
          le(this, o, c, _, G, 0);
        }
        let B = _ - 1,
          U = 1;
        for (this[c + B] = o & 255; --B >= 0 && (U *= 256); )
          this[c + B] = (o / U) & 255;
        return c + _;
      }),
    (d.prototype.writeUint8 = d.prototype.writeUInt8 =
      function (o, c, _) {
        return (
          (o = +o),
          (c = c >>> 0),
          _ || le(this, o, c, 1, 255, 0),
          (this[c] = o & 255),
          c + 1
        );
      }),
    (d.prototype.writeUint16LE = d.prototype.writeUInt16LE =
      function (o, c, _) {
        return (
          (o = +o),
          (c = c >>> 0),
          _ || le(this, o, c, 2, 65535, 0),
          (this[c] = o & 255),
          (this[c + 1] = o >>> 8),
          c + 2
        );
      }),
    (d.prototype.writeUint16BE = d.prototype.writeUInt16BE =
      function (o, c, _) {
        return (
          (o = +o),
          (c = c >>> 0),
          _ || le(this, o, c, 2, 65535, 0),
          (this[c] = o >>> 8),
          (this[c + 1] = o & 255),
          c + 2
        );
      }),
    (d.prototype.writeUint32LE = d.prototype.writeUInt32LE =
      function (o, c, _) {
        return (
          (o = +o),
          (c = c >>> 0),
          _ || le(this, o, c, 4, 4294967295, 0),
          (this[c + 3] = o >>> 24),
          (this[c + 2] = o >>> 16),
          (this[c + 1] = o >>> 8),
          (this[c] = o & 255),
          c + 4
        );
      }),
    (d.prototype.writeUint32BE = d.prototype.writeUInt32BE =
      function (o, c, _) {
        return (
          (o = +o),
          (c = c >>> 0),
          _ || le(this, o, c, 4, 4294967295, 0),
          (this[c] = o >>> 24),
          (this[c + 1] = o >>> 16),
          (this[c + 2] = o >>> 8),
          (this[c + 3] = o & 255),
          c + 4
        );
      }));
  function tt(a, o, c, _, w) {
    pt(o, _, w, a, c, 7);
    let B = Number(o & BigInt(4294967295));
    ((a[c++] = B),
      (B = B >> 8),
      (a[c++] = B),
      (B = B >> 8),
      (a[c++] = B),
      (B = B >> 8),
      (a[c++] = B));
    let U = Number((o >> BigInt(32)) & BigInt(4294967295));
    return (
      (a[c++] = U),
      (U = U >> 8),
      (a[c++] = U),
      (U = U >> 8),
      (a[c++] = U),
      (U = U >> 8),
      (a[c++] = U),
      c
    );
  }
  function rt(a, o, c, _, w) {
    pt(o, _, w, a, c, 7);
    let B = Number(o & BigInt(4294967295));
    ((a[c + 7] = B),
      (B = B >> 8),
      (a[c + 6] = B),
      (B = B >> 8),
      (a[c + 5] = B),
      (B = B >> 8),
      (a[c + 4] = B));
    let U = Number((o >> BigInt(32)) & BigInt(4294967295));
    return (
      (a[c + 3] = U),
      (U = U >> 8),
      (a[c + 2] = U),
      (U = U >> 8),
      (a[c + 1] = U),
      (U = U >> 8),
      (a[c] = U),
      c + 8
    );
  }
  ((d.prototype.writeBigUInt64LE = p(function (o, c = 0) {
    return tt(this, o, c, BigInt(0), BigInt("0xffffffffffffffff"));
  })),
    (d.prototype.writeBigUInt64BE = p(function (o, c = 0) {
      return rt(this, o, c, BigInt(0), BigInt("0xffffffffffffffff"));
    })),
    (d.prototype.writeIntLE = function (o, c, _, w) {
      if (((o = +o), (c = c >>> 0), !w)) {
        const Q = Math.pow(2, 8 * _ - 1);
        le(this, o, c, _, Q - 1, -Q);
      }
      let B = 0,
        U = 1,
        G = 0;
      for (this[c] = o & 255; ++B < _ && (U *= 256); )
        (o < 0 && G === 0 && this[c + B - 1] !== 0 && (G = 1),
          (this[c + B] = (((o / U) >> 0) - G) & 255));
      return c + _;
    }),
    (d.prototype.writeIntBE = function (o, c, _, w) {
      if (((o = +o), (c = c >>> 0), !w)) {
        const Q = Math.pow(2, 8 * _ - 1);
        le(this, o, c, _, Q - 1, -Q);
      }
      let B = _ - 1,
        U = 1,
        G = 0;
      for (this[c + B] = o & 255; --B >= 0 && (U *= 256); )
        (o < 0 && G === 0 && this[c + B + 1] !== 0 && (G = 1),
          (this[c + B] = (((o / U) >> 0) - G) & 255));
      return c + _;
    }),
    (d.prototype.writeInt8 = function (o, c, _) {
      return (
        (o = +o),
        (c = c >>> 0),
        _ || le(this, o, c, 1, 127, -128),
        o < 0 && (o = 255 + o + 1),
        (this[c] = o & 255),
        c + 1
      );
    }),
    (d.prototype.writeInt16LE = function (o, c, _) {
      return (
        (o = +o),
        (c = c >>> 0),
        _ || le(this, o, c, 2, 32767, -32768),
        (this[c] = o & 255),
        (this[c + 1] = o >>> 8),
        c + 2
      );
    }),
    (d.prototype.writeInt16BE = function (o, c, _) {
      return (
        (o = +o),
        (c = c >>> 0),
        _ || le(this, o, c, 2, 32767, -32768),
        (this[c] = o >>> 8),
        (this[c + 1] = o & 255),
        c + 2
      );
    }),
    (d.prototype.writeInt32LE = function (o, c, _) {
      return (
        (o = +o),
        (c = c >>> 0),
        _ || le(this, o, c, 4, 2147483647, -2147483648),
        (this[c] = o & 255),
        (this[c + 1] = o >>> 8),
        (this[c + 2] = o >>> 16),
        (this[c + 3] = o >>> 24),
        c + 4
      );
    }),
    (d.prototype.writeInt32BE = function (o, c, _) {
      return (
        (o = +o),
        (c = c >>> 0),
        _ || le(this, o, c, 4, 2147483647, -2147483648),
        o < 0 && (o = 4294967295 + o + 1),
        (this[c] = o >>> 24),
        (this[c + 1] = o >>> 16),
        (this[c + 2] = o >>> 8),
        (this[c + 3] = o & 255),
        c + 4
      );
    }),
    (d.prototype.writeBigInt64LE = p(function (o, c = 0) {
      return tt(
        this,
        o,
        c,
        -BigInt("0x8000000000000000"),
        BigInt("0x7fffffffffffffff"),
      );
    })),
    (d.prototype.writeBigInt64BE = p(function (o, c = 0) {
      return rt(
        this,
        o,
        c,
        -BigInt("0x8000000000000000"),
        BigInt("0x7fffffffffffffff"),
      );
    })));
  function ut(a, o, c, _, w, B) {
    if (c + _ > a.length) throw new RangeError("Index out of range");
    if (c < 0) throw new RangeError("Index out of range");
  }
  function Le(a, o, c, _, w) {
    return (
      (o = +o),
      (c = c >>> 0),
      w || ut(a, o, c, 4),
      t.write(a, o, c, _, 23, 4),
      c + 4
    );
  }
  ((d.prototype.writeFloatLE = function (o, c, _) {
    return Le(this, o, c, !0, _);
  }),
    (d.prototype.writeFloatBE = function (o, c, _) {
      return Le(this, o, c, !1, _);
    }));
  function ft(a, o, c, _, w) {
    return (
      (o = +o),
      (c = c >>> 0),
      w || ut(a, o, c, 8),
      t.write(a, o, c, _, 52, 8),
      c + 8
    );
  }
  ((d.prototype.writeDoubleLE = function (o, c, _) {
    return ft(this, o, c, !0, _);
  }),
    (d.prototype.writeDoubleBE = function (o, c, _) {
      return ft(this, o, c, !1, _);
    }),
    (d.prototype.copy = function (o, c, _, w) {
      if (!d.isBuffer(o)) throw new TypeError("argument should be a Buffer");
      if (
        (_ || (_ = 0),
        !w && w !== 0 && (w = this.length),
        c >= o.length && (c = o.length),
        c || (c = 0),
        w > 0 && w < _ && (w = _),
        w === _ || o.length === 0 || this.length === 0)
      )
        return 0;
      if (c < 0) throw new RangeError("targetStart out of bounds");
      if (_ < 0 || _ >= this.length) throw new RangeError("Index out of range");
      if (w < 0) throw new RangeError("sourceEnd out of bounds");
      (w > this.length && (w = this.length),
        o.length - c < w - _ && (w = o.length - c + _));
      const B = w - _;
      return (
        this === o && typeof s.prototype.copyWithin == "function"
          ? this.copyWithin(c, _, w)
          : s.prototype.set.call(o, this.subarray(_, w), c),
        B
      );
    }),
    (d.prototype.fill = function (o, c, _, w) {
      if (typeof o == "string") {
        if (
          (typeof c == "string"
            ? ((w = c), (c = 0), (_ = this.length))
            : typeof _ == "string" && ((w = _), (_ = this.length)),
          w !== void 0 && typeof w != "string")
        )
          throw new TypeError("encoding must be a string");
        if (typeof w == "string" && !d.isEncoding(w))
          throw new TypeError("Unknown encoding: " + w);
        if (o.length === 1) {
          const U = o.charCodeAt(0);
          ((w === "utf8" && U < 128) || w === "latin1") && (o = U);
        }
      } else
        typeof o == "number"
          ? (o = o & 255)
          : typeof o == "boolean" && (o = Number(o));
      if (c < 0 || this.length < c || this.length < _)
        throw new RangeError("Out of range index");
      if (_ <= c) return this;
      ((c = c >>> 0), (_ = _ === void 0 ? this.length : _ >>> 0), o || (o = 0));
      let B;
      if (typeof o == "number") for (B = c; B < _; ++B) this[B] = o;
      else {
        const U = d.isBuffer(o) ? o : d.from(o, w),
          G = U.length;
        if (G === 0)
          throw new TypeError(
            'The value "' + o + '" is invalid for argument "value"',
          );
        for (B = 0; B < _ - c; ++B) this[B + c] = U[B % G];
      }
      return this;
    }));
  const ze = {};
  function ht(a, o, c) {
    ze[a] = class extends c {
      constructor() {
        (super(),
          Object.defineProperty(this, "message", {
            value: o.apply(this, arguments),
            writable: !0,
            configurable: !0,
          }),
          (this.name = `${this.name} [${a}]`),
          this.stack,
          delete this.name);
      }
      get code() {
        return a;
      }
      set code(w) {
        Object.defineProperty(this, "code", {
          configurable: !0,
          enumerable: !0,
          value: w,
          writable: !0,
        });
      }
      toString() {
        return `${this.name} [${a}]: ${this.message}`;
      }
    };
  }
  (ht(
    "ERR_BUFFER_OUT_OF_BOUNDS",
    function (a) {
      return a
        ? `${a} is outside of buffer bounds`
        : "Attempt to access memory outside buffer bounds";
    },
    RangeError,
  ),
    ht(
      "ERR_INVALID_ARG_TYPE",
      function (a, o) {
        return `The "${a}" argument must be of type number. Received type ${typeof o}`;
      },
      TypeError,
    ),
    ht(
      "ERR_OUT_OF_RANGE",
      function (a, o, c) {
        let _ = `The value of "${a}" is out of range.`,
          w = c;
        return (
          Number.isInteger(c) && Math.abs(c) > 2 ** 32
            ? (w = dt(String(c)))
            : typeof c == "bigint" &&
              ((w = String(c)),
              (c > BigInt(2) ** BigInt(32) || c < -(BigInt(2) ** BigInt(32))) &&
                (w = dt(w)),
              (w += "n")),
          (_ += ` It must be ${o}. Received ${w}`),
          _
        );
      },
      RangeError,
    ));
  function dt(a) {
    let o = "",
      c = a.length;
    const _ = a[0] === "-" ? 1 : 0;
    for (; c >= _ + 4; c -= 3) o = `_${a.slice(c - 3, c)}${o}`;
    return `${a.slice(0, c)}${o}`;
  }
  function _t(a, o, c) {
    (wt(o, "offset"),
      (a[o] === void 0 || a[o + c] === void 0) && xt(o, a.length - (c + 1)));
  }
  function pt(a, o, c, _, w, B) {
    if (a > c || a < o) {
      const U = typeof o == "bigint" ? "n" : "";
      let G;
      throw (
        o === 0 || o === BigInt(0)
          ? (G = `>= 0${U} and < 2${U} ** ${(B + 1) * 8}${U}`)
          : (G = `>= -(2${U} ** ${(B + 1) * 8 - 1}${U}) and < 2 ** ${(B + 1) * 8 - 1}${U}`),
        new ze.ERR_OUT_OF_RANGE("value", G, a)
      );
    }
    _t(_, w, B);
  }
  function wt(a, o) {
    if (typeof a != "number") throw new ze.ERR_INVALID_ARG_TYPE(o, "number", a);
  }
  function xt(a, o, c) {
    throw Math.floor(a) !== a
      ? (wt(a, c), new ze.ERR_OUT_OF_RANGE("offset", "an integer", a))
      : o < 0
        ? new ze.ERR_BUFFER_OUT_OF_BOUNDS()
        : new ze.ERR_OUT_OF_RANGE("offset", `>= 0 and <= ${o}`, a);
  }
  const dr = /[^+/0-9A-Za-z-_]/g;
  function zn(a) {
    if (((a = a.split("=")[0]), (a = a.trim().replace(dr, "")), a.length < 2))
      return "";
    for (; a.length % 4 !== 0; ) a = a + "=";
    return a;
  }
  function _r(a, o) {
    o = o || 1 / 0;
    let c;
    const _ = a.length;
    let w = null;
    const B = [];
    for (let U = 0; U < _; ++U) {
      if (((c = a.charCodeAt(U)), c > 55295 && c < 57344)) {
        if (!w) {
          if (c > 56319) {
            (o -= 3) > -1 && B.push(239, 191, 189);
            continue;
          } else if (U + 1 === _) {
            (o -= 3) > -1 && B.push(239, 191, 189);
            continue;
          }
          w = c;
          continue;
        }
        if (c < 56320) {
          ((o -= 3) > -1 && B.push(239, 191, 189), (w = c));
          continue;
        }
        c = (((w - 55296) << 10) | (c - 56320)) + 65536;
      } else w && (o -= 3) > -1 && B.push(239, 191, 189);
      if (((w = null), c < 128)) {
        if ((o -= 1) < 0) break;
        B.push(c);
      } else if (c < 2048) {
        if ((o -= 2) < 0) break;
        B.push((c >> 6) | 192, (c & 63) | 128);
      } else if (c < 65536) {
        if ((o -= 3) < 0) break;
        B.push((c >> 12) | 224, ((c >> 6) & 63) | 128, (c & 63) | 128);
      } else if (c < 1114112) {
        if ((o -= 4) < 0) break;
        B.push(
          (c >> 18) | 240,
          ((c >> 12) & 63) | 128,
          ((c >> 6) & 63) | 128,
          (c & 63) | 128,
        );
      } else throw new Error("Invalid code point");
    }
    return B;
  }
  function jr(a) {
    const o = [];
    for (let c = 0; c < a.length; ++c) o.push(a.charCodeAt(c) & 255);
    return o;
  }
  function Vt(a, o) {
    let c, _, w;
    const B = [];
    for (let U = 0; U < a.length && !((o -= 2) < 0); ++U)
      ((c = a.charCodeAt(U)),
        (_ = c >> 8),
        (w = c % 256),
        B.push(w),
        B.push(_));
    return B;
  }
  function Ce(a) {
    return r.toByteArray(zn(a));
  }
  function gt(a, o, c, _) {
    let w;
    for (w = 0; w < _ && !(w + c >= o.length || w >= a.length); ++w)
      o[w + c] = a[w];
    return w;
  }
  function Fe(a, o) {
    return (
      a instanceof o ||
      (a != null &&
        a.constructor != null &&
        a.constructor.name != null &&
        a.constructor.name === o.name)
    );
  }
  function Me(a) {
    return a !== a;
  }
  const Fn = (function () {
    const a = "0123456789abcdef",
      o = new Array(256);
    for (let c = 0; c < 16; ++c) {
      const _ = c * 16;
      for (let w = 0; w < 16; ++w) o[_ + w] = a[c] + a[w];
    }
    return o;
  })();
  function p(a) {
    return typeof BigInt > "u" ? f : a;
  }
  function f() {
    throw new Error("BigInt not supported");
  }
})(Jo);
const ia = Jo.Buffer;
function es(e) {
  if (typeof ia < "u") return ia.from(e, "base64");
  if (typeof atob == "function")
    return Uint8Array.from(atob(e), (r) => r.charCodeAt(0));
  throw new Error("No implementation found for base64 decoding.");
}
/*! pako 2.1.0 https://github.com/nodeca/pako @license (MIT AND Zlib) */ function lr(
  e,
) {
  let r = e.length;
  for (; --r >= 0; ) e[r] = 0;
}
const fl = 3,
  hl = 258,
  ts = 29,
  dl = 256,
  _l = dl + 1 + ts,
  rs = 30,
  pl = 512,
  wl = new Array((_l + 2) * 2);
lr(wl);
const gl = new Array(rs * 2);
lr(gl);
const yl = new Array(pl);
lr(yl);
const bl = new Array(hl - fl + 1);
lr(bl);
const ml = new Array(ts);
lr(ml);
const El = new Array(rs);
lr(El);
const kl = (e, r, t, n) => {
  let i = (e & 65535) | 0,
    s = ((e >>> 16) & 65535) | 0,
    l = 0;
  for (; t !== 0; ) {
    ((l = t > 2e3 ? 2e3 : t), (t -= l));
    do ((i = (i + r[n++]) | 0), (s = (s + i) | 0));
    while (--l);
    ((i %= 65521), (s %= 65521));
  }
  return i | (s << 16) | 0;
};
var gi = kl;
const Bl = () => {
    let e,
      r = [];
    for (var t = 0; t < 256; t++) {
      e = t;
      for (var n = 0; n < 8; n++) e = e & 1 ? 3988292384 ^ (e >>> 1) : e >>> 1;
      r[t] = e;
    }
    return r;
  },
  Sl = new Uint32Array(Bl()),
  Il = (e, r, t, n) => {
    const i = Sl,
      s = n + t;
    e ^= -1;
    for (let l = n; l < s; l++) e = (e >>> 8) ^ i[(e ^ r[l]) & 255];
    return e ^ -1;
  };
var Ge = Il,
  yi = {
    2: "need dictionary",
    1: "stream end",
    0: "",
    "-1": "file error",
    "-2": "stream error",
    "-3": "data error",
    "-4": "insufficient memory",
    "-5": "buffer error",
    "-6": "incompatible version",
  },
  ns = {
    Z_NO_FLUSH: 0,
    Z_FINISH: 4,
    Z_BLOCK: 5,
    Z_TREES: 6,
    Z_OK: 0,
    Z_STREAM_END: 1,
    Z_NEED_DICT: 2,
    Z_STREAM_ERROR: -2,
    Z_DATA_ERROR: -3,
    Z_MEM_ERROR: -4,
    Z_BUF_ERROR: -5,
    Z_DEFLATED: 8,
  };
const Al = (e, r) => Object.prototype.hasOwnProperty.call(e, r);
var vl = function (e) {
    const r = Array.prototype.slice.call(arguments, 1);
    for (; r.length; ) {
      const t = r.shift();
      if (t) {
        if (typeof t != "object") throw new TypeError(t + "must be non-object");
        for (const n in t) Al(t, n) && (e[n] = t[n]);
      }
    }
    return e;
  },
  xl = (e) => {
    let r = 0;
    for (let n = 0, i = e.length; n < i; n++) r += e[n].length;
    const t = new Uint8Array(r);
    for (let n = 0, i = 0, s = e.length; n < s; n++) {
      let l = e[n];
      (t.set(l, i), (i += l.length));
    }
    return t;
  },
  is = { assign: vl, flattenChunks: xl };
let as = !0;
try {
  String.fromCharCode.apply(null, new Uint8Array(1));
} catch {
  as = !1;
}
const Tr = new Uint8Array(256);
for (let e = 0; e < 256; e++)
  Tr[e] =
    e >= 252
      ? 6
      : e >= 248
        ? 5
        : e >= 240
          ? 4
          : e >= 224
            ? 3
            : e >= 192
              ? 2
              : 1;
Tr[254] = Tr[254] = 1;
var Tl = (e) => {
  if (typeof TextEncoder == "function" && TextEncoder.prototype.encode)
    return new TextEncoder().encode(e);
  let r,
    t,
    n,
    i,
    s,
    l = e.length,
    h = 0;
  for (i = 0; i < l; i++)
    ((t = e.charCodeAt(i)),
      (t & 64512) === 55296 &&
        i + 1 < l &&
        ((n = e.charCodeAt(i + 1)),
        (n & 64512) === 56320 &&
          ((t = 65536 + ((t - 55296) << 10) + (n - 56320)), i++)),
      (h += t < 128 ? 1 : t < 2048 ? 2 : t < 65536 ? 3 : 4));
  for (r = new Uint8Array(h), s = 0, i = 0; s < h; i++)
    ((t = e.charCodeAt(i)),
      (t & 64512) === 55296 &&
        i + 1 < l &&
        ((n = e.charCodeAt(i + 1)),
        (n & 64512) === 56320 &&
          ((t = 65536 + ((t - 55296) << 10) + (n - 56320)), i++)),
      t < 128
        ? (r[s++] = t)
        : t < 2048
          ? ((r[s++] = 192 | (t >>> 6)), (r[s++] = 128 | (t & 63)))
          : t < 65536
            ? ((r[s++] = 224 | (t >>> 12)),
              (r[s++] = 128 | ((t >>> 6) & 63)),
              (r[s++] = 128 | (t & 63)))
            : ((r[s++] = 240 | (t >>> 18)),
              (r[s++] = 128 | ((t >>> 12) & 63)),
              (r[s++] = 128 | ((t >>> 6) & 63)),
              (r[s++] = 128 | (t & 63))));
  return r;
};
const Ul = (e, r) => {
  if (r < 65534 && e.subarray && as)
    return String.fromCharCode.apply(
      null,
      e.length === r ? e : e.subarray(0, r),
    );
  let t = "";
  for (let n = 0; n < r; n++) t += String.fromCharCode(e[n]);
  return t;
};
var Rl = (e, r) => {
    const t = r || e.length;
    if (typeof TextDecoder == "function" && TextDecoder.prototype.decode)
      return new TextDecoder().decode(e.subarray(0, r));
    let n, i;
    const s = new Array(t * 2);
    for (i = 0, n = 0; n < t; ) {
      let l = e[n++];
      if (l < 128) {
        s[i++] = l;
        continue;
      }
      let h = Tr[l];
      if (h > 4) {
        ((s[i++] = 65533), (n += h - 1));
        continue;
      }
      for (l &= h === 2 ? 31 : h === 3 ? 15 : 7; h > 1 && n < t; )
        ((l = (l << 6) | (e[n++] & 63)), h--);
      if (h > 1) {
        s[i++] = 65533;
        continue;
      }
      l < 65536
        ? (s[i++] = l)
        : ((l -= 65536),
          (s[i++] = 55296 | ((l >> 10) & 1023)),
          (s[i++] = 56320 | (l & 1023)));
    }
    return Ul(s, i);
  },
  Cl = (e, r) => {
    ((r = r || e.length), r > e.length && (r = e.length));
    let t = r - 1;
    for (; t >= 0 && (e[t] & 192) === 128; ) t--;
    return t < 0 || t === 0 ? r : t + Tr[e[t]] > r ? t : r;
  },
  bi = { string2buf: Tl, buf2string: Rl, utf8border: Cl };
function Dl() {
  ((this.input = null),
    (this.next_in = 0),
    (this.avail_in = 0),
    (this.total_in = 0),
    (this.output = null),
    (this.next_out = 0),
    (this.avail_out = 0),
    (this.total_out = 0),
    (this.msg = ""),
    (this.state = null),
    (this.data_type = 2),
    (this.adler = 0));
}
var Nl = Dl;
const Xr = 16209,
  Ol = 16191;
var $l = function (r, t) {
  let n, i, s, l, h, g, u, d, E, b, y, I, x, T, R, $, D, m, z, V, C, H, M, N;
  const F = r.state;
  ((n = r.next_in),
    (M = r.input),
    (i = n + (r.avail_in - 5)),
    (s = r.next_out),
    (N = r.output),
    (l = s - (t - r.avail_out)),
    (h = s + (r.avail_out - 257)),
    (g = F.dmax),
    (u = F.wsize),
    (d = F.whave),
    (E = F.wnext),
    (b = F.window),
    (y = F.hold),
    (I = F.bits),
    (x = F.lencode),
    (T = F.distcode),
    (R = (1 << F.lenbits) - 1),
    ($ = (1 << F.distbits) - 1));
  e: do {
    (I < 15 && ((y += M[n++] << I), (I += 8), (y += M[n++] << I), (I += 8)),
      (D = x[y & R]));
    t: for (;;) {
      if (
        ((m = D >>> 24), (y >>>= m), (I -= m), (m = (D >>> 16) & 255), m === 0)
      )
        N[s++] = D & 65535;
      else if (m & 16) {
        ((z = D & 65535),
          (m &= 15),
          m &&
            (I < m && ((y += M[n++] << I), (I += 8)),
            (z += y & ((1 << m) - 1)),
            (y >>>= m),
            (I -= m)),
          I < 15 &&
            ((y += M[n++] << I), (I += 8), (y += M[n++] << I), (I += 8)),
          (D = T[y & $]));
        r: for (;;) {
          if (
            ((m = D >>> 24),
            (y >>>= m),
            (I -= m),
            (m = (D >>> 16) & 255),
            m & 16)
          ) {
            if (
              ((V = D & 65535),
              (m &= 15),
              I < m &&
                ((y += M[n++] << I),
                (I += 8),
                I < m && ((y += M[n++] << I), (I += 8))),
              (V += y & ((1 << m) - 1)),
              V > g)
            ) {
              ((r.msg = "invalid distance too far back"), (F.mode = Xr));
              break e;
            }
            if (((y >>>= m), (I -= m), (m = s - l), V > m)) {
              if (((m = V - m), m > d && F.sane)) {
                ((r.msg = "invalid distance too far back"), (F.mode = Xr));
                break e;
              }
              if (((C = 0), (H = b), E === 0)) {
                if (((C += u - m), m < z)) {
                  z -= m;
                  do N[s++] = b[C++];
                  while (--m);
                  ((C = s - V), (H = N));
                }
              } else if (E < m) {
                if (((C += u + E - m), (m -= E), m < z)) {
                  z -= m;
                  do N[s++] = b[C++];
                  while (--m);
                  if (((C = 0), E < z)) {
                    ((m = E), (z -= m));
                    do N[s++] = b[C++];
                    while (--m);
                    ((C = s - V), (H = N));
                  }
                }
              } else if (((C += E - m), m < z)) {
                z -= m;
                do N[s++] = b[C++];
                while (--m);
                ((C = s - V), (H = N));
              }
              for (; z > 2; )
                ((N[s++] = H[C++]),
                  (N[s++] = H[C++]),
                  (N[s++] = H[C++]),
                  (z -= 3));
              z && ((N[s++] = H[C++]), z > 1 && (N[s++] = H[C++]));
            } else {
              C = s - V;
              do
                ((N[s++] = N[C++]),
                  (N[s++] = N[C++]),
                  (N[s++] = N[C++]),
                  (z -= 3));
              while (z > 2);
              z && ((N[s++] = N[C++]), z > 1 && (N[s++] = N[C++]));
            }
          } else if ((m & 64) === 0) {
            D = T[(D & 65535) + (y & ((1 << m) - 1))];
            continue r;
          } else {
            ((r.msg = "invalid distance code"), (F.mode = Xr));
            break e;
          }
          break;
        }
      } else if ((m & 64) === 0) {
        D = x[(D & 65535) + (y & ((1 << m) - 1))];
        continue t;
      } else if (m & 32) {
        F.mode = Ol;
        break e;
      } else {
        ((r.msg = "invalid literal/length code"), (F.mode = Xr));
        break e;
      }
      break;
    }
  } while (n < i && s < h);
  ((z = I >> 3),
    (n -= z),
    (I -= z << 3),
    (y &= (1 << I) - 1),
    (r.next_in = n),
    (r.next_out = s),
    (r.avail_in = n < i ? 5 + (i - n) : 5 - (n - i)),
    (r.avail_out = s < h ? 257 + (h - s) : 257 - (s - h)),
    (F.hold = y),
    (F.bits = I));
};
const Xt = 15,
  aa = 852,
  oa = 592,
  sa = 0,
  Zn = 1,
  ca = 2,
  Ll = new Uint16Array([
    3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 19, 23, 27, 31, 35, 43, 51, 59, 67,
    83, 99, 115, 131, 163, 195, 227, 258, 0, 0,
  ]),
  zl = new Uint8Array([
    16, 16, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19,
    19, 20, 20, 20, 20, 21, 21, 21, 21, 16, 72, 78,
  ]),
  Fl = new Uint16Array([
    1, 2, 3, 4, 5, 7, 9, 13, 17, 25, 33, 49, 65, 97, 129, 193, 257, 385, 513,
    769, 1025, 1537, 2049, 3073, 4097, 6145, 8193, 12289, 16385, 24577, 0, 0,
  ]),
  Ml = new Uint8Array([
    16, 16, 16, 16, 17, 17, 18, 18, 19, 19, 20, 20, 21, 21, 22, 22, 23, 23, 24,
    24, 25, 25, 26, 26, 27, 27, 28, 28, 29, 29, 64, 64,
  ]),
  Pl = (e, r, t, n, i, s, l, h) => {
    const g = h.bits;
    let u = 0,
      d = 0,
      E = 0,
      b = 0,
      y = 0,
      I = 0,
      x = 0,
      T = 0,
      R = 0,
      $ = 0,
      D,
      m,
      z,
      V,
      C,
      H = null,
      M;
    const N = new Uint16Array(Xt + 1),
      F = new Uint16Array(Xt + 1);
    let se = null,
      A,
      P,
      L;
    for (u = 0; u <= Xt; u++) N[u] = 0;
    for (d = 0; d < n; d++) N[r[t + d]]++;
    for (y = g, b = Xt; b >= 1 && N[b] === 0; b--);
    if ((y > b && (y = b), b === 0))
      return (
        (i[s++] = (1 << 24) | (64 << 16) | 0),
        (i[s++] = (1 << 24) | (64 << 16) | 0),
        (h.bits = 1),
        0
      );
    for (E = 1; E < b && N[E] === 0; E++);
    for (y < E && (y = E), T = 1, u = 1; u <= Xt; u++)
      if (((T <<= 1), (T -= N[u]), T < 0)) return -1;
    if (T > 0 && (e === sa || b !== 1)) return -1;
    for (F[1] = 0, u = 1; u < Xt; u++) F[u + 1] = F[u] + N[u];
    for (d = 0; d < n; d++) r[t + d] !== 0 && (l[F[r[t + d]]++] = d);
    if (
      (e === sa
        ? ((H = se = l), (M = 20))
        : e === Zn
          ? ((H = Ll), (se = zl), (M = 257))
          : ((H = Fl), (se = Ml), (M = 0)),
      ($ = 0),
      (d = 0),
      (u = E),
      (C = s),
      (I = y),
      (x = 0),
      (z = -1),
      (R = 1 << y),
      (V = R - 1),
      (e === Zn && R > aa) || (e === ca && R > oa))
    )
      return 1;
    for (;;) {
      ((A = u - x),
        l[d] + 1 < M
          ? ((P = 0), (L = l[d]))
          : l[d] >= M
            ? ((P = se[l[d] - M]), (L = H[l[d] - M]))
            : ((P = 96), (L = 0)),
        (D = 1 << (u - x)),
        (m = 1 << I),
        (E = m));
      do ((m -= D), (i[C + ($ >> x) + m] = (A << 24) | (P << 16) | L | 0));
      while (m !== 0);
      for (D = 1 << (u - 1); $ & D; ) D >>= 1;
      if ((D !== 0 ? (($ &= D - 1), ($ += D)) : ($ = 0), d++, --N[u] === 0)) {
        if (u === b) break;
        u = r[t + l[d]];
      }
      if (u > y && ($ & V) !== z) {
        for (
          x === 0 && (x = y), C += E, I = u - x, T = 1 << I;
          I + x < b && ((T -= N[I + x]), !(T <= 0));
        )
          (I++, (T <<= 1));
        if (((R += 1 << I), (e === Zn && R > aa) || (e === ca && R > oa)))
          return 1;
        ((z = $ & V), (i[z] = (y << 24) | (I << 16) | (C - s) | 0));
      }
    }
    return (
      $ !== 0 && (i[C + $] = ((u - x) << 24) | (64 << 16) | 0),
      (h.bits = y),
      0
    );
  };
var kr = Pl;
const Zl = 0,
  os = 1,
  ss = 2,
  {
    Z_FINISH: la,
    Z_BLOCK: Hl,
    Z_TREES: qr,
    Z_OK: zt,
    Z_STREAM_END: Wl,
    Z_NEED_DICT: Vl,
    Z_STREAM_ERROR: We,
    Z_DATA_ERROR: cs,
    Z_MEM_ERROR: ls,
    Z_BUF_ERROR: Yl,
    Z_DEFLATED: ua,
  } = ns,
  Tn = 16180,
  fa = 16181,
  ha = 16182,
  da = 16183,
  _a = 16184,
  pa = 16185,
  wa = 16186,
  ga = 16187,
  ya = 16188,
  ba = 16189,
  bn = 16190,
  nt = 16191,
  Hn = 16192,
  ma = 16193,
  Wn = 16194,
  Ea = 16195,
  ka = 16196,
  Ba = 16197,
  Sa = 16198,
  Jr = 16199,
  Qr = 16200,
  Ia = 16201,
  Aa = 16202,
  va = 16203,
  xa = 16204,
  Ta = 16205,
  Vn = 16206,
  Ua = 16207,
  Ra = 16208,
  pe = 16209,
  us = 16210,
  fs = 16211,
  Gl = 852,
  jl = 592,
  Kl = 15,
  Xl = Kl,
  Ca = (e) =>
    ((e >>> 24) & 255) +
    ((e >>> 8) & 65280) +
    ((e & 65280) << 8) +
    ((e & 255) << 24);
function ql() {
  ((this.strm = null),
    (this.mode = 0),
    (this.last = !1),
    (this.wrap = 0),
    (this.havedict = !1),
    (this.flags = 0),
    (this.dmax = 0),
    (this.check = 0),
    (this.total = 0),
    (this.head = null),
    (this.wbits = 0),
    (this.wsize = 0),
    (this.whave = 0),
    (this.wnext = 0),
    (this.window = null),
    (this.hold = 0),
    (this.bits = 0),
    (this.length = 0),
    (this.offset = 0),
    (this.extra = 0),
    (this.lencode = null),
    (this.distcode = null),
    (this.lenbits = 0),
    (this.distbits = 0),
    (this.ncode = 0),
    (this.nlen = 0),
    (this.ndist = 0),
    (this.have = 0),
    (this.next = null),
    (this.lens = new Uint16Array(320)),
    (this.work = new Uint16Array(288)),
    (this.lendyn = null),
    (this.distdyn = null),
    (this.sane = 0),
    (this.back = 0),
    (this.was = 0));
}
const Ht = (e) => {
    if (!e) return 1;
    const r = e.state;
    return !r || r.strm !== e || r.mode < Tn || r.mode > fs ? 1 : 0;
  },
  hs = (e) => {
    if (Ht(e)) return We;
    const r = e.state;
    return (
      (e.total_in = e.total_out = r.total = 0),
      (e.msg = ""),
      r.wrap && (e.adler = r.wrap & 1),
      (r.mode = Tn),
      (r.last = 0),
      (r.havedict = 0),
      (r.flags = -1),
      (r.dmax = 32768),
      (r.head = null),
      (r.hold = 0),
      (r.bits = 0),
      (r.lencode = r.lendyn = new Int32Array(Gl)),
      (r.distcode = r.distdyn = new Int32Array(jl)),
      (r.sane = 1),
      (r.back = -1),
      zt
    );
  },
  ds = (e) => {
    if (Ht(e)) return We;
    const r = e.state;
    return ((r.wsize = 0), (r.whave = 0), (r.wnext = 0), hs(e));
  },
  _s = (e, r) => {
    let t;
    if (Ht(e)) return We;
    const n = e.state;
    return (
      r < 0 ? ((t = 0), (r = -r)) : ((t = (r >> 4) + 5), r < 48 && (r &= 15)),
      r && (r < 8 || r > 15)
        ? We
        : (n.window !== null && n.wbits !== r && (n.window = null),
          (n.wrap = t),
          (n.wbits = r),
          ds(e))
    );
  },
  ps = (e, r) => {
    if (!e) return We;
    const t = new ql();
    ((e.state = t), (t.strm = e), (t.window = null), (t.mode = Tn));
    const n = _s(e, r);
    return (n !== zt && (e.state = null), n);
  },
  Jl = (e) => ps(e, Xl);
let Da = !0,
  Yn,
  Gn;
const Ql = (e) => {
    if (Da) {
      ((Yn = new Int32Array(512)), (Gn = new Int32Array(32)));
      let r = 0;
      for (; r < 144; ) e.lens[r++] = 8;
      for (; r < 256; ) e.lens[r++] = 9;
      for (; r < 280; ) e.lens[r++] = 7;
      for (; r < 288; ) e.lens[r++] = 8;
      for (kr(os, e.lens, 0, 288, Yn, 0, e.work, { bits: 9 }), r = 0; r < 32; )
        e.lens[r++] = 5;
      (kr(ss, e.lens, 0, 32, Gn, 0, e.work, { bits: 5 }), (Da = !1));
    }
    ((e.lencode = Yn), (e.lenbits = 9), (e.distcode = Gn), (e.distbits = 5));
  },
  ws = (e, r, t, n) => {
    let i;
    const s = e.state;
    return (
      s.window === null &&
        ((s.wsize = 1 << s.wbits),
        (s.wnext = 0),
        (s.whave = 0),
        (s.window = new Uint8Array(s.wsize))),
      n >= s.wsize
        ? (s.window.set(r.subarray(t - s.wsize, t), 0),
          (s.wnext = 0),
          (s.whave = s.wsize))
        : ((i = s.wsize - s.wnext),
          i > n && (i = n),
          s.window.set(r.subarray(t - n, t - n + i), s.wnext),
          (n -= i),
          n
            ? (s.window.set(r.subarray(t - n, t), 0),
              (s.wnext = n),
              (s.whave = s.wsize))
            : ((s.wnext += i),
              s.wnext === s.wsize && (s.wnext = 0),
              s.whave < s.wsize && (s.whave += i))),
      0
    );
  },
  eu = (e, r) => {
    let t,
      n,
      i,
      s,
      l,
      h,
      g,
      u,
      d,
      E,
      b,
      y,
      I,
      x,
      T = 0,
      R,
      $,
      D,
      m,
      z,
      V,
      C,
      H;
    const M = new Uint8Array(4);
    let N, F;
    const se = new Uint8Array([
      16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15,
    ]);
    if (Ht(e) || !e.output || (!e.input && e.avail_in !== 0)) return We;
    ((t = e.state),
      t.mode === nt && (t.mode = Hn),
      (l = e.next_out),
      (i = e.output),
      (g = e.avail_out),
      (s = e.next_in),
      (n = e.input),
      (h = e.avail_in),
      (u = t.hold),
      (d = t.bits),
      (E = h),
      (b = g),
      (H = zt));
    e: for (;;)
      switch (t.mode) {
        case Tn:
          if (t.wrap === 0) {
            t.mode = Hn;
            break;
          }
          for (; d < 16; ) {
            if (h === 0) break e;
            (h--, (u += n[s++] << d), (d += 8));
          }
          if (t.wrap & 2 && u === 35615) {
            (t.wbits === 0 && (t.wbits = 15),
              (t.check = 0),
              (M[0] = u & 255),
              (M[1] = (u >>> 8) & 255),
              (t.check = Ge(t.check, M, 2, 0)),
              (u = 0),
              (d = 0),
              (t.mode = fa));
            break;
          }
          if (
            (t.head && (t.head.done = !1),
            !(t.wrap & 1) || (((u & 255) << 8) + (u >> 8)) % 31)
          ) {
            ((e.msg = "incorrect header check"), (t.mode = pe));
            break;
          }
          if ((u & 15) !== ua) {
            ((e.msg = "unknown compression method"), (t.mode = pe));
            break;
          }
          if (
            ((u >>>= 4),
            (d -= 4),
            (C = (u & 15) + 8),
            t.wbits === 0 && (t.wbits = C),
            C > 15 || C > t.wbits)
          ) {
            ((e.msg = "invalid window size"), (t.mode = pe));
            break;
          }
          ((t.dmax = 1 << t.wbits),
            (t.flags = 0),
            (e.adler = t.check = 1),
            (t.mode = u & 512 ? ba : nt),
            (u = 0),
            (d = 0));
          break;
        case fa:
          for (; d < 16; ) {
            if (h === 0) break e;
            (h--, (u += n[s++] << d), (d += 8));
          }
          if (((t.flags = u), (t.flags & 255) !== ua)) {
            ((e.msg = "unknown compression method"), (t.mode = pe));
            break;
          }
          if (t.flags & 57344) {
            ((e.msg = "unknown header flags set"), (t.mode = pe));
            break;
          }
          (t.head && (t.head.text = (u >> 8) & 1),
            t.flags & 512 &&
              t.wrap & 4 &&
              ((M[0] = u & 255),
              (M[1] = (u >>> 8) & 255),
              (t.check = Ge(t.check, M, 2, 0))),
            (u = 0),
            (d = 0),
            (t.mode = ha));
        case ha:
          for (; d < 32; ) {
            if (h === 0) break e;
            (h--, (u += n[s++] << d), (d += 8));
          }
          (t.head && (t.head.time = u),
            t.flags & 512 &&
              t.wrap & 4 &&
              ((M[0] = u & 255),
              (M[1] = (u >>> 8) & 255),
              (M[2] = (u >>> 16) & 255),
              (M[3] = (u >>> 24) & 255),
              (t.check = Ge(t.check, M, 4, 0))),
            (u = 0),
            (d = 0),
            (t.mode = da));
        case da:
          for (; d < 16; ) {
            if (h === 0) break e;
            (h--, (u += n[s++] << d), (d += 8));
          }
          (t.head && ((t.head.xflags = u & 255), (t.head.os = u >> 8)),
            t.flags & 512 &&
              t.wrap & 4 &&
              ((M[0] = u & 255),
              (M[1] = (u >>> 8) & 255),
              (t.check = Ge(t.check, M, 2, 0))),
            (u = 0),
            (d = 0),
            (t.mode = _a));
        case _a:
          if (t.flags & 1024) {
            for (; d < 16; ) {
              if (h === 0) break e;
              (h--, (u += n[s++] << d), (d += 8));
            }
            ((t.length = u),
              t.head && (t.head.extra_len = u),
              t.flags & 512 &&
                t.wrap & 4 &&
                ((M[0] = u & 255),
                (M[1] = (u >>> 8) & 255),
                (t.check = Ge(t.check, M, 2, 0))),
              (u = 0),
              (d = 0));
          } else t.head && (t.head.extra = null);
          t.mode = pa;
        case pa:
          if (
            t.flags & 1024 &&
            ((y = t.length),
            y > h && (y = h),
            y &&
              (t.head &&
                ((C = t.head.extra_len - t.length),
                t.head.extra ||
                  (t.head.extra = new Uint8Array(t.head.extra_len)),
                t.head.extra.set(n.subarray(s, s + y), C)),
              t.flags & 512 && t.wrap & 4 && (t.check = Ge(t.check, n, y, s)),
              (h -= y),
              (s += y),
              (t.length -= y)),
            t.length)
          )
            break e;
          ((t.length = 0), (t.mode = wa));
        case wa:
          if (t.flags & 2048) {
            if (h === 0) break e;
            y = 0;
            do
              ((C = n[s + y++]),
                t.head &&
                  C &&
                  t.length < 65536 &&
                  (t.head.name += String.fromCharCode(C)));
            while (C && y < h);
            if (
              (t.flags & 512 && t.wrap & 4 && (t.check = Ge(t.check, n, y, s)),
              (h -= y),
              (s += y),
              C)
            )
              break e;
          } else t.head && (t.head.name = null);
          ((t.length = 0), (t.mode = ga));
        case ga:
          if (t.flags & 4096) {
            if (h === 0) break e;
            y = 0;
            do
              ((C = n[s + y++]),
                t.head &&
                  C &&
                  t.length < 65536 &&
                  (t.head.comment += String.fromCharCode(C)));
            while (C && y < h);
            if (
              (t.flags & 512 && t.wrap & 4 && (t.check = Ge(t.check, n, y, s)),
              (h -= y),
              (s += y),
              C)
            )
              break e;
          } else t.head && (t.head.comment = null);
          t.mode = ya;
        case ya:
          if (t.flags & 512) {
            for (; d < 16; ) {
              if (h === 0) break e;
              (h--, (u += n[s++] << d), (d += 8));
            }
            if (t.wrap & 4 && u !== (t.check & 65535)) {
              ((e.msg = "header crc mismatch"), (t.mode = pe));
              break;
            }
            ((u = 0), (d = 0));
          }
          (t.head && ((t.head.hcrc = (t.flags >> 9) & 1), (t.head.done = !0)),
            (e.adler = t.check = 0),
            (t.mode = nt));
          break;
        case ba:
          for (; d < 32; ) {
            if (h === 0) break e;
            (h--, (u += n[s++] << d), (d += 8));
          }
          ((e.adler = t.check = Ca(u)), (u = 0), (d = 0), (t.mode = bn));
        case bn:
          if (t.havedict === 0)
            return (
              (e.next_out = l),
              (e.avail_out = g),
              (e.next_in = s),
              (e.avail_in = h),
              (t.hold = u),
              (t.bits = d),
              Vl
            );
          ((e.adler = t.check = 1), (t.mode = nt));
        case nt:
          if (r === Hl || r === qr) break e;
        case Hn:
          if (t.last) {
            ((u >>>= d & 7), (d -= d & 7), (t.mode = Vn));
            break;
          }
          for (; d < 3; ) {
            if (h === 0) break e;
            (h--, (u += n[s++] << d), (d += 8));
          }
          switch (((t.last = u & 1), (u >>>= 1), (d -= 1), u & 3)) {
            case 0:
              t.mode = ma;
              break;
            case 1:
              if ((Ql(t), (t.mode = Jr), r === qr)) {
                ((u >>>= 2), (d -= 2));
                break e;
              }
              break;
            case 2:
              t.mode = ka;
              break;
            case 3:
              ((e.msg = "invalid block type"), (t.mode = pe));
          }
          ((u >>>= 2), (d -= 2));
          break;
        case ma:
          for (u >>>= d & 7, d -= d & 7; d < 32; ) {
            if (h === 0) break e;
            (h--, (u += n[s++] << d), (d += 8));
          }
          if ((u & 65535) !== ((u >>> 16) ^ 65535)) {
            ((e.msg = "invalid stored block lengths"), (t.mode = pe));
            break;
          }
          if (
            ((t.length = u & 65535), (u = 0), (d = 0), (t.mode = Wn), r === qr)
          )
            break e;
        case Wn:
          t.mode = Ea;
        case Ea:
          if (((y = t.length), y)) {
            if ((y > h && (y = h), y > g && (y = g), y === 0)) break e;
            (i.set(n.subarray(s, s + y), l),
              (h -= y),
              (s += y),
              (g -= y),
              (l += y),
              (t.length -= y));
            break;
          }
          t.mode = nt;
          break;
        case ka:
          for (; d < 14; ) {
            if (h === 0) break e;
            (h--, (u += n[s++] << d), (d += 8));
          }
          if (
            ((t.nlen = (u & 31) + 257),
            (u >>>= 5),
            (d -= 5),
            (t.ndist = (u & 31) + 1),
            (u >>>= 5),
            (d -= 5),
            (t.ncode = (u & 15) + 4),
            (u >>>= 4),
            (d -= 4),
            t.nlen > 286 || t.ndist > 30)
          ) {
            ((e.msg = "too many length or distance symbols"), (t.mode = pe));
            break;
          }
          ((t.have = 0), (t.mode = Ba));
        case Ba:
          for (; t.have < t.ncode; ) {
            for (; d < 3; ) {
              if (h === 0) break e;
              (h--, (u += n[s++] << d), (d += 8));
            }
            ((t.lens[se[t.have++]] = u & 7), (u >>>= 3), (d -= 3));
          }
          for (; t.have < 19; ) t.lens[se[t.have++]] = 0;
          if (
            ((t.lencode = t.lendyn),
            (t.lenbits = 7),
            (N = { bits: t.lenbits }),
            (H = kr(Zl, t.lens, 0, 19, t.lencode, 0, t.work, N)),
            (t.lenbits = N.bits),
            H)
          ) {
            ((e.msg = "invalid code lengths set"), (t.mode = pe));
            break;
          }
          ((t.have = 0), (t.mode = Sa));
        case Sa:
          for (; t.have < t.nlen + t.ndist; ) {
            for (
              ;
              (T = t.lencode[u & ((1 << t.lenbits) - 1)]),
                (R = T >>> 24),
                ($ = (T >>> 16) & 255),
                (D = T & 65535),
                !(R <= d);
            ) {
              if (h === 0) break e;
              (h--, (u += n[s++] << d), (d += 8));
            }
            if (D < 16) ((u >>>= R), (d -= R), (t.lens[t.have++] = D));
            else {
              if (D === 16) {
                for (F = R + 2; d < F; ) {
                  if (h === 0) break e;
                  (h--, (u += n[s++] << d), (d += 8));
                }
                if (((u >>>= R), (d -= R), t.have === 0)) {
                  ((e.msg = "invalid bit length repeat"), (t.mode = pe));
                  break;
                }
                ((C = t.lens[t.have - 1]),
                  (y = 3 + (u & 3)),
                  (u >>>= 2),
                  (d -= 2));
              } else if (D === 17) {
                for (F = R + 3; d < F; ) {
                  if (h === 0) break e;
                  (h--, (u += n[s++] << d), (d += 8));
                }
                ((u >>>= R),
                  (d -= R),
                  (C = 0),
                  (y = 3 + (u & 7)),
                  (u >>>= 3),
                  (d -= 3));
              } else {
                for (F = R + 7; d < F; ) {
                  if (h === 0) break e;
                  (h--, (u += n[s++] << d), (d += 8));
                }
                ((u >>>= R),
                  (d -= R),
                  (C = 0),
                  (y = 11 + (u & 127)),
                  (u >>>= 7),
                  (d -= 7));
              }
              if (t.have + y > t.nlen + t.ndist) {
                ((e.msg = "invalid bit length repeat"), (t.mode = pe));
                break;
              }
              for (; y--; ) t.lens[t.have++] = C;
            }
          }
          if (t.mode === pe) break;
          if (t.lens[256] === 0) {
            ((e.msg = "invalid code -- missing end-of-block"), (t.mode = pe));
            break;
          }
          if (
            ((t.lenbits = 9),
            (N = { bits: t.lenbits }),
            (H = kr(os, t.lens, 0, t.nlen, t.lencode, 0, t.work, N)),
            (t.lenbits = N.bits),
            H)
          ) {
            ((e.msg = "invalid literal/lengths set"), (t.mode = pe));
            break;
          }
          if (
            ((t.distbits = 6),
            (t.distcode = t.distdyn),
            (N = { bits: t.distbits }),
            (H = kr(ss, t.lens, t.nlen, t.ndist, t.distcode, 0, t.work, N)),
            (t.distbits = N.bits),
            H)
          ) {
            ((e.msg = "invalid distances set"), (t.mode = pe));
            break;
          }
          if (((t.mode = Jr), r === qr)) break e;
        case Jr:
          t.mode = Qr;
        case Qr:
          if (h >= 6 && g >= 258) {
            ((e.next_out = l),
              (e.avail_out = g),
              (e.next_in = s),
              (e.avail_in = h),
              (t.hold = u),
              (t.bits = d),
              $l(e, b),
              (l = e.next_out),
              (i = e.output),
              (g = e.avail_out),
              (s = e.next_in),
              (n = e.input),
              (h = e.avail_in),
              (u = t.hold),
              (d = t.bits),
              t.mode === nt && (t.back = -1));
            break;
          }
          for (
            t.back = 0;
            (T = t.lencode[u & ((1 << t.lenbits) - 1)]),
              (R = T >>> 24),
              ($ = (T >>> 16) & 255),
              (D = T & 65535),
              !(R <= d);
          ) {
            if (h === 0) break e;
            (h--, (u += n[s++] << d), (d += 8));
          }
          if ($ && ($ & 240) === 0) {
            for (
              m = R, z = $, V = D;
              (T = t.lencode[V + ((u & ((1 << (m + z)) - 1)) >> m)]),
                (R = T >>> 24),
                ($ = (T >>> 16) & 255),
                (D = T & 65535),
                !(m + R <= d);
            ) {
              if (h === 0) break e;
              (h--, (u += n[s++] << d), (d += 8));
            }
            ((u >>>= m), (d -= m), (t.back += m));
          }
          if (((u >>>= R), (d -= R), (t.back += R), (t.length = D), $ === 0)) {
            t.mode = Ta;
            break;
          }
          if ($ & 32) {
            ((t.back = -1), (t.mode = nt));
            break;
          }
          if ($ & 64) {
            ((e.msg = "invalid literal/length code"), (t.mode = pe));
            break;
          }
          ((t.extra = $ & 15), (t.mode = Ia));
        case Ia:
          if (t.extra) {
            for (F = t.extra; d < F; ) {
              if (h === 0) break e;
              (h--, (u += n[s++] << d), (d += 8));
            }
            ((t.length += u & ((1 << t.extra) - 1)),
              (u >>>= t.extra),
              (d -= t.extra),
              (t.back += t.extra));
          }
          ((t.was = t.length), (t.mode = Aa));
        case Aa:
          for (
            ;
            (T = t.distcode[u & ((1 << t.distbits) - 1)]),
              (R = T >>> 24),
              ($ = (T >>> 16) & 255),
              (D = T & 65535),
              !(R <= d);
          ) {
            if (h === 0) break e;
            (h--, (u += n[s++] << d), (d += 8));
          }
          if (($ & 240) === 0) {
            for (
              m = R, z = $, V = D;
              (T = t.distcode[V + ((u & ((1 << (m + z)) - 1)) >> m)]),
                (R = T >>> 24),
                ($ = (T >>> 16) & 255),
                (D = T & 65535),
                !(m + R <= d);
            ) {
              if (h === 0) break e;
              (h--, (u += n[s++] << d), (d += 8));
            }
            ((u >>>= m), (d -= m), (t.back += m));
          }
          if (((u >>>= R), (d -= R), (t.back += R), $ & 64)) {
            ((e.msg = "invalid distance code"), (t.mode = pe));
            break;
          }
          ((t.offset = D), (t.extra = $ & 15), (t.mode = va));
        case va:
          if (t.extra) {
            for (F = t.extra; d < F; ) {
              if (h === 0) break e;
              (h--, (u += n[s++] << d), (d += 8));
            }
            ((t.offset += u & ((1 << t.extra) - 1)),
              (u >>>= t.extra),
              (d -= t.extra),
              (t.back += t.extra));
          }
          if (t.offset > t.dmax) {
            ((e.msg = "invalid distance too far back"), (t.mode = pe));
            break;
          }
          t.mode = xa;
        case xa:
          if (g === 0) break e;
          if (((y = b - g), t.offset > y)) {
            if (((y = t.offset - y), y > t.whave && t.sane)) {
              ((e.msg = "invalid distance too far back"), (t.mode = pe));
              break;
            }
            (y > t.wnext
              ? ((y -= t.wnext), (I = t.wsize - y))
              : (I = t.wnext - y),
              y > t.length && (y = t.length),
              (x = t.window));
          } else ((x = i), (I = l - t.offset), (y = t.length));
          (y > g && (y = g), (g -= y), (t.length -= y));
          do i[l++] = x[I++];
          while (--y);
          t.length === 0 && (t.mode = Qr);
          break;
        case Ta:
          if (g === 0) break e;
          ((i[l++] = t.length), g--, (t.mode = Qr));
          break;
        case Vn:
          if (t.wrap) {
            for (; d < 32; ) {
              if (h === 0) break e;
              (h--, (u |= n[s++] << d), (d += 8));
            }
            if (
              ((b -= g),
              (e.total_out += b),
              (t.total += b),
              t.wrap & 4 &&
                b &&
                (e.adler = t.check =
                  t.flags
                    ? Ge(t.check, i, b, l - b)
                    : gi(t.check, i, b, l - b)),
              (b = g),
              t.wrap & 4 && (t.flags ? u : Ca(u)) !== t.check)
            ) {
              ((e.msg = "incorrect data check"), (t.mode = pe));
              break;
            }
            ((u = 0), (d = 0));
          }
          t.mode = Ua;
        case Ua:
          if (t.wrap && t.flags) {
            for (; d < 32; ) {
              if (h === 0) break e;
              (h--, (u += n[s++] << d), (d += 8));
            }
            if (t.wrap & 4 && u !== (t.total & 4294967295)) {
              ((e.msg = "incorrect length check"), (t.mode = pe));
              break;
            }
            ((u = 0), (d = 0));
          }
          t.mode = Ra;
        case Ra:
          H = Wl;
          break e;
        case pe:
          H = cs;
          break e;
        case us:
          return ls;
        case fs:
        default:
          return We;
      }
    return (
      (e.next_out = l),
      (e.avail_out = g),
      (e.next_in = s),
      (e.avail_in = h),
      (t.hold = u),
      (t.bits = d),
      (t.wsize ||
        (b !== e.avail_out && t.mode < pe && (t.mode < Vn || r !== la))) &&
        ws(e, e.output, e.next_out, b - e.avail_out),
      (E -= e.avail_in),
      (b -= e.avail_out),
      (e.total_in += E),
      (e.total_out += b),
      (t.total += b),
      t.wrap & 4 &&
        b &&
        (e.adler = t.check =
          t.flags
            ? Ge(t.check, i, b, e.next_out - b)
            : gi(t.check, i, b, e.next_out - b)),
      (e.data_type =
        t.bits +
        (t.last ? 64 : 0) +
        (t.mode === nt ? 128 : 0) +
        (t.mode === Jr || t.mode === Wn ? 256 : 0)),
      ((E === 0 && b === 0) || r === la) && H === zt && (H = Yl),
      H
    );
  },
  tu = (e) => {
    if (Ht(e)) return We;
    let r = e.state;
    return (r.window && (r.window = null), (e.state = null), zt);
  },
  ru = (e, r) => {
    if (Ht(e)) return We;
    const t = e.state;
    return (t.wrap & 2) === 0 ? We : ((t.head = r), (r.done = !1), zt);
  },
  nu = (e, r) => {
    const t = r.length;
    let n, i, s;
    return Ht(e) || ((n = e.state), n.wrap !== 0 && n.mode !== bn)
      ? We
      : n.mode === bn && ((i = 1), (i = gi(i, r, t, 0)), i !== n.check)
        ? cs
        : ((s = ws(e, r, t, t)),
          s ? ((n.mode = us), ls) : ((n.havedict = 1), zt));
  };
var iu = ds,
  au = _s,
  ou = hs,
  su = Jl,
  cu = ps,
  lu = eu,
  uu = tu,
  fu = ru,
  hu = nu,
  du = "pako inflate (from Nodeca project)",
  at = {
    inflateReset: iu,
    inflateReset2: au,
    inflateResetKeep: ou,
    inflateInit: su,
    inflateInit2: cu,
    inflate: lu,
    inflateEnd: uu,
    inflateGetHeader: fu,
    inflateSetDictionary: hu,
    inflateInfo: du,
  };
function _u() {
  ((this.text = 0),
    (this.time = 0),
    (this.xflags = 0),
    (this.os = 0),
    (this.extra = null),
    (this.extra_len = 0),
    (this.name = ""),
    (this.comment = ""),
    (this.hcrc = 0),
    (this.done = !1));
}
var pu = _u;
const gs = Object.prototype.toString,
  {
    Z_NO_FLUSH: wu,
    Z_FINISH: gu,
    Z_OK: Ur,
    Z_STREAM_END: jn,
    Z_NEED_DICT: Kn,
    Z_STREAM_ERROR: yu,
    Z_DATA_ERROR: Na,
    Z_MEM_ERROR: bu,
  } = ns;
function Un(e) {
  this.options = is.assign(
    { chunkSize: 1024 * 64, windowBits: 15, to: "" },
    e || {},
  );
  const r = this.options;
  (r.raw &&
    r.windowBits >= 0 &&
    r.windowBits < 16 &&
    ((r.windowBits = -r.windowBits),
    r.windowBits === 0 && (r.windowBits = -15)),
    r.windowBits >= 0 &&
      r.windowBits < 16 &&
      !(e && e.windowBits) &&
      (r.windowBits += 32),
    r.windowBits > 15 &&
      r.windowBits < 48 &&
      (r.windowBits & 15) === 0 &&
      (r.windowBits |= 15),
    (this.err = 0),
    (this.msg = ""),
    (this.ended = !1),
    (this.chunks = []),
    (this.strm = new Nl()),
    (this.strm.avail_out = 0));
  let t = at.inflateInit2(this.strm, r.windowBits);
  if (t !== Ur) throw new Error(yi[t]);
  if (
    ((this.header = new pu()),
    at.inflateGetHeader(this.strm, this.header),
    r.dictionary &&
      (typeof r.dictionary == "string"
        ? (r.dictionary = bi.string2buf(r.dictionary))
        : gs.call(r.dictionary) === "[object ArrayBuffer]" &&
          (r.dictionary = new Uint8Array(r.dictionary)),
      r.raw &&
        ((t = at.inflateSetDictionary(this.strm, r.dictionary)), t !== Ur)))
  )
    throw new Error(yi[t]);
}
Un.prototype.push = function (e, r) {
  const t = this.strm,
    n = this.options.chunkSize,
    i = this.options.dictionary;
  let s, l, h;
  if (this.ended) return !1;
  for (
    r === ~~r ? (l = r) : (l = r === !0 ? gu : wu),
      gs.call(e) === "[object ArrayBuffer]"
        ? (t.input = new Uint8Array(e))
        : (t.input = e),
      t.next_in = 0,
      t.avail_in = t.input.length;
    ;
  ) {
    for (
      t.avail_out === 0 &&
        ((t.output = new Uint8Array(n)), (t.next_out = 0), (t.avail_out = n)),
        s = at.inflate(t, l),
        s === Kn &&
          i &&
          ((s = at.inflateSetDictionary(t, i)),
          s === Ur ? (s = at.inflate(t, l)) : s === Na && (s = Kn));
      t.avail_in > 0 && s === jn && t.state.wrap > 0 && e[t.next_in] !== 0;
    )
      (at.inflateReset(t), (s = at.inflate(t, l)));
    switch (s) {
      case yu:
      case Na:
      case Kn:
      case bu:
        return (this.onEnd(s), (this.ended = !0), !1);
    }
    if (((h = t.avail_out), t.next_out && (t.avail_out === 0 || s === jn)))
      if (this.options.to === "string") {
        let g = bi.utf8border(t.output, t.next_out),
          u = t.next_out - g,
          d = bi.buf2string(t.output, g);
        ((t.next_out = u),
          (t.avail_out = n - u),
          u && t.output.set(t.output.subarray(g, g + u), 0),
          this.onData(d));
      } else
        this.onData(
          t.output.length === t.next_out
            ? t.output
            : t.output.subarray(0, t.next_out),
        );
    if (!(s === Ur && h === 0)) {
      if (s === jn)
        return (
          (s = at.inflateEnd(this.strm)),
          this.onEnd(s),
          (this.ended = !0),
          !0
        );
      if (t.avail_in === 0) break;
    }
  }
  return !0;
};
Un.prototype.onData = function (e) {
  this.chunks.push(e);
};
Un.prototype.onEnd = function (e) {
  (e === Ur &&
    (this.options.to === "string"
      ? (this.result = this.chunks.join(""))
      : (this.result = is.flattenChunks(this.chunks))),
    (this.chunks = []),
    (this.err = e),
    (this.msg = this.strm.msg));
};
function mu(e, r) {
  const t = new Un(r);
  if ((t.push(e), t.err)) throw t.msg || yi[t.err];
  return t.result;
}
var Eu = mu,
  ku = { inflate: Eu };
const { inflate: Bu } = ku;
var Su = Bu;
function Iu(e) {
  return JSON.parse(Su(es(e), { to: "string", raw: !0 })).debug_infos;
}
function Au(e, r, t) {
  if (!("callStack" in e) || !e.callStack) return;
  const { callStack: n, brilligFunctionId: i } = e;
  if (!r) return n;
  try {
    return vu(n, r, t, i);
  } catch {
    return n;
  }
}
function vu(e, r, t, n) {
  let i = e.flatMap((s) => xu(s, r, t, n));
  if (i.length > 0) {
    const s = e[e.length - 1].split(".");
    if (s.length === 2) {
      const l = r.acir_locations[s[0]];
      if (l !== void 0) {
        const h = r.location_tree.locations[l];
        i = ys(h, r.location_tree.locations, t).concat(i);
      }
    }
  }
  return i;
}
function ys(e, r, t) {
  const n = [];
  for (; e.parent !== null; ) {
    const { file: i, span: s } = e.value,
      { path: l, source: h } = t[i],
      g = h.substring(s.start, s.end),
      d = h.substring(0, s.start).split(`
`),
      E = d.length,
      b = d[d.length - 1].length + 1;
    (n.push({ filePath: l, line: E, column: b, locationText: g }),
      (e = r[e.parent]));
  }
  return n.reverse();
}
function xu(e, r, t, n) {
  let i = r.acir_locations[e];
  const s = Tu(e);
  if (
    n !== void 0 &&
    s !== void 0 &&
    ((i = r.brillig_locations[n][s]), i === void 0)
  )
    return [];
  if (i === void 0) return [];
  const l = r.location_tree.locations[i];
  return ys(l, r.location_tree.locations, t);
}
function Tu(e) {
  const r = e.split(".");
  if (r.length === 2) return r[1];
}
const Uu = async (e, r) => {
  if (e == "print") return [];
  throw Error(`Unexpected oracle during execution: ${e}(${r.join(", ")})`);
};
function Ru(e, r) {
  const t = r;
  if (r.rawAssertionPayload)
    try {
      const n = Jc(e.abi, r.rawAssertionPayload);
      typeof n == "string"
        ? (t.message = `Circuit execution failed: ${n}`)
        : (t.decodedAssertionPayload = n);
    } catch {}
  try {
    const n = Au(r, Iu(e.debug_symbols)[r.acirFunctionId], e.file_map);
    t.noirCallStack =
      n == null
        ? void 0
        : n.map((i) =>
            typeof i == "string"
              ? `at opcode ${i}`
              : `at ${i.locationText} (${i.filePath}:${i.line}:${i.column})`,
          );
  } catch {}
  return t;
}
async function Cu(e, r, t = Uu) {
  const n = Xc(e.abi, r);
  try {
    return await Hc(es(e.bytecode), n, t);
  } catch (i) {
    throw typeof i == "object" && i !== null && "rawAssertionPayload" in i
      ? Ru(e, i)
      : new Error(`Circuit execution failed: ${i}`);
  }
}
class Du {
  constructor(r) {
    Qi(this, "circuit");
    this.circuit = r;
  }
  async init() {
    typeof yn == "function" && (await Promise.all([yn(), $i()]));
  }
  async execute(r, t) {
    await this.init();
    const n = await Cu(this.circuit, r, t),
      i = n[0].witness,
      { return_value: s } = qc(this.circuit.abi, i);
    return { witness: Zc(n), returnValue: s };
  }
}
const Nu = "modulepreload",
  Ou = function (e) {
    return "/" + e;
  },
  Oa = {},
  $a = function (r, t, n) {
    let i = Promise.resolve();
    if (t && t.length > 0) {
      let l = function (u) {
        return Promise.all(
          u.map((d) =>
            Promise.resolve(d).then(
              (E) => ({ status: "fulfilled", value: E }),
              (E) => ({ status: "rejected", reason: E }),
            ),
          ),
        );
      };
      document.getElementsByTagName("link");
      const h = document.querySelector("meta[property=csp-nonce]"),
        g =
          (h == null ? void 0 : h.nonce) ||
          (h == null ? void 0 : h.getAttribute("nonce"));
      i = l(
        t.map((u) => {
          if (((u = Ou(u)), u in Oa)) return;
          Oa[u] = !0;
          const d = u.endsWith(".css"),
            E = d ? '[rel="stylesheet"]' : "";
          if (document.querySelector(`link[href="${u}"]${E}`)) return;
          const b = document.createElement("link");
          if (
            ((b.rel = d ? "stylesheet" : Nu),
            d || (b.as = "script"),
            (b.crossOrigin = ""),
            (b.href = u),
            g && b.setAttribute("nonce", g),
            document.head.appendChild(b),
            d)
          )
            return new Promise((y, I) => {
              (b.addEventListener("load", y),
                b.addEventListener("error", () =>
                  I(new Error(`Unable to preload CSS for ${u}`)),
                ));
            });
        }),
      );
    }
    function s(l) {
      const h = new Event("vite:preloadError", { cancelable: !0 });
      if (((h.payload = l), window.dispatchEvent(h), !h.defaultPrevented))
        throw l;
    }
    return i.then((l) => {
      for (const h of l || []) h.status === "rejected" && s(h.reason);
      return r().catch(s);
    });
  };
var $u = {
    0: (e) => {
      var r = 1e3,
        t = r * 60,
        n = t * 60,
        i = n * 24,
        s = i * 7,
        l = i * 365.25;
      e.exports = function (E, b) {
        b = b || {};
        var y = typeof E;
        if (y === "string" && E.length > 0) return h(E);
        if (y === "number" && isFinite(E)) return b.long ? u(E) : g(E);
        throw new Error(
          "val is not a non-empty string or a valid number. val=" +
            JSON.stringify(E),
        );
      };
      function h(E) {
        if (((E = String(E)), !(E.length > 100))) {
          var b =
            /^(-?(?:\d+)?\.?\d+) *(milliseconds?|msecs?|ms|seconds?|secs?|s|minutes?|mins?|m|hours?|hrs?|h|days?|d|weeks?|w|years?|yrs?|y)?$/i.exec(
              E,
            );
          if (b) {
            var y = parseFloat(b[1]),
              I = (b[2] || "ms").toLowerCase();
            switch (I) {
              case "years":
              case "year":
              case "yrs":
              case "yr":
              case "y":
                return y * l;
              case "weeks":
              case "week":
              case "w":
                return y * s;
              case "days":
              case "day":
              case "d":
                return y * i;
              case "hours":
              case "hour":
              case "hrs":
              case "hr":
              case "h":
                return y * n;
              case "minutes":
              case "minute":
              case "mins":
              case "min":
              case "m":
                return y * t;
              case "seconds":
              case "second":
              case "secs":
              case "sec":
              case "s":
                return y * r;
              case "milliseconds":
              case "millisecond":
              case "msecs":
              case "msec":
              case "ms":
                return y;
              default:
                return;
            }
          }
        }
      }
      function g(E) {
        var b = Math.abs(E);
        return b >= i
          ? Math.round(E / i) + "d"
          : b >= n
            ? Math.round(E / n) + "h"
            : b >= t
              ? Math.round(E / t) + "m"
              : b >= r
                ? Math.round(E / r) + "s"
                : E + "ms";
      }
      function u(E) {
        var b = Math.abs(E);
        return b >= i
          ? d(E, b, i, "day")
          : b >= n
            ? d(E, b, n, "hour")
            : b >= t
              ? d(E, b, t, "minute")
              : b >= r
                ? d(E, b, r, "second")
                : E + " ms";
      }
      function d(E, b, y, I) {
        var x = b >= y * 1.5;
        return Math.round(E / y) + " " + I + (x ? "s" : "");
      }
    },
    19: (e, r) => {
      Object.defineProperty(r, "__esModule", { value: !0 });
      var t = { exports: {} },
        n = (t.exports = {}),
        i,
        s;
      function l() {
        throw new Error("setTimeout has not been defined");
      }
      function h() {
        throw new Error("clearTimeout has not been defined");
      }
      (function () {
        try {
          typeof setTimeout == "function" ? (i = setTimeout) : (i = l);
        } catch {
          i = l;
        }
        try {
          typeof clearTimeout == "function" ? (s = clearTimeout) : (s = h);
        } catch {
          s = h;
        }
      })();
      function g(Y) {
        if (i === setTimeout) return setTimeout(Y, 0);
        if ((i === l || !i) && setTimeout)
          return ((i = setTimeout), setTimeout(Y, 0));
        try {
          return i(Y, 0);
        } catch {
          try {
            return i.call(null, Y, 0);
          } catch {
            return i.call(this, Y, 0);
          }
        }
      }
      function u(Y) {
        if (s === clearTimeout) return clearTimeout(Y);
        if ((s === h || !s) && clearTimeout)
          return ((s = clearTimeout), clearTimeout(Y));
        try {
          return s(Y);
        } catch {
          try {
            return s.call(null, Y);
          } catch {
            return s.call(this, Y);
          }
        }
      }
      var d = [],
        E = !1,
        b,
        y = -1;
      function I() {
        !E ||
          !b ||
          ((E = !1), b.length ? (d = b.concat(d)) : (y = -1), d.length && x());
      }
      function x() {
        if (!E) {
          var Y = g(I);
          E = !0;
          for (var K = d.length; K; ) {
            for (b = d, d = []; ++y < K; ) b && b[y].run();
            ((y = -1), (K = d.length));
          }
          ((b = null), (E = !1), u(Y));
        }
      }
      n.nextTick = function (Y) {
        var K = new Array(arguments.length - 1);
        if (arguments.length > 1)
          for (var ee = 1; ee < arguments.length; ee++)
            K[ee - 1] = arguments[ee];
        (d.push(new T(Y, K)), d.length === 1 && !E && g(x));
      };
      function T(Y, K) {
        ((this.fun = Y), (this.array = K));
      }
      ((T.prototype.run = function () {
        this.fun.apply(null, this.array);
      }),
        (n.title = "browser"),
        (n.browser = !0),
        (n.env = {}),
        (n.argv = []),
        (n.version = ""),
        (n.versions = {}));
      function R() {}
      ((n.on = R),
        (n.addListener = R),
        (n.once = R),
        (n.off = R),
        (n.removeListener = R),
        (n.removeAllListeners = R),
        (n.emit = R),
        (n.prependListener = R),
        (n.prependOnceListener = R),
        (n.listeners = function (Y) {
          return [];
        }),
        (n.binding = function (Y) {
          throw new Error("process.binding is not supported");
        }),
        (n.cwd = function () {
          return "/";
        }),
        (n.chdir = function (Y) {
          throw new Error("process.chdir is not supported");
        }),
        (n.umask = function () {
          return 0;
        }));
      function $() {}
      var D = t.exports.browser,
        m = $,
        z = t.exports.binding,
        V = $,
        C = 1,
        H = {},
        M = $,
        N = $,
        F = $,
        se = $,
        A = $,
        P = "browser",
        L = "browser",
        O = "browser",
        Z = [],
        j = {
          nextTick: t.exports.nextTick,
          title: t.exports.title,
          browser: D,
          env: t.exports.env,
          argv: t.exports.argv,
          version: t.exports.version,
          versions: t.exports.versions,
          on: t.exports.on,
          addListener: t.exports.addListener,
          once: t.exports.once,
          off: t.exports.off,
          removeListener: t.exports.removeListener,
          removeAllListeners: t.exports.removeAllListeners,
          emit: t.exports.emit,
          emitWarning: m,
          prependListener: t.exports.prependListener,
          prependOnceListener: t.exports.prependOnceListener,
          listeners: t.exports.listeners,
          binding: z,
          cwd: t.exports.cwd,
          chdir: t.exports.chdir,
          umask: t.exports.umask,
          exit: V,
          pid: C,
          features: H,
          kill: M,
          dlopen: N,
          uptime: F,
          memoryUsage: se,
          uvCounters: A,
          platform: P,
          arch: L,
          execPath: O,
          execArgv: Z,
        };
      ((r.addListener = t.exports.addListener),
        (r.arch = L),
        (r.argv = t.exports.argv),
        (r.binding = z),
        (r.browser = D),
        (r.chdir = t.exports.chdir),
        (r.cwd = t.exports.cwd),
        (r.default = j),
        (r.dlopen = N),
        (r.emit = t.exports.emit),
        (r.emitWarning = m),
        (r.env = t.exports.env),
        (r.execArgv = Z),
        (r.execPath = O),
        (r.exit = V),
        (r.features = H),
        (r.kill = M),
        (r.listeners = t.exports.listeners),
        (r.memoryUsage = se),
        (r.nextTick = t.exports.nextTick),
        (r.off = t.exports.off),
        (r.on = t.exports.on),
        (r.once = t.exports.once),
        (r.pid = C),
        (r.platform = P),
        (r.prependListener = t.exports.prependListener),
        (r.prependOnceListener = t.exports.prependOnceListener),
        (r.removeAllListeners = t.exports.removeAllListeners),
        (r.removeListener = t.exports.removeListener),
        (r.title = t.exports.title),
        (r.umask = t.exports.umask),
        (r.uptime = F),
        (r.uvCounters = A),
        (r.version = t.exports.version),
        (r.versions = t.exports.versions),
        (r = e.exports = j));
    },
    251: (e, r) => {
      ((r.read = function (t, n, i, s, l) {
        var h,
          g,
          u = l * 8 - s - 1,
          d = (1 << u) - 1,
          E = d >> 1,
          b = -7,
          y = i ? l - 1 : 0,
          I = i ? -1 : 1,
          x = t[n + y];
        for (
          y += I, h = x & ((1 << -b) - 1), x >>= -b, b += u;
          b > 0;
          h = h * 256 + t[n + y], y += I, b -= 8
        );
        for (
          g = h & ((1 << -b) - 1), h >>= -b, b += s;
          b > 0;
          g = g * 256 + t[n + y], y += I, b -= 8
        );
        if (h === 0) h = 1 - E;
        else {
          if (h === d) return g ? NaN : (x ? -1 : 1) * (1 / 0);
          ((g = g + Math.pow(2, s)), (h = h - E));
        }
        return (x ? -1 : 1) * g * Math.pow(2, h - s);
      }),
        (r.write = function (t, n, i, s, l, h) {
          var g,
            u,
            d,
            E = h * 8 - l - 1,
            b = (1 << E) - 1,
            y = b >> 1,
            I = l === 23 ? Math.pow(2, -24) - Math.pow(2, -77) : 0,
            x = s ? 0 : h - 1,
            T = s ? 1 : -1,
            R = n < 0 || (n === 0 && 1 / n < 0) ? 1 : 0;
          for (
            n = Math.abs(n),
              isNaN(n) || n === 1 / 0
                ? ((u = isNaN(n) ? 1 : 0), (g = b))
                : ((g = Math.floor(Math.log(n) / Math.LN2)),
                  n * (d = Math.pow(2, -g)) < 1 && (g--, (d *= 2)),
                  g + y >= 1 ? (n += I / d) : (n += I * Math.pow(2, 1 - y)),
                  n * d >= 2 && (g++, (d /= 2)),
                  g + y >= b
                    ? ((u = 0), (g = b))
                    : g + y >= 1
                      ? ((u = (n * d - 1) * Math.pow(2, l)), (g = g + y))
                      : ((u = n * Math.pow(2, y - 1) * Math.pow(2, l)),
                        (g = 0)));
            l >= 8;
            t[i + x] = u & 255, x += T, u /= 256, l -= 8
          );
          for (
            g = (g << l) | u, E += l;
            E > 0;
            t[i + x] = g & 255, x += T, g /= 256, E -= 8
          );
          t[i + x - T] |= R * 128;
        }));
    },
    287: (e, r, t) => {
      const n = t(526),
        i = t(251),
        s =
          typeof Symbol == "function" && typeof Symbol.for == "function"
            ? Symbol.for("nodejs.util.inspect.custom")
            : null;
      ((r.hp = u), (r.IS = 50));
      const l = 2147483647;
      ((u.TYPED_ARRAY_SUPPORT = h()),
        !u.TYPED_ARRAY_SUPPORT &&
          typeof console < "u" &&
          typeof console.error == "function" &&
          console.error(
            "This browser lacks typed array (Uint8Array) support which is required by `buffer` v5.x. Use `buffer` v4.x if you require old browser support.",
          ));
      function h() {
        try {
          const p = new Uint8Array(1),
            f = {
              foo: function () {
                return 42;
              },
            };
          return (
            Object.setPrototypeOf(f, Uint8Array.prototype),
            Object.setPrototypeOf(p, f),
            p.foo() === 42
          );
        } catch {
          return !1;
        }
      }
      (Object.defineProperty(u.prototype, "parent", {
        enumerable: !0,
        get: function () {
          if (u.isBuffer(this)) return this.buffer;
        },
      }),
        Object.defineProperty(u.prototype, "offset", {
          enumerable: !0,
          get: function () {
            if (u.isBuffer(this)) return this.byteOffset;
          },
        }));
      function g(p) {
        if (p > l)
          throw new RangeError(
            'The value "' + p + '" is invalid for option "size"',
          );
        const f = new Uint8Array(p);
        return (Object.setPrototypeOf(f, u.prototype), f);
      }
      function u(p, f, a) {
        if (typeof p == "number") {
          if (typeof f == "string")
            throw new TypeError(
              'The "string" argument must be of type string. Received type number',
            );
          return y(p);
        }
        return d(p, f, a);
      }
      u.poolSize = 8192;
      function d(p, f, a) {
        if (typeof p == "string") return I(p, f);
        if (ArrayBuffer.isView(p)) return T(p);
        if (p == null)
          throw new TypeError(
            "The first argument must be one of type string, Buffer, ArrayBuffer, Array, or Array-like Object. Received type " +
              typeof p,
          );
        if (
          Ce(p, ArrayBuffer) ||
          (p && Ce(p.buffer, ArrayBuffer)) ||
          (typeof SharedArrayBuffer < "u" &&
            (Ce(p, SharedArrayBuffer) ||
              (p && Ce(p.buffer, SharedArrayBuffer))))
        )
          return R(p, f, a);
        if (typeof p == "number")
          throw new TypeError(
            'The "value" argument must not be of type number. Received type number',
          );
        const o = p.valueOf && p.valueOf();
        if (o != null && o !== p) return u.from(o, f, a);
        const c = $(p);
        if (c) return c;
        if (
          typeof Symbol < "u" &&
          Symbol.toPrimitive != null &&
          typeof p[Symbol.toPrimitive] == "function"
        )
          return u.from(p[Symbol.toPrimitive]("string"), f, a);
        throw new TypeError(
          "The first argument must be one of type string, Buffer, ArrayBuffer, Array, or Array-like Object. Received type " +
            typeof p,
        );
      }
      ((u.from = function (p, f, a) {
        return d(p, f, a);
      }),
        Object.setPrototypeOf(u.prototype, Uint8Array.prototype),
        Object.setPrototypeOf(u, Uint8Array));
      function E(p) {
        if (typeof p != "number")
          throw new TypeError('"size" argument must be of type number');
        if (p < 0)
          throw new RangeError(
            'The value "' + p + '" is invalid for option "size"',
          );
      }
      function b(p, f, a) {
        return (
          E(p),
          p <= 0
            ? g(p)
            : f !== void 0
              ? typeof a == "string"
                ? g(p).fill(f, a)
                : g(p).fill(f)
              : g(p)
        );
      }
      u.alloc = function (p, f, a) {
        return b(p, f, a);
      };
      function y(p) {
        return (E(p), g(p < 0 ? 0 : D(p) | 0));
      }
      ((u.allocUnsafe = function (p) {
        return y(p);
      }),
        (u.allocUnsafeSlow = function (p) {
          return y(p);
        }));
      function I(p, f) {
        if (
          ((typeof f != "string" || f === "") && (f = "utf8"), !u.isEncoding(f))
        )
          throw new TypeError("Unknown encoding: " + f);
        const a = m(p, f) | 0;
        let o = g(a);
        const c = o.write(p, f);
        return (c !== a && (o = o.slice(0, c)), o);
      }
      function x(p) {
        const f = p.length < 0 ? 0 : D(p.length) | 0,
          a = g(f);
        for (let o = 0; o < f; o += 1) a[o] = p[o] & 255;
        return a;
      }
      function T(p) {
        if (Ce(p, Uint8Array)) {
          const f = new Uint8Array(p);
          return R(f.buffer, f.byteOffset, f.byteLength);
        }
        return x(p);
      }
      function R(p, f, a) {
        if (f < 0 || p.byteLength < f)
          throw new RangeError('"offset" is outside of buffer bounds');
        if (p.byteLength < f + (a || 0))
          throw new RangeError('"length" is outside of buffer bounds');
        let o;
        return (
          f === void 0 && a === void 0
            ? (o = new Uint8Array(p))
            : a === void 0
              ? (o = new Uint8Array(p, f))
              : (o = new Uint8Array(p, f, a)),
          Object.setPrototypeOf(o, u.prototype),
          o
        );
      }
      function $(p) {
        if (u.isBuffer(p)) {
          const f = D(p.length) | 0,
            a = g(f);
          return (a.length === 0 || p.copy(a, 0, 0, f), a);
        }
        if (p.length !== void 0)
          return typeof p.length != "number" || gt(p.length) ? g(0) : x(p);
        if (p.type === "Buffer" && Array.isArray(p.data)) return x(p.data);
      }
      function D(p) {
        if (p >= l)
          throw new RangeError(
            "Attempt to allocate Buffer larger than maximum size: 0x" +
              l.toString(16) +
              " bytes",
          );
        return p | 0;
      }
      ((u.isBuffer = function (f) {
        return f != null && f._isBuffer === !0 && f !== u.prototype;
      }),
        (u.compare = function (f, a) {
          if (
            (Ce(f, Uint8Array) && (f = u.from(f, f.offset, f.byteLength)),
            Ce(a, Uint8Array) && (a = u.from(a, a.offset, a.byteLength)),
            !u.isBuffer(f) || !u.isBuffer(a))
          )
            throw new TypeError(
              'The "buf1", "buf2" arguments must be one of type Buffer or Uint8Array',
            );
          if (f === a) return 0;
          let o = f.length,
            c = a.length;
          for (let _ = 0, w = Math.min(o, c); _ < w; ++_)
            if (f[_] !== a[_]) {
              ((o = f[_]), (c = a[_]));
              break;
            }
          return o < c ? -1 : c < o ? 1 : 0;
        }),
        (u.isEncoding = function (f) {
          switch (String(f).toLowerCase()) {
            case "hex":
            case "utf8":
            case "utf-8":
            case "ascii":
            case "latin1":
            case "binary":
            case "base64":
            case "ucs2":
            case "ucs-2":
            case "utf16le":
            case "utf-16le":
              return !0;
            default:
              return !1;
          }
        }),
        (u.concat = function (f, a) {
          if (!Array.isArray(f))
            throw new TypeError('"list" argument must be an Array of Buffers');
          if (f.length === 0) return u.alloc(0);
          let o;
          if (a === void 0)
            for (a = 0, o = 0; o < f.length; ++o) a += f[o].length;
          const c = u.allocUnsafe(a);
          let _ = 0;
          for (o = 0; o < f.length; ++o) {
            let w = f[o];
            if (Ce(w, Uint8Array))
              _ + w.length > c.length
                ? (u.isBuffer(w) || (w = u.from(w)), w.copy(c, _))
                : Uint8Array.prototype.set.call(c, w, _);
            else if (u.isBuffer(w)) w.copy(c, _);
            else
              throw new TypeError(
                '"list" argument must be an Array of Buffers',
              );
            _ += w.length;
          }
          return c;
        }));
      function m(p, f) {
        if (u.isBuffer(p)) return p.length;
        if (ArrayBuffer.isView(p) || Ce(p, ArrayBuffer)) return p.byteLength;
        if (typeof p != "string")
          throw new TypeError(
            'The "string" argument must be one of type string, Buffer, or ArrayBuffer. Received type ' +
              typeof p,
          );
        const a = p.length,
          o = arguments.length > 2 && arguments[2] === !0;
        if (!o && a === 0) return 0;
        let c = !1;
        for (;;)
          switch (f) {
            case "ascii":
            case "latin1":
            case "binary":
              return a;
            case "utf8":
            case "utf-8":
              return dr(p).length;
            case "ucs2":
            case "ucs-2":
            case "utf16le":
            case "utf-16le":
              return a * 2;
            case "hex":
              return a >>> 1;
            case "base64":
              return jr(p).length;
            default:
              if (c) return o ? -1 : dr(p).length;
              ((f = ("" + f).toLowerCase()), (c = !0));
          }
      }
      u.byteLength = m;
      function z(p, f, a) {
        let o = !1;
        if (
          ((f === void 0 || f < 0) && (f = 0),
          f > this.length ||
            ((a === void 0 || a > this.length) && (a = this.length), a <= 0) ||
            ((a >>>= 0), (f >>>= 0), a <= f))
        )
          return "";
        for (p || (p = "utf8"); ; )
          switch (p) {
            case "hex":
              return K(this, f, a);
            case "utf8":
            case "utf-8":
              return L(this, f, a);
            case "ascii":
              return j(this, f, a);
            case "latin1":
            case "binary":
              return Y(this, f, a);
            case "base64":
              return P(this, f, a);
            case "ucs2":
            case "ucs-2":
            case "utf16le":
            case "utf-16le":
              return ee(this, f, a);
            default:
              if (o) throw new TypeError("Unknown encoding: " + p);
              ((p = (p + "").toLowerCase()), (o = !0));
          }
      }
      u.prototype._isBuffer = !0;
      function V(p, f, a) {
        const o = p[f];
        ((p[f] = p[a]), (p[a] = o));
      }
      ((u.prototype.swap16 = function () {
        const f = this.length;
        if (f % 2 !== 0)
          throw new RangeError("Buffer size must be a multiple of 16-bits");
        for (let a = 0; a < f; a += 2) V(this, a, a + 1);
        return this;
      }),
        (u.prototype.swap32 = function () {
          const f = this.length;
          if (f % 4 !== 0)
            throw new RangeError("Buffer size must be a multiple of 32-bits");
          for (let a = 0; a < f; a += 4)
            (V(this, a, a + 3), V(this, a + 1, a + 2));
          return this;
        }),
        (u.prototype.swap64 = function () {
          const f = this.length;
          if (f % 8 !== 0)
            throw new RangeError("Buffer size must be a multiple of 64-bits");
          for (let a = 0; a < f; a += 8)
            (V(this, a, a + 7),
              V(this, a + 1, a + 6),
              V(this, a + 2, a + 5),
              V(this, a + 3, a + 4));
          return this;
        }),
        (u.prototype.toString = function () {
          const f = this.length;
          return f === 0
            ? ""
            : arguments.length === 0
              ? L(this, 0, f)
              : z.apply(this, arguments);
        }),
        (u.prototype.toLocaleString = u.prototype.toString),
        (u.prototype.equals = function (f) {
          if (!u.isBuffer(f)) throw new TypeError("Argument must be a Buffer");
          return this === f ? !0 : u.compare(this, f) === 0;
        }),
        (u.prototype.inspect = function () {
          let f = "";
          const a = r.IS;
          return (
            (f = this.toString("hex", 0, a)
              .replace(/(.{2})/g, "$1 ")
              .trim()),
            this.length > a && (f += " ... "),
            "<Buffer " + f + ">"
          );
        }),
        s && (u.prototype[s] = u.prototype.inspect),
        (u.prototype.compare = function (f, a, o, c, _) {
          if (
            (Ce(f, Uint8Array) && (f = u.from(f, f.offset, f.byteLength)),
            !u.isBuffer(f))
          )
            throw new TypeError(
              'The "target" argument must be one of type Buffer or Uint8Array. Received type ' +
                typeof f,
            );
          if (
            (a === void 0 && (a = 0),
            o === void 0 && (o = f ? f.length : 0),
            c === void 0 && (c = 0),
            _ === void 0 && (_ = this.length),
            a < 0 || o > f.length || c < 0 || _ > this.length)
          )
            throw new RangeError("out of range index");
          if (c >= _ && a >= o) return 0;
          if (c >= _) return -1;
          if (a >= o) return 1;
          if (((a >>>= 0), (o >>>= 0), (c >>>= 0), (_ >>>= 0), this === f))
            return 0;
          let w = _ - c,
            B = o - a;
          const U = Math.min(w, B),
            G = this.slice(c, _),
            Q = f.slice(a, o);
          for (let q = 0; q < U; ++q)
            if (G[q] !== Q[q]) {
              ((w = G[q]), (B = Q[q]));
              break;
            }
          return w < B ? -1 : B < w ? 1 : 0;
        }));
      function C(p, f, a, o, c) {
        if (p.length === 0) return -1;
        if (
          (typeof a == "string"
            ? ((o = a), (a = 0))
            : a > 2147483647
              ? (a = 2147483647)
              : a < -2147483648 && (a = -2147483648),
          (a = +a),
          gt(a) && (a = c ? 0 : p.length - 1),
          a < 0 && (a = p.length + a),
          a >= p.length)
        ) {
          if (c) return -1;
          a = p.length - 1;
        } else if (a < 0)
          if (c) a = 0;
          else return -1;
        if ((typeof f == "string" && (f = u.from(f, o)), u.isBuffer(f)))
          return f.length === 0 ? -1 : H(p, f, a, o, c);
        if (typeof f == "number")
          return (
            (f = f & 255),
            typeof Uint8Array.prototype.indexOf == "function"
              ? c
                ? Uint8Array.prototype.indexOf.call(p, f, a)
                : Uint8Array.prototype.lastIndexOf.call(p, f, a)
              : H(p, [f], a, o, c)
          );
        throw new TypeError("val must be string, number or Buffer");
      }
      function H(p, f, a, o, c) {
        let _ = 1,
          w = p.length,
          B = f.length;
        if (
          o !== void 0 &&
          ((o = String(o).toLowerCase()),
          o === "ucs2" || o === "ucs-2" || o === "utf16le" || o === "utf-16le")
        ) {
          if (p.length < 2 || f.length < 2) return -1;
          ((_ = 2), (w /= 2), (B /= 2), (a /= 2));
        }
        function U(Q, q) {
          return _ === 1 ? Q[q] : Q.readUInt16BE(q * _);
        }
        let G;
        if (c) {
          let Q = -1;
          for (G = a; G < w; G++)
            if (U(p, G) === U(f, Q === -1 ? 0 : G - Q)) {
              if ((Q === -1 && (Q = G), G - Q + 1 === B)) return Q * _;
            } else (Q !== -1 && (G -= G - Q), (Q = -1));
        } else
          for (a + B > w && (a = w - B), G = a; G >= 0; G--) {
            let Q = !0;
            for (let q = 0; q < B; q++)
              if (U(p, G + q) !== U(f, q)) {
                Q = !1;
                break;
              }
            if (Q) return G;
          }
        return -1;
      }
      ((u.prototype.includes = function (f, a, o) {
        return this.indexOf(f, a, o) !== -1;
      }),
        (u.prototype.indexOf = function (f, a, o) {
          return C(this, f, a, o, !0);
        }),
        (u.prototype.lastIndexOf = function (f, a, o) {
          return C(this, f, a, o, !1);
        }));
      function M(p, f, a, o) {
        a = Number(a) || 0;
        const c = p.length - a;
        o ? ((o = Number(o)), o > c && (o = c)) : (o = c);
        const _ = f.length;
        o > _ / 2 && (o = _ / 2);
        let w;
        for (w = 0; w < o; ++w) {
          const B = parseInt(f.substr(w * 2, 2), 16);
          if (gt(B)) return w;
          p[a + w] = B;
        }
        return w;
      }
      function N(p, f, a, o) {
        return Vt(dr(f, p.length - a), p, a, o);
      }
      function F(p, f, a, o) {
        return Vt(zn(f), p, a, o);
      }
      function se(p, f, a, o) {
        return Vt(jr(f), p, a, o);
      }
      function A(p, f, a, o) {
        return Vt(_r(f, p.length - a), p, a, o);
      }
      ((u.prototype.write = function (f, a, o, c) {
        if (a === void 0) ((c = "utf8"), (o = this.length), (a = 0));
        else if (o === void 0 && typeof a == "string")
          ((c = a), (o = this.length), (a = 0));
        else if (isFinite(a))
          ((a = a >>> 0),
            isFinite(o)
              ? ((o = o >>> 0), c === void 0 && (c = "utf8"))
              : ((c = o), (o = void 0)));
        else
          throw new Error(
            "Buffer.write(string, encoding, offset[, length]) is no longer supported",
          );
        const _ = this.length - a;
        if (
          ((o === void 0 || o > _) && (o = _),
          (f.length > 0 && (o < 0 || a < 0)) || a > this.length)
        )
          throw new RangeError("Attempt to write outside buffer bounds");
        c || (c = "utf8");
        let w = !1;
        for (;;)
          switch (c) {
            case "hex":
              return M(this, f, a, o);
            case "utf8":
            case "utf-8":
              return N(this, f, a, o);
            case "ascii":
            case "latin1":
            case "binary":
              return F(this, f, a, o);
            case "base64":
              return se(this, f, a, o);
            case "ucs2":
            case "ucs-2":
            case "utf16le":
            case "utf-16le":
              return A(this, f, a, o);
            default:
              if (w) throw new TypeError("Unknown encoding: " + c);
              ((c = ("" + c).toLowerCase()), (w = !0));
          }
      }),
        (u.prototype.toJSON = function () {
          return {
            type: "Buffer",
            data: Array.prototype.slice.call(this._arr || this, 0),
          };
        }));
      function P(p, f, a) {
        return f === 0 && a === p.length
          ? n.fromByteArray(p)
          : n.fromByteArray(p.slice(f, a));
      }
      function L(p, f, a) {
        a = Math.min(p.length, a);
        const o = [];
        let c = f;
        for (; c < a; ) {
          const _ = p[c];
          let w = null,
            B = _ > 239 ? 4 : _ > 223 ? 3 : _ > 191 ? 2 : 1;
          if (c + B <= a) {
            let U, G, Q, q;
            switch (B) {
              case 1:
                _ < 128 && (w = _);
                break;
              case 2:
                ((U = p[c + 1]),
                  (U & 192) === 128 &&
                    ((q = ((_ & 31) << 6) | (U & 63)), q > 127 && (w = q)));
                break;
              case 3:
                ((U = p[c + 1]),
                  (G = p[c + 2]),
                  (U & 192) === 128 &&
                    (G & 192) === 128 &&
                    ((q = ((_ & 15) << 12) | ((U & 63) << 6) | (G & 63)),
                    q > 2047 && (q < 55296 || q > 57343) && (w = q)));
                break;
              case 4:
                ((U = p[c + 1]),
                  (G = p[c + 2]),
                  (Q = p[c + 3]),
                  (U & 192) === 128 &&
                    (G & 192) === 128 &&
                    (Q & 192) === 128 &&
                    ((q =
                      ((_ & 15) << 18) |
                      ((U & 63) << 12) |
                      ((G & 63) << 6) |
                      (Q & 63)),
                    q > 65535 && q < 1114112 && (w = q)));
            }
          }
          (w === null
            ? ((w = 65533), (B = 1))
            : w > 65535 &&
              ((w -= 65536),
              o.push(((w >>> 10) & 1023) | 55296),
              (w = 56320 | (w & 1023))),
            o.push(w),
            (c += B));
        }
        return Z(o);
      }
      const O = 4096;
      function Z(p) {
        const f = p.length;
        if (f <= O) return String.fromCharCode.apply(String, p);
        let a = "",
          o = 0;
        for (; o < f; )
          a += String.fromCharCode.apply(String, p.slice(o, (o += O)));
        return a;
      }
      function j(p, f, a) {
        let o = "";
        a = Math.min(p.length, a);
        for (let c = f; c < a; ++c) o += String.fromCharCode(p[c] & 127);
        return o;
      }
      function Y(p, f, a) {
        let o = "";
        a = Math.min(p.length, a);
        for (let c = f; c < a; ++c) o += String.fromCharCode(p[c]);
        return o;
      }
      function K(p, f, a) {
        const o = p.length;
        ((!f || f < 0) && (f = 0), (!a || a < 0 || a > o) && (a = o));
        let c = "";
        for (let _ = f; _ < a; ++_) c += Fe[p[_]];
        return c;
      }
      function ee(p, f, a) {
        const o = p.slice(f, a);
        let c = "";
        for (let _ = 0; _ < o.length - 1; _ += 2)
          c += String.fromCharCode(o[_] + o[_ + 1] * 256);
        return c;
      }
      u.prototype.slice = function (f, a) {
        const o = this.length;
        ((f = ~~f),
          (a = a === void 0 ? o : ~~a),
          f < 0 ? ((f += o), f < 0 && (f = 0)) : f > o && (f = o),
          a < 0 ? ((a += o), a < 0 && (a = 0)) : a > o && (a = o),
          a < f && (a = f));
        const c = this.subarray(f, a);
        return (Object.setPrototypeOf(c, u.prototype), c);
      };
      function X(p, f, a) {
        if (p % 1 !== 0 || p < 0) throw new RangeError("offset is not uint");
        if (p + f > a)
          throw new RangeError("Trying to access beyond buffer length");
      }
      ((u.prototype.readUintLE = u.prototype.readUIntLE =
        function (f, a, o) {
          ((f = f >>> 0), (a = a >>> 0), o || X(f, a, this.length));
          let c = this[f],
            _ = 1,
            w = 0;
          for (; ++w < a && (_ *= 256); ) c += this[f + w] * _;
          return c;
        }),
        (u.prototype.readUintBE = u.prototype.readUIntBE =
          function (f, a, o) {
            ((f = f >>> 0), (a = a >>> 0), o || X(f, a, this.length));
            let c = this[f + --a],
              _ = 1;
            for (; a > 0 && (_ *= 256); ) c += this[f + --a] * _;
            return c;
          }),
        (u.prototype.readUint8 = u.prototype.readUInt8 =
          function (f, a) {
            return ((f = f >>> 0), a || X(f, 1, this.length), this[f]);
          }),
        (u.prototype.readUint16LE = u.prototype.readUInt16LE =
          function (f, a) {
            return (
              (f = f >>> 0),
              a || X(f, 2, this.length),
              this[f] | (this[f + 1] << 8)
            );
          }),
        (u.prototype.readUint16BE = u.prototype.readUInt16BE =
          function (f, a) {
            return (
              (f = f >>> 0),
              a || X(f, 2, this.length),
              (this[f] << 8) | this[f + 1]
            );
          }),
        (u.prototype.readUint32LE = u.prototype.readUInt32LE =
          function (f, a) {
            return (
              (f = f >>> 0),
              a || X(f, 4, this.length),
              (this[f] | (this[f + 1] << 8) | (this[f + 2] << 16)) +
                this[f + 3] * 16777216
            );
          }),
        (u.prototype.readUint32BE = u.prototype.readUInt32BE =
          function (f, a) {
            return (
              (f = f >>> 0),
              a || X(f, 4, this.length),
              this[f] * 16777216 +
                ((this[f + 1] << 16) | (this[f + 2] << 8) | this[f + 3])
            );
          }),
        (u.prototype.readBigUInt64LE = Me(function (f) {
          ((f = f >>> 0), _t(f, "offset"));
          const a = this[f],
            o = this[f + 7];
          (a === void 0 || o === void 0) && pt(f, this.length - 8);
          const c =
              a +
              this[++f] * 2 ** 8 +
              this[++f] * 2 ** 16 +
              this[++f] * 2 ** 24,
            _ =
              this[++f] +
              this[++f] * 2 ** 8 +
              this[++f] * 2 ** 16 +
              o * 2 ** 24;
          return BigInt(c) + (BigInt(_) << BigInt(32));
        })),
        (u.prototype.readBigUInt64BE = Me(function (f) {
          ((f = f >>> 0), _t(f, "offset"));
          const a = this[f],
            o = this[f + 7];
          (a === void 0 || o === void 0) && pt(f, this.length - 8);
          const c =
              a * 2 ** 24 +
              this[++f] * 2 ** 16 +
              this[++f] * 2 ** 8 +
              this[++f],
            _ =
              this[++f] * 2 ** 24 +
              this[++f] * 2 ** 16 +
              this[++f] * 2 ** 8 +
              o;
          return (BigInt(c) << BigInt(32)) + BigInt(_);
        })),
        (u.prototype.readIntLE = function (f, a, o) {
          ((f = f >>> 0), (a = a >>> 0), o || X(f, a, this.length));
          let c = this[f],
            _ = 1,
            w = 0;
          for (; ++w < a && (_ *= 256); ) c += this[f + w] * _;
          return ((_ *= 128), c >= _ && (c -= Math.pow(2, 8 * a)), c);
        }),
        (u.prototype.readIntBE = function (f, a, o) {
          ((f = f >>> 0), (a = a >>> 0), o || X(f, a, this.length));
          let c = a,
            _ = 1,
            w = this[f + --c];
          for (; c > 0 && (_ *= 256); ) w += this[f + --c] * _;
          return ((_ *= 128), w >= _ && (w -= Math.pow(2, 8 * a)), w);
        }),
        (u.prototype.readInt8 = function (f, a) {
          return (
            (f = f >>> 0),
            a || X(f, 1, this.length),
            this[f] & 128 ? (255 - this[f] + 1) * -1 : this[f]
          );
        }),
        (u.prototype.readInt16LE = function (f, a) {
          ((f = f >>> 0), a || X(f, 2, this.length));
          const o = this[f] | (this[f + 1] << 8);
          return o & 32768 ? o | 4294901760 : o;
        }),
        (u.prototype.readInt16BE = function (f, a) {
          ((f = f >>> 0), a || X(f, 2, this.length));
          const o = this[f + 1] | (this[f] << 8);
          return o & 32768 ? o | 4294901760 : o;
        }),
        (u.prototype.readInt32LE = function (f, a) {
          return (
            (f = f >>> 0),
            a || X(f, 4, this.length),
            this[f] |
              (this[f + 1] << 8) |
              (this[f + 2] << 16) |
              (this[f + 3] << 24)
          );
        }),
        (u.prototype.readInt32BE = function (f, a) {
          return (
            (f = f >>> 0),
            a || X(f, 4, this.length),
            (this[f] << 24) |
              (this[f + 1] << 16) |
              (this[f + 2] << 8) |
              this[f + 3]
          );
        }),
        (u.prototype.readBigInt64LE = Me(function (f) {
          ((f = f >>> 0), _t(f, "offset"));
          const a = this[f],
            o = this[f + 7];
          (a === void 0 || o === void 0) && pt(f, this.length - 8);
          const c =
            this[f + 4] +
            this[f + 5] * 2 ** 8 +
            this[f + 6] * 2 ** 16 +
            (o << 24);
          return (
            (BigInt(c) << BigInt(32)) +
            BigInt(
              a +
                this[++f] * 2 ** 8 +
                this[++f] * 2 ** 16 +
                this[++f] * 2 ** 24,
            )
          );
        })),
        (u.prototype.readBigInt64BE = Me(function (f) {
          ((f = f >>> 0), _t(f, "offset"));
          const a = this[f],
            o = this[f + 7];
          (a === void 0 || o === void 0) && pt(f, this.length - 8);
          const c =
            (a << 24) + this[++f] * 2 ** 16 + this[++f] * 2 ** 8 + this[++f];
          return (
            (BigInt(c) << BigInt(32)) +
            BigInt(
              this[++f] * 2 ** 24 +
                this[++f] * 2 ** 16 +
                this[++f] * 2 ** 8 +
                o,
            )
          );
        })),
        (u.prototype.readFloatLE = function (f, a) {
          return (
            (f = f >>> 0),
            a || X(f, 4, this.length),
            i.read(this, f, !0, 23, 4)
          );
        }),
        (u.prototype.readFloatBE = function (f, a) {
          return (
            (f = f >>> 0),
            a || X(f, 4, this.length),
            i.read(this, f, !1, 23, 4)
          );
        }),
        (u.prototype.readDoubleLE = function (f, a) {
          return (
            (f = f >>> 0),
            a || X(f, 8, this.length),
            i.read(this, f, !0, 52, 8)
          );
        }),
        (u.prototype.readDoubleBE = function (f, a) {
          return (
            (f = f >>> 0),
            a || X(f, 8, this.length),
            i.read(this, f, !1, 52, 8)
          );
        }));
      function ie(p, f, a, o, c, _) {
        if (!u.isBuffer(p))
          throw new TypeError('"buffer" argument must be a Buffer instance');
        if (f > c || f < _)
          throw new RangeError('"value" argument is out of bounds');
        if (a + o > p.length) throw new RangeError("Index out of range");
      }
      ((u.prototype.writeUintLE = u.prototype.writeUIntLE =
        function (f, a, o, c) {
          if (((f = +f), (a = a >>> 0), (o = o >>> 0), !c)) {
            const B = Math.pow(2, 8 * o) - 1;
            ie(this, f, a, o, B, 0);
          }
          let _ = 1,
            w = 0;
          for (this[a] = f & 255; ++w < o && (_ *= 256); )
            this[a + w] = (f / _) & 255;
          return a + o;
        }),
        (u.prototype.writeUintBE = u.prototype.writeUIntBE =
          function (f, a, o, c) {
            if (((f = +f), (a = a >>> 0), (o = o >>> 0), !c)) {
              const B = Math.pow(2, 8 * o) - 1;
              ie(this, f, a, o, B, 0);
            }
            let _ = o - 1,
              w = 1;
            for (this[a + _] = f & 255; --_ >= 0 && (w *= 256); )
              this[a + _] = (f / w) & 255;
            return a + o;
          }),
        (u.prototype.writeUint8 = u.prototype.writeUInt8 =
          function (f, a, o) {
            return (
              (f = +f),
              (a = a >>> 0),
              o || ie(this, f, a, 1, 255, 0),
              (this[a] = f & 255),
              a + 1
            );
          }),
        (u.prototype.writeUint16LE = u.prototype.writeUInt16LE =
          function (f, a, o) {
            return (
              (f = +f),
              (a = a >>> 0),
              o || ie(this, f, a, 2, 65535, 0),
              (this[a] = f & 255),
              (this[a + 1] = f >>> 8),
              a + 2
            );
          }),
        (u.prototype.writeUint16BE = u.prototype.writeUInt16BE =
          function (f, a, o) {
            return (
              (f = +f),
              (a = a >>> 0),
              o || ie(this, f, a, 2, 65535, 0),
              (this[a] = f >>> 8),
              (this[a + 1] = f & 255),
              a + 2
            );
          }),
        (u.prototype.writeUint32LE = u.prototype.writeUInt32LE =
          function (f, a, o) {
            return (
              (f = +f),
              (a = a >>> 0),
              o || ie(this, f, a, 4, 4294967295, 0),
              (this[a + 3] = f >>> 24),
              (this[a + 2] = f >>> 16),
              (this[a + 1] = f >>> 8),
              (this[a] = f & 255),
              a + 4
            );
          }),
        (u.prototype.writeUint32BE = u.prototype.writeUInt32BE =
          function (f, a, o) {
            return (
              (f = +f),
              (a = a >>> 0),
              o || ie(this, f, a, 4, 4294967295, 0),
              (this[a] = f >>> 24),
              (this[a + 1] = f >>> 16),
              (this[a + 2] = f >>> 8),
              (this[a + 3] = f & 255),
              a + 4
            );
          }));
      function ae(p, f, a, o, c) {
        dt(f, o, c, p, a, 7);
        let _ = Number(f & BigInt(4294967295));
        ((p[a++] = _),
          (_ = _ >> 8),
          (p[a++] = _),
          (_ = _ >> 8),
          (p[a++] = _),
          (_ = _ >> 8),
          (p[a++] = _));
        let w = Number((f >> BigInt(32)) & BigInt(4294967295));
        return (
          (p[a++] = w),
          (w = w >> 8),
          (p[a++] = w),
          (w = w >> 8),
          (p[a++] = w),
          (w = w >> 8),
          (p[a++] = w),
          a
        );
      }
      function le(p, f, a, o, c) {
        dt(f, o, c, p, a, 7);
        let _ = Number(f & BigInt(4294967295));
        ((p[a + 7] = _),
          (_ = _ >> 8),
          (p[a + 6] = _),
          (_ = _ >> 8),
          (p[a + 5] = _),
          (_ = _ >> 8),
          (p[a + 4] = _));
        let w = Number((f >> BigInt(32)) & BigInt(4294967295));
        return (
          (p[a + 3] = w),
          (w = w >> 8),
          (p[a + 2] = w),
          (w = w >> 8),
          (p[a + 1] = w),
          (w = w >> 8),
          (p[a] = w),
          a + 8
        );
      }
      ((u.prototype.writeBigUInt64LE = Me(function (f, a = 0) {
        return ae(this, f, a, BigInt(0), BigInt("0xffffffffffffffff"));
      })),
        (u.prototype.writeBigUInt64BE = Me(function (f, a = 0) {
          return le(this, f, a, BigInt(0), BigInt("0xffffffffffffffff"));
        })),
        (u.prototype.writeIntLE = function (f, a, o, c) {
          if (((f = +f), (a = a >>> 0), !c)) {
            const U = Math.pow(2, 8 * o - 1);
            ie(this, f, a, o, U - 1, -U);
          }
          let _ = 0,
            w = 1,
            B = 0;
          for (this[a] = f & 255; ++_ < o && (w *= 256); )
            (f < 0 && B === 0 && this[a + _ - 1] !== 0 && (B = 1),
              (this[a + _] = (((f / w) >> 0) - B) & 255));
          return a + o;
        }),
        (u.prototype.writeIntBE = function (f, a, o, c) {
          if (((f = +f), (a = a >>> 0), !c)) {
            const U = Math.pow(2, 8 * o - 1);
            ie(this, f, a, o, U - 1, -U);
          }
          let _ = o - 1,
            w = 1,
            B = 0;
          for (this[a + _] = f & 255; --_ >= 0 && (w *= 256); )
            (f < 0 && B === 0 && this[a + _ + 1] !== 0 && (B = 1),
              (this[a + _] = (((f / w) >> 0) - B) & 255));
          return a + o;
        }),
        (u.prototype.writeInt8 = function (f, a, o) {
          return (
            (f = +f),
            (a = a >>> 0),
            o || ie(this, f, a, 1, 127, -128),
            f < 0 && (f = 255 + f + 1),
            (this[a] = f & 255),
            a + 1
          );
        }),
        (u.prototype.writeInt16LE = function (f, a, o) {
          return (
            (f = +f),
            (a = a >>> 0),
            o || ie(this, f, a, 2, 32767, -32768),
            (this[a] = f & 255),
            (this[a + 1] = f >>> 8),
            a + 2
          );
        }),
        (u.prototype.writeInt16BE = function (f, a, o) {
          return (
            (f = +f),
            (a = a >>> 0),
            o || ie(this, f, a, 2, 32767, -32768),
            (this[a] = f >>> 8),
            (this[a + 1] = f & 255),
            a + 2
          );
        }),
        (u.prototype.writeInt32LE = function (f, a, o) {
          return (
            (f = +f),
            (a = a >>> 0),
            o || ie(this, f, a, 4, 2147483647, -2147483648),
            (this[a] = f & 255),
            (this[a + 1] = f >>> 8),
            (this[a + 2] = f >>> 16),
            (this[a + 3] = f >>> 24),
            a + 4
          );
        }),
        (u.prototype.writeInt32BE = function (f, a, o) {
          return (
            (f = +f),
            (a = a >>> 0),
            o || ie(this, f, a, 4, 2147483647, -2147483648),
            f < 0 && (f = 4294967295 + f + 1),
            (this[a] = f >>> 24),
            (this[a + 1] = f >>> 16),
            (this[a + 2] = f >>> 8),
            (this[a + 3] = f & 255),
            a + 4
          );
        }),
        (u.prototype.writeBigInt64LE = Me(function (f, a = 0) {
          return ae(
            this,
            f,
            a,
            -BigInt("0x8000000000000000"),
            BigInt("0x7fffffffffffffff"),
          );
        })),
        (u.prototype.writeBigInt64BE = Me(function (f, a = 0) {
          return le(
            this,
            f,
            a,
            -BigInt("0x8000000000000000"),
            BigInt("0x7fffffffffffffff"),
          );
        })));
      function tt(p, f, a, o, c, _) {
        if (a + o > p.length) throw new RangeError("Index out of range");
        if (a < 0) throw new RangeError("Index out of range");
      }
      function rt(p, f, a, o, c) {
        return (
          (f = +f),
          (a = a >>> 0),
          c || tt(p, f, a, 4),
          i.write(p, f, a, o, 23, 4),
          a + 4
        );
      }
      ((u.prototype.writeFloatLE = function (f, a, o) {
        return rt(this, f, a, !0, o);
      }),
        (u.prototype.writeFloatBE = function (f, a, o) {
          return rt(this, f, a, !1, o);
        }));
      function ut(p, f, a, o, c) {
        return (
          (f = +f),
          (a = a >>> 0),
          c || tt(p, f, a, 8),
          i.write(p, f, a, o, 52, 8),
          a + 8
        );
      }
      ((u.prototype.writeDoubleLE = function (f, a, o) {
        return ut(this, f, a, !0, o);
      }),
        (u.prototype.writeDoubleBE = function (f, a, o) {
          return ut(this, f, a, !1, o);
        }),
        (u.prototype.copy = function (f, a, o, c) {
          if (!u.isBuffer(f))
            throw new TypeError("argument should be a Buffer");
          if (
            (o || (o = 0),
            !c && c !== 0 && (c = this.length),
            a >= f.length && (a = f.length),
            a || (a = 0),
            c > 0 && c < o && (c = o),
            c === o || f.length === 0 || this.length === 0)
          )
            return 0;
          if (a < 0) throw new RangeError("targetStart out of bounds");
          if (o < 0 || o >= this.length)
            throw new RangeError("Index out of range");
          if (c < 0) throw new RangeError("sourceEnd out of bounds");
          (c > this.length && (c = this.length),
            f.length - a < c - o && (c = f.length - a + o));
          const _ = c - o;
          return (
            this === f && typeof Uint8Array.prototype.copyWithin == "function"
              ? this.copyWithin(a, o, c)
              : Uint8Array.prototype.set.call(f, this.subarray(o, c), a),
            _
          );
        }),
        (u.prototype.fill = function (f, a, o, c) {
          if (typeof f == "string") {
            if (
              (typeof a == "string"
                ? ((c = a), (a = 0), (o = this.length))
                : typeof o == "string" && ((c = o), (o = this.length)),
              c !== void 0 && typeof c != "string")
            )
              throw new TypeError("encoding must be a string");
            if (typeof c == "string" && !u.isEncoding(c))
              throw new TypeError("Unknown encoding: " + c);
            if (f.length === 1) {
              const w = f.charCodeAt(0);
              ((c === "utf8" && w < 128) || c === "latin1") && (f = w);
            }
          } else
            typeof f == "number"
              ? (f = f & 255)
              : typeof f == "boolean" && (f = Number(f));
          if (a < 0 || this.length < a || this.length < o)
            throw new RangeError("Out of range index");
          if (o <= a) return this;
          ((a = a >>> 0),
            (o = o === void 0 ? this.length : o >>> 0),
            f || (f = 0));
          let _;
          if (typeof f == "number") for (_ = a; _ < o; ++_) this[_] = f;
          else {
            const w = u.isBuffer(f) ? f : u.from(f, c),
              B = w.length;
            if (B === 0)
              throw new TypeError(
                'The value "' + f + '" is invalid for argument "value"',
              );
            for (_ = 0; _ < o - a; ++_) this[_ + a] = w[_ % B];
          }
          return this;
        }));
      const Le = {};
      function ft(p, f, a) {
        Le[p] = class extends a {
          constructor() {
            (super(),
              Object.defineProperty(this, "message", {
                value: f.apply(this, arguments),
                writable: !0,
                configurable: !0,
              }),
              (this.name = `${this.name} [${p}]`),
              this.stack,
              delete this.name);
          }
          get code() {
            return p;
          }
          set code(c) {
            Object.defineProperty(this, "code", {
              configurable: !0,
              enumerable: !0,
              value: c,
              writable: !0,
            });
          }
          toString() {
            return `${this.name} [${p}]: ${this.message}`;
          }
        };
      }
      (ft(
        "ERR_BUFFER_OUT_OF_BOUNDS",
        function (p) {
          return p
            ? `${p} is outside of buffer bounds`
            : "Attempt to access memory outside buffer bounds";
        },
        RangeError,
      ),
        ft(
          "ERR_INVALID_ARG_TYPE",
          function (p, f) {
            return `The "${p}" argument must be of type number. Received type ${typeof f}`;
          },
          TypeError,
        ),
        ft(
          "ERR_OUT_OF_RANGE",
          function (p, f, a) {
            let o = `The value of "${p}" is out of range.`,
              c = a;
            return (
              Number.isInteger(a) && Math.abs(a) > 2 ** 32
                ? (c = ze(String(a)))
                : typeof a == "bigint" &&
                  ((c = String(a)),
                  (a > BigInt(2) ** BigInt(32) ||
                    a < -(BigInt(2) ** BigInt(32))) &&
                    (c = ze(c)),
                  (c += "n")),
              (o += ` It must be ${f}. Received ${c}`),
              o
            );
          },
          RangeError,
        ));
      function ze(p) {
        let f = "",
          a = p.length;
        const o = p[0] === "-" ? 1 : 0;
        for (; a >= o + 4; a -= 3) f = `_${p.slice(a - 3, a)}${f}`;
        return `${p.slice(0, a)}${f}`;
      }
      function ht(p, f, a) {
        (_t(f, "offset"),
          (p[f] === void 0 || p[f + a] === void 0) &&
            pt(f, p.length - (a + 1)));
      }
      function dt(p, f, a, o, c, _) {
        if (p > a || p < f) {
          const w = typeof f == "bigint" ? "n" : "";
          let B;
          throw (
            f === 0 || f === BigInt(0)
              ? (B = `>= 0${w} and < 2${w} ** ${(_ + 1) * 8}${w}`)
              : (B = `>= -(2${w} ** ${(_ + 1) * 8 - 1}${w}) and < 2 ** ${(_ + 1) * 8 - 1}${w}`),
            new Le.ERR_OUT_OF_RANGE("value", B, p)
          );
        }
        ht(o, c, _);
      }
      function _t(p, f) {
        if (typeof p != "number")
          throw new Le.ERR_INVALID_ARG_TYPE(f, "number", p);
      }
      function pt(p, f, a) {
        throw Math.floor(p) !== p
          ? (_t(p, a), new Le.ERR_OUT_OF_RANGE("offset", "an integer", p))
          : f < 0
            ? new Le.ERR_BUFFER_OUT_OF_BOUNDS()
            : new Le.ERR_OUT_OF_RANGE("offset", `>= 0 and <= ${f}`, p);
      }
      const wt = /[^+/0-9A-Za-z-_]/g;
      function xt(p) {
        if (
          ((p = p.split("=")[0]), (p = p.trim().replace(wt, "")), p.length < 2)
        )
          return "";
        for (; p.length % 4 !== 0; ) p = p + "=";
        return p;
      }
      function dr(p, f) {
        f = f || 1 / 0;
        let a;
        const o = p.length;
        let c = null;
        const _ = [];
        for (let w = 0; w < o; ++w) {
          if (((a = p.charCodeAt(w)), a > 55295 && a < 57344)) {
            if (!c) {
              if (a > 56319) {
                (f -= 3) > -1 && _.push(239, 191, 189);
                continue;
              } else if (w + 1 === o) {
                (f -= 3) > -1 && _.push(239, 191, 189);
                continue;
              }
              c = a;
              continue;
            }
            if (a < 56320) {
              ((f -= 3) > -1 && _.push(239, 191, 189), (c = a));
              continue;
            }
            a = (((c - 55296) << 10) | (a - 56320)) + 65536;
          } else c && (f -= 3) > -1 && _.push(239, 191, 189);
          if (((c = null), a < 128)) {
            if ((f -= 1) < 0) break;
            _.push(a);
          } else if (a < 2048) {
            if ((f -= 2) < 0) break;
            _.push((a >> 6) | 192, (a & 63) | 128);
          } else if (a < 65536) {
            if ((f -= 3) < 0) break;
            _.push((a >> 12) | 224, ((a >> 6) & 63) | 128, (a & 63) | 128);
          } else if (a < 1114112) {
            if ((f -= 4) < 0) break;
            _.push(
              (a >> 18) | 240,
              ((a >> 12) & 63) | 128,
              ((a >> 6) & 63) | 128,
              (a & 63) | 128,
            );
          } else throw new Error("Invalid code point");
        }
        return _;
      }
      function zn(p) {
        const f = [];
        for (let a = 0; a < p.length; ++a) f.push(p.charCodeAt(a) & 255);
        return f;
      }
      function _r(p, f) {
        let a, o, c;
        const _ = [];
        for (let w = 0; w < p.length && !((f -= 2) < 0); ++w)
          ((a = p.charCodeAt(w)),
            (o = a >> 8),
            (c = a % 256),
            _.push(c),
            _.push(o));
        return _;
      }
      function jr(p) {
        return n.toByteArray(xt(p));
      }
      function Vt(p, f, a, o) {
        let c;
        for (c = 0; c < o && !(c + a >= f.length || c >= p.length); ++c)
          f[c + a] = p[c];
        return c;
      }
      function Ce(p, f) {
        return (
          p instanceof f ||
          (p != null &&
            p.constructor != null &&
            p.constructor.name != null &&
            p.constructor.name === f.name)
        );
      }
      function gt(p) {
        return p !== p;
      }
      const Fe = (function () {
        const p = "0123456789abcdef",
          f = new Array(256);
        for (let a = 0; a < 16; ++a) {
          const o = a * 16;
          for (let c = 0; c < 16; ++c) f[o + c] = p[a] + p[c];
        }
        return f;
      })();
      function Me(p) {
        return typeof BigInt > "u" ? Fn : p;
      }
      function Fn() {
        throw new Error("BigInt not supported");
      }
    },
    526: (e, r) => {
      ((r.byteLength = u), (r.toByteArray = E), (r.fromByteArray = I));
      for (
        var t = [],
          n = [],
          i = typeof Uint8Array < "u" ? Uint8Array : Array,
          s =
            "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/",
          l = 0,
          h = s.length;
        l < h;
        ++l
      )
        ((t[l] = s[l]), (n[s.charCodeAt(l)] = l));
      ((n[45] = 62), (n[95] = 63));
      function g(x) {
        var T = x.length;
        if (T % 4 > 0)
          throw new Error("Invalid string. Length must be a multiple of 4");
        var R = x.indexOf("=");
        R === -1 && (R = T);
        var $ = R === T ? 0 : 4 - (R % 4);
        return [R, $];
      }
      function u(x) {
        var T = g(x),
          R = T[0],
          $ = T[1];
        return ((R + $) * 3) / 4 - $;
      }
      function d(x, T, R) {
        return ((T + R) * 3) / 4 - R;
      }
      function E(x) {
        var T,
          R = g(x),
          $ = R[0],
          D = R[1],
          m = new i(d(x, $, D)),
          z = 0,
          V = D > 0 ? $ - 4 : $,
          C;
        for (C = 0; C < V; C += 4)
          ((T =
            (n[x.charCodeAt(C)] << 18) |
            (n[x.charCodeAt(C + 1)] << 12) |
            (n[x.charCodeAt(C + 2)] << 6) |
            n[x.charCodeAt(C + 3)]),
            (m[z++] = (T >> 16) & 255),
            (m[z++] = (T >> 8) & 255),
            (m[z++] = T & 255));
        return (
          D === 2 &&
            ((T = (n[x.charCodeAt(C)] << 2) | (n[x.charCodeAt(C + 1)] >> 4)),
            (m[z++] = T & 255)),
          D === 1 &&
            ((T =
              (n[x.charCodeAt(C)] << 10) |
              (n[x.charCodeAt(C + 1)] << 4) |
              (n[x.charCodeAt(C + 2)] >> 2)),
            (m[z++] = (T >> 8) & 255),
            (m[z++] = T & 255)),
          m
        );
      }
      function b(x) {
        return (
          t[(x >> 18) & 63] + t[(x >> 12) & 63] + t[(x >> 6) & 63] + t[x & 63]
        );
      }
      function y(x, T, R) {
        for (var $, D = [], m = T; m < R; m += 3)
          (($ =
            ((x[m] << 16) & 16711680) +
            ((x[m + 1] << 8) & 65280) +
            (x[m + 2] & 255)),
            D.push(b($)));
        return D.join("");
      }
      function I(x) {
        for (
          var T, R = x.length, $ = R % 3, D = [], m = 16383, z = 0, V = R - $;
          z < V;
          z += m
        )
          D.push(y(x, z, z + m > V ? V : z + m));
        return (
          $ === 1
            ? ((T = x[R - 1]), D.push(t[T >> 2] + t[(T << 4) & 63] + "=="))
            : $ === 2 &&
              ((T = (x[R - 2] << 8) + x[R - 1]),
              D.push(t[T >> 10] + t[(T >> 4) & 63] + t[(T << 2) & 63] + "=")),
          D.join("")
        );
      }
    },
    733: () => {},
    736: (e, r, t) => {
      function n(i) {
        ((l.debug = l),
          (l.default = l),
          (l.coerce = b),
          (l.disable = u),
          (l.enable = g),
          (l.enabled = d),
          (l.humanize = t(0)),
          (l.destroy = y),
          Object.keys(i).forEach((I) => {
            l[I] = i[I];
          }),
          (l.names = []),
          (l.skips = []),
          (l.formatters = {}));
        function s(I) {
          let x = 0;
          for (let T = 0; T < I.length; T++)
            ((x = (x << 5) - x + I.charCodeAt(T)), (x |= 0));
          return l.colors[Math.abs(x) % l.colors.length];
        }
        l.selectColor = s;
        function l(I) {
          let x,
            T = null,
            R,
            $;
          function D(...m) {
            if (!D.enabled) return;
            const z = D,
              V = Number(new Date()),
              C = V - (x || V);
            ((z.diff = C),
              (z.prev = x),
              (z.curr = V),
              (x = V),
              (m[0] = l.coerce(m[0])),
              typeof m[0] != "string" && m.unshift("%O"));
            let H = 0;
            ((m[0] = m[0].replace(/%([a-zA-Z%])/g, (N, F) => {
              if (N === "%%") return "%";
              H++;
              const se = l.formatters[F];
              if (typeof se == "function") {
                const A = m[H];
                ((N = se.call(z, A)), m.splice(H, 1), H--);
              }
              return N;
            })),
              l.formatArgs.call(z, m),
              (z.log || l.log).apply(z, m));
          }
          return (
            (D.namespace = I),
            (D.useColors = l.useColors()),
            (D.color = l.selectColor(I)),
            (D.extend = h),
            (D.destroy = l.destroy),
            Object.defineProperty(D, "enabled", {
              enumerable: !0,
              configurable: !1,
              get: () =>
                T !== null
                  ? T
                  : (R !== l.namespaces &&
                      ((R = l.namespaces), ($ = l.enabled(I))),
                    $),
              set: (m) => {
                T = m;
              },
            }),
            typeof l.init == "function" && l.init(D),
            D
          );
        }
        function h(I, x) {
          const T = l(this.namespace + (typeof x > "u" ? ":" : x) + I);
          return ((T.log = this.log), T);
        }
        function g(I) {
          (l.save(I), (l.namespaces = I), (l.names = []), (l.skips = []));
          let x;
          const T = (typeof I == "string" ? I : "").split(/[\s,]+/),
            R = T.length;
          for (x = 0; x < R; x++)
            T[x] &&
              ((I = T[x].replace(/\*/g, ".*?")),
              I[0] === "-"
                ? l.skips.push(new RegExp("^" + I.slice(1) + "$"))
                : l.names.push(new RegExp("^" + I + "$")));
        }
        function u() {
          const I = [
            ...l.names.map(E),
            ...l.skips.map(E).map((x) => "-" + x),
          ].join(",");
          return (l.enable(""), I);
        }
        function d(I) {
          if (I[I.length - 1] === "*") return !0;
          let x, T;
          for (x = 0, T = l.skips.length; x < T; x++)
            if (l.skips[x].test(I)) return !1;
          for (x = 0, T = l.names.length; x < T; x++)
            if (l.names[x].test(I)) return !0;
          return !1;
        }
        function E(I) {
          return I.toString()
            .substring(2, I.toString().length - 2)
            .replace(/\.\*\?$/, "*");
        }
        function b(I) {
          return I instanceof Error ? I.stack || I.message : I;
        }
        function y() {
          console.warn(
            "Instance method `debug.destroy()` is deprecated and no longer does anything. It will be removed in the next major version of `debug`.",
          );
        }
        return (l.enable(l.load()), l);
      }
      e.exports = n;
    },
    833: (e, r, t) => {
      var n = t(19);
      ((r.formatArgs = s),
        (r.save = l),
        (r.load = h),
        (r.useColors = i),
        (r.storage = g()),
        (r.destroy = (() => {
          let d = !1;
          return () => {
            d ||
              ((d = !0),
              console.warn(
                "Instance method `debug.destroy()` is deprecated and no longer does anything. It will be removed in the next major version of `debug`.",
              ));
          };
        })()),
        (r.colors = [
          "#0000CC",
          "#0000FF",
          "#0033CC",
          "#0033FF",
          "#0066CC",
          "#0066FF",
          "#0099CC",
          "#0099FF",
          "#00CC00",
          "#00CC33",
          "#00CC66",
          "#00CC99",
          "#00CCCC",
          "#00CCFF",
          "#3300CC",
          "#3300FF",
          "#3333CC",
          "#3333FF",
          "#3366CC",
          "#3366FF",
          "#3399CC",
          "#3399FF",
          "#33CC00",
          "#33CC33",
          "#33CC66",
          "#33CC99",
          "#33CCCC",
          "#33CCFF",
          "#6600CC",
          "#6600FF",
          "#6633CC",
          "#6633FF",
          "#66CC00",
          "#66CC33",
          "#9900CC",
          "#9900FF",
          "#9933CC",
          "#9933FF",
          "#99CC00",
          "#99CC33",
          "#CC0000",
          "#CC0033",
          "#CC0066",
          "#CC0099",
          "#CC00CC",
          "#CC00FF",
          "#CC3300",
          "#CC3333",
          "#CC3366",
          "#CC3399",
          "#CC33CC",
          "#CC33FF",
          "#CC6600",
          "#CC6633",
          "#CC9900",
          "#CC9933",
          "#CCCC00",
          "#CCCC33",
          "#FF0000",
          "#FF0033",
          "#FF0066",
          "#FF0099",
          "#FF00CC",
          "#FF00FF",
          "#FF3300",
          "#FF3333",
          "#FF3366",
          "#FF3399",
          "#FF33CC",
          "#FF33FF",
          "#FF6600",
          "#FF6633",
          "#FF9900",
          "#FF9933",
          "#FFCC00",
          "#FFCC33",
        ]));
      function i() {
        return typeof window < "u" &&
          window.process &&
          (window.process.type === "renderer" || window.process.__nwjs)
          ? !0
          : typeof navigator < "u" &&
              navigator.userAgent &&
              navigator.userAgent.toLowerCase().match(/(edge|trident)\/(\d+)/)
            ? !1
            : (typeof document < "u" &&
                document.documentElement &&
                document.documentElement.style &&
                document.documentElement.style.WebkitAppearance) ||
              (typeof window < "u" &&
                window.console &&
                (window.console.firebug ||
                  (window.console.exception && window.console.table))) ||
              (typeof navigator < "u" &&
                navigator.userAgent &&
                navigator.userAgent.toLowerCase().match(/firefox\/(\d+)/) &&
                parseInt(RegExp.$1, 10) >= 31) ||
              (typeof navigator < "u" &&
                navigator.userAgent &&
                navigator.userAgent.toLowerCase().match(/applewebkit\/(\d+)/));
      }
      function s(d) {
        if (
          ((d[0] =
            (this.useColors ? "%c" : "") +
            this.namespace +
            (this.useColors ? " %c" : " ") +
            d[0] +
            (this.useColors ? "%c " : " ") +
            "+" +
            e.exports.humanize(this.diff)),
          !this.useColors)
        )
          return;
        const E = "color: " + this.color;
        d.splice(1, 0, E, "color: inherit");
        let b = 0,
          y = 0;
        (d[0].replace(/%[a-zA-Z%]/g, (I) => {
          I !== "%%" && (b++, I === "%c" && (y = b));
        }),
          d.splice(y, 0, E));
      }
      r.log = console.debug || console.log || (() => {});
      function l(d) {
        try {
          d ? r.storage.setItem("debug", d) : r.storage.removeItem("debug");
        } catch {}
      }
      function h() {
        let d;
        try {
          d = r.storage.getItem("debug");
        } catch {}
        return (!d && typeof n < "u" && "env" in n && (d = n.env.DEBUG), d);
      }
      function g() {
        try {
          return localStorage;
        } catch {}
      }
      e.exports = t(736)(r);
      const { formatters: u } = e.exports;
      u.j = function (d) {
        try {
          return JSON.stringify(d);
        } catch (E) {
          return "[UnexpectedJSONParseError]: " + E.message;
        }
      };
    },
  },
  La = {};
function Ee(e) {
  var r = La[e];
  if (r !== void 0) return r.exports;
  var t = (La[e] = { exports: {} });
  return ($u[e](t, t.exports, Ee), t.exports);
}
Ee.n = (e) => {
  var r = e && e.__esModule ? () => e.default : () => e;
  return (Ee.d(r, { a: r }), r);
};
(() => {
  var e = Object.getPrototypeOf
      ? (t) => Object.getPrototypeOf(t)
      : (t) => t.__proto__,
    r;
  Ee.t = function (t, n) {
    if (
      (n & 1 && (t = this(t)),
      n & 8 ||
        (typeof t == "object" &&
          t &&
          ((n & 4 && t.__esModule) || (n & 16 && typeof t.then == "function"))))
    )
      return t;
    var i = Object.create(null);
    Ee.r(i);
    var s = {};
    r = r || [null, e({}), e([]), e(e)];
    for (var l = n & 2 && t; typeof l == "object" && !~r.indexOf(l); l = e(l))
      Object.getOwnPropertyNames(l).forEach((h) => (s[h] = () => t[h]));
    return ((s.default = () => t), Ee.d(i, s), i);
  };
})();
Ee.d = (e, r) => {
  for (var t in r)
    Ee.o(r, t) &&
      !Ee.o(e, t) &&
      Object.defineProperty(e, t, { enumerable: !0, get: r[t] });
};
Ee.o = (e, r) => Object.prototype.hasOwnProperty.call(e, r);
Ee.r = (e) => {
  (typeof Symbol < "u" &&
    Symbol.toStringTag &&
    Object.defineProperty(e, Symbol.toStringTag, { value: "Module" }),
    Object.defineProperty(e, "__esModule", { value: !0 }));
};
function* Lu() {
  const e = [1, 1, 1, 2, 4, 8, 16, 32, 64];
  let r = 0;
  for (;;) yield e[Math.min(r++, e.length - 1)];
}
function* za(e) {
  for (const r of e) yield r;
}
async function Fa(e, r = Lu()) {
  for (;;)
    try {
      return await e();
    } catch (t) {
      const n = r.next().value;
      if (n === void 0) throw t;
      await new Promise((i) => setTimeout(i, n * 1e3));
      continue;
    }
}
class zu {
  constructor(r) {
    this.numPoints = r;
  }
  async init() {
    (await this.downloadG1Data(), await this.downloadG2Data());
  }
  async streamG1Data() {
    return (await this.fetchG1Data()).body;
  }
  async streamG2Data() {
    return (await this.fetchG2Data()).body;
  }
  async downloadG1Data() {
    const r = await this.fetchG1Data();
    return (this.data = new Uint8Array(await r.arrayBuffer()));
  }
  async downloadG2Data() {
    const r = await this.fetchG2Data();
    return (this.g2Data = new Uint8Array(await r.arrayBuffer()));
  }
  getG1Data() {
    return this.data;
  }
  getG2Data() {
    return this.g2Data;
  }
  async fetchG1Data() {
    if (this.numPoints === 0) return new Response(new Uint8Array([]));
    const r = this.numPoints * 64 - 1;
    return await Fa(
      () =>
        fetch("https://crs.aztec.network/g1.dat", {
          headers: { Range: `bytes=0-${r}` },
          cache: "force-cache",
        }),
      za([5, 5, 5]),
    );
  }
  async fetchG2Data() {
    return await Fa(
      () => fetch("https://crs.aztec.network/g2.dat", { cache: "force-cache" }),
      za([5, 5, 5]),
    );
  }
}
class Fu {
  constructor(r) {
    this.numPoints = r;
  }
  async init() {
    await this.downloadG1Data();
  }
  async downloadG1Data() {
    const r = await this.fetchG1Data();
    return (this.data = new Uint8Array(await r.arrayBuffer()));
  }
  async streamG1Data() {
    return (await this.fetchG1Data()).body;
  }
  getG1Data() {
    return this.data;
  }
  async fetchG1Data() {
    if (this.numPoints === 0) return new Response(new Uint8Array([]));
    const r = this.numPoints * 64 - 1;
    return await fetch("https://crs.aztec.network/grumpkin_g1.dat", {
      headers: { Range: `bytes=0-${r}` },
      cache: "force-cache",
    });
  }
}
function zi(e) {
  return new Promise((r, t) => {
    ((e.oncomplete = e.onsuccess = () => r(e.result)),
      (e.onabort = e.onerror = () => t(e.error)));
  });
}
function Mu(e, r) {
  const t = indexedDB.open(e);
  t.onupgradeneeded = () => t.result.createObjectStore(r);
  const n = zi(t);
  return (i, s) => n.then((l) => s(l.transaction(r, i).objectStore(r)));
}
let Xn;
function bs() {
  return (Xn || (Xn = Mu("keyval-store", "keyval")), Xn);
}
function mi(e, r = bs()) {
  return r("readonly", (t) => zi(t.get(e)));
}
function Ei(e, r, t = bs()) {
  return t("readwrite", (n) => (n.put(r, e), zi(n.transaction)));
}
class mn {
  constructor(r) {
    this.numPoints = r;
  }
  static async new(r) {
    const t = new mn(r);
    return (await t.init(), t);
  }
  async init() {
    const r = await mi("g1Data"),
      t = await mi("g2Data"),
      n = new zu(this.numPoints),
      i = this.numPoints * 64;
    (!r || r.length < i
      ? ((this.g1Data = await n.downloadG1Data()),
        await Ei("g1Data", this.g1Data))
      : (this.g1Data = r),
      t
        ? (this.g2Data = t)
        : ((this.g2Data = await n.downloadG2Data()),
          await Ei("g2Data", this.g2Data)));
  }
  getG1Data() {
    return this.g1Data;
  }
  getG2Data() {
    return this.g2Data;
  }
}
class Fi {
  constructor(r) {
    this.numPoints = r;
  }
  static async new(r) {
    const t = new Fi(r);
    return (await t.init(), t);
  }
  async init() {
    const r = await mi("grumpkinG1Data"),
      t = new Fu(this.numPoints),
      n = this.numPoints * 64;
    !r || r.length < n
      ? ((this.g1Data = await t.downloadG1Data()),
        await Ei("grumpkinG1Data", this.g1Data))
      : (this.g1Data = r);
  }
  getG1Data() {
    return this.g1Data;
  }
}
const ms = Symbol("Comlink.proxy"),
  Pu = Symbol("Comlink.endpoint"),
  Zu = Symbol("Comlink.releaseProxy"),
  qn = Symbol("Comlink.finalizer"),
  dn = Symbol("Comlink.thrown"),
  Es = (e) => (typeof e == "object" && e !== null) || typeof e == "function",
  Hu = {
    canHandle: (e) => Es(e) && e[ms],
    serialize(e) {
      const { port1: r, port2: t } = new MessageChannel();
      return (Bs(e, r), [t, [t]]);
    },
    deserialize(e) {
      return (e.start(), Is(e));
    },
  },
  Wu = {
    canHandle: (e) => Es(e) && dn in e,
    serialize({ value: e }) {
      let r;
      return (
        e instanceof Error
          ? (r = {
              isError: !0,
              value: { message: e.message, name: e.name, stack: e.stack },
            })
          : (r = { isError: !1, value: e }),
        [r, []]
      );
    },
    deserialize(e) {
      throw e.isError
        ? Object.assign(new Error(e.value.message), e.value)
        : e.value;
    },
  },
  ks = new Map([
    ["proxy", Hu],
    ["throw", Wu],
  ]);
function Vu(e, r) {
  for (const t of e)
    if (r === t || t === "*" || (t instanceof RegExp && t.test(r))) return !0;
  return !1;
}
function Bs(e, r = globalThis, t = ["*"]) {
  (r.addEventListener("message", function n(i) {
    if (!i || !i.data) return;
    if (!Vu(t, i.origin)) {
      console.warn(`Invalid origin '${i.origin}' for comlink proxy`);
      return;
    }
    const { id: s, type: l, path: h } = Object.assign({ path: [] }, i.data),
      g = (i.data.argumentList || []).map(Dt);
    let u;
    try {
      const d = h.slice(0, -1).reduce((b, y) => b[y], e),
        E = h.reduce((b, y) => b[y], e);
      switch (l) {
        case "GET":
          u = E;
          break;
        case "SET":
          ((d[h.slice(-1)[0]] = Dt(i.data.value)), (u = !0));
          break;
        case "APPLY":
          u = E.apply(d, g);
          break;
        case "CONSTRUCT":
          {
            const b = new E(...g);
            u = xs(b);
          }
          break;
        case "ENDPOINT":
          {
            const { port1: b, port2: y } = new MessageChannel();
            (Bs(e, y), (u = Xu(b, [b])));
          }
          break;
        case "RELEASE":
          u = void 0;
          break;
        default:
          return;
      }
    } catch (d) {
      u = { value: d, [dn]: 0 };
    }
    Promise.resolve(u)
      .catch((d) => ({ value: d, [dn]: 0 }))
      .then((d) => {
        const [E, b] = Bn(d);
        (r.postMessage(Object.assign(Object.assign({}, E), { id: s }), b),
          l === "RELEASE" &&
            (r.removeEventListener("message", n),
            Ss(r),
            qn in e && typeof e[qn] == "function" && e[qn]()));
      })
      .catch((d) => {
        const [E, b] = Bn({
          value: new TypeError("Unserializable return value"),
          [dn]: 0,
        });
        r.postMessage(Object.assign(Object.assign({}, E), { id: s }), b);
      });
  }),
    r.start && r.start());
}
function Yu(e) {
  return e.constructor.name === "MessagePort";
}
function Ss(e) {
  Yu(e) && e.close();
}
function Is(e, r) {
  return ki(e, [], r);
}
function en(e) {
  if (e) throw new Error("Proxy has been released and is not useable");
}
function As(e) {
  return tr(e, { type: "RELEASE" }).then(() => {
    Ss(e);
  });
}
const En = new WeakMap(),
  kn =
    "FinalizationRegistry" in globalThis &&
    new FinalizationRegistry((e) => {
      const r = (En.get(e) || 0) - 1;
      (En.set(e, r), r === 0 && As(e));
    });
function Gu(e, r) {
  const t = (En.get(r) || 0) + 1;
  (En.set(r, t), kn && kn.register(e, r, e));
}
function ju(e) {
  kn && kn.unregister(e);
}
function ki(e, r = [], t = function () {}) {
  let n = !1;
  const i = new Proxy(t, {
    get(s, l) {
      if ((en(n), l === Zu))
        return () => {
          (ju(i), As(e), (n = !0));
        };
      if (l === "then") {
        if (r.length === 0) return { then: () => i };
        const h = tr(e, { type: "GET", path: r.map((g) => g.toString()) }).then(
          Dt,
        );
        return h.then.bind(h);
      }
      return ki(e, [...r, l]);
    },
    set(s, l, h) {
      en(n);
      const [g, u] = Bn(h);
      return tr(
        e,
        { type: "SET", path: [...r, l].map((d) => d.toString()), value: g },
        u,
      ).then(Dt);
    },
    apply(s, l, h) {
      en(n);
      const g = r[r.length - 1];
      if (g === Pu) return tr(e, { type: "ENDPOINT" }).then(Dt);
      if (g === "bind") return ki(e, r.slice(0, -1));
      const [u, d] = Ma(h);
      return tr(
        e,
        { type: "APPLY", path: r.map((E) => E.toString()), argumentList: u },
        d,
      ).then(Dt);
    },
    construct(s, l) {
      en(n);
      const [h, g] = Ma(l);
      return tr(
        e,
        {
          type: "CONSTRUCT",
          path: r.map((u) => u.toString()),
          argumentList: h,
        },
        g,
      ).then(Dt);
    },
  });
  return (Gu(i, e), i);
}
function Ku(e) {
  return Array.prototype.concat.apply([], e);
}
function Ma(e) {
  const r = e.map(Bn);
  return [r.map((t) => t[0]), Ku(r.map((t) => t[1]))];
}
const vs = new WeakMap();
function Xu(e, r) {
  return (vs.set(e, r), e);
}
function xs(e) {
  return Object.assign(e, { [ms]: !0 });
}
function Bn(e) {
  for (const [r, t] of ks)
    if (t.canHandle(e)) {
      const [n, i] = t.serialize(e);
      return [{ type: "HANDLER", name: r, value: n }, i];
    }
  return [{ type: "RAW", value: e }, vs.get(e) || []];
}
function Dt(e) {
  switch (e.type) {
    case "HANDLER":
      return ks.get(e.name).deserialize(e.value);
    case "RAW":
      return e.value;
  }
}
function tr(e, r, t) {
  return new Promise((n) => {
    const i = qu();
    (e.addEventListener("message", function s(l) {
      !l.data ||
        !l.data.id ||
        l.data.id !== i ||
        (e.removeEventListener("message", s), n(l.data));
    }),
      e.start && e.start(),
      e.postMessage(Object.assign({ id: i }, r), t));
  });
}
function qu() {
  return new Array(4)
    .fill(0)
    .map(() => Math.floor(Math.random() * Number.MAX_SAFE_INTEGER).toString(16))
    .join("-");
}
class ct extends Uint8Array {}
function Ju(e) {
  const r = new Uint8Array(1);
  return ((r[0] = e ? 1 : 0), r);
}
function Ts(e, r = 4) {
  const t = new Uint8Array(r);
  return (new DataView(t.buffer).setUint32(t.byteLength - 4, e, !1), t);
}
function Qu(e, r = 4) {
  const t = new Uint8Array(r);
  return (new DataView(t.buffer).setInt32(t.byteLength - 4, e, !1), t);
}
function Us(e) {
  const r = e.reduce((i, s) => i + s.length, 0),
    t = new Uint8Array(r);
  let n = 0;
  for (const i of e) (t.set(i, n), (n += i.length));
  return t;
}
function ef(e) {
  return e.reduce((r, t) => r + t.toString(16).padStart(2, "0"), "");
}
function Pa(e) {
  return Us([Qu(e.length), e]);
}
function tf(e, r = 32) {
  const t = new Uint8Array(r);
  for (let n = 0; n < r; n++)
    t[r - n - 1] = Number((e >> BigInt(n * 8)) & 0xffn);
  return t;
}
function rf(e) {
  return Us([Ts(e.length), ...e.flat()]);
}
function J(e) {
  return Array.isArray(e)
    ? rf(e.map(J))
    : e instanceof ct
      ? e
      : e instanceof Uint8Array
        ? Pa(e)
        : typeof e == "boolean"
          ? Ju(e)
          : typeof e == "number"
            ? Ts(e)
            : typeof e == "bigint"
              ? tf(e)
              : typeof e == "string"
                ? Pa(new TextEncoder().encode(e))
                : e.toBuffer();
}
class Ue {
  constructor(r, t = 0) {
    ((this.buffer = r), (this.index = t));
  }
  static asReader(r) {
    return r instanceof Ue ? r : new Ue(r);
  }
  readNumber() {
    const r = new DataView(
      this.buffer.buffer,
      this.buffer.byteOffset + this.index,
      4,
    );
    return ((this.index += 4), r.getUint32(0, !1));
  }
  readBoolean() {
    return ((this.index += 1), !!this.buffer.at(this.index - 1));
  }
  readBytes(r) {
    return ((this.index += r), this.buffer.slice(this.index - r, this.index));
  }
  readNumberVector() {
    return this.readVector({ fromBuffer: (r) => r.readNumber() });
  }
  readVector(r) {
    const t = this.readNumber(),
      n = new Array(t);
    for (let i = 0; i < t; i++) n[i] = r.fromBuffer(this);
    return n;
  }
  readArray(r, t) {
    const n = new Array(r);
    for (let i = 0; i < r; i++) n[i] = t.fromBuffer(this);
    return n;
  }
  readObject(r) {
    return r.fromBuffer(this);
  }
  peekBytes(r) {
    return this.buffer.subarray(this.index, r ? this.index + r : void 0);
  }
  readString() {
    return new TextDecoder().decode(this.readBuffer());
  }
  readBuffer() {
    const r = this.readNumber();
    return this.readBytes(r);
  }
  readMap(r) {
    const t = this.readNumber(),
      n = {};
    for (let i = 0; i < t; i++) {
      const s = this.readString(),
        l = this.readObject(r);
      n[s] = l;
    }
    return n;
  }
}
function bt() {
  return { SIZE_IN_BYTES: 1, fromBuffer: (e) => Ue.asReader(e).readBoolean() };
}
function Jn() {
  return { SIZE_IN_BYTES: 4, fromBuffer: (e) => Ue.asReader(e).readNumber() };
}
function qt(e) {
  return { fromBuffer: (r) => Ue.asReader(r).readVector(e) };
}
function Ae() {
  return { fromBuffer: (e) => Ue.asReader(e).readBuffer() };
}
function Za() {
  return { fromBuffer: (e) => Ue.asReader(e).readString() };
}
const Mi = (e) => {
  const t = (() => {
    if (typeof window < "u" && window.crypto) return window.crypto;
    if (typeof globalThis < "u" && globalThis.crypto) return globalThis.crypto;
  })();
  if (!t) throw new Error("randomBytes UnsupportedEnvironment");
  const n = new Uint8Array(e),
    i = 65536;
  if (e > i)
    for (let s = 0; s < e; s += i) t.getRandomValues(n.subarray(s, s + i));
  else t.getRandomValues(n);
  return n;
};
var Rs = Ee(287).hp;
function Cs(e) {
  return (
    (e.readBigUInt64BE(0) << 192n) +
    (e.readBigUInt64BE(8) << 128n) +
    (e.readBigUInt64BE(16) << 64n) +
    e.readBigUInt64BE(24)
  );
}
function nr(e) {
  const r = Rs.from(e);
  return Cs(r);
}
function Ds(e, r = 32) {
  if (r != 32)
    throw new Error(
      `Only 32 bytes supported for conversion from bigint to buffer, attempted byte length: ${r}`,
    );
  const t = Rs.alloc(r);
  return (
    t.writeBigUInt64BE(e >> 192n, 0),
    t.writeBigUInt64BE((e >> 128n) & 0xffffffffffffffffn, 8),
    t.writeBigUInt64BE((e >> 64n) & 0xffffffffffffffffn, 16),
    t.writeBigUInt64BE(e & 0xffffffffffffffffn, 24),
    t
  );
}
function nf(e, r = 32) {
  return new Uint8Array(Ds(e, r));
}
var _n = Ee(287).hp,
  ir,
  Br;
class he {
  constructor(r) {
    const t = typeof r == "bigint" ? r : r instanceof _n ? Cs(r) : nr(r);
    if (t > ir.MAX_VALUE)
      throw new Error(
        `Value 0x${t.toString(16)} is greater or equal to field modulus.`,
      );
    this.value =
      typeof r == "bigint" ? nf(r) : r instanceof _n ? new Uint8Array(r) : r;
  }
  static random() {
    const r = nr(Mi(64)) % ir.MODULUS;
    return new this(r);
  }
  static fromBuffer(r) {
    const t = Ue.asReader(r);
    return new this(t.readBytes(this.SIZE_IN_BYTES));
  }
  static fromBufferReduce(r) {
    const t = Ue.asReader(r);
    return new this(nr(t.readBytes(this.SIZE_IN_BYTES)) % ir.MODULUS);
  }
  static fromString(r) {
    return this.fromBuffer(_n.from(r.replace(/^0x/i, ""), "hex"));
  }
  toBuffer() {
    return this.value;
  }
  toString() {
    return "0x" + ef(this.toBuffer());
  }
  equals(r) {
    return this.value.every((t, n) => t === r.value[n]);
  }
  isZero() {
    return this.value.every((r) => r === 0);
  }
}
ir = he;
he.ZERO = new ir(0n);
he.MODULUS =
  0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f0000001n;
he.MAX_VALUE = ir.MODULUS - 1n;
he.SIZE_IN_BYTES = 32;
class Rn {
  constructor(r) {
    if (((this.value = r), r > Br.MAX_VALUE))
      throw new Error(`Fq out of range ${r}.`);
  }
  static random() {
    const r = nr(Mi(64)) % Br.MODULUS;
    return new this(r);
  }
  static fromBuffer(r) {
    const t = Ue.asReader(r);
    return new this(nr(t.readBytes(this.SIZE_IN_BYTES)));
  }
  static fromBufferReduce(r) {
    const t = Ue.asReader(r);
    return new this(nr(t.readBytes(this.SIZE_IN_BYTES)) % he.MODULUS);
  }
  static fromString(r) {
    return this.fromBuffer(_n.from(r.replace(/^0x/i, ""), "hex"));
  }
  toBuffer() {
    return Ds(this.value, Br.SIZE_IN_BYTES);
  }
  toString() {
    return "0x" + this.value.toString(16);
  }
  equals(r) {
    return this.value === r.value;
  }
  isZero() {
    return this.value === 0n;
  }
}
Br = Rn;
Rn.MODULUS =
  0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47n;
Rn.MAX_VALUE = Br.MODULUS - 1n;
Rn.SIZE_IN_BYTES = 32;
var Ha = Ee(287).hp;
class Ft {
  constructor(r, t) {
    ((this.x = r), (this.y = t));
  }
  static random() {
    return new Ft(he.random(), he.random());
  }
  static fromBuffer(r) {
    const t = Ue.asReader(r);
    return new this(he.fromBuffer(t), he.fromBuffer(t));
  }
  static fromString(r) {
    return Ft.fromBuffer(Ha.from(r.replace(/^0x/i, ""), "hex"));
  }
  toBuffer() {
    return Ha.concat([this.x.toBuffer(), this.y.toBuffer()]);
  }
  toString() {
    return "0x" + this.toBuffer().toString("hex");
  }
  equals(r) {
    return this.x.equals(r.x) && this.y.equals(r.y);
  }
}
Ft.SIZE_IN_BYTES = 64;
Ft.EMPTY = new Ft(he.ZERO, he.ZERO);
class Rr {
  constructor(r) {
    this.buffer = r;
  }
  static fromBuffer(r) {
    const t = Ue.asReader(r);
    return new Rr(t.readBytes(this.SIZE_IN_BYTES));
  }
  static random() {
    return new Rr(Mi(this.SIZE_IN_BYTES));
  }
  toBuffer() {
    return this.buffer;
  }
}
Rr.SIZE_IN_BYTES = 32;
class af {
  constructor(r) {
    this.wasm = r;
  }
  async pedersenCommit(r, t) {
    const n = [r, t].map(J),
      i = [Ft];
    return (
      await this.wasm.callWasmExport(
        "pedersen_commit",
        n,
        i.map((h) => h.SIZE_IN_BYTES),
      )
    ).map((h, g) => i[g].fromBuffer(h))[0];
  }
  async pedersenHash(r, t) {
    const n = [r, t].map(J),
      i = [he];
    return (
      await this.wasm.callWasmExport(
        "pedersen_hash",
        n,
        i.map((h) => h.SIZE_IN_BYTES),
      )
    ).map((h, g) => i[g].fromBuffer(h))[0];
  }
  async pedersenHashes(r, t) {
    const n = [r, t].map(J),
      i = [he];
    return (
      await this.wasm.callWasmExport(
        "pedersen_hashes",
        n,
        i.map((h) => h.SIZE_IN_BYTES),
      )
    ).map((h, g) => i[g].fromBuffer(h))[0];
  }
  async pedersenHashBuffer(r, t) {
    const n = [r, t].map(J),
      i = [he];
    return (
      await this.wasm.callWasmExport(
        "pedersen_hash_buffer",
        n,
        i.map((h) => h.SIZE_IN_BYTES),
      )
    ).map((h, g) => i[g].fromBuffer(h))[0];
  }
  async poseidon2Hash(r) {
    const t = [r].map(J),
      n = [he];
    return (
      await this.wasm.callWasmExport(
        "poseidon2_hash",
        t,
        n.map((l) => l.SIZE_IN_BYTES),
      )
    ).map((l, h) => n[h].fromBuffer(l))[0];
  }
  async poseidon2Hashes(r) {
    const t = [r].map(J),
      n = [he];
    return (
      await this.wasm.callWasmExport(
        "poseidon2_hashes",
        t,
        n.map((l) => l.SIZE_IN_BYTES),
      )
    ).map((l, h) => n[h].fromBuffer(l))[0];
  }
  async poseidon2Permutation(r) {
    const t = [r].map(J),
      n = [qt(he)];
    return (
      await this.wasm.callWasmExport(
        "poseidon2_permutation",
        t,
        n.map((l) => l.SIZE_IN_BYTES),
      )
    ).map((l, h) => n[h].fromBuffer(l))[0];
  }
  async poseidon2HashAccumulate(r) {
    const t = [r].map(J),
      n = [he];
    return (
      await this.wasm.callWasmExport(
        "poseidon2_hash_accumulate",
        t,
        n.map((l) => l.SIZE_IN_BYTES),
      )
    ).map((l, h) => n[h].fromBuffer(l))[0];
  }
  async blake2s(r) {
    const t = [r].map(J),
      n = [Rr];
    return (
      await this.wasm.callWasmExport(
        "blake2s",
        t,
        n.map((l) => l.SIZE_IN_BYTES),
      )
    ).map((l, h) => n[h].fromBuffer(l))[0];
  }
  async blake2sToField(r) {
    const t = [r].map(J),
      n = [he];
    return (
      await this.wasm.callWasmExport(
        "blake2s_to_field_",
        t,
        n.map((l) => l.SIZE_IN_BYTES),
      )
    ).map((l, h) => n[h].fromBuffer(l))[0];
  }
  async aesEncryptBufferCbc(r, t, n, i) {
    const s = [r, t, n, i].map(J),
      l = [Ae()];
    return (
      await this.wasm.callWasmExport(
        "aes_encrypt_buffer_cbc",
        s,
        l.map((u) => u.SIZE_IN_BYTES),
      )
    ).map((u, d) => l[d].fromBuffer(u))[0];
  }
  async aesDecryptBufferCbc(r, t, n, i) {
    const s = [r, t, n, i].map(J),
      l = [Ae()];
    return (
      await this.wasm.callWasmExport(
        "aes_decrypt_buffer_cbc",
        s,
        l.map((u) => u.SIZE_IN_BYTES),
      )
    ).map((u, d) => l[d].fromBuffer(u))[0];
  }
  async srsInitSrs(r, t, n) {
    const i = [r, t, n].map(J),
      s = [];
    (
      await this.wasm.callWasmExport(
        "srs_init_srs",
        i,
        s.map((h) => h.SIZE_IN_BYTES),
      )
    ).map((h, g) => s[g].fromBuffer(h));
  }
  async srsInitGrumpkinSrs(r, t) {
    const n = [r, t].map(J),
      i = [];
    (
      await this.wasm.callWasmExport(
        "srs_init_grumpkin_srs",
        n,
        i.map((l) => l.SIZE_IN_BYTES),
      )
    ).map((l, h) => i[h].fromBuffer(l));
  }
  async testThreads(r, t) {
    const n = [r, t].map(J),
      i = [Jn()];
    return (
      await this.wasm.callWasmExport(
        "test_threads",
        n,
        i.map((h) => h.SIZE_IN_BYTES),
      )
    ).map((h, g) => i[g].fromBuffer(h))[0];
  }
  async commonInitSlabAllocator(r) {
    const t = [r].map(J),
      n = [];
    (
      await this.wasm.callWasmExport(
        "common_init_slab_allocator",
        t,
        n.map((s) => s.SIZE_IN_BYTES),
      )
    ).map((s, l) => n[l].fromBuffer(s));
  }
  async acirGetCircuitSizes(r, t, n) {
    const i = [r, t, n].map(J),
      s = [Jn(), Jn()];
    return (
      await this.wasm.callWasmExport(
        "acir_get_circuit_sizes",
        i,
        s.map((g) => g.SIZE_IN_BYTES),
      )
    ).map((g, u) => s[u].fromBuffer(g));
  }
  async acirProveAndVerifyUltraHonk(r, t) {
    const n = [r, t].map(J),
      i = [bt()];
    return (
      await this.wasm.callWasmExport(
        "acir_prove_and_verify_ultra_honk",
        n,
        i.map((h) => h.SIZE_IN_BYTES),
      )
    ).map((h, g) => i[g].fromBuffer(h))[0];
  }
  async acirProveAndVerifyMegaHonk(r, t) {
    const n = [r, t].map(J),
      i = [bt()];
    return (
      await this.wasm.callWasmExport(
        "acir_prove_and_verify_mega_honk",
        n,
        i.map((h) => h.SIZE_IN_BYTES),
      )
    ).map((h, g) => i[g].fromBuffer(h))[0];
  }
  async acirProveAztecClient(r) {
    const t = [r].map(J),
      n = [Ae(), Ae()];
    return (
      await this.wasm.callWasmExport(
        "acir_prove_aztec_client",
        t,
        n.map((l) => l.SIZE_IN_BYTES),
      )
    ).map((l, h) => n[h].fromBuffer(l));
  }
  async acirVerifyAztecClient(r, t) {
    const n = [r, t].map(J),
      i = [bt()];
    return (
      await this.wasm.callWasmExport(
        "acir_verify_aztec_client",
        n,
        i.map((h) => h.SIZE_IN_BYTES),
      )
    ).map((h, g) => i[g].fromBuffer(h))[0];
  }
  async acirLoadVerificationKey(r, t) {
    const n = [r, t].map(J),
      i = [];
    (
      await this.wasm.callWasmExport(
        "acir_load_verification_key",
        n,
        i.map((l) => l.SIZE_IN_BYTES),
      )
    ).map((l, h) => i[h].fromBuffer(l));
  }
  async acirInitVerificationKey(r) {
    const t = [r].map(J),
      n = [];
    (
      await this.wasm.callWasmExport(
        "acir_init_verification_key",
        t,
        n.map((s) => s.SIZE_IN_BYTES),
      )
    ).map((s, l) => n[l].fromBuffer(s));
  }
  async acirGetVerificationKey(r) {
    const t = [r].map(J),
      n = [Ae()];
    return (
      await this.wasm.callWasmExport(
        "acir_get_verification_key",
        t,
        n.map((l) => l.SIZE_IN_BYTES),
      )
    ).map((l, h) => n[h].fromBuffer(l))[0];
  }
  async acirGetProvingKey(r, t, n) {
    const i = [r, t, n].map(J),
      s = [Ae()];
    return (
      await this.wasm.callWasmExport(
        "acir_get_proving_key",
        i,
        s.map((g) => g.SIZE_IN_BYTES),
      )
    ).map((g, u) => s[u].fromBuffer(g))[0];
  }
  async acirVerifyProof(r, t) {
    const n = [r, t].map(J),
      i = [bt()];
    return (
      await this.wasm.callWasmExport(
        "acir_verify_proof",
        n,
        i.map((h) => h.SIZE_IN_BYTES),
      )
    ).map((h, g) => i[g].fromBuffer(h))[0];
  }
  async acirGetSolidityVerifier(r) {
    const t = [r].map(J),
      n = [Za()];
    return (
      await this.wasm.callWasmExport(
        "acir_get_solidity_verifier",
        t,
        n.map((l) => l.SIZE_IN_BYTES),
      )
    ).map((l, h) => n[h].fromBuffer(l))[0];
  }
  async acirHonkSolidityVerifier(r, t) {
    const n = [r, t].map(J),
      i = [Za()];
    return (
      await this.wasm.callWasmExport(
        "acir_honk_solidity_verifier",
        n,
        i.map((h) => h.SIZE_IN_BYTES),
      )
    ).map((h, g) => i[g].fromBuffer(h))[0];
  }
  async acirSerializeProofIntoFields(r, t, n) {
    const i = [r, t, n].map(J),
      s = [qt(he)];
    return (
      await this.wasm.callWasmExport(
        "acir_serialize_proof_into_fields",
        i,
        s.map((g) => g.SIZE_IN_BYTES),
      )
    ).map((g, u) => s[u].fromBuffer(g))[0];
  }
  async acirSerializeVerificationKeyIntoFields(r) {
    const t = [r].map(J),
      n = [qt(he), he];
    return (
      await this.wasm.callWasmExport(
        "acir_serialize_verification_key_into_fields",
        t,
        n.map((l) => l.SIZE_IN_BYTES),
      )
    ).map((l, h) => n[h].fromBuffer(l));
  }
  async acirProveUltraHonk(r, t) {
    const n = [r, t].map(J),
      i = [Ae()];
    return (
      await this.wasm.callWasmExport(
        "acir_prove_ultra_honk",
        n,
        i.map((h) => h.SIZE_IN_BYTES),
      )
    ).map((h, g) => i[g].fromBuffer(h))[0];
  }
  async acirProveUltraKeccakHonk(r, t) {
    const n = [r, t].map(J),
      i = [Ae()];
    return (
      await this.wasm.callWasmExport(
        "acir_prove_ultra_keccak_honk",
        n,
        i.map((h) => h.SIZE_IN_BYTES),
      )
    ).map((h, g) => i[g].fromBuffer(h))[0];
  }
  async acirProveUltraKeccakZKHonk(r, t) {
    const n = [r, t].map(J),
      i = [Ae()];
    return (
      await this.wasm.callWasmExport(
        "acir_prove_ultra_keccak_zk_honk",
        n,
        i.map((h) => h.SIZE_IN_BYTES),
      )
    ).map((h, g) => i[g].fromBuffer(h))[0];
  }
  async acirProveUltraStarknetHonk(r, t) {
    const n = [r, t].map(J),
      i = [Ae()];
    return (
      await this.wasm.callWasmExport(
        "acir_prove_ultra_starknet_honk",
        n,
        i.map((h) => h.SIZE_IN_BYTES),
      )
    ).map((h, g) => i[g].fromBuffer(h))[0];
  }
  async acirVerifyUltraHonk(r, t) {
    const n = [r, t].map(J),
      i = [bt()];
    return (
      await this.wasm.callWasmExport(
        "acir_verify_ultra_honk",
        n,
        i.map((h) => h.SIZE_IN_BYTES),
      )
    ).map((h, g) => i[g].fromBuffer(h))[0];
  }
  async acirVerifyUltraKeccakHonk(r, t) {
    const n = [r, t].map(J),
      i = [bt()];
    return (
      await this.wasm.callWasmExport(
        "acir_verify_ultra_keccak_honk",
        n,
        i.map((h) => h.SIZE_IN_BYTES),
      )
    ).map((h, g) => i[g].fromBuffer(h))[0];
  }
  async acirVerifyUltraKeccakZKHonk(r, t) {
    const n = [r, t].map(J),
      i = [bt()];
    return (
      await this.wasm.callWasmExport(
        "acir_verify_ultra_keccak_zk_honk",
        n,
        i.map((h) => h.SIZE_IN_BYTES),
      )
    ).map((h, g) => i[g].fromBuffer(h))[0];
  }
  async acirVerifyUltraStarknetHonk(r, t) {
    const n = [r, t].map(J),
      i = [bt()];
    return (
      await this.wasm.callWasmExport(
        "acir_verify_ultra_starknet_honk",
        n,
        i.map((h) => h.SIZE_IN_BYTES),
      )
    ).map((h, g) => i[g].fromBuffer(h))[0];
  }
  async acirWriteVkUltraHonk(r) {
    const t = [r].map(J),
      n = [Ae()];
    return (
      await this.wasm.callWasmExport(
        "acir_write_vk_ultra_honk",
        t,
        n.map((l) => l.SIZE_IN_BYTES),
      )
    ).map((l, h) => n[h].fromBuffer(l))[0];
  }
  async acirWriteVkUltraKeccakHonk(r) {
    const t = [r].map(J),
      n = [Ae()];
    return (
      await this.wasm.callWasmExport(
        "acir_write_vk_ultra_keccak_honk",
        t,
        n.map((l) => l.SIZE_IN_BYTES),
      )
    ).map((l, h) => n[h].fromBuffer(l))[0];
  }
  async acirWriteVkUltraKeccakZKHonk(r) {
    const t = [r].map(J),
      n = [Ae()];
    return (
      await this.wasm.callWasmExport(
        "acir_write_vk_ultra_keccak_zk_honk",
        t,
        n.map((l) => l.SIZE_IN_BYTES),
      )
    ).map((l, h) => n[h].fromBuffer(l))[0];
  }
  async acirWriteVkUltraStarknetHonk(r) {
    const t = [r].map(J),
      n = [Ae()];
    return (
      await this.wasm.callWasmExport(
        "acir_write_vk_ultra_starknet_honk",
        t,
        n.map((l) => l.SIZE_IN_BYTES),
      )
    ).map((l, h) => n[h].fromBuffer(l))[0];
  }
  async acirProofAsFieldsUltraHonk(r) {
    const t = [r].map(J),
      n = [qt(he)];
    return (
      await this.wasm.callWasmExport(
        "acir_proof_as_fields_ultra_honk",
        t,
        n.map((l) => l.SIZE_IN_BYTES),
      )
    ).map((l, h) => n[h].fromBuffer(l))[0];
  }
  async acirVkAsFieldsUltraHonk(r) {
    const t = [r].map(J),
      n = [qt(he)];
    return (
      await this.wasm.callWasmExport(
        "acir_vk_as_fields_ultra_honk",
        t,
        n.map((l) => l.SIZE_IN_BYTES),
      )
    ).map((l, h) => n[h].fromBuffer(l))[0];
  }
  async acirVkAsFieldsMegaHonk(r) {
    const t = [r].map(J),
      n = [qt(he)];
    return (
      await this.wasm.callWasmExport(
        "acir_vk_as_fields_mega_honk",
        t,
        n.map((l) => l.SIZE_IN_BYTES),
      )
    ).map((l, h) => n[h].fromBuffer(l))[0];
  }
  async acirGatesAztecClient(r) {
    const t = [r].map(J),
      n = [Ae()];
    return (
      await this.wasm.callWasmExport(
        "acir_gates_aztec_client",
        t,
        n.map((l) => l.SIZE_IN_BYTES),
      )
    ).map((l, h) => n[h].fromBuffer(l))[0];
  }
}
var of = Ee(833),
  Sn = Ee.n(of);
function sf() {
  const e = typeof window < "u" ? window : globalThis;
  return typeof SharedArrayBuffer < "u" && e.crossOriginIsolated;
}
function cf(e) {
  return Is(e);
}
function lf(e, r) {
  e.addEventListener("message", function t(n) {
    n.data && n.data.ready === !0 && (e.removeEventListener("message", t), r());
  });
}
async function uf() {
  const e = new Worker(
      new URL("/assets/main.worker-8FZ3Rkwm.js", import.meta.url),
      { type: "module" },
    ),
    r = Sn().disable();
  return (
    Sn().enable(r),
    e.postMessage({ debug: r }),
    await new Promise((t) => lf(e, t)),
    e
  );
}
const ff = 4,
  Wa = 0,
  Va = 1,
  hf = 2;
function ur(e) {
  let r = e.length;
  for (; --r >= 0; ) e[r] = 0;
}
const df = 0,
  Ns = 1,
  _f = 2,
  pf = 3,
  wf = 258,
  Pi = 29,
  Pr = 256,
  Cr = Pr + 1 + Pi,
  ar = 30,
  Zi = 19,
  Os = 2 * Cr + 1,
  Nt = 15,
  Qn = 16,
  gf = 7,
  Hi = 256,
  $s = 16,
  Ls = 17,
  zs = 18,
  Bi = new Uint8Array([
    0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5,
    5, 5, 5, 0,
  ]),
  pn = new Uint8Array([
    0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10,
    11, 11, 12, 12, 13, 13,
  ]),
  yf = new Uint8Array([
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 3, 7,
  ]),
  Fs = new Uint8Array([
    16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15,
  ]),
  bf = 512,
  ot = new Array((Cr + 2) * 2);
ur(ot);
const Sr = new Array(ar * 2);
ur(Sr);
const Dr = new Array(bf);
ur(Dr);
const Nr = new Array(wf - pf + 1);
ur(Nr);
const Wi = new Array(Pi);
ur(Wi);
const In = new Array(ar);
ur(In);
function ei(e, r, t, n, i) {
  ((this.static_tree = e),
    (this.extra_bits = r),
    (this.extra_base = t),
    (this.elems = n),
    (this.max_length = i),
    (this.has_stree = e && e.length));
}
let Ms, Ps, Zs;
function ti(e, r) {
  ((this.dyn_tree = e), (this.max_code = 0), (this.stat_desc = r));
}
const Hs = (e) => (e < 256 ? Dr[e] : Dr[256 + (e >>> 7)]),
  Or = (e, r) => {
    ((e.pending_buf[e.pending++] = r & 255),
      (e.pending_buf[e.pending++] = (r >>> 8) & 255));
  },
  Te = (e, r, t) => {
    e.bi_valid > Qn - t
      ? ((e.bi_buf |= (r << e.bi_valid) & 65535),
        Or(e, e.bi_buf),
        (e.bi_buf = r >> (Qn - e.bi_valid)),
        (e.bi_valid += t - Qn))
      : ((e.bi_buf |= (r << e.bi_valid) & 65535), (e.bi_valid += t));
  },
  Xe = (e, r, t) => {
    Te(e, t[r * 2], t[r * 2 + 1]);
  },
  Ws = (e, r) => {
    let t = 0;
    do ((t |= e & 1), (e >>>= 1), (t <<= 1));
    while (--r > 0);
    return t >>> 1;
  },
  mf = (e) => {
    e.bi_valid === 16
      ? (Or(e, e.bi_buf), (e.bi_buf = 0), (e.bi_valid = 0))
      : e.bi_valid >= 8 &&
        ((e.pending_buf[e.pending++] = e.bi_buf & 255),
        (e.bi_buf >>= 8),
        (e.bi_valid -= 8));
  },
  Ef = (e, r) => {
    const t = r.dyn_tree,
      n = r.max_code,
      i = r.stat_desc.static_tree,
      s = r.stat_desc.has_stree,
      l = r.stat_desc.extra_bits,
      h = r.stat_desc.extra_base,
      g = r.stat_desc.max_length;
    let u,
      d,
      E,
      b,
      y,
      I,
      x = 0;
    for (b = 0; b <= Nt; b++) e.bl_count[b] = 0;
    for (t[e.heap[e.heap_max] * 2 + 1] = 0, u = e.heap_max + 1; u < Os; u++)
      ((d = e.heap[u]),
        (b = t[t[d * 2 + 1] * 2 + 1] + 1),
        b > g && ((b = g), x++),
        (t[d * 2 + 1] = b),
        !(d > n) &&
          (e.bl_count[b]++,
          (y = 0),
          d >= h && (y = l[d - h]),
          (I = t[d * 2]),
          (e.opt_len += I * (b + y)),
          s && (e.static_len += I * (i[d * 2 + 1] + y))));
    if (x !== 0) {
      do {
        for (b = g - 1; e.bl_count[b] === 0; ) b--;
        (e.bl_count[b]--, (e.bl_count[b + 1] += 2), e.bl_count[g]--, (x -= 2));
      } while (x > 0);
      for (b = g; b !== 0; b--)
        for (d = e.bl_count[b]; d !== 0; )
          ((E = e.heap[--u]),
            !(E > n) &&
              (t[E * 2 + 1] !== b &&
                ((e.opt_len += (b - t[E * 2 + 1]) * t[E * 2]),
                (t[E * 2 + 1] = b)),
              d--));
    }
  },
  Vs = (e, r, t) => {
    const n = new Array(Nt + 1);
    let i = 0,
      s,
      l;
    for (s = 1; s <= Nt; s++) ((i = (i + t[s - 1]) << 1), (n[s] = i));
    for (l = 0; l <= r; l++) {
      let h = e[l * 2 + 1];
      h !== 0 && (e[l * 2] = Ws(n[h]++, h));
    }
  },
  kf = () => {
    let e, r, t, n, i;
    const s = new Array(Nt + 1);
    for (t = 0, n = 0; n < Pi - 1; n++)
      for (Wi[n] = t, e = 0; e < 1 << Bi[n]; e++) Nr[t++] = n;
    for (Nr[t - 1] = n, i = 0, n = 0; n < 16; n++)
      for (In[n] = i, e = 0; e < 1 << pn[n]; e++) Dr[i++] = n;
    for (i >>= 7; n < ar; n++)
      for (In[n] = i << 7, e = 0; e < 1 << (pn[n] - 7); e++) Dr[256 + i++] = n;
    for (r = 0; r <= Nt; r++) s[r] = 0;
    for (e = 0; e <= 143; ) ((ot[e * 2 + 1] = 8), e++, s[8]++);
    for (; e <= 255; ) ((ot[e * 2 + 1] = 9), e++, s[9]++);
    for (; e <= 279; ) ((ot[e * 2 + 1] = 7), e++, s[7]++);
    for (; e <= 287; ) ((ot[e * 2 + 1] = 8), e++, s[8]++);
    for (Vs(ot, Cr + 1, s), e = 0; e < ar; e++)
      ((Sr[e * 2 + 1] = 5), (Sr[e * 2] = Ws(e, 5)));
    ((Ms = new ei(ot, Bi, Pr + 1, Cr, Nt)),
      (Ps = new ei(Sr, pn, 0, ar, Nt)),
      (Zs = new ei(new Array(0), yf, 0, Zi, gf)));
  },
  Ys = (e) => {
    let r;
    for (r = 0; r < Cr; r++) e.dyn_ltree[r * 2] = 0;
    for (r = 0; r < ar; r++) e.dyn_dtree[r * 2] = 0;
    for (r = 0; r < Zi; r++) e.bl_tree[r * 2] = 0;
    ((e.dyn_ltree[Hi * 2] = 1),
      (e.opt_len = e.static_len = 0),
      (e.sym_next = e.matches = 0));
  },
  Gs = (e) => {
    (e.bi_valid > 8
      ? Or(e, e.bi_buf)
      : e.bi_valid > 0 && (e.pending_buf[e.pending++] = e.bi_buf),
      (e.bi_buf = 0),
      (e.bi_valid = 0));
  },
  Ya = (e, r, t, n) => {
    const i = r * 2,
      s = t * 2;
    return e[i] < e[s] || (e[i] === e[s] && n[r] <= n[t]);
  },
  ri = (e, r, t) => {
    const n = e.heap[t];
    let i = t << 1;
    for (
      ;
      i <= e.heap_len &&
      (i < e.heap_len && Ya(r, e.heap[i + 1], e.heap[i], e.depth) && i++,
      !Ya(r, n, e.heap[i], e.depth));
    )
      ((e.heap[t] = e.heap[i]), (t = i), (i <<= 1));
    e.heap[t] = n;
  },
  Ga = (e, r, t) => {
    let n,
      i,
      s = 0,
      l,
      h;
    if (e.sym_next !== 0)
      do
        ((n = e.pending_buf[e.sym_buf + s++] & 255),
          (n += (e.pending_buf[e.sym_buf + s++] & 255) << 8),
          (i = e.pending_buf[e.sym_buf + s++]),
          n === 0
            ? Xe(e, i, r)
            : ((l = Nr[i]),
              Xe(e, l + Pr + 1, r),
              (h = Bi[l]),
              h !== 0 && ((i -= Wi[l]), Te(e, i, h)),
              n--,
              (l = Hs(n)),
              Xe(e, l, t),
              (h = pn[l]),
              h !== 0 && ((n -= In[l]), Te(e, n, h))));
      while (s < e.sym_next);
    Xe(e, Hi, r);
  },
  Si = (e, r) => {
    const t = r.dyn_tree,
      n = r.stat_desc.static_tree,
      i = r.stat_desc.has_stree,
      s = r.stat_desc.elems;
    let l,
      h,
      g = -1,
      u;
    for (e.heap_len = 0, e.heap_max = Os, l = 0; l < s; l++)
      t[l * 2] !== 0
        ? ((e.heap[++e.heap_len] = g = l), (e.depth[l] = 0))
        : (t[l * 2 + 1] = 0);
    for (; e.heap_len < 2; )
      ((u = e.heap[++e.heap_len] = g < 2 ? ++g : 0),
        (t[u * 2] = 1),
        (e.depth[u] = 0),
        e.opt_len--,
        i && (e.static_len -= n[u * 2 + 1]));
    for (r.max_code = g, l = e.heap_len >> 1; l >= 1; l--) ri(e, t, l);
    u = s;
    do
      ((l = e.heap[1]),
        (e.heap[1] = e.heap[e.heap_len--]),
        ri(e, t, 1),
        (h = e.heap[1]),
        (e.heap[--e.heap_max] = l),
        (e.heap[--e.heap_max] = h),
        (t[u * 2] = t[l * 2] + t[h * 2]),
        (e.depth[u] = (e.depth[l] >= e.depth[h] ? e.depth[l] : e.depth[h]) + 1),
        (t[l * 2 + 1] = t[h * 2 + 1] = u),
        (e.heap[1] = u++),
        ri(e, t, 1));
    while (e.heap_len >= 2);
    ((e.heap[--e.heap_max] = e.heap[1]), Ef(e, r), Vs(t, g, e.bl_count));
  },
  ja = (e, r, t) => {
    let n,
      i = -1,
      s,
      l = r[1],
      h = 0,
      g = 7,
      u = 4;
    for (
      l === 0 && ((g = 138), (u = 3)), r[(t + 1) * 2 + 1] = 65535, n = 0;
      n <= t;
      n++
    )
      ((s = l),
        (l = r[(n + 1) * 2 + 1]),
        !(++h < g && s === l) &&
          (h < u
            ? (e.bl_tree[s * 2] += h)
            : s !== 0
              ? (s !== i && e.bl_tree[s * 2]++, e.bl_tree[$s * 2]++)
              : h <= 10
                ? e.bl_tree[Ls * 2]++
                : e.bl_tree[zs * 2]++,
          (h = 0),
          (i = s),
          l === 0
            ? ((g = 138), (u = 3))
            : s === l
              ? ((g = 6), (u = 3))
              : ((g = 7), (u = 4))));
  },
  Ka = (e, r, t) => {
    let n,
      i = -1,
      s,
      l = r[1],
      h = 0,
      g = 7,
      u = 4;
    for (l === 0 && ((g = 138), (u = 3)), n = 0; n <= t; n++)
      if (((s = l), (l = r[(n + 1) * 2 + 1]), !(++h < g && s === l))) {
        if (h < u)
          do Xe(e, s, e.bl_tree);
          while (--h !== 0);
        else
          s !== 0
            ? (s !== i && (Xe(e, s, e.bl_tree), h--),
              Xe(e, $s, e.bl_tree),
              Te(e, h - 3, 2))
            : h <= 10
              ? (Xe(e, Ls, e.bl_tree), Te(e, h - 3, 3))
              : (Xe(e, zs, e.bl_tree), Te(e, h - 11, 7));
        ((h = 0),
          (i = s),
          l === 0
            ? ((g = 138), (u = 3))
            : s === l
              ? ((g = 6), (u = 3))
              : ((g = 7), (u = 4)));
      }
  },
  Bf = (e) => {
    let r;
    for (
      ja(e, e.dyn_ltree, e.l_desc.max_code),
        ja(e, e.dyn_dtree, e.d_desc.max_code),
        Si(e, e.bl_desc),
        r = Zi - 1;
      r >= 3 && e.bl_tree[Fs[r] * 2 + 1] === 0;
      r--
    );
    return ((e.opt_len += 3 * (r + 1) + 5 + 5 + 4), r);
  },
  Sf = (e, r, t, n) => {
    let i;
    for (Te(e, r - 257, 5), Te(e, t - 1, 5), Te(e, n - 4, 4), i = 0; i < n; i++)
      Te(e, e.bl_tree[Fs[i] * 2 + 1], 3);
    (Ka(e, e.dyn_ltree, r - 1), Ka(e, e.dyn_dtree, t - 1));
  },
  If = (e) => {
    let r = 4093624447,
      t;
    for (t = 0; t <= 31; t++, r >>>= 1)
      if (r & 1 && e.dyn_ltree[t * 2] !== 0) return Wa;
    if (e.dyn_ltree[18] !== 0 || e.dyn_ltree[20] !== 0 || e.dyn_ltree[26] !== 0)
      return Va;
    for (t = 32; t < Pr; t++) if (e.dyn_ltree[t * 2] !== 0) return Va;
    return Wa;
  };
let Xa = !1;
const Af = (e) => {
    (Xa || (kf(), (Xa = !0)),
      (e.l_desc = new ti(e.dyn_ltree, Ms)),
      (e.d_desc = new ti(e.dyn_dtree, Ps)),
      (e.bl_desc = new ti(e.bl_tree, Zs)),
      (e.bi_buf = 0),
      (e.bi_valid = 0),
      Ys(e));
  },
  js = (e, r, t, n) => {
    (Te(e, (df << 1) + (n ? 1 : 0), 3),
      Gs(e),
      Or(e, t),
      Or(e, ~t),
      t && e.pending_buf.set(e.window.subarray(r, r + t), e.pending),
      (e.pending += t));
  },
  vf = (e) => {
    (Te(e, Ns << 1, 3), Xe(e, Hi, ot), mf(e));
  },
  xf = (e, r, t, n) => {
    let i,
      s,
      l = 0;
    (e.level > 0
      ? (e.strm.data_type === hf && (e.strm.data_type = If(e)),
        Si(e, e.l_desc),
        Si(e, e.d_desc),
        (l = Bf(e)),
        (i = (e.opt_len + 3 + 7) >>> 3),
        (s = (e.static_len + 3 + 7) >>> 3),
        s <= i && (i = s))
      : (i = s = t + 5),
      t + 4 <= i && r !== -1
        ? js(e, r, t, n)
        : e.strategy === ff || s === i
          ? (Te(e, (Ns << 1) + (n ? 1 : 0), 3), Ga(e, ot, Sr))
          : (Te(e, (_f << 1) + (n ? 1 : 0), 3),
            Sf(e, e.l_desc.max_code + 1, e.d_desc.max_code + 1, l + 1),
            Ga(e, e.dyn_ltree, e.dyn_dtree)),
      Ys(e),
      n && Gs(e));
  },
  Tf = (e, r, t) => (
    (e.pending_buf[e.sym_buf + e.sym_next++] = r),
    (e.pending_buf[e.sym_buf + e.sym_next++] = r >> 8),
    (e.pending_buf[e.sym_buf + e.sym_next++] = t),
    r === 0
      ? e.dyn_ltree[t * 2]++
      : (e.matches++,
        r--,
        e.dyn_ltree[(Nr[t] + Pr + 1) * 2]++,
        e.dyn_dtree[Hs(r) * 2]++),
    e.sym_next === e.sym_end
  );
var Uf = Af,
  Rf = js,
  Cf = xf,
  Df = Tf,
  Nf = vf,
  Of = {
    _tr_init: Uf,
    _tr_stored_block: Rf,
    _tr_flush_block: Cf,
    _tr_tally: Df,
    _tr_align: Nf,
  };
const $f = (e, r, t, n) => {
  let i = (e & 65535) | 0,
    s = ((e >>> 16) & 65535) | 0,
    l = 0;
  for (; t !== 0; ) {
    ((l = t > 2e3 ? 2e3 : t), (t -= l));
    do ((i = (i + r[n++]) | 0), (s = (s + i) | 0));
    while (--l);
    ((i %= 65521), (s %= 65521));
  }
  return i | (s << 16) | 0;
};
var $r = $f;
const Lf = () => {
    let e,
      r = [];
    for (var t = 0; t < 256; t++) {
      e = t;
      for (var n = 0; n < 8; n++) e = e & 1 ? 3988292384 ^ (e >>> 1) : e >>> 1;
      r[t] = e;
    }
    return r;
  },
  zf = new Uint32Array(Lf()),
  Ff = (e, r, t, n) => {
    const i = zf,
      s = n + t;
    e ^= -1;
    for (let l = n; l < s; l++) e = (e >>> 8) ^ i[(e ^ r[l]) & 255];
    return e ^ -1;
  };
var Be = Ff,
  Mt = {
    2: "need dictionary",
    1: "stream end",
    0: "",
    "-1": "file error",
    "-2": "stream error",
    "-3": "data error",
    "-4": "insufficient memory",
    "-5": "buffer error",
    "-6": "incompatible version",
  },
  Zr = {
    Z_NO_FLUSH: 0,
    Z_PARTIAL_FLUSH: 1,
    Z_SYNC_FLUSH: 2,
    Z_FULL_FLUSH: 3,
    Z_FINISH: 4,
    Z_BLOCK: 5,
    Z_TREES: 6,
    Z_OK: 0,
    Z_STREAM_END: 1,
    Z_NEED_DICT: 2,
    Z_ERRNO: -1,
    Z_STREAM_ERROR: -2,
    Z_DATA_ERROR: -3,
    Z_MEM_ERROR: -4,
    Z_BUF_ERROR: -5,
    Z_NO_COMPRESSION: 0,
    Z_BEST_SPEED: 1,
    Z_BEST_COMPRESSION: 9,
    Z_DEFAULT_COMPRESSION: -1,
    Z_FILTERED: 1,
    Z_HUFFMAN_ONLY: 2,
    Z_RLE: 3,
    Z_FIXED: 4,
    Z_DEFAULT_STRATEGY: 0,
    Z_BINARY: 0,
    Z_TEXT: 1,
    Z_UNKNOWN: 2,
    Z_DEFLATED: 8,
  };
const {
    _tr_init: Mf,
    _tr_stored_block: Ii,
    _tr_flush_block: Pf,
    _tr_tally: St,
    _tr_align: Zf,
  } = Of,
  {
    Z_NO_FLUSH: It,
    Z_PARTIAL_FLUSH: Hf,
    Z_FULL_FLUSH: Wf,
    Z_FINISH: He,
    Z_BLOCK: qa,
    Z_OK: Ie,
    Z_STREAM_END: Ja,
    Z_STREAM_ERROR: Je,
    Z_DATA_ERROR: Vf,
    Z_BUF_ERROR: ni,
    Z_DEFAULT_COMPRESSION: Yf,
    Z_FILTERED: Gf,
    Z_HUFFMAN_ONLY: tn,
    Z_RLE: jf,
    Z_FIXED: Kf,
    Z_DEFAULT_STRATEGY: Xf,
    Z_UNKNOWN: qf,
    Z_DEFLATED: Cn,
  } = Zr,
  Jf = 9,
  Qf = 15,
  eh = 8,
  th = 29,
  rh = 256,
  Ai = rh + 1 + th,
  nh = 30,
  ih = 19,
  ah = 2 * Ai + 1,
  oh = 15,
  re = 3,
  kt = 258,
  Qe = kt + re + 1,
  sh = 32,
  sr = 42,
  Vi = 57,
  vi = 69,
  xi = 73,
  Ti = 91,
  Ui = 103,
  Ot = 113,
  mr = 666,
  xe = 1,
  fr = 2,
  Pt = 3,
  hr = 4,
  ch = 3,
  $t = (e, r) => ((e.msg = Mt[r]), r),
  Qa = (e) => e * 2 - (e > 4 ? 9 : 0),
  Et = (e) => {
    let r = e.length;
    for (; --r >= 0; ) e[r] = 0;
  },
  lh = (e) => {
    let r,
      t,
      n,
      i = e.w_size;
    ((r = e.hash_size), (n = r));
    do ((t = e.head[--n]), (e.head[n] = t >= i ? t - i : 0));
    while (--r);
    ((r = i), (n = r));
    do ((t = e.prev[--n]), (e.prev[n] = t >= i ? t - i : 0));
    while (--r);
  };
let uh = (e, r, t) => ((r << e.hash_shift) ^ t) & e.hash_mask,
  At = uh;
const De = (e) => {
    const r = e.state;
    let t = r.pending;
    (t > e.avail_out && (t = e.avail_out),
      t !== 0 &&
        (e.output.set(
          r.pending_buf.subarray(r.pending_out, r.pending_out + t),
          e.next_out,
        ),
        (e.next_out += t),
        (r.pending_out += t),
        (e.total_out += t),
        (e.avail_out -= t),
        (r.pending -= t),
        r.pending === 0 && (r.pending_out = 0)));
  },
  $e = (e, r) => {
    (Pf(
      e,
      e.block_start >= 0 ? e.block_start : -1,
      e.strstart - e.block_start,
      r,
    ),
      (e.block_start = e.strstart),
      De(e.strm));
  },
  oe = (e, r) => {
    e.pending_buf[e.pending++] = r;
  },
  pr = (e, r) => {
    ((e.pending_buf[e.pending++] = (r >>> 8) & 255),
      (e.pending_buf[e.pending++] = r & 255));
  },
  Ri = (e, r, t, n) => {
    let i = e.avail_in;
    return (
      i > n && (i = n),
      i === 0
        ? 0
        : ((e.avail_in -= i),
          r.set(e.input.subarray(e.next_in, e.next_in + i), t),
          e.state.wrap === 1
            ? (e.adler = $r(e.adler, r, i, t))
            : e.state.wrap === 2 && (e.adler = Be(e.adler, r, i, t)),
          (e.next_in += i),
          (e.total_in += i),
          i)
    );
  },
  Ks = (e, r) => {
    let t = e.max_chain_length,
      n = e.strstart,
      i,
      s,
      l = e.prev_length,
      h = e.nice_match;
    const g = e.strstart > e.w_size - Qe ? e.strstart - (e.w_size - Qe) : 0,
      u = e.window,
      d = e.w_mask,
      E = e.prev,
      b = e.strstart + kt;
    let y = u[n + l - 1],
      I = u[n + l];
    (e.prev_length >= e.good_match && (t >>= 2),
      h > e.lookahead && (h = e.lookahead));
    do
      if (
        ((i = r),
        !(
          u[i + l] !== I ||
          u[i + l - 1] !== y ||
          u[i] !== u[n] ||
          u[++i] !== u[n + 1]
        ))
      ) {
        ((n += 2), i++);
        do;
        while (
          u[++n] === u[++i] &&
          u[++n] === u[++i] &&
          u[++n] === u[++i] &&
          u[++n] === u[++i] &&
          u[++n] === u[++i] &&
          u[++n] === u[++i] &&
          u[++n] === u[++i] &&
          u[++n] === u[++i] &&
          n < b
        );
        if (((s = kt - (b - n)), (n = b - kt), s > l)) {
          if (((e.match_start = r), (l = s), s >= h)) break;
          ((y = u[n + l - 1]), (I = u[n + l]));
        }
      }
    while ((r = E[r & d]) > g && --t !== 0);
    return l <= e.lookahead ? l : e.lookahead;
  },
  cr = (e) => {
    const r = e.w_size;
    let t, n, i;
    do {
      if (
        ((n = e.window_size - e.lookahead - e.strstart),
        e.strstart >= r + (r - Qe) &&
          (e.window.set(e.window.subarray(r, r + r - n), 0),
          (e.match_start -= r),
          (e.strstart -= r),
          (e.block_start -= r),
          e.insert > e.strstart && (e.insert = e.strstart),
          lh(e),
          (n += r)),
        e.strm.avail_in === 0)
      )
        break;
      if (
        ((t = Ri(e.strm, e.window, e.strstart + e.lookahead, n)),
        (e.lookahead += t),
        e.lookahead + e.insert >= re)
      )
        for (
          i = e.strstart - e.insert,
            e.ins_h = e.window[i],
            e.ins_h = At(e, e.ins_h, e.window[i + 1]);
          e.insert &&
          ((e.ins_h = At(e, e.ins_h, e.window[i + re - 1])),
          (e.prev[i & e.w_mask] = e.head[e.ins_h]),
          (e.head[e.ins_h] = i),
          i++,
          e.insert--,
          !(e.lookahead + e.insert < re));
        );
    } while (e.lookahead < Qe && e.strm.avail_in !== 0);
  },
  Xs = (e, r) => {
    let t =
        e.pending_buf_size - 5 > e.w_size ? e.w_size : e.pending_buf_size - 5,
      n,
      i,
      s,
      l = 0,
      h = e.strm.avail_in;
    do {
      if (
        ((n = 65535),
        (s = (e.bi_valid + 42) >> 3),
        e.strm.avail_out < s ||
          ((s = e.strm.avail_out - s),
          (i = e.strstart - e.block_start),
          n > i + e.strm.avail_in && (n = i + e.strm.avail_in),
          n > s && (n = s),
          n < t &&
            ((n === 0 && r !== He) || r === It || n !== i + e.strm.avail_in)))
      )
        break;
      ((l = r === He && n === i + e.strm.avail_in ? 1 : 0),
        Ii(e, 0, 0, l),
        (e.pending_buf[e.pending - 4] = n),
        (e.pending_buf[e.pending - 3] = n >> 8),
        (e.pending_buf[e.pending - 2] = ~n),
        (e.pending_buf[e.pending - 1] = ~n >> 8),
        De(e.strm),
        i &&
          (i > n && (i = n),
          e.strm.output.set(
            e.window.subarray(e.block_start, e.block_start + i),
            e.strm.next_out,
          ),
          (e.strm.next_out += i),
          (e.strm.avail_out -= i),
          (e.strm.total_out += i),
          (e.block_start += i),
          (n -= i)),
        n &&
          (Ri(e.strm, e.strm.output, e.strm.next_out, n),
          (e.strm.next_out += n),
          (e.strm.avail_out -= n),
          (e.strm.total_out += n)));
    } while (l === 0);
    return (
      (h -= e.strm.avail_in),
      h &&
        (h >= e.w_size
          ? ((e.matches = 2),
            e.window.set(
              e.strm.input.subarray(e.strm.next_in - e.w_size, e.strm.next_in),
              0,
            ),
            (e.strstart = e.w_size),
            (e.insert = e.strstart))
          : (e.window_size - e.strstart <= h &&
              ((e.strstart -= e.w_size),
              e.window.set(
                e.window.subarray(e.w_size, e.w_size + e.strstart),
                0,
              ),
              e.matches < 2 && e.matches++,
              e.insert > e.strstart && (e.insert = e.strstart)),
            e.window.set(
              e.strm.input.subarray(e.strm.next_in - h, e.strm.next_in),
              e.strstart,
            ),
            (e.strstart += h),
            (e.insert += h > e.w_size - e.insert ? e.w_size - e.insert : h)),
        (e.block_start = e.strstart)),
      e.high_water < e.strstart && (e.high_water = e.strstart),
      l
        ? hr
        : r !== It &&
            r !== He &&
            e.strm.avail_in === 0 &&
            e.strstart === e.block_start
          ? fr
          : ((s = e.window_size - e.strstart),
            e.strm.avail_in > s &&
              e.block_start >= e.w_size &&
              ((e.block_start -= e.w_size),
              (e.strstart -= e.w_size),
              e.window.set(
                e.window.subarray(e.w_size, e.w_size + e.strstart),
                0,
              ),
              e.matches < 2 && e.matches++,
              (s += e.w_size),
              e.insert > e.strstart && (e.insert = e.strstart)),
            s > e.strm.avail_in && (s = e.strm.avail_in),
            s &&
              (Ri(e.strm, e.window, e.strstart, s),
              (e.strstart += s),
              (e.insert += s > e.w_size - e.insert ? e.w_size - e.insert : s)),
            e.high_water < e.strstart && (e.high_water = e.strstart),
            (s = (e.bi_valid + 42) >> 3),
            (s =
              e.pending_buf_size - s > 65535 ? 65535 : e.pending_buf_size - s),
            (t = s > e.w_size ? e.w_size : s),
            (i = e.strstart - e.block_start),
            (i >= t ||
              ((i || r === He) &&
                r !== It &&
                e.strm.avail_in === 0 &&
                i <= s)) &&
              ((n = i > s ? s : i),
              (l = r === He && e.strm.avail_in === 0 && n === i ? 1 : 0),
              Ii(e, e.block_start, n, l),
              (e.block_start += n),
              De(e.strm)),
            l ? Pt : xe)
    );
  },
  ii = (e, r) => {
    let t, n;
    for (;;) {
      if (e.lookahead < Qe) {
        if ((cr(e), e.lookahead < Qe && r === It)) return xe;
        if (e.lookahead === 0) break;
      }
      if (
        ((t = 0),
        e.lookahead >= re &&
          ((e.ins_h = At(e, e.ins_h, e.window[e.strstart + re - 1])),
          (t = e.prev[e.strstart & e.w_mask] = e.head[e.ins_h]),
          (e.head[e.ins_h] = e.strstart)),
        t !== 0 &&
          e.strstart - t <= e.w_size - Qe &&
          (e.match_length = Ks(e, t)),
        e.match_length >= re)
      )
        if (
          ((n = St(e, e.strstart - e.match_start, e.match_length - re)),
          (e.lookahead -= e.match_length),
          e.match_length <= e.max_lazy_match && e.lookahead >= re)
        ) {
          e.match_length--;
          do
            (e.strstart++,
              (e.ins_h = At(e, e.ins_h, e.window[e.strstart + re - 1])),
              (t = e.prev[e.strstart & e.w_mask] = e.head[e.ins_h]),
              (e.head[e.ins_h] = e.strstart));
          while (--e.match_length !== 0);
          e.strstart++;
        } else
          ((e.strstart += e.match_length),
            (e.match_length = 0),
            (e.ins_h = e.window[e.strstart]),
            (e.ins_h = At(e, e.ins_h, e.window[e.strstart + 1])));
      else ((n = St(e, 0, e.window[e.strstart])), e.lookahead--, e.strstart++);
      if (n && ($e(e, !1), e.strm.avail_out === 0)) return xe;
    }
    return (
      (e.insert = e.strstart < re - 1 ? e.strstart : re - 1),
      r === He
        ? ($e(e, !0), e.strm.avail_out === 0 ? Pt : hr)
        : e.sym_next && ($e(e, !1), e.strm.avail_out === 0)
          ? xe
          : fr
    );
  },
  Jt = (e, r) => {
    let t, n, i;
    for (;;) {
      if (e.lookahead < Qe) {
        if ((cr(e), e.lookahead < Qe && r === It)) return xe;
        if (e.lookahead === 0) break;
      }
      if (
        ((t = 0),
        e.lookahead >= re &&
          ((e.ins_h = At(e, e.ins_h, e.window[e.strstart + re - 1])),
          (t = e.prev[e.strstart & e.w_mask] = e.head[e.ins_h]),
          (e.head[e.ins_h] = e.strstart)),
        (e.prev_length = e.match_length),
        (e.prev_match = e.match_start),
        (e.match_length = re - 1),
        t !== 0 &&
          e.prev_length < e.max_lazy_match &&
          e.strstart - t <= e.w_size - Qe &&
          ((e.match_length = Ks(e, t)),
          e.match_length <= 5 &&
            (e.strategy === Gf ||
              (e.match_length === re && e.strstart - e.match_start > 4096)) &&
            (e.match_length = re - 1)),
        e.prev_length >= re && e.match_length <= e.prev_length)
      ) {
        ((i = e.strstart + e.lookahead - re),
          (n = St(e, e.strstart - 1 - e.prev_match, e.prev_length - re)),
          (e.lookahead -= e.prev_length - 1),
          (e.prev_length -= 2));
        do
          ++e.strstart <= i &&
            ((e.ins_h = At(e, e.ins_h, e.window[e.strstart + re - 1])),
            (t = e.prev[e.strstart & e.w_mask] = e.head[e.ins_h]),
            (e.head[e.ins_h] = e.strstart));
        while (--e.prev_length !== 0);
        if (
          ((e.match_available = 0),
          (e.match_length = re - 1),
          e.strstart++,
          n && ($e(e, !1), e.strm.avail_out === 0))
        )
          return xe;
      } else if (e.match_available) {
        if (
          ((n = St(e, 0, e.window[e.strstart - 1])),
          n && $e(e, !1),
          e.strstart++,
          e.lookahead--,
          e.strm.avail_out === 0)
        )
          return xe;
      } else ((e.match_available = 1), e.strstart++, e.lookahead--);
    }
    return (
      e.match_available &&
        ((n = St(e, 0, e.window[e.strstart - 1])), (e.match_available = 0)),
      (e.insert = e.strstart < re - 1 ? e.strstart : re - 1),
      r === He
        ? ($e(e, !0), e.strm.avail_out === 0 ? Pt : hr)
        : e.sym_next && ($e(e, !1), e.strm.avail_out === 0)
          ? xe
          : fr
    );
  },
  fh = (e, r) => {
    let t, n, i, s;
    const l = e.window;
    for (;;) {
      if (e.lookahead <= kt) {
        if ((cr(e), e.lookahead <= kt && r === It)) return xe;
        if (e.lookahead === 0) break;
      }
      if (
        ((e.match_length = 0),
        e.lookahead >= re &&
          e.strstart > 0 &&
          ((i = e.strstart - 1),
          (n = l[i]),
          n === l[++i] && n === l[++i] && n === l[++i]))
      ) {
        s = e.strstart + kt;
        do;
        while (
          n === l[++i] &&
          n === l[++i] &&
          n === l[++i] &&
          n === l[++i] &&
          n === l[++i] &&
          n === l[++i] &&
          n === l[++i] &&
          n === l[++i] &&
          i < s
        );
        ((e.match_length = kt - (s - i)),
          e.match_length > e.lookahead && (e.match_length = e.lookahead));
      }
      if (
        (e.match_length >= re
          ? ((t = St(e, 1, e.match_length - re)),
            (e.lookahead -= e.match_length),
            (e.strstart += e.match_length),
            (e.match_length = 0))
          : ((t = St(e, 0, e.window[e.strstart])), e.lookahead--, e.strstart++),
        t && ($e(e, !1), e.strm.avail_out === 0))
      )
        return xe;
    }
    return (
      (e.insert = 0),
      r === He
        ? ($e(e, !0), e.strm.avail_out === 0 ? Pt : hr)
        : e.sym_next && ($e(e, !1), e.strm.avail_out === 0)
          ? xe
          : fr
    );
  },
  hh = (e, r) => {
    let t;
    for (;;) {
      if (e.lookahead === 0 && (cr(e), e.lookahead === 0)) {
        if (r === It) return xe;
        break;
      }
      if (
        ((e.match_length = 0),
        (t = St(e, 0, e.window[e.strstart])),
        e.lookahead--,
        e.strstart++,
        t && ($e(e, !1), e.strm.avail_out === 0))
      )
        return xe;
    }
    return (
      (e.insert = 0),
      r === He
        ? ($e(e, !0), e.strm.avail_out === 0 ? Pt : hr)
        : e.sym_next && ($e(e, !1), e.strm.avail_out === 0)
          ? xe
          : fr
    );
  };
function je(e, r, t, n, i) {
  ((this.good_length = e),
    (this.max_lazy = r),
    (this.nice_length = t),
    (this.max_chain = n),
    (this.func = i));
}
const Er = [
    new je(0, 0, 0, 0, Xs),
    new je(4, 4, 8, 4, ii),
    new je(4, 5, 16, 8, ii),
    new je(4, 6, 32, 32, ii),
    new je(4, 4, 16, 16, Jt),
    new je(8, 16, 32, 32, Jt),
    new je(8, 16, 128, 128, Jt),
    new je(8, 32, 128, 256, Jt),
    new je(32, 128, 258, 1024, Jt),
    new je(32, 258, 258, 4096, Jt),
  ],
  dh = (e) => {
    ((e.window_size = 2 * e.w_size),
      Et(e.head),
      (e.max_lazy_match = Er[e.level].max_lazy),
      (e.good_match = Er[e.level].good_length),
      (e.nice_match = Er[e.level].nice_length),
      (e.max_chain_length = Er[e.level].max_chain),
      (e.strstart = 0),
      (e.block_start = 0),
      (e.lookahead = 0),
      (e.insert = 0),
      (e.match_length = e.prev_length = re - 1),
      (e.match_available = 0),
      (e.ins_h = 0));
  };
function _h() {
  ((this.strm = null),
    (this.status = 0),
    (this.pending_buf = null),
    (this.pending_buf_size = 0),
    (this.pending_out = 0),
    (this.pending = 0),
    (this.wrap = 0),
    (this.gzhead = null),
    (this.gzindex = 0),
    (this.method = Cn),
    (this.last_flush = -1),
    (this.w_size = 0),
    (this.w_bits = 0),
    (this.w_mask = 0),
    (this.window = null),
    (this.window_size = 0),
    (this.prev = null),
    (this.head = null),
    (this.ins_h = 0),
    (this.hash_size = 0),
    (this.hash_bits = 0),
    (this.hash_mask = 0),
    (this.hash_shift = 0),
    (this.block_start = 0),
    (this.match_length = 0),
    (this.prev_match = 0),
    (this.match_available = 0),
    (this.strstart = 0),
    (this.match_start = 0),
    (this.lookahead = 0),
    (this.prev_length = 0),
    (this.max_chain_length = 0),
    (this.max_lazy_match = 0),
    (this.level = 0),
    (this.strategy = 0),
    (this.good_match = 0),
    (this.nice_match = 0),
    (this.dyn_ltree = new Uint16Array(ah * 2)),
    (this.dyn_dtree = new Uint16Array((2 * nh + 1) * 2)),
    (this.bl_tree = new Uint16Array((2 * ih + 1) * 2)),
    Et(this.dyn_ltree),
    Et(this.dyn_dtree),
    Et(this.bl_tree),
    (this.l_desc = null),
    (this.d_desc = null),
    (this.bl_desc = null),
    (this.bl_count = new Uint16Array(oh + 1)),
    (this.heap = new Uint16Array(2 * Ai + 1)),
    Et(this.heap),
    (this.heap_len = 0),
    (this.heap_max = 0),
    (this.depth = new Uint16Array(2 * Ai + 1)),
    Et(this.depth),
    (this.sym_buf = 0),
    (this.lit_bufsize = 0),
    (this.sym_next = 0),
    (this.sym_end = 0),
    (this.opt_len = 0),
    (this.static_len = 0),
    (this.matches = 0),
    (this.insert = 0),
    (this.bi_buf = 0),
    (this.bi_valid = 0));
}
const Hr = (e) => {
    if (!e) return 1;
    const r = e.state;
    return !r ||
      r.strm !== e ||
      (r.status !== sr &&
        r.status !== Vi &&
        r.status !== vi &&
        r.status !== xi &&
        r.status !== Ti &&
        r.status !== Ui &&
        r.status !== Ot &&
        r.status !== mr)
      ? 1
      : 0;
  },
  qs = (e) => {
    if (Hr(e)) return $t(e, Je);
    ((e.total_in = e.total_out = 0), (e.data_type = qf));
    const r = e.state;
    return (
      (r.pending = 0),
      (r.pending_out = 0),
      r.wrap < 0 && (r.wrap = -r.wrap),
      (r.status = r.wrap === 2 ? Vi : r.wrap ? sr : Ot),
      (e.adler = r.wrap === 2 ? 0 : 1),
      (r.last_flush = -2),
      Mf(r),
      Ie
    );
  },
  Js = (e) => {
    const r = qs(e);
    return (r === Ie && dh(e.state), r);
  },
  ph = (e, r) =>
    Hr(e) || e.state.wrap !== 2 ? Je : ((e.state.gzhead = r), Ie),
  Qs = (e, r, t, n, i, s) => {
    if (!e) return Je;
    let l = 1;
    if (
      (r === Yf && (r = 6),
      n < 0 ? ((l = 0), (n = -n)) : n > 15 && ((l = 2), (n -= 16)),
      i < 1 ||
        i > Jf ||
        t !== Cn ||
        n < 8 ||
        n > 15 ||
        r < 0 ||
        r > 9 ||
        s < 0 ||
        s > Kf ||
        (n === 8 && l !== 1))
    )
      return $t(e, Je);
    n === 8 && (n = 9);
    const h = new _h();
    return (
      (e.state = h),
      (h.strm = e),
      (h.status = sr),
      (h.wrap = l),
      (h.gzhead = null),
      (h.w_bits = n),
      (h.w_size = 1 << h.w_bits),
      (h.w_mask = h.w_size - 1),
      (h.hash_bits = i + 7),
      (h.hash_size = 1 << h.hash_bits),
      (h.hash_mask = h.hash_size - 1),
      (h.hash_shift = ~~((h.hash_bits + re - 1) / re)),
      (h.window = new Uint8Array(h.w_size * 2)),
      (h.head = new Uint16Array(h.hash_size)),
      (h.prev = new Uint16Array(h.w_size)),
      (h.lit_bufsize = 1 << (i + 6)),
      (h.pending_buf_size = h.lit_bufsize * 4),
      (h.pending_buf = new Uint8Array(h.pending_buf_size)),
      (h.sym_buf = h.lit_bufsize),
      (h.sym_end = (h.lit_bufsize - 1) * 3),
      (h.level = r),
      (h.strategy = s),
      (h.method = t),
      Js(e)
    );
  },
  wh = (e, r) => Qs(e, r, Cn, Qf, eh, Xf),
  gh = (e, r) => {
    if (Hr(e) || r > qa || r < 0) return e ? $t(e, Je) : Je;
    const t = e.state;
    if (
      !e.output ||
      (e.avail_in !== 0 && !e.input) ||
      (t.status === mr && r !== He)
    )
      return $t(e, e.avail_out === 0 ? ni : Je);
    const n = t.last_flush;
    if (((t.last_flush = r), t.pending !== 0)) {
      if ((De(e), e.avail_out === 0)) return ((t.last_flush = -1), Ie);
    } else if (e.avail_in === 0 && Qa(r) <= Qa(n) && r !== He) return $t(e, ni);
    if (t.status === mr && e.avail_in !== 0) return $t(e, ni);
    if ((t.status === sr && t.wrap === 0 && (t.status = Ot), t.status === sr)) {
      let i = (Cn + ((t.w_bits - 8) << 4)) << 8,
        s = -1;
      if (
        (t.strategy >= tn || t.level < 2
          ? (s = 0)
          : t.level < 6
            ? (s = 1)
            : t.level === 6
              ? (s = 2)
              : (s = 3),
        (i |= s << 6),
        t.strstart !== 0 && (i |= sh),
        (i += 31 - (i % 31)),
        pr(t, i),
        t.strstart !== 0 && (pr(t, e.adler >>> 16), pr(t, e.adler & 65535)),
        (e.adler = 1),
        (t.status = Ot),
        De(e),
        t.pending !== 0)
      )
        return ((t.last_flush = -1), Ie);
    }
    if (t.status === Vi) {
      if (((e.adler = 0), oe(t, 31), oe(t, 139), oe(t, 8), t.gzhead))
        (oe(
          t,
          (t.gzhead.text ? 1 : 0) +
            (t.gzhead.hcrc ? 2 : 0) +
            (t.gzhead.extra ? 4 : 0) +
            (t.gzhead.name ? 8 : 0) +
            (t.gzhead.comment ? 16 : 0),
        ),
          oe(t, t.gzhead.time & 255),
          oe(t, (t.gzhead.time >> 8) & 255),
          oe(t, (t.gzhead.time >> 16) & 255),
          oe(t, (t.gzhead.time >> 24) & 255),
          oe(t, t.level === 9 ? 2 : t.strategy >= tn || t.level < 2 ? 4 : 0),
          oe(t, t.gzhead.os & 255),
          t.gzhead.extra &&
            t.gzhead.extra.length &&
            (oe(t, t.gzhead.extra.length & 255),
            oe(t, (t.gzhead.extra.length >> 8) & 255)),
          t.gzhead.hcrc && (e.adler = Be(e.adler, t.pending_buf, t.pending, 0)),
          (t.gzindex = 0),
          (t.status = vi));
      else if (
        (oe(t, 0),
        oe(t, 0),
        oe(t, 0),
        oe(t, 0),
        oe(t, 0),
        oe(t, t.level === 9 ? 2 : t.strategy >= tn || t.level < 2 ? 4 : 0),
        oe(t, ch),
        (t.status = Ot),
        De(e),
        t.pending !== 0)
      )
        return ((t.last_flush = -1), Ie);
    }
    if (t.status === vi) {
      if (t.gzhead.extra) {
        let i = t.pending,
          s = (t.gzhead.extra.length & 65535) - t.gzindex;
        for (; t.pending + s > t.pending_buf_size; ) {
          let h = t.pending_buf_size - t.pending;
          if (
            (t.pending_buf.set(
              t.gzhead.extra.subarray(t.gzindex, t.gzindex + h),
              t.pending,
            ),
            (t.pending = t.pending_buf_size),
            t.gzhead.hcrc &&
              t.pending > i &&
              (e.adler = Be(e.adler, t.pending_buf, t.pending - i, i)),
            (t.gzindex += h),
            De(e),
            t.pending !== 0)
          )
            return ((t.last_flush = -1), Ie);
          ((i = 0), (s -= h));
        }
        let l = new Uint8Array(t.gzhead.extra);
        (t.pending_buf.set(l.subarray(t.gzindex, t.gzindex + s), t.pending),
          (t.pending += s),
          t.gzhead.hcrc &&
            t.pending > i &&
            (e.adler = Be(e.adler, t.pending_buf, t.pending - i, i)),
          (t.gzindex = 0));
      }
      t.status = xi;
    }
    if (t.status === xi) {
      if (t.gzhead.name) {
        let i = t.pending,
          s;
        do {
          if (t.pending === t.pending_buf_size) {
            if (
              (t.gzhead.hcrc &&
                t.pending > i &&
                (e.adler = Be(e.adler, t.pending_buf, t.pending - i, i)),
              De(e),
              t.pending !== 0)
            )
              return ((t.last_flush = -1), Ie);
            i = 0;
          }
          (t.gzindex < t.gzhead.name.length
            ? (s = t.gzhead.name.charCodeAt(t.gzindex++) & 255)
            : (s = 0),
            oe(t, s));
        } while (s !== 0);
        (t.gzhead.hcrc &&
          t.pending > i &&
          (e.adler = Be(e.adler, t.pending_buf, t.pending - i, i)),
          (t.gzindex = 0));
      }
      t.status = Ti;
    }
    if (t.status === Ti) {
      if (t.gzhead.comment) {
        let i = t.pending,
          s;
        do {
          if (t.pending === t.pending_buf_size) {
            if (
              (t.gzhead.hcrc &&
                t.pending > i &&
                (e.adler = Be(e.adler, t.pending_buf, t.pending - i, i)),
              De(e),
              t.pending !== 0)
            )
              return ((t.last_flush = -1), Ie);
            i = 0;
          }
          (t.gzindex < t.gzhead.comment.length
            ? (s = t.gzhead.comment.charCodeAt(t.gzindex++) & 255)
            : (s = 0),
            oe(t, s));
        } while (s !== 0);
        t.gzhead.hcrc &&
          t.pending > i &&
          (e.adler = Be(e.adler, t.pending_buf, t.pending - i, i));
      }
      t.status = Ui;
    }
    if (t.status === Ui) {
      if (t.gzhead.hcrc) {
        if (t.pending + 2 > t.pending_buf_size && (De(e), t.pending !== 0))
          return ((t.last_flush = -1), Ie);
        (oe(t, e.adler & 255), oe(t, (e.adler >> 8) & 255), (e.adler = 0));
      }
      if (((t.status = Ot), De(e), t.pending !== 0))
        return ((t.last_flush = -1), Ie);
    }
    if (
      e.avail_in !== 0 ||
      t.lookahead !== 0 ||
      (r !== It && t.status !== mr)
    ) {
      let i =
        t.level === 0
          ? Xs(t, r)
          : t.strategy === tn
            ? hh(t, r)
            : t.strategy === jf
              ? fh(t, r)
              : Er[t.level].func(t, r);
      if (((i === Pt || i === hr) && (t.status = mr), i === xe || i === Pt))
        return (e.avail_out === 0 && (t.last_flush = -1), Ie);
      if (
        i === fr &&
        (r === Hf
          ? Zf(t)
          : r !== qa &&
            (Ii(t, 0, 0, !1),
            r === Wf &&
              (Et(t.head),
              t.lookahead === 0 &&
                ((t.strstart = 0), (t.block_start = 0), (t.insert = 0)))),
        De(e),
        e.avail_out === 0)
      )
        return ((t.last_flush = -1), Ie);
    }
    return r !== He
      ? Ie
      : t.wrap <= 0
        ? Ja
        : (t.wrap === 2
            ? (oe(t, e.adler & 255),
              oe(t, (e.adler >> 8) & 255),
              oe(t, (e.adler >> 16) & 255),
              oe(t, (e.adler >> 24) & 255),
              oe(t, e.total_in & 255),
              oe(t, (e.total_in >> 8) & 255),
              oe(t, (e.total_in >> 16) & 255),
              oe(t, (e.total_in >> 24) & 255))
            : (pr(t, e.adler >>> 16), pr(t, e.adler & 65535)),
          De(e),
          t.wrap > 0 && (t.wrap = -t.wrap),
          t.pending !== 0 ? Ie : Ja);
  },
  yh = (e) => {
    if (Hr(e)) return Je;
    const r = e.state.status;
    return ((e.state = null), r === Ot ? $t(e, Vf) : Ie);
  },
  bh = (e, r) => {
    let t = r.length;
    if (Hr(e)) return Je;
    const n = e.state,
      i = n.wrap;
    if (i === 2 || (i === 1 && n.status !== sr) || n.lookahead) return Je;
    if (
      (i === 1 && (e.adler = $r(e.adler, r, t, 0)), (n.wrap = 0), t >= n.w_size)
    ) {
      i === 0 &&
        (Et(n.head), (n.strstart = 0), (n.block_start = 0), (n.insert = 0));
      let g = new Uint8Array(n.w_size);
      (g.set(r.subarray(t - n.w_size, t), 0), (r = g), (t = n.w_size));
    }
    const s = e.avail_in,
      l = e.next_in,
      h = e.input;
    for (
      e.avail_in = t, e.next_in = 0, e.input = r, cr(n);
      n.lookahead >= re;
    ) {
      let g = n.strstart,
        u = n.lookahead - (re - 1);
      do
        ((n.ins_h = At(n, n.ins_h, n.window[g + re - 1])),
          (n.prev[g & n.w_mask] = n.head[n.ins_h]),
          (n.head[n.ins_h] = g),
          g++);
      while (--u);
      ((n.strstart = g), (n.lookahead = re - 1), cr(n));
    }
    return (
      (n.strstart += n.lookahead),
      (n.block_start = n.strstart),
      (n.insert = n.lookahead),
      (n.lookahead = 0),
      (n.match_length = n.prev_length = re - 1),
      (n.match_available = 0),
      (e.next_in = l),
      (e.input = h),
      (e.avail_in = s),
      (n.wrap = i),
      Ie
    );
  };
var mh = wh,
  Eh = Qs,
  kh = Js,
  Bh = qs,
  Sh = ph,
  Ih = gh,
  Ah = yh,
  vh = bh,
  xh = "pako deflate (from Nodeca project)",
  Ir = {
    deflateInit: mh,
    deflateInit2: Eh,
    deflateReset: kh,
    deflateResetKeep: Bh,
    deflateSetHeader: Sh,
    deflate: Ih,
    deflateEnd: Ah,
    deflateSetDictionary: vh,
    deflateInfo: xh,
  };
const Th = (e, r) => Object.prototype.hasOwnProperty.call(e, r);
var Uh = function (e) {
    const r = Array.prototype.slice.call(arguments, 1);
    for (; r.length; ) {
      const t = r.shift();
      if (t) {
        if (typeof t != "object") throw new TypeError(t + "must be non-object");
        for (const n in t) Th(t, n) && (e[n] = t[n]);
      }
    }
    return e;
  },
  Rh = (e) => {
    let r = 0;
    for (let n = 0, i = e.length; n < i; n++) r += e[n].length;
    const t = new Uint8Array(r);
    for (let n = 0, i = 0, s = e.length; n < s; n++) {
      let l = e[n];
      (t.set(l, i), (i += l.length));
    }
    return t;
  },
  Dn = { assign: Uh, flattenChunks: Rh };
let ec = !0;
try {
  String.fromCharCode.apply(null, new Uint8Array(1));
} catch {
  ec = !1;
}
const Lr = new Uint8Array(256);
for (let e = 0; e < 256; e++)
  Lr[e] =
    e >= 252
      ? 6
      : e >= 248
        ? 5
        : e >= 240
          ? 4
          : e >= 224
            ? 3
            : e >= 192
              ? 2
              : 1;
Lr[254] = Lr[254] = 1;
var Ch = (e) => {
  if (typeof TextEncoder == "function" && TextEncoder.prototype.encode)
    return new TextEncoder().encode(e);
  let r,
    t,
    n,
    i,
    s,
    l = e.length,
    h = 0;
  for (i = 0; i < l; i++)
    ((t = e.charCodeAt(i)),
      (t & 64512) === 55296 &&
        i + 1 < l &&
        ((n = e.charCodeAt(i + 1)),
        (n & 64512) === 56320 &&
          ((t = 65536 + ((t - 55296) << 10) + (n - 56320)), i++)),
      (h += t < 128 ? 1 : t < 2048 ? 2 : t < 65536 ? 3 : 4));
  for (r = new Uint8Array(h), s = 0, i = 0; s < h; i++)
    ((t = e.charCodeAt(i)),
      (t & 64512) === 55296 &&
        i + 1 < l &&
        ((n = e.charCodeAt(i + 1)),
        (n & 64512) === 56320 &&
          ((t = 65536 + ((t - 55296) << 10) + (n - 56320)), i++)),
      t < 128
        ? (r[s++] = t)
        : t < 2048
          ? ((r[s++] = 192 | (t >>> 6)), (r[s++] = 128 | (t & 63)))
          : t < 65536
            ? ((r[s++] = 224 | (t >>> 12)),
              (r[s++] = 128 | ((t >>> 6) & 63)),
              (r[s++] = 128 | (t & 63)))
            : ((r[s++] = 240 | (t >>> 18)),
              (r[s++] = 128 | ((t >>> 12) & 63)),
              (r[s++] = 128 | ((t >>> 6) & 63)),
              (r[s++] = 128 | (t & 63))));
  return r;
};
const Dh = (e, r) => {
  if (r < 65534 && e.subarray && ec)
    return String.fromCharCode.apply(
      null,
      e.length === r ? e : e.subarray(0, r),
    );
  let t = "";
  for (let n = 0; n < r; n++) t += String.fromCharCode(e[n]);
  return t;
};
var Nh = (e, r) => {
    const t = r || e.length;
    if (typeof TextDecoder == "function" && TextDecoder.prototype.decode)
      return new TextDecoder().decode(e.subarray(0, r));
    let n, i;
    const s = new Array(t * 2);
    for (i = 0, n = 0; n < t; ) {
      let l = e[n++];
      if (l < 128) {
        s[i++] = l;
        continue;
      }
      let h = Lr[l];
      if (h > 4) {
        ((s[i++] = 65533), (n += h - 1));
        continue;
      }
      for (l &= h === 2 ? 31 : h === 3 ? 15 : 7; h > 1 && n < t; )
        ((l = (l << 6) | (e[n++] & 63)), h--);
      if (h > 1) {
        s[i++] = 65533;
        continue;
      }
      l < 65536
        ? (s[i++] = l)
        : ((l -= 65536),
          (s[i++] = 55296 | ((l >> 10) & 1023)),
          (s[i++] = 56320 | (l & 1023)));
    }
    return Dh(s, i);
  },
  Oh = (e, r) => {
    ((r = r || e.length), r > e.length && (r = e.length));
    let t = r - 1;
    for (; t >= 0 && (e[t] & 192) === 128; ) t--;
    return t < 0 || t === 0 ? r : t + Lr[e[t]] > r ? t : r;
  },
  zr = { string2buf: Ch, buf2string: Nh, utf8border: Oh };
function $h() {
  ((this.input = null),
    (this.next_in = 0),
    (this.avail_in = 0),
    (this.total_in = 0),
    (this.output = null),
    (this.next_out = 0),
    (this.avail_out = 0),
    (this.total_out = 0),
    (this.msg = ""),
    (this.state = null),
    (this.data_type = 2),
    (this.adler = 0));
}
var tc = $h;
const rc = Object.prototype.toString,
  {
    Z_NO_FLUSH: Lh,
    Z_SYNC_FLUSH: zh,
    Z_FULL_FLUSH: Fh,
    Z_FINISH: Mh,
    Z_OK: An,
    Z_STREAM_END: Ph,
    Z_DEFAULT_COMPRESSION: Zh,
    Z_DEFAULT_STRATEGY: Hh,
    Z_DEFLATED: Wh,
  } = Zr;
function Wr(e) {
  this.options = Dn.assign(
    {
      level: Zh,
      method: Wh,
      chunkSize: 16384,
      windowBits: 15,
      memLevel: 8,
      strategy: Hh,
    },
    e || {},
  );
  let r = this.options;
  (r.raw && r.windowBits > 0
    ? (r.windowBits = -r.windowBits)
    : r.gzip && r.windowBits > 0 && r.windowBits < 16 && (r.windowBits += 16),
    (this.err = 0),
    (this.msg = ""),
    (this.ended = !1),
    (this.chunks = []),
    (this.strm = new tc()),
    (this.strm.avail_out = 0));
  let t = Ir.deflateInit2(
    this.strm,
    r.level,
    r.method,
    r.windowBits,
    r.memLevel,
    r.strategy,
  );
  if (t !== An) throw new Error(Mt[t]);
  if ((r.header && Ir.deflateSetHeader(this.strm, r.header), r.dictionary)) {
    let n;
    if (
      (typeof r.dictionary == "string"
        ? (n = zr.string2buf(r.dictionary))
        : rc.call(r.dictionary) === "[object ArrayBuffer]"
          ? (n = new Uint8Array(r.dictionary))
          : (n = r.dictionary),
      (t = Ir.deflateSetDictionary(this.strm, n)),
      t !== An)
    )
      throw new Error(Mt[t]);
    this._dict_set = !0;
  }
}
Wr.prototype.push = function (e, r) {
  const t = this.strm,
    n = this.options.chunkSize;
  let i, s;
  if (this.ended) return !1;
  for (
    r === ~~r ? (s = r) : (s = r === !0 ? Mh : Lh),
      typeof e == "string"
        ? (t.input = zr.string2buf(e))
        : rc.call(e) === "[object ArrayBuffer]"
          ? (t.input = new Uint8Array(e))
          : (t.input = e),
      t.next_in = 0,
      t.avail_in = t.input.length;
    ;
  ) {
    if (
      (t.avail_out === 0 &&
        ((t.output = new Uint8Array(n)), (t.next_out = 0), (t.avail_out = n)),
      (s === zh || s === Fh) && t.avail_out <= 6)
    ) {
      (this.onData(t.output.subarray(0, t.next_out)), (t.avail_out = 0));
      continue;
    }
    if (((i = Ir.deflate(t, s)), i === Ph))
      return (
        t.next_out > 0 && this.onData(t.output.subarray(0, t.next_out)),
        (i = Ir.deflateEnd(this.strm)),
        this.onEnd(i),
        (this.ended = !0),
        i === An
      );
    if (t.avail_out === 0) {
      this.onData(t.output);
      continue;
    }
    if (s > 0 && t.next_out > 0) {
      (this.onData(t.output.subarray(0, t.next_out)), (t.avail_out = 0));
      continue;
    }
    if (t.avail_in === 0) break;
  }
  return !0;
};
Wr.prototype.onData = function (e) {
  this.chunks.push(e);
};
Wr.prototype.onEnd = function (e) {
  (e === An && (this.result = Dn.flattenChunks(this.chunks)),
    (this.chunks = []),
    (this.err = e),
    (this.msg = this.strm.msg));
};
function Yi(e, r) {
  const t = new Wr(r);
  if ((t.push(e, !0), t.err)) throw t.msg || Mt[t.err];
  return t.result;
}
function Vh(e, r) {
  return ((r = r || {}), (r.raw = !0), Yi(e, r));
}
function Yh(e, r) {
  return ((r = r || {}), (r.gzip = !0), Yi(e, r));
}
var Gh = Wr,
  jh = Yi,
  Kh = Vh,
  Xh = Yh,
  qh = { Deflate: Gh, deflate: jh, deflateRaw: Kh, gzip: Xh };
const rn = 16209,
  Jh = 16191;
var Qh = function (r, t) {
  let n, i, s, l, h, g, u, d, E, b, y, I, x, T, R, $, D, m, z, V, C, H, M, N;
  const F = r.state;
  ((n = r.next_in),
    (M = r.input),
    (i = n + (r.avail_in - 5)),
    (s = r.next_out),
    (N = r.output),
    (l = s - (t - r.avail_out)),
    (h = s + (r.avail_out - 257)),
    (g = F.dmax),
    (u = F.wsize),
    (d = F.whave),
    (E = F.wnext),
    (b = F.window),
    (y = F.hold),
    (I = F.bits),
    (x = F.lencode),
    (T = F.distcode),
    (R = (1 << F.lenbits) - 1),
    ($ = (1 << F.distbits) - 1));
  e: do {
    (I < 15 && ((y += M[n++] << I), (I += 8), (y += M[n++] << I), (I += 8)),
      (D = x[y & R]));
    t: for (;;) {
      if (
        ((m = D >>> 24), (y >>>= m), (I -= m), (m = (D >>> 16) & 255), m === 0)
      )
        N[s++] = D & 65535;
      else if (m & 16) {
        ((z = D & 65535),
          (m &= 15),
          m &&
            (I < m && ((y += M[n++] << I), (I += 8)),
            (z += y & ((1 << m) - 1)),
            (y >>>= m),
            (I -= m)),
          I < 15 &&
            ((y += M[n++] << I), (I += 8), (y += M[n++] << I), (I += 8)),
          (D = T[y & $]));
        r: for (;;) {
          if (
            ((m = D >>> 24),
            (y >>>= m),
            (I -= m),
            (m = (D >>> 16) & 255),
            m & 16)
          ) {
            if (
              ((V = D & 65535),
              (m &= 15),
              I < m &&
                ((y += M[n++] << I),
                (I += 8),
                I < m && ((y += M[n++] << I), (I += 8))),
              (V += y & ((1 << m) - 1)),
              V > g)
            ) {
              ((r.msg = "invalid distance too far back"), (F.mode = rn));
              break e;
            }
            if (((y >>>= m), (I -= m), (m = s - l), V > m)) {
              if (((m = V - m), m > d && F.sane)) {
                ((r.msg = "invalid distance too far back"), (F.mode = rn));
                break e;
              }
              if (((C = 0), (H = b), E === 0)) {
                if (((C += u - m), m < z)) {
                  z -= m;
                  do N[s++] = b[C++];
                  while (--m);
                  ((C = s - V), (H = N));
                }
              } else if (E < m) {
                if (((C += u + E - m), (m -= E), m < z)) {
                  z -= m;
                  do N[s++] = b[C++];
                  while (--m);
                  if (((C = 0), E < z)) {
                    ((m = E), (z -= m));
                    do N[s++] = b[C++];
                    while (--m);
                    ((C = s - V), (H = N));
                  }
                }
              } else if (((C += E - m), m < z)) {
                z -= m;
                do N[s++] = b[C++];
                while (--m);
                ((C = s - V), (H = N));
              }
              for (; z > 2; )
                ((N[s++] = H[C++]),
                  (N[s++] = H[C++]),
                  (N[s++] = H[C++]),
                  (z -= 3));
              z && ((N[s++] = H[C++]), z > 1 && (N[s++] = H[C++]));
            } else {
              C = s - V;
              do
                ((N[s++] = N[C++]),
                  (N[s++] = N[C++]),
                  (N[s++] = N[C++]),
                  (z -= 3));
              while (z > 2);
              z && ((N[s++] = N[C++]), z > 1 && (N[s++] = N[C++]));
            }
          } else if ((m & 64) === 0) {
            D = T[(D & 65535) + (y & ((1 << m) - 1))];
            continue r;
          } else {
            ((r.msg = "invalid distance code"), (F.mode = rn));
            break e;
          }
          break;
        }
      } else if ((m & 64) === 0) {
        D = x[(D & 65535) + (y & ((1 << m) - 1))];
        continue t;
      } else if (m & 32) {
        F.mode = Jh;
        break e;
      } else {
        ((r.msg = "invalid literal/length code"), (F.mode = rn));
        break e;
      }
      break;
    }
  } while (n < i && s < h);
  ((z = I >> 3),
    (n -= z),
    (I -= z << 3),
    (y &= (1 << I) - 1),
    (r.next_in = n),
    (r.next_out = s),
    (r.avail_in = n < i ? 5 + (i - n) : 5 - (n - i)),
    (r.avail_out = s < h ? 257 + (h - s) : 257 - (s - h)),
    (F.hold = y),
    (F.bits = I));
};
const Qt = 15,
  eo = 852,
  to = 592,
  ro = 0,
  ai = 1,
  no = 2,
  e1 = new Uint16Array([
    3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 19, 23, 27, 31, 35, 43, 51, 59, 67,
    83, 99, 115, 131, 163, 195, 227, 258, 0, 0,
  ]),
  t1 = new Uint8Array([
    16, 16, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19,
    19, 20, 20, 20, 20, 21, 21, 21, 21, 16, 72, 78,
  ]),
  r1 = new Uint16Array([
    1, 2, 3, 4, 5, 7, 9, 13, 17, 25, 33, 49, 65, 97, 129, 193, 257, 385, 513,
    769, 1025, 1537, 2049, 3073, 4097, 6145, 8193, 12289, 16385, 24577, 0, 0,
  ]),
  n1 = new Uint8Array([
    16, 16, 16, 16, 17, 17, 18, 18, 19, 19, 20, 20, 21, 21, 22, 22, 23, 23, 24,
    24, 25, 25, 26, 26, 27, 27, 28, 28, 29, 29, 64, 64,
  ]),
  i1 = (e, r, t, n, i, s, l, h) => {
    const g = h.bits;
    let u = 0,
      d = 0,
      E = 0,
      b = 0,
      y = 0,
      I = 0,
      x = 0,
      T = 0,
      R = 0,
      $ = 0,
      D,
      m,
      z,
      V,
      C,
      H = null,
      M;
    const N = new Uint16Array(Qt + 1),
      F = new Uint16Array(Qt + 1);
    let se = null,
      A,
      P,
      L;
    for (u = 0; u <= Qt; u++) N[u] = 0;
    for (d = 0; d < n; d++) N[r[t + d]]++;
    for (y = g, b = Qt; b >= 1 && N[b] === 0; b--);
    if ((y > b && (y = b), b === 0))
      return (
        (i[s++] = (1 << 24) | (64 << 16) | 0),
        (i[s++] = (1 << 24) | (64 << 16) | 0),
        (h.bits = 1),
        0
      );
    for (E = 1; E < b && N[E] === 0; E++);
    for (y < E && (y = E), T = 1, u = 1; u <= Qt; u++)
      if (((T <<= 1), (T -= N[u]), T < 0)) return -1;
    if (T > 0 && (e === ro || b !== 1)) return -1;
    for (F[1] = 0, u = 1; u < Qt; u++) F[u + 1] = F[u] + N[u];
    for (d = 0; d < n; d++) r[t + d] !== 0 && (l[F[r[t + d]]++] = d);
    if (
      (e === ro
        ? ((H = se = l), (M = 20))
        : e === ai
          ? ((H = e1), (se = t1), (M = 257))
          : ((H = r1), (se = n1), (M = 0)),
      ($ = 0),
      (d = 0),
      (u = E),
      (C = s),
      (I = y),
      (x = 0),
      (z = -1),
      (R = 1 << y),
      (V = R - 1),
      (e === ai && R > eo) || (e === no && R > to))
    )
      return 1;
    for (;;) {
      ((A = u - x),
        l[d] + 1 < M
          ? ((P = 0), (L = l[d]))
          : l[d] >= M
            ? ((P = se[l[d] - M]), (L = H[l[d] - M]))
            : ((P = 96), (L = 0)),
        (D = 1 << (u - x)),
        (m = 1 << I),
        (E = m));
      do ((m -= D), (i[C + ($ >> x) + m] = (A << 24) | (P << 16) | L | 0));
      while (m !== 0);
      for (D = 1 << (u - 1); $ & D; ) D >>= 1;
      if ((D !== 0 ? (($ &= D - 1), ($ += D)) : ($ = 0), d++, --N[u] === 0)) {
        if (u === b) break;
        u = r[t + l[d]];
      }
      if (u > y && ($ & V) !== z) {
        for (
          x === 0 && (x = y), C += E, I = u - x, T = 1 << I;
          I + x < b && ((T -= N[I + x]), !(T <= 0));
        )
          (I++, (T <<= 1));
        if (((R += 1 << I), (e === ai && R > eo) || (e === no && R > to)))
          return 1;
        ((z = $ & V), (i[z] = (y << 24) | (I << 16) | (C - s) | 0));
      }
    }
    return (
      $ !== 0 && (i[C + $] = ((u - x) << 24) | (64 << 16) | 0),
      (h.bits = y),
      0
    );
  };
var Ar = i1;
const a1 = 0,
  nc = 1,
  ic = 2,
  {
    Z_FINISH: io,
    Z_BLOCK: o1,
    Z_TREES: nn,
    Z_OK: Zt,
    Z_STREAM_END: s1,
    Z_NEED_DICT: c1,
    Z_STREAM_ERROR: Ve,
    Z_DATA_ERROR: ac,
    Z_MEM_ERROR: oc,
    Z_BUF_ERROR: l1,
    Z_DEFLATED: ao,
  } = Zr,
  Nn = 16180,
  oo = 16181,
  so = 16182,
  co = 16183,
  lo = 16184,
  uo = 16185,
  fo = 16186,
  ho = 16187,
  _o = 16188,
  po = 16189,
  vn = 16190,
  it = 16191,
  oi = 16192,
  wo = 16193,
  si = 16194,
  go = 16195,
  yo = 16196,
  bo = 16197,
  mo = 16198,
  an = 16199,
  on = 16200,
  Eo = 16201,
  ko = 16202,
  Bo = 16203,
  So = 16204,
  Io = 16205,
  ci = 16206,
  Ao = 16207,
  vo = 16208,
  we = 16209,
  sc = 16210,
  cc = 16211,
  u1 = 852,
  f1 = 592,
  h1 = 15,
  d1 = h1,
  xo = (e) =>
    ((e >>> 24) & 255) +
    ((e >>> 8) & 65280) +
    ((e & 65280) << 8) +
    ((e & 255) << 24);
function _1() {
  ((this.strm = null),
    (this.mode = 0),
    (this.last = !1),
    (this.wrap = 0),
    (this.havedict = !1),
    (this.flags = 0),
    (this.dmax = 0),
    (this.check = 0),
    (this.total = 0),
    (this.head = null),
    (this.wbits = 0),
    (this.wsize = 0),
    (this.whave = 0),
    (this.wnext = 0),
    (this.window = null),
    (this.hold = 0),
    (this.bits = 0),
    (this.length = 0),
    (this.offset = 0),
    (this.extra = 0),
    (this.lencode = null),
    (this.distcode = null),
    (this.lenbits = 0),
    (this.distbits = 0),
    (this.ncode = 0),
    (this.nlen = 0),
    (this.ndist = 0),
    (this.have = 0),
    (this.next = null),
    (this.lens = new Uint16Array(320)),
    (this.work = new Uint16Array(288)),
    (this.lendyn = null),
    (this.distdyn = null),
    (this.sane = 0),
    (this.back = 0),
    (this.was = 0));
}
const Wt = (e) => {
    if (!e) return 1;
    const r = e.state;
    return !r || r.strm !== e || r.mode < Nn || r.mode > cc ? 1 : 0;
  },
  lc = (e) => {
    if (Wt(e)) return Ve;
    const r = e.state;
    return (
      (e.total_in = e.total_out = r.total = 0),
      (e.msg = ""),
      r.wrap && (e.adler = r.wrap & 1),
      (r.mode = Nn),
      (r.last = 0),
      (r.havedict = 0),
      (r.flags = -1),
      (r.dmax = 32768),
      (r.head = null),
      (r.hold = 0),
      (r.bits = 0),
      (r.lencode = r.lendyn = new Int32Array(u1)),
      (r.distcode = r.distdyn = new Int32Array(f1)),
      (r.sane = 1),
      (r.back = -1),
      Zt
    );
  },
  uc = (e) => {
    if (Wt(e)) return Ve;
    const r = e.state;
    return ((r.wsize = 0), (r.whave = 0), (r.wnext = 0), lc(e));
  },
  fc = (e, r) => {
    let t;
    if (Wt(e)) return Ve;
    const n = e.state;
    return (
      r < 0 ? ((t = 0), (r = -r)) : ((t = (r >> 4) + 5), r < 48 && (r &= 15)),
      r && (r < 8 || r > 15)
        ? Ve
        : (n.window !== null && n.wbits !== r && (n.window = null),
          (n.wrap = t),
          (n.wbits = r),
          uc(e))
    );
  },
  hc = (e, r) => {
    if (!e) return Ve;
    const t = new _1();
    ((e.state = t), (t.strm = e), (t.window = null), (t.mode = Nn));
    const n = fc(e, r);
    return (n !== Zt && (e.state = null), n);
  },
  p1 = (e) => hc(e, d1);
let To = !0,
  li,
  ui;
const w1 = (e) => {
    if (To) {
      ((li = new Int32Array(512)), (ui = new Int32Array(32)));
      let r = 0;
      for (; r < 144; ) e.lens[r++] = 8;
      for (; r < 256; ) e.lens[r++] = 9;
      for (; r < 280; ) e.lens[r++] = 7;
      for (; r < 288; ) e.lens[r++] = 8;
      for (Ar(nc, e.lens, 0, 288, li, 0, e.work, { bits: 9 }), r = 0; r < 32; )
        e.lens[r++] = 5;
      (Ar(ic, e.lens, 0, 32, ui, 0, e.work, { bits: 5 }), (To = !1));
    }
    ((e.lencode = li), (e.lenbits = 9), (e.distcode = ui), (e.distbits = 5));
  },
  dc = (e, r, t, n) => {
    let i;
    const s = e.state;
    return (
      s.window === null &&
        ((s.wsize = 1 << s.wbits),
        (s.wnext = 0),
        (s.whave = 0),
        (s.window = new Uint8Array(s.wsize))),
      n >= s.wsize
        ? (s.window.set(r.subarray(t - s.wsize, t), 0),
          (s.wnext = 0),
          (s.whave = s.wsize))
        : ((i = s.wsize - s.wnext),
          i > n && (i = n),
          s.window.set(r.subarray(t - n, t - n + i), s.wnext),
          (n -= i),
          n
            ? (s.window.set(r.subarray(t - n, t), 0),
              (s.wnext = n),
              (s.whave = s.wsize))
            : ((s.wnext += i),
              s.wnext === s.wsize && (s.wnext = 0),
              s.whave < s.wsize && (s.whave += i))),
      0
    );
  },
  g1 = (e, r) => {
    let t,
      n,
      i,
      s,
      l,
      h,
      g,
      u,
      d,
      E,
      b,
      y,
      I,
      x,
      T = 0,
      R,
      $,
      D,
      m,
      z,
      V,
      C,
      H;
    const M = new Uint8Array(4);
    let N, F;
    const se = new Uint8Array([
      16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15,
    ]);
    if (Wt(e) || !e.output || (!e.input && e.avail_in !== 0)) return Ve;
    ((t = e.state),
      t.mode === it && (t.mode = oi),
      (l = e.next_out),
      (i = e.output),
      (g = e.avail_out),
      (s = e.next_in),
      (n = e.input),
      (h = e.avail_in),
      (u = t.hold),
      (d = t.bits),
      (E = h),
      (b = g),
      (H = Zt));
    e: for (;;)
      switch (t.mode) {
        case Nn:
          if (t.wrap === 0) {
            t.mode = oi;
            break;
          }
          for (; d < 16; ) {
            if (h === 0) break e;
            (h--, (u += n[s++] << d), (d += 8));
          }
          if (t.wrap & 2 && u === 35615) {
            (t.wbits === 0 && (t.wbits = 15),
              (t.check = 0),
              (M[0] = u & 255),
              (M[1] = (u >>> 8) & 255),
              (t.check = Be(t.check, M, 2, 0)),
              (u = 0),
              (d = 0),
              (t.mode = oo));
            break;
          }
          if (
            (t.head && (t.head.done = !1),
            !(t.wrap & 1) || (((u & 255) << 8) + (u >> 8)) % 31)
          ) {
            ((e.msg = "incorrect header check"), (t.mode = we));
            break;
          }
          if ((u & 15) !== ao) {
            ((e.msg = "unknown compression method"), (t.mode = we));
            break;
          }
          if (
            ((u >>>= 4),
            (d -= 4),
            (C = (u & 15) + 8),
            t.wbits === 0 && (t.wbits = C),
            C > 15 || C > t.wbits)
          ) {
            ((e.msg = "invalid window size"), (t.mode = we));
            break;
          }
          ((t.dmax = 1 << t.wbits),
            (t.flags = 0),
            (e.adler = t.check = 1),
            (t.mode = u & 512 ? po : it),
            (u = 0),
            (d = 0));
          break;
        case oo:
          for (; d < 16; ) {
            if (h === 0) break e;
            (h--, (u += n[s++] << d), (d += 8));
          }
          if (((t.flags = u), (t.flags & 255) !== ao)) {
            ((e.msg = "unknown compression method"), (t.mode = we));
            break;
          }
          if (t.flags & 57344) {
            ((e.msg = "unknown header flags set"), (t.mode = we));
            break;
          }
          (t.head && (t.head.text = (u >> 8) & 1),
            t.flags & 512 &&
              t.wrap & 4 &&
              ((M[0] = u & 255),
              (M[1] = (u >>> 8) & 255),
              (t.check = Be(t.check, M, 2, 0))),
            (u = 0),
            (d = 0),
            (t.mode = so));
        case so:
          for (; d < 32; ) {
            if (h === 0) break e;
            (h--, (u += n[s++] << d), (d += 8));
          }
          (t.head && (t.head.time = u),
            t.flags & 512 &&
              t.wrap & 4 &&
              ((M[0] = u & 255),
              (M[1] = (u >>> 8) & 255),
              (M[2] = (u >>> 16) & 255),
              (M[3] = (u >>> 24) & 255),
              (t.check = Be(t.check, M, 4, 0))),
            (u = 0),
            (d = 0),
            (t.mode = co));
        case co:
          for (; d < 16; ) {
            if (h === 0) break e;
            (h--, (u += n[s++] << d), (d += 8));
          }
          (t.head && ((t.head.xflags = u & 255), (t.head.os = u >> 8)),
            t.flags & 512 &&
              t.wrap & 4 &&
              ((M[0] = u & 255),
              (M[1] = (u >>> 8) & 255),
              (t.check = Be(t.check, M, 2, 0))),
            (u = 0),
            (d = 0),
            (t.mode = lo));
        case lo:
          if (t.flags & 1024) {
            for (; d < 16; ) {
              if (h === 0) break e;
              (h--, (u += n[s++] << d), (d += 8));
            }
            ((t.length = u),
              t.head && (t.head.extra_len = u),
              t.flags & 512 &&
                t.wrap & 4 &&
                ((M[0] = u & 255),
                (M[1] = (u >>> 8) & 255),
                (t.check = Be(t.check, M, 2, 0))),
              (u = 0),
              (d = 0));
          } else t.head && (t.head.extra = null);
          t.mode = uo;
        case uo:
          if (
            t.flags & 1024 &&
            ((y = t.length),
            y > h && (y = h),
            y &&
              (t.head &&
                ((C = t.head.extra_len - t.length),
                t.head.extra ||
                  (t.head.extra = new Uint8Array(t.head.extra_len)),
                t.head.extra.set(n.subarray(s, s + y), C)),
              t.flags & 512 && t.wrap & 4 && (t.check = Be(t.check, n, y, s)),
              (h -= y),
              (s += y),
              (t.length -= y)),
            t.length)
          )
            break e;
          ((t.length = 0), (t.mode = fo));
        case fo:
          if (t.flags & 2048) {
            if (h === 0) break e;
            y = 0;
            do
              ((C = n[s + y++]),
                t.head &&
                  C &&
                  t.length < 65536 &&
                  (t.head.name += String.fromCharCode(C)));
            while (C && y < h);
            if (
              (t.flags & 512 && t.wrap & 4 && (t.check = Be(t.check, n, y, s)),
              (h -= y),
              (s += y),
              C)
            )
              break e;
          } else t.head && (t.head.name = null);
          ((t.length = 0), (t.mode = ho));
        case ho:
          if (t.flags & 4096) {
            if (h === 0) break e;
            y = 0;
            do
              ((C = n[s + y++]),
                t.head &&
                  C &&
                  t.length < 65536 &&
                  (t.head.comment += String.fromCharCode(C)));
            while (C && y < h);
            if (
              (t.flags & 512 && t.wrap & 4 && (t.check = Be(t.check, n, y, s)),
              (h -= y),
              (s += y),
              C)
            )
              break e;
          } else t.head && (t.head.comment = null);
          t.mode = _o;
        case _o:
          if (t.flags & 512) {
            for (; d < 16; ) {
              if (h === 0) break e;
              (h--, (u += n[s++] << d), (d += 8));
            }
            if (t.wrap & 4 && u !== (t.check & 65535)) {
              ((e.msg = "header crc mismatch"), (t.mode = we));
              break;
            }
            ((u = 0), (d = 0));
          }
          (t.head && ((t.head.hcrc = (t.flags >> 9) & 1), (t.head.done = !0)),
            (e.adler = t.check = 0),
            (t.mode = it));
          break;
        case po:
          for (; d < 32; ) {
            if (h === 0) break e;
            (h--, (u += n[s++] << d), (d += 8));
          }
          ((e.adler = t.check = xo(u)), (u = 0), (d = 0), (t.mode = vn));
        case vn:
          if (t.havedict === 0)
            return (
              (e.next_out = l),
              (e.avail_out = g),
              (e.next_in = s),
              (e.avail_in = h),
              (t.hold = u),
              (t.bits = d),
              c1
            );
          ((e.adler = t.check = 1), (t.mode = it));
        case it:
          if (r === o1 || r === nn) break e;
        case oi:
          if (t.last) {
            ((u >>>= d & 7), (d -= d & 7), (t.mode = ci));
            break;
          }
          for (; d < 3; ) {
            if (h === 0) break e;
            (h--, (u += n[s++] << d), (d += 8));
          }
          switch (((t.last = u & 1), (u >>>= 1), (d -= 1), u & 3)) {
            case 0:
              t.mode = wo;
              break;
            case 1:
              if ((w1(t), (t.mode = an), r === nn)) {
                ((u >>>= 2), (d -= 2));
                break e;
              }
              break;
            case 2:
              t.mode = yo;
              break;
            case 3:
              ((e.msg = "invalid block type"), (t.mode = we));
          }
          ((u >>>= 2), (d -= 2));
          break;
        case wo:
          for (u >>>= d & 7, d -= d & 7; d < 32; ) {
            if (h === 0) break e;
            (h--, (u += n[s++] << d), (d += 8));
          }
          if ((u & 65535) !== ((u >>> 16) ^ 65535)) {
            ((e.msg = "invalid stored block lengths"), (t.mode = we));
            break;
          }
          if (
            ((t.length = u & 65535), (u = 0), (d = 0), (t.mode = si), r === nn)
          )
            break e;
        case si:
          t.mode = go;
        case go:
          if (((y = t.length), y)) {
            if ((y > h && (y = h), y > g && (y = g), y === 0)) break e;
            (i.set(n.subarray(s, s + y), l),
              (h -= y),
              (s += y),
              (g -= y),
              (l += y),
              (t.length -= y));
            break;
          }
          t.mode = it;
          break;
        case yo:
          for (; d < 14; ) {
            if (h === 0) break e;
            (h--, (u += n[s++] << d), (d += 8));
          }
          if (
            ((t.nlen = (u & 31) + 257),
            (u >>>= 5),
            (d -= 5),
            (t.ndist = (u & 31) + 1),
            (u >>>= 5),
            (d -= 5),
            (t.ncode = (u & 15) + 4),
            (u >>>= 4),
            (d -= 4),
            t.nlen > 286 || t.ndist > 30)
          ) {
            ((e.msg = "too many length or distance symbols"), (t.mode = we));
            break;
          }
          ((t.have = 0), (t.mode = bo));
        case bo:
          for (; t.have < t.ncode; ) {
            for (; d < 3; ) {
              if (h === 0) break e;
              (h--, (u += n[s++] << d), (d += 8));
            }
            ((t.lens[se[t.have++]] = u & 7), (u >>>= 3), (d -= 3));
          }
          for (; t.have < 19; ) t.lens[se[t.have++]] = 0;
          if (
            ((t.lencode = t.lendyn),
            (t.lenbits = 7),
            (N = { bits: t.lenbits }),
            (H = Ar(a1, t.lens, 0, 19, t.lencode, 0, t.work, N)),
            (t.lenbits = N.bits),
            H)
          ) {
            ((e.msg = "invalid code lengths set"), (t.mode = we));
            break;
          }
          ((t.have = 0), (t.mode = mo));
        case mo:
          for (; t.have < t.nlen + t.ndist; ) {
            for (
              ;
              (T = t.lencode[u & ((1 << t.lenbits) - 1)]),
                (R = T >>> 24),
                ($ = (T >>> 16) & 255),
                (D = T & 65535),
                !(R <= d);
            ) {
              if (h === 0) break e;
              (h--, (u += n[s++] << d), (d += 8));
            }
            if (D < 16) ((u >>>= R), (d -= R), (t.lens[t.have++] = D));
            else {
              if (D === 16) {
                for (F = R + 2; d < F; ) {
                  if (h === 0) break e;
                  (h--, (u += n[s++] << d), (d += 8));
                }
                if (((u >>>= R), (d -= R), t.have === 0)) {
                  ((e.msg = "invalid bit length repeat"), (t.mode = we));
                  break;
                }
                ((C = t.lens[t.have - 1]),
                  (y = 3 + (u & 3)),
                  (u >>>= 2),
                  (d -= 2));
              } else if (D === 17) {
                for (F = R + 3; d < F; ) {
                  if (h === 0) break e;
                  (h--, (u += n[s++] << d), (d += 8));
                }
                ((u >>>= R),
                  (d -= R),
                  (C = 0),
                  (y = 3 + (u & 7)),
                  (u >>>= 3),
                  (d -= 3));
              } else {
                for (F = R + 7; d < F; ) {
                  if (h === 0) break e;
                  (h--, (u += n[s++] << d), (d += 8));
                }
                ((u >>>= R),
                  (d -= R),
                  (C = 0),
                  (y = 11 + (u & 127)),
                  (u >>>= 7),
                  (d -= 7));
              }
              if (t.have + y > t.nlen + t.ndist) {
                ((e.msg = "invalid bit length repeat"), (t.mode = we));
                break;
              }
              for (; y--; ) t.lens[t.have++] = C;
            }
          }
          if (t.mode === we) break;
          if (t.lens[256] === 0) {
            ((e.msg = "invalid code -- missing end-of-block"), (t.mode = we));
            break;
          }
          if (
            ((t.lenbits = 9),
            (N = { bits: t.lenbits }),
            (H = Ar(nc, t.lens, 0, t.nlen, t.lencode, 0, t.work, N)),
            (t.lenbits = N.bits),
            H)
          ) {
            ((e.msg = "invalid literal/lengths set"), (t.mode = we));
            break;
          }
          if (
            ((t.distbits = 6),
            (t.distcode = t.distdyn),
            (N = { bits: t.distbits }),
            (H = Ar(ic, t.lens, t.nlen, t.ndist, t.distcode, 0, t.work, N)),
            (t.distbits = N.bits),
            H)
          ) {
            ((e.msg = "invalid distances set"), (t.mode = we));
            break;
          }
          if (((t.mode = an), r === nn)) break e;
        case an:
          t.mode = on;
        case on:
          if (h >= 6 && g >= 258) {
            ((e.next_out = l),
              (e.avail_out = g),
              (e.next_in = s),
              (e.avail_in = h),
              (t.hold = u),
              (t.bits = d),
              Qh(e, b),
              (l = e.next_out),
              (i = e.output),
              (g = e.avail_out),
              (s = e.next_in),
              (n = e.input),
              (h = e.avail_in),
              (u = t.hold),
              (d = t.bits),
              t.mode === it && (t.back = -1));
            break;
          }
          for (
            t.back = 0;
            (T = t.lencode[u & ((1 << t.lenbits) - 1)]),
              (R = T >>> 24),
              ($ = (T >>> 16) & 255),
              (D = T & 65535),
              !(R <= d);
          ) {
            if (h === 0) break e;
            (h--, (u += n[s++] << d), (d += 8));
          }
          if ($ && ($ & 240) === 0) {
            for (
              m = R, z = $, V = D;
              (T = t.lencode[V + ((u & ((1 << (m + z)) - 1)) >> m)]),
                (R = T >>> 24),
                ($ = (T >>> 16) & 255),
                (D = T & 65535),
                !(m + R <= d);
            ) {
              if (h === 0) break e;
              (h--, (u += n[s++] << d), (d += 8));
            }
            ((u >>>= m), (d -= m), (t.back += m));
          }
          if (((u >>>= R), (d -= R), (t.back += R), (t.length = D), $ === 0)) {
            t.mode = Io;
            break;
          }
          if ($ & 32) {
            ((t.back = -1), (t.mode = it));
            break;
          }
          if ($ & 64) {
            ((e.msg = "invalid literal/length code"), (t.mode = we));
            break;
          }
          ((t.extra = $ & 15), (t.mode = Eo));
        case Eo:
          if (t.extra) {
            for (F = t.extra; d < F; ) {
              if (h === 0) break e;
              (h--, (u += n[s++] << d), (d += 8));
            }
            ((t.length += u & ((1 << t.extra) - 1)),
              (u >>>= t.extra),
              (d -= t.extra),
              (t.back += t.extra));
          }
          ((t.was = t.length), (t.mode = ko));
        case ko:
          for (
            ;
            (T = t.distcode[u & ((1 << t.distbits) - 1)]),
              (R = T >>> 24),
              ($ = (T >>> 16) & 255),
              (D = T & 65535),
              !(R <= d);
          ) {
            if (h === 0) break e;
            (h--, (u += n[s++] << d), (d += 8));
          }
          if (($ & 240) === 0) {
            for (
              m = R, z = $, V = D;
              (T = t.distcode[V + ((u & ((1 << (m + z)) - 1)) >> m)]),
                (R = T >>> 24),
                ($ = (T >>> 16) & 255),
                (D = T & 65535),
                !(m + R <= d);
            ) {
              if (h === 0) break e;
              (h--, (u += n[s++] << d), (d += 8));
            }
            ((u >>>= m), (d -= m), (t.back += m));
          }
          if (((u >>>= R), (d -= R), (t.back += R), $ & 64)) {
            ((e.msg = "invalid distance code"), (t.mode = we));
            break;
          }
          ((t.offset = D), (t.extra = $ & 15), (t.mode = Bo));
        case Bo:
          if (t.extra) {
            for (F = t.extra; d < F; ) {
              if (h === 0) break e;
              (h--, (u += n[s++] << d), (d += 8));
            }
            ((t.offset += u & ((1 << t.extra) - 1)),
              (u >>>= t.extra),
              (d -= t.extra),
              (t.back += t.extra));
          }
          if (t.offset > t.dmax) {
            ((e.msg = "invalid distance too far back"), (t.mode = we));
            break;
          }
          t.mode = So;
        case So:
          if (g === 0) break e;
          if (((y = b - g), t.offset > y)) {
            if (((y = t.offset - y), y > t.whave && t.sane)) {
              ((e.msg = "invalid distance too far back"), (t.mode = we));
              break;
            }
            (y > t.wnext
              ? ((y -= t.wnext), (I = t.wsize - y))
              : (I = t.wnext - y),
              y > t.length && (y = t.length),
              (x = t.window));
          } else ((x = i), (I = l - t.offset), (y = t.length));
          (y > g && (y = g), (g -= y), (t.length -= y));
          do i[l++] = x[I++];
          while (--y);
          t.length === 0 && (t.mode = on);
          break;
        case Io:
          if (g === 0) break e;
          ((i[l++] = t.length), g--, (t.mode = on));
          break;
        case ci:
          if (t.wrap) {
            for (; d < 32; ) {
              if (h === 0) break e;
              (h--, (u |= n[s++] << d), (d += 8));
            }
            if (
              ((b -= g),
              (e.total_out += b),
              (t.total += b),
              t.wrap & 4 &&
                b &&
                (e.adler = t.check =
                  t.flags
                    ? Be(t.check, i, b, l - b)
                    : $r(t.check, i, b, l - b)),
              (b = g),
              t.wrap & 4 && (t.flags ? u : xo(u)) !== t.check)
            ) {
              ((e.msg = "incorrect data check"), (t.mode = we));
              break;
            }
            ((u = 0), (d = 0));
          }
          t.mode = Ao;
        case Ao:
          if (t.wrap && t.flags) {
            for (; d < 32; ) {
              if (h === 0) break e;
              (h--, (u += n[s++] << d), (d += 8));
            }
            if (t.wrap & 4 && u !== (t.total & 4294967295)) {
              ((e.msg = "incorrect length check"), (t.mode = we));
              break;
            }
            ((u = 0), (d = 0));
          }
          t.mode = vo;
        case vo:
          H = s1;
          break e;
        case we:
          H = ac;
          break e;
        case sc:
          return oc;
        case cc:
        default:
          return Ve;
      }
    return (
      (e.next_out = l),
      (e.avail_out = g),
      (e.next_in = s),
      (e.avail_in = h),
      (t.hold = u),
      (t.bits = d),
      (t.wsize ||
        (b !== e.avail_out && t.mode < we && (t.mode < ci || r !== io))) &&
        dc(e, e.output, e.next_out, b - e.avail_out),
      (E -= e.avail_in),
      (b -= e.avail_out),
      (e.total_in += E),
      (e.total_out += b),
      (t.total += b),
      t.wrap & 4 &&
        b &&
        (e.adler = t.check =
          t.flags
            ? Be(t.check, i, b, e.next_out - b)
            : $r(t.check, i, b, e.next_out - b)),
      (e.data_type =
        t.bits +
        (t.last ? 64 : 0) +
        (t.mode === it ? 128 : 0) +
        (t.mode === an || t.mode === si ? 256 : 0)),
      ((E === 0 && b === 0) || r === io) && H === Zt && (H = l1),
      H
    );
  },
  y1 = (e) => {
    if (Wt(e)) return Ve;
    let r = e.state;
    return (r.window && (r.window = null), (e.state = null), Zt);
  },
  b1 = (e, r) => {
    if (Wt(e)) return Ve;
    const t = e.state;
    return (t.wrap & 2) === 0 ? Ve : ((t.head = r), (r.done = !1), Zt);
  },
  m1 = (e, r) => {
    const t = r.length;
    let n, i, s;
    return Wt(e) || ((n = e.state), n.wrap !== 0 && n.mode !== vn)
      ? Ve
      : n.mode === vn && ((i = 1), (i = $r(i, r, t, 0)), i !== n.check)
        ? ac
        : ((s = dc(e, r, t, t)),
          s ? ((n.mode = sc), oc) : ((n.havedict = 1), Zt));
  };
var E1 = uc,
  k1 = fc,
  B1 = lc,
  S1 = p1,
  I1 = hc,
  A1 = g1,
  v1 = y1,
  x1 = b1,
  T1 = m1,
  U1 = "pako inflate (from Nodeca project)",
  st = {
    inflateReset: E1,
    inflateReset2: k1,
    inflateResetKeep: B1,
    inflateInit: S1,
    inflateInit2: I1,
    inflate: A1,
    inflateEnd: v1,
    inflateGetHeader: x1,
    inflateSetDictionary: T1,
    inflateInfo: U1,
  };
function R1() {
  ((this.text = 0),
    (this.time = 0),
    (this.xflags = 0),
    (this.os = 0),
    (this.extra = null),
    (this.extra_len = 0),
    (this.name = ""),
    (this.comment = ""),
    (this.hcrc = 0),
    (this.done = !1));
}
var C1 = R1;
const _c = Object.prototype.toString,
  {
    Z_NO_FLUSH: D1,
    Z_FINISH: N1,
    Z_OK: Fr,
    Z_STREAM_END: fi,
    Z_NEED_DICT: hi,
    Z_STREAM_ERROR: O1,
    Z_DATA_ERROR: Uo,
    Z_MEM_ERROR: $1,
  } = Zr;
function Vr(e) {
  this.options = Dn.assign(
    { chunkSize: 1024 * 64, windowBits: 15, to: "" },
    e || {},
  );
  const r = this.options;
  (r.raw &&
    r.windowBits >= 0 &&
    r.windowBits < 16 &&
    ((r.windowBits = -r.windowBits),
    r.windowBits === 0 && (r.windowBits = -15)),
    r.windowBits >= 0 &&
      r.windowBits < 16 &&
      !(e && e.windowBits) &&
      (r.windowBits += 32),
    r.windowBits > 15 &&
      r.windowBits < 48 &&
      (r.windowBits & 15) === 0 &&
      (r.windowBits |= 15),
    (this.err = 0),
    (this.msg = ""),
    (this.ended = !1),
    (this.chunks = []),
    (this.strm = new tc()),
    (this.strm.avail_out = 0));
  let t = st.inflateInit2(this.strm, r.windowBits);
  if (t !== Fr) throw new Error(Mt[t]);
  if (
    ((this.header = new C1()),
    st.inflateGetHeader(this.strm, this.header),
    r.dictionary &&
      (typeof r.dictionary == "string"
        ? (r.dictionary = zr.string2buf(r.dictionary))
        : _c.call(r.dictionary) === "[object ArrayBuffer]" &&
          (r.dictionary = new Uint8Array(r.dictionary)),
      r.raw &&
        ((t = st.inflateSetDictionary(this.strm, r.dictionary)), t !== Fr)))
  )
    throw new Error(Mt[t]);
}
Vr.prototype.push = function (e, r) {
  const t = this.strm,
    n = this.options.chunkSize,
    i = this.options.dictionary;
  let s, l, h;
  if (this.ended) return !1;
  for (
    r === ~~r ? (l = r) : (l = r === !0 ? N1 : D1),
      _c.call(e) === "[object ArrayBuffer]"
        ? (t.input = new Uint8Array(e))
        : (t.input = e),
      t.next_in = 0,
      t.avail_in = t.input.length;
    ;
  ) {
    for (
      t.avail_out === 0 &&
        ((t.output = new Uint8Array(n)), (t.next_out = 0), (t.avail_out = n)),
        s = st.inflate(t, l),
        s === hi &&
          i &&
          ((s = st.inflateSetDictionary(t, i)),
          s === Fr ? (s = st.inflate(t, l)) : s === Uo && (s = hi));
      t.avail_in > 0 && s === fi && t.state.wrap > 0 && e[t.next_in] !== 0;
    )
      (st.inflateReset(t), (s = st.inflate(t, l)));
    switch (s) {
      case O1:
      case Uo:
      case hi:
      case $1:
        return (this.onEnd(s), (this.ended = !0), !1);
    }
    if (((h = t.avail_out), t.next_out && (t.avail_out === 0 || s === fi)))
      if (this.options.to === "string") {
        let g = zr.utf8border(t.output, t.next_out),
          u = t.next_out - g,
          d = zr.buf2string(t.output, g);
        ((t.next_out = u),
          (t.avail_out = n - u),
          u && t.output.set(t.output.subarray(g, g + u), 0),
          this.onData(d));
      } else
        this.onData(
          t.output.length === t.next_out
            ? t.output
            : t.output.subarray(0, t.next_out),
        );
    if (!(s === Fr && h === 0)) {
      if (s === fi)
        return (
          (s = st.inflateEnd(this.strm)),
          this.onEnd(s),
          (this.ended = !0),
          !0
        );
      if (t.avail_in === 0) break;
    }
  }
  return !0;
};
Vr.prototype.onData = function (e) {
  this.chunks.push(e);
};
Vr.prototype.onEnd = function (e) {
  (e === Fr &&
    (this.options.to === "string"
      ? (this.result = this.chunks.join(""))
      : (this.result = Dn.flattenChunks(this.chunks))),
    (this.chunks = []),
    (this.err = e),
    (this.msg = this.strm.msg));
};
function Gi(e, r) {
  const t = new Vr(r);
  if ((t.push(e), t.err)) throw t.msg || Mt[t.err];
  return t.result;
}
function L1(e, r) {
  return ((r = r || {}), (r.raw = !0), Gi(e, r));
}
var z1 = Vr,
  F1 = Gi,
  M1 = L1,
  P1 = Gi,
  Z1 = { Inflate: z1, inflate: F1, inflateRaw: M1, ungzip: P1 };
const { Deflate: H1, deflate: W1, deflateRaw: V1, gzip: Y1 } = qh,
  { Inflate: G1, inflate: j1, inflateRaw: K1, ungzip: X1 } = Z1;
var q1 = H1,
  J1 = W1,
  Q1 = V1,
  ed = Y1,
  td = G1,
  rd = j1,
  nd = K1,
  id = X1,
  ad = Zr,
  od = {
    Deflate: q1,
    deflate: J1,
    deflateRaw: Q1,
    gzip: ed,
    Inflate: td,
    inflate: rd,
    inflateRaw: nd,
    ungzip: id,
    constants: ad,
  };
async function sd(e, r) {
  let t;
  if (r) {
    const h = e ? "-threads" : "",
      g = r.split("/").slice(0, -1).join("/"),
      u = r.split("/").pop(),
      [d, ...E] = u.split(".");
    t = `${g}/${d}${h}.${E.join(".")}`;
  } else
    t = e
      ? (
          await $a(async () => {
            const { default: h } =
              await import("./assets/barretenberg-threads-CEUSJ7or.js");
            return { default: h };
          }, [])
        ).default
      : (
          await $a(async () => {
            const { default: h } =
              await import("./assets/barretenberg-Dfd87FCq.js");
            return { default: h };
          }, [])
        ).default;
  const i = await (await fetch(t)).arrayBuffer(),
    s = new Uint8Array(i);
  return s[0] === 31 && s[1] === 139 && s[2] === 8 ? od.ungzip(s).buffer : s;
}
async function cd(e = 32, r, t = Sn()("bb.js:fetch_mat")) {
  const n = sf(),
    i = n ? await ld(t) : 1,
    s = Math.min(e, i, 32);
  t(`Fetching bb wasm from ${r ?? "default location"}`);
  const l = await sd(n, r);
  t(`Compiling bb wasm of ${l.byteLength} bytes`);
  const h = await WebAssembly.compile(l);
  return (t("Compilation of bb wasm complete"), { module: h, threads: s });
}
async function ld(e) {
  if (typeof navigator < "u" && navigator.hardwareConcurrency)
    return navigator.hardwareConcurrency;
  try {
    return (await Promise.resolve().then(Ee.t.bind(Ee, 733, 23))).cpus().length;
  } catch (r) {
    return (
      e(
        `Could not detect environment to query number of threads. Falling back to one thread. Error: ${r.message ?? r}`,
      ),
      1
    );
  }
}
const ud = 16,
  Ro = 32;
function fd(e, r) {
  const t = e.slice(0, r * Ro);
  return { proof: e.slice(r * Ro), publicInputs: t };
}
function hd(e, r) {
  return Uint8Array.from([...e, ...r]);
}
function dd(e) {
  const t = [];
  for (let n = 0; n < e.length; n += 32) {
    const i = e.slice(n, n + 32);
    t.push(i);
  }
  return t.map(wd);
}
function _d(e) {
  const r = e.map(gd);
  return pd(r);
}
function pd(e) {
  const r = e.reduce((i, s) => i + s.length, 0),
    t = new Uint8Array(r);
  let n = 0;
  for (const i of e) (t.set(i, n), (n += i.length));
  return t;
}
function wd(e) {
  const r = [];
  return (
    e.forEach(function (t) {
      let n = t.toString(16);
      (n.length % 2 && (n = "0" + n), r.push(n));
    }),
    "0x" + r.join("")
  );
}
function gd(e) {
  const r = BigInt(e).toString(16).padStart(64, "0"),
    t = r.length / 2,
    n = new Uint8Array(t);
  let i = 0,
    s = 0;
  for (; i < t; )
    ((n[i] = parseInt(r.slice(s, s + 2), 16)), (i += 1), (s += 2));
  return n;
}
var Oe = Uint8Array,
  vr = Uint16Array,
  yd = Int32Array,
  pc = new Oe([
    0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5,
    5, 5, 5, 0, 0, 0, 0,
  ]),
  wc = new Oe([
    0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10,
    11, 11, 12, 12, 13, 13, 0, 0,
  ]),
  bd = new Oe([
    16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15,
  ]),
  gc = function (e, r) {
    for (var t = new vr(31), n = 0; n < 31; ++n) t[n] = r += 1 << e[n - 1];
    for (var i = new yd(t[30]), n = 1; n < 30; ++n)
      for (var s = t[n]; s < t[n + 1]; ++s) i[s] = ((s - t[n]) << 5) | n;
    return { b: t, r: i };
  },
  yc = gc(pc, 2),
  bc = yc.b,
  md = yc.r;
((bc[28] = 258), (md[258] = 28));
var Ed = gc(wc, 0),
  kd = Ed.b,
  mc = new vr(32768);
for (var _e = 0; _e < 32768; ++_e) {
  var mt = ((_e & 43690) >> 1) | ((_e & 21845) << 1);
  ((mt = ((mt & 52428) >> 2) | ((mt & 13107) << 2)),
    (mt = ((mt & 61680) >> 4) | ((mt & 3855) << 4)),
    (mc[_e] = (((mt & 65280) >> 8) | ((mt & 255) << 8)) >> 1));
}
var xr = function (e, r, t) {
    for (var n = e.length, i = 0, s = new vr(r); i < n; ++i)
      e[i] && ++s[e[i] - 1];
    var l = new vr(r);
    for (i = 1; i < r; ++i) l[i] = (l[i - 1] + s[i - 1]) << 1;
    var h;
    {
      h = new vr(1 << r);
      var g = 15 - r;
      for (i = 0; i < n; ++i)
        if (e[i])
          for (
            var u = (i << 4) | e[i],
              d = r - e[i],
              E = l[e[i] - 1]++ << d,
              b = E | ((1 << d) - 1);
            E <= b;
            ++E
          )
            h[mc[E] >> g] = u;
    }
    return h;
  },
  Yr = new Oe(288);
for (var _e = 0; _e < 144; ++_e) Yr[_e] = 8;
for (var _e = 144; _e < 256; ++_e) Yr[_e] = 9;
for (var _e = 256; _e < 280; ++_e) Yr[_e] = 7;
for (var _e = 280; _e < 288; ++_e) Yr[_e] = 8;
var Ec = new Oe(32);
for (var _e = 0; _e < 32; ++_e) Ec[_e] = 5;
var Bd = xr(Yr, 9),
  Sd = xr(Ec, 5),
  di = function (e) {
    for (var r = e[0], t = 1; t < e.length; ++t) e[t] > r && (r = e[t]);
    return r;
  },
  Ye = function (e, r, t) {
    var n = (r / 8) | 0;
    return ((e[n] | (e[n + 1] << 8)) >> (r & 7)) & t;
  },
  _i = function (e, r) {
    var t = (r / 8) | 0;
    return (e[t] | (e[t + 1] << 8) | (e[t + 2] << 16)) >> (r & 7);
  },
  Id = function (e) {
    return ((e + 7) / 8) | 0;
  },
  Ad = function (e, r, t) {
    return (
      (t == null || t > e.length) && (t = e.length),
      new Oe(e.subarray(r, t))
    );
  },
  vd = [
    "unexpected EOF",
    "invalid block type",
    "invalid length/literal",
    "invalid distance",
    "stream finished",
    "no stream handler",
    ,
    "no callback",
    "invalid UTF-8 data",
    "extra field too long",
    "date not in range 1980-2099",
    "filename too long",
    "stream finishing",
    "invalid zip data",
  ],
  Ne = function (e, r, t) {
    var n = new Error(r || vd[e]);
    if (
      ((n.code = e),
      Error.captureStackTrace && Error.captureStackTrace(n, Ne),
      !t)
    )
      throw n;
    return n;
  },
  ji = function (e, r, t, n) {
    var i = e.length,
      s = 0;
    if (!i || (r.f && !r.l)) return t || new Oe(0);
    var l = !t,
      h = l || r.i != 2,
      g = r.i;
    l && (t = new Oe(i * 3));
    var u = function (ze) {
        var ht = t.length;
        if (ze > ht) {
          var dt = new Oe(Math.max(ht * 2, ze));
          (dt.set(t), (t = dt));
        }
      },
      d = r.f || 0,
      E = r.p || 0,
      b = r.b || 0,
      y = r.l,
      I = r.d,
      x = r.m,
      T = r.n,
      R = i * 8;
    do {
      if (!y) {
        d = Ye(e, E, 1);
        var $ = Ye(e, E + 1, 3);
        if (((E += 3), $))
          if ($ == 1) ((y = Bd), (I = Sd), (x = 9), (T = 5));
          else if ($ == 2) {
            var V = Ye(e, E, 31) + 257,
              C = Ye(e, E + 10, 15) + 4,
              H = V + Ye(e, E + 5, 31) + 1;
            E += 14;
            for (var M = new Oe(H), N = new Oe(19), F = 0; F < C; ++F)
              N[bd[F]] = Ye(e, E + F * 3, 7);
            E += C * 3;
            for (
              var se = di(N), A = (1 << se) - 1, P = xr(N, se), F = 0;
              F < H;
            ) {
              var L = P[Ye(e, E, A)];
              E += L & 15;
              var D = L >> 4;
              if (D < 16) M[F++] = D;
              else {
                var O = 0,
                  Z = 0;
                for (
                  D == 16
                    ? ((Z = 3 + Ye(e, E, 3)), (E += 2), (O = M[F - 1]))
                    : D == 17
                      ? ((Z = 3 + Ye(e, E, 7)), (E += 3))
                      : D == 18 && ((Z = 11 + Ye(e, E, 127)), (E += 7));
                  Z--;
                )
                  M[F++] = O;
              }
            }
            var j = M.subarray(0, V),
              Y = M.subarray(V);
            ((x = di(j)), (T = di(Y)), (y = xr(j, x)), (I = xr(Y, T)));
          } else Ne(1);
        else {
          var D = Id(E) + 4,
            m = e[D - 4] | (e[D - 3] << 8),
            z = D + m;
          if (z > i) {
            g && Ne(0);
            break;
          }
          (h && u(b + m),
            t.set(e.subarray(D, z), b),
            (r.b = b += m),
            (r.p = E = z * 8),
            (r.f = d));
          continue;
        }
        if (E > R) {
          g && Ne(0);
          break;
        }
      }
      h && u(b + 131072);
      for (var K = (1 << x) - 1, ee = (1 << T) - 1, X = E; ; X = E) {
        var O = y[_i(e, E) & K],
          ie = O >> 4;
        if (((E += O & 15), E > R)) {
          g && Ne(0);
          break;
        }
        if ((O || Ne(2), ie < 256)) t[b++] = ie;
        else if (ie == 256) {
          ((X = E), (y = null));
          break;
        } else {
          var ae = ie - 254;
          if (ie > 264) {
            var F = ie - 257,
              le = pc[F];
            ((ae = Ye(e, E, (1 << le) - 1) + bc[F]), (E += le));
          }
          var tt = I[_i(e, E) & ee],
            rt = tt >> 4;
          (tt || Ne(3), (E += tt & 15));
          var Y = kd[rt];
          if (rt > 3) {
            var le = wc[rt];
            ((Y += _i(e, E) & ((1 << le) - 1)), (E += le));
          }
          if (E > R) {
            g && Ne(0);
            break;
          }
          h && u(b + 131072);
          var ut = b + ae;
          if (b < Y) {
            var Le = s - Y,
              ft = Math.min(Y, ut);
            for (Le + b < 0 && Ne(3); b < ft; ++b) t[b] = n[Le + b];
          }
          for (; b < ut; ++b) t[b] = t[b - Y];
        }
      }
      ((r.l = y),
        (r.p = X),
        (r.b = b),
        (r.f = d),
        y && ((d = 1), (r.m = x), (r.d = I), (r.n = T)));
    } while (!d);
    return b != t.length && l ? Ad(t, 0, b) : t.subarray(0, b);
  },
  xd = new Oe(0),
  Td = function (e) {
    (e[0] != 31 || e[1] != 139 || e[2] != 8) && Ne(6, "invalid gzip data");
    var r = e[3],
      t = 10;
    r & 4 && (t += (e[10] | (e[11] << 8)) + 2);
    for (var n = ((r >> 3) & 1) + ((r >> 4) & 1); n > 0; n -= !e[t++]);
    return t + (r & 2);
  },
  Ud = function (e) {
    var r = e.length;
    return (
      (e[r - 4] | (e[r - 3] << 8) | (e[r - 2] << 16) | (e[r - 1] << 24)) >>> 0
    );
  },
  Rd = function (e, r) {
    return (
      ((e[0] & 15) != 8 || e[0] >> 4 > 7 || ((e[0] << 8) | e[1]) % 31) &&
        Ne(6, "invalid zlib data"),
      ((e[1] >> 5) & 1) == 1 &&
        Ne(
          6,
          "invalid zlib data: " +
            (e[1] & 32 ? "need" : "unexpected") +
            " dictionary",
        ),
      ((e[1] >> 3) & 4) + 2
    );
  };
function Cd(e, r) {
  return ji(e, { i: 2 }, r, r);
}
function Dd(e, r) {
  var t = Td(e);
  return (
    t + 8 > e.length && Ne(6, "invalid gzip data"),
    ji(e.subarray(t, -8), { i: 2 }, new Oe(Ud(e)), r)
  );
}
function Nd(e, r) {
  return ji(e.subarray(Rd(e), -4), { i: 2 }, r, r);
}
function kc(e, r) {
  return e[0] == 31 && e[1] == 139 && e[2] == 8
    ? Dd(e, r)
    : (e[0] & 15) != 8 || e[0] >> 4 > 7 || ((e[0] << 8) | e[1]) % 31
      ? Cd(e, r)
      : Nd(e, r);
}
typeof TextEncoder < "u" && new TextEncoder();
var Od = typeof TextDecoder < "u" && new TextDecoder(),
  $d = 0;
try {
  (Od.decode(xd, { stream: !0 }), ($d = 1));
} catch {}
var Co = Ee(287).hp,
  Ci;
try {
  Ci = new TextDecoder();
} catch {}
var W,
  et,
  k = 0,
  de = {},
  ne,
  Bt,
  Ze = 0,
  qe = 0,
  Se,
  lt,
  Re = [],
  te,
  Do = { useRecords: !1, mapsAsObjects: !0 };
class Bc {}
const Sc = new Bc();
Sc.name = "MessagePack 0xC1";
var vt = !1,
  Ic = 2,
  Ld;
try {
  new Function("");
} catch {
  Ic = 1 / 0;
}
class Mr {
  constructor(r) {
    (r &&
      (r.useRecords === !1 &&
        r.mapsAsObjects === void 0 &&
        (r.mapsAsObjects = !0),
      r.sequential &&
        r.trusted !== !1 &&
        ((r.trusted = !0),
        !r.structures &&
          r.useRecords != !1 &&
          ((r.structures = []),
          r.maxSharedStructures || (r.maxSharedStructures = 0))),
      r.structures
        ? (r.structures.sharedLength = r.structures.length)
        : r.getStructures &&
          (((r.structures = []).uninitialized = !0),
          (r.structures.sharedLength = 0)),
      r.int64AsNumber && (r.int64AsType = "number")),
      Object.assign(this, r));
  }
  unpack(r, t) {
    if (W)
      return Rc(
        () => (
          Ni(),
          this ? this.unpack(r, t) : Mr.prototype.unpack.call(Do, r, t)
        ),
      );
    (!r.buffer &&
      r.constructor === ArrayBuffer &&
      (r = typeof Co < "u" ? Co.from(r) : new Uint8Array(r)),
      typeof t == "object"
        ? ((et = t.end || r.length), (k = t.start || 0))
        : ((k = 0), (et = t > -1 ? t : r.length)),
      (qe = 0),
      (Bt = null),
      (Se = null),
      (W = r));
    try {
      te =
        r.dataView ||
        (r.dataView = new DataView(r.buffer, r.byteOffset, r.byteLength));
    } catch (n) {
      throw (
        (W = null),
        r instanceof Uint8Array
          ? n
          : new Error(
              "Source must be a Uint8Array or Buffer but was a " +
                (r && typeof r == "object" ? r.constructor.name : typeof r),
            )
      );
    }
    if (this instanceof Mr) {
      if (((de = this), this.structures))
        return ((ne = this.structures), sn(t));
      (!ne || ne.length > 0) && (ne = []);
    } else ((de = Do), (!ne || ne.length > 0) && (ne = []));
    return sn(t);
  }
  unpackMultiple(r, t) {
    let n,
      i = 0;
    try {
      vt = !0;
      let s = r.length,
        l = this ? this.unpack(r, s) : On.unpack(r, s);
      if (t) {
        if (t(l, i, k) === !1) return;
        for (; k < s; ) if (((i = k), t(sn(), i, k) === !1)) return;
      } else {
        for (n = [l]; k < s; ) ((i = k), n.push(sn()));
        return n;
      }
    } catch (s) {
      throw ((s.lastPosition = i), (s.values = n), s);
    } finally {
      ((vt = !1), Ni());
    }
  }
  _mergeStructures(r, t) {
    ((r = r || []), Object.isFrozen(r) && (r = r.map((n) => n.slice(0))));
    for (let n = 0, i = r.length; n < i; n++) {
      let s = r[n];
      s && ((s.isShared = !0), n >= 32 && (s.highByte = (n - 32) >> 5));
    }
    r.sharedLength = r.length;
    for (let n in t || [])
      if (n >= 0) {
        let i = r[n],
          s = t[n];
        s &&
          (i && ((r.restoreStructures || (r.restoreStructures = []))[n] = i),
          (r[n] = s));
      }
    return (this.structures = r);
  }
  decode(r, t) {
    return this.unpack(r, t);
  }
}
function sn(e) {
  try {
    if (!de.trusted && !vt) {
      let t = ne.sharedLength || 0;
      t < ne.length && (ne.length = t);
    }
    let r;
    if (
      ((de.randomAccessStructure && W[k] < 64 && W[k] >= 32 && Ld) ||
        (r = me()),
      Se && ((k = Se.postBundlePosition), (Se = null)),
      vt && (ne.restoreStructures = null),
      k == et)
    )
      (ne && ne.restoreStructures && No(),
        (ne = null),
        (W = null),
        lt && (lt = null));
    else {
      if (k > et) throw new Error("Unexpected end of MessagePack data");
      if (!vt) {
        let t;
        try {
          t = JSON.stringify(r, (n, i) =>
            typeof i == "bigint" ? `${i}n` : i,
          ).slice(0, 100);
        } catch (n) {
          t = "(JSON view not available " + n + ")";
        }
        throw new Error("Data read, but end of buffer not reached " + t);
      }
    }
    return r;
  } catch (r) {
    throw (
      ne && ne.restoreStructures && No(),
      Ni(),
      (r instanceof RangeError ||
        r.message.startsWith("Unexpected end of buffer") ||
        k > et) &&
        (r.incomplete = !0),
      r
    );
  }
}
function No() {
  for (let e in ne.restoreStructures) ne[e] = ne.restoreStructures[e];
  ne.restoreStructures = null;
}
function me() {
  let e = W[k++];
  if (e < 160)
    if (e < 128) {
      if (e < 64) return e;
      {
        let r = ne[e & 63] || (de.getStructures && Ac()[e & 63]);
        return r ? (r.read || (r.read = Ki(r, e & 63)), r.read()) : e;
      }
    } else if (e < 144)
      if (((e -= 128), de.mapsAsObjects)) {
        let r = {};
        for (let t = 0; t < e; t++) {
          let n = xc();
          (n === "__proto__" && (n = "__proto_"), (r[n] = me()));
        }
        return r;
      } else {
        let r = new Map();
        for (let t = 0; t < e; t++) r.set(me(), me());
        return r;
      }
    else {
      e -= 144;
      let r = new Array(e);
      for (let t = 0; t < e; t++) r[t] = me();
      return de.freezeData ? Object.freeze(r) : r;
    }
  else if (e < 192) {
    let r = e - 160;
    if (qe >= k) return Bt.slice(k - Ze, (k += r) - Ze);
    if (qe == 0 && et < 140) {
      let t = r < 16 ? Xi(r) : vc(r);
      if (t != null) return t;
    }
    return Di(r);
  } else {
    let r;
    switch (e) {
      case 192:
        return null;
      case 193:
        return Se
          ? ((r = me()),
            r > 0
              ? Se[1].slice(Se.position1, (Se.position1 += r))
              : Se[0].slice(Se.position0, (Se.position0 -= r)))
          : Sc;
      case 194:
        return !1;
      case 195:
        return !0;
      case 196:
        if (((r = W[k++]), r === void 0))
          throw new Error("Unexpected end of buffer");
        return pi(r);
      case 197:
        return ((r = te.getUint16(k)), (k += 2), pi(r));
      case 198:
        return ((r = te.getUint32(k)), (k += 4), pi(r));
      case 199:
        return Ut(W[k++]);
      case 200:
        return ((r = te.getUint16(k)), (k += 2), Ut(r));
      case 201:
        return ((r = te.getUint32(k)), (k += 4), Ut(r));
      case 202:
        if (((r = te.getFloat32(k)), de.useFloat32 > 2)) {
          let t = qi[((W[k] & 127) << 1) | (W[k + 1] >> 7)];
          return ((k += 4), ((t * r + (r > 0 ? 0.5 : -0.5)) >> 0) / t);
        }
        return ((k += 4), r);
      case 203:
        return ((r = te.getFloat64(k)), (k += 8), r);
      case 204:
        return W[k++];
      case 205:
        return ((r = te.getUint16(k)), (k += 2), r);
      case 206:
        return ((r = te.getUint32(k)), (k += 4), r);
      case 207:
        return (
          de.int64AsType === "number"
            ? ((r = te.getUint32(k) * 4294967296), (r += te.getUint32(k + 4)))
            : de.int64AsType === "string"
              ? (r = te.getBigUint64(k).toString())
              : de.int64AsType === "auto"
                ? ((r = te.getBigUint64(k)),
                  r <= BigInt(2) << BigInt(52) && (r = Number(r)))
                : (r = te.getBigUint64(k)),
          (k += 8),
          r
        );
      case 208:
        return te.getInt8(k++);
      case 209:
        return ((r = te.getInt16(k)), (k += 2), r);
      case 210:
        return ((r = te.getInt32(k)), (k += 4), r);
      case 211:
        return (
          de.int64AsType === "number"
            ? ((r = te.getInt32(k) * 4294967296), (r += te.getUint32(k + 4)))
            : de.int64AsType === "string"
              ? (r = te.getBigInt64(k).toString())
              : de.int64AsType === "auto"
                ? ((r = te.getBigInt64(k)),
                  r >= BigInt(-2) << BigInt(52) &&
                    r <= BigInt(2) << BigInt(52) &&
                    (r = Number(r)))
                : (r = te.getBigInt64(k)),
          (k += 8),
          r
        );
      case 212:
        if (((r = W[k++]), r == 114)) return Mo(W[k++] & 63);
        {
          let t = Re[r];
          if (t)
            return t.read
              ? (k++, t.read(me()))
              : t.noBuffer
                ? (k++, t())
                : t(W.subarray(k, ++k));
          throw new Error("Unknown extension " + r);
        }
      case 213:
        return ((r = W[k]), r == 114 ? (k++, Mo(W[k++] & 63, W[k++])) : Ut(2));
      case 214:
        return Ut(4);
      case 215:
        return Ut(8);
      case 216:
        return Ut(16);
      case 217:
        return (
          (r = W[k++]),
          qe >= k ? Bt.slice(k - Ze, (k += r) - Ze) : Fd(r)
        );
      case 218:
        return (
          (r = te.getUint16(k)),
          (k += 2),
          qe >= k ? Bt.slice(k - Ze, (k += r) - Ze) : Md(r)
        );
      case 219:
        return (
          (r = te.getUint32(k)),
          (k += 4),
          qe >= k ? Bt.slice(k - Ze, (k += r) - Ze) : Pd(r)
        );
      case 220:
        return ((r = te.getUint16(k)), (k += 2), $o(r));
      case 221:
        return ((r = te.getUint32(k)), (k += 4), $o(r));
      case 222:
        return ((r = te.getUint16(k)), (k += 2), Lo(r));
      case 223:
        return ((r = te.getUint32(k)), (k += 4), Lo(r));
      default:
        if (e >= 224) return e - 256;
        if (e === void 0) {
          let t = new Error("Unexpected end of MessagePack data");
          throw ((t.incomplete = !0), t);
        }
        throw new Error("Unknown MessagePack token " + e);
    }
  }
}
const zd = /^[a-zA-Z_$][a-zA-Z\d_$]*$/;
function Ki(e, r) {
  function t() {
    if (t.count++ > Ic) {
      let i = (e.read = new Function(
        "r",
        "return function(){return " +
          (de.freezeData ? "Object.freeze" : "") +
          "({" +
          e
            .map((s) =>
              s === "__proto__"
                ? "__proto_:r()"
                : zd.test(s)
                  ? s + ":r()"
                  : "[" + JSON.stringify(s) + "]:r()",
            )
            .join(",") +
          "})}",
      )(me));
      return (e.highByte === 0 && (e.read = Oo(r, e.read)), i());
    }
    let n = {};
    for (let i = 0, s = e.length; i < s; i++) {
      let l = e[i];
      (l === "__proto__" && (l = "__proto_"), (n[l] = me()));
    }
    return de.freezeData ? Object.freeze(n) : n;
  }
  return ((t.count = 0), e.highByte === 0 ? Oo(r, t) : t);
}
const Oo = (e, r) =>
  function () {
    let t = W[k++];
    if (t === 0) return r();
    let n = e < 32 ? -(e + (t << 5)) : e + (t << 5),
      i = ne[n] || Ac()[n];
    if (!i) throw new Error("Record id is not defined for " + n);
    return (i.read || (i.read = Ki(i, e)), i.read());
  };
function Ac() {
  let e = Rc(() => ((W = null), de.getStructures()));
  return (ne = de._mergeStructures(e, ne));
}
var Di = Gr,
  Fd = Gr,
  Md = Gr,
  Pd = Gr;
function Gr(e) {
  let r;
  if (e < 16 && (r = Xi(e))) return r;
  if (e > 64 && Ci) return Ci.decode(W.subarray(k, (k += e)));
  const t = k + e,
    n = [];
  for (r = ""; k < t; ) {
    const i = W[k++];
    if ((i & 128) === 0) n.push(i);
    else if ((i & 224) === 192) {
      const s = W[k++] & 63;
      n.push(((i & 31) << 6) | s);
    } else if ((i & 240) === 224) {
      const s = W[k++] & 63,
        l = W[k++] & 63;
      n.push(((i & 31) << 12) | (s << 6) | l);
    } else if ((i & 248) === 240) {
      const s = W[k++] & 63,
        l = W[k++] & 63,
        h = W[k++] & 63;
      let g = ((i & 7) << 18) | (s << 12) | (l << 6) | h;
      (g > 65535 &&
        ((g -= 65536),
        n.push(((g >>> 10) & 1023) | 55296),
        (g = 56320 | (g & 1023))),
        n.push(g));
    } else n.push(i);
    n.length >= 4096 && ((r += ke.apply(String, n)), (n.length = 0));
  }
  return (n.length > 0 && (r += ke.apply(String, n)), r);
}
function $o(e) {
  let r = new Array(e);
  for (let t = 0; t < e; t++) r[t] = me();
  return de.freezeData ? Object.freeze(r) : r;
}
function Lo(e) {
  if (de.mapsAsObjects) {
    let r = {};
    for (let t = 0; t < e; t++) {
      let n = xc();
      (n === "__proto__" && (n = "__proto_"), (r[n] = me()));
    }
    return r;
  } else {
    let r = new Map();
    for (let t = 0; t < e; t++) r.set(me(), me());
    return r;
  }
}
var ke = String.fromCharCode;
function vc(e) {
  let r = k,
    t = new Array(e);
  for (let n = 0; n < e; n++) {
    const i = W[k++];
    if ((i & 128) > 0) {
      k = r;
      return;
    }
    t[n] = i;
  }
  return ke.apply(String, t);
}
function Xi(e) {
  if (e < 4)
    if (e < 2) {
      if (e === 0) return "";
      {
        let r = W[k++];
        if ((r & 128) > 1) {
          k -= 1;
          return;
        }
        return ke(r);
      }
    } else {
      let r = W[k++],
        t = W[k++];
      if ((r & 128) > 0 || (t & 128) > 0) {
        k -= 2;
        return;
      }
      if (e < 3) return ke(r, t);
      let n = W[k++];
      if ((n & 128) > 0) {
        k -= 3;
        return;
      }
      return ke(r, t, n);
    }
  else {
    let r = W[k++],
      t = W[k++],
      n = W[k++],
      i = W[k++];
    if ((r & 128) > 0 || (t & 128) > 0 || (n & 128) > 0 || (i & 128) > 0) {
      k -= 4;
      return;
    }
    if (e < 6) {
      if (e === 4) return ke(r, t, n, i);
      {
        let s = W[k++];
        if ((s & 128) > 0) {
          k -= 5;
          return;
        }
        return ke(r, t, n, i, s);
      }
    } else if (e < 8) {
      let s = W[k++],
        l = W[k++];
      if ((s & 128) > 0 || (l & 128) > 0) {
        k -= 6;
        return;
      }
      if (e < 7) return ke(r, t, n, i, s, l);
      let h = W[k++];
      if ((h & 128) > 0) {
        k -= 7;
        return;
      }
      return ke(r, t, n, i, s, l, h);
    } else {
      let s = W[k++],
        l = W[k++],
        h = W[k++],
        g = W[k++];
      if ((s & 128) > 0 || (l & 128) > 0 || (h & 128) > 0 || (g & 128) > 0) {
        k -= 8;
        return;
      }
      if (e < 10) {
        if (e === 8) return ke(r, t, n, i, s, l, h, g);
        {
          let u = W[k++];
          if ((u & 128) > 0) {
            k -= 9;
            return;
          }
          return ke(r, t, n, i, s, l, h, g, u);
        }
      } else if (e < 12) {
        let u = W[k++],
          d = W[k++];
        if ((u & 128) > 0 || (d & 128) > 0) {
          k -= 10;
          return;
        }
        if (e < 11) return ke(r, t, n, i, s, l, h, g, u, d);
        let E = W[k++];
        if ((E & 128) > 0) {
          k -= 11;
          return;
        }
        return ke(r, t, n, i, s, l, h, g, u, d, E);
      } else {
        let u = W[k++],
          d = W[k++],
          E = W[k++],
          b = W[k++];
        if ((u & 128) > 0 || (d & 128) > 0 || (E & 128) > 0 || (b & 128) > 0) {
          k -= 12;
          return;
        }
        if (e < 14) {
          if (e === 12) return ke(r, t, n, i, s, l, h, g, u, d, E, b);
          {
            let y = W[k++];
            if ((y & 128) > 0) {
              k -= 13;
              return;
            }
            return ke(r, t, n, i, s, l, h, g, u, d, E, b, y);
          }
        } else {
          let y = W[k++],
            I = W[k++];
          if ((y & 128) > 0 || (I & 128) > 0) {
            k -= 14;
            return;
          }
          if (e < 15) return ke(r, t, n, i, s, l, h, g, u, d, E, b, y, I);
          let x = W[k++];
          if ((x & 128) > 0) {
            k -= 15;
            return;
          }
          return ke(r, t, n, i, s, l, h, g, u, d, E, b, y, I, x);
        }
      }
    }
  }
}
function zo() {
  let e = W[k++],
    r;
  if (e < 192) r = e - 160;
  else
    switch (e) {
      case 217:
        r = W[k++];
        break;
      case 218:
        ((r = te.getUint16(k)), (k += 2));
        break;
      case 219:
        ((r = te.getUint32(k)), (k += 4));
        break;
      default:
        throw new Error("Expected string");
    }
  return Gr(r);
}
function pi(e) {
  return de.copyBuffers
    ? Uint8Array.prototype.slice.call(W, k, (k += e))
    : W.subarray(k, (k += e));
}
function Ut(e) {
  let r = W[k++];
  if (Re[r]) {
    let t;
    return Re[r](W.subarray(k, (t = k += e)), (n) => {
      k = n;
      try {
        return me();
      } finally {
        k = t;
      }
    });
  } else throw new Error("Unknown extension type " + r);
}
var Fo = new Array(4096);
function xc() {
  let e = W[k++];
  if (e >= 160 && e < 192) {
    if (((e = e - 160), qe >= k)) return Bt.slice(k - Ze, (k += e) - Ze);
    if (!(qe == 0 && et < 180)) return Di(e);
  } else return (k--, Tc(me()));
  let r = ((e << 5) ^ (e > 1 ? te.getUint16(k) : e > 0 ? W[k] : 0)) & 4095,
    t = Fo[r],
    n = k,
    i = k + e - 3,
    s,
    l = 0;
  if (t && t.bytes == e) {
    for (; n < i; ) {
      if (((s = te.getUint32(n)), s != t[l++])) {
        n = 1879048192;
        break;
      }
      n += 4;
    }
    for (i += 3; n < i; )
      if (((s = W[n++]), s != t[l++])) {
        n = 1879048192;
        break;
      }
    if (n === i) return ((k = n), t.string);
    ((i -= 3), (n = k));
  }
  for (t = [], Fo[r] = t, t.bytes = e; n < i; )
    ((s = te.getUint32(n)), t.push(s), (n += 4));
  for (i += 3; n < i; ) ((s = W[n++]), t.push(s));
  let h = e < 16 ? Xi(e) : vc(e);
  return h != null ? (t.string = h) : (t.string = Di(e));
}
function Tc(e) {
  if (typeof e == "string") return e;
  if (typeof e == "number" || typeof e == "boolean" || typeof e == "bigint")
    return e.toString();
  if (e == null) return e + "";
  throw new Error("Invalid property type for record", typeof e);
}
const Mo = (e, r) => {
  let t = me().map(Tc),
    n = e;
  r !== void 0 &&
    ((e = e < 32 ? -((r << 5) + e) : (r << 5) + e), (t.highByte = r));
  let i = ne[e];
  return (
    i &&
      (i.isShared || vt) &&
      ((ne.restoreStructures || (ne.restoreStructures = []))[e] = i),
    (ne[e] = t),
    (t.read = Ki(t, n)),
    t.read()
  );
};
Re[0] = () => {};
Re[0].noBuffer = !0;
Re[66] = (e) => {
  let r = e.length,
    t = BigInt(e[0] & 128 ? e[0] - 256 : e[0]);
  for (let n = 1; n < r; n++) ((t <<= BigInt(8)), (t += BigInt(e[n])));
  return t;
};
let Zd = { Error, TypeError, ReferenceError };
Re[101] = () => {
  let e = me();
  return (Zd[e[0]] || Error)(e[1], { cause: e[2] });
};
Re[105] = (e) => {
  if (de.structuredClone === !1)
    throw new Error("Structured clone extension is disabled");
  let r = te.getUint32(k - 4);
  lt || (lt = new Map());
  let t = W[k],
    n;
  (t >= 144 && t < 160) || t == 220 || t == 221 ? (n = []) : (n = {});
  let i = { target: n };
  lt.set(r, i);
  let s = me();
  return i.used ? Object.assign(n, s) : ((i.target = s), s);
};
Re[112] = (e) => {
  if (de.structuredClone === !1)
    throw new Error("Structured clone extension is disabled");
  let r = te.getUint32(k - 4),
    t = lt.get(r);
  return ((t.used = !0), t.target);
};
Re[115] = () => new Set(me());
const Uc = [
  "Int8",
  "Uint8",
  "Uint8Clamped",
  "Int16",
  "Uint16",
  "Int32",
  "Uint32",
  "Float32",
  "Float64",
  "BigInt64",
  "BigUint64",
].map((e) => e + "Array");
let Hd = typeof globalThis == "object" ? globalThis : window;
Re[116] = (e) => {
  let r = e[0],
    t = Uc[r];
  if (!t) {
    if (r === 16) {
      let n = new ArrayBuffer(e.length - 1);
      return (new Uint8Array(n).set(e.subarray(1)), n);
    }
    throw new Error("Could not find typed array for code " + r);
  }
  return new Hd[t](Uint8Array.prototype.slice.call(e, 1).buffer);
};
Re[120] = () => {
  let e = me();
  return new RegExp(e[0], e[1]);
};
const Wd = [];
Re[98] = (e) => {
  let r = (e[0] << 24) + (e[1] << 16) + (e[2] << 8) + e[3],
    t = k;
  return (
    (k += r - e.length),
    (Se = Wd),
    (Se = [zo(), zo()]),
    (Se.position0 = 0),
    (Se.position1 = 0),
    (Se.postBundlePosition = k),
    (k = t),
    me()
  );
};
Re[255] = (e) =>
  e.length == 4
    ? new Date((e[0] * 16777216 + (e[1] << 16) + (e[2] << 8) + e[3]) * 1e3)
    : e.length == 8
      ? new Date(
          ((e[0] << 22) + (e[1] << 14) + (e[2] << 6) + (e[3] >> 2)) / 1e6 +
            ((e[3] & 3) * 4294967296 +
              e[4] * 16777216 +
              (e[5] << 16) +
              (e[6] << 8) +
              e[7]) *
              1e3,
        )
      : e.length == 12
        ? new Date(
            ((e[0] << 24) + (e[1] << 16) + (e[2] << 8) + e[3]) / 1e6 +
              ((e[4] & 128 ? -281474976710656 : 0) +
                e[6] * 1099511627776 +
                e[7] * 4294967296 +
                e[8] * 16777216 +
                (e[9] << 16) +
                (e[10] << 8) +
                e[11]) *
                1e3,
          )
        : new Date("invalid");
function Rc(e) {
  let r = et,
    t = k,
    n = Ze,
    i = qe,
    s = Bt,
    l = lt,
    h = Se,
    g = new Uint8Array(W.slice(0, et)),
    u = ne,
    d = ne.slice(0, ne.length),
    E = de,
    b = vt,
    y = e();
  return (
    (et = r),
    (k = t),
    (Ze = n),
    (qe = i),
    (Bt = s),
    (lt = l),
    (Se = h),
    (W = g),
    (vt = b),
    (ne = u),
    ne.splice(0, ne.length, ...d),
    (de = E),
    (te = new DataView(W.buffer, W.byteOffset, W.byteLength)),
    y
  );
}
function Ni() {
  ((W = null), (lt = null), (ne = null));
}
const qi = new Array(147);
for (let e = 0; e < 256; e++) qi[e] = +("1e" + Math.floor(45.15 - e * 0.30103));
var On = new Mr({ useRecords: !1 });
On.unpack;
On.unpackMultiple;
On.unpack;
let Vd = new Float32Array(1);
new Uint8Array(Vd.buffer, 0, 4);
var $n = Ee(287).hp;
let wn;
try {
  wn = new TextEncoder();
} catch {}
let Oi, Cc;
const Ln = typeof $n < "u",
  cn = Ln
    ? function (e) {
        return $n.allocUnsafeSlow(e);
      }
    : Uint8Array,
  Dc = Ln ? $n : Uint8Array,
  Po = Ln ? 4294967296 : 2144337920;
let v,
  wr,
  fe,
  S = 0,
  ve,
  ge = null,
  Yd;
const Gd = 21760,
  jd = /[\u0080-\uFFFF]/,
  er = Symbol("record-id");
class Kd extends Mr {
  constructor(r) {
    (super(r), (this.offset = 0));
    let t,
      n,
      i,
      s,
      l = Dc.prototype.utf8Write
        ? function (A, P) {
            return v.utf8Write(A, P, v.byteLength - P);
          }
        : wn && wn.encodeInto
          ? function (A, P) {
              return wn.encodeInto(A, v.subarray(P)).written;
            }
          : !1,
      h = this;
    r || (r = {});
    let g = r && r.sequential,
      u = r.structures || r.saveStructures,
      d = r.maxSharedStructures;
    if ((d == null && (d = u ? 32 : 0), d > 8160))
      throw new Error("Maximum maxSharedStructure is 8160");
    r.structuredClone && r.moreTypes == null && (this.moreTypes = !0);
    let E = r.maxOwnStructures;
    (E == null && (E = u ? 32 : 64),
      !this.structures && r.useRecords != !1 && (this.structures = []));
    let b = d > 32 || E + d > 64,
      y = d + 64,
      I = d + E + 64;
    if (I > 8256)
      throw new Error("Maximum maxSharedStructure + maxOwnStructure is 8192");
    let x = [],
      T = 0,
      R = 0;
    this.pack = this.encode = function (A, P) {
      if (
        (v ||
          ((v = new cn(8192)),
          (fe = v.dataView || (v.dataView = new DataView(v.buffer, 0, 8192))),
          (S = 0)),
        (ve = v.length - 10),
        ve - S < 2048
          ? ((v = new cn(v.length)),
            (fe =
              v.dataView || (v.dataView = new DataView(v.buffer, 0, v.length))),
            (ve = v.length - 10),
            (S = 0))
          : (S = (S + 7) & 2147483640),
        (t = S),
        P & t0 && (S += P & 255),
        (s = h.structuredClone ? new Map() : null),
        h.bundleStrings && typeof A != "string"
          ? ((ge = []), (ge.size = 1 / 0))
          : (ge = null),
        (i = h.structures),
        i)
      ) {
        i.uninitialized && (i = h._mergeStructures(h.getStructures()));
        let O = i.sharedLength || 0;
        if (O > d)
          throw new Error(
            "Shared structures is larger than maximum shared structures, try increasing maxSharedStructures to " +
              i.sharedLength,
          );
        if (!i.transitions) {
          i.transitions = Object.create(null);
          for (let Z = 0; Z < O; Z++) {
            let j = i[Z];
            if (!j) continue;
            let Y,
              K = i.transitions;
            for (let ee = 0, X = j.length; ee < X; ee++) {
              let ie = j[ee];
              ((Y = K[ie]), Y || (Y = K[ie] = Object.create(null)), (K = Y));
            }
            K[er] = Z + 64;
          }
          this.lastNamedStructuresLength = O;
        }
        g || (i.nextId = O + 64);
      }
      n && (n = !1);
      let L;
      try {
        h.randomAccessStructure &&
        A &&
        A.constructor &&
        A.constructor === Object
          ? se(A)
          : m(A);
        let O = ge;
        if ((ge && Wo(t, m, 0), s && s.idsToInsert)) {
          let Z = s.idsToInsert.sort((ee, X) =>
              ee.offset > X.offset ? 1 : -1,
            ),
            j = Z.length,
            Y = -1;
          for (; O && j > 0; ) {
            let ee = Z[--j].offset + t;
            (ee < O.stringsPosition + t && Y === -1 && (Y = 0),
              ee > O.position + t
                ? Y >= 0 && (Y += 6)
                : (Y >= 0 &&
                    (fe.setUint32(
                      O.position + t,
                      fe.getUint32(O.position + t) + Y,
                    ),
                    (Y = -1)),
                  (O = O.previous),
                  j++));
          }
          (Y >= 0 &&
            O &&
            fe.setUint32(O.position + t, fe.getUint32(O.position + t) + Y),
            (S += Z.length * 6),
            S > ve && M(S),
            (h.offset = S));
          let K = qd(v.subarray(t, S), Z);
          return ((s = null), K);
        }
        return (
          (h.offset = S),
          P & Qd ? ((v.start = t), (v.end = S), v) : v.subarray(t, S)
        );
      } catch (O) {
        throw ((L = O), O);
      } finally {
        if (i && ($(), n && h.saveStructures)) {
          let O = i.sharedLength || 0,
            Z = v.subarray(t, S),
            j = Jd(i, h);
          if (!L)
            return h.saveStructures(j, j.isCompatible) === !1
              ? h.pack(A, P)
              : ((h.lastNamedStructuresLength = O),
                v.length > 1073741824 && (v = null),
                Z);
        }
        (v.length > 1073741824 && (v = null), P & e0 && (S = t));
      }
    };
    const $ = () => {
        R < 10 && R++;
        let A = i.sharedLength || 0;
        if ((i.length > A && !g && (i.length = A), T > 1e4))
          ((i.transitions = null), (R = 0), (T = 0), x.length > 0 && (x = []));
        else if (x.length > 0 && !g) {
          for (let P = 0, L = x.length; P < L; P++) x[P][er] = 0;
          x = [];
        }
      },
      D = (A) => {
        var P = A.length;
        P < 16
          ? (v[S++] = 144 | P)
          : P < 65536
            ? ((v[S++] = 220), (v[S++] = P >> 8), (v[S++] = P & 255))
            : ((v[S++] = 221), fe.setUint32(S, P), (S += 4));
        for (let L = 0; L < P; L++) m(A[L]);
      },
      m = (A) => {
        S > ve && (v = M(S));
        var P = typeof A,
          L;
        if (P === "string") {
          let O = A.length;
          if (ge && O >= 4 && O < 4096) {
            if ((ge.size += O) > Gd) {
              let K,
                ee = (ge[0] ? ge[0].length * 3 + ge[1].length : 0) + 10;
              S + ee > ve && (v = M(S + ee));
              let X;
              (ge.position
                ? ((X = ge),
                  (v[S] = 200),
                  (S += 3),
                  (v[S++] = 98),
                  (K = S - t),
                  (S += 4),
                  Wo(t, m, 0),
                  fe.setUint16(K + t - 3, S - t - K))
                : ((v[S++] = 214), (v[S++] = 98), (K = S - t), (S += 4)),
                (ge = ["", ""]),
                (ge.previous = X),
                (ge.size = 0),
                (ge.position = K));
            }
            let Y = jd.test(A);
            ((ge[Y ? 0 : 1] += A), (v[S++] = 193), m(Y ? -O : O));
            return;
          }
          let Z;
          O < 32 ? (Z = 1) : O < 256 ? (Z = 2) : O < 65536 ? (Z = 3) : (Z = 5);
          let j = O * 3;
          if ((S + j > ve && (v = M(S + j)), O < 64 || !l)) {
            let Y,
              K,
              ee,
              X = S + Z;
            for (Y = 0; Y < O; Y++)
              ((K = A.charCodeAt(Y)),
                K < 128
                  ? (v[X++] = K)
                  : K < 2048
                    ? ((v[X++] = (K >> 6) | 192), (v[X++] = (K & 63) | 128))
                    : (K & 64512) === 55296 &&
                        ((ee = A.charCodeAt(Y + 1)) & 64512) === 56320
                      ? ((K = 65536 + ((K & 1023) << 10) + (ee & 1023)),
                        Y++,
                        (v[X++] = (K >> 18) | 240),
                        (v[X++] = ((K >> 12) & 63) | 128),
                        (v[X++] = ((K >> 6) & 63) | 128),
                        (v[X++] = (K & 63) | 128))
                      : ((v[X++] = (K >> 12) | 224),
                        (v[X++] = ((K >> 6) & 63) | 128),
                        (v[X++] = (K & 63) | 128)));
            L = X - S - Z;
          } else L = l(A, S + Z);
          (L < 32
            ? (v[S++] = 160 | L)
            : L < 256
              ? (Z < 2 && v.copyWithin(S + 2, S + 1, S + 1 + L),
                (v[S++] = 217),
                (v[S++] = L))
              : L < 65536
                ? (Z < 3 && v.copyWithin(S + 3, S + 2, S + 2 + L),
                  (v[S++] = 218),
                  (v[S++] = L >> 8),
                  (v[S++] = L & 255))
                : (Z < 5 && v.copyWithin(S + 5, S + 3, S + 3 + L),
                  (v[S++] = 219),
                  fe.setUint32(S, L),
                  (S += 4)),
            (S += L));
        } else if (P === "number")
          if (A >>> 0 === A)
            A < 32 ||
            (A < 128 && this.useRecords === !1) ||
            (A < 64 && !this.randomAccessStructure)
              ? (v[S++] = A)
              : A < 256
                ? ((v[S++] = 204), (v[S++] = A))
                : A < 65536
                  ? ((v[S++] = 205), (v[S++] = A >> 8), (v[S++] = A & 255))
                  : ((v[S++] = 206), fe.setUint32(S, A), (S += 4));
          else if (A >> 0 === A)
            A >= -32
              ? (v[S++] = 256 + A)
              : A >= -128
                ? ((v[S++] = 208), (v[S++] = A + 256))
                : A >= -32768
                  ? ((v[S++] = 209), fe.setInt16(S, A), (S += 2))
                  : ((v[S++] = 210), fe.setInt32(S, A), (S += 4));
          else {
            let O;
            if (
              (O = this.useFloat32) > 0 &&
              A < 4294967296 &&
              A >= -2147483648
            ) {
              ((v[S++] = 202), fe.setFloat32(S, A));
              let Z;
              if (
                O < 4 ||
                (Z = A * qi[((v[S] & 127) << 1) | (v[S + 1] >> 7)]) >> 0 === Z
              ) {
                S += 4;
                return;
              } else S--;
            }
            ((v[S++] = 203), fe.setFloat64(S, A), (S += 8));
          }
        else if (P === "object" || P === "function")
          if (!A) v[S++] = 192;
          else {
            if (s) {
              let Z = s.get(A);
              if (Z) {
                if (!Z.id) {
                  let j = s.idsToInsert || (s.idsToInsert = []);
                  Z.id = j.push(Z);
                }
                ((v[S++] = 214),
                  (v[S++] = 112),
                  fe.setUint32(S, Z.id),
                  (S += 4));
                return;
              } else s.set(A, { offset: S - t });
            }
            let O = A.constructor;
            if (O === Object) H(A);
            else if (O === Array) D(A);
            else if (O === Map)
              if (this.mapAsEmptyObject) v[S++] = 128;
              else {
                ((L = A.size),
                  L < 16
                    ? (v[S++] = 128 | L)
                    : L < 65536
                      ? ((v[S++] = 222), (v[S++] = L >> 8), (v[S++] = L & 255))
                      : ((v[S++] = 223), fe.setUint32(S, L), (S += 4)));
                for (let [Z, j] of A) (m(Z), m(j));
              }
            else {
              for (let Z = 0, j = Oi.length; Z < j; Z++) {
                let Y = Cc[Z];
                if (A instanceof Y) {
                  let K = Oi[Z];
                  if (K.write) {
                    K.type && ((v[S++] = 212), (v[S++] = K.type), (v[S++] = 0));
                    let le = K.write.call(this, A);
                    le === A ? (Array.isArray(A) ? D(A) : H(A)) : m(le);
                    return;
                  }
                  let ee = v,
                    X = fe,
                    ie = S;
                  v = null;
                  let ae;
                  try {
                    ae = K.pack.call(
                      this,
                      A,
                      (le) => (
                        (v = ee),
                        (ee = null),
                        (S += le),
                        S > ve && M(S),
                        { target: v, targetView: fe, position: S - le }
                      ),
                      m,
                    );
                  } finally {
                    ee && ((v = ee), (fe = X), (S = ie), (ve = v.length - 10));
                  }
                  ae &&
                    (ae.length + S > ve && M(ae.length + S),
                    (S = Xd(ae, v, S, K.type)));
                  return;
                }
              }
              if (Array.isArray(A)) D(A);
              else {
                if (A.toJSON) {
                  const Z = A.toJSON();
                  if (Z !== A) return m(Z);
                }
                if (P === "function")
                  return m(this.writeFunction && this.writeFunction(A));
                H(A);
              }
            }
          }
        else if (P === "boolean") v[S++] = A ? 195 : 194;
        else if (P === "bigint") {
          if (A < BigInt(1) << BigInt(63) && A >= -(BigInt(1) << BigInt(63)))
            ((v[S++] = 211), fe.setBigInt64(S, A));
          else if (A < BigInt(1) << BigInt(64) && A > 0)
            ((v[S++] = 207), fe.setBigUint64(S, A));
          else if (this.largeBigIntToFloat)
            ((v[S++] = 203), fe.setFloat64(S, Number(A)));
          else {
            if (this.largeBigIntToString) return m(A.toString());
            if (
              this.useBigIntExtension &&
              A < BigInt(2) ** BigInt(1023) &&
              A > -(BigInt(2) ** BigInt(1023))
            ) {
              ((v[S++] = 199), S++, (v[S++] = 66));
              let O = [],
                Z;
              do {
                let j = A & BigInt(255);
                ((Z =
                  (j & BigInt(128)) ===
                  (A < BigInt(0) ? BigInt(128) : BigInt(0))),
                  O.push(j),
                  (A >>= BigInt(8)));
              } while (!((A === BigInt(0) || A === BigInt(-1)) && Z));
              v[S - 2] = O.length;
              for (let j = O.length; j > 0; ) v[S++] = Number(O[--j]);
              return;
            } else
              throw new RangeError(
                A +
                  " was too large to fit in MessagePack 64-bit integer format, use useBigIntExtension, or set largeBigIntToFloat to convert to float-64, or set largeBigIntToString to convert to string",
              );
          }
          S += 8;
        } else if (P === "undefined")
          this.encodeUndefinedAsNil
            ? (v[S++] = 192)
            : ((v[S++] = 212), (v[S++] = 0), (v[S++] = 0));
        else throw new Error("Unknown type: " + P);
      },
      z =
        this.variableMapSize || this.coercibleKeyAsNumber || this.skipValues
          ? (A) => {
              let P;
              if (this.skipValues) {
                P = [];
                for (let Z in A)
                  (typeof A.hasOwnProperty != "function" ||
                    A.hasOwnProperty(Z)) &&
                    !this.skipValues.includes(A[Z]) &&
                    P.push(Z);
              } else P = Object.keys(A);
              let L = P.length;
              L < 16
                ? (v[S++] = 128 | L)
                : L < 65536
                  ? ((v[S++] = 222), (v[S++] = L >> 8), (v[S++] = L & 255))
                  : ((v[S++] = 223), fe.setUint32(S, L), (S += 4));
              let O;
              if (this.coercibleKeyAsNumber)
                for (let Z = 0; Z < L; Z++) {
                  O = P[Z];
                  let j = Number(O);
                  (m(isNaN(j) ? O : j), m(A[O]));
                }
              else for (let Z = 0; Z < L; Z++) (m((O = P[Z])), m(A[O]));
            }
          : (A) => {
              v[S++] = 222;
              let P = S - t;
              S += 2;
              let L = 0;
              for (let O in A)
                (typeof A.hasOwnProperty != "function" ||
                  A.hasOwnProperty(O)) &&
                  (m(O), m(A[O]), L++);
              if (L > 65535)
                throw new Error(
                  'Object is too large to serialize with fast 16-bit map size, use the "variableMapSize" option to serialize this object',
                );
              ((v[P++ + t] = L >> 8), (v[P + t] = L & 255));
            },
      V =
        this.useRecords === !1
          ? z
          : r.progressiveRecords && !b
            ? (A) => {
                let P,
                  L = i.transitions || (i.transitions = Object.create(null)),
                  O = S++ - t,
                  Z;
                for (let j in A)
                  if (
                    typeof A.hasOwnProperty != "function" ||
                    A.hasOwnProperty(j)
                  ) {
                    if (((P = L[j]), P)) L = P;
                    else {
                      let Y = Object.keys(A),
                        K = L;
                      L = i.transitions;
                      let ee = 0;
                      for (let X = 0, ie = Y.length; X < ie; X++) {
                        let ae = Y[X];
                        ((P = L[ae]),
                          P || ((P = L[ae] = Object.create(null)), ee++),
                          (L = P));
                      }
                      (O + t + 1 == S ? (S--, N(L, Y, ee)) : F(L, Y, O, ee),
                        (Z = !0),
                        (L = K[j]));
                    }
                    m(A[j]);
                  }
                if (!Z) {
                  let j = L[er];
                  j ? (v[O + t] = j) : F(L, Object.keys(A), O, 0);
                }
              }
            : (A) => {
                let P,
                  L = i.transitions || (i.transitions = Object.create(null)),
                  O = 0;
                for (let j in A)
                  (typeof A.hasOwnProperty != "function" ||
                    A.hasOwnProperty(j)) &&
                    ((P = L[j]),
                    P || ((P = L[j] = Object.create(null)), O++),
                    (L = P));
                let Z = L[er];
                Z
                  ? Z >= 96 && b
                    ? ((v[S++] = ((Z -= 96) & 31) + 96), (v[S++] = Z >> 5))
                    : (v[S++] = Z)
                  : N(L, L.__keys__ || Object.keys(A), O);
                for (let j in A)
                  (typeof A.hasOwnProperty != "function" ||
                    A.hasOwnProperty(j)) &&
                    m(A[j]);
              },
      C = typeof this.useRecords == "function" && this.useRecords,
      H = C
        ? (A) => {
            C(A) ? V(A) : z(A);
          }
        : V,
      M = (A) => {
        let P;
        if (A > 16777216) {
          if (A - t > Po)
            throw new Error(
              "Packed buffer would be larger than maximum buffer size",
            );
          P = Math.min(
            Po,
            Math.round(
              Math.max((A - t) * (A > 67108864 ? 1.25 : 2), 4194304) / 4096,
            ) * 4096,
          );
        } else P = ((Math.max((A - t) << 2, v.length - 1) >> 12) + 1) << 12;
        let L = new cn(P);
        return (
          (fe = L.dataView || (L.dataView = new DataView(L.buffer, 0, P))),
          (A = Math.min(A, v.length)),
          v.copy ? v.copy(L, 0, t, A) : L.set(v.slice(t, A)),
          (S -= t),
          (t = 0),
          (ve = L.length - 10),
          (v = L)
        );
      },
      N = (A, P, L) => {
        let O = i.nextId;
        (O || (O = 64),
          O < y && this.shouldShareStructure && !this.shouldShareStructure(P)
            ? ((O = i.nextOwnId), O < I || (O = y), (i.nextOwnId = O + 1))
            : (O >= I && (O = y), (i.nextId = O + 1)));
        let Z = (P.highByte = O >= 96 && b ? (O - 96) >> 5 : -1);
        ((A[er] = O),
          (A.__keys__ = P),
          (i[O - 64] = P),
          O < y
            ? ((P.isShared = !0),
              (i.sharedLength = O - 63),
              (n = !0),
              Z >= 0 ? ((v[S++] = (O & 31) + 96), (v[S++] = Z)) : (v[S++] = O))
            : (Z >= 0
                ? ((v[S++] = 213),
                  (v[S++] = 114),
                  (v[S++] = (O & 31) + 96),
                  (v[S++] = Z))
                : ((v[S++] = 212), (v[S++] = 114), (v[S++] = O)),
              L && (T += R * L),
              x.length >= E && (x.shift()[er] = 0),
              x.push(A),
              m(P)));
      },
      F = (A, P, L, O) => {
        let Z = v,
          j = S,
          Y = ve,
          K = t;
        ((v = wr),
          (S = 0),
          (t = 0),
          v || (wr = v = new cn(8192)),
          (ve = v.length - 10),
          N(A, P, O),
          (wr = v));
        let ee = S;
        if (((v = Z), (S = j), (ve = Y), (t = K), ee > 1)) {
          let X = S + ee - 1;
          X > ve && M(X);
          let ie = L + t;
          (v.copyWithin(ie + ee, ie + 1, S),
            v.set(wr.slice(0, ee), ie),
            (S = X));
        } else v[L + t] = wr[0];
      },
      se = (A) => {
        let P = Yd(
          A,
          v,
          t,
          S,
          i,
          M,
          (L, O, Z) => {
            if (Z) return (n = !0);
            S = O;
            let j = v;
            return (
              m(L),
              $(),
              j !== v ? { position: S, targetView: fe, target: v } : S
            );
          },
          this,
        );
        if (P === 0) return H(A);
        S = P;
      };
  }
  useBuffer(r) {
    ((v = r),
      v.dataView ||
        (v.dataView = new DataView(v.buffer, v.byteOffset, v.byteLength)),
      (S = 0));
  }
  set position(r) {
    S = r;
  }
  get position() {
    return S;
  }
  clearSharedData() {
    (this.structures && (this.structures = []),
      this.typedStructs && (this.typedStructs = []));
  }
}
Cc = [
  Date,
  Set,
  Error,
  RegExp,
  ArrayBuffer,
  Object.getPrototypeOf(Uint8Array.prototype).constructor,
  Bc,
];
Oi = [
  {
    pack(e, r, t) {
      let n = e.getTime() / 1e3;
      if (
        (this.useTimestamp32 || e.getMilliseconds() === 0) &&
        n >= 0 &&
        n < 4294967296
      ) {
        let { target: i, targetView: s, position: l } = r(6);
        ((i[l++] = 214), (i[l++] = 255), s.setUint32(l, n));
      } else if (n > 0 && n < 4294967296) {
        let { target: i, targetView: s, position: l } = r(10);
        ((i[l++] = 215),
          (i[l++] = 255),
          s.setUint32(
            l,
            e.getMilliseconds() * 4e6 + ((n / 1e3 / 4294967296) >> 0),
          ),
          s.setUint32(l + 4, n));
      } else if (isNaN(n)) {
        if (this.onInvalidDate) return (r(0), t(this.onInvalidDate()));
        let { target: i, targetView: s, position: l } = r(3);
        ((i[l++] = 212), (i[l++] = 255), (i[l++] = 255));
      } else {
        let { target: i, targetView: s, position: l } = r(15);
        ((i[l++] = 199),
          (i[l++] = 12),
          (i[l++] = 255),
          s.setUint32(l, e.getMilliseconds() * 1e6),
          s.setBigInt64(l + 4, BigInt(Math.floor(n))));
      }
    },
  },
  {
    pack(e, r, t) {
      if (this.setAsEmptyObject) return (r(0), t({}));
      let n = Array.from(e),
        { target: i, position: s } = r(this.moreTypes ? 3 : 0);
      (this.moreTypes && ((i[s++] = 212), (i[s++] = 115), (i[s++] = 0)), t(n));
    },
  },
  {
    pack(e, r, t) {
      let { target: n, position: i } = r(this.moreTypes ? 3 : 0);
      (this.moreTypes && ((n[i++] = 212), (n[i++] = 101), (n[i++] = 0)),
        t([e.name, e.message, e.cause]));
    },
  },
  {
    pack(e, r, t) {
      let { target: n, position: i } = r(this.moreTypes ? 3 : 0);
      (this.moreTypes && ((n[i++] = 212), (n[i++] = 120), (n[i++] = 0)),
        t([e.source, e.flags]));
    },
  },
  {
    pack(e, r) {
      this.moreTypes
        ? Zo(e, 16, r)
        : Ho(Ln ? $n.from(e) : new Uint8Array(e), r);
    },
  },
  {
    pack(e, r) {
      let t = e.constructor;
      t !== Dc && this.moreTypes ? Zo(e, Uc.indexOf(t.name), r) : Ho(e, r);
    },
  },
  {
    pack(e, r) {
      let { target: t, position: n } = r(1);
      t[n] = 193;
    },
  },
];
function Zo(e, r, t, n) {
  let i = e.byteLength;
  if (i + 1 < 256) {
    var { target: s, position: l } = t(4 + i);
    ((s[l++] = 199), (s[l++] = i + 1));
  } else if (i + 1 < 65536) {
    var { target: s, position: l } = t(5 + i);
    ((s[l++] = 200), (s[l++] = (i + 1) >> 8), (s[l++] = (i + 1) & 255));
  } else {
    var { target: s, position: l, targetView: h } = t(7 + i);
    ((s[l++] = 201), h.setUint32(l, i + 1), (l += 4));
  }
  ((s[l++] = 116),
    (s[l++] = r),
    e.buffer || (e = new Uint8Array(e)),
    s.set(new Uint8Array(e.buffer, e.byteOffset, e.byteLength), l));
}
function Ho(e, r) {
  let t = e.byteLength;
  var n, i;
  if (t < 256) {
    var { target: n, position: i } = r(t + 2);
    ((n[i++] = 196), (n[i++] = t));
  } else if (t < 65536) {
    var { target: n, position: i } = r(t + 3);
    ((n[i++] = 197), (n[i++] = t >> 8), (n[i++] = t & 255));
  } else {
    var { target: n, position: i, targetView: s } = r(t + 5);
    ((n[i++] = 198), s.setUint32(i, t), (i += 4));
  }
  n.set(e, i);
}
function Xd(e, r, t, n) {
  let i = e.length;
  switch (i) {
    case 1:
      r[t++] = 212;
      break;
    case 2:
      r[t++] = 213;
      break;
    case 4:
      r[t++] = 214;
      break;
    case 8:
      r[t++] = 215;
      break;
    case 16:
      r[t++] = 216;
      break;
    default:
      i < 256
        ? ((r[t++] = 199), (r[t++] = i))
        : i < 65536
          ? ((r[t++] = 200), (r[t++] = i >> 8), (r[t++] = i & 255))
          : ((r[t++] = 201),
            (r[t++] = i >> 24),
            (r[t++] = (i >> 16) & 255),
            (r[t++] = (i >> 8) & 255),
            (r[t++] = i & 255));
  }
  return ((r[t++] = n), r.set(e, t), (t += i), t);
}
function qd(e, r) {
  let t,
    n = r.length * 6,
    i = e.length - n;
  for (; (t = r.pop()); ) {
    let s = t.offset,
      l = t.id;
    (e.copyWithin(s + n, s, i), (n -= 6));
    let h = s + n;
    ((e[h++] = 214),
      (e[h++] = 105),
      (e[h++] = l >> 24),
      (e[h++] = (l >> 16) & 255),
      (e[h++] = (l >> 8) & 255),
      (e[h++] = l & 255),
      (i = s));
  }
  return e;
}
function Wo(e, r, t) {
  if (ge.length > 0) {
    (fe.setUint32(ge.position + e, S + t - ge.position - e),
      (ge.stringsPosition = S - e));
    let n = ge;
    ((ge = null), r(n[0]), r(n[1]));
  }
}
function Jd(e, r) {
  return (
    (e.isCompatible = (t) => {
      let n = !t || (r.lastNamedStructuresLength || 0) === t.length;
      return (n || r._mergeStructures(t), n);
    }),
    e
  );
}
let Nc = new Kd({ useRecords: !1 });
Nc.pack;
Nc.pack;
const Qd = 512,
  e0 = 1024,
  t0 = 2048;
var Vo = Ee(287).hp;
class r0 {
  constructor(r, t = { threads: 1 }, n = { recursive: !1 }) {
    ((this.backendOptions = t),
      (this.circuitOptions = n),
      (this.acirUncompressedBytecode = n0(r)));
  }
  async instantiate() {
    if (!this.api) {
      const r = await Ji.new(this.backendOptions);
      (await r.acirInitSRS(
        this.acirUncompressedBytecode,
        this.circuitOptions.recursive,
        !0,
      ),
        (this.api = r));
    }
  }
  async generateProof(r, t) {
    await this.instantiate();
    const i = await (
        t != null && t.keccak
          ? this.api.acirProveUltraKeccakHonk.bind(this.api)
          : t != null && t.keccakZK
            ? this.api.acirProveUltraKeccakZKHonk.bind(this.api)
            : t != null && t.starknet
              ? this.api.acirProveUltraStarknetHonk.bind(this.api)
              : this.api.acirProveUltraHonk.bind(this.api)
      )(this.acirUncompressedBytecode, kc(r)),
      l = await (
        t != null && t.keccak
          ? this.api.acirWriteVkUltraKeccakHonk.bind(this.api)
          : t != null && t.keccakZK
            ? this.api.acirWriteVkUltraKeccakZKHonk.bind(this.api)
            : t != null && t.starknet
              ? this.api.acirWriteVkUltraStarknetHonk.bind(this.api)
              : this.api.acirWriteVkUltraHonk.bind(this.api)
      )(this.acirUncompressedBytecode),
      h = await this.api.acirVkAsFieldsUltraHonk(new ct(l)),
      u = Number(h[1].toString()) - ud,
      { proof: d, publicInputs: E } = fd(i, u),
      b = dd(E);
    return { proof: d, publicInputs: b };
  }
  async verifyProof(r, t) {
    await this.instantiate();
    const n = hd(_d(r.publicInputs), r.proof),
      i =
        t != null && t.keccak
          ? this.api.acirWriteVkUltraKeccakHonk.bind(this.api)
          : t != null && t.keccakZK
            ? this.api.acirWriteVkUltraKeccakZKHonk.bind(this.api)
            : t != null && t.starknet
              ? this.api.acirWriteVkUltraStarknetHonk.bind(this.api)
              : this.api.acirWriteVkUltraHonk.bind(this.api),
      s =
        t != null && t.keccak
          ? this.api.acirVerifyUltraKeccakHonk.bind(this.api)
          : t != null && t.keccakZK
            ? this.api.acirVerifyUltraKeccakZKHonk.bind(this.api)
            : t != null && t.starknet
              ? this.api.acirVerifyUltraStarknetHonk.bind(this.api)
              : this.api.acirVerifyUltraHonk.bind(this.api),
      l = await i(this.acirUncompressedBytecode);
    return await s(n, new ct(l));
  }
  async getVerificationKey(r) {
    return (
      await this.instantiate(),
      r != null && r.keccak
        ? await this.api.acirWriteVkUltraKeccakHonk(
            this.acirUncompressedBytecode,
          )
        : r != null && r.keccakZK
          ? await this.api.acirWriteVkUltraKeccakZKHonk(
              this.acirUncompressedBytecode,
            )
          : r != null && r.starknet
            ? await this.api.acirWriteVkUltraStarknetHonk(
                this.acirUncompressedBytecode,
              )
            : await this.api.acirWriteVkUltraHonk(this.acirUncompressedBytecode)
    );
  }
  async getSolidityVerifier(r) {
    await this.instantiate();
    const t =
      r ??
      (await this.api.acirWriteVkUltraKeccakHonk(
        this.acirUncompressedBytecode,
      ));
    return await this.api.acirHonkSolidityVerifier(
      this.acirUncompressedBytecode,
      new ct(t),
    );
  }
  async generateRecursiveProofArtifacts(r, t) {
    await this.instantiate();
    const n = await this.api.acirWriteVkUltraHonk(
        this.acirUncompressedBytecode,
      ),
      i = await this.api.acirVkAsFieldsUltraHonk(n);
    return {
      proofAsFields: [],
      vkAsFields: i.map((s) => s.toString()),
      vkHash: "",
    };
  }
  async destroy() {
    this.api && (await this.api.destroy());
  }
}
function n0(e) {
  const r = i0(e);
  return kc(r);
}
function i0(e) {
  if (typeof Vo < "u") {
    const r = Vo.from(e, "base64");
    return new Uint8Array(r.buffer, r.byteOffset, r.byteLength);
  } else {
    if (typeof atob == "function")
      return Uint8Array.from(atob(e), (r) => r.charCodeAt(0));
    throw new Error("No implementation found for base64 decoding.");
  }
}
class Ji extends af {
  constructor(r, t, n) {
    (super(t), (this.worker = r), (this.options = n));
  }
  static async new(r = {}) {
    var l, h;
    const t = await uf(),
      n = cf(t),
      { module: i, threads: s } = await cd(r.threads, r.wasmPath, r.logger);
    return (
      await n.init(
        i,
        s,
        xs(r.logger ?? Sn()("bb.js:bb_wasm_async")),
        (l = r.memory) == null ? void 0 : l.initial,
        (h = r.memory) == null ? void 0 : h.maximum,
      ),
      new Ji(t, n, r)
    );
  }
  async getNumThreads() {
    return await this.wasm.getNumThreads();
  }
  async initSRSForCircuitSize(r) {
    const t = await mn.new(r + 1, this.options.crsPath, this.options.logger);
    await this.srsInitSrs(
      new ct(t.getG1Data()),
      t.numPoints,
      new ct(t.getG2Data()),
    );
  }
  async initSRSClientIVC() {
    const r = await mn.new(1048577, this.options.crsPath, this.options.logger),
      t = await Fi.new(2 ** 16 + 1, this.options.crsPath, this.options.logger);
    (await this.srsInitSrs(
      new ct(r.getG1Data()),
      r.numPoints,
      new ct(r.getG2Data()),
    ),
      await this.srsInitGrumpkinSrs(new ct(t.getG1Data()), t.numPoints));
  }
  async acirInitSRS(r, t, n) {
    const [i, s] = await this.acirGetCircuitSizes(r, t, n);
    return this.initSRSForCircuitSize(s);
  }
  async destroy() {
    (await this.wasm.destroy(), await this.worker.terminate());
  }
  getWasm() {
    return this.wasm;
  }
}
const a0 = "1.0.0-beta.9+6abff2f16e1c1314ba30708d1cf032a536de3d19",
  o0 = "5264932767758831614",
  s0 = {
    parameters: [
      { name: "root", type: { kind: "field" }, visibility: "public" },
      { name: "nullifier_hash", type: { kind: "field" }, visibility: "public" },
      { name: "recipient_hash", type: { kind: "field" }, visibility: "public" },
      { name: "recipient", type: { kind: "field" }, visibility: "private" },
      { name: "secret", type: { kind: "field" }, visibility: "private" },
      { name: "nullifier", type: { kind: "field" }, visibility: "private" },
      {
        name: "merkle_proof",
        type: { kind: "array", length: 8, type: { kind: "field" } },
        visibility: "private",
      },
      {
        name: "is_even",
        type: { kind: "array", length: 8, type: { kind: "boolean" } },
        visibility: "private",
      },
    ],
    return_type: null,
    error_types: {
      "3559124755279371145": {
        error_kind: "string",
        string:
          "Computed nullifier hash does not match the provided nullifier hash",
      },
      "13687630160716619492": {
        error_kind: "string",
        string: "Computed root does not match the provided root",
      },
      "16486370636630262716": {
        error_kind: "string",
        string:
          "Computed recipient_hash does not match the provided recipient_hash",
      },
    },
  },
  c0 =
    "H4sIAAAAAAAA/9Va2U4UQRS9MMiO7IsCLuACLtA13c10gwu4gAuouIsbjDM8+OJ3+OAn+CEm6qsPfoAPJj7xCT4bb0l1up2USQOnTFUlJ1VTnbm52zk90111tD0qjFit6xgFNe9Xc3avU7PXpdnr1uz1aPZ6NXt9mr1+NWdH8nlezb43EwTVUrEqfLHhFeNyFHpBWJ6JRCTCKKwUI9+vRkFUistxyYtF4FfFZhj7m972GMjY8vY4TPo5uHs/i7UbSV0aMr7uY/xS64bMeiCzHlTr5HtDjAOMg4zhzL6pHIzsPgdipzkY+Md6pCYHo4xDjMOMI5oc1INzUEewfhWjhO19dL0bKdUjpN0HhuP29jaEjHnIQNwPyYzWNYDjbwTGfBToF7BvhCu1GALWYswQh23ihe6+InswuX+MUb576zjjGOM440SNPQLG3kTp7zuk3Udkt8Z2qhyj435MbvC6CRjzSaBfwL4RrtRiHFiLCUMctokXOo2VPZho6QTl09hJxinGacYZMqexzZT+X0bafUJ2a2yXyjE67jVyg9fNwJjPAv0C9o1wpRaTwFpMGeKwTbzQaazswURLpyifxk5LXxiCUSRzGttC6fNHpN2nZLfGdqsco+N+Rm7wugUYsw/0C9g3wpVaTANrERjisE280Gms7MFESwPKp7EhY4ZRYkRkTmNbKX2fg7T7nOzW2B6VY3TcL8gNXrcCY46BfgH7RrhSixBYi1lDHLaJFzqNlT2YaOks5dPYOcY5xnnGBTKnsW2Uvh9H2n1Jdmtsr8oxOu51coPXbcCYLwL9AvaNWHekFnPAWswb4rBNvNBprOzBREvnKZ/GLjAuMS4zrpA5jW2n9LwR0u4G2a2xfSrH6LjL5Aav24ExXwX6Bewb4UotFoC1WDTEYZt4odNY2YOJli5SPo1dYlxjXGfcIHMa20F/n99E2X1Fdmtsv8oxOu4KucHrDmDMN4F+AftGuFKLJWAtlg1x2CZe6DRW9mCipcuUT2NXGLcYtxl3yPyZYGTPrBjOZ4F2fsZ6lXGXcY9x/z/ksx6Yz1VwPpPYe9VcUHvy7Lo8NyvPdclzB/K9mHxuK58ryN+9UpfluWJ57k2ey+hWtZF25P+CfmWLMrWqz3zOXutQ89vvH94Pv6uIzKU/7yHk2Prx5vXI3M9P2WuRmj8Wvnz7vPZ1i2rGb8PIDU+cMgAA",
  l0 =
    "tZbNbuIwFIXfJWsWvj924r7KaIQChCpSFFAKI40Q716HHqdk4QjF7YZDYs4n2+f64ltxaHbX923bH08fxdufW7Eb2q5r37fdaV9f2lMf3t7umyI+bi9D04RXxdN4cJ3roekvxVt/7bpN8a/uro8ffZzr/qGXegijZlM0/SFoAB7brhm/3TffbpO2SiUwq8hkt3M/Lfgtwy++/Pb7mZ/TfmaKE2BmlyJImkCkkUDk3Ko5lGaaQ6Upgl2YQ2k1zqEsJUVwaYJnB4AXv8JPxky7YNStWUPl4y6QN8k1LNSS5RIA63yylkxmMRFlJ0mcHSVJZpZLgBfDXFxGfpqeAHDCqTQX/KWPYVY2XQ1VGqAmBqH0FCW9DpCYgwbXCoCt4hLcc2uaAzi7O+a3R/6B/pjfIDm/Q3Jui+T8Hsm/2iSrcjoWXlYcqzBznhbxnMWcILlVKfn1IJJdD6KZ9bAEeLEeFpeRXQ9Exk3HU8tZnn/DU71vh9mlsahC6WwK//gk8yUU3KFsiaEybmtQDQmN4xbqoCW0gvovZQMlKEMFCh6Dx+AxeAwegyfgCXgCnoAn4Al4Ap6AJ+AJeAqegqfgKXgKnoKn4Cl4Cp6CZ8Gz4FnwLHg28CSEZwNv/DOxbrwx38c0h7bedQ1u8cdrv3+61F/+n+NIvPafh9O+OVyHZszyMRbS/QQ=",
  u0 = {
    50: {
      source: `use dep::poseidon::poseidon2;
mod merkle_tree;

fn main(
    // public inputs
    root: pub Field,
    nullifier_hash: pub Field,
    recipient_hash: pub Field,
    // private inputs
    recipient: Field,
    secret: Field,
    nullifier: Field,
    merkle_proof: [Field; 8],
    is_even: [bool; 8],
) {
    // compute the commitment Poseidon(nullifier, secret)
    let commitment = poseidon2::Poseidon2::hash([nullifier, secret], 2);
    // check that the nullfier matches the nullifier hash
    let computed_nullifier_hash = poseidon2::Poseidon2::hash([nullifier], 1);
    assert(
        computed_nullifier_hash == nullifier_hash,
        "Computed nullifier hash does not match the provided nullifier hash",
    );
    //check the commitment is in the merkle tree
    let computed_root = merkle_tree::compute_merkle_root(commitment, merkle_proof, is_even);
    assert(computed_root == root, "Computed root does not match the provided root");
    // check that the recipient matches the recipient binding
    let computed_recipient_hash = poseidon2::Poseidon2::hash([recipient], 1);
    assert(
        computed_recipient_hash == recipient_hash,
        "Computed recipient_hash does not match the provided recipient_hash",
    );
}
`,
      path: "/Users/dave/Work/umbra_swap/circuit/src/main.nr",
    },
    51: {
      source: `use dep::poseidon::poseidon2;

pub fn compute_merkle_root(leaf: Field, merkle_proof: [Field; 8], is_even: [bool; 8]) -> Field {
    // temporary variable to store the hash for the current level we are working on
    let mut hash = leaf;
    // increment through the levels
    for i in 0..8 {
        // if the current level is even, we hash the current hash and the proof
        let (left, right) = if is_even[i] {
            (hash, merkle_proof[i])
        } else {
            (merkle_proof[i], hash)
        };
        // compute the hash for the current level
        hash = poseidon2::Poseidon2::hash([left, right], 2);
    }
    // return the root hash
    hash
}
`,
      path: "/Users/dave/Work/umbra_swap/circuit/src/merkle_tree.nr",
    },
    59: {
      source: `use std::default::Default;
use std::hash::Hasher;

comptime global RATE: u32 = 3;

pub struct Poseidon2 {
    cache: [Field; 3],
    state: [Field; 4],
    cache_size: u32,
    squeeze_mode: bool, // 0 => absorb, 1 => squeeze
}

impl Poseidon2 {
    #[no_predicates]
    pub fn hash<let N: u32>(input: [Field; N], message_size: u32) -> Field {
        Poseidon2::hash_internal(input, message_size)
    }

    pub(crate) fn new(iv: Field) -> Poseidon2 {
        let mut result =
            Poseidon2 { cache: [0; 3], state: [0; 4], cache_size: 0, squeeze_mode: false };
        result.state[RATE] = iv;
        result
    }

    fn perform_duplex(&mut self) {
        // add the cache into sponge state
        for i in 0..RATE {
            // We effectively zero-pad the cache by only adding to the state
            // cache that is less than the specified \`cache_size\`
            if i < self.cache_size {
                self.state[i] += self.cache[i];
            }
        }
        self.state = crate::poseidon2_permutation(self.state, 4);
    }

    fn absorb(&mut self, input: Field) {
        assert(!self.squeeze_mode);
        if self.cache_size == RATE {
            // If we're absorbing, and the cache is full, apply the sponge permutation to compress the cache
            self.perform_duplex();
            self.cache[0] = input;
            self.cache_size = 1;
        } else {
            // If we're absorbing, and the cache is not full, add the input into the cache
            self.cache[self.cache_size] = input;
            self.cache_size += 1;
        }
    }

    fn squeeze(&mut self) -> Field {
        assert(!self.squeeze_mode);
        // If we're in absorb mode, apply sponge permutation to compress the cache.
        self.perform_duplex();
        self.squeeze_mode = true;

        // Pop one item off the top of the permutation and return it.
        self.state[0]
    }

    fn hash_internal<let N: u32>(input: [Field; N], in_len: u32) -> Field {
        let two_pow_64 = 18446744073709551616;
        let iv: Field = (in_len as Field) * two_pow_64;
        let mut sponge = Poseidon2::new(iv);
        for i in 0..input.len() {
            if i < in_len {
                sponge.absorb(input[i]);
            }
        }
        sponge.squeeze()
    }
}

pub struct Poseidon2Hasher {
    _state: [Field],
}

impl Hasher for Poseidon2Hasher {
    fn finish(self) -> Field {
        let iv: Field = (self._state.len() as Field) * 18446744073709551616; // iv = (self._state.len() << 64)
        let mut sponge = Poseidon2::new(iv);
        for i in 0..self._state.len() {
            sponge.absorb(self._state[i]);
        }

        sponge.squeeze()
    }

    fn write(&mut self, input: Field) {
        self._state = self._state.push_back(input);
    }
}

impl Default for Poseidon2Hasher {
    fn default() -> Self {
        Poseidon2Hasher { _state: &[] }
    }
}
`,
      path: "/Users/dave/nargo/github.com/noir-lang/poseidon/v0.2.0/src/poseidon2.nr",
    },
  },
  f0 = ["main"],
  h0 = [],
  Yo = {
    noir_version: a0,
    hash: o0,
    abi: s0,
    bytecode: c0,
    debug_symbols: l0,
    file_map: u0,
    names: f0,
    brillig_names: h0,
  };
function d0(e) {
  const r = e.map(p0);
  return _0(r);
}
function _0(e) {
  const r = e.reduce((i, s) => i + s.length, 0),
    t = new Uint8Array(r);
  let n = 0;
  for (const i of e) (t.set(i, n), (n += i.length));
  return t;
}
function p0(e) {
  const r = BigInt(e).toString(16).padStart(64, "0"),
    t = r.length / 2,
    n = new Uint8Array(t);
  let i = 0,
    s = 0;
  for (; i < t; )
    ((n[i] = parseInt(r.slice(s, s + 2), 16)), (i += 1), (s += 2));
  return n;
}
const Go = (e, r = 1e4) => {
  const t = Date.now(),
    n = () => {
      window.ZkBridgeReady
        ? window.ZkBridgeReady.postMessage(e)
        : Date.now() - t > r
          ? console.error(
              `ZkBridge timeout: bridge never injected, tried to send: ${e}`,
            )
          : setTimeout(n, 50);
    };
  n();
};
async function w0() {
  try {
    const e = new URL("./acvm_js_bg-BvxvrAml.wasm", import.meta.url).href,
      r = new URL("./noirc_abi_wasm_bg-DRbWm09M.wasm", import.meta.url).href;
    (await Promise.all([$i(fetch(e)), yn(fetch(r))]),
      (window.__zkGenerateProof = async (t) => {
        const n = new Du(Yo),
          { witness: i } = await n.execute(t),
          s = new r0(Yo.bytecode, { threads: 1 }),
          l = await s.generateProof(i, { keccak: !0 });
        return (
          s.destroy(),
          {
            proofBytesHex: jo(l.proof),
            publicInputsHex: jo(d0(l.publicInputs)),
          }
        );
      }),
      Go("ready"));
  } catch (e) {
    (console.error("ZkWorker init error:", e), Go("error:" + e.toString()));
  }
}
function jo(e) {
  return Array.from(e)
    .map((r) => r.toString(16).padStart(2, "0"))
    .join("");
}
w0();
