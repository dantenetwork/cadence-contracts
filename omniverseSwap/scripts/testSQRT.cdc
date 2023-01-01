
// pub fun sqrt(d: UFix64): UFix64 {
//     let before: UInt256 = 1000000;
//     let after: UFix64 = 1000.0;

//     var y: UInt256 = UInt256(d) * before;
//     if (y > 3) {
//         var z = y;
//         var x = y / 2 + 1;
//         while (x < z) {
//             z = x;
//             x = (y / x + x) / 2;
//         }

//         return UFix64(z) / after;
//     } else if (y != 0) {
//         return 1.0 / 100.0;
//     } else {
//         return 0.0;
//     }
// }

// based on `Taylor's formula`
pub fun sqrt2(d: UFix64): UFix64 {
    var y = d;
    if (y > 4.0) {
        var z = y;
        var x = y / 2.0;
        while (x < z) {
            z = x;
            // The same as `x = x + (y - x * x) / (2 * x);`
            x = (y / x + x) / 2.0;
        }

        return z;
    } else if (y != 0.0) {
        return sqrt3(d: y);
    } else {
        return 0.0;
    }
}

// based on `Taylor's formula`
pub fun sqrt3(d: UFix64): UFix64 {
    if (d >= 4.0) || (d == 0.0) {
        panic("sqrt3 only available for `0.0 < d < 4.0`");
    }
    var x = d / 2.0;
    var differ = Fix64(x * x) - Fix64(d);
    var precision: Fix64 = 0.0001;
    while (differ < -precision) || (differ > precision) {
        // x = x + (d - x * x) / (2.0 * x);
        x = (d / x + x) / 2.0;
        differ = Fix64(x * x) - Fix64(d);
    }

    return x;
}

pub fun main(): UFix64 {
    let x: Fix64 = 12345.12;
    let y: Fix64 = 98765.34;

    let price = y / x;
    let L = x * y;

    let dl:Fix64 = 100.0;

    log(Fix64.max);

    log(price);

    // let sqrt_price = sqrt(d: UFix64(price));
    // let sqrt_dl = sqrt(d: UFix64(L + dl));

    // log(sqrt_price * sqrt_dl);
    // log(sqrt_dl);

    // let dy: Fix64 = Fix64(sqrt_price * sqrt_dl) - y;
    // let dx: Fix64 = Fix64(1.0 / sqrt_price * sqrt_dl) - x;

    // log(dx);
    // log(dy);

    // return sqrt_price * sqrt_dl;

    let y_add_dy = sqrt2(d: UFix64(price * (L + dl)));
    let x_add_dx = sqrt2(d: UFix64(Fix64(1.0) / price * (L + dl)));

    log(y_add_dy - UFix64(y));
    log(x_add_dx - UFix64(x));

    log(sqrt2(d: 0.0));

    return (y_add_dy / x_add_dx);
}
 