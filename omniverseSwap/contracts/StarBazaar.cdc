import StarToken from "./StarToken.cdc"

pub contract StarBazaar {
    pub resource StarDust {
        pub let liquidity: @StarToken.Vault;
        pub let poolType: UInt32;

        
    }
} 