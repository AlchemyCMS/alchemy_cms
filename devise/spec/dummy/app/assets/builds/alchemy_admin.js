(() => {
  // node_modules/@alchemy_cms/admin/package/dist/admin.js
  (() => {
    var Vn = /\./;
    function vr() {
      if (Alchemy.locale == null)
        throw "Alchemy.locale is not set! Please set Alchemy.locale to a locale string in order to translate something.";
      return Alchemy.locale;
    }
    function br() {
      let n = vr(), t = Alchemy.translations && Alchemy.translations[n];
      return t || (console.warn(`Translations for locale ${n} not found!`), {});
    }
    function yr(n, t) {
      let e = t.split(Vn), i = n[e[0]];
      return i && i[e[1]] || t;
    }
    function Dr(n) {
      let t = br();
      return Vn.test(n) ? yr(t, n) : t[n] || n;
    }
    function cn(n, t) {
      let e = Dr(n);
      return t ? e.replace(/%\{.+\}/, t) : e;
    }
    var wr = { en: { allowed_chars: "of %{count} chars", cancel: "Cancel", cancelled: "Cancelled", click_to_edit: "click to edit", complete: "Complete", element_dirty_notice: "This element has unsaved changes. Do you really want to fold it?", help: "Help", ok: "Ok", page_dirty_notice: "You have unsaved changes on this page. They will be lost if you continue.", page_found: "Page found", pages_found: "Pages found", url_validation_failed: "The url has no valid format.", warning: "Warning!", "File is too large": "File is too large", "File is too small": "File is too small", "File type not allowed": "File type not allowed", "Maximum number of files exceeded": "Maximum number of files exceeded.", "Uploaded bytes exceed file size": "Uploaded bytes exceed file size", formats: { datetime: "Y-m-d H:i", date: "Y-m-d", time: "H:i", time_24hr: false } } }, Zn = wr;
    function Qn(n, t) {
      var e = Object.keys(n);
      if (Object.getOwnPropertySymbols) {
        var i = Object.getOwnPropertySymbols(n);
        t && (i = i.filter(function(a) {
          return Object.getOwnPropertyDescriptor(n, a).enumerable;
        })), e.push.apply(e, i);
      }
      return e;
    }
    function Se(n) {
      for (var t = 1; t < arguments.length; t++) {
        var e = arguments[t] != null ? arguments[t] : {};
        t % 2 ? Qn(Object(e), true).forEach(function(i) {
          Er(n, i, e[i]);
        }) : Object.getOwnPropertyDescriptors ? Object.defineProperties(n, Object.getOwnPropertyDescriptors(e)) : Qn(Object(e)).forEach(function(i) {
          Object.defineProperty(n, i, Object.getOwnPropertyDescriptor(e, i));
        });
      }
      return n;
    }
    function Ot(n) {
      return typeof Symbol == "function" && typeof Symbol.iterator == "symbol" ? Ot = function(t) {
        return typeof t;
      } : Ot = function(t) {
        return t && typeof Symbol == "function" && t.constructor === Symbol && t !== Symbol.prototype ? "symbol" : typeof t;
      }, Ot(n);
    }
    function Er(n, t, e) {
      return t in n ? Object.defineProperty(n, t, { value: e, enumerable: true, configurable: true, writable: true }) : n[t] = e, n;
    }
    function Te() {
      return Te = Object.assign || function(n) {
        for (var t = 1; t < arguments.length; t++) {
          var e = arguments[t];
          for (var i in e)
            Object.prototype.hasOwnProperty.call(e, i) && (n[i] = e[i]);
        }
        return n;
      }, Te.apply(this, arguments);
    }
    function Sr(n, t) {
      if (n == null)
        return {};
      var e = {}, i = Object.keys(n), a, l;
      for (l = 0; l < i.length; l++)
        a = i[l], !(t.indexOf(a) >= 0) && (e[a] = n[a]);
      return e;
    }
    function Cr(n, t) {
      if (n == null)
        return {};
      var e = Sr(n, t), i, a;
      if (Object.getOwnPropertySymbols) {
        var l = Object.getOwnPropertySymbols(n);
        for (a = 0; a < l.length; a++)
          i = l[a], !(t.indexOf(i) >= 0) && Object.prototype.propertyIsEnumerable.call(n, i) && (e[i] = n[i]);
      }
      return e;
    }
    var Mr = "1.15.0";
    function xe(n) {
      if (typeof window < "u" && window.navigator)
        return !!navigator.userAgent.match(n);
    }
    var Ie = xe(/(?:Trident.*rv[ :]?11\.|msie|iemobile|Windows Phone)/i), ct = xe(/Edge/i), ei = xe(/firefox/i), at = xe(/safari/i) && !xe(/chrome/i) && !xe(/android/i), si = xe(/iP(ad|od|hone)/i), ui = xe(/chrome/i) && xe(/android/i), ci = { capture: false, passive: false };
    function N(n, t, e) {
      n.addEventListener(t, e, !Ie && ci);
    }
    function F(n, t, e) {
      n.removeEventListener(t, e, !Ie && ci);
    }
    function Lt(n, t) {
      if (t) {
        if (t[0] === ">" && (t = t.substring(1)), n)
          try {
            if (n.matches)
              return n.matches(t);
            if (n.msMatchesSelector)
              return n.msMatchesSelector(t);
            if (n.webkitMatchesSelector)
              return n.webkitMatchesSelector(t);
          } catch {
            return false;
          }
        return false;
      }
    }
    function _r(n) {
      return n.host && n !== document && n.host.nodeType ? n.host : n.parentNode;
    }
    function we(n, t, e, i) {
      if (n) {
        e = e || document;
        do {
          if (t != null && (t[0] === ">" ? n.parentNode === e && Lt(n, t) : Lt(n, t)) || i && n === e)
            return n;
          if (n === e)
            break;
        } while (n = _r(n));
      }
      return null;
    }
    var ti = /\s+/g;
    function de(n, t, e) {
      if (n && t)
        if (n.classList)
          n.classList[e ? "add" : "remove"](t);
        else {
          var i = (" " + n.className + " ").replace(ti, " ").replace(" " + t + " ", " ");
          n.className = (i + (e ? " " + t : "")).replace(ti, " ");
        }
    }
    function S(n, t, e) {
      var i = n && n.style;
      if (i) {
        if (e === void 0)
          return document.defaultView && document.defaultView.getComputedStyle ? e = document.defaultView.getComputedStyle(n, "") : n.currentStyle && (e = n.currentStyle), t === void 0 ? e : e[t];
        !(t in i) && t.indexOf("webkit") === -1 && (t = "-webkit-" + t), i[t] = e + (typeof e == "string" ? "" : "px");
      }
    }
    function Ue(n, t) {
      var e = "";
      if (typeof n == "string")
        e = n;
      else
        do {
          var i = S(n, "transform");
          i && i !== "none" && (e = i + " " + e);
        } while (!t && (n = n.parentNode));
      var a = window.DOMMatrix || window.WebKitCSSMatrix || window.CSSMatrix || window.MSCSSMatrix;
      return a && new a(e);
    }
    function di(n, t, e) {
      if (n) {
        var i = n.getElementsByTagName(t), a = 0, l = i.length;
        if (e)
          for (; a < l; a++)
            e(i[a], a);
        return i;
      }
      return [];
    }
    function Ee() {
      var n = document.scrollingElement;
      return n || document.documentElement;
    }
    function U(n, t, e, i, a) {
      if (!(!n.getBoundingClientRect && n !== window)) {
        var l, u, c, f, p, v, g;
        if (n !== window && n.parentNode && n !== Ee() ? (l = n.getBoundingClientRect(), u = l.top, c = l.left, f = l.bottom, p = l.right, v = l.height, g = l.width) : (u = 0, c = 0, f = window.innerHeight, p = window.innerWidth, v = window.innerHeight, g = window.innerWidth), (t || e) && n !== window && (a = a || n.parentNode, !Ie))
          do
            if (a && a.getBoundingClientRect && (S(a, "transform") !== "none" || e && S(a, "position") !== "static")) {
              var E = a.getBoundingClientRect();
              u -= E.top + parseInt(S(a, "border-top-width")), c -= E.left + parseInt(S(a, "border-left-width")), f = u + l.height, p = c + l.width;
              break;
            }
          while (a = a.parentNode);
        if (i && n !== window) {
          var _ = Ue(a || n), I = _ && _.a, y = _ && _.d;
          _ && (u /= y, c /= I, g /= I, v /= y, f = u + v, p = c + g);
        }
        return { top: u, left: c, bottom: f, right: p, width: g, height: v };
      }
    }
    function ni(n, t, e) {
      for (var i = Pe(n, true), a = U(n)[t]; i; ) {
        var l = U(i)[e], u = void 0;
        if (e === "top" || e === "left" ? u = a >= l : u = a <= l, !u)
          return i;
        if (i === Ee())
          break;
        i = Pe(i, false);
      }
      return false;
    }
    function Je(n, t, e, i) {
      for (var a = 0, l = 0, u = n.children; l < u.length; ) {
        if (u[l].style.display !== "none" && u[l] !== C.ghost && (i || u[l] !== C.dragged) && we(u[l], e.draggable, n, false)) {
          if (a === t)
            return u[l];
          a++;
        }
        l++;
      }
      return null;
    }
    function Cn(n, t) {
      for (var e = n.lastElementChild; e && (e === C.ghost || S(e, "display") === "none" || t && !Lt(e, t)); )
        e = e.previousElementSibling;
      return e || null;
    }
    function he(n, t) {
      var e = 0;
      if (!n || !n.parentNode)
        return -1;
      for (; n = n.previousElementSibling; )
        n.nodeName.toUpperCase() !== "TEMPLATE" && n !== C.clone && (!t || Lt(n, t)) && e++;
      return e;
    }
    function ii(n) {
      var t = 0, e = 0, i = Ee();
      if (n)
        do {
          var a = Ue(n), l = a.a, u = a.d;
          t += n.scrollLeft * l, e += n.scrollTop * u;
        } while (n !== i && (n = n.parentNode));
      return [t, e];
    }
    function xr(n, t) {
      for (var e in n)
        if (n.hasOwnProperty(e)) {
          for (var i in t)
            if (t.hasOwnProperty(i) && t[i] === n[e][i])
              return Number(e);
        }
      return -1;
    }
    function Pe(n, t) {
      if (!n || !n.getBoundingClientRect)
        return Ee();
      var e = n, i = false;
      do
        if (e.clientWidth < e.scrollWidth || e.clientHeight < e.scrollHeight) {
          var a = S(e);
          if (e.clientWidth < e.scrollWidth && (a.overflowX == "auto" || a.overflowX == "scroll") || e.clientHeight < e.scrollHeight && (a.overflowY == "auto" || a.overflowY == "scroll")) {
            if (!e.getBoundingClientRect || e === document.body)
              return Ee();
            if (i || t)
              return e;
            i = true;
          }
        }
      while (e = e.parentNode);
      return Ee();
    }
    function Tr(n, t) {
      if (n && t)
        for (var e in t)
          t.hasOwnProperty(e) && (n[e] = t[e]);
      return n;
    }
    function dn(n, t) {
      return Math.round(n.top) === Math.round(t.top) && Math.round(n.left) === Math.round(t.left) && Math.round(n.height) === Math.round(t.height) && Math.round(n.width) === Math.round(t.width);
    }
    var ot;
    function fi(n, t) {
      return function() {
        if (!ot) {
          var e = arguments, i = this;
          e.length === 1 ? n.call(i, e[0]) : n.apply(i, e), ot = setTimeout(function() {
            ot = void 0;
          }, t);
        }
      };
    }
    function Ir() {
      clearTimeout(ot), ot = void 0;
    }
    function pi(n, t, e) {
      n.scrollLeft += t, n.scrollTop += e;
    }
    function hi(n) {
      var t = window.Polymer, e = window.jQuery || window.Zepto;
      return t && t.dom ? t.dom(n).cloneNode(true) : e ? e(n).clone(true)[0] : n.cloneNode(true);
    }
    var pe = "Sortable" + (/* @__PURE__ */ new Date()).getTime();
    function Ar() {
      var n = [], t;
      return { captureAnimationState: function() {
        if (n = [], !!this.options.animation) {
          var i = [].slice.call(this.el.children);
          i.forEach(function(a) {
            if (!(S(a, "display") === "none" || a === C.ghost)) {
              n.push({ target: a, rect: U(a) });
              var l = Se({}, n[n.length - 1].rect);
              if (a.thisAnimationDuration) {
                var u = Ue(a, true);
                u && (l.top -= u.f, l.left -= u.e);
              }
              a.fromRect = l;
            }
          });
        }
      }, addAnimationState: function(i) {
        n.push(i);
      }, removeAnimationState: function(i) {
        n.splice(xr(n, { target: i }), 1);
      }, animateAll: function(i) {
        var a = this;
        if (!this.options.animation) {
          clearTimeout(t), typeof i == "function" && i();
          return;
        }
        var l = false, u = 0;
        n.forEach(function(c) {
          var f = 0, p = c.target, v = p.fromRect, g = U(p), E = p.prevFromRect, _ = p.prevToRect, I = c.rect, y = Ue(p, true);
          y && (g.top -= y.f, g.left -= y.e), p.toRect = g, p.thisAnimationDuration && dn(E, g) && !dn(v, g) && (I.top - g.top) / (I.left - g.left) === (v.top - g.top) / (v.left - g.left) && (f = Fr(I, E, _, a.options)), dn(g, v) || (p.prevFromRect = v, p.prevToRect = g, f || (f = a.options.animation), a.animate(p, I, g, f)), f && (l = true, u = Math.max(u, f), clearTimeout(p.animationResetTimer), p.animationResetTimer = setTimeout(function() {
            p.animationTime = 0, p.prevFromRect = null, p.fromRect = null, p.prevToRect = null, p.thisAnimationDuration = null;
          }, f), p.thisAnimationDuration = f);
        }), clearTimeout(t), l ? t = setTimeout(function() {
          typeof i == "function" && i();
        }, u) : typeof i == "function" && i(), n = [];
      }, animate: function(i, a, l, u) {
        if (u) {
          S(i, "transition", ""), S(i, "transform", "");
          var c = Ue(this.el), f = c && c.a, p = c && c.d, v = (a.left - l.left) / (f || 1), g = (a.top - l.top) / (p || 1);
          i.animatingX = !!v, i.animatingY = !!g, S(i, "transform", "translate3d(" + v + "px," + g + "px,0)"), this.forRepaintDummy = Or(i), S(i, "transition", "transform " + u + "ms" + (this.options.easing ? " " + this.options.easing : "")), S(i, "transform", "translate3d(0,0,0)"), typeof i.animated == "number" && clearTimeout(i.animated), i.animated = setTimeout(function() {
            S(i, "transition", ""), S(i, "transform", ""), i.animated = false, i.animatingX = false, i.animatingY = false;
          }, u);
        }
      } };
    }
    function Or(n) {
      return n.offsetWidth;
    }
    function Fr(n, t, e, i) {
      return Math.sqrt(Math.pow(t.top - n.top, 2) + Math.pow(t.left - n.left, 2)) / Math.sqrt(Math.pow(t.top - e.top, 2) + Math.pow(t.left - e.left, 2)) * i.animation;
    }
    var Ke = [], fn = { initializeByDefault: true }, dt = { mount: function(t) {
      for (var e in fn)
        fn.hasOwnProperty(e) && !(e in t) && (t[e] = fn[e]);
      Ke.forEach(function(i) {
        if (i.pluginName === t.pluginName)
          throw "Sortable: Cannot mount plugin ".concat(t.pluginName, " more than once");
      }), Ke.push(t);
    }, pluginEvent: function(t, e, i) {
      var a = this;
      this.eventCanceled = false, i.cancel = function() {
        a.eventCanceled = true;
      };
      var l = t + "Global";
      Ke.forEach(function(u) {
        e[u.pluginName] && (e[u.pluginName][l] && e[u.pluginName][l](Se({ sortable: e }, i)), e.options[u.pluginName] && e[u.pluginName][t] && e[u.pluginName][t](Se({ sortable: e }, i)));
      });
    }, initializePlugins: function(t, e, i, a) {
      Ke.forEach(function(c) {
        var f = c.pluginName;
        if (!(!t.options[f] && !c.initializeByDefault)) {
          var p = new c(t, e, t.options);
          p.sortable = t, p.options = t.options, t[f] = p, Te(i, p.defaults);
        }
      });
      for (var l in t.options)
        if (t.options.hasOwnProperty(l)) {
          var u = this.modifyOption(t, l, t.options[l]);
          typeof u < "u" && (t.options[l] = u);
        }
    }, getEventProperties: function(t, e) {
      var i = {};
      return Ke.forEach(function(a) {
        typeof a.eventProperties == "function" && Te(i, a.eventProperties.call(e[a.pluginName], t));
      }), i;
    }, modifyOption: function(t, e, i) {
      var a;
      return Ke.forEach(function(l) {
        t[l.pluginName] && l.optionListeners && typeof l.optionListeners[e] == "function" && (a = l.optionListeners[e].call(t[l.pluginName], i));
      }), a;
    } };
    function kr(n) {
      var t = n.sortable, e = n.rootEl, i = n.name, a = n.targetEl, l = n.cloneEl, u = n.toEl, c = n.fromEl, f = n.oldIndex, p = n.newIndex, v = n.oldDraggableIndex, g = n.newDraggableIndex, E = n.originalEvent, _ = n.putSortable, I = n.extraEventProperties;
      if (t = t || e && e[pe], !!t) {
        var y, B = t.options, J = "on" + i.charAt(0).toUpperCase() + i.substr(1);
        window.CustomEvent && !Ie && !ct ? y = new CustomEvent(i, { bubbles: true, cancelable: true }) : (y = document.createEvent("Event"), y.initEvent(i, true, true)), y.to = u || e, y.from = c || e, y.item = a || e, y.clone = l, y.oldIndex = f, y.newIndex = p, y.oldDraggableIndex = v, y.newDraggableIndex = g, y.originalEvent = E, y.pullMode = _ ? _.lastPutMode : void 0;
        var P = Se(Se({}, I), dt.getEventProperties(i, t));
        for (var q in P)
          y[q] = P[q];
        e && e.dispatchEvent(y), B[J] && B[J].call(t, y);
      }
    }
    var Nr = ["evt"], oe = function(t, e) {
      var i = arguments.length > 2 && arguments[2] !== void 0 ? arguments[2] : {}, a = i.evt, l = Cr(i, Nr);
      dt.pluginEvent.bind(C)(t, e, Se({ dragEl: m, parentEl: z, ghostEl: x, rootEl: H, nextEl: Re, lastDownEl: Ft, cloneEl: R, cloneHidden: Ne, dragStarted: nt, putSortable: Z, activeSortable: C.active, originalEvent: a, oldIndex: $e, oldDraggableIndex: lt, newIndex: fe, newDraggableIndex: ke, hideGhostForTarget: bi, unhideGhostForTarget: yi, cloneNowHidden: function() {
        Ne = true;
      }, cloneNowShown: function() {
        Ne = false;
      }, dispatchSortableEvent: function(c) {
        ae({ sortable: e, name: c, originalEvent: a });
      } }, l));
    };
    function ae(n) {
      kr(Se({ putSortable: Z, cloneEl: R, targetEl: m, rootEl: H, oldIndex: $e, oldDraggableIndex: lt, newIndex: fe, newDraggableIndex: ke }, n));
    }
    var m, z, x, H, Re, Ft, R, Ne, $e, fe, lt, ke, xt, Z, Ge = false, Ht = false, Yt = [], Ye, ge, pn, hn, ri, ai, nt, Xe, st, ut = false, Tt = false, kt, ee, mn = [], Dn = false, jt = [], Bt = typeof document < "u", It = si, oi = ct || Ie ? "cssFloat" : "float", Pr = Bt && !ui && !si && "draggable" in document.createElement("div"), mi = function() {
      if (Bt) {
        if (Ie)
          return false;
        var n = document.createElement("x");
        return n.style.cssText = "pointer-events:auto", n.style.pointerEvents === "auto";
      }
    }(), gi = function(t, e) {
      var i = S(t), a = parseInt(i.width) - parseInt(i.paddingLeft) - parseInt(i.paddingRight) - parseInt(i.borderLeftWidth) - parseInt(i.borderRightWidth), l = Je(t, 0, e), u = Je(t, 1, e), c = l && S(l), f = u && S(u), p = c && parseInt(c.marginLeft) + parseInt(c.marginRight) + U(l).width, v = f && parseInt(f.marginLeft) + parseInt(f.marginRight) + U(u).width;
      if (i.display === "flex")
        return i.flexDirection === "column" || i.flexDirection === "column-reverse" ? "vertical" : "horizontal";
      if (i.display === "grid")
        return i.gridTemplateColumns.split(" ").length <= 1 ? "vertical" : "horizontal";
      if (l && c.float && c.float !== "none") {
        var g = c.float === "left" ? "left" : "right";
        return u && (f.clear === "both" || f.clear === g) ? "vertical" : "horizontal";
      }
      return l && (c.display === "block" || c.display === "flex" || c.display === "table" || c.display === "grid" || p >= a && i[oi] === "none" || u && i[oi] === "none" && p + v > a) ? "vertical" : "horizontal";
    }, Lr = function(t, e, i) {
      var a = i ? t.left : t.top, l = i ? t.right : t.bottom, u = i ? t.width : t.height, c = i ? e.left : e.top, f = i ? e.right : e.bottom, p = i ? e.width : e.height;
      return a === c || l === f || a + u / 2 === c + p / 2;
    }, Hr = function(t, e) {
      var i;
      return Yt.some(function(a) {
        var l = a[pe].options.emptyInsertThreshold;
        if (!(!l || Cn(a))) {
          var u = U(a), c = t >= u.left - l && t <= u.right + l, f = e >= u.top - l && e <= u.bottom + l;
          if (c && f)
            return i = a;
        }
      }), i;
    }, vi = function(t) {
      function e(l, u) {
        return function(c, f, p, v) {
          var g = c.options.group.name && f.options.group.name && c.options.group.name === f.options.group.name;
          if (l == null && (u || g))
            return true;
          if (l == null || l === false)
            return false;
          if (u && l === "clone")
            return l;
          if (typeof l == "function")
            return e(l(c, f, p, v), u)(c, f, p, v);
          var E = (u ? c : f).options.group.name;
          return l === true || typeof l == "string" && l === E || l.join && l.indexOf(E) > -1;
        };
      }
      var i = {}, a = t.group;
      (!a || Ot(a) != "object") && (a = { name: a }), i.name = a.name, i.checkPull = e(a.pull, true), i.checkPut = e(a.put), i.revertClone = a.revertClone, t.group = i;
    }, bi = function() {
      !mi && x && S(x, "display", "none");
    }, yi = function() {
      !mi && x && S(x, "display", "");
    };
    Bt && !ui && document.addEventListener("click", function(n) {
      if (Ht)
        return n.preventDefault(), n.stopPropagation && n.stopPropagation(), n.stopImmediatePropagation && n.stopImmediatePropagation(), Ht = false, false;
    }, true);
    var je = function(t) {
      if (m) {
        t = t.touches ? t.touches[0] : t;
        var e = Hr(t.clientX, t.clientY);
        if (e) {
          var i = {};
          for (var a in t)
            t.hasOwnProperty(a) && (i[a] = t[a]);
          i.target = i.rootEl = e, i.preventDefault = void 0, i.stopPropagation = void 0, e[pe]._onDragOver(i);
        }
      }
    }, Yr = function(t) {
      m && m.parentNode[pe]._isOutsideThisEl(t.target);
    };
    function C(n, t) {
      if (!(n && n.nodeType && n.nodeType === 1))
        throw "Sortable: `el` must be an HTMLElement, not ".concat({}.toString.call(n));
      this.el = n, this.options = t = Te({}, t), n[pe] = this;
      var e = { group: null, sort: true, disabled: false, store: null, handle: null, draggable: /^[uo]l$/i.test(n.nodeName) ? ">li" : ">*", swapThreshold: 1, invertSwap: false, invertedSwapThreshold: null, removeCloneOnHide: true, direction: function() {
        return gi(n, this.options);
      }, ghostClass: "sortable-ghost", chosenClass: "sortable-chosen", dragClass: "sortable-drag", ignore: "a, img", filter: null, preventOnFilter: true, animation: 0, easing: null, setData: function(u, c) {
        u.setData("Text", c.textContent);
      }, dropBubble: false, dragoverBubble: false, dataIdAttr: "data-id", delay: 0, delayOnTouchOnly: false, touchStartThreshold: (Number.parseInt ? Number : window).parseInt(window.devicePixelRatio, 10) || 1, forceFallback: false, fallbackClass: "sortable-fallback", fallbackOnBody: false, fallbackTolerance: 0, fallbackOffset: { x: 0, y: 0 }, supportPointer: C.supportPointer !== false && "PointerEvent" in window && !at, emptyInsertThreshold: 5 };
      dt.initializePlugins(this, n, e);
      for (var i in e)
        !(i in t) && (t[i] = e[i]);
      vi(t);
      for (var a in this)
        a.charAt(0) === "_" && typeof this[a] == "function" && (this[a] = this[a].bind(this));
      this.nativeDraggable = t.forceFallback ? false : Pr, this.nativeDraggable && (this.options.touchStartThreshold = 1), t.supportPointer ? N(n, "pointerdown", this._onTapStart) : (N(n, "mousedown", this._onTapStart), N(n, "touchstart", this._onTapStart)), this.nativeDraggable && (N(n, "dragover", this), N(n, "dragenter", this)), Yt.push(this.el), t.store && t.store.get && this.sort(t.store.get(this) || []), Te(this, Ar());
    }
    C.prototype = { constructor: C, _isOutsideThisEl: function(t) {
      !this.el.contains(t) && t !== this.el && (Xe = null);
    }, _getDirection: function(t, e) {
      return typeof this.options.direction == "function" ? this.options.direction.call(this, t, e, m) : this.options.direction;
    }, _onTapStart: function(t) {
      if (t.cancelable) {
        var e = this, i = this.el, a = this.options, l = a.preventOnFilter, u = t.type, c = t.touches && t.touches[0] || t.pointerType && t.pointerType === "touch" && t, f = (c || t).target, p = t.target.shadowRoot && (t.path && t.path[0] || t.composedPath && t.composedPath()[0]) || f, v = a.filter;
        if (Xr(i), !m && !(/mousedown|pointerdown/.test(u) && t.button !== 0 || a.disabled) && !p.isContentEditable && !(!this.nativeDraggable && at && f && f.tagName.toUpperCase() === "SELECT") && (f = we(f, a.draggable, i, false), !(f && f.animated) && Ft !== f)) {
          if ($e = he(f), lt = he(f, a.draggable), typeof v == "function") {
            if (v.call(this, t, f, this)) {
              ae({ sortable: e, rootEl: p, name: "filter", targetEl: f, toEl: i, fromEl: i }), oe("filter", e, { evt: t }), l && t.cancelable && t.preventDefault();
              return;
            }
          } else if (v && (v = v.split(",").some(function(g) {
            if (g = we(p, g.trim(), i, false), g)
              return ae({ sortable: e, rootEl: g, name: "filter", targetEl: f, fromEl: i, toEl: i }), oe("filter", e, { evt: t }), true;
          }), v)) {
            l && t.cancelable && t.preventDefault();
            return;
          }
          a.handle && !we(p, a.handle, i, false) || this._prepareDragStart(t, c, f);
        }
      }
    }, _prepareDragStart: function(t, e, i) {
      var a = this, l = a.el, u = a.options, c = l.ownerDocument, f;
      if (i && !m && i.parentNode === l) {
        var p = U(i);
        if (H = l, m = i, z = m.parentNode, Re = m.nextSibling, Ft = i, xt = u.group, C.dragged = m, Ye = { target: m, clientX: (e || t).clientX, clientY: (e || t).clientY }, ri = Ye.clientX - p.left, ai = Ye.clientY - p.top, this._lastX = (e || t).clientX, this._lastY = (e || t).clientY, m.style["will-change"] = "all", f = function() {
          if (oe("delayEnded", a, { evt: t }), C.eventCanceled) {
            a._onDrop();
            return;
          }
          a._disableDelayedDragEvents(), !ei && a.nativeDraggable && (m.draggable = true), a._triggerDragStart(t, e), ae({ sortable: a, name: "choose", originalEvent: t }), de(m, u.chosenClass, true);
        }, u.ignore.split(",").forEach(function(v) {
          di(m, v.trim(), gn);
        }), N(c, "dragover", je), N(c, "mousemove", je), N(c, "touchmove", je), N(c, "mouseup", a._onDrop), N(c, "touchend", a._onDrop), N(c, "touchcancel", a._onDrop), ei && this.nativeDraggable && (this.options.touchStartThreshold = 4, m.draggable = true), oe("delayStart", this, { evt: t }), u.delay && (!u.delayOnTouchOnly || e) && (!this.nativeDraggable || !(ct || Ie))) {
          if (C.eventCanceled) {
            this._onDrop();
            return;
          }
          N(c, "mouseup", a._disableDelayedDrag), N(c, "touchend", a._disableDelayedDrag), N(c, "touchcancel", a._disableDelayedDrag), N(c, "mousemove", a._delayedDragTouchMoveHandler), N(c, "touchmove", a._delayedDragTouchMoveHandler), u.supportPointer && N(c, "pointermove", a._delayedDragTouchMoveHandler), a._dragStartTimer = setTimeout(f, u.delay);
        } else
          f();
      }
    }, _delayedDragTouchMoveHandler: function(t) {
      var e = t.touches ? t.touches[0] : t;
      Math.max(Math.abs(e.clientX - this._lastX), Math.abs(e.clientY - this._lastY)) >= Math.floor(this.options.touchStartThreshold / (this.nativeDraggable && window.devicePixelRatio || 1)) && this._disableDelayedDrag();
    }, _disableDelayedDrag: function() {
      m && gn(m), clearTimeout(this._dragStartTimer), this._disableDelayedDragEvents();
    }, _disableDelayedDragEvents: function() {
      var t = this.el.ownerDocument;
      F(t, "mouseup", this._disableDelayedDrag), F(t, "touchend", this._disableDelayedDrag), F(t, "touchcancel", this._disableDelayedDrag), F(t, "mousemove", this._delayedDragTouchMoveHandler), F(t, "touchmove", this._delayedDragTouchMoveHandler), F(t, "pointermove", this._delayedDragTouchMoveHandler);
    }, _triggerDragStart: function(t, e) {
      e = e || t.pointerType == "touch" && t, !this.nativeDraggable || e ? this.options.supportPointer ? N(document, "pointermove", this._onTouchMove) : e ? N(document, "touchmove", this._onTouchMove) : N(document, "mousemove", this._onTouchMove) : (N(m, "dragend", this), N(H, "dragstart", this._onDragStart));
      try {
        document.selection ? Nt(function() {
          document.selection.empty();
        }) : window.getSelection().removeAllRanges();
      } catch {
      }
    }, _dragStarted: function(t, e) {
      if (Ge = false, H && m) {
        oe("dragStarted", this, { evt: e }), this.nativeDraggable && N(document, "dragover", Yr);
        var i = this.options;
        !t && de(m, i.dragClass, false), de(m, i.ghostClass, true), C.active = this, t && this._appendGhost(), ae({ sortable: this, name: "start", originalEvent: e });
      } else
        this._nulling();
    }, _emulateDragOver: function() {
      if (ge) {
        this._lastX = ge.clientX, this._lastY = ge.clientY, bi();
        for (var t = document.elementFromPoint(ge.clientX, ge.clientY), e = t; t && t.shadowRoot && (t = t.shadowRoot.elementFromPoint(ge.clientX, ge.clientY), t !== e); )
          e = t;
        if (m.parentNode[pe]._isOutsideThisEl(t), e)
          do {
            if (e[pe]) {
              var i = void 0;
              if (i = e[pe]._onDragOver({ clientX: ge.clientX, clientY: ge.clientY, target: t, rootEl: e }), i && !this.options.dragoverBubble)
                break;
            }
            t = e;
          } while (e = e.parentNode);
        yi();
      }
    }, _onTouchMove: function(t) {
      if (Ye) {
        var e = this.options, i = e.fallbackTolerance, a = e.fallbackOffset, l = t.touches ? t.touches[0] : t, u = x && Ue(x, true), c = x && u && u.a, f = x && u && u.d, p = It && ee && ii(ee), v = (l.clientX - Ye.clientX + a.x) / (c || 1) + (p ? p[0] - mn[0] : 0) / (c || 1), g = (l.clientY - Ye.clientY + a.y) / (f || 1) + (p ? p[1] - mn[1] : 0) / (f || 1);
        if (!C.active && !Ge) {
          if (i && Math.max(Math.abs(l.clientX - this._lastX), Math.abs(l.clientY - this._lastY)) < i)
            return;
          this._onDragStart(t, true);
        }
        if (x) {
          u ? (u.e += v - (pn || 0), u.f += g - (hn || 0)) : u = { a: 1, b: 0, c: 0, d: 1, e: v, f: g };
          var E = "matrix(".concat(u.a, ",").concat(u.b, ",").concat(u.c, ",").concat(u.d, ",").concat(u.e, ",").concat(u.f, ")");
          S(x, "webkitTransform", E), S(x, "mozTransform", E), S(x, "msTransform", E), S(x, "transform", E), pn = v, hn = g, ge = l;
        }
        t.cancelable && t.preventDefault();
      }
    }, _appendGhost: function() {
      if (!x) {
        var t = this.options.fallbackOnBody ? document.body : H, e = U(m, true, It, true, t), i = this.options;
        if (It) {
          for (ee = t; S(ee, "position") === "static" && S(ee, "transform") === "none" && ee !== document; )
            ee = ee.parentNode;
          ee !== document.body && ee !== document.documentElement ? (ee === document && (ee = Ee()), e.top += ee.scrollTop, e.left += ee.scrollLeft) : ee = Ee(), mn = ii(ee);
        }
        x = m.cloneNode(true), de(x, i.ghostClass, false), de(x, i.fallbackClass, true), de(x, i.dragClass, true), S(x, "transition", ""), S(x, "transform", ""), S(x, "box-sizing", "border-box"), S(x, "margin", 0), S(x, "top", e.top), S(x, "left", e.left), S(x, "width", e.width), S(x, "height", e.height), S(x, "opacity", "0.8"), S(x, "position", It ? "absolute" : "fixed"), S(x, "zIndex", "100000"), S(x, "pointerEvents", "none"), C.ghost = x, t.appendChild(x), S(x, "transform-origin", ri / parseInt(x.style.width) * 100 + "% " + ai / parseInt(x.style.height) * 100 + "%");
      }
    }, _onDragStart: function(t, e) {
      var i = this, a = t.dataTransfer, l = i.options;
      if (oe("dragStart", this, { evt: t }), C.eventCanceled) {
        this._onDrop();
        return;
      }
      oe("setupClone", this), C.eventCanceled || (R = hi(m), R.removeAttribute("id"), R.draggable = false, R.style["will-change"] = "", this._hideClone(), de(R, this.options.chosenClass, false), C.clone = R), i.cloneId = Nt(function() {
        oe("clone", i), !C.eventCanceled && (i.options.removeCloneOnHide || H.insertBefore(R, m), i._hideClone(), ae({ sortable: i, name: "clone" }));
      }), !e && de(m, l.dragClass, true), e ? (Ht = true, i._loopId = setInterval(i._emulateDragOver, 50)) : (F(document, "mouseup", i._onDrop), F(document, "touchend", i._onDrop), F(document, "touchcancel", i._onDrop), a && (a.effectAllowed = "move", l.setData && l.setData.call(i, a, m)), N(document, "drop", i), S(m, "transform", "translateZ(0)")), Ge = true, i._dragStartId = Nt(i._dragStarted.bind(i, e, t)), N(document, "selectstart", i), nt = true, at && S(document.body, "user-select", "none");
    }, _onDragOver: function(t) {
      var e = this.el, i = t.target, a, l, u, c = this.options, f = c.group, p = C.active, v = xt === f, g = c.sort, E = Z || p, _, I = this, y = false;
      if (Dn)
        return;
      function B(Fe, Dt) {
        oe(Fe, I, Se({ evt: t, isOwner: v, axis: _ ? "vertical" : "horizontal", revert: u, dragRect: a, targetRect: l, canSort: g, fromSortable: E, target: i, completed: P, onMove: function(ze, nn) {
          return At(H, e, m, a, ze, U(ze), t, nn);
        }, changed: q }, Dt));
      }
      function J() {
        B("dragOverAnimationCapture"), I.captureAnimationState(), I !== E && E.captureAnimationState();
      }
      function P(Fe) {
        return B("dragOverCompleted", { insertion: Fe }), Fe && (v ? p._hideClone() : p._showClone(I), I !== E && (de(m, Z ? Z.options.ghostClass : p.options.ghostClass, false), de(m, c.ghostClass, true)), Z !== I && I !== C.active ? Z = I : I === C.active && Z && (Z = null), E === I && (I._ignoreWhileAnimating = i), I.animateAll(function() {
          B("dragOverAnimationComplete"), I._ignoreWhileAnimating = null;
        }), I !== E && (E.animateAll(), E._ignoreWhileAnimating = null)), (i === m && !m.animated || i === e && !i.animated) && (Xe = null), !c.dragoverBubble && !t.rootEl && i !== document && (m.parentNode[pe]._isOutsideThisEl(t.target), !Fe && je(t)), !c.dragoverBubble && t.stopPropagation && t.stopPropagation(), y = true;
      }
      function q() {
        fe = he(m), ke = he(m, c.draggable), ae({ sortable: I, name: "change", toEl: e, newIndex: fe, newDraggableIndex: ke, originalEvent: t });
      }
      if (t.preventDefault !== void 0 && t.cancelable && t.preventDefault(), i = we(i, c.draggable, e, true), B("dragOver"), C.eventCanceled)
        return y;
      if (m.contains(t.target) || i.animated && i.animatingX && i.animatingY || I._ignoreWhileAnimating === i)
        return P(false);
      if (Ht = false, p && !c.disabled && (v ? g || (u = z !== H) : Z === this || (this.lastPutMode = xt.checkPull(this, p, m, t)) && f.checkPut(this, p, m, t))) {
        if (_ = this._getDirection(t, i) === "vertical", a = U(m), B("dragOverValid"), C.eventCanceled)
          return y;
        if (u)
          return z = H, J(), this._hideClone(), B("revert"), C.eventCanceled || (Re ? H.insertBefore(m, Re) : H.appendChild(m)), P(true);
        var W = Cn(e, c.draggable);
        if (!W || Wr(t, _, this) && !W.animated) {
          if (W === m)
            return P(false);
          if (W && e === t.target && (i = W), i && (l = U(i)), At(H, e, m, a, i, l, t, !!i) !== false)
            return J(), W && W.nextSibling ? e.insertBefore(m, W.nextSibling) : e.appendChild(m), z = e, q(), P(true);
        } else if (W && Br(t, _, this)) {
          var re = Je(e, 0, c, true);
          if (re === m)
            return P(false);
          if (i = re, l = U(i), At(H, e, m, a, i, l, t, false) !== false)
            return J(), e.insertBefore(m, re), z = e, q(), P(true);
        } else if (i.parentNode === e) {
          l = U(i);
          var A = 0, Y, V = m.parentNode !== e, K = !Lr(m.animated && m.toRect || a, i.animated && i.toRect || l, _), me = _ ? "top" : "left", ve = ni(i, "top", "top") || ni(m, "top", "top"), be = ve ? ve.scrollTop : void 0;
          Xe !== i && (Y = l[me], ut = false, Tt = !K && c.invertSwap || V), A = zr(t, i, l, _, K ? 1 : c.swapThreshold, c.invertedSwapThreshold == null ? c.swapThreshold : c.invertedSwapThreshold, Tt, Xe === i);
          var Q;
          if (A !== 0) {
            var Me = he(m);
            do
              Me -= A, Q = z.children[Me];
            while (Q && (S(Q, "display") === "none" || Q === x));
          }
          if (A === 0 || Q === i)
            return P(false);
          Xe = i, st = A;
          var Oe = i.nextElementSibling, ye = false;
          ye = A === 1;
          var We = At(H, e, m, a, i, l, t, ye);
          if (We !== false)
            return (We === 1 || We === -1) && (ye = We === 1), Dn = true, setTimeout(Rr, 30), J(), ye && !Oe ? e.appendChild(m) : i.parentNode.insertBefore(m, ye ? Oe : i), ve && pi(ve, 0, be - ve.scrollTop), z = m.parentNode, Y !== void 0 && !Tt && (kt = Math.abs(Y - U(i)[me])), q(), P(true);
        }
        if (e.contains(m))
          return P(false);
      }
      return false;
    }, _ignoreWhileAnimating: null, _offMoveEvents: function() {
      F(document, "mousemove", this._onTouchMove), F(document, "touchmove", this._onTouchMove), F(document, "pointermove", this._onTouchMove), F(document, "dragover", je), F(document, "mousemove", je), F(document, "touchmove", je);
    }, _offUpEvents: function() {
      var t = this.el.ownerDocument;
      F(t, "mouseup", this._onDrop), F(t, "touchend", this._onDrop), F(t, "pointerup", this._onDrop), F(t, "touchcancel", this._onDrop), F(document, "selectstart", this);
    }, _onDrop: function(t) {
      var e = this.el, i = this.options;
      if (fe = he(m), ke = he(m, i.draggable), oe("drop", this, { evt: t }), z = m && m.parentNode, fe = he(m), ke = he(m, i.draggable), C.eventCanceled) {
        this._nulling();
        return;
      }
      Ge = false, Tt = false, ut = false, clearInterval(this._loopId), clearTimeout(this._dragStartTimer), wn(this.cloneId), wn(this._dragStartId), this.nativeDraggable && (F(document, "drop", this), F(e, "dragstart", this._onDragStart)), this._offMoveEvents(), this._offUpEvents(), at && S(document.body, "user-select", ""), S(m, "transform", ""), t && (nt && (t.cancelable && t.preventDefault(), !i.dropBubble && t.stopPropagation()), x && x.parentNode && x.parentNode.removeChild(x), (H === z || Z && Z.lastPutMode !== "clone") && R && R.parentNode && R.parentNode.removeChild(R), m && (this.nativeDraggable && F(m, "dragend", this), gn(m), m.style["will-change"] = "", nt && !Ge && de(m, Z ? Z.options.ghostClass : this.options.ghostClass, false), de(m, this.options.chosenClass, false), ae({ sortable: this, name: "unchoose", toEl: z, newIndex: null, newDraggableIndex: null, originalEvent: t }), H !== z ? (fe >= 0 && (ae({ rootEl: z, name: "add", toEl: z, fromEl: H, originalEvent: t }), ae({ sortable: this, name: "remove", toEl: z, originalEvent: t }), ae({ rootEl: z, name: "sort", toEl: z, fromEl: H, originalEvent: t }), ae({ sortable: this, name: "sort", toEl: z, originalEvent: t })), Z && Z.save()) : fe !== $e && fe >= 0 && (ae({ sortable: this, name: "update", toEl: z, originalEvent: t }), ae({ sortable: this, name: "sort", toEl: z, originalEvent: t })), C.active && ((fe == null || fe === -1) && (fe = $e, ke = lt), ae({ sortable: this, name: "end", toEl: z, originalEvent: t }), this.save()))), this._nulling();
    }, _nulling: function() {
      oe("nulling", this), H = m = z = x = Re = R = Ft = Ne = Ye = ge = nt = fe = ke = $e = lt = Xe = st = Z = xt = C.dragged = C.ghost = C.clone = C.active = null, jt.forEach(function(t) {
        t.checked = true;
      }), jt.length = pn = hn = 0;
    }, handleEvent: function(t) {
      switch (t.type) {
        case "drop":
        case "dragend":
          this._onDrop(t);
          break;
        case "dragenter":
        case "dragover":
          m && (this._onDragOver(t), jr(t));
          break;
        case "selectstart":
          t.preventDefault();
          break;
      }
    }, toArray: function() {
      for (var t = [], e, i = this.el.children, a = 0, l = i.length, u = this.options; a < l; a++)
        e = i[a], we(e, u.draggable, this.el, false) && t.push(e.getAttribute(u.dataIdAttr) || Kr(e));
      return t;
    }, sort: function(t, e) {
      var i = {}, a = this.el;
      this.toArray().forEach(function(l, u) {
        var c = a.children[u];
        we(c, this.options.draggable, a, false) && (i[l] = c);
      }, this), e && this.captureAnimationState(), t.forEach(function(l) {
        i[l] && (a.removeChild(i[l]), a.appendChild(i[l]));
      }), e && this.animateAll();
    }, save: function() {
      var t = this.options.store;
      t && t.set && t.set(this);
    }, closest: function(t, e) {
      return we(t, e || this.options.draggable, this.el, false);
    }, option: function(t, e) {
      var i = this.options;
      if (e === void 0)
        return i[t];
      var a = dt.modifyOption(this, t, e);
      typeof a < "u" ? i[t] = a : i[t] = e, t === "group" && vi(i);
    }, destroy: function() {
      oe("destroy", this);
      var t = this.el;
      t[pe] = null, F(t, "mousedown", this._onTapStart), F(t, "touchstart", this._onTapStart), F(t, "pointerdown", this._onTapStart), this.nativeDraggable && (F(t, "dragover", this), F(t, "dragenter", this)), Array.prototype.forEach.call(t.querySelectorAll("[draggable]"), function(e) {
        e.removeAttribute("draggable");
      }), this._onDrop(), this._disableDelayedDragEvents(), Yt.splice(Yt.indexOf(this.el), 1), this.el = t = null;
    }, _hideClone: function() {
      if (!Ne) {
        if (oe("hideClone", this), C.eventCanceled)
          return;
        S(R, "display", "none"), this.options.removeCloneOnHide && R.parentNode && R.parentNode.removeChild(R), Ne = true;
      }
    }, _showClone: function(t) {
      if (t.lastPutMode !== "clone") {
        this._hideClone();
        return;
      }
      if (Ne) {
        if (oe("showClone", this), C.eventCanceled)
          return;
        m.parentNode == H && !this.options.group.revertClone ? H.insertBefore(R, m) : Re ? H.insertBefore(R, Re) : H.appendChild(R), this.options.group.revertClone && this.animate(m, R), S(R, "display", ""), Ne = false;
      }
    } };
    function jr(n) {
      n.dataTransfer && (n.dataTransfer.dropEffect = "move"), n.cancelable && n.preventDefault();
    }
    function At(n, t, e, i, a, l, u, c) {
      var f, p = n[pe], v = p.options.onMove, g;
      return window.CustomEvent && !Ie && !ct ? f = new CustomEvent("move", { bubbles: true, cancelable: true }) : (f = document.createEvent("Event"), f.initEvent("move", true, true)), f.to = t, f.from = n, f.dragged = e, f.draggedRect = i, f.related = a || t, f.relatedRect = l || U(t), f.willInsertAfter = c, f.originalEvent = u, n.dispatchEvent(f), v && (g = v.call(p, f, u)), g;
    }
    function gn(n) {
      n.draggable = false;
    }
    function Rr() {
      Dn = false;
    }
    function Br(n, t, e) {
      var i = U(Je(e.el, 0, e.options, true)), a = 10;
      return t ? n.clientX < i.left - a || n.clientY < i.top && n.clientX < i.right : n.clientY < i.top - a || n.clientY < i.bottom && n.clientX < i.left;
    }
    function Wr(n, t, e) {
      var i = U(Cn(e.el, e.options.draggable)), a = 10;
      return t ? n.clientX > i.right + a || n.clientX <= i.right && n.clientY > i.bottom && n.clientX >= i.left : n.clientX > i.right && n.clientY > i.top || n.clientX <= i.right && n.clientY > i.bottom + a;
    }
    function zr(n, t, e, i, a, l, u, c) {
      var f = i ? n.clientY : n.clientX, p = i ? e.height : e.width, v = i ? e.top : e.left, g = i ? e.bottom : e.right, E = false;
      if (!u) {
        if (c && kt < p * a) {
          if (!ut && (st === 1 ? f > v + p * l / 2 : f < g - p * l / 2) && (ut = true), ut)
            E = true;
          else if (st === 1 ? f < v + kt : f > g - kt)
            return -st;
        } else if (f > v + p * (1 - a) / 2 && f < g - p * (1 - a) / 2)
          return qr(t);
      }
      return E = E || u, E && (f < v + p * l / 2 || f > g - p * l / 2) ? f > v + p / 2 ? 1 : -1 : 0;
    }
    function qr(n) {
      return he(m) < he(n) ? 1 : -1;
    }
    function Kr(n) {
      for (var t = n.tagName + n.className + n.src + n.href + n.textContent, e = t.length, i = 0; e--; )
        i += t.charCodeAt(e);
      return i.toString(36);
    }
    function Xr(n) {
      jt.length = 0;
      for (var t = n.getElementsByTagName("input"), e = t.length; e--; ) {
        var i = t[e];
        i.checked && jt.push(i);
      }
    }
    function Nt(n) {
      return setTimeout(n, 0);
    }
    function wn(n) {
      return clearTimeout(n);
    }
    Bt && N(document, "touchmove", function(n) {
      (C.active || Ge) && n.cancelable && n.preventDefault();
    });
    C.utils = { on: N, off: F, css: S, find: di, is: function(t, e) {
      return !!we(t, e, t, false);
    }, extend: Tr, throttle: fi, closest: we, toggleClass: de, clone: hi, index: he, nextTick: Nt, cancelNextTick: wn, detectDirection: gi, getChild: Je };
    C.get = function(n) {
      return n[pe];
    };
    C.mount = function() {
      for (var n = arguments.length, t = new Array(n), e = 0; e < n; e++)
        t[e] = arguments[e];
      t[0].constructor === Array && (t = t[0]), t.forEach(function(i) {
        if (!i.prototype || !i.prototype.constructor)
          throw "Sortable: Mounted plugin must be a constructor function, not ".concat({}.toString.call(i));
        i.utils && (C.utils = Se(Se({}, C.utils), i.utils)), dt.mount(i);
      });
    };
    C.create = function(n, t) {
      return new C(n, t);
    };
    C.version = Mr;
    var X = [], it, En, Sn = false, vn, bn, Rt, rt;
    function Gr() {
      function n() {
        this.defaults = { scroll: true, forceAutoScrollFallback: false, scrollSensitivity: 30, scrollSpeed: 10, bubbleScroll: true };
        for (var t in this)
          t.charAt(0) === "_" && typeof this[t] == "function" && (this[t] = this[t].bind(this));
      }
      return n.prototype = { dragStarted: function(e) {
        var i = e.originalEvent;
        this.sortable.nativeDraggable ? N(document, "dragover", this._handleAutoScroll) : this.options.supportPointer ? N(document, "pointermove", this._handleFallbackAutoScroll) : i.touches ? N(document, "touchmove", this._handleFallbackAutoScroll) : N(document, "mousemove", this._handleFallbackAutoScroll);
      }, dragOverCompleted: function(e) {
        var i = e.originalEvent;
        !this.options.dragOverBubble && !i.rootEl && this._handleAutoScroll(i);
      }, drop: function() {
        this.sortable.nativeDraggable ? F(document, "dragover", this._handleAutoScroll) : (F(document, "pointermove", this._handleFallbackAutoScroll), F(document, "touchmove", this._handleFallbackAutoScroll), F(document, "mousemove", this._handleFallbackAutoScroll)), li(), Pt(), Ir();
      }, nulling: function() {
        Rt = En = it = Sn = rt = vn = bn = null, X.length = 0;
      }, _handleFallbackAutoScroll: function(e) {
        this._handleAutoScroll(e, true);
      }, _handleAutoScroll: function(e, i) {
        var a = this, l = (e.touches ? e.touches[0] : e).clientX, u = (e.touches ? e.touches[0] : e).clientY, c = document.elementFromPoint(l, u);
        if (Rt = e, i || this.options.forceAutoScrollFallback || ct || Ie || at) {
          yn(e, this.options, c, i);
          var f = Pe(c, true);
          Sn && (!rt || l !== vn || u !== bn) && (rt && li(), rt = setInterval(function() {
            var p = Pe(document.elementFromPoint(l, u), true);
            p !== f && (f = p, Pt()), yn(e, a.options, p, i);
          }, 10), vn = l, bn = u);
        } else {
          if (!this.options.bubbleScroll || Pe(c, true) === Ee()) {
            Pt();
            return;
          }
          yn(e, this.options, Pe(c, false), false);
        }
      } }, Te(n, { pluginName: "scroll", initializeByDefault: true });
    }
    function Pt() {
      X.forEach(function(n) {
        clearInterval(n.pid);
      }), X = [];
    }
    function li() {
      clearInterval(rt);
    }
    var yn = fi(function(n, t, e, i) {
      if (t.scroll) {
        var a = (n.touches ? n.touches[0] : n).clientX, l = (n.touches ? n.touches[0] : n).clientY, u = t.scrollSensitivity, c = t.scrollSpeed, f = Ee(), p = false, v;
        En !== e && (En = e, Pt(), it = t.scroll, v = t.scrollFn, it === true && (it = Pe(e, true)));
        var g = 0, E = it;
        do {
          var _ = E, I = U(_), y = I.top, B = I.bottom, J = I.left, P = I.right, q = I.width, W = I.height, re = void 0, A = void 0, Y = _.scrollWidth, V = _.scrollHeight, K = S(_), me = _.scrollLeft, ve = _.scrollTop;
          _ === f ? (re = q < Y && (K.overflowX === "auto" || K.overflowX === "scroll" || K.overflowX === "visible"), A = W < V && (K.overflowY === "auto" || K.overflowY === "scroll" || K.overflowY === "visible")) : (re = q < Y && (K.overflowX === "auto" || K.overflowX === "scroll"), A = W < V && (K.overflowY === "auto" || K.overflowY === "scroll"));
          var be = re && (Math.abs(P - a) <= u && me + q < Y) - (Math.abs(J - a) <= u && !!me), Q = A && (Math.abs(B - l) <= u && ve + W < V) - (Math.abs(y - l) <= u && !!ve);
          if (!X[g])
            for (var Me = 0; Me <= g; Me++)
              X[Me] || (X[Me] = {});
          (X[g].vx != be || X[g].vy != Q || X[g].el !== _) && (X[g].el = _, X[g].vx = be, X[g].vy = Q, clearInterval(X[g].pid), (be != 0 || Q != 0) && (p = true, X[g].pid = setInterval(function() {
            i && this.layer === 0 && C.active._onTouchMove(Rt);
            var Oe = X[this.layer].vy ? X[this.layer].vy * c : 0, ye = X[this.layer].vx ? X[this.layer].vx * c : 0;
            typeof v == "function" && v.call(C.dragged.parentNode[pe], ye, Oe, n, Rt, X[this.layer].el) !== "continue" || pi(X[this.layer].el, ye, Oe);
          }.bind({ layer: g }), 24))), g++;
        } while (t.bubbleScroll && E !== f && (E = Pe(E, false)));
        Sn = p;
      }
    }, 30), Di = function(t) {
      var e = t.originalEvent, i = t.putSortable, a = t.dragEl, l = t.activeSortable, u = t.dispatchSortableEvent, c = t.hideGhostForTarget, f = t.unhideGhostForTarget;
      if (e) {
        var p = i || l;
        c();
        var v = e.changedTouches && e.changedTouches.length ? e.changedTouches[0] : e, g = document.elementFromPoint(v.clientX, v.clientY);
        f(), p && !p.el.contains(g) && (u("spill"), this.onSpill({ dragEl: a, putSortable: i }));
      }
    };
    function Mn() {
    }
    Mn.prototype = { startIndex: null, dragStart: function(t) {
      var e = t.oldDraggableIndex;
      this.startIndex = e;
    }, onSpill: function(t) {
      var e = t.dragEl, i = t.putSortable;
      this.sortable.captureAnimationState(), i && i.captureAnimationState();
      var a = Je(this.sortable.el, this.startIndex, this.options);
      a ? this.sortable.el.insertBefore(e, a) : this.sortable.el.appendChild(e), this.sortable.animateAll(), i && i.animateAll();
    }, drop: Di };
    Te(Mn, { pluginName: "revertOnSpill" });
    function _n() {
    }
    _n.prototype = { onSpill: function(t) {
      var e = t.dragEl, i = t.putSortable, a = i || this.sortable;
      a.captureAnimationState(), e.parentNode && e.parentNode.removeChild(e), a.animateAll();
    }, drop: Di };
    Te(_n, { pluginName: "removeOnSpill" });
    C.mount(new Gr());
    C.mount(_n, Mn);
    var Wt = C;
    function $r(n) {
      return new Promise((t, e) => {
        n.onload = () => {
          if (n.status >= 200 && n.status < 400)
            try {
              t({ data: JSON.parse(n.responseText), status: n.status });
            } catch (i) {
              e(i);
            }
          else
            try {
              e(JSON.parse(n.responseText));
            } catch (i) {
              e(i);
            }
        }, n.onerror = () => {
          e(new Error("An error occurred during the transaction"));
        };
      });
    }
    function Ur() {
      return document.querySelector('meta[name="csrf-token"]').attributes.content.textContent;
    }
    function zt(n, t) {
      return xn("GET", n, t);
    }
    function Be(n, t) {
      return xn("PATCH", n, t);
    }
    function xn(n, t, e) {
      let i = new XMLHttpRequest(), a = $r(i), l = new URL(window.location.origin + t);
      return e && n.toLowerCase() === "get" && (l.search = new URLSearchParams(e).toString()), i.open(n, l.toString()), i.setRequestHeader("Content-type", "application/json; charset=utf-8"), i.setRequestHeader("Accept", "application/json"), i.setRequestHeader("X-CSRF-Token", Ur()), e && n.toLowerCase() !== "get" ? i.send(JSON.stringify(e)) : i.send(), a;
    }
    function qt(n, t, e, i) {
      document.querySelectorAll(t).forEach((a) => {
        a.addEventListener(n, (l) => {
          let u = Array.from(a.querySelectorAll(e)), c = l.target;
          for (; c !== a; ) {
            if (u.includes(c)) {
              i.call(c, l);
              return;
            }
            c = c.parentElement;
          }
        });
      });
    }
    function Tn() {
      document.querySelectorAll("li.menu-item").forEach((n) => {
        let t = n.querySelector(".nodes_tree-left_images"), e = n.querySelector(".children"), i = { folded: n.dataset.folded === "true", id: n.dataset.id, type: n.dataset.type };
        e.children.length > 0 || i.folded ? t.innerHTML = HandlebarsTemplates.node_folder({ node: i }) : t.innerHTML = "&nbsp;";
      });
    }
    function Jr(n) {
      let t = Alchemy.routes[n.item.dataset.type].move_api_path(n.item.dataset.id), e = { target_parent_id: n.to.dataset.recordId, new_position: n.newIndex };
      Be(t, e).then(() => {
        let i = Alchemy.t("Successfully moved menu item");
        Alchemy.growl(i), Tn();
      }).catch((i) => {
        Alchemy.growl(i.message || i, "error");
      });
    }
    function Vr() {
      qt("click", ".nodes_tree", ".node_folder", function() {
        let n = this.dataset.recordId, t = this.closest("li.menu-item"), e = Alchemy.routes[this.dataset.recordType].toggle_folded_api_path(n), i = t.querySelector(".children");
        Be(e).then(() => {
          i.classList.toggle("folded"), t.dataset.folded = t.dataset.folded == "true" ? "false" : "true", Tn();
        }).catch((a) => {
          Alchemy.growl(a.message || a);
        });
      });
    }
    function In() {
      Vr(), Tn(), document.querySelectorAll(".nodes_tree ul.children").forEach((n) => {
        new Wt(n, { group: "nodes", animation: 150, fallbackOnBody: true, swapThreshold: 0.65, handle: ".node_name", invertSwap: true, onEnd: Jr });
      });
    }
    var An = class {
      constructor(t) {
        this.container = t, this.deleteLink = t.querySelector(".remove_file_link"), this.fileIcon = t.querySelector(".file_icon"), this.fileName = t.querySelector(".file_name"), this.deleteLink.addEventListener("click", this.removeFile.bind(this)), this.formFieldId = this.deleteLink.dataset.formFieldId, this.formField = t.querySelector(`#${this.formFieldId}`), this.assignFileText = this.deleteLink.dataset.assignFileText;
      }
      removeFile(t) {
        return t.stopPropagation(), this.formField.value = "", this.fileIcon.innerHTML = "", this.fileName.innerHTML = "", this.deleteLink.classList.add("hidden"), Alchemy.setElementDirty(this.container.closest(".element-editor")), false;
      }
    };
    function On(n) {
      document.querySelectorAll(n).forEach((t) => {
        new An(t);
      });
    }
    var ft = class {
      static updateIcon(t, e = false) {
        let i = document.querySelector(`[data-ingredient-id="${t}"]`);
        if (i) {
          let a = i.querySelector(".edit-ingredient-anchor-link > a > .icon");
          a && (e ? a.classList.replace("far", "fas") : a.classList.replace("fas", "far"));
        }
      }
    };
    function Zr(n) {
      var t = typeof n;
      return n != null && (t == "object" || t == "function");
    }
    var pt = Zr;
    var Qr = typeof global == "object" && global && global.Object === Object && global, wi = Qr;
    var ea = typeof self == "object" && self && self.Object === Object && self, ta = wi || ea || Function("return this")(), Kt = ta;
    var na = function() {
      return Kt.Date.now();
    }, Xt = na;
    var ia = /\s/;
    function ra(n) {
      for (var t = n.length; t-- && ia.test(n.charAt(t)); )
        ;
      return t;
    }
    var Ei = ra;
    var aa = /^\s+/;
    function oa(n) {
      return n && n.slice(0, Ei(n) + 1).replace(aa, "");
    }
    var Si = oa;
    var la = Kt.Symbol, Ve = la;
    var Ci = Object.prototype, sa = Ci.hasOwnProperty, ua = Ci.toString, ht = Ve ? Ve.toStringTag : void 0;
    function ca(n) {
      var t = sa.call(n, ht), e = n[ht];
      try {
        n[ht] = void 0;
        var i = true;
      } catch {
      }
      var a = ua.call(n);
      return i && (t ? n[ht] = e : delete n[ht]), a;
    }
    var Mi = ca;
    var da = Object.prototype, fa = da.toString;
    function pa(n) {
      return fa.call(n);
    }
    var _i = pa;
    var ha = "[object Null]", ma = "[object Undefined]", xi = Ve ? Ve.toStringTag : void 0;
    function ga(n) {
      return n == null ? n === void 0 ? ma : ha : xi && xi in Object(n) ? Mi(n) : _i(n);
    }
    var Ti = ga;
    function va(n) {
      return n != null && typeof n == "object";
    }
    var Ii = va;
    var ba = "[object Symbol]";
    function ya(n) {
      return typeof n == "symbol" || Ii(n) && Ti(n) == ba;
    }
    var Gt = ya;
    var Ai = 0 / 0, Da = /^[-+]0x[0-9a-f]+$/i, wa = /^0b[01]+$/i, Ea = /^0o[0-7]+$/i, Sa = parseInt;
    function Ca(n) {
      if (typeof n == "number")
        return n;
      if (Gt(n))
        return Ai;
      if (pt(n)) {
        var t = typeof n.valueOf == "function" ? n.valueOf() : n;
        n = pt(t) ? t + "" : t;
      }
      if (typeof n != "string")
        return n === 0 ? n : +n;
      n = Si(n);
      var e = wa.test(n);
      return e || Ea.test(n) ? Sa(n.slice(2), e ? 2 : 8) : Da.test(n) ? Ai : +n;
    }
    var Fn = Ca;
    var Ma = "Expected a function", _a = Math.max, xa = Math.min;
    function Ta(n, t, e) {
      var i, a, l, u, c, f, p = 0, v = false, g = false, E = true;
      if (typeof n != "function")
        throw new TypeError(Ma);
      t = Fn(t) || 0, pt(e) && (v = !!e.leading, g = "maxWait" in e, l = g ? _a(Fn(e.maxWait) || 0, t) : l, E = "trailing" in e ? !!e.trailing : E);
      function _(A) {
        var Y = i, V = a;
        return i = a = void 0, p = A, u = n.apply(V, Y), u;
      }
      function I(A) {
        return p = A, c = setTimeout(J, t), v ? _(A) : u;
      }
      function y(A) {
        var Y = A - f, V = A - p, K = t - Y;
        return g ? xa(K, l - V) : K;
      }
      function B(A) {
        var Y = A - f, V = A - p;
        return f === void 0 || Y >= t || Y < 0 || g && V >= l;
      }
      function J() {
        var A = Xt();
        if (B(A))
          return P(A);
        c = setTimeout(J, y(A));
      }
      function P(A) {
        return c = void 0, E && i ? _(A) : (i = a = void 0, u);
      }
      function q() {
        c !== void 0 && clearTimeout(c), p = 0, i = f = a = c = void 0;
      }
      function W() {
        return c === void 0 ? u : P(Xt());
      }
      function re() {
        var A = Xt(), Y = B(A);
        if (i = arguments, a = this, f = A, Y) {
          if (c === void 0)
            return I(f);
          if (g)
            return clearTimeout(c), c = setTimeout(J, t), _(f);
        }
        return c === void 0 && (c = setTimeout(J, t)), u;
      }
      return re.cancel = q, re.flush = W, re;
    }
    var Oi = Ta;
    function Ia(n, t, e) {
      for (var i = -1, a = n.length; ++i < a; ) {
        var l = n[i], u = t(l);
        if (u != null && (c === void 0 ? u === u && !Gt(u) : e(u, c)))
          var c = u, f = l;
      }
      return f;
    }
    var Fi = Ia;
    function Aa(n, t) {
      return n > t;
    }
    var ki = Aa;
    function Oa(n) {
      return n;
    }
    var Ni = Oa;
    function Fa(n) {
      return n && n.length ? Fi(n, Ni, ki) : void 0;
    }
    var Pi = Fa;
    var Li = { fill: "#fff" }, Ce = class {
      static init(t = document, e = Li) {
        typeof t == "string" && (t = document.querySelector(t)), t.querySelectorAll("img").forEach((i) => {
          new Ce(i, e).load();
        });
      }
      constructor(t, e = Li) {
        this.image = t, this.parent = t.parentNode, this.spinner = new Alchemy.Spinner("small", e), this.bind();
      }
      bind() {
        this.image.addEventListener("load", this.onLoaded.bind(this)), this.image.addEventListener("error", this.onError.bind(this));
      }
      load(t = false) {
        !t && this.image.complete || (this.image.classList.add("loading"), this.spinner.spin(this.image.parentElement));
      }
      onLoaded() {
        this.removeSpinner(), this.image.classList.remove("loading"), this.unbind();
      }
      onError(t) {
        let e = `Could not load "${this.image.src}"`;
        this.removeSpinner(), this.parent.innerHTML = `<span class="icon error fas fa-exclamation-triangle" title="${e}" />`, console.error(e, t), this.unbind();
      }
      unbind() {
        this.image.removeEventListener("load", this.onLoaded), this.image.removeEventListener("error", this.onError);
      }
      removeSpinner() {
        this.parent.querySelectorAll(".spinner").forEach((t) => {
          t.remove();
        });
      }
    };
    var ka = 125, Na = '<i class="icon far fa-image fa-fw"></i>', Pa = "160x120", kn = class {
      constructor(t) {
        this.container = t, this.cropFromField = t.querySelector("[data-crop-from]"), this.cropSizeField = t.querySelector("[data-crop-size]"), this.pictureIdField = t.querySelector("[data-picture-id]"), this.targetSizeField = t.querySelector("[data-target-size]"), this.imageCropperField = t.querySelector("[data-image-cropper]"), this.image = t.querySelector("img"), this.thumbnailBackground = t.querySelector(".thumbnail_background"), this.deleteButton = t.querySelector(".picture_tool.delete"), this.cropLink = t.querySelector(".crop_link"), this.targetSize = this.targetSizeField.dataset.targetSize, this.pictureId = this.pictureIdField.value, this.image && (this.imageLoader = new Ce(this.image)), this.update = Oi(() => {
          this.updateImage(), this.updateCropLink();
        }, ka), this.deleteButton.addEventListener("click", this.removeImage.bind(this));
      }
      observe() {
        let t = new MutationObserver(this.mutationCallback.bind(this));
        t.observe(this.cropFromField, { attributes: true }), t.observe(this.cropSizeField, { attributes: true }), t.observe(this.pictureIdField, { attributes: true });
      }
      mutationCallback(t) {
        for (let e of t)
          "pictureId" in e.target.dataset && (this.cropFromField.value = "", this.cropSizeField.value = "", this.pictureId = e.target.value), this.update();
      }
      updateImage() {
        this.pictureId && (this.ensureImage(), this.image.removeAttribute("alt"), this.image.removeAttribute("src"), this.imageLoader.load(true), zt(Alchemy.routes.url_admin_picture_path(this.pictureId), { crop: this.imageCropperEnabled, crop_from: this.cropFrom, crop_size: this.cropSize, flatten: true, size: Pa }).then(({ data: t }) => {
          this.image.src = t.url, this.image.alt = t.alt, this.image.title = t.title;
        }).catch((t) => {
          console.error(t.message || t), Alchemy.growl(t.message || t, "error");
        }));
      }
      ensureImage() {
        if (this.image)
          return;
        let t = new Image();
        this.thumbnailBackground.replaceChildren(t), this.image = t, this.imageLoader = new Ce(t);
      }
      removeImage() {
        this.thumbnailBackground.innerHTML = Na, this.pictureIdField.value = "", this.image = null, this.cropLink.classList.add("disabled"), Alchemy.setElementDirty(this.container.closest(".element-editor"));
      }
      updateCropLink() {
        !this.pictureId || !this.imageCropperEnabled || (this.cropLink.classList.remove("disabled"), this.cropLink.href.match(/(picture_id=)\d+/) ? this.cropLink.href = this.cropLink.href.replace(/(picture_id=)\d+/, "$1" + this.pictureId) : this.cropLink.href = this.cropLink.href + `&picture_id=${this.pictureId}`);
      }
      get cropFrom() {
        return this.cropFromField.value === "" ? this.defaultCropFrom.join("x") : this.cropFromField.value;
      }
      get cropSize() {
        return this.cropSizeField.value === "" ? this.defaultCropSize.join("x") : this.cropSizeField.value;
      }
      get defaultCropSize() {
        if (!this.imageCropperEnabled)
          return [];
        let t = this.targetSize.split("x").map((i) => parseInt(i)), e = Pi([t[0] / this.imageFileWidth, t[1] / this.imageFileHeight]);
        return [Math.round(t[0] / e), Math.round(t[1] / e)];
      }
      get defaultCropFrom() {
        if (!this.imageCropperEnabled)
          return [];
        let t = this.defaultCropSize;
        return [Math.round((this.imageFileWidth - t[0]) / 2), Math.round((this.imageFileHeight - t[1]) / 2)];
      }
      get imageFileWidth() {
        return parseInt(this.pictureIdField.dataset.imageFileWidth);
      }
      get imageFileHeight() {
        return parseInt(this.pictureIdField.dataset.imageFileHeight);
      }
      get imageCropperEnabled() {
        return this.targetSizeField.dataset.imageCropper === "true";
      }
    };
    function Nn(n) {
      document.querySelectorAll(n).forEach((t) => {
        new kn(t).observe();
      });
    }
    var mt = class {
      constructor(t, e, i, a, l, u) {
        this.initialized = false, this.minSize = t, this.defaultBox = e, this.aspectRatio = i, this.trueSize = a, this.cropFromField = document.getElementById(l[0]), this.cropSizeField = document.getElementById(l[1]), this.elementId = u, this.dialog = Alchemy.currentDialog(), this.dialog.options.closed = this.destroy, this.init(), this.bind();
      }
      get jcropOptions() {
        return { onSelect: this.update.bind(this), setSelect: this.box, aspectRatio: this.aspectRatio, minSize: this.minSize, boxWidth: 800, boxHeight: 600, trueSize: this.trueSize, closed: this.destroy.bind(this) };
      }
      get cropFrom() {
        if (this.cropFromField.value)
          return this.cropFromField.value.split("x").map((t) => parseInt(t));
      }
      get cropSize() {
        if (this.cropSizeField.value)
          return this.cropSizeField.value.split("x").map((t) => parseInt(t));
      }
      get box() {
        return this.cropFrom && this.cropSize ? [this.cropFrom[0], this.cropFrom[1], this.cropFrom[0] + this.cropSize[0], this.cropFrom[1] + this.cropSize[1]] : this.defaultBox;
      }
      init() {
        this.initialized || (this.api = $.Jcrop("#imageToCrop", this.jcropOptions), this.initialized = true);
      }
      update(t) {
        this.cropFromField.value = Math.round(t.x) + "x" + Math.round(t.y), this.cropFromField.dispatchEvent(new Event("change")), this.cropSizeField.value = Math.round(t.w) + "x" + Math.round(t.h), this.cropFromField.dispatchEvent(new Event("change"));
      }
      reset() {
        this.api.setSelect(this.defaultBox), this.cropFromField.value = `${this.box[0]}x${this.box[1]}`, this.cropSizeField.value = `${this.box[2]}x${this.box[3] - this.box[1]}`;
      }
      destroy() {
        return this.api && this.api.destroy(), this.initialized = false, true;
      }
      bind() {
        this.dialog.dialog_body.find('button[type="submit"]').click(() => (Alchemy.setElementDirty(`[data-element-id='${this.elementId}']`), this.dialog.close(), false)), this.dialog.dialog_body.find('button[type="reset"]').click(() => (this.reset(), false));
      }
    };
    var $t = ["onChange", "onClose", "onDayCreate", "onDestroy", "onKeyDown", "onMonthChange", "onOpen", "onParseConfig", "onReady", "onValueUpdate", "onYearChange", "onPreCalendarPosition"], Le = { _disable: [], allowInput: false, allowInvalidPreload: false, altFormat: "F j, Y", altInput: false, altInputClass: "form-control input", animate: typeof window == "object" && window.navigator.userAgent.indexOf("MSIE") === -1, ariaDateFormat: "F j, Y", autoFillDefaultTime: true, clickOpens: true, closeOnSelect: true, conjunction: ", ", dateFormat: "Y-m-d", defaultHour: 12, defaultMinute: 0, defaultSeconds: 0, disable: [], disableMobile: false, enableSeconds: false, enableTime: false, errorHandler: function(n) {
      return typeof console < "u" && console.warn(n);
    }, getWeek: function(n) {
      var t = new Date(n.getTime());
      t.setHours(0, 0, 0, 0), t.setDate(t.getDate() + 3 - (t.getDay() + 6) % 7);
      var e = new Date(t.getFullYear(), 0, 4);
      return 1 + Math.round(((t.getTime() - e.getTime()) / 864e5 - 3 + (e.getDay() + 6) % 7) / 7);
    }, hourIncrement: 1, ignoredFocusElements: [], inline: false, locale: "default", minuteIncrement: 5, mode: "single", monthSelectorType: "dropdown", nextArrow: "<svg version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' viewBox='0 0 17 17'><g></g><path d='M13.207 8.472l-7.854 7.854-0.707-0.707 7.146-7.146-7.146-7.148 0.707-0.707 7.854 7.854z' /></svg>", noCalendar: false, now: /* @__PURE__ */ new Date(), onChange: [], onClose: [], onDayCreate: [], onDestroy: [], onKeyDown: [], onMonthChange: [], onOpen: [], onParseConfig: [], onReady: [], onValueUpdate: [], onYearChange: [], onPreCalendarPosition: [], plugins: [], position: "auto", positionElement: void 0, prevArrow: "<svg version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' viewBox='0 0 17 17'><g></g><path d='M5.207 8.471l7.146 7.147-0.707 0.707-7.853-7.854 7.854-7.853 0.707 0.707-7.147 7.146z' /></svg>", shorthandCurrentMonth: false, showMonths: 1, static: false, time_24hr: false, weekNumbers: false, wrap: false };
    var Ut = { weekdays: { shorthand: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], longhand: ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"] }, months: { shorthand: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"], longhand: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"] }, daysInMonth: [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31], firstDayOfWeek: 0, ordinal: function(n) {
      var t = n % 100;
      if (t > 3 && t < 21)
        return "th";
      switch (t % 10) {
        case 1:
          return "st";
        case 2:
          return "nd";
        case 3:
          return "rd";
        default:
          return "th";
      }
    }, rangeSeparator: " to ", weekAbbreviation: "Wk", scrollTitle: "Scroll to increment", toggleTitle: "Click to toggle", amPM: ["AM", "PM"], yearAriaLabel: "Year", monthAriaLabel: "Month", hourAriaLabel: "Hour", minuteAriaLabel: "Minute", time_24hr: false }, Jt = Ut;
    var te = function(n, t) {
      return t === void 0 && (t = 2), ("000" + n).slice(t * -1);
    }, le = function(n) {
      return n === true ? 1 : 0;
    };
    function Pn(n, t) {
      var e;
      return function() {
        var i = this, a = arguments;
        clearTimeout(e), e = setTimeout(function() {
          return n.apply(i, a);
        }, t);
      };
    }
    var Vt = function(n) {
      return n instanceof Array ? n : [n];
    };
    function ne(n, t, e) {
      if (e === true)
        return n.classList.add(t);
      n.classList.remove(t);
    }
    function k(n, t, e) {
      var i = window.document.createElement(n);
      return t = t || "", e = e || "", i.className = t, e !== void 0 && (i.textContent = e), i;
    }
    function gt(n) {
      for (; n.firstChild; )
        n.removeChild(n.firstChild);
    }
    function Ln(n, t) {
      if (t(n))
        return n;
      if (n.parentNode)
        return Ln(n.parentNode, t);
    }
    function vt(n, t) {
      var e = k("div", "numInputWrapper"), i = k("input", "numInput " + n), a = k("span", "arrowUp"), l = k("span", "arrowDown");
      if (navigator.userAgent.indexOf("MSIE 9.0") === -1 ? i.type = "number" : (i.type = "text", i.pattern = "\\d*"), t !== void 0)
        for (var u in t)
          i.setAttribute(u, t[u]);
      return e.appendChild(i), e.appendChild(a), e.appendChild(l), e;
    }
    function se(n) {
      try {
        if (typeof n.composedPath == "function") {
          var t = n.composedPath();
          return t[0];
        }
        return n.target;
      } catch {
        return n.target;
      }
    }
    var Hn = function() {
    }, bt = function(n, t, e) {
      return e.months[t ? "shorthand" : "longhand"][n];
    }, Hi = { D: Hn, F: function(n, t, e) {
      n.setMonth(e.months.longhand.indexOf(t));
    }, G: function(n, t) {
      n.setHours((n.getHours() >= 12 ? 12 : 0) + parseFloat(t));
    }, H: function(n, t) {
      n.setHours(parseFloat(t));
    }, J: function(n, t) {
      n.setDate(parseFloat(t));
    }, K: function(n, t, e) {
      n.setHours(n.getHours() % 12 + 12 * le(new RegExp(e.amPM[1], "i").test(t)));
    }, M: function(n, t, e) {
      n.setMonth(e.months.shorthand.indexOf(t));
    }, S: function(n, t) {
      n.setSeconds(parseFloat(t));
    }, U: function(n, t) {
      return new Date(parseFloat(t) * 1e3);
    }, W: function(n, t, e) {
      var i = parseInt(t), a = new Date(n.getFullYear(), 0, 2 + (i - 1) * 7, 0, 0, 0, 0);
      return a.setDate(a.getDate() - a.getDay() + e.firstDayOfWeek), a;
    }, Y: function(n, t) {
      n.setFullYear(parseFloat(t));
    }, Z: function(n, t) {
      return new Date(t);
    }, d: function(n, t) {
      n.setDate(parseFloat(t));
    }, h: function(n, t) {
      n.setHours((n.getHours() >= 12 ? 12 : 0) + parseFloat(t));
    }, i: function(n, t) {
      n.setMinutes(parseFloat(t));
    }, j: function(n, t) {
      n.setDate(parseFloat(t));
    }, l: Hn, m: function(n, t) {
      n.setMonth(parseFloat(t) - 1);
    }, n: function(n, t) {
      n.setMonth(parseFloat(t) - 1);
    }, s: function(n, t) {
      n.setSeconds(parseFloat(t));
    }, u: function(n, t) {
      return new Date(parseFloat(t));
    }, w: Hn, y: function(n, t) {
      n.setFullYear(2e3 + parseFloat(t));
    } }, Ae = { D: "", F: "", G: "(\\d\\d|\\d)", H: "(\\d\\d|\\d)", J: "(\\d\\d|\\d)\\w+", K: "", M: "", S: "(\\d\\d|\\d)", U: "(.+)", W: "(\\d\\d|\\d)", Y: "(\\d{4})", Z: "(.+)", d: "(\\d\\d|\\d)", h: "(\\d\\d|\\d)", i: "(\\d\\d|\\d)", j: "(\\d\\d|\\d)", l: "", m: "(\\d\\d|\\d)", n: "(\\d\\d|\\d)", s: "(\\d\\d|\\d)", u: "(.+)", w: "(\\d\\d|\\d)", y: "(\\d{2})" }, Ze = { Z: function(n) {
      return n.toISOString();
    }, D: function(n, t, e) {
      return t.weekdays.shorthand[Ze.w(n, t, e)];
    }, F: function(n, t, e) {
      return bt(Ze.n(n, t, e) - 1, false, t);
    }, G: function(n, t, e) {
      return te(Ze.h(n, t, e));
    }, H: function(n) {
      return te(n.getHours());
    }, J: function(n, t) {
      return t.ordinal !== void 0 ? n.getDate() + t.ordinal(n.getDate()) : n.getDate();
    }, K: function(n, t) {
      return t.amPM[le(n.getHours() > 11)];
    }, M: function(n, t) {
      return bt(n.getMonth(), true, t);
    }, S: function(n) {
      return te(n.getSeconds());
    }, U: function(n) {
      return n.getTime() / 1e3;
    }, W: function(n, t, e) {
      return e.getWeek(n);
    }, Y: function(n) {
      return te(n.getFullYear(), 4);
    }, d: function(n) {
      return te(n.getDate());
    }, h: function(n) {
      return n.getHours() % 12 ? n.getHours() % 12 : 12;
    }, i: function(n) {
      return te(n.getMinutes());
    }, j: function(n) {
      return n.getDate();
    }, l: function(n, t) {
      return t.weekdays.longhand[n.getDay()];
    }, m: function(n) {
      return te(n.getMonth() + 1);
    }, n: function(n) {
      return n.getMonth() + 1;
    }, s: function(n) {
      return n.getSeconds();
    }, u: function(n) {
      return n.getTime();
    }, w: function(n) {
      return n.getDay();
    }, y: function(n) {
      return String(n.getFullYear()).substring(2);
    } };
    var Yn = function(n) {
      var t = n.config, e = t === void 0 ? Le : t, i = n.l10n, a = i === void 0 ? Ut : i, l = n.isMobile, u = l === void 0 ? false : l;
      return function(c, f, p) {
        var v = p || a;
        return e.formatDate !== void 0 && !u ? e.formatDate(c, f, v) : f.split("").map(function(g, E, _) {
          return Ze[g] && _[E - 1] !== "\\" ? Ze[g](c, v, e) : g !== "\\" ? g : "";
        }).join("");
      };
    }, Zt = function(n) {
      var t = n.config, e = t === void 0 ? Le : t, i = n.l10n, a = i === void 0 ? Ut : i;
      return function(l, u, c, f) {
        if (!(l !== 0 && !l)) {
          var p = f || a, v, g = l;
          if (l instanceof Date)
            v = new Date(l.getTime());
          else if (typeof l != "string" && l.toFixed !== void 0)
            v = new Date(l);
          else if (typeof l == "string") {
            var E = u || (e || Le).dateFormat, _ = String(l).trim();
            if (_ === "today")
              v = /* @__PURE__ */ new Date(), c = true;
            else if (e && e.parseDate)
              v = e.parseDate(l, E);
            else if (/Z$/.test(_) || /GMT$/.test(_))
              v = new Date(l);
            else {
              for (var I = void 0, y = [], B = 0, J = 0, P = ""; B < E.length; B++) {
                var q = E[B], W = q === "\\", re = E[B - 1] === "\\" || W;
                if (Ae[q] && !re) {
                  P += Ae[q];
                  var A = new RegExp(P).exec(l);
                  A && (I = true) && y[q !== "Y" ? "push" : "unshift"]({ fn: Hi[q], val: A[++J] });
                } else
                  W || (P += ".");
              }
              v = !e || !e.noCalendar ? new Date((/* @__PURE__ */ new Date()).getFullYear(), 0, 1, 0, 0, 0, 0) : new Date((/* @__PURE__ */ new Date()).setHours(0, 0, 0, 0)), y.forEach(function(Y) {
                var V = Y.fn, K = Y.val;
                return v = V(v, K, p) || v;
              }), v = I ? v : void 0;
            }
          }
          if (!(v instanceof Date && !isNaN(v.getTime()))) {
            e.errorHandler(new Error("Invalid date provided: " + g));
            return;
          }
          return c === true && v.setHours(0, 0, 0, 0), v;
        }
      };
    };
    function ue(n, t, e) {
      return e === void 0 && (e = true), e !== false ? new Date(n.getTime()).setHours(0, 0, 0, 0) - new Date(t.getTime()).setHours(0, 0, 0, 0) : n.getTime() - t.getTime();
    }
    var Yi = function(n, t, e) {
      return n > Math.min(t, e) && n < Math.max(t, e);
    }, Qt = function(n, t, e) {
      return n * 3600 + t * 60 + e;
    }, ji = function(n) {
      var t = Math.floor(n / 3600), e = (n - t * 3600) / 60;
      return [t, e, n - t * 3600 - e * 60];
    }, Ri = { DAY: 864e5 };
    function en(n) {
      var t = n.defaultHour, e = n.defaultMinute, i = n.defaultSeconds;
      if (n.minDate !== void 0) {
        var a = n.minDate.getHours(), l = n.minDate.getMinutes(), u = n.minDate.getSeconds();
        t < a && (t = a), t === a && e < l && (e = l), t === a && e === l && i < u && (i = n.minDate.getSeconds());
      }
      if (n.maxDate !== void 0) {
        var c = n.maxDate.getHours(), f = n.maxDate.getMinutes();
        t = Math.min(t, c), t === c && (e = Math.min(f, e)), t === c && e === f && (i = n.maxDate.getSeconds());
      }
      return { hours: t, minutes: e, seconds: i };
    }
    typeof Object.assign != "function" && (Object.assign = function(n) {
      for (var t = [], e = 1; e < arguments.length; e++)
        t[e - 1] = arguments[e];
      if (!n)
        throw TypeError("Cannot convert undefined or null to object");
      for (var i = function(c) {
        c && Object.keys(c).forEach(function(f) {
          return n[f] = c[f];
        });
      }, a = 0, l = t; a < l.length; a++) {
        var u = l[a];
        i(u);
      }
      return n;
    });
    var ie = function() {
      return ie = Object.assign || function(n) {
        for (var t, e = 1, i = arguments.length; e < i; e++) {
          t = arguments[e];
          for (var a in t)
            Object.prototype.hasOwnProperty.call(t, a) && (n[a] = t[a]);
        }
        return n;
      }, ie.apply(this, arguments);
    }, Bi = function() {
      for (var n = 0, t = 0, e = arguments.length; t < e; t++)
        n += arguments[t].length;
      for (var i = Array(n), a = 0, t = 0; t < e; t++)
        for (var l = arguments[t], u = 0, c = l.length; u < c; u++, a++)
          i[a] = l[u];
      return i;
    }, La = 300;
    function Ha(n, t) {
      var e = { config: ie(ie({}, Le), G.defaultConfig), l10n: Jt };
      e.parseDate = Zt({ config: e.config, l10n: e.l10n }), e._handlers = [], e.pluginElements = [], e.loadedPlugins = [], e._bind = y, e._setHoursFromDate = E, e._positionCalendar = Ct, e.changeMonth = ze, e.changeYear = wt, e.clear = nn, e.close = Ki, e.onMouseOver = St, e._createElement = k, e.createDay = A, e.destroy = Xi, e.isEnabled = He, e.jumpToDate = P, e.updateValue = _e, e.open = Ui, e.redraw = Xn, e.set = Qi, e.setDate = er, e.toggle = rr;
      function i() {
        e.utils = { getDaysInMonth: function(r, o) {
          return r === void 0 && (r = e.currentMonth), o === void 0 && (o = e.currentYear), r === 1 && (o % 4 === 0 && o % 100 !== 0 || o % 400 === 0) ? 29 : e.l10n.daysInMonth[r];
        } };
      }
      function a() {
        e.element = e.input = n, e.isOpen = false, Ji(), Kn(), nr(), tr(), i(), e.isMobile || re(), J(), (e.selectedDates.length || e.config.noCalendar) && (e.config.enableTime && E(e.config.noCalendar ? e.latestSelectedDateObj : void 0), _e(false)), c();
        var r = /^((?!chrome|android).)*safari/i.test(navigator.userAgent);
        !e.isMobile && r && Ct(), j("onReady");
      }
      function l() {
        var r;
        return ((r = e.calendarContainer) === null || r === void 0 ? void 0 : r.getRootNode()).activeElement || document.activeElement;
      }
      function u(r) {
        return r.bind(e);
      }
      function c() {
        var r = e.config;
        r.weekNumbers === false && r.showMonths === 1 || r.noCalendar !== true && window.requestAnimationFrame(function() {
          if (e.calendarContainer !== void 0 && (e.calendarContainer.style.visibility = "hidden", e.calendarContainer.style.display = "block"), e.daysContainer !== void 0) {
            var o = (e.days.offsetWidth + 1) * r.showMonths;
            e.daysContainer.style.width = o + "px", e.calendarContainer.style.width = o + (e.weekWrapper !== void 0 ? e.weekWrapper.offsetWidth : 0) + "px", e.calendarContainer.style.removeProperty("visibility"), e.calendarContainer.style.removeProperty("display");
          }
        });
      }
      function f(r) {
        if (e.selectedDates.length === 0) {
          var o = e.config.minDate === void 0 || ue(/* @__PURE__ */ new Date(), e.config.minDate) >= 0 ? /* @__PURE__ */ new Date() : new Date(e.config.minDate.getTime()), s = en(e.config);
          o.setHours(s.hours, s.minutes, s.seconds, o.getMilliseconds()), e.selectedDates = [o], e.latestSelectedDateObj = o;
        }
        r !== void 0 && r.type !== "blur" && lr(r);
        var d = e._input.value;
        g(), _e(), e._input.value !== d && e._debouncedChange();
      }
      function p(r, o) {
        return r % 12 + 12 * le(o === e.l10n.amPM[1]);
      }
      function v(r) {
        switch (r % 24) {
          case 0:
          case 12:
            return 12;
          default:
            return r % 12;
        }
      }
      function g() {
        if (!(e.hourElement === void 0 || e.minuteElement === void 0)) {
          var r = (parseInt(e.hourElement.value.slice(-2), 10) || 0) % 24, o = (parseInt(e.minuteElement.value, 10) || 0) % 60, s = e.secondElement !== void 0 ? (parseInt(e.secondElement.value, 10) || 0) % 60 : 0;
          e.amPM !== void 0 && (r = p(r, e.amPM.textContent));
          var d = e.config.minTime !== void 0 || e.config.minDate && e.minDateHasTime && e.latestSelectedDateObj && ue(e.latestSelectedDateObj, e.config.minDate, true) === 0, h = e.config.maxTime !== void 0 || e.config.maxDate && e.maxDateHasTime && e.latestSelectedDateObj && ue(e.latestSelectedDateObj, e.config.maxDate, true) === 0;
          if (e.config.maxTime !== void 0 && e.config.minTime !== void 0 && e.config.minTime > e.config.maxTime) {
            var b = Qt(e.config.minTime.getHours(), e.config.minTime.getMinutes(), e.config.minTime.getSeconds()), T = Qt(e.config.maxTime.getHours(), e.config.maxTime.getMinutes(), e.config.maxTime.getSeconds()), w = Qt(r, o, s);
            if (w > T && w < b) {
              var O = ji(b);
              r = O[0], o = O[1], s = O[2];
            }
          } else {
            if (h) {
              var D = e.config.maxTime !== void 0 ? e.config.maxTime : e.config.maxDate;
              r = Math.min(r, D.getHours()), r === D.getHours() && (o = Math.min(o, D.getMinutes())), o === D.getMinutes() && (s = Math.min(s, D.getSeconds()));
            }
            if (d) {
              var M = e.config.minTime !== void 0 ? e.config.minTime : e.config.minDate;
              r = Math.max(r, M.getHours()), r === M.getHours() && o < M.getMinutes() && (o = M.getMinutes()), o === M.getMinutes() && (s = Math.max(s, M.getSeconds()));
            }
          }
          _(r, o, s);
        }
      }
      function E(r) {
        var o = r || e.latestSelectedDateObj;
        o && o instanceof Date && _(o.getHours(), o.getMinutes(), o.getSeconds());
      }
      function _(r, o, s) {
        e.latestSelectedDateObj !== void 0 && e.latestSelectedDateObj.setHours(r % 24, o, s || 0, 0), !(!e.hourElement || !e.minuteElement || e.isMobile) && (e.hourElement.value = te(e.config.time_24hr ? r : (12 + r) % 12 + 12 * le(r % 12 === 0)), e.minuteElement.value = te(o), e.amPM !== void 0 && (e.amPM.textContent = e.l10n.amPM[le(r >= 12)]), e.secondElement !== void 0 && (e.secondElement.value = te(s)));
      }
      function I(r) {
        var o = se(r), s = parseInt(o.value) + (r.delta || 0);
        (s / 1e3 > 1 || r.key === "Enter" && !/[^\d]/.test(s.toString())) && wt(s);
      }
      function y(r, o, s, d) {
        if (o instanceof Array)
          return o.forEach(function(h) {
            return y(r, h, s, d);
          });
        if (r instanceof Array)
          return r.forEach(function(h) {
            return y(h, o, s, d);
          });
        r.addEventListener(o, s, d), e._handlers.push({ remove: function() {
          return r.removeEventListener(o, s, d);
        } });
      }
      function B() {
        j("onChange");
      }
      function J() {
        if (e.config.wrap && ["open", "close", "toggle", "clear"].forEach(function(s) {
          Array.prototype.forEach.call(e.element.querySelectorAll("[data-" + s + "]"), function(d) {
            return y(d, "click", e[s]);
          });
        }), e.isMobile) {
          ir();
          return;
        }
        var r = Pn($i, 50);
        if (e._debouncedChange = Pn(B, La), e.daysContainer && !/iPhone|iPad|iPod/i.test(navigator.userAgent) && y(e.daysContainer, "mouseover", function(s) {
          e.config.mode === "range" && St(se(s));
        }), y(e._input, "keydown", Wn), e.calendarContainer !== void 0 && y(e.calendarContainer, "keydown", Wn), !e.config.inline && !e.config.static && y(window, "resize", r), window.ontouchstart !== void 0 ? y(window.document, "touchstart", rn) : y(window.document, "mousedown", rn), y(window.document, "focus", rn, { capture: true }), e.config.clickOpens === true && (y(e._input, "focus", e.open), y(e._input, "click", e.open)), e.daysContainer !== void 0 && (y(e.monthNav, "click", or), y(e.monthNav, ["keyup", "increment"], I), y(e.daysContainer, "click", Gn)), e.timeContainer !== void 0 && e.minuteElement !== void 0 && e.hourElement !== void 0) {
          var o = function(s) {
            return se(s).select();
          };
          y(e.timeContainer, ["increment"], f), y(e.timeContainer, "blur", f, { capture: true }), y(e.timeContainer, "click", q), y([e.hourElement, e.minuteElement], ["focus", "click"], o), e.secondElement !== void 0 && y(e.secondElement, "focus", function() {
            return e.secondElement && e.secondElement.select();
          }), e.amPM !== void 0 && y(e.amPM, "click", function(s) {
            f(s);
          });
        }
        e.config.allowInput && y(e._input, "blur", Gi);
      }
      function P(r, o) {
        var s = r !== void 0 ? e.parseDate(r) : e.latestSelectedDateObj || (e.config.minDate && e.config.minDate > e.now ? e.config.minDate : e.config.maxDate && e.config.maxDate < e.now ? e.config.maxDate : e.now), d = e.currentYear, h = e.currentMonth;
        try {
          s !== void 0 && (e.currentYear = s.getFullYear(), e.currentMonth = s.getMonth());
        } catch (b) {
          b.message = "Invalid date supplied: " + s, e.config.errorHandler(b);
        }
        o && e.currentYear !== d && (j("onYearChange"), Q()), o && (e.currentYear !== d || e.currentMonth !== h) && j("onMonthChange"), e.redraw();
      }
      function q(r) {
        var o = se(r);
        ~o.className.indexOf("arrow") && W(r, o.classList.contains("arrowUp") ? 1 : -1);
      }
      function W(r, o, s) {
        var d = r && se(r), h = s || d && d.parentNode && d.parentNode.firstChild, b = on("increment");
        b.delta = o, h && h.dispatchEvent(b);
      }
      function re() {
        var r = window.document.createDocumentFragment();
        if (e.calendarContainer = k("div", "flatpickr-calendar"), e.calendarContainer.tabIndex = -1, !e.config.noCalendar) {
          if (r.appendChild(ye()), e.innerContainer = k("div", "flatpickr-innerContainer"), e.config.weekNumbers) {
            var o = Bn(), s = o.weekWrapper, d = o.weekNumbers;
            e.innerContainer.appendChild(s), e.weekNumbers = d, e.weekWrapper = s;
          }
          e.rContainer = k("div", "flatpickr-rContainer"), e.rContainer.appendChild(Fe()), e.daysContainer || (e.daysContainer = k("div", "flatpickr-days"), e.daysContainer.tabIndex = -1), be(), e.rContainer.appendChild(e.daysContainer), e.innerContainer.appendChild(e.rContainer), r.appendChild(e.innerContainer);
        }
        e.config.enableTime && r.appendChild(We()), ne(e.calendarContainer, "rangeMode", e.config.mode === "range"), ne(e.calendarContainer, "animate", e.config.animate === true), ne(e.calendarContainer, "multiMonth", e.config.showMonths > 1), e.calendarContainer.appendChild(r);
        var h = e.config.appendTo !== void 0 && e.config.appendTo.nodeType !== void 0;
        if ((e.config.inline || e.config.static) && (e.calendarContainer.classList.add(e.config.inline ? "inline" : "static"), e.config.inline && (!h && e.element.parentNode ? e.element.parentNode.insertBefore(e.calendarContainer, e._input.nextSibling) : e.config.appendTo !== void 0 && e.config.appendTo.appendChild(e.calendarContainer)), e.config.static)) {
          var b = k("div", "flatpickr-wrapper");
          e.element.parentNode && e.element.parentNode.insertBefore(b, e.element), b.appendChild(e.element), e.altInput && b.appendChild(e.altInput), b.appendChild(e.calendarContainer);
        }
        !e.config.static && !e.config.inline && (e.config.appendTo !== void 0 ? e.config.appendTo : window.document.body).appendChild(e.calendarContainer);
      }
      function A(r, o, s, d) {
        var h = He(o, true), b = k("span", r, o.getDate().toString());
        return b.dateObj = o, b.$i = d, b.setAttribute("aria-label", e.formatDate(o, e.config.ariaDateFormat)), r.indexOf("hidden") === -1 && ue(o, e.now) === 0 && (e.todayDateElem = b, b.classList.add("today"), b.setAttribute("aria-current", "date")), h ? (b.tabIndex = -1, ln(o) && (b.classList.add("selected"), e.selectedDateElem = b, e.config.mode === "range" && (ne(b, "startRange", e.selectedDates[0] && ue(o, e.selectedDates[0], true) === 0), ne(b, "endRange", e.selectedDates[1] && ue(o, e.selectedDates[1], true) === 0), r === "nextMonthDay" && b.classList.add("inRange")))) : b.classList.add("flatpickr-disabled"), e.config.mode === "range" && ar(o) && !ln(o) && b.classList.add("inRange"), e.weekNumbers && e.config.showMonths === 1 && r !== "prevMonthDay" && d % 7 === 6 && e.weekNumbers.insertAdjacentHTML("beforeend", "<span class='flatpickr-day'>" + e.config.getWeek(o) + "</span>"), j("onDayCreate", b), b;
      }
      function Y(r) {
        r.focus(), e.config.mode === "range" && St(r);
      }
      function V(r) {
        for (var o = r > 0 ? 0 : e.config.showMonths - 1, s = r > 0 ? e.config.showMonths : -1, d = o; d != s; d += r)
          for (var h = e.daysContainer.children[d], b = r > 0 ? 0 : h.children.length - 1, T = r > 0 ? h.children.length : -1, w = b; w != T; w += r) {
            var O = h.children[w];
            if (O.className.indexOf("hidden") === -1 && He(O.dateObj))
              return O;
          }
      }
      function K(r, o) {
        for (var s = r.className.indexOf("Month") === -1 ? r.dateObj.getMonth() : e.currentMonth, d = o > 0 ? e.config.showMonths : -1, h = o > 0 ? 1 : -1, b = s - e.currentMonth; b != d; b += h)
          for (var T = e.daysContainer.children[b], w = s - e.currentMonth === b ? r.$i + o : o < 0 ? T.children.length - 1 : 0, O = T.children.length, D = w; D >= 0 && D < O && D != (o > 0 ? O : -1); D += h) {
            var M = T.children[D];
            if (M.className.indexOf("hidden") === -1 && He(M.dateObj) && Math.abs(r.$i - D) >= Math.abs(o))
              return Y(M);
          }
        e.changeMonth(h), me(V(h), 0);
      }
      function me(r, o) {
        var s = l(), d = Et(s || document.body), h = r !== void 0 ? r : d ? s : e.selectedDateElem !== void 0 && Et(e.selectedDateElem) ? e.selectedDateElem : e.todayDateElem !== void 0 && Et(e.todayDateElem) ? e.todayDateElem : V(o > 0 ? 1 : -1);
        h === void 0 ? e._input.focus() : d ? K(h, o) : Y(h);
      }
      function ve(r, o) {
        for (var s = (new Date(r, o, 1).getDay() - e.l10n.firstDayOfWeek + 7) % 7, d = e.utils.getDaysInMonth((o - 1 + 12) % 12, r), h = e.utils.getDaysInMonth(o, r), b = window.document.createDocumentFragment(), T = e.config.showMonths > 1, w = T ? "prevMonthDay hidden" : "prevMonthDay", O = T ? "nextMonthDay hidden" : "nextMonthDay", D = d + 1 - s, M = 0; D <= d; D++, M++)
          b.appendChild(A("flatpickr-day " + w, new Date(r, o - 1, D), D, M));
        for (D = 1; D <= h; D++, M++)
          b.appendChild(A("flatpickr-day", new Date(r, o, D), D, M));
        for (var L = h + 1; L <= 42 - s && (e.config.showMonths === 1 || M % 7 !== 0); L++, M++)
          b.appendChild(A("flatpickr-day " + O, new Date(r, o + 1, L % h), L, M));
        var De = k("div", "dayContainer");
        return De.appendChild(b), De;
      }
      function be() {
        if (e.daysContainer !== void 0) {
          gt(e.daysContainer), e.weekNumbers && gt(e.weekNumbers);
          for (var r = document.createDocumentFragment(), o = 0; o < e.config.showMonths; o++) {
            var s = new Date(e.currentYear, e.currentMonth, 1);
            s.setMonth(e.currentMonth + o), r.appendChild(ve(s.getFullYear(), s.getMonth()));
          }
          e.daysContainer.appendChild(r), e.days = e.daysContainer.firstChild, e.config.mode === "range" && e.selectedDates.length === 1 && St();
        }
      }
      function Q() {
        if (!(e.config.showMonths > 1 || e.config.monthSelectorType !== "dropdown")) {
          var r = function(d) {
            return e.config.minDate !== void 0 && e.currentYear === e.config.minDate.getFullYear() && d < e.config.minDate.getMonth() ? false : !(e.config.maxDate !== void 0 && e.currentYear === e.config.maxDate.getFullYear() && d > e.config.maxDate.getMonth());
          };
          e.monthsDropdownContainer.tabIndex = -1, e.monthsDropdownContainer.innerHTML = "";
          for (var o = 0; o < 12; o++)
            if (r(o)) {
              var s = k("option", "flatpickr-monthDropdown-month");
              s.value = new Date(e.currentYear, o).getMonth().toString(), s.textContent = bt(o, e.config.shorthandCurrentMonth, e.l10n), s.tabIndex = -1, e.currentMonth === o && (s.selected = true), e.monthsDropdownContainer.appendChild(s);
            }
        }
      }
      function Me() {
        var r = k("div", "flatpickr-month"), o = window.document.createDocumentFragment(), s;
        e.config.showMonths > 1 || e.config.monthSelectorType === "static" ? s = k("span", "cur-month") : (e.monthsDropdownContainer = k("select", "flatpickr-monthDropdown-months"), e.monthsDropdownContainer.setAttribute("aria-label", e.l10n.monthAriaLabel), y(e.monthsDropdownContainer, "change", function(T) {
          var w = se(T), O = parseInt(w.value, 10);
          e.changeMonth(O - e.currentMonth), j("onMonthChange");
        }), Q(), s = e.monthsDropdownContainer);
        var d = vt("cur-year", { tabindex: "-1" }), h = d.getElementsByTagName("input")[0];
        h.setAttribute("aria-label", e.l10n.yearAriaLabel), e.config.minDate && h.setAttribute("min", e.config.minDate.getFullYear().toString()), e.config.maxDate && (h.setAttribute("max", e.config.maxDate.getFullYear().toString()), h.disabled = !!e.config.minDate && e.config.minDate.getFullYear() === e.config.maxDate.getFullYear());
        var b = k("div", "flatpickr-current-month");
        return b.appendChild(s), b.appendChild(d), o.appendChild(b), r.appendChild(o), { container: r, yearElement: h, monthElement: s };
      }
      function Oe() {
        gt(e.monthNav), e.monthNav.appendChild(e.prevMonthNav), e.config.showMonths && (e.yearElements = [], e.monthElements = []);
        for (var r = e.config.showMonths; r--; ) {
          var o = Me();
          e.yearElements.push(o.yearElement), e.monthElements.push(o.monthElement), e.monthNav.appendChild(o.container);
        }
        e.monthNav.appendChild(e.nextMonthNav);
      }
      function ye() {
        return e.monthNav = k("div", "flatpickr-months"), e.yearElements = [], e.monthElements = [], e.prevMonthNav = k("span", "flatpickr-prev-month"), e.prevMonthNav.innerHTML = e.config.prevArrow, e.nextMonthNav = k("span", "flatpickr-next-month"), e.nextMonthNav.innerHTML = e.config.nextArrow, Oe(), Object.defineProperty(e, "_hidePrevMonthArrow", { get: function() {
          return e.__hidePrevMonthArrow;
        }, set: function(r) {
          e.__hidePrevMonthArrow !== r && (ne(e.prevMonthNav, "flatpickr-disabled", r), e.__hidePrevMonthArrow = r);
        } }), Object.defineProperty(e, "_hideNextMonthArrow", { get: function() {
          return e.__hideNextMonthArrow;
        }, set: function(r) {
          e.__hideNextMonthArrow !== r && (ne(e.nextMonthNav, "flatpickr-disabled", r), e.__hideNextMonthArrow = r);
        } }), e.currentYearElement = e.yearElements[0], _t(), e.monthNav;
      }
      function We() {
        e.calendarContainer.classList.add("hasTime"), e.config.noCalendar && e.calendarContainer.classList.add("noCalendar");
        var r = en(e.config);
        e.timeContainer = k("div", "flatpickr-time"), e.timeContainer.tabIndex = -1;
        var o = k("span", "flatpickr-time-separator", ":"), s = vt("flatpickr-hour", { "aria-label": e.l10n.hourAriaLabel });
        e.hourElement = s.getElementsByTagName("input")[0];
        var d = vt("flatpickr-minute", { "aria-label": e.l10n.minuteAriaLabel });
        if (e.minuteElement = d.getElementsByTagName("input")[0], e.hourElement.tabIndex = e.minuteElement.tabIndex = -1, e.hourElement.value = te(e.latestSelectedDateObj ? e.latestSelectedDateObj.getHours() : e.config.time_24hr ? r.hours : v(r.hours)), e.minuteElement.value = te(e.latestSelectedDateObj ? e.latestSelectedDateObj.getMinutes() : r.minutes), e.hourElement.setAttribute("step", e.config.hourIncrement.toString()), e.minuteElement.setAttribute("step", e.config.minuteIncrement.toString()), e.hourElement.setAttribute("min", e.config.time_24hr ? "0" : "1"), e.hourElement.setAttribute("max", e.config.time_24hr ? "23" : "12"), e.hourElement.setAttribute("maxlength", "2"), e.minuteElement.setAttribute("min", "0"), e.minuteElement.setAttribute("max", "59"), e.minuteElement.setAttribute("maxlength", "2"), e.timeContainer.appendChild(s), e.timeContainer.appendChild(o), e.timeContainer.appendChild(d), e.config.time_24hr && e.timeContainer.classList.add("time24hr"), e.config.enableSeconds) {
          e.timeContainer.classList.add("hasSeconds");
          var h = vt("flatpickr-second");
          e.secondElement = h.getElementsByTagName("input")[0], e.secondElement.value = te(e.latestSelectedDateObj ? e.latestSelectedDateObj.getSeconds() : r.seconds), e.secondElement.setAttribute("step", e.minuteElement.getAttribute("step")), e.secondElement.setAttribute("min", "0"), e.secondElement.setAttribute("max", "59"), e.secondElement.setAttribute("maxlength", "2"), e.timeContainer.appendChild(k("span", "flatpickr-time-separator", ":")), e.timeContainer.appendChild(h);
        }
        return e.config.time_24hr || (e.amPM = k("span", "flatpickr-am-pm", e.l10n.amPM[le((e.latestSelectedDateObj ? e.hourElement.value : e.config.defaultHour) > 11)]), e.amPM.title = e.l10n.toggleTitle, e.amPM.tabIndex = -1, e.timeContainer.appendChild(e.amPM)), e.timeContainer;
      }
      function Fe() {
        e.weekdayContainer ? gt(e.weekdayContainer) : e.weekdayContainer = k("div", "flatpickr-weekdays");
        for (var r = e.config.showMonths; r--; ) {
          var o = k("div", "flatpickr-weekdaycontainer");
          e.weekdayContainer.appendChild(o);
        }
        return Dt(), e.weekdayContainer;
      }
      function Dt() {
        if (e.weekdayContainer) {
          var r = e.l10n.firstDayOfWeek, o = Bi(e.l10n.weekdays.shorthand);
          r > 0 && r < o.length && (o = Bi(o.splice(r, o.length), o.splice(0, r)));
          for (var s = e.config.showMonths; s--; )
            e.weekdayContainer.children[s].innerHTML = `
      <span class='flatpickr-weekday'>
        ` + o.join("</span><span class='flatpickr-weekday'>") + `
      </span>
      `;
        }
      }
      function Bn() {
        e.calendarContainer.classList.add("hasWeeks");
        var r = k("div", "flatpickr-weekwrapper");
        r.appendChild(k("span", "flatpickr-weekday", e.l10n.weekAbbreviation));
        var o = k("div", "flatpickr-weeks");
        return r.appendChild(o), { weekWrapper: r, weekNumbers: o };
      }
      function ze(r, o) {
        o === void 0 && (o = true);
        var s = o ? r : r - e.currentMonth;
        s < 0 && e._hidePrevMonthArrow === true || s > 0 && e._hideNextMonthArrow === true || (e.currentMonth += s, (e.currentMonth < 0 || e.currentMonth > 11) && (e.currentYear += e.currentMonth > 11 ? 1 : -1, e.currentMonth = (e.currentMonth + 12) % 12, j("onYearChange"), Q()), be(), j("onMonthChange"), _t());
      }
      function nn(r, o) {
        if (r === void 0 && (r = true), o === void 0 && (o = true), e.input.value = "", e.altInput !== void 0 && (e.altInput.value = ""), e.mobileInput !== void 0 && (e.mobileInput.value = ""), e.selectedDates = [], e.latestSelectedDateObj = void 0, o === true && (e.currentYear = e._initialDate.getFullYear(), e.currentMonth = e._initialDate.getMonth()), e.config.enableTime === true) {
          var s = en(e.config), d = s.hours, h = s.minutes, b = s.seconds;
          _(d, h, b);
        }
        e.redraw(), r && j("onChange");
      }
      function Ki() {
        e.isOpen = false, e.isMobile || (e.calendarContainer !== void 0 && e.calendarContainer.classList.remove("open"), e._input !== void 0 && e._input.classList.remove("active")), j("onClose");
      }
      function Xi() {
        e.config !== void 0 && j("onDestroy");
        for (var r = e._handlers.length; r--; )
          e._handlers[r].remove();
        if (e._handlers = [], e.mobileInput)
          e.mobileInput.parentNode && e.mobileInput.parentNode.removeChild(e.mobileInput), e.mobileInput = void 0;
        else if (e.calendarContainer && e.calendarContainer.parentNode)
          if (e.config.static && e.calendarContainer.parentNode) {
            var o = e.calendarContainer.parentNode;
            if (o.lastChild && o.removeChild(o.lastChild), o.parentNode) {
              for (; o.firstChild; )
                o.parentNode.insertBefore(o.firstChild, o);
              o.parentNode.removeChild(o);
            }
          } else
            e.calendarContainer.parentNode.removeChild(e.calendarContainer);
        e.altInput && (e.input.type = "text", e.altInput.parentNode && e.altInput.parentNode.removeChild(e.altInput), delete e.altInput), e.input && (e.input.type = e.input._type, e.input.classList.remove("flatpickr-input"), e.input.removeAttribute("readonly")), ["_showTimeInput", "latestSelectedDateObj", "_hideNextMonthArrow", "_hidePrevMonthArrow", "__hideNextMonthArrow", "__hidePrevMonthArrow", "isMobile", "isOpen", "selectedDateElem", "minDateHasTime", "maxDateHasTime", "days", "daysContainer", "_input", "_positionElement", "innerContainer", "rContainer", "monthNav", "todayDateElem", "calendarContainer", "weekdayContainer", "prevMonthNav", "nextMonthNav", "monthsDropdownContainer", "currentMonthElement", "currentYearElement", "navigationCurrentMonth", "selectedDateElem", "config"].forEach(function(s) {
          try {
            delete e[s];
          } catch {
          }
        });
      }
      function et(r) {
        return e.calendarContainer.contains(r);
      }
      function rn(r) {
        if (e.isOpen && !e.config.inline) {
          var o = se(r), s = et(o), d = o === e.input || o === e.altInput || e.element.contains(o) || r.path && r.path.indexOf && (~r.path.indexOf(e.input) || ~r.path.indexOf(e.altInput)), h = !d && !s && !et(r.relatedTarget), b = !e.config.ignoredFocusElements.some(function(T) {
            return T.contains(o);
          });
          h && b && (e.config.allowInput && e.setDate(e._input.value, false, e.config.altInput ? e.config.altFormat : e.config.dateFormat), e.timeContainer !== void 0 && e.minuteElement !== void 0 && e.hourElement !== void 0 && e.input.value !== "" && e.input.value !== void 0 && f(), e.close(), e.config && e.config.mode === "range" && e.selectedDates.length === 1 && e.clear(false));
        }
      }
      function wt(r) {
        if (!(!r || e.config.minDate && r < e.config.minDate.getFullYear() || e.config.maxDate && r > e.config.maxDate.getFullYear())) {
          var o = r, s = e.currentYear !== o;
          e.currentYear = o || e.currentYear, e.config.maxDate && e.currentYear === e.config.maxDate.getFullYear() ? e.currentMonth = Math.min(e.config.maxDate.getMonth(), e.currentMonth) : e.config.minDate && e.currentYear === e.config.minDate.getFullYear() && (e.currentMonth = Math.max(e.config.minDate.getMonth(), e.currentMonth)), s && (e.redraw(), j("onYearChange"), Q());
        }
      }
      function He(r, o) {
        var s;
        o === void 0 && (o = true);
        var d = e.parseDate(r, void 0, o);
        if (e.config.minDate && d && ue(d, e.config.minDate, o !== void 0 ? o : !e.minDateHasTime) < 0 || e.config.maxDate && d && ue(d, e.config.maxDate, o !== void 0 ? o : !e.maxDateHasTime) > 0)
          return false;
        if (!e.config.enable && e.config.disable.length === 0)
          return true;
        if (d === void 0)
          return false;
        for (var h = !!e.config.enable, b = (s = e.config.enable) !== null && s !== void 0 ? s : e.config.disable, T = 0, w = void 0; T < b.length; T++) {
          if (w = b[T], typeof w == "function" && w(d))
            return h;
          if (w instanceof Date && d !== void 0 && w.getTime() === d.getTime())
            return h;
          if (typeof w == "string") {
            var O = e.parseDate(w, void 0, true);
            return O && O.getTime() === d.getTime() ? h : !h;
          } else if (typeof w == "object" && d !== void 0 && w.from && w.to && d.getTime() >= w.from.getTime() && d.getTime() <= w.to.getTime())
            return h;
        }
        return !h;
      }
      function Et(r) {
        return e.daysContainer !== void 0 ? r.className.indexOf("hidden") === -1 && r.className.indexOf("flatpickr-disabled") === -1 && e.daysContainer.contains(r) : false;
      }
      function Gi(r) {
        var o = r.target === e._input, s = e._input.value.trimEnd() !== sn();
        o && s && !(r.relatedTarget && et(r.relatedTarget)) && e.setDate(e._input.value, true, r.target === e.altInput ? e.config.altFormat : e.config.dateFormat);
      }
      function Wn(r) {
        var o = se(r), s = e.config.wrap ? n.contains(o) : o === e._input, d = e.config.allowInput, h = e.isOpen && (!d || !s), b = e.config.inline && s && !d;
        if (r.keyCode === 13 && s) {
          if (d)
            return e.setDate(e._input.value, true, o === e.altInput ? e.config.altFormat : e.config.dateFormat), e.close(), o.blur();
          e.open();
        } else if (et(o) || h || b) {
          var T = !!e.timeContainer && e.timeContainer.contains(o);
          switch (r.keyCode) {
            case 13:
              T ? (r.preventDefault(), f(), an()) : Gn(r);
              break;
            case 27:
              r.preventDefault(), an();
              break;
            case 8:
            case 46:
              s && !e.config.allowInput && (r.preventDefault(), e.clear());
              break;
            case 37:
            case 39:
              if (!T && !s) {
                r.preventDefault();
                var w = l();
                if (e.daysContainer !== void 0 && (d === false || w && Et(w))) {
                  var O = r.keyCode === 39 ? 1 : -1;
                  r.ctrlKey ? (r.stopPropagation(), ze(O), me(V(1), 0)) : me(void 0, O);
                }
              } else
                e.hourElement && e.hourElement.focus();
              break;
            case 38:
            case 40:
              r.preventDefault();
              var D = r.keyCode === 40 ? 1 : -1;
              e.daysContainer && o.$i !== void 0 || o === e.input || o === e.altInput ? r.ctrlKey ? (r.stopPropagation(), wt(e.currentYear - D), me(V(1), 0)) : T || me(void 0, D * 7) : o === e.currentYearElement ? wt(e.currentYear - D) : e.config.enableTime && (!T && e.hourElement && e.hourElement.focus(), f(r), e._debouncedChange());
              break;
            case 9:
              if (T) {
                var M = [e.hourElement, e.minuteElement, e.secondElement, e.amPM].concat(e.pluginElements).filter(function(ce) {
                  return ce;
                }), L = M.indexOf(o);
                if (L !== -1) {
                  var De = M[L + (r.shiftKey ? -1 : 1)];
                  r.preventDefault(), (De || e._input).focus();
                }
              } else
                !e.config.noCalendar && e.daysContainer && e.daysContainer.contains(o) && r.shiftKey && (r.preventDefault(), e._input.focus());
              break;
            default:
              break;
          }
        }
        if (e.amPM !== void 0 && o === e.amPM)
          switch (r.key) {
            case e.l10n.amPM[0].charAt(0):
            case e.l10n.amPM[0].charAt(0).toLowerCase():
              e.amPM.textContent = e.l10n.amPM[0], g(), _e();
              break;
            case e.l10n.amPM[1].charAt(0):
            case e.l10n.amPM[1].charAt(0).toLowerCase():
              e.amPM.textContent = e.l10n.amPM[1], g(), _e();
              break;
          }
        (s || et(o)) && j("onKeyDown", r);
      }
      function St(r, o) {
        if (o === void 0 && (o = "flatpickr-day"), !(e.selectedDates.length !== 1 || r && (!r.classList.contains(o) || r.classList.contains("flatpickr-disabled")))) {
          for (var s = r ? r.dateObj.getTime() : e.days.firstElementChild.dateObj.getTime(), d = e.parseDate(e.selectedDates[0], void 0, true).getTime(), h = Math.min(s, e.selectedDates[0].getTime()), b = Math.max(s, e.selectedDates[0].getTime()), T = false, w = 0, O = 0, D = h; D < b; D += Ri.DAY)
            He(new Date(D), true) || (T = T || D > h && D < b, D < d && (!w || D > w) ? w = D : D > d && (!O || D < O) && (O = D));
          var M = Array.from(e.rContainer.querySelectorAll("*:nth-child(-n+" + e.config.showMonths + ") > ." + o));
          M.forEach(function(L) {
            var De = L.dateObj, ce = De.getTime(), tt = w > 0 && ce < w || O > 0 && ce > O;
            if (tt) {
              L.classList.add("notAllowed"), ["inRange", "startRange", "endRange"].forEach(function(qe) {
                L.classList.remove(qe);
              });
              return;
            } else if (T && !tt)
              return;
            ["startRange", "inRange", "endRange", "notAllowed"].forEach(function(qe) {
              L.classList.remove(qe);
            }), r !== void 0 && (r.classList.add(s <= e.selectedDates[0].getTime() ? "startRange" : "endRange"), d < s && ce === d ? L.classList.add("startRange") : d > s && ce === d && L.classList.add("endRange"), ce >= w && (O === 0 || ce <= O) && Yi(ce, d, s) && L.classList.add("inRange"));
          });
        }
      }
      function $i() {
        e.isOpen && !e.config.static && !e.config.inline && Ct();
      }
      function Ui(r, o) {
        if (o === void 0 && (o = e._positionElement), e.isMobile === true) {
          if (r) {
            r.preventDefault();
            var s = se(r);
            s && s.blur();
          }
          e.mobileInput !== void 0 && (e.mobileInput.focus(), e.mobileInput.click()), j("onOpen");
          return;
        } else if (e._input.disabled || e.config.inline)
          return;
        var d = e.isOpen;
        e.isOpen = true, d || (e.calendarContainer.classList.add("open"), e._input.classList.add("active"), j("onOpen"), Ct(o)), e.config.enableTime === true && e.config.noCalendar === true && e.config.allowInput === false && (r === void 0 || !e.timeContainer.contains(r.relatedTarget)) && setTimeout(function() {
          return e.hourElement.select();
        }, 50);
      }
      function zn(r) {
        return function(o) {
          var s = e.config["_" + r + "Date"] = e.parseDate(o, e.config.dateFormat), d = e.config["_" + (r === "min" ? "max" : "min") + "Date"];
          s !== void 0 && (e[r === "min" ? "minDateHasTime" : "maxDateHasTime"] = s.getHours() > 0 || s.getMinutes() > 0 || s.getSeconds() > 0), e.selectedDates && (e.selectedDates = e.selectedDates.filter(function(h) {
            return He(h);
          }), !e.selectedDates.length && r === "min" && E(s), _e()), e.daysContainer && (Xn(), s !== void 0 ? e.currentYearElement[r] = s.getFullYear().toString() : e.currentYearElement.removeAttribute(r), e.currentYearElement.disabled = !!d && s !== void 0 && d.getFullYear() === s.getFullYear());
        };
      }
      function Ji() {
        var r = ["wrap", "weekNumbers", "allowInput", "allowInvalidPreload", "clickOpens", "time_24hr", "enableTime", "noCalendar", "altInput", "shorthandCurrentMonth", "inline", "static", "enableSeconds", "disableMobile"], o = ie(ie({}, JSON.parse(JSON.stringify(n.dataset || {}))), t), s = {};
        e.config.parseDate = o.parseDate, e.config.formatDate = o.formatDate, Object.defineProperty(e.config, "enable", { get: function() {
          return e.config._enable;
        }, set: function(M) {
          e.config._enable = Un(M);
        } }), Object.defineProperty(e.config, "disable", { get: function() {
          return e.config._disable;
        }, set: function(M) {
          e.config._disable = Un(M);
        } });
        var d = o.mode === "time";
        if (!o.dateFormat && (o.enableTime || d)) {
          var h = G.defaultConfig.dateFormat || Le.dateFormat;
          s.dateFormat = o.noCalendar || d ? "H:i" + (o.enableSeconds ? ":S" : "") : h + " H:i" + (o.enableSeconds ? ":S" : "");
        }
        if (o.altInput && (o.enableTime || d) && !o.altFormat) {
          var b = G.defaultConfig.altFormat || Le.altFormat;
          s.altFormat = o.noCalendar || d ? "h:i" + (o.enableSeconds ? ":S K" : " K") : b + (" h:i" + (o.enableSeconds ? ":S" : "") + " K");
        }
        Object.defineProperty(e.config, "minDate", { get: function() {
          return e.config._minDate;
        }, set: zn("min") }), Object.defineProperty(e.config, "maxDate", { get: function() {
          return e.config._maxDate;
        }, set: zn("max") });
        var T = function(M) {
          return function(L) {
            e.config[M === "min" ? "_minTime" : "_maxTime"] = e.parseDate(L, "H:i:S");
          };
        };
        Object.defineProperty(e.config, "minTime", { get: function() {
          return e.config._minTime;
        }, set: T("min") }), Object.defineProperty(e.config, "maxTime", { get: function() {
          return e.config._maxTime;
        }, set: T("max") }), o.mode === "time" && (e.config.noCalendar = true, e.config.enableTime = true), Object.assign(e.config, s, o);
        for (var w = 0; w < r.length; w++)
          e.config[r[w]] = e.config[r[w]] === true || e.config[r[w]] === "true";
        $t.filter(function(M) {
          return e.config[M] !== void 0;
        }).forEach(function(M) {
          e.config[M] = Vt(e.config[M] || []).map(u);
        }), e.isMobile = !e.config.disableMobile && !e.config.inline && e.config.mode === "single" && !e.config.disable.length && !e.config.enable && !e.config.weekNumbers && /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
        for (var w = 0; w < e.config.plugins.length; w++) {
          var O = e.config.plugins[w](e) || {};
          for (var D in O)
            $t.indexOf(D) > -1 ? e.config[D] = Vt(O[D]).map(u).concat(e.config[D]) : typeof o[D] > "u" && (e.config[D] = O[D]);
        }
        o.altInputClass || (e.config.altInputClass = qn().className + " " + e.config.altInputClass), j("onParseConfig");
      }
      function qn() {
        return e.config.wrap ? n.querySelector("[data-input]") : n;
      }
      function Kn() {
        typeof e.config.locale != "object" && typeof G.l10ns[e.config.locale] > "u" && e.config.errorHandler(new Error("flatpickr: invalid locale " + e.config.locale)), e.l10n = ie(ie({}, G.l10ns.default), typeof e.config.locale == "object" ? e.config.locale : e.config.locale !== "default" ? G.l10ns[e.config.locale] : void 0), Ae.D = "(" + e.l10n.weekdays.shorthand.join("|") + ")", Ae.l = "(" + e.l10n.weekdays.longhand.join("|") + ")", Ae.M = "(" + e.l10n.months.shorthand.join("|") + ")", Ae.F = "(" + e.l10n.months.longhand.join("|") + ")", Ae.K = "(" + e.l10n.amPM[0] + "|" + e.l10n.amPM[1] + "|" + e.l10n.amPM[0].toLowerCase() + "|" + e.l10n.amPM[1].toLowerCase() + ")";
        var r = ie(ie({}, t), JSON.parse(JSON.stringify(n.dataset || {})));
        r.time_24hr === void 0 && G.defaultConfig.time_24hr === void 0 && (e.config.time_24hr = e.l10n.time_24hr), e.formatDate = Yn(e), e.parseDate = Zt({ config: e.config, l10n: e.l10n });
      }
      function Ct(r) {
        if (typeof e.config.position == "function")
          return void e.config.position(e, r);
        if (e.calendarContainer !== void 0) {
          j("onPreCalendarPosition");
          var o = r || e._positionElement, s = Array.prototype.reduce.call(e.calendarContainer.children, function(mr, gr) {
            return mr + gr.offsetHeight;
          }, 0), d = e.calendarContainer.offsetWidth, h = e.config.position.split(" "), b = h[0], T = h.length > 1 ? h[1] : null, w = o.getBoundingClientRect(), O = window.innerHeight - w.bottom, D = b === "above" || b !== "below" && O < s && w.top > s, M = window.pageYOffset + w.top + (D ? -s - 2 : o.offsetHeight + 2);
          if (ne(e.calendarContainer, "arrowTop", !D), ne(e.calendarContainer, "arrowBottom", D), !e.config.inline) {
            var L = window.pageXOffset + w.left, De = false, ce = false;
            T === "center" ? (L -= (d - w.width) / 2, De = true) : T === "right" && (L -= d - w.width, ce = true), ne(e.calendarContainer, "arrowLeft", !De && !ce), ne(e.calendarContainer, "arrowCenter", De), ne(e.calendarContainer, "arrowRight", ce);
            var tt = window.document.body.offsetWidth - (window.pageXOffset + w.right), qe = L + d > window.document.body.offsetWidth, sr = tt + d > window.document.body.offsetWidth;
            if (ne(e.calendarContainer, "rightMost", qe), !e.config.static)
              if (e.calendarContainer.style.top = M + "px", !qe)
                e.calendarContainer.style.left = L + "px", e.calendarContainer.style.right = "auto";
              else if (!sr)
                e.calendarContainer.style.left = "auto", e.calendarContainer.style.right = tt + "px";
              else {
                var un = Vi();
                if (un === void 0)
                  return;
                var ur = window.document.body.offsetWidth, cr = Math.max(0, ur / 2 - d / 2), dr = ".flatpickr-calendar.centerMost:before", fr = ".flatpickr-calendar.centerMost:after", pr = un.cssRules.length, hr = "{left:" + w.left + "px;right:auto;}";
                ne(e.calendarContainer, "rightMost", false), ne(e.calendarContainer, "centerMost", true), un.insertRule(dr + "," + fr + hr, pr), e.calendarContainer.style.left = cr + "px", e.calendarContainer.style.right = "auto";
              }
          }
        }
      }
      function Vi() {
        for (var r = null, o = 0; o < document.styleSheets.length; o++) {
          var s = document.styleSheets[o];
          if (s.cssRules) {
            try {
              s.cssRules;
            } catch {
              continue;
            }
            r = s;
            break;
          }
        }
        return r ?? Zi();
      }
      function Zi() {
        var r = document.createElement("style");
        return document.head.appendChild(r), r.sheet;
      }
      function Xn() {
        e.config.noCalendar || e.isMobile || (Q(), _t(), be());
      }
      function an() {
        e._input.focus(), window.navigator.userAgent.indexOf("MSIE") !== -1 || navigator.msMaxTouchPoints !== void 0 ? setTimeout(e.close, 0) : e.close();
      }
      function Gn(r) {
        r.preventDefault(), r.stopPropagation();
        var o = function(M) {
          return M.classList && M.classList.contains("flatpickr-day") && !M.classList.contains("flatpickr-disabled") && !M.classList.contains("notAllowed");
        }, s = Ln(se(r), o);
        if (s !== void 0) {
          var d = s, h = e.latestSelectedDateObj = new Date(d.dateObj.getTime()), b = (h.getMonth() < e.currentMonth || h.getMonth() > e.currentMonth + e.config.showMonths - 1) && e.config.mode !== "range";
          if (e.selectedDateElem = d, e.config.mode === "single")
            e.selectedDates = [h];
          else if (e.config.mode === "multiple") {
            var T = ln(h);
            T ? e.selectedDates.splice(parseInt(T), 1) : e.selectedDates.push(h);
          } else
            e.config.mode === "range" && (e.selectedDates.length === 2 && e.clear(false, false), e.latestSelectedDateObj = h, e.selectedDates.push(h), ue(h, e.selectedDates[0], true) !== 0 && e.selectedDates.sort(function(M, L) {
              return M.getTime() - L.getTime();
            }));
          if (g(), b) {
            var w = e.currentYear !== h.getFullYear();
            e.currentYear = h.getFullYear(), e.currentMonth = h.getMonth(), w && (j("onYearChange"), Q()), j("onMonthChange");
          }
          if (_t(), be(), _e(), !b && e.config.mode !== "range" && e.config.showMonths === 1 ? Y(d) : e.selectedDateElem !== void 0 && e.hourElement === void 0 && e.selectedDateElem && e.selectedDateElem.focus(), e.hourElement !== void 0 && e.hourElement !== void 0 && e.hourElement.focus(), e.config.closeOnSelect) {
            var O = e.config.mode === "single" && !e.config.enableTime, D = e.config.mode === "range" && e.selectedDates.length === 2 && !e.config.enableTime;
            (O || D) && an();
          }
          B();
        }
      }
      var Mt = { locale: [Kn, Dt], showMonths: [Oe, c, Fe], minDate: [P], maxDate: [P], positionElement: [Jn], clickOpens: [function() {
        e.config.clickOpens === true ? (y(e._input, "focus", e.open), y(e._input, "click", e.open)) : (e._input.removeEventListener("focus", e.open), e._input.removeEventListener("click", e.open));
      }] };
      function Qi(r, o) {
        if (r !== null && typeof r == "object") {
          Object.assign(e.config, r);
          for (var s in r)
            Mt[s] !== void 0 && Mt[s].forEach(function(d) {
              return d();
            });
        } else
          e.config[r] = o, Mt[r] !== void 0 ? Mt[r].forEach(function(d) {
            return d();
          }) : $t.indexOf(r) > -1 && (e.config[r] = Vt(o));
        e.redraw(), _e(true);
      }
      function $n(r, o) {
        var s = [];
        if (r instanceof Array)
          s = r.map(function(d) {
            return e.parseDate(d, o);
          });
        else if (r instanceof Date || typeof r == "number")
          s = [e.parseDate(r, o)];
        else if (typeof r == "string")
          switch (e.config.mode) {
            case "single":
            case "time":
              s = [e.parseDate(r, o)];
              break;
            case "multiple":
              s = r.split(e.config.conjunction).map(function(d) {
                return e.parseDate(d, o);
              });
              break;
            case "range":
              s = r.split(e.l10n.rangeSeparator).map(function(d) {
                return e.parseDate(d, o);
              });
              break;
            default:
              break;
          }
        else
          e.config.errorHandler(new Error("Invalid date supplied: " + JSON.stringify(r)));
        e.selectedDates = e.config.allowInvalidPreload ? s : s.filter(function(d) {
          return d instanceof Date && He(d, false);
        }), e.config.mode === "range" && e.selectedDates.sort(function(d, h) {
          return d.getTime() - h.getTime();
        });
      }
      function er(r, o, s) {
        if (o === void 0 && (o = false), s === void 0 && (s = e.config.dateFormat), r !== 0 && !r || r instanceof Array && r.length === 0)
          return e.clear(o);
        $n(r, s), e.latestSelectedDateObj = e.selectedDates[e.selectedDates.length - 1], e.redraw(), P(void 0, o), E(), e.selectedDates.length === 0 && e.clear(false), _e(o), o && j("onChange");
      }
      function Un(r) {
        return r.slice().map(function(o) {
          return typeof o == "string" || typeof o == "number" || o instanceof Date ? e.parseDate(o, void 0, true) : o && typeof o == "object" && o.from && o.to ? { from: e.parseDate(o.from, void 0), to: e.parseDate(o.to, void 0) } : o;
        }).filter(function(o) {
          return o;
        });
      }
      function tr() {
        e.selectedDates = [], e.now = e.parseDate(e.config.now) || /* @__PURE__ */ new Date();
        var r = e.config.defaultDate || ((e.input.nodeName === "INPUT" || e.input.nodeName === "TEXTAREA") && e.input.placeholder && e.input.value === e.input.placeholder ? null : e.input.value);
        r && $n(r, e.config.dateFormat), e._initialDate = e.selectedDates.length > 0 ? e.selectedDates[0] : e.config.minDate && e.config.minDate.getTime() > e.now.getTime() ? e.config.minDate : e.config.maxDate && e.config.maxDate.getTime() < e.now.getTime() ? e.config.maxDate : e.now, e.currentYear = e._initialDate.getFullYear(), e.currentMonth = e._initialDate.getMonth(), e.selectedDates.length > 0 && (e.latestSelectedDateObj = e.selectedDates[0]), e.config.minTime !== void 0 && (e.config.minTime = e.parseDate(e.config.minTime, "H:i")), e.config.maxTime !== void 0 && (e.config.maxTime = e.parseDate(e.config.maxTime, "H:i")), e.minDateHasTime = !!e.config.minDate && (e.config.minDate.getHours() > 0 || e.config.minDate.getMinutes() > 0 || e.config.minDate.getSeconds() > 0), e.maxDateHasTime = !!e.config.maxDate && (e.config.maxDate.getHours() > 0 || e.config.maxDate.getMinutes() > 0 || e.config.maxDate.getSeconds() > 0);
      }
      function nr() {
        if (e.input = qn(), !e.input) {
          e.config.errorHandler(new Error("Invalid input element specified"));
          return;
        }
        e.input._type = e.input.type, e.input.type = "text", e.input.classList.add("flatpickr-input"), e._input = e.input, e.config.altInput && (e.altInput = k(e.input.nodeName, e.config.altInputClass), e._input = e.altInput, e.altInput.placeholder = e.input.placeholder, e.altInput.disabled = e.input.disabled, e.altInput.required = e.input.required, e.altInput.tabIndex = e.input.tabIndex, e.altInput.type = "text", e.input.setAttribute("type", "hidden"), !e.config.static && e.input.parentNode && e.input.parentNode.insertBefore(e.altInput, e.input.nextSibling)), e.config.allowInput || e._input.setAttribute("readonly", "readonly"), Jn();
      }
      function Jn() {
        e._positionElement = e.config.positionElement || e._input;
      }
      function ir() {
        var r = e.config.enableTime ? e.config.noCalendar ? "time" : "datetime-local" : "date";
        e.mobileInput = k("input", e.input.className + " flatpickr-mobile"), e.mobileInput.tabIndex = 1, e.mobileInput.type = r, e.mobileInput.disabled = e.input.disabled, e.mobileInput.required = e.input.required, e.mobileInput.placeholder = e.input.placeholder, e.mobileFormatStr = r === "datetime-local" ? "Y-m-d\\TH:i:S" : r === "date" ? "Y-m-d" : "H:i:S", e.selectedDates.length > 0 && (e.mobileInput.defaultValue = e.mobileInput.value = e.formatDate(e.selectedDates[0], e.mobileFormatStr)), e.config.minDate && (e.mobileInput.min = e.formatDate(e.config.minDate, "Y-m-d")), e.config.maxDate && (e.mobileInput.max = e.formatDate(e.config.maxDate, "Y-m-d")), e.input.getAttribute("step") && (e.mobileInput.step = String(e.input.getAttribute("step"))), e.input.type = "hidden", e.altInput !== void 0 && (e.altInput.type = "hidden");
        try {
          e.input.parentNode && e.input.parentNode.insertBefore(e.mobileInput, e.input.nextSibling);
        } catch {
        }
        y(e.mobileInput, "change", function(o) {
          e.setDate(se(o).value, false, e.mobileFormatStr), j("onChange"), j("onClose");
        });
      }
      function rr(r) {
        if (e.isOpen === true)
          return e.close();
        e.open(r);
      }
      function j(r, o) {
        if (e.config !== void 0) {
          var s = e.config[r];
          if (s !== void 0 && s.length > 0)
            for (var d = 0; s[d] && d < s.length; d++)
              s[d](e.selectedDates, e.input.value, e, o);
          r === "onChange" && (e.input.dispatchEvent(on("change")), e.input.dispatchEvent(on("input")));
        }
      }
      function on(r) {
        var o = document.createEvent("Event");
        return o.initEvent(r, true, true), o;
      }
      function ln(r) {
        for (var o = 0; o < e.selectedDates.length; o++) {
          var s = e.selectedDates[o];
          if (s instanceof Date && ue(s, r) === 0)
            return "" + o;
        }
        return false;
      }
      function ar(r) {
        return e.config.mode !== "range" || e.selectedDates.length < 2 ? false : ue(r, e.selectedDates[0]) >= 0 && ue(r, e.selectedDates[1]) <= 0;
      }
      function _t() {
        e.config.noCalendar || e.isMobile || !e.monthNav || (e.yearElements.forEach(function(r, o) {
          var s = new Date(e.currentYear, e.currentMonth, 1);
          s.setMonth(e.currentMonth + o), e.config.showMonths > 1 || e.config.monthSelectorType === "static" ? e.monthElements[o].textContent = bt(s.getMonth(), e.config.shorthandCurrentMonth, e.l10n) + " " : e.monthsDropdownContainer.value = s.getMonth().toString(), r.value = s.getFullYear().toString();
        }), e._hidePrevMonthArrow = e.config.minDate !== void 0 && (e.currentYear === e.config.minDate.getFullYear() ? e.currentMonth <= e.config.minDate.getMonth() : e.currentYear < e.config.minDate.getFullYear()), e._hideNextMonthArrow = e.config.maxDate !== void 0 && (e.currentYear === e.config.maxDate.getFullYear() ? e.currentMonth + 1 > e.config.maxDate.getMonth() : e.currentYear > e.config.maxDate.getFullYear()));
      }
      function sn(r) {
        var o = r || (e.config.altInput ? e.config.altFormat : e.config.dateFormat);
        return e.selectedDates.map(function(s) {
          return e.formatDate(s, o);
        }).filter(function(s, d, h) {
          return e.config.mode !== "range" || e.config.enableTime || h.indexOf(s) === d;
        }).join(e.config.mode !== "range" ? e.config.conjunction : e.l10n.rangeSeparator);
      }
      function _e(r) {
        r === void 0 && (r = true), e.mobileInput !== void 0 && e.mobileFormatStr && (e.mobileInput.value = e.latestSelectedDateObj !== void 0 ? e.formatDate(e.latestSelectedDateObj, e.mobileFormatStr) : ""), e.input.value = sn(e.config.dateFormat), e.altInput !== void 0 && (e.altInput.value = sn(e.config.altFormat)), r !== false && j("onValueUpdate");
      }
      function or(r) {
        var o = se(r), s = e.prevMonthNav.contains(o), d = e.nextMonthNav.contains(o);
        s || d ? ze(s ? -1 : 1) : e.yearElements.indexOf(o) >= 0 ? o.select() : o.classList.contains("arrowUp") ? e.changeYear(e.currentYear + 1) : o.classList.contains("arrowDown") && e.changeYear(e.currentYear - 1);
      }
      function lr(r) {
        r.preventDefault();
        var o = r.type === "keydown", s = se(r), d = s;
        e.amPM !== void 0 && s === e.amPM && (e.amPM.textContent = e.l10n.amPM[le(e.amPM.textContent === e.l10n.amPM[0])]);
        var h = parseFloat(d.getAttribute("min")), b = parseFloat(d.getAttribute("max")), T = parseFloat(d.getAttribute("step")), w = parseInt(d.value, 10), O = r.delta || (o ? r.which === 38 ? 1 : -1 : 0), D = w + T * O;
        if (typeof d.value < "u" && d.value.length === 2) {
          var M = d === e.hourElement, L = d === e.minuteElement;
          D < h ? (D = b + D + le(!M) + (le(M) && le(!e.amPM)), L && W(void 0, -1, e.hourElement)) : D > b && (D = d === e.hourElement ? D - b - le(!e.amPM) : h, L && W(void 0, 1, e.hourElement)), e.amPM && M && (T === 1 ? D + w === 23 : Math.abs(D - w) > T) && (e.amPM.textContent = e.l10n.amPM[le(e.amPM.textContent === e.l10n.amPM[0])]), d.value = te(D);
        }
      }
      return a(), e;
    }
    function Qe(n, t) {
      for (var e = Array.prototype.slice.call(n).filter(function(u) {
        return u instanceof HTMLElement;
      }), i = [], a = 0; a < e.length; a++) {
        var l = e[a];
        try {
          if (l.getAttribute("data-fp-omit") !== null)
            continue;
          l._flatpickr !== void 0 && (l._flatpickr.destroy(), l._flatpickr = void 0), l._flatpickr = Ha(l, t || {}), i.push(l._flatpickr);
        } catch (u) {
          console.error(u);
        }
      }
      return i.length === 1 ? i[0] : i;
    }
    typeof HTMLElement < "u" && typeof HTMLCollection < "u" && typeof NodeList < "u" && (HTMLCollection.prototype.flatpickr = NodeList.prototype.flatpickr = function(n) {
      return Qe(this, n);
    }, HTMLElement.prototype.flatpickr = function(n) {
      return Qe([this], n);
    });
    var G = function(n, t) {
      return typeof n == "string" ? Qe(window.document.querySelectorAll(n), t) : n instanceof Node ? Qe([n], t) : Qe(n, t);
    };
    G.defaultConfig = {};
    G.l10ns = { en: ie({}, Jt), default: ie({}, Jt) };
    G.localize = function(n) {
      G.l10ns.default = ie(ie({}, G.l10ns.default), n);
    };
    G.setDefaults = function(n) {
      G.defaultConfig = ie(ie({}, G.defaultConfig), n);
    };
    G.parseDate = Zt({});
    G.formatDate = Yn({});
    G.compareDates = ue;
    typeof jQuery < "u" && typeof jQuery.fn < "u" && (jQuery.fn.flatpickr = function(n) {
      return Qe(this, n);
    });
    Date.prototype.fp_incr = function(n) {
      return new Date(this.getFullYear(), this.getMonth(), this.getDate() + (typeof n == "string" ? parseInt(n, 10) : n));
    };
    typeof window < "u" && (window.flatpickr = G);
    var Wi = G;
    function jn(n = document) {
      n === "" ? n = document : n instanceof String && (n = document.querySelectorAll(n));
      let t = n.querySelectorAll("input[data-datepicker-type]");
      Alchemy.isiOS ? t.forEach((e) => {
        e.attributes.type = e.dataset.datepickerType;
      }) : t.forEach((e) => {
        let i = e.dataset.datepickerType, a = { locale: Alchemy.locale.slice(0, 2), altInput: true, altFormat: Alchemy.t(`formats.${i}`), altInputClass: "flatpickr-input", enableTime: /time/.test(i), noCalendar: i === "time", time_24hr: Alchemy.t("formats.time_24hr"), onValueUpdate(l, u, c) {
          return Alchemy.setElementDirty(c.element.closest(".element-editor"));
        } };
        Wi(e, a);
      });
    }
    function Ya(n) {
      let t = n.item.dataset.pageId, e = Alchemy.routes.move_admin_page_path(t), i = { target_parent_id: n.to.dataset.parentId, new_position: n.newIndex };
      Be(e, i).then(async (a) => {
        let l = await a.data, c = document.getElementById(`page_${t}`).querySelector(".sitemap_url");
        Alchemy.growl(Alchemy.t("Successfully moved page")), c.textContent = l.url_path, tn();
      }).catch((a) => {
        Alchemy.growl(a.message || a, "error");
      });
    }
    function tn() {
      document.querySelectorAll("li.sitemap-item").forEach((n) => {
        let t = n.querySelector(".page_folder"), e = n.querySelector(".children"), i = { folded: n.dataset.folded === "true", id: n.dataset.pageId, type: n.dataset.type };
        e.children.length > 0 || i.folded ? t.outerHTML = HandlebarsTemplates.page_folder({ page: i }) : t.innerHTML = "";
      });
    }
    function Rn(n) {
      n.forEach((t) => {
        new Wt(t, { group: "pages", animation: 150, fallbackOnBody: true, swapThreshold: 0.65, handle: ".handle", onEnd: Ya });
      });
    }
    function zi() {
      let n = document.querySelectorAll("ul.children");
      tn(), Rn(n);
    }
    var yt = class {
      constructor(t) {
        let e = document.getElementById("sitemap-list").innerHTML.replace(/__ID__/g, "{{id}}");
        this.search_field = document.querySelector(".search_input_field"), this.filter_field_clear = document.querySelector(".search_field_clear"), this.filter_field_clear.removeAttribute("href"), this.display = document.getElementById("page_filter_result"), this.sitemap_wrapper = document.getElementById("sitemap-wrapper"), this.template = Handlebars.compile(document.getElementById("sitemap-template").innerHTML), this.list_template = Handlebars.compile(e), this.items = null, this.options = t, Handlebars.registerPartial("list", e), this.load(t.page_root_id);
      }
      load(t) {
        let e = new Alchemy.Spinner("medium"), i = this.sitemap_wrapper;
        i.innerHTML = "", e.spin(i), zt(this.options.url, { id: t }).then(async (a) => {
          this.render(await a.data), this.handlePageFolders(), e.stop();
        }).catch(this.errorHandler);
      }
      handlePageFolders() {
        qt("click", "#sitemap", ".page_folder", function(t) {
          let e = new Alchemy.Spinner("small"), i = t.target.closest(".page_folder"), a = i.dataset.pageId;
          i.innerHTML = "", e.spin(i), Be(Alchemy.routes.fold_admin_page_path(a)).then(async (l) => {
            this.reRender(a, await l.data), e.stop();
          }).catch(this.errorHandler);
        }.bind(this));
      }
      render(t) {
        let e = this.sitemap_wrapper, i = this.template;
        e.innerHTML = i({ children: t.pages }), this.items = document.getElementById("sitemap").querySelectorAll(".sitemap_page"), this.sitemap_wrapper = document.getElementById("sitemap-wrapper"), this._observe(), zi();
      }
      reRender(t, e) {
        let i = document.getElementById(`page_${t}`);
        i.outerHTML = this.list_template({ children: e.pages }), i = document.getElementById(`page_${t}`);
        let a = i.querySelectorAll("ul.children");
        Rn(a), tn();
      }
      filter(t) {
        let e = [];
        this.items.forEach(function(a) {
          t !== "" && a.getAttribute("name").toLowerCase().indexOf(t) !== -1 ? (a.classList.add("highlight"), a.classList.remove("no-match"), e.push(a)) : (a.classList.add("no-match"), a.classList.remove("highlight"));
        }), this.filter_field_clear.style.display = "inline-block";
        let { length: i } = e;
        i === 1 ? (this.display.style.display = "block", this.display.innerText = `1 ${Alchemy.t("page_found")}`, e[0].scrollIntoView({ behavior: "smooth", block: "center" })) : i > 1 ? (this.display.style.display = "block", this.display.innerText = `${i} ${Alchemy.t("pages_found")}`) : (this.items.forEach((a) => a.classList.remove("no-match", "highlight")), this.display.style.display = "none", window.scrollTo({ top: 0, left: 0, behavior: "smooth" }), this.filter_field_clear.style.display = "none");
      }
      _observe() {
        this.search_field.addEventListener("keyup", (t) => {
          let e = t.target.value;
          this.filter(e.toLowerCase());
        }), this.search_field.addEventListener("focus", () => key.setScope("search")), this.filter_field_clear.addEventListener("click", () => (this.search_field.value = "", this.filter(""), false));
      }
      errorHandler(t) {
        Alchemy.growl(t.message || t, "error"), console.error(t);
      }
    };
    function qi() {
      document.addEventListener("DialogReady.Alchemy", function(n) {
        let t = n.detail.body, e = t.querySelector("#page_public_on"), i = t.querySelector("#page_public_until"), a = t.querySelector(".page-publication-date-fields"), l = t.querySelector("#page_public");
        l && l.addEventListener("click", function(u) {
          let c = u.target, f = /* @__PURE__ */ new Date();
          c.checked ? (a.classList.remove("hidden"), e._flatpickr.setDate(f)) : (a.classList.add("hidden"), e.value = ""), i.value = "";
        });
      });
    }
    typeof window.Alchemy > "u" && (window.Alchemy = {});
    Object.assign(Alchemy, { t: cn, translations: Object.assign(Alchemy.translations || {}, Zn), NodeTree: In, fileEditors: On, pictureEditors: Nn, ImageLoader: Ce.init, ImageCropper: mt, IngredientAnchorLink: ft, Datepicker: jn, Sitemap: yt, PagePublicationFields: qi });
  })();
})();
/*! Bundled license information:

@alchemy_cms/admin/package/dist/admin.js:
  (*! Bundled license information:
  
  sortablejs/modular/sortable.esm.js:
    (**!
     * Sortable 1.15.0
     * @author	RubaXa   <trash@rubaxa.org>
     * @author	owenm    <owen23355@gmail.com>
     * @license MIT
     *)
  *)
*/
//# sourceMappingURL=assets/alchemy_admin.js.map
