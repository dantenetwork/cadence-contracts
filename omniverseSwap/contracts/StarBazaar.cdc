import StarToken from "./StarToken.cdc";
import FungibleToken from "../../omniverseNFT/contracts/utility/FungibleToken.cdc";

pub contract StarBazaar {
    /////////////////////////////////////////////////////////////////////
    /// StarDust
    pub resource StarDust {
        // `liquidity` can be used for get `Δx` and `Δy` when depositing to or withdrawing from the pool
        pub var liquidity: @StarToken.Vault?;
        pub let poolType: String;

        init(liquidity: @StarToken.Vault, poolType: String) {
            self.liquidity <- liquidity;
            self.poolType = poolType;
        }

        destroy () {
            destroy self.liquidity;
        }

        priv fun extractLiquidity(): @StarToken.Vault {
            let liquidity: @StarToken.Vault? <- self.liquidity <- nil;
            return <- liquidity!;
        }

        pub fun deposite(dust: @StarDust) {
            if self.poolType == dust.poolType {
                // It's OK as the type of dust is `@StarDust`
                // let liquidity2: @StarToken.Vault? <- dust.liquidity <- nil;
                // destroy liquidity2;

                let liquidity <- dust.extractLiquidity();
                let myLQref: &StarToken.Vault = (&self.liquidity as &StarToken.Vault?)!;
                myLQref.deposit(from: <- liquidity);
                destroy  dust;
            } else {
                panic("`poolType` not match!");
            }
        }

        pub fun withdraw(amount: UFix64): @StarDust {
            let myLQref: &StarToken.Vault = (&self.liquidity as &StarToken.Vault?)!;
            let starToken <- myLQref.withdraw(amount: amount);
            let dust <- create StarDust(liquidity: <- starToken, poolType: self.poolType);
            return <- dust;
        }

        pub fun getStarTokenAmount(): UFix64 {
            let myLQref: &StarToken.Vault = (&self.liquidity as &StarToken.Vault?)!;
            return myLQref.balance;
        }
    }

    /////////////////////////////////////////////////////////////////////
    /// PoolVault
    pub resource PoolVault {
        pub var tokenX: @FungibleToken.Vault?;
        pub var tokenY: @FungibleToken.Vault?;
        pub let poolType: String;

        init(tokenX: @FungibleToken.Vault, tokenY: @FungibleToken.Vault, poolType: String) {
            self.tokenX <- tokenX;
            self.tokenY <- tokenY;
            self.poolType = poolType;
        }

        pub fun extractTokenX(): @FungibleToken.Vault {
            let liquidity: @FungibleToken.Vault? <- self.tokenX <- nil;
            return <- liquidity!;
        }

        pub fun extractTokenY(): @FungibleToken.Vault {
            let liquidity: @FungibleToken.Vault? <- self.tokenY <- nil;
            return <- liquidity!;
        }

        pub fun getXAmount(): UFix64 {
            let XRef = (&self.tokenX as &FungibleToken.Vault?)!;
            return XRef.balance;
        }

        pub fun getYAmount(): UFix64 {
            let YRef = (&self.tokenY as &FungibleToken.Vault?)!;
            return YRef.balance;
        }

        destroy () {
            destroy self.tokenX;
            destroy self.tokenY;
        }
    }

    pub struct DLiquidity {
        pub let dX: UFix64;
        pub let dY: UFix64;
        pub let positive: Bool;

        init(dX: UFix64, dY: UFix64, positive: Bool) {
            self.dX = dX;
            self.dY = dY;
            self.positive = positive;
        }
    }

    /////////////////////////////////////////////////////////////////////
    /// DEXPool
    pub resource DEXPool {
        pub let poolType: String;
        pub var tokenX: @FungibleToken.Vault?;
        pub var tokenY: @FungibleToken.Vault?;
        
        priv var price: UFix64;
        priv var liquidity: UFix64;

        init(poolType: String) {
            self.poolType = poolType;

            self.tokenX <- nil;
            self.tokenY <- nil;

            self.price = 0.0;
            self.liquidity = 0.0;
        }

        destroy () {
            destroy self.tokenX;
            destroy self.tokenY;
        }
        
        pub fun depositLiquidity(pool: @PoolVault): @StarDust?{
            if (pool.getXAmount() == 0.0) || (pool.getYAmount() == 0.0) {
                panic("Empty input `pool`.");
            }

            var d_lq: UFix64 = 0.0;
            
            if self.liquidity > 0.0 {
                let XRef = (&self.tokenX as &FungibleToken.Vault?)!;
                let YRef = (&self.tokenY as &FungibleToken.Vault?)!;
                if let dl = StarBazaar.liquidityValidation(dX: pool.getXAmount(), dY: pool.getYAmount(), positive: true, tokenX: XRef.balance, tokenY: YRef.balance) {
                    XRef.deposit(from: <- pool.extractTokenX());
                    YRef.deposit(from: <- pool.extractTokenY());
                    self._recalc();

                    d_lq = dl;
                } else {
                    panic("Invalid input `pool`.");
                }
            } else {
                d_lq = pool.getXAmount() * pool.getYAmount();

                self.tokenX <-! pool.extractTokenX();
                self.tokenY <-! pool.extractTokenY();
                self._recalc();
            }

            destroy  pool;
            return <- StarBazaar.createStarDust(amount: d_lq, poolType: self.poolType);
        }

        pub fun withdrawLiquidity(starDust: @StarDust): @PoolVault? {
            if self.liquidity > starDust.getStarTokenAmount() {
                let XRef = (&self.tokenX as &FungibleToken.Vault?)!;
                let YRef = (&self.tokenY as &FungibleToken.Vault?)!;

                let dl = StarBazaar.dXdY_l(x: XRef.balance, y: YRef.balance, dL2: starDust.getStarTokenAmount(), positive: false);
                let dx <- XRef.withdraw(amount: dl.dX);
                let dy <- YRef.withdraw(amount: dl.dY);

                destroy  starDust;
                return <- create PoolVault(tokenX: <- dx, tokenY: <- dy, poolType: self.poolType);
            } else {    
                panic("Not enough liquidity!");
            }
            
            panic("Why here?????");
            // return nil;
        }

        pub fun swap(in_token: @FungibleToken.Vault): @FungibleToken.Vault? {
            if self.isReady() {
                let XRef = (&self.tokenX as &FungibleToken.Vault?)!;
                let YRef = (&self.tokenY as &FungibleToken.Vault?)!;

                if in_token.isInstance(XRef.getType()) {
                    let out_amount = YRef.balance * in_token.balance / (XRef.balance + in_token.balance);
                    XRef.deposit(from: <- in_token);
                    return <- YRef.withdraw(amount: out_amount);

                } else if in_token.isInstance(YRef.getType()) {
                    let out_amount = XRef.balance * in_token.balance / (YRef.balance + in_token.balance);
                    YRef.deposit(from: <- in_token);
                    return <- XRef.withdraw(amount: out_amount);
                } else {
                    panic("Invalid input token type!");
                }
            }

            panic("Empty liquidity!");
        }

        pub fun isReady(): Bool {
            return self.liquidity > 0.0;
        }

        // pub fun liquidityValidation(dX: UFix64, dY: UFix64): Bool {
        //     let XRef = (&self.tokenX as &FungibleToken.Vault?)!;
        //     let YRef = (&self.tokenY as &FungibleToken.Vault?)!;

        //     let newPrice = (YRef.balance + dY) / (XRef.balance + dX);
        //     return ((self.price - 0.001) <= newPrice) && (newPrice <= (self.price + 0.001));
        // }

        priv fun _recalc() {
            let XRef = (&self.tokenX as &FungibleToken.Vault?)!;
            let YRef = (&self.tokenY as &FungibleToken.Vault?)!;

            self.price =  YRef.balance / XRef.balance;
            self.liquidity = YRef.balance * XRef.balance;
        }
    }

    access(contract) fun createStarDust(amount: UFix64, poolType: String): @StarDust {
        let liquidity <- StarToken.mintVault(amount: amount);
        let dust <- create StarDust(liquidity: <- liquidity, poolType: poolType);
        return <- dust;
    }

    pub fun createDEXPool(poolType: String): @DEXPool {
        return <- create DEXPool(poolType: poolType);
    }

    // based on `Taylor's formula`
    pub fun sqrt2(d: UFix64): UFix64 {
        var y = d;
        if (y >= 4.0) {
            var z = y;
            var x = y / 2.0;
            while (x < z) {
                z = x;
                // The same as `x = x + (y - x * x) / (2 * x);`
                x = (y / x + x) / 2.0;
            }

            return z;
        } else if (y != 0.0) {
            return self.sqrt3(d: y);
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

    pub fun dXdY_l(x: UFix64, y: UFix64, dL2: UFix64, positive: Bool): DLiquidity {
        let L2 = x * y;
        let y_x = y / x;
        let x_y = x / y;
        
        if positive {
            let newL = L2 + dL2;
            let y_add_dy = self.sqrt2(d: y_x * newL);
            let x_add_dx = self.sqrt2(d: x_y * newL);
            return DLiquidity(dX: x_add_dx - x, dY: y_add_dy - y, positive: positive);
        } else {
            let newL = L2 - dL2;
            let y_sub_dy = self.sqrt2(d: y_x * newL);
            let x_sub_dx = self.sqrt2(d: x_y * newL);
            return DLiquidity(dX: x - x_sub_dx, dY: y - y_sub_dy, positive:positive);
        }
    }

    // `positive` 
    pub fun liquidityValidation(dX: UFix64, dY: UFix64, positive: Bool, tokenX: UFix64, tokenY: UFix64): UFix64? {
        var newX: UFix64 = 0.0;
        var newY: UFix64 = 0.0;
        if positive {
            newX = tokenX + dX;
            newY = tokenY + dY;
        } else {
            newX = tokenX - dX;
            newY = tokenY - dY;
        }

        let price = tokenY / tokenX;
        let newPrice = newY / newX;
        if ((price - 0.001) <= newPrice) && (newPrice <= (price + 0.001)) {
            if positive {
                return newX * newY - tokenX * tokenY;
            } else {
                return tokenX * tokenY - newX * newY;
            }
        } else {
            return nil;
        }
    }

    /////////////////////////////////////////////////////////////////////
    /// StarBazaar


    /////////////////////////////////////////////////////////////////////
    // Test functions
    pub fun testStarDust(dust: @StarDust) {
        // The below is invalid as `StarDust::liquidity` is just `pub var` but not `pub(set) var`
        // let liquidity2: @StarToken.Vault? <- dust.liquidity <- nil;
        // destroy liquidity2;
        destroy  dust;
    }

    pub fun testFunction() {

    }
} 
 