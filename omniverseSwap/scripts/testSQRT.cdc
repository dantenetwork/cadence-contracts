
pub fun sqrt(d: UFix64): UFix64 {
    let before: UInt256 = 1000000000000;
    let after: UFix64 = 1000000.0;

    var y: UInt256 = UInt256(d) * before;
    if (y > 3) {
        var z = y;
        var x = y / 2 + 1;
        while (x < z) {
            z = x;
            x = (y / x + x) / 2;
        }

        return UFix64(z) / after;
    } else if (y != 0) {
        return 1.0 / 100.0;
    } else {
        return 0.0;
    }
}

pub fun main(): UFix64 {
    let x: Fix64 = 123.12;
    let y: Fix64 = 987.34;

    let price = y / x;
    let L = x * y;

    let dl:Fix64 = 20000.0;

    let sqrt_price = sqrt(d: UFix64(price));
    let sqrt_dl = sqrt(d: UFix64(L + dl));

    log(sqrt_price * sqrt_dl);
    log(sqrt_dl);

    let dy: Fix64 = Fix64(sqrt_price * sqrt_dl) - y;
    let dx: Fix64 = Fix64(1.0 / sqrt_price * sqrt_dl) - x;

    log(dx);
    log(dy);

    return sqrt_price * sqrt_dl;
}