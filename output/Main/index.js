import * as Effect_Console from "../Effect.Console/index.js";
var SelectorString = /* #__PURE__ */ (function () {
    function SelectorString(value0) {
        this.value0 = value0;
    };
    SelectorString.create = function (value0) {
        return new SelectorString(value0);
    };
    return SelectorString;
})();
var SelectorFunction = /* #__PURE__ */ (function () {
    function SelectorFunction(value0) {
        this.value0 = value0;
    };
    SelectorFunction.create = function (value0) {
        return new SelectorFunction(value0);
    };
    return SelectorFunction;
})();
var Attr = /* #__PURE__ */ (function () {
    function Attr(value0, value1) {
        this.value0 = value0;
        this.value1 = value1;
    };
    Attr.create = function (value0) {
        return function (value1) {
            return new Attr(value0, value1);
        };
    };
    return Attr;
})();
var AttrFunction = /* #__PURE__ */ (function () {
    function AttrFunction(value0, value1) {
        this.value0 = value0;
        this.value1 = value1;
    };
    AttrFunction.create = function (value0) {
        return function (value1) {
            return new AttrFunction(value0, value1);
        };
    };
    return AttrFunction;
})();
var Style = /* #__PURE__ */ (function () {
    function Style() {

    };
    Style.value = new Style();
    return Style;
})();
var Remove = /* #__PURE__ */ (function () {
    function Remove() {

    };
    Remove.value = new Remove();
    return Remove;
})();
var Append = /* #__PURE__ */ (function () {
    function Append(value0) {
        this.value0 = value0;
    };
    Append.create = function (value0) {
        return new Append(value0);
    };
    return Append;
})();
var Insert = /* #__PURE__ */ (function () {
    function Insert(value0) {
        this.value0 = value0;
    };
    Insert.create = function (value0) {
        return new Insert(value0);
    };
    return Insert;
})();
var Transition = /* #__PURE__ */ (function () {
    function Transition(value0) {
        this.value0 = value0;
    };
    Transition.create = function (value0) {
        return new Transition(value0);
    };
    return Transition;
})();
var main = /* #__PURE__ */ Effect_Console.log("\ud83c\udf5d");

// special case where the datum is used as the key and we just ignore the index and nodes
var identityKeyFunction = function (dictOrd) {
    return function (dictOrd1) {
        return function (d) {
            return function (v) {
                return function (v1) {
                    return d;
                };
            };
        };
    };
};
var emptySelection = {
    groups: [  ],
    parents: [  ]
};

// insertBeforeSelection :: Selection -> DOM.Element -> Selection
var insertBeforeSelection = function (selection) {
    return function (element) {
        return emptySelection;
    };
};

// corresponds to D3's d3.select
var selectFirst = function (selector) {
    return emptySelection;
};

// corresponds to D3's selection.select
var selectFirstFrom = function (selection) {
    return function (selector) {
        return emptySelection;
    };
};

// corresponds to D3's selection.selectAll
var selectGrouped = function (selection) {
    return function (selector) {
        return emptySelection;
    };
};

// corresponds to D3's d3.selectAll
var selectMany = function (selector) {
    return emptySelection;
};
var emptyEnterSelection = {
    enter: [  ],
    exit: [  ],
    update: [  ],
    parents: [  ]
};
var subdivideData = function (selection) {
    return function (keyFunction) {
        return emptyEnterSelection;
    };
};

// if the data is not simply ordered by index, then the key function is used to match the data to the nodes
var assignDataToSelection = function (selection) {
    return function (ds) {
        return function (keyFunction) {
            return emptyEnterSelection;
        };
    };
};

// now that the data has been assigned to the nodes, we can apply the actions to the nodes
// the actions that are applied to the enter, exit, and update selections are different
// we end up with a new selection which is the merge of the enter and update selections
var applyDataToSelection = function (updateSelection) {
    return function (actions) {
        return emptySelection;
    };
};

// appendToSelection :: Selection -> DOM.Element -> Selection
var appendToSelection = function (selection) {
    return function (element) {
        return emptySelection;
    };
};
var matrix2Table = /* #__PURE__ */ (function () {
    var three = selectMany(new SelectorString("tr"));
    var one = selectFirst(new SelectorString("body"));
    var two = appendToSelection(one)("table");
    var four = assignDataToSelection(three)([ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ])(function (dictOrd) {
        var identityKeyFunction1 = identityKeyFunction(dictOrd);
        return function (dictOrd1) {
            return identityKeyFunction1(dictOrd1);
        };
    });
    var five = applyDataToSelection(four)({
        enter: [ new Append("tr") ],
        exit: [ Remove.value ],
        update: [  ]
    });
    var six = selectGrouped(five)(new SelectorString("td"));
    var seven = subdivideData(six)(function (dictOrd) {
        var identityKeyFunction1 = identityKeyFunction(dictOrd);
        return function (dictOrd1) {
            return identityKeyFunction1(dictOrd1);
        };
    });
    var eight = applyDataToSelection(seven)({
        enter: [ new Append("td") ],
        exit: [ Remove.value ],
        update: [ new Attr("class", "cell") ]
    });
    return Effect_Console.log("\ud83c\udf5d");
})();
export {
    Attr,
    AttrFunction,
    Style,
    Remove,
    Append,
    Insert,
    Transition,
    SelectorString,
    SelectorFunction,
    assignDataToSelection,
    identityKeyFunction,
    main,
    selectFirst,
    selectFirstFrom,
    selectGrouped,
    selectMany
};
