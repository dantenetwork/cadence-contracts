import * as fcl from '@onflow/fcl';
import * as types from "@onflow/types";
import { type } from 'os';

export enum SQoSType {
    Reveal = 0,
    Challenge,
    Threshold,
    Priority,
    ExceptionRollback,
    SelectionDelay,
    Anonymous,
    Identity,
    Isolation,
    CrossVerify
}

export class SQoSItem {
    t: SQoSType;
    v: Uint8Array;
    id: string;

    constructor(type: SQoSType, value: Uint8Array | Buffer, moduleAddress: string) {
        this.t = type;
        this.v = value;
        if (moduleAddress.startsWith('0x')) {
            this.id = 'A.' + moduleAddress.slice(2) + '.MessageProtocol.InputSQoSItem';
        } else {
            this.id = 'A.' + moduleAddress + '.MessageProtocol.InputSQoSItem';
        }
    }

    get_fcl_arg() {

        return fcl.arg({
            fields: [
              {name: "t", value: String(this.t)},
              {name: "v", value: Array.from(this.v).map((num: number) => {return String(num);})},
            ]
        },types.Struct(this.id, [
            {name: "t", value: types.UInt8},
            {name: "v", value: types.Array(types.UInt8)},
        ]));
    }

    get_value() {
        return {
                    fields: [
                    {name: "t", value: String(this.t)},
                    {name: "v", value: Array.from(this.v).map((num: number) => {return String(num);})},
                    ]
                }
    }

    get_type() {
        return types.Struct(this.id, [
                    {name: "t", value: types.UInt8},
                    {name: "v", value: types.Array(types.UInt8)},
                ]);
    }

    static type_trait(moduleAddress: string) {
        var id;
        if (moduleAddress.startsWith('0x')) {
            id = 'A.' + moduleAddress.slice(2) + '.MessageProtocol.InputSQoSItem';
        } else {
            id = 'A.' + moduleAddress + '.MessageProtocol.InputSQoSItem';
        }

        return types.Struct(id, [
            {name: "t", value: types.UInt8},
            {name: "v", value: types.Array(types.UInt8)},
        ]);
    }
}

export class SQoSItemArray {
    v: [SQoSItem];
    id: string;

    constructor(value: [SQoSItem], moduleAddress: string) {
        this.v = value;
        if (moduleAddress.startsWith('0x')) {
            this.id = 'A.' + moduleAddress.slice(2) + '.MessageProtocol.InputSQoSArray';
        } else {
            this.id = 'A.' + moduleAddress + '.MessageProtocol.InputSQoSArray';
        }
    }

    get_fcl_arg() {

        const values = this.v.map(item => {return item.get_value()});

        return fcl.arg({
            fields: [
              {name: "v", value: values},
            ]
        },types.Struct(this.id, [
            {name: "v", value: types.Array(SQoSItem.type_trait(this.id.slice(2, 2 + 16)))},
        ]));
    }

    get_value() {
        const values = this.v.map(item => {return item.get_value()});

        return {
                    fields: [
                        {name: "v", value: values},
                    ]
                }
    }

    get_type() {
        return types.Struct(this.id, [
            {name: "v", value: types.Array(SQoSItem.type_trait(this.id))},
        ]);
    }

    static type_trait(moduleAddress: string) {
        var id;
        if (moduleAddress.startsWith('0x')) {
            id = 'A.' + moduleAddress.slice(2) + '.MessageProtocol.InputSQoSArray';
        } else {
            id = 'A.' + moduleAddress + '.MessageProtocol.InputSQoSArray';
        }

        return types.Struct(id, [
            {name: "v", value: types.Array(SQoSItem.type_trait(id))},
        ]);
    }
}


