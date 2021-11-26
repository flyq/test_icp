import Hash "mo:base/Hash";
import Array "mo:base/Array";
import Principal "mo:base/Principal";
import Char "mo:base/Char";
import Blob "mo:base/Blob";
import Nat8 "mo:base/Nat8";
import SHA224 "./SHA224";
import CRC32 "./CRC32";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import Nat32 "mo:base/Nat32";
import Iter "mo:base/Iter";
import Text "mo:base/Text";

module {
    private let symbols = [
        '0', '1', '2', '3', '4', '5', '6', '7',
        '8', '9', 'a', 'b', 'c', 'd', 'e', 'f',
    ];
    private let base : Nat8 = 0x10;

    /// Account Identitier type.   
    public type AccountIdentifier = {
        hash: [Nat8];
    };

    /// Convert bytes array to hex string.       
    /// E.g `[255,255]` to "ffff"
    public func encode(array : [Nat8]) : Text {
        Array.foldLeft<Nat8, Text>(array, "", func (accum, u8) {
            accum # nat8ToText(u8);
        });
    };

    /// Convert a byte to hex string.
    /// E.g `255` to "ff"
    func nat8ToText(u8: Nat8) : Text {
        let c1 = symbols[Nat8.toNat((u8/base))];
        let c2 = symbols[Nat8.toNat((u8%base))];
        return Char.toText(c1) # Char.toText(c2);
    };

    /// Return the [motoko-base's Hash.Hash](https://github.com/dfinity/motoko-base/blob/master/src/Hash.mo#L9) of `AccountIdentifier`.  
    /// To be used in HashMap.
    public func hash(a: AccountIdentifier) : Hash.Hash {
        var array : [Hash.Hash] = [];
        var temp : Hash.Hash = 0;
        for (i in a.hash.vals()) {
            temp := Hash.hash(Nat8.toNat(i));
            array := Array.append<Hash.Hash>(array, Array.make<Hash.Hash>(temp));
        };

        return Hash.hashNat8(array);
    };

    /// Test if two account identifier are equal.
    public func equal(a: AccountIdentifier, b: AccountIdentifier) : Bool {
        Array.equal<Nat8>(a.hash, b.hash, Nat8.equal)
    };

    /// Return the account identifier of the Principal.
    public func principalToAccount(p : Principal) : AccountIdentifier {
        let digest = SHA224.Digest();
        digest.write([10, 97, 99, 99, 111, 117, 110, 116, 45, 105, 100]:[Nat8]); // b"\x0Aaccount-id"
        let blob = Principal.toBlob(p);
        digest.write(Blob.toArray(blob));
        digest.write(Array.freeze<Nat8>(Array.init<Nat8>(32, 0 : Nat8))); // sub account
        let hash_bytes = digest.sum();

        return {hash=hash_bytes;}: AccountIdentifier;
    };

    /// Return the Text of the account identifier.
    public func accountToText(p : AccountIdentifier) : Text {
        let crc = CRC32.crc32(p.hash);
        let aid_bytes = Array.append<Nat8>(crc, p.hash);

        return encode(aid_bytes);
    };
};