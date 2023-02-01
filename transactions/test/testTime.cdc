
transaction {

    prepare(acct: AuthAccount) {
        
    }

    execute {
        log("Current time: ".concat(getCurrentBlock().timestamp.toString()));
        log("Current time: ".concat(getCurrentBlock().timestamp.toString()));
        log("Current block: ".concat(getCurrentBlock().height.toString()));
    }
}
