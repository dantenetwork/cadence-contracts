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
                if self.liquidityValidation(dX: pool.getXAmount(), dY: pool.getYAmount()) {
                    let XRef = (&self.tokenX as &FungibleToken.Vault?)!;
                    let YRef = (&self.tokenY as &FungibleToken.Vault?)!;
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

        pub fun liquidityValidation(dX: UFix64, dY: UFix64): Bool {
            let XRef = (&self.tokenX as &FungibleToken.Vault?)!;
            let YRef = (&self.tokenY as &FungibleToken.Vault?)!;

            let newPrice = (YRef.balance + dY) / (XRef.balance + dX);
            return ((self.price - 0.001) <= newPrice) && (newPrice <= (self.price + 0.001));
        }

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

    // pub fun dXdY_l(x: Fix64, y: Fix64, l: Fix64): DLiquidity {
    //     let dx = 
    // }

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
 