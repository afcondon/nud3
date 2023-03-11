#!/usr/bin/env node
(() => {
  // output/Effect.Console/foreign.js
  var log = function(s) {
    return function() {
      console.log(s);
    };
  };

  // output/Data.Show/foreign.js
  var showIntImpl = function(n) {
    return n.toString();
  };
  var showNumberImpl = function(n) {
    var str = n.toString();
    return isNaN(str + ".0") ? str : str + ".0";
  };
  var showCharImpl = function(c) {
    var code = c.charCodeAt(0);
    if (code < 32 || code === 127) {
      switch (c) {
        case "\x07":
          return "'\\a'";
        case "\b":
          return "'\\b'";
        case "\f":
          return "'\\f'";
        case "\n":
          return "'\\n'";
        case "\r":
          return "'\\r'";
        case "	":
          return "'\\t'";
        case "\v":
          return "'\\v'";
      }
      return "'\\" + code.toString(10) + "'";
    }
    return c === "'" || c === "\\" ? "'\\" + c + "'" : "'" + c + "'";
  };
  var showStringImpl = function(s) {
    var l = s.length;
    return '"' + s.replace(
      /[\0-\x1F\x7F"\\]/g,
      function(c, i) {
        switch (c) {
          case '"':
          case "\\":
            return "\\" + c;
          case "\x07":
            return "\\a";
          case "\b":
            return "\\b";
          case "\f":
            return "\\f";
          case "\n":
            return "\\n";
          case "\r":
            return "\\r";
          case "	":
            return "\\t";
          case "\v":
            return "\\v";
        }
        var k = i + 1;
        var empty = k < l && s[k] >= "0" && s[k] <= "9" ? "\\&" : "";
        return "\\" + c.charCodeAt(0).toString(10) + empty;
      }
    ) + '"';
  };
  var showArrayImpl = function(f) {
    return function(xs) {
      var ss = [];
      for (var i = 0, l = xs.length; i < l; i++) {
        ss[i] = f(xs[i]);
      }
      return "[" + ss.join(",") + "]";
    };
  };

  // output/Type.Proxy/index.js
  var $$Proxy = /* @__PURE__ */ function() {
    function $$Proxy2() {
    }
    ;
    $$Proxy2.value = new $$Proxy2();
    return $$Proxy2;
  }();

  // output/Data.Symbol/index.js
  var reflectSymbol = function(dict) {
    return dict.reflectSymbol;
  };

  // output/Data.Show/index.js
  var showString = {
    show: showStringImpl
  };
  var showNumber = {
    show: showNumberImpl
  };
  var showInt = {
    show: showIntImpl
  };
  var showChar = {
    show: showCharImpl
  };
  var show = function(dict) {
    return dict.show;
  };
  var showArray = function(dictShow) {
    return {
      show: showArrayImpl(show(dictShow))
    };
  };

  // output/Data.Int/foreign.js
  var toNumber = function(n) {
    return n;
  };

  // output/Control.Semigroupoid/index.js
  var semigroupoidFn = {
    compose: function(f) {
      return function(g) {
        return function(x) {
          return f(g(x));
        };
      };
    }
  };

  // output/Control.Category/index.js
  var identity = function(dict) {
    return dict.identity;
  };
  var categoryFn = {
    identity: function(x) {
      return x;
    },
    Semigroupoid0: function() {
      return semigroupoidFn;
    }
  };

  // output/Data.Bounded/foreign.js
  var topChar = String.fromCharCode(65535);
  var bottomChar = String.fromCharCode(0);
  var topNumber = Number.POSITIVE_INFINITY;
  var bottomNumber = Number.NEGATIVE_INFINITY;

  // output/Data.Unit/foreign.js
  var unit = void 0;

  // output/Data.Semigroup/foreign.js
  var concatArray = function(xs) {
    return function(ys) {
      if (xs.length === 0)
        return ys;
      if (ys.length === 0)
        return xs;
      return xs.concat(ys);
    };
  };

  // output/Data.Semigroup/index.js
  var semigroupArray = {
    append: concatArray
  };
  var append = function(dict) {
    return dict.append;
  };

  // output/Control.Apply/index.js
  var apply = function(dict) {
    return dict.apply;
  };

  // output/Control.Applicative/index.js
  var pure = function(dict) {
    return dict.pure;
  };
  var liftA1 = function(dictApplicative) {
    var apply2 = apply(dictApplicative.Apply0());
    var pure1 = pure(dictApplicative);
    return function(f) {
      return function(a) {
        return apply2(pure1(f))(a);
      };
    };
  };

  // output/Data.Generic.Rep/index.js
  var Inl = /* @__PURE__ */ function() {
    function Inl2(value0) {
      this.value0 = value0;
    }
    ;
    Inl2.create = function(value0) {
      return new Inl2(value0);
    };
    return Inl2;
  }();
  var Inr = /* @__PURE__ */ function() {
    function Inr2(value0) {
      this.value0 = value0;
    }
    ;
    Inr2.create = function(value0) {
      return new Inr2(value0);
    };
    return Inr2;
  }();
  var from = function(dict) {
    return dict.from;
  };

  // output/Data.String.CodeUnits/foreign.js
  var toCharArray = function(s) {
    return s.split("");
  };
  var singleton = function(c) {
    return c;
  };

  // output/Data.Show.Generic/foreign.js
  var intercalate = function(separator) {
    return function(xs) {
      return xs.join(separator);
    };
  };

  // output/Data.Show.Generic/index.js
  var append2 = /* @__PURE__ */ append(semigroupArray);
  var genericShowArgsArgument = function(dictShow) {
    var show4 = show(dictShow);
    return {
      genericShowArgs: function(v) {
        return [show4(v)];
      }
    };
  };
  var genericShowArgs = function(dict) {
    return dict.genericShowArgs;
  };
  var genericShowConstructor = function(dictGenericShowArgs) {
    var genericShowArgs1 = genericShowArgs(dictGenericShowArgs);
    return function(dictIsSymbol) {
      var reflectSymbol2 = reflectSymbol(dictIsSymbol);
      return {
        "genericShow'": function(v) {
          var ctor = reflectSymbol2($$Proxy.value);
          var v1 = genericShowArgs1(v);
          if (v1.length === 0) {
            return ctor;
          }
          ;
          return "(" + (intercalate(" ")(append2([ctor])(v1)) + ")");
        }
      };
    };
  };
  var genericShow$prime = function(dict) {
    return dict["genericShow'"];
  };
  var genericShowSum = function(dictGenericShow) {
    var genericShow$prime1 = genericShow$prime(dictGenericShow);
    return function(dictGenericShow1) {
      var genericShow$prime2 = genericShow$prime(dictGenericShow1);
      return {
        "genericShow'": function(v) {
          if (v instanceof Inl) {
            return genericShow$prime1(v.value0);
          }
          ;
          if (v instanceof Inr) {
            return genericShow$prime2(v.value0);
          }
          ;
          throw new Error("Failed pattern match at Data.Show.Generic (line 26, column 1 - line 28, column 40): " + [v.constructor.name]);
        }
      };
    };
  };
  var genericShow = function(dictGeneric) {
    var from2 = from(dictGeneric);
    return function(dictGenericShow) {
      var genericShow$prime1 = genericShow$prime(dictGenericShow);
      return function(x) {
        return genericShow$prime1(from2(x));
      };
    };
  };

  // output/Debug/foreign.js
  var req = typeof module === "undefined" ? void 0 : module.require;
  var util = function() {
    try {
      return req === void 0 ? void 0 : req("util");
    } catch (e) {
      return void 0;
    }
  }();
  function _trace(x, k) {
    if (util !== void 0) {
      console.log(util.inspect(x, { depth: null, colors: true }));
    } else {
      console.log(x);
    }
    return k({});
  }
  var now = function() {
    var perf;
    if (typeof performance !== "undefined") {
      perf = performance;
    } else if (req) {
      try {
        perf = req("perf_hooks").performance;
      } catch (e) {
      }
    }
    return function() {
      return (perf || Date).now();
    };
  }();

  // output/Control.Bind/index.js
  var bind = function(dict) {
    return dict.bind;
  };

  // output/Debug/index.js
  var trace = function() {
    return function(a) {
      return function(k) {
        return _trace(a, k);
      };
    };
  };

  // output/Effect/foreign.js
  var pureE = function(a) {
    return function() {
      return a;
    };
  };
  var bindE = function(a) {
    return function(f) {
      return function() {
        return f(a())();
      };
    };
  };

  // output/Control.Monad/index.js
  var ap = function(dictMonad) {
    var bind2 = bind(dictMonad.Bind1());
    var pure3 = pure(dictMonad.Applicative0());
    return function(f) {
      return function(a) {
        return bind2(f)(function(f$prime) {
          return bind2(a)(function(a$prime) {
            return pure3(f$prime(a$prime));
          });
        });
      };
    };
  };

  // output/Effect/index.js
  var $runtime_lazy = function(name, moduleName, init) {
    var state = 0;
    var val;
    return function(lineNumber) {
      if (state === 2)
        return val;
      if (state === 1)
        throw new ReferenceError(name + " was needed before it finished initializing (module " + moduleName + ", line " + lineNumber + ")", moduleName, lineNumber);
      state = 1;
      val = init();
      state = 2;
      return val;
    };
  };
  var monadEffect = {
    Applicative0: function() {
      return applicativeEffect;
    },
    Bind1: function() {
      return bindEffect;
    }
  };
  var bindEffect = {
    bind: bindE,
    Apply0: function() {
      return $lazy_applyEffect(0);
    }
  };
  var applicativeEffect = {
    pure: pureE,
    Apply0: function() {
      return $lazy_applyEffect(0);
    }
  };
  var $lazy_functorEffect = /* @__PURE__ */ $runtime_lazy("functorEffect", "Effect", function() {
    return {
      map: liftA1(applicativeEffect)
    };
  });
  var $lazy_applyEffect = /* @__PURE__ */ $runtime_lazy("applyEffect", "Effect", function() {
    return {
      apply: ap(monadEffect),
      Functor0: function() {
        return $lazy_functorEffect(0);
      }
    };
  });

  // output/Effect.Class/index.js
  var monadEffectEffect = {
    liftEffect: /* @__PURE__ */ identity(categoryFn),
    Monad0: function() {
      return monadEffect;
    }
  };
  var liftEffect = function(dict) {
    return dict.liftEffect;
  };

  // output/Effect.Class.Console/index.js
  var log3 = function(dictMonadEffect) {
    var $51 = liftEffect(dictMonadEffect);
    return function($52) {
      return $51(log($52));
    };
  };

  // output/Nud3.Attributes/index.js
  var show2 = /* @__PURE__ */ show(showNumber);
  var Remove = /* @__PURE__ */ function() {
    function Remove2() {
    }
    ;
    Remove2.value = new Remove2();
    return Remove2;
  }();
  var Background_ = /* @__PURE__ */ function() {
    function Background_2(value0) {
      this.value0 = value0;
    }
    ;
    Background_2.create = function(value0) {
      return new Background_2(value0);
    };
    return Background_2;
  }();
  var Background = /* @__PURE__ */ function() {
    function Background2(value0) {
      this.value0 = value0;
    }
    ;
    Background2.create = function(value0) {
      return new Background2(value0);
    };
    return Background2;
  }();
  var Color_ = /* @__PURE__ */ function() {
    function Color_2(value0) {
      this.value0 = value0;
    }
    ;
    Color_2.create = function(value0) {
      return new Color_2(value0);
    };
    return Color_2;
  }();
  var Color = /* @__PURE__ */ function() {
    function Color2(value0) {
      this.value0 = value0;
    }
    ;
    Color2.create = function(value0) {
      return new Color2(value0);
    };
    return Color2;
  }();
  var Classed_ = /* @__PURE__ */ function() {
    function Classed_2(value0) {
      this.value0 = value0;
    }
    ;
    Classed_2.create = function(value0) {
      return new Classed_2(value0);
    };
    return Classed_2;
  }();
  var Classed = /* @__PURE__ */ function() {
    function Classed2(value0) {
      this.value0 = value0;
    }
    ;
    Classed2.create = function(value0) {
      return new Classed2(value0);
    };
    return Classed2;
  }();
  var CX_ = /* @__PURE__ */ function() {
    function CX_2(value0) {
      this.value0 = value0;
    }
    ;
    CX_2.create = function(value0) {
      return new CX_2(value0);
    };
    return CX_2;
  }();
  var CX = /* @__PURE__ */ function() {
    function CX2(value0) {
      this.value0 = value0;
    }
    ;
    CX2.create = function(value0) {
      return new CX2(value0);
    };
    return CX2;
  }();
  var CY_ = /* @__PURE__ */ function() {
    function CY_2(value0) {
      this.value0 = value0;
    }
    ;
    CY_2.create = function(value0) {
      return new CY_2(value0);
    };
    return CY_2;
  }();
  var CY = /* @__PURE__ */ function() {
    function CY2(value0) {
      this.value0 = value0;
    }
    ;
    CY2.create = function(value0) {
      return new CY2(value0);
    };
    return CY2;
  }();
  var DX_ = /* @__PURE__ */ function() {
    function DX_2(value0) {
      this.value0 = value0;
    }
    ;
    DX_2.create = function(value0) {
      return new DX_2(value0);
    };
    return DX_2;
  }();
  var DX = /* @__PURE__ */ function() {
    function DX2(value0) {
      this.value0 = value0;
    }
    ;
    DX2.create = function(value0) {
      return new DX2(value0);
    };
    return DX2;
  }();
  var DY_ = /* @__PURE__ */ function() {
    function DY_2(value0) {
      this.value0 = value0;
    }
    ;
    DY_2.create = function(value0) {
      return new DY_2(value0);
    };
    return DY_2;
  }();
  var DY = /* @__PURE__ */ function() {
    function DY2(value0) {
      this.value0 = value0;
    }
    ;
    DY2.create = function(value0) {
      return new DY2(value0);
    };
    return DY2;
  }();
  var Fill_ = /* @__PURE__ */ function() {
    function Fill_2(value0) {
      this.value0 = value0;
    }
    ;
    Fill_2.create = function(value0) {
      return new Fill_2(value0);
    };
    return Fill_2;
  }();
  var Fill = /* @__PURE__ */ function() {
    function Fill2(value0) {
      this.value0 = value0;
    }
    ;
    Fill2.create = function(value0) {
      return new Fill2(value0);
    };
    return Fill2;
  }();
  var FontFamily_ = /* @__PURE__ */ function() {
    function FontFamily_2(value0) {
      this.value0 = value0;
    }
    ;
    FontFamily_2.create = function(value0) {
      return new FontFamily_2(value0);
    };
    return FontFamily_2;
  }();
  var FontFamily = /* @__PURE__ */ function() {
    function FontFamily2(value0) {
      this.value0 = value0;
    }
    ;
    FontFamily2.create = function(value0) {
      return new FontFamily2(value0);
    };
    return FontFamily2;
  }();
  var FontSize_ = /* @__PURE__ */ function() {
    function FontSize_2(value0) {
      this.value0 = value0;
    }
    ;
    FontSize_2.create = function(value0) {
      return new FontSize_2(value0);
    };
    return FontSize_2;
  }();
  var FontSize = /* @__PURE__ */ function() {
    function FontSize2(value0) {
      this.value0 = value0;
    }
    ;
    FontSize2.create = function(value0) {
      return new FontSize2(value0);
    };
    return FontSize2;
  }();
  var Height_ = /* @__PURE__ */ function() {
    function Height_2(value0) {
      this.value0 = value0;
    }
    ;
    Height_2.create = function(value0) {
      return new Height_2(value0);
    };
    return Height_2;
  }();
  var Height = /* @__PURE__ */ function() {
    function Height2(value0) {
      this.value0 = value0;
    }
    ;
    Height2.create = function(value0) {
      return new Height2(value0);
    };
    return Height2;
  }();
  var Radius_ = /* @__PURE__ */ function() {
    function Radius_2(value0) {
      this.value0 = value0;
    }
    ;
    Radius_2.create = function(value0) {
      return new Radius_2(value0);
    };
    return Radius_2;
  }();
  var Radius = /* @__PURE__ */ function() {
    function Radius2(value0) {
      this.value0 = value0;
    }
    ;
    Radius2.create = function(value0) {
      return new Radius2(value0);
    };
    return Radius2;
  }();
  var StrokeColor_ = /* @__PURE__ */ function() {
    function StrokeColor_2(value0) {
      this.value0 = value0;
    }
    ;
    StrokeColor_2.create = function(value0) {
      return new StrokeColor_2(value0);
    };
    return StrokeColor_2;
  }();
  var StrokeColor = /* @__PURE__ */ function() {
    function StrokeColor2(value0) {
      this.value0 = value0;
    }
    ;
    StrokeColor2.create = function(value0) {
      return new StrokeColor2(value0);
    };
    return StrokeColor2;
  }();
  var StrokeOpacity_ = /* @__PURE__ */ function() {
    function StrokeOpacity_2(value0) {
      this.value0 = value0;
    }
    ;
    StrokeOpacity_2.create = function(value0) {
      return new StrokeOpacity_2(value0);
    };
    return StrokeOpacity_2;
  }();
  var StrokeOpacity = /* @__PURE__ */ function() {
    function StrokeOpacity2(value0) {
      this.value0 = value0;
    }
    ;
    StrokeOpacity2.create = function(value0) {
      return new StrokeOpacity2(value0);
    };
    return StrokeOpacity2;
  }();
  var StrokeWidth_ = /* @__PURE__ */ function() {
    function StrokeWidth_2(value0) {
      this.value0 = value0;
    }
    ;
    StrokeWidth_2.create = function(value0) {
      return new StrokeWidth_2(value0);
    };
    return StrokeWidth_2;
  }();
  var StrokeWidth = /* @__PURE__ */ function() {
    function StrokeWidth2(value0) {
      this.value0 = value0;
    }
    ;
    StrokeWidth2.create = function(value0) {
      return new StrokeWidth2(value0);
    };
    return StrokeWidth2;
  }();
  var Style_ = /* @__PURE__ */ function() {
    function Style_2(value0) {
      this.value0 = value0;
    }
    ;
    Style_2.create = function(value0) {
      return new Style_2(value0);
    };
    return Style_2;
  }();
  var Style = /* @__PURE__ */ function() {
    function Style2(value0) {
      this.value0 = value0;
    }
    ;
    Style2.create = function(value0) {
      return new Style2(value0);
    };
    return Style2;
  }();
  var Text_ = /* @__PURE__ */ function() {
    function Text_2(value0) {
      this.value0 = value0;
    }
    ;
    Text_2.create = function(value0) {
      return new Text_2(value0);
    };
    return Text_2;
  }();
  var Text = /* @__PURE__ */ function() {
    function Text2(value0) {
      this.value0 = value0;
    }
    ;
    Text2.create = function(value0) {
      return new Text2(value0);
    };
    return Text2;
  }();
  var TextAnchor_ = /* @__PURE__ */ function() {
    function TextAnchor_2(value0) {
      this.value0 = value0;
    }
    ;
    TextAnchor_2.create = function(value0) {
      return new TextAnchor_2(value0);
    };
    return TextAnchor_2;
  }();
  var TextAnchor = /* @__PURE__ */ function() {
    function TextAnchor2(value0) {
      this.value0 = value0;
    }
    ;
    TextAnchor2.create = function(value0) {
      return new TextAnchor2(value0);
    };
    return TextAnchor2;
  }();
  var TransitionTo = /* @__PURE__ */ function() {
    function TransitionTo2(value0) {
      this.value0 = value0;
    }
    ;
    TransitionTo2.create = function(value0) {
      return new TransitionTo2(value0);
    };
    return TransitionTo2;
  }();
  var Width_ = /* @__PURE__ */ function() {
    function Width_2(value0) {
      this.value0 = value0;
    }
    ;
    Width_2.create = function(value0) {
      return new Width_2(value0);
    };
    return Width_2;
  }();
  var Width = /* @__PURE__ */ function() {
    function Width2(value0) {
      this.value0 = value0;
    }
    ;
    Width2.create = function(value0) {
      return new Width2(value0);
    };
    return Width2;
  }();
  var ViewBox_ = /* @__PURE__ */ function() {
    function ViewBox_2(value0, value1, value2, value3) {
      this.value0 = value0;
      this.value1 = value1;
      this.value2 = value2;
      this.value3 = value3;
    }
    ;
    ViewBox_2.create = function(value0) {
      return function(value1) {
        return function(value2) {
          return function(value3) {
            return new ViewBox_2(value0, value1, value2, value3);
          };
        };
      };
    };
    return ViewBox_2;
  }();
  var X_ = /* @__PURE__ */ function() {
    function X_2(value0) {
      this.value0 = value0;
    }
    ;
    X_2.create = function(value0) {
      return new X_2(value0);
    };
    return X_2;
  }();
  var X = /* @__PURE__ */ function() {
    function X3(value0) {
      this.value0 = value0;
    }
    ;
    X3.create = function(value0) {
      return new X3(value0);
    };
    return X3;
  }();
  var Y_ = /* @__PURE__ */ function() {
    function Y_2(value0) {
      this.value0 = value0;
    }
    ;
    Y_2.create = function(value0) {
      return new Y_2(value0);
    };
    return Y_2;
  }();
  var Y = /* @__PURE__ */ function() {
    function Y3(value0) {
      this.value0 = value0;
    }
    ;
    Y3.create = function(value0) {
      return new Y3(value0);
    };
    return Y3;
  }();
  var X1_ = /* @__PURE__ */ function() {
    function X1_2(value0) {
      this.value0 = value0;
    }
    ;
    X1_2.create = function(value0) {
      return new X1_2(value0);
    };
    return X1_2;
  }();
  var X1 = /* @__PURE__ */ function() {
    function X12(value0) {
      this.value0 = value0;
    }
    ;
    X12.create = function(value0) {
      return new X12(value0);
    };
    return X12;
  }();
  var X2_ = /* @__PURE__ */ function() {
    function X2_2(value0) {
      this.value0 = value0;
    }
    ;
    X2_2.create = function(value0) {
      return new X2_2(value0);
    };
    return X2_2;
  }();
  var X2 = /* @__PURE__ */ function() {
    function X22(value0) {
      this.value0 = value0;
    }
    ;
    X22.create = function(value0) {
      return new X22(value0);
    };
    return X22;
  }();
  var Y1_ = /* @__PURE__ */ function() {
    function Y1_2(value0) {
      this.value0 = value0;
    }
    ;
    Y1_2.create = function(value0) {
      return new Y1_2(value0);
    };
    return Y1_2;
  }();
  var Y1 = /* @__PURE__ */ function() {
    function Y12(value0) {
      this.value0 = value0;
    }
    ;
    Y12.create = function(value0) {
      return new Y12(value0);
    };
    return Y12;
  }();
  var Y2_ = /* @__PURE__ */ function() {
    function Y2_2(value0) {
      this.value0 = value0;
    }
    ;
    Y2_2.create = function(value0) {
      return new Y2_2(value0);
    };
    return Y2_2;
  }();
  var Y2 = /* @__PURE__ */ function() {
    function Y22(value0) {
      this.value0 = value0;
    }
    ;
    Y22.create = function(value0) {
      return new Y22(value0);
    };
    return Y22;
  }();
  var TransitionDuration_ = /* @__PURE__ */ function() {
    function TransitionDuration_2(value0) {
      this.value0 = value0;
    }
    ;
    TransitionDuration_2.create = function(value0) {
      return new TransitionDuration_2(value0);
    };
    return TransitionDuration_2;
  }();
  var TransitionDuration = /* @__PURE__ */ function() {
    function TransitionDuration2(value0) {
      this.value0 = value0;
    }
    ;
    TransitionDuration2.create = function(value0) {
      return new TransitionDuration2(value0);
    };
    return TransitionDuration2;
  }();
  var TransitionDelay_ = /* @__PURE__ */ function() {
    function TransitionDelay_2(value0) {
      this.value0 = value0;
    }
    ;
    TransitionDelay_2.create = function(value0) {
      return new TransitionDelay_2(value0);
    };
    return TransitionDelay_2;
  }();
  var TransitionDelay = /* @__PURE__ */ function() {
    function TransitionDelay2(value0) {
      this.value0 = value0;
    }
    ;
    TransitionDelay2.create = function(value0) {
      return new TransitionDelay2(value0);
    };
    return TransitionDelay2;
  }();
  var Attr = /* @__PURE__ */ function() {
    function Attr2(value0) {
      this.value0 = value0;
    }
    ;
    Attr2.create = function(value0) {
      return new Attr2(value0);
    };
    return Attr2;
  }();
  var showTransitionAttribute = {
    show: function(v) {
      if (v instanceof TransitionDuration_) {
        return "TransitionDuration_" + (" set directly to " + show2(v.value0));
      }
      ;
      if (v instanceof TransitionDelay_) {
        return "TransitionDelay_" + (" set directly to " + show2(v.value0));
      }
      ;
      if (v instanceof Attr) {
        return "Attr" + (" set directly to " + show(showAttribute)(v.value0));
      }
      ;
      if (v instanceof TransitionDuration) {
        return "TransitionDuration set by function";
      }
      ;
      if (v instanceof TransitionDelay) {
        return "TransitionDelay set by function";
      }
      ;
      throw new Error("Failed pattern match at Nud3.Attributes (line 125, column 1 - line 130, column 63): " + [v.constructor.name]);
    }
  };
  var showAttribute = {
    show: function(v) {
      if (v instanceof Remove) {
        return "\n		Remove";
      }
      ;
      if (v instanceof Background_) {
        return "\n		Background_" + (" set directly to " + v.value0);
      }
      ;
      if (v instanceof Color_) {
        return "\n		Color_" + (" set directly to " + v.value0);
      }
      ;
      if (v instanceof Classed_) {
        return "\n		Classed_" + (" set directly to " + v.value0);
      }
      ;
      if (v instanceof CX_) {
        return "\n		CX_" + (" set directly to " + show2(v.value0));
      }
      ;
      if (v instanceof CY_) {
        return "\n		CY_" + (" set directly to " + show2(v.value0));
      }
      ;
      if (v instanceof DX_) {
        return "\n		DX_" + (" set directly to " + show2(v.value0));
      }
      ;
      if (v instanceof DY_) {
        return "\n		DY_" + (" set directly to " + show2(v.value0));
      }
      ;
      if (v instanceof Fill_) {
        return "\n		Fill_" + (" set directly to " + v.value0);
      }
      ;
      if (v instanceof FontFamily_) {
        return "\n		FontFamily_" + (" set directly to " + v.value0);
      }
      ;
      if (v instanceof FontSize_) {
        return "\n		FontSize_" + (" set directly to " + show2(v.value0));
      }
      ;
      if (v instanceof Height_) {
        return "\n		Height_" + (" set directly to " + show2(v.value0));
      }
      ;
      if (v instanceof Radius_) {
        return "\n		Radius_" + (" set directly to " + show2(v.value0));
      }
      ;
      if (v instanceof StrokeColor_) {
        return "\n		StrokeColor_" + (" set directly to " + v.value0);
      }
      ;
      if (v instanceof StrokeOpacity_) {
        return "\n		StrokeOpacity_" + (" set directly to " + show2(v.value0));
      }
      ;
      if (v instanceof StrokeWidth_) {
        return "\n		StrokeWidth_" + (" set directly to " + show2(v.value0));
      }
      ;
      if (v instanceof Style_) {
        return "\n		Style_" + (" set directly to " + v.value0);
      }
      ;
      if (v instanceof Text_) {
        return "\n		Text_" + (" set directly to " + v.value0);
      }
      ;
      if (v instanceof TextAnchor_) {
        return "\n		TextAnchor_" + (" set directly to " + v.value0);
      }
      ;
      if (v instanceof TransitionTo) {
        return "\n		TransitionTo" + (" set directly to " + show(showArray(showTransitionAttribute))(v.value0));
      }
      ;
      if (v instanceof Width_) {
        return "\n		Width_" + (" set directly to " + show2(v.value0));
      }
      ;
      if (v instanceof ViewBox_) {
        return "\n		ViewBox_" + (" set directly to " + (show2(v.value0) + (" " + (show2(v.value1) + (" " + (show2(v.value2) + (" " + show2(v.value3))))))));
      }
      ;
      if (v instanceof X_) {
        return "\n		X_" + (" set directly to " + show2(v.value0));
      }
      ;
      if (v instanceof Y_) {
        return "\n		Y_" + (" set directly to " + show2(v.value0));
      }
      ;
      if (v instanceof X1_) {
        return "\n		X1_" + (" set directly to " + show2(v.value0));
      }
      ;
      if (v instanceof X2_) {
        return "\n		X2_" + (" set directly to " + show2(v.value0));
      }
      ;
      if (v instanceof Y1_) {
        return "\n		Y1_" + (" set directly to " + show2(v.value0));
      }
      ;
      if (v instanceof Y2_) {
        return "\n		Y2_" + (" set directly to " + show2(v.value0));
      }
      ;
      if (v instanceof Background) {
        return "\n		Background set by function";
      }
      ;
      if (v instanceof Color) {
        return "\n		Color set by function";
      }
      ;
      if (v instanceof Classed) {
        return "\n		Classed set by function";
      }
      ;
      if (v instanceof CX) {
        return "\n		CX set by function";
      }
      ;
      if (v instanceof CY) {
        return "\n		CY set by function";
      }
      ;
      if (v instanceof DX) {
        return "\n		DX set by function";
      }
      ;
      if (v instanceof DY) {
        return "\n		DY set by function";
      }
      ;
      if (v instanceof Fill) {
        return "\n		Fill set by function";
      }
      ;
      if (v instanceof FontFamily) {
        return "\n		FontFamily set by function";
      }
      ;
      if (v instanceof FontSize) {
        return "\n		FontSize set by function";
      }
      ;
      if (v instanceof Height) {
        return "\n		Height set by function";
      }
      ;
      if (v instanceof Radius) {
        return "\n		Radius set by function";
      }
      ;
      if (v instanceof StrokeColor) {
        return "\n		StrokeColor set by function";
      }
      ;
      if (v instanceof StrokeOpacity) {
        return "\n		StrokeOpacity set by function";
      }
      ;
      if (v instanceof StrokeWidth) {
        return "\n		StrokeWidth set by function";
      }
      ;
      if (v instanceof Style) {
        return "\n		Style set by function";
      }
      ;
      if (v instanceof Text) {
        return "\n		Text set by function";
      }
      ;
      if (v instanceof TextAnchor) {
        return "\n		TextAnchor set by function";
      }
      ;
      if (v instanceof Width) {
        return "\n		Width set by function";
      }
      ;
      if (v instanceof X) {
        return "\n		X set by function";
      }
      ;
      if (v instanceof Y) {
        return "\n		Y set by function";
      }
      ;
      if (v instanceof X1) {
        return "\n		X1 set by function";
      }
      ;
      if (v instanceof X2) {
        return "\n		X2 set by function";
      }
      ;
      if (v instanceof Y1) {
        return "\n		Y1 set by function";
      }
      ;
      if (v instanceof Y2) {
        return "\n		Y2 set by function";
      }
      ;
      throw new Error("Failed pattern match at Nud3.Attributes (line 62, column 1 - line 115, column 43): " + [v.constructor.name]);
    }
  };

  // output/Nud3.FFI/foreign.js
  function selectManyWithString_(name) {
    return (selector2) => new Selection([document.querySelectorAll(selector2)], [document.documentElement], name);
  }
  function selectManyWithFunction_(name) {
    return (selectorFn) => new Selection([array(selectorFn)], root);
  }
  function getName_(selection2) {
    return selection2._name;
  }
  function appendElement_(name) {
    return (selection2) => selection2.append(name);
  }
  function insertElement_(name) {
    return (selector2) => (selection2) => selection2.insert(name, selector2);
  }
  var root = [null];
  function Selection(groups, parents, name) {
    this._groups = groups;
    this._parents = parents;
    this._name = name;
  }
  function array(x) {
    return x == null ? [] : Array.isArray(x) ? x : Array.from(x);
  }
  function selection_append(name) {
    var create = typeof name === "function" ? name : creator(name);
    return this.select(function() {
      return this.appendChild(create.apply(this, arguments));
    });
  }
  function constantNull() {
    return null;
  }
  function selection_insert(name, before) {
    var create = typeof name === "function" ? name : creator(name), select2 = before == null ? constantNull : typeof before === "function" ? before : selector(before);
    return this.select(function() {
      return this.insertBefore(create.apply(this, arguments), select2.apply(this, arguments) || null);
    });
  }
  function creatorInherit(name) {
    return function() {
      var document2 = this.ownerDocument, uri = this.namespaceURI;
      return uri === namespaces.xhtml && document2.documentElement.namespaceURI === namespaces.xhtml ? document2.createElement(name) : document2.createElementNS(uri, name);
    };
  }
  function creatorFixed(fullname) {
    return function() {
      return this.ownerDocument.createElementNS(fullname.space, fullname.local);
    };
  }
  function creator(name) {
    var fullname = namespace(name);
    return (fullname.local ? creatorFixed : creatorInherit)(fullname);
  }
  function namespace(name) {
    var prefix = name += "", i = prefix.indexOf(":");
    if (i >= 0 && (prefix = name.slice(0, i)) !== "xmlns")
      name = name.slice(i + 1);
    return namespaces.hasOwnProperty(prefix) ? { space: namespaces[prefix], local: name } : name;
  }
  var xhtml = "http://www.w3.org/1999/xhtml";
  var namespaces = {
    svg: "http://www.w3.org/2000/svg",
    xhtml,
    xlink: "http://www.w3.org/1999/xlink",
    xml: "http://www.w3.org/XML/1998/namespace",
    xmlns: "http://www.w3.org/2000/xmlns/"
  };
  function selection() {
    return new Selection([[document.documentElement]], root);
  }
  function selection_selection() {
    return this;
  }
  function selection_select(select2) {
    if (typeof select2 !== "function")
      select2 = selector(select2);
    for (var groups = this._groups, m = groups.length, subgroups = new Array(m), j = 0; j < m; ++j) {
      for (var group = groups[j], n = group.length, subgroup = subgroups[j] = new Array(n), node, subnode, i = 0; i < n; ++i) {
        if ((node = group[i]) && (subnode = select2.call(node, node.__data__, i, group))) {
          if ("__data__" in node)
            subnode.__data__ = node.__data__;
          subgroup[i] = subnode;
        }
      }
    }
    return new Selection(subgroups, this._parents);
  }
  function none() {
  }
  function selector(selector2) {
    return selector2 == null ? none : function() {
      return this.querySelector(selector2);
    };
  }
  Selection.prototype = selection.prototype = {
    constructor: Selection,
    select: selection_select,
    selection: selection_selection,
    append: selection_append,
    insert: selection_insert
  };

  // output/Nud3/index.js
  var pure2 = /* @__PURE__ */ pure(applicativeEffect);
  var trace2 = /* @__PURE__ */ trace();
  var genericShowConstructor2 = /* @__PURE__ */ genericShowConstructor(/* @__PURE__ */ genericShowArgsArgument(showString));
  var log4 = /* @__PURE__ */ log3(monadEffectEffect);
  var show3 = /* @__PURE__ */ show(/* @__PURE__ */ showArray(showAttribute));
  var SelectorString = /* @__PURE__ */ function() {
    function SelectorString2(value0) {
      this.value0 = value0;
    }
    ;
    SelectorString2.create = function(value0) {
      return new SelectorString2(value0);
    };
    return SelectorString2;
  }();
  var SelectorFunction = /* @__PURE__ */ function() {
    function SelectorFunction2(value0) {
      this.value0 = value0;
    }
    ;
    SelectorFunction2.create = function(value0) {
      return new SelectorFunction2(value0);
    };
    return SelectorFunction2;
  }();
  var SVG = /* @__PURE__ */ function() {
    function SVG2(value0) {
      this.value0 = value0;
    }
    ;
    SVG2.create = function(value0) {
      return new SVG2(value0);
    };
    return SVG2;
  }();
  var HTML = /* @__PURE__ */ function() {
    function HTML2(value0) {
      this.value0 = value0;
    }
    ;
    HTML2.create = function(value0) {
      return new HTML2(value0);
    };
    return HTML2;
  }();
  var Append = /* @__PURE__ */ function() {
    function Append2(value0) {
      this.value0 = value0;
    }
    ;
    Append2.create = function(value0) {
      return new Append2(value0);
    };
    return Append2;
  }();
  var Insert = /* @__PURE__ */ function() {
    function Insert2(value0) {
      this.value0 = value0;
    }
    ;
    Insert2.create = function(value0) {
      return new Insert2(value0);
    };
    return Insert2;
  }();
  var InheritData = /* @__PURE__ */ function() {
    function InheritData2() {
    }
    ;
    InheritData2.value = new InheritData2();
    return InheritData2;
  }();
  var NewData = /* @__PURE__ */ function() {
    function NewData2(value0) {
      this.value0 = value0;
    }
    ;
    NewData2.create = function(value0) {
      return new NewData2(value0);
    };
    return NewData2;
  }();
  var style = function(s) {
    return function(v) {
      return pure2(s);
    };
  };
  var showSelection = function(s) {
    return "Selection named: " + getName_(s);
  };
  var showDataSource = function(dictShow) {
    var show32 = show(showArray(dictShow));
    return {
      show: function(v) {
        if (v instanceof InheritData) {
          return "data is inherited from parent";
        }
        ;
        if (v instanceof NewData) {
          return "data is new" + show32(v.value0);
        }
        ;
        throw new Error("Failed pattern match at Nud3 (line 69, column 1 - line 71, column 47): " + [v.constructor.name]);
      }
    };
  };
  var select = function(v) {
    return function(v1) {
      if (v1 instanceof SelectorString) {
        return trace2("select with string: " + v1.value0)(function(v2) {
          return selectManyWithString_(v)(v1.value0);
        });
      }
      ;
      if (v1 instanceof SelectorFunction) {
        return trace2("select with function")(function(v2) {
          return selectManyWithFunction_(v)(v1.value0);
        });
      }
      ;
      throw new Error("Failed pattern match at Nud3 (line 97, column 1 - line 97, column 47): " + [v.constructor.name, v1.constructor.name]);
    };
  };
  var revisualize = function(s) {
    return function(ds) {
      return trace2("joining new data to the DOM and updating visualiztion with it")(function(v) {
        return pure2(s);
      });
    };
  };
  var identityKeyFunction = function(dictOrd) {
    return function(dictOrd1) {
      return function(d) {
        return function(v) {
          return function(v1) {
            return d;
          };
        };
      };
    };
  };
  var genericEnterElement = {
    to: function(x) {
      if (x instanceof Inl) {
        return new Append(x.value0);
      }
      ;
      if (x instanceof Inr) {
        return new Insert(x.value0);
      }
      ;
      throw new Error("Failed pattern match at Nud3 (line 83, column 1 - line 83, column 62): " + [x.constructor.name]);
    },
    from: function(x) {
      if (x instanceof Append) {
        return new Inl(x.value0);
      }
      ;
      if (x instanceof Insert) {
        return new Inr(x.value0);
      }
      ;
      throw new Error("Failed pattern match at Nud3 (line 83, column 1 - line 83, column 62): " + [x.constructor.name]);
    }
  };
  var genericElement = {
    to: function(x) {
      if (x instanceof Inl) {
        return new SVG(x.value0);
      }
      ;
      if (x instanceof Inr) {
        return new HTML(x.value0);
      }
      ;
      throw new Error("Failed pattern match at Nud3 (line 90, column 1 - line 90, column 52): " + [x.constructor.name]);
    },
    from: function(x) {
      if (x instanceof SVG) {
        return new Inl(x.value0);
      }
      ;
      if (x instanceof HTML) {
        return new Inr(x.value0);
      }
      ;
      throw new Error("Failed pattern match at Nud3 (line 90, column 1 - line 90, column 52): " + [x.constructor.name]);
    }
  };
  var showElement = {
    show: /* @__PURE__ */ genericShow(genericElement)(/* @__PURE__ */ genericShowSum(/* @__PURE__ */ genericShowConstructor2({
      reflectSymbol: function() {
        return "SVG";
      }
    }))(/* @__PURE__ */ genericShowConstructor2({
      reflectSymbol: function() {
        return "HTML";
      }
    })))
  };
  var show1 = /* @__PURE__ */ show(showElement);
  var genericShowConstructor1 = /* @__PURE__ */ genericShowConstructor(/* @__PURE__ */ genericShowArgsArgument(showElement));
  var insertElement = function(s) {
    return function(element) {
      return function __do2() {
        log4("inserting " + show1(element))();
        if (element instanceof SVG) {
          return insertElement_(element.value0)(":first-child")(s);
        }
        ;
        if (element instanceof HTML) {
          return insertElement_(element.value0)(":first-child")(s);
        }
        ;
        throw new Error("Failed pattern match at Nud3 (line 111, column 10 - line 113, column 56): " + [element.constructor.name]);
      };
    };
  };
  var showEnterElement = {
    show: /* @__PURE__ */ genericShow(genericEnterElement)(/* @__PURE__ */ genericShowSum(/* @__PURE__ */ genericShowConstructor1({
      reflectSymbol: function() {
        return "Append";
      }
    }))(/* @__PURE__ */ genericShowConstructor1({
      reflectSymbol: function() {
        return "Insert";
      }
    })))
  };
  var show22 = /* @__PURE__ */ show(showEnterElement);
  var showJoin = function(dictShow) {
    var show32 = show(showDataSource(dictShow));
    return function(join2) {
      return "Join details: { \n" + ("	what: " + (show22(join2.what) + ("\n	where: " + (showSelection(join2.where) + ("\n	using: " + (show32(join2.using) + ("\n	key: (function)" + ("\n	enter attrs: " + (show3(join2.attributes.enter) + ("\n	update attrs:" + (show3(join2.attributes.update) + ("\n	exit attrs: " + show3(join2.attributes.exit)))))))))))));
    };
  };
  var visualize = function(dictShow) {
    var showJoin1 = showJoin(dictShow);
    return function(config) {
      return function __do2() {
        log4(showJoin1(config))();
        return config.where;
      };
    };
  };
  var filter = function(s) {
    return function(v) {
      return s;
    };
  };
  var appendElement = function(s) {
    return function(element) {
      return function __do2() {
        log4("appending " + show1(element))();
        if (element instanceof SVG) {
          return appendElement_(element.value0)(s);
        }
        ;
        if (element instanceof HTML) {
          return appendElement_(element.value0)(s);
        }
        ;
        throw new Error("Failed pattern match at Nud3 (line 104, column 10 - line 106, column 41): " + [element.constructor.name]);
      };
    };
  };

  // output/Examples.GUP/index.js
  var visualize2 = /* @__PURE__ */ visualize(showChar);
  var generalUpdatePattern = /* @__PURE__ */ function() {
    var letterdata = toCharArray("abcdefghijklmnopqrstuvwxyz");
    var letterdata2 = toCharArray("acdefglmnostxz");
    var root2 = select("root")(new SelectorString("div#gup"));
    return function __do2() {
      var svg = appendElement(root2)(new SVG("svg"))();
      style(svg)([new ViewBox_(0, 0, 650, 650), new Classed_("d3svg gup")])();
      var gupGroup = appendElement(svg)(new SVG("g"))();
      var letters = visualize2({
        what: new Append(new SVG("text")),
        using: new NewData(letterdata),
        where: gupGroup,
        key: function(dictOrd) {
          var identityKeyFunction2 = identityKeyFunction(dictOrd);
          return function(dictOrd1) {
            return identityKeyFunction2(dictOrd1);
          };
        },
        attributes: {
          enter: [new Text(function(d) {
            return function(i) {
              return singleton(d);
            };
          }), new Fill_("green"), new X(function(d) {
            return function(i) {
              return toNumber((i * 48 | 0) + 50 | 0);
            };
          }), new Y_(0), new FontSize_(96), new TransitionTo([new Attr(new Y_(200))])],
          exit: [new Classed_("exit"), new Fill_("brown"), new TransitionTo([new Attr(new Y_(400)), new Attr(Remove.value)])],
          update: [new Classed_("update"), new Fill_("gray"), new Y_(200)]
        }
      })();
      revisualize(letters)(letterdata2)();
      return unit;
    };
  }();

  // output/Examples.Matrix/index.js
  var visualize3 = /* @__PURE__ */ visualize(/* @__PURE__ */ showArray(showInt));
  var matrix2table = /* @__PURE__ */ function() {
    var matrix = [[1, 2, 3], [4, 5, 6], [7, 8, 9]];
    var root2 = select("root")(new SelectorString("body"));
    return function __do2() {
      var table = appendElement(root2)(new HTML("table"))();
      var beforeTable = insertElement(root2)(new HTML("p"))();
      var rows = visualize3({
        what: new Append(new HTML("tr")),
        where: table,
        using: new NewData(matrix),
        key: function(dictOrd) {
          var identityKeyFunction2 = identityKeyFunction(dictOrd);
          return function(dictOrd1) {
            return identityKeyFunction2(dictOrd1);
          };
        },
        attributes: {
          enter: [new Classed_("new")],
          exit: [new Classed_("exit"), Remove.value],
          update: [new Classed_("updated")]
        }
      })();
      var oddrows = filter(rows)("nth-child(odd)");
      style(oddrows)([new Background_("light-gray"), new Color_("white")])();
      var items = visualize3({
        what: new Append(new HTML("td")),
        using: InheritData.value,
        where: rows,
        key: function(dictOrd) {
          var identityKeyFunction2 = identityKeyFunction(dictOrd);
          return function(dictOrd1) {
            return identityKeyFunction2(dictOrd1);
          };
        },
        attributes: {
          enter: [new Classed_("cell")],
          exit: [],
          update: []
        }
      })();
      return unit;
    };
  }();

  // output/Examples.ThreeLittleCircles/index.js
  var visualize4 = /* @__PURE__ */ visualize(showInt);
  var threeLittleCircles = /* @__PURE__ */ function() {
    var root2 = select("root")(new SelectorString("div#circles"));
    return function __do2() {
      var svg = appendElement(root2)(new SVG("svg"))();
      style(svg)([new ViewBox_(-100, -100, 650, 650), new Classed_("d3svg circles")])();
      var circleGroup = appendElement(svg)(new SVG("g"))();
      var circles = visualize4({
        what: new Append(new SVG("circle")),
        using: new NewData([32, 57, 293]),
        where: circleGroup,
        key: function(dictOrd) {
          var identityKeyFunction2 = identityKeyFunction(dictOrd);
          return function(dictOrd1) {
            return identityKeyFunction2(dictOrd1);
          };
        },
        attributes: {
          enter: [new Fill_("green"), new CX(function(v) {
            return function(i) {
              return toNumber(i * 100 | 0);
            };
          }), new CY_(50), new Radius_(20)],
          exit: [],
          update: []
        }
      })();
      return unit;
    };
  }();

  // output/Main/index.js
  var main = function __do() {
    matrix2table();
    threeLittleCircles();
    generalUpdatePattern();
    return log("\u{1F35D}")();
  };

  // <stdin>
  main();
})();
