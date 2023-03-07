// Generated by purs version 0.15.7
import * as Data_Ring from "../Data.Ring/index.js";
import * as Data_Semiring from "../Data.Semiring/index.js";
var ringRecord = /* #__PURE__ */ Data_Ring.ringRecord();
var commutativeRingUnit = {
    Ring0: function () {
        return Data_Ring.ringUnit;
    }
};
var commutativeRingRecordNil = {
    RingRecord0: function () {
        return Data_Ring.ringRecordNil;
    }
};
var commutativeRingRecordCons = function (dictIsSymbol) {
    var ringRecordCons = Data_Ring.ringRecordCons(dictIsSymbol)();
    return function () {
        return function (dictCommutativeRingRecord) {
            var ringRecordCons1 = ringRecordCons(dictCommutativeRingRecord.RingRecord0());
            return function (dictCommutativeRing) {
                var ringRecordCons2 = ringRecordCons1(dictCommutativeRing.Ring0());
                return {
                    RingRecord0: function () {
                        return ringRecordCons2;
                    }
                };
            };
        };
    };
};
var commutativeRingRecord = function () {
    return function (dictCommutativeRingRecord) {
        var ringRecord1 = ringRecord(dictCommutativeRingRecord.RingRecord0());
        return {
            Ring0: function () {
                return ringRecord1;
            }
        };
    };
};
var commutativeRingProxy = {
    Ring0: function () {
        return Data_Ring.ringProxy;
    }
};
var commutativeRingNumber = {
    Ring0: function () {
        return Data_Ring.ringNumber;
    }
};
var commutativeRingInt = {
    Ring0: function () {
        return Data_Ring.ringInt;
    }
};
var commutativeRingFn = function (dictCommutativeRing) {
    var ringFn = Data_Ring.ringFn(dictCommutativeRing.Ring0());
    return {
        Ring0: function () {
            return ringFn;
        }
    };
};
export {
    commutativeRingInt,
    commutativeRingNumber,
    commutativeRingUnit,
    commutativeRingFn,
    commutativeRingRecord,
    commutativeRingProxy,
    commutativeRingRecordNil,
    commutativeRingRecordCons
};
export {
    add,
    mul,
    one,
    zero
} from "../Data.Semiring/index.js";
