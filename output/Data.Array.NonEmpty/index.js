// Generated by purs version 0.15.7
import * as Control_Bind from "../Control.Bind/index.js";
import * as Data_Array from "../Data.Array/index.js";
import * as Data_Array_NonEmpty_Internal from "../Data.Array.NonEmpty.Internal/index.js";
import * as Data_Bifunctor from "../Data.Bifunctor/index.js";
import * as Data_Boolean from "../Data.Boolean/index.js";
import * as Data_Eq from "../Data.Eq/index.js";
import * as Data_Function from "../Data.Function/index.js";
import * as Data_Functor from "../Data.Functor/index.js";
import * as Data_Maybe from "../Data.Maybe/index.js";
import * as Data_NonEmpty from "../Data.NonEmpty/index.js";
import * as Data_Ord from "../Data.Ord/index.js";
import * as Data_Semigroup from "../Data.Semigroup/index.js";
import * as Data_Semigroup_Foldable from "../Data.Semigroup.Foldable/index.js";
import * as Data_Tuple from "../Data.Tuple/index.js";
import * as Data_Unfoldable1 from "../Data.Unfoldable1/index.js";
import * as Safe_Coerce from "../Safe.Coerce/index.js";
import * as Unsafe_Coerce from "../Unsafe.Coerce/index.js";
var coerce = /* #__PURE__ */ Safe_Coerce.coerce();
var max = /* #__PURE__ */ Data_Ord.max(Data_Ord.ordInt);
var append = /* #__PURE__ */ Data_Semigroup.append(Data_Semigroup.semigroupArray);
var intercalate1 = /* #__PURE__ */ Data_Semigroup_Foldable.intercalate(Data_Array_NonEmpty_Internal.foldable1NonEmptyArray);
var foldMap11 = /* #__PURE__ */ Data_Semigroup_Foldable.foldMap1(Data_Array_NonEmpty_Internal.foldable1NonEmptyArray);
var fold11 = /* #__PURE__ */ Data_Semigroup_Foldable.fold1(Data_Array_NonEmpty_Internal.foldable1NonEmptyArray);
var fromJust = /* #__PURE__ */ Data_Maybe.fromJust();
var unsafeIndex1 = /* #__PURE__ */ Data_Array.unsafeIndex();
var unsafeFromArrayF = Unsafe_Coerce.unsafeCoerce;
var unsafeFromArray = Data_Array_NonEmpty_Internal.NonEmptyArray;
var transpose = function ($99) {
    return coerce(Data_Array.transpose(coerce($99)));
};
var toArray = function (v) {
    return v;
};
var unionBy$prime = function (eq) {
    return function (xs) {
        var $100 = Data_Array.unionBy(eq)(toArray(xs));
        return function ($101) {
            return unsafeFromArray($100($101));
        };
    };
};
var union$prime = function (dictEq) {
    return unionBy$prime(Data_Eq.eq(dictEq));
};
var unionBy = function (eq) {
    return function (xs) {
        var $102 = unionBy$prime(eq)(xs);
        return function ($103) {
            return $102(toArray($103));
        };
    };
};
var union = function (dictEq) {
    return unionBy(Data_Eq.eq(dictEq));
};
var unzip = /* #__PURE__ */ (function () {
    var $104 = Data_Bifunctor.bimap(Data_Bifunctor.bifunctorTuple)(unsafeFromArray)(unsafeFromArray);
    return function ($105) {
        return $104(Data_Array.unzip(toArray($105)));
    };
})();
var updateAt = function (i) {
    return function (x) {
        var $106 = Data_Array.updateAt(i)(x);
        return function ($107) {
            return unsafeFromArrayF($106(toArray($107)));
        };
    };
};
var zip = function (xs) {
    return function (ys) {
        return unsafeFromArray(Data_Array.zip(toArray(xs))(toArray(ys)));
    };
};
var zipWith = function (f) {
    return function (xs) {
        return function (ys) {
            return unsafeFromArray(Data_Array.zipWith(f)(toArray(xs))(toArray(ys)));
        };
    };
};
var zipWithA = function (dictApplicative) {
    var zipWithA1 = Data_Array.zipWithA(dictApplicative);
    return function (f) {
        return function (xs) {
            return function (ys) {
                return unsafeFromArrayF(zipWithA1(f)(toArray(xs))(toArray(ys)));
            };
        };
    };
};
var splitAt = function (i) {
    return function (xs) {
        return Data_Array.splitAt(i)(toArray(xs));
    };
};
var some = function (dictAlternative) {
    var some1 = Data_Array.some(dictAlternative);
    return function (dictLazy) {
        var $108 = some1(dictLazy);
        return function ($109) {
            return unsafeFromArrayF($108($109));
        };
    };
};
var snoc$prime = function (xs) {
    return function (x) {
        return unsafeFromArray(Data_Array.snoc(xs)(x));
    };
};
var snoc = function (xs) {
    return function (x) {
        return unsafeFromArray(Data_Array.snoc(toArray(xs))(x));
    };
};
var singleton = function ($110) {
    return unsafeFromArray(Data_Array.singleton($110));
};
var replicate = function (i) {
    return function (x) {
        return unsafeFromArray(Data_Array.replicate(max(1)(i))(x));
    };
};
var range = function (x) {
    return function (y) {
        return unsafeFromArray(Data_Array.range(x)(y));
    };
};
var prependArray = function (xs) {
    return function (ys) {
        return unsafeFromArray(append(xs)(toArray(ys)));
    };
};
var modifyAt = function (i) {
    return function (f) {
        var $111 = Data_Array.modifyAt(i)(f);
        return function ($112) {
            return unsafeFromArrayF($111(toArray($112)));
        };
    };
};
var intersectBy$prime = function (eq) {
    return function (xs) {
        return Data_Array.intersectBy(eq)(toArray(xs));
    };
};
var intersectBy = function (eq) {
    return function (xs) {
        var $113 = intersectBy$prime(eq)(xs);
        return function ($114) {
            return $113(toArray($114));
        };
    };
};
var intersect$prime = function (dictEq) {
    return intersectBy$prime(Data_Eq.eq(dictEq));
};
var intersect = function (dictEq) {
    return intersectBy(Data_Eq.eq(dictEq));
};
var intercalate = function (dictSemigroup) {
    return intercalate1(dictSemigroup);
};
var insertAt = function (i) {
    return function (x) {
        var $115 = Data_Array.insertAt(i)(x);
        return function ($116) {
            return unsafeFromArrayF($115(toArray($116)));
        };
    };
};
var fromFoldable1 = function (dictFoldable1) {
    var $117 = Data_Array.fromFoldable(dictFoldable1.Foldable0());
    return function ($118) {
        return unsafeFromArray($117($118));
    };
};
var fromArray = function (xs) {
    if (Data_Array.length(xs) > 0) {
        return new Data_Maybe.Just(unsafeFromArray(xs));
    };
    if (Data_Boolean.otherwise) {
        return Data_Maybe.Nothing.value;
    };
    throw new Error("Failed pattern match at Data.Array.NonEmpty (line 161, column 1 - line 161, column 58): " + [ xs.constructor.name ]);
};
var fromFoldable = function (dictFoldable) {
    var $119 = Data_Array.fromFoldable(dictFoldable);
    return function ($120) {
        return fromArray($119($120));
    };
};
var transpose$prime = function ($121) {
    return fromArray(Data_Array.transpose(coerce($121)));
};
var foldr1 = /* #__PURE__ */ Data_Semigroup_Foldable.foldr1(Data_Array_NonEmpty_Internal.foldable1NonEmptyArray);
var foldl1 = /* #__PURE__ */ Data_Semigroup_Foldable.foldl1(Data_Array_NonEmpty_Internal.foldable1NonEmptyArray);
var foldMap1 = function (dictSemigroup) {
    return foldMap11(dictSemigroup);
};
var fold1 = function (dictSemigroup) {
    return fold11(dictSemigroup);
};
var difference$prime = function (dictEq) {
    var difference1 = Data_Array.difference(dictEq);
    return function (xs) {
        return difference1(toArray(xs));
    };
};
var cons$prime = function (x) {
    return function (xs) {
        return unsafeFromArray(Data_Array.cons(x)(xs));
    };
};
var fromNonEmpty = function (v) {
    return cons$prime(v.value0)(v.value1);
};
var concatMap = /* #__PURE__ */ Data_Function.flip(/* #__PURE__ */ Control_Bind.bind(Data_Array_NonEmpty_Internal.bindNonEmptyArray));
var concat = /* #__PURE__ */ (function () {
    var $122 = Data_Functor.map(Data_Array_NonEmpty_Internal.functorNonEmptyArray)(toArray);
    return function ($123) {
        return unsafeFromArray(Data_Array.concat(toArray($122($123))));
    };
})();
var appendArray = function (xs) {
    return function (ys) {
        return unsafeFromArray(append(toArray(xs))(ys));
    };
};
var alterAt = function (i) {
    return function (f) {
        var $124 = Data_Array.alterAt(i)(f);
        return function ($125) {
            return $124(toArray($125));
        };
    };
};
var adaptMaybe = function (f) {
    return function ($126) {
        return fromJust(f(toArray($126)));
    };
};
var head = /* #__PURE__ */ adaptMaybe(Data_Array.head);
var init = /* #__PURE__ */ adaptMaybe(Data_Array.init);
var last = /* #__PURE__ */ adaptMaybe(Data_Array.last);
var tail = /* #__PURE__ */ adaptMaybe(Data_Array.tail);
var uncons = /* #__PURE__ */ adaptMaybe(Data_Array.uncons);
var toNonEmpty = function ($127) {
    return (function (v) {
        return new Data_NonEmpty.NonEmpty(v.head, v.tail);
    })(uncons($127));
};
var unsnoc = /* #__PURE__ */ adaptMaybe(Data_Array.unsnoc);
var adaptAny = function (f) {
    return function ($128) {
        return f(toArray($128));
    };
};
var all = function (p) {
    return adaptAny(Data_Array.all(p));
};
var any = function (p) {
    return adaptAny(Data_Array.any(p));
};
var catMaybes = /* #__PURE__ */ adaptAny(Data_Array.catMaybes);
var $$delete = function (dictEq) {
    var delete1 = Data_Array["delete"](dictEq);
    return function (x) {
        return adaptAny(delete1(x));
    };
};
var deleteAt = function (i) {
    return adaptAny(Data_Array.deleteAt(i));
};
var deleteBy = function (f) {
    return function (x) {
        return adaptAny(Data_Array.deleteBy(f)(x));
    };
};
var difference = function (dictEq) {
    var difference$prime1 = difference$prime(dictEq);
    return function (xs) {
        return adaptAny(difference$prime1(xs));
    };
};
var drop = function (i) {
    return adaptAny(Data_Array.drop(i));
};
var dropEnd = function (i) {
    return adaptAny(Data_Array.dropEnd(i));
};
var dropWhile = function (f) {
    return adaptAny(Data_Array.dropWhile(f));
};
var elem = function (dictEq) {
    var elem1 = Data_Array.elem(dictEq);
    return function (x) {
        return adaptAny(elem1(x));
    };
};
var elemIndex = function (dictEq) {
    var elemIndex1 = Data_Array.elemIndex(dictEq);
    return function (x) {
        return adaptAny(elemIndex1(x));
    };
};
var elemLastIndex = function (dictEq) {
    var elemLastIndex1 = Data_Array.elemLastIndex(dictEq);
    return function (x) {
        return adaptAny(elemLastIndex1(x));
    };
};
var filter = function (f) {
    return adaptAny(Data_Array.filter(f));
};
var filterA = function (dictApplicative) {
    var filterA1 = Data_Array.filterA(dictApplicative);
    return function (f) {
        return adaptAny(filterA1(f));
    };
};
var find = function (p) {
    return adaptAny(Data_Array.find(p));
};
var findIndex = function (p) {
    return adaptAny(Data_Array.findIndex(p));
};
var findLastIndex = function (x) {
    return adaptAny(Data_Array.findLastIndex(x));
};
var findMap = function (p) {
    return adaptAny(Data_Array.findMap(p));
};
var foldM = function (dictMonad) {
    var foldM1 = Data_Array.foldM(dictMonad);
    return function (f) {
        return function (acc) {
            return adaptAny(foldM1(f)(acc));
        };
    };
};
var foldRecM = function (dictMonadRec) {
    var foldRecM1 = Data_Array.foldRecM(dictMonadRec);
    return function (f) {
        return function (acc) {
            return adaptAny(foldRecM1(f)(acc));
        };
    };
};
var index = /* #__PURE__ */ adaptAny(Data_Array.index);
var length = /* #__PURE__ */ adaptAny(Data_Array.length);
var mapMaybe = function (f) {
    return adaptAny(Data_Array.mapMaybe(f));
};
var notElem = function (dictEq) {
    var notElem1 = Data_Array.notElem(dictEq);
    return function (x) {
        return adaptAny(notElem1(x));
    };
};
var partition = function (f) {
    return adaptAny(Data_Array.partition(f));
};
var slice = function (start) {
    return function (end) {
        return adaptAny(Data_Array.slice(start)(end));
    };
};
var span = function (f) {
    return adaptAny(Data_Array.span(f));
};
var take = function (i) {
    return adaptAny(Data_Array.take(i));
};
var takeEnd = function (i) {
    return adaptAny(Data_Array.takeEnd(i));
};
var takeWhile = function (f) {
    return adaptAny(Data_Array.takeWhile(f));
};
var toUnfoldable = function (dictUnfoldable) {
    return adaptAny(Data_Array.toUnfoldable(dictUnfoldable));
};
var unsafeAdapt = function (f) {
    var $129 = adaptAny(f);
    return function ($130) {
        return unsafeFromArray($129($130));
    };
};
var cons = function (x) {
    return unsafeAdapt(Data_Array.cons(x));
};
var group = function (dictEq) {
    return unsafeAdapt(Data_Array.group(dictEq));
};
var groupAllBy = function (op) {
    return unsafeAdapt(Data_Array.groupAllBy(op));
};
var groupAll = function (dictOrd) {
    return groupAllBy(Data_Ord.compare(dictOrd));
};
var groupBy = function (op) {
    return unsafeAdapt(Data_Array.groupBy(op));
};
var insert = function (dictOrd) {
    var insert1 = Data_Array.insert(dictOrd);
    return function (x) {
        return unsafeAdapt(insert1(x));
    };
};
var insertBy = function (f) {
    return function (x) {
        return unsafeAdapt(Data_Array.insertBy(f)(x));
    };
};
var intersperse = function (x) {
    return unsafeAdapt(Data_Array.intersperse(x));
};
var mapWithIndex = function (f) {
    return unsafeAdapt(Data_Array.mapWithIndex(f));
};
var modifyAtIndices = function (dictFoldable) {
    var modifyAtIndices1 = Data_Array.modifyAtIndices(dictFoldable);
    return function (is) {
        return function (f) {
            return unsafeAdapt(modifyAtIndices1(is)(f));
        };
    };
};
var nub = function (dictOrd) {
    return unsafeAdapt(Data_Array.nub(dictOrd));
};
var nubBy = function (f) {
    return unsafeAdapt(Data_Array.nubBy(f));
};
var nubByEq = function (f) {
    return unsafeAdapt(Data_Array.nubByEq(f));
};
var nubEq = function (dictEq) {
    return unsafeAdapt(Data_Array.nubEq(dictEq));
};
var reverse = /* #__PURE__ */ unsafeAdapt(Data_Array.reverse);
var scanl = function (f) {
    return function (x) {
        return unsafeAdapt(Data_Array.scanl(f)(x));
    };
};
var scanr = function (f) {
    return function (x) {
        return unsafeAdapt(Data_Array.scanr(f)(x));
    };
};
var sort = function (dictOrd) {
    return unsafeAdapt(Data_Array.sort(dictOrd));
};
var sortBy = function (f) {
    return unsafeAdapt(Data_Array.sortBy(f));
};
var sortWith = function (dictOrd) {
    var sortWith1 = Data_Array.sortWith(dictOrd);
    return function (f) {
        return unsafeAdapt(sortWith1(f));
    };
};
var updateAtIndices = function (dictFoldable) {
    var updateAtIndices1 = Data_Array.updateAtIndices(dictFoldable);
    return function (pairs) {
        return unsafeAdapt(updateAtIndices1(pairs));
    };
};
var unsafeIndex = function () {
    return adaptAny(unsafeIndex1);
};
var unsafeIndex2 = /* #__PURE__ */ unsafeIndex();
var toUnfoldable1 = function (dictUnfoldable1) {
    var unfoldr1 = Data_Unfoldable1.unfoldr1(dictUnfoldable1);
    return function (xs) {
        var len = length(xs);
        var f = function (i) {
            return new Data_Tuple.Tuple(unsafeIndex2(xs)(i), (function () {
                var $98 = i < (len - 1 | 0);
                if ($98) {
                    return new Data_Maybe.Just(i + 1 | 0);
                };
                return Data_Maybe.Nothing.value;
            })());
        };
        return unfoldr1(f)(0);
    };
};
export {
    fromArray,
    fromNonEmpty,
    toArray,
    toNonEmpty,
    fromFoldable,
    fromFoldable1,
    toUnfoldable,
    toUnfoldable1,
    singleton,
    range,
    replicate,
    some,
    length,
    cons,
    cons$prime,
    snoc,
    snoc$prime,
    appendArray,
    prependArray,
    insert,
    insertBy,
    head,
    last,
    tail,
    init,
    uncons,
    unsnoc,
    index,
    elem,
    notElem,
    elemIndex,
    elemLastIndex,
    find,
    findMap,
    findIndex,
    findLastIndex,
    insertAt,
    deleteAt,
    updateAt,
    updateAtIndices,
    modifyAt,
    modifyAtIndices,
    alterAt,
    intersperse,
    reverse,
    concat,
    concatMap,
    filter,
    partition,
    splitAt,
    filterA,
    mapMaybe,
    catMaybes,
    mapWithIndex,
    foldl1,
    foldr1,
    foldMap1,
    fold1,
    intercalate,
    transpose,
    transpose$prime,
    scanl,
    scanr,
    sort,
    sortBy,
    sortWith,
    slice,
    take,
    takeEnd,
    takeWhile,
    drop,
    dropEnd,
    dropWhile,
    span,
    group,
    groupAll,
    groupBy,
    groupAllBy,
    nub,
    nubBy,
    nubEq,
    nubByEq,
    union,
    union$prime,
    unionBy,
    unionBy$prime,
    $$delete as delete,
    deleteBy,
    difference,
    difference$prime,
    intersect,
    intersect$prime,
    intersectBy,
    intersectBy$prime,
    zipWith,
    zipWithA,
    zip,
    unzip,
    any,
    all,
    foldM,
    foldRecM,
    unsafeIndex
};
