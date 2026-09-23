import "@stdlib/deploy";

contract NktPresale with Deployable {
    owner: Address;
    nktWallet: Address; 
    pricePerToken: Int; 
    totalSold: Int;
    maxPresaleCap: Int; 
    isSaleActive: Bool;

    init(owner: Address, nktWallet: Address, pricePerToken: Int, maxPresaleCap: Int) {
        self.owner = owner;
        self.nktWallet = nktWallet;
        self.pricePerToken = pricePerToken;
        self.totalSold = 0;
        self.maxPresaleCap = maxPresaleCap;
        self.isSaleActive = true;
    }

    // Ricezione di TON liberi per l'acquisto (senza body stringa rigido)
    receive() {
        let ctx: Context = context();
        require(self.isSaleActive, "Presale is closed");
        
        let tonAmount: Int = ctx.value;
        require(tonAmount > 0, "Send TON to buy tokens");
        
        let tokensToBuy: Int = (tonAmount * 1000000000) / self.pricePerToken;
        require(self.totalSold + tokensToBuy <= self.maxPresaleCap, "Exceeds presale cap");

        self.totalSold = self.totalSold + tokensToBuy;
    }

    // Funzione amministrativa per aprire/chiudere la prevendita
    receive("toggle_sale") {
        require(sender() == self.owner, "Only owner");
        self.isSaleActive = !self.isSaleActive;
    }

    // Prelievo dei TON raccolti
    receive("withdraw_ton") {
        require(sender() == self.owner, "Only owner");
        let balance: Int = myBalance();
        rawReserve(100000000, 0); 
        send(SendParameters{
            to: self.owner,
            value: 0,
            mode: SendRemainingBalance + SendIgnoreErrors,
            body: "Presale revenue withdrawal".asComment()
        });
    }
}


