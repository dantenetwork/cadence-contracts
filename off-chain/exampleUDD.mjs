import fs from 'fs';
import path from 'path';

import fcl from '@onflow/fcl';
import * as types from "@onflow/types";
import FlowService from './flowoffchain.mjs'
import {sha256} from 'js-sha256';

const flowService = new FlowService('0xf8d6e0586b0a20c7', 
                                    '69e7e51ead557351ade7a575e947c4d4bd19dd8a6cdf00c51f9c7f6f721b72dc',
                                    0,
                                    sha256,
                                    'p256');

async function exeUDDScript() {
    // Genereate digest
    const script = fs.readFileSync(
        path.join(
            process.cwd(),
            '../test/scripts/testInputComplex.cdc'
        ),
        'utf8'
    );

    console.log(await fcl.config.get('Profile'));

    const session = {
        "type": "Struct",
        "value": {
            "id": `A.${await fcl.config.get('Profile')}.MessageProtocol.Session`,
            "fields": [
                {
                    "name": "id",
                    "value": {"type": "UInt128", "value": "1"}
                },
                {
                    "name": "type",
                    "value": {"type": "UInt8", "value": "2"}
                },
                {
                    "name": "callback",
                    "value": {"type": "Optional", "value": {"type": "Array", "value": [{"type": "UInt8", "value": "3"}, {"type": "UInt8", "value": "4"}]}}
                },
                {
                    "name": "commitment",
                    "value": {"type": "Optional", "value": {"type": "Array", "value": [{"type": "UInt8", "value": "5"}, {"type": "UInt8", "value": "6"}]}}
                },
                {
                    "name": "answer",
                    "value": {"type": "Optional", "value": {"type": "Array", "value": [{"type": "UInt8", "value": "7"}, {"type": "UInt8", "value": "8"}]}}
                }
            ]
        }
    };

    console.log(JSON.stringify(session));

    const session2 = {
        type:"Struct",
        value:{
            id:"A.f8d6e0586b0a20c7.MessageProtocol.Session",
            fields:[
                {
                    name:"id",
                    value:{
                        type:"UInt128",
                        value:"1"
                    }
                },
                {
                    name:"type",value:{type:"UInt8",value:"2"}
                },
                {
                    name:"callback",value:{type:"Optional",value:{type:"Array",value:[{type:"UInt8",value:"3"},{type:"UInt8",value:"4"}]}}
                },
                {
                    name:"commitment",value:{type:"Optional",value:{type:"Array",value:[{type:"UInt8",value:"5"},{type:"UInt8",value:"6"}]}}
                },
                {
                    name:"answer",value:{type:"Optional",value:{type:"Array",value:[{type:"UInt8",value:"7"},{type:"UInt8",value:"8"}]}}
                }
            ]
        }
    };

    // const arg1 = fcl.arg(session, types.Struct);

    // console.log(arg1.value.value.fields[2].value.value);

    let rstData = await flowService.executeScripts({
        script: script,
        args: [
            fcl.arg(session, types.Struct),
            fcl.arg("hello nika", types.String)
        ]
    });

    console.log(rstData);
}

await exeUDDScript();
