"use strict";
exports.__esModule = true;
exports.SQoSItemArray = exports.SQoSItem = exports.SQoSType = void 0;
var fcl = require("@onflow/fcl");
var types = require("@onflow/types");
var SQoSType;
(function (SQoSType) {
    SQoSType[SQoSType["Reveal"] = 0] = "Reveal";
    SQoSType[SQoSType["Challenge"] = 1] = "Challenge";
    SQoSType[SQoSType["Threshold"] = 2] = "Threshold";
    SQoSType[SQoSType["Priority"] = 3] = "Priority";
    SQoSType[SQoSType["ExceptionRollback"] = 4] = "ExceptionRollback";
    SQoSType[SQoSType["SelectionDelay"] = 5] = "SelectionDelay";
    SQoSType[SQoSType["Anonymous"] = 6] = "Anonymous";
    SQoSType[SQoSType["Identity"] = 7] = "Identity";
    SQoSType[SQoSType["Isolation"] = 8] = "Isolation";
    SQoSType[SQoSType["CrossVerify"] = 9] = "CrossVerify";
})(SQoSType = exports.SQoSType || (exports.SQoSType = {}));
var SQoSItem = /** @class */ (function () {
    function SQoSItem(type, value, moduleAddress) {
        this.t = type;
        this.v = value;
        if (moduleAddress.startsWith('0x')) {
            this.id = 'A.' + moduleAddress.slice(2) + '.MessageProtocol.InputSQoSItem';
        }
        else {
            this.id = 'A.' + moduleAddress + '.MessageProtocol.InputSQoSItem';
        }
    }
    SQoSItem.prototype.get_fcl_arg = function () {
        return fcl.arg({
            fields: [
                { name: "t", value: String(this.t) },
                { name: "v", value: Array.from(this.v).map(function (num) { return String(num); }) },
            ]
        }, types.Struct(this.id, [
            { name: "t", value: types.UInt8 },
            { name: "v", value: types.Array(types.UInt8) },
        ]));
    };
    SQoSItem.prototype.get_value = function () {
        return {
            fields: [
                { name: "t", value: String(this.t) },
                { name: "v", value: Array.from(this.v).map(function (num) { return String(num); }) },
            ]
        };
    };
    SQoSItem.prototype.get_type = function () {
        return types.Struct(this.id, [
            { name: "t", value: types.UInt8 },
            { name: "v", value: types.Array(types.UInt8) },
        ]);
    };
    SQoSItem.type_trait = function (moduleAddress) {
        var id;
        if (moduleAddress.startsWith('0x')) {
            id = 'A.' + moduleAddress.slice(2) + '.MessageProtocol.InputSQoSItem';
        }
        else {
            id = 'A.' + moduleAddress + '.MessageProtocol.InputSQoSItem';
        }
        return types.Struct(id, [
            { name: "t", value: types.UInt8 },
            { name: "v", value: types.Array(types.UInt8) },
        ]);
    };
    return SQoSItem;
}());
exports.SQoSItem = SQoSItem;
var SQoSItemArray = /** @class */ (function () {
    function SQoSItemArray(value, moduleAddress) {
        this.v = value;
        if (moduleAddress.startsWith('0x')) {
            this.id = 'A.' + moduleAddress.slice(2) + '.MessageProtocol.InputSQoSArray';
        }
        else {
            this.id = 'A.' + moduleAddress + '.MessageProtocol.InputSQoSArray';
        }
    }
    SQoSItemArray.prototype.get_fcl_arg = function () {
        var values = this.v.map(function (item) { return item.get_value(); });
        return fcl.arg({
            fields: [
                { name: "v", value: values },
            ]
        }, types.Struct(this.id, [
            { name: "v", value: types.Array(SQoSItem.type_trait(this.id.slice(2, 2 + 16))) },
        ]));
    };
    SQoSItemArray.prototype.get_value = function () {
        var values = this.v.map(function (item) { return item.get_value(); });
        return {
            fields: [
                { name: "v", value: values },
            ]
        };
    };
    SQoSItemArray.prototype.get_type = function () {
        return types.Struct(this.id, [
            { name: "v", value: types.Array(SQoSItem.type_trait(this.id)) },
        ]);
    };
    SQoSItemArray.type_trait = function (moduleAddress) {
        var id;
        if (moduleAddress.startsWith('0x')) {
            id = 'A.' + moduleAddress.slice(2) + '.MessageProtocol.InputSQoSArray';
        }
        else {
            id = 'A.' + moduleAddress + '.MessageProtocol.InputSQoSArray';
        }
        return types.Struct(id, [
            { name: "v", value: types.Array(SQoSItem.type_trait(id)) },
        ]);
    };
    return SQoSItemArray;
}());
exports.SQoSItemArray = SQoSItemArray;
