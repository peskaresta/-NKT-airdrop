import "@stdlib/deploy";

// Struttura del messaggio definita PRIMA del contratto e con la keyword "message"
message ClaimMessage {
    user: Address;
    tokenAmount: Int;
    signature: Slice;
    hash: Int;
}

contract NktAirdropClaim with Deployable {
    owner: Address;
    signerPublicKey: Int; 
    nktWallet: Address;   
    totalDistributed: Int;
    maxAirdropCap: Int;   
    isClaimActive: Bool;

    claimedUsers: map<Address, Bool>;

    init(owner: Address, signerPublicKey: Int, nktWallet: Address, maxAirdropCap: Int) {
        self.owner = owner;
        self.signerPublicKey = signerPublicKey;
        self.nktWallet = nktWallet;
        self.totalDistributed = 0;
        self.maxAirdropCap = maxAirdropCap;
        self.isClaimActive = true;
    }

    receive(msg: ClaimMessage) {
        require(self.isClaimActive, "Airdrop claim is finished");
        
        // Controllo corretto per la mappa in Tact
        let alreadyClaimed: Bool? = self.claimedUsers.get(msg.user);
        require(alreadyClaimed == null, "User already claimed");

        require(self.totalDistributed + msg.tokenAmount <= self.maxAirdropCap, "Airdrop pool is fully exhausted");

        self.totalDistributed = self.totalDistributed + msg.tokenAmount;
        self.claimedUsers.set(msg.user, true);
    }

    receive("stop_claim") {
        require(sender() == self.owner, "Only owner");
        self.isClaimActive = false;
    }
}
