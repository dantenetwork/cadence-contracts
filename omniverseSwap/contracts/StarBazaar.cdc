import StarToken from "./StarToken.cdc";
import FungibleToken from "../../omniverseNFT/contracts/utility/FungibleToken.cdc";

pub contract StarBazaar {
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

        pub fun extractLiquidity(): @StarToken.Vault {
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
    }

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
        
        
        pub fun depositLiquidity(pool: @PoolVault): @PoolVault?{
            if (pool.getXAmount() == 0.0) || (pool.getYAmount() == 0.0) {
                return <- pool;
            }
            
            if self.liquidity > 0.0 {
                let XRef = (&self.tokenX as &FungibleToken.Vault?)!;
                let YRef = (&self.tokenY as &FungibleToken.Vault?)!;
                if StarBazaar.liquidityValidation(dX: pool.getXAmount(), dY: pool.getYAmount(), positive: true, tokenX: XRef.balance, tokenY: YRef.balance) {
                    XRef.deposit(from: <- pool.extractTokenX());
                    YRef.deposit(from: <- pool.extractTokenY());
                    self._recalc();
                } else {
                    return <- pool;
                }
            } else {
                self.tokenX <-! pool.extractTokenX();
                self.tokenY <-! pool.extractTokenY();
                self._recalc();
            }

            destroy  pool;
            return nil;
        }

        pub fun withdrawLiquidity(liquidity: Fix64): @PoolVault? {
            return nil;
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
    pub fun liquidityValidation(dX: UFix64, dY: UFix64, positive: Bool, tokenX: UFix64, tokenY: UFix64): Bool {
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
        return ((price - 0.001) <= newPrice) && (newPrice <= (price + 0.001));
    }

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
 