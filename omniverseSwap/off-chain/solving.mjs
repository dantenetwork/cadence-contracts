import nerdamer from 'nerdamer'; 
// Load additional modules. These are not required.  
import 'nerdamer/Algebra.js'; 
import 'nerdamer/Calculus.js'; 
import 'nerdamer/Solve.js'; 
import 'nerdamer/Extra.js';
// import 'nerdamer/Diff.js';

async function solve() {
    var x6 = nerdamer.solveEquations(['2x+y=7', 'x-y+3z=11', 'y-z=-1']);
    console.log(x6.toString());
}

async function solve_O_AMM_from_X(x, b, C) {
    var y = nerdamer.solveEquations(['a=x*y/(((x+y)/2)^2)', 'a*(-(x**2+y**2)+b*(x+y)) + 2*(1-a)*C=2*x*y', `x=${x}`, `b=${b}`, `C=${C}`]);
    // console.log(y);
    return y;
}

async function solve_O_AMM_from_Y(y, b, C) {
    var x = nerdamer.solveEquations(['a=x*y/(((x+y)/2)^2)', 'a*(-(x**2+y**2)+b*(x+y)) + 2*(1-a)*C=2*x*y', `y=${y}`, `b=${b}`, `C=${C}`]);
    // console.log(x)
    return x;
}

// `token={t_name: .. , t_value: ..}`
async function solve_O_AMM(token, b, C) {
    var other = nerdamer.solveEquations(['a=x*y/(((x+y)/2)^2)', 'a*(-(x**2+y**2)+b*(x+y)) + 2*(1-a)*C=2*x*y', `${token.t_name}=${token.t_value}`, `b=${b}`, `C=${C}`]);
    // console.log(x)
    return other;
}

async function get_price(x, y, b, C) {
    // Note that there must not be any `spaces`
    const expr = '(x*y/(((x+y)/2)^2))*(-(x**2+y**2)+b*(x+y))+2*(1-(x*y/(((x+y)/2)^2)))*C-2*x*y';

    const dzdx = nerdamer.diff(expr, 'x', 1);
    // console.log(dzdx.toString());
    const zx = nerdamer.solveEquations(['z='+dzdx.toString(), `x=${x}`, `y=${y}`, `b=${b}`, `C=${C}`]);
    // console.log(zx);
    const dzdy = nerdamer.diff(expr, 'y', 1);
    // console.log(dzdy.toString());
    const zy = nerdamer.solveEquations(['z='+dzdy.toString(), `x=${x}`, `y=${y}`, `b=${b}`, `C=${C}`]);
    // console.log(zy);

    const price = -get_result('z', zx)/get_result('z', zy);
    console.log(price);

    return price;
}

function get_result(symbol, rsts) {
    // console.log(rsts)
    for (var idx in rsts) {
        // console.log(rsts[idx]);
        if (rsts[idx][0] == symbol) {
            return rsts[idx][1];
        }
    }
}

// @inToken: {t_name: .., dx: .., x: ..}
// @b, @C and the balance of the @input token need to be achieved on-chain
// return: swap out token, [`balance before swap`, `swap out amount`]
async function swap(inToken, b, C) {
    const y_src = await solve_O_AMM({t_name: inToken.t_name, t_value: inToken.x}, b, C);
    let y = get_result('y', y_src);

    const y_after = await solve_O_AMM({t_name: inToken.t_name, t_value: inToken.x + inToken.dx}, b, C);
    const dy = y - get_result('y', y_after);
    return [y, dy];
}

async function test_swap() {
    let x = 10;
    let y = 20;

    let C = x * y;
    let b = 2 * Math.sqrt(C);

    const x_in = 5;
    const dx = 1;
    let y_out = await swap({t_name: 'x', x: x_in, dx: dx}, b, C);

    // console.log(y_out);
    console.log(`in:  x: ${x_in.toFixed(2)}, dx: ${dx.toFixed(2)}\nout: y: ${y_out[0].toFixed(2)}, dy: ${y_out[1].toFixed(2)}`);
}

async function test_price() {
    let x = 10;
    let y = 20;

    let C = x * y;
    let b = 2 * Math.sqrt(C);

    let x_val = 1;
    let y_src = await solve_O_AMM_from_X(x_val, b, C);
    let y_val = get_result('y', y_src);
    // console.log(y_val);
    
    await get_price(x_val, y_val, b, C);
}

async function test_s_o_amm() {
    let x = 10;
    let y = 20;

    let C = x * y;
    let b = 2 * Math.sqrt(C);

    await solve_O_AMM_from_X(x, b, C);
    await solve_O_AMM_from_Y(y, b, C);
}

// await solve();


// await test_s_o_amm();
// await test_price();
await test_swap();
