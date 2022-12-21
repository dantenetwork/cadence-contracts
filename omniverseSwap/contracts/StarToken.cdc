import FungibleToken from "../../omniverseNFT/contracts/utility/FungibleToken.cdc";

pub contract StarToken: FungibleToken {
    pub var totalSupply: UFix64;

    pub event TokensInitialized(initialSupply: UFix64);
    pub event TokensWithdrawn(amount: UFix64, from: Address?);
    pub event TokensDeposited(amount: UFix64, to: Address?);

    /// Vault
    ///
    /// The resource that contains the functions to send and receive tokens.
    ///
    pub resource Vault: FungibleToken.Provider, FungibleToken.Receiver, FungibleToken.Balance {
        pub var balance: UFix64;

        init(balance: UFix64) {
            self.balance = balance;
        }

        /// withdraw subtracts `amount` from the Vault's balance
        /// and returns a new Vault with the subtracted balance
        ///
        pub fun withdraw(amount: UFix64): @Vault {
            self.balance = self.balance - amount;
            
            let outVault <- create Vault(balance: amount);
            return <-outVault;
        }

        /// deposit takes a Vault and adds its balance to the balance of this Vault
        ///
        pub fun deposit(from: @FungibleToken.Vault) {
            self.balance = self.balance + from.balance;
            destroy from;
        }
    }

    init() {
        self.totalSupply = 0.0;
    }

    pub fun createEmptyVault(): @Vault {
        return <- create Vault(balance: 0.0);
    }

    access(account) fun mintVault(amount: UFix64): @Vault {
        return <- create Vault(balance: amount);
    }
}
