import Utils "./Utils";
import Principal "mo:base/Principal";

shared(msg) actor class TICP() = this {
    type ICPTs = {
        e8s: Nat64;
    };

    type TimeStamp = {
        timestamp_nanos: Nat64;
    };

    type SendArgs = {
        memo: Nat64;
        amount: ICPTs;
        fee: ICPTs;
        from_subaccount: ?[Nat8];
        to: Text;
        created_at_time: ?TimeStamp;
    };

    type LedgerActor = actor {
        send_dfx : (args: SendArgs) -> async Nat64;
    };

    private stable let ICPFEE : Nat64 = 10000; // 0.0001 ICP
    private stable let owner : Principal = msg.caller;
    
    public shared(msg) func send(amount: Nat64, to: Text) : async Bool {
        assert(msg.caller == owner);
        let ledger : LedgerActor = actor("ryjl3-tyaaa-aaaaa-aaaba-cai");

        let icpts : ICPTs = {
            e8s = amount;
        };
        let fee : ICPTs = {
            e8s = ICPFEE;
        };
        let args : SendArgs = {
            memo = 1:Nat64;
            amount = icpts;
            fee = fee;
            from_subaccount = null;
            to = to;
            created_at_time = null;
        };

        ignore await ledger.send_dfx(args);
        return true;
    };

    public query func getOwner() : async Principal {
        owner
    };

    public query func accountIdentifier(p: Principal) : async Text {
        p2a(p)
    };

    public query func getSelf() : async Text {
        p2a(Principal.fromActor(this))
    };

    func p2a(p: Principal) : Text {
        Utils.accountToText(Utils.principalToAccount(p))
    };
};
