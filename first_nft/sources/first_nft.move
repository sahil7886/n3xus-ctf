module first_nft::first_nft;

use std::string::{Self, String};
use sui::object::{UID, ID, new, delete, id};
use sui::event;
use sui::url::{Self, Url, new_unsafe_from_bytes};
use sui::transfer::{public_transfer, share_object};
use sui::tx_context::{TxContext, sender};
use sui::coin::{Self, Coin, value};
use sui::balance::{Self, Balance}; // Keep Balance if needed elsewhere, maybe not for this change
use sui::package; // Import for Publisher in init if used, maybe not needed if just storing address

// Use the Testnet USDC type. VERIFY THIS ADDRESS IS CORRECT FOR YOUR NETWORK (Testnet/Devnet/Mainnet)
// Testnet: 0xc060006111016b8a020ad5b33834984a437aaa7d3c74c18e09a95d48aceab08c::usdc::USDC
use usdc::usdc::USDC;

// === REMOVED Type Alias ===
// type UsdcCoin = Coin<USDC>;

// === Constants ===

/// Maximum number of NFTs that can be minted
const MAX_SUPPLY: u64 = 5000;
/// Mint price in smallest USDC denomination (1 USDC = 1,000,000)
const USDC_MINT_PRICE: u64 = 1_000_000;

// === Error Codes ===

/// When the supply cap is reached
const EMaxSupplyReached: u64 = 1;
/// When the payment amount is incorrect
const EIncorrectPaymentAmount: u64 = 2;

// === Structs ===

/// The NFT itself (renamed from TestnetNFT)
public struct MyNft has key, store {
		id: UID,
		/// Name for the token
		name: String,
		/// Description of the token
		description: String,
		/// URL for the token
		url: Url,
		// TODO: allow custom attributes
        creator: String
}

/// Shared object to track the supply and hold publisher address
public struct NftSupply has key {
		id: UID,
		/// Number of NFTs minted so far
		count: u64,
		/// Address that published the contract, receives payments
		publisher: address
}

// ===== Events =====

/// Event emitted when an NFT is minted
public struct NFTMinted has copy, drop {
		// The Object ID of the NFT
		object_id: ID,
		/// Address of the account that initiated the mint transaction
		minter: address,
		// The name of the NFT
		name: String,
}

// ===== Module Initializer =====

/// Initialize the package, create and share the NftSupply object
fun init(ctx: &mut TxContext) {
		let supply = NftSupply {
				id: new(ctx),
				count: 0,
				publisher: sender(ctx), // Store the address of the publisher
		};
		// Share the object so anyone can access it (mutably) in transactions
		share_object(supply);
		
		// Optional: Claim and transfer Publisher cap if needed for other functionalities
		// let publisher_cap = package::claim(witness, ctx);
		// transfer::public_transfer(publisher_cap, sender(ctx));
}

// ===== Public View Functions =====

/// Get the NFT's `name`
public fun name(nft: &MyNft): &String {
		&nft.name
}

/// Get the NFT's `description`
public fun description(nft: &MyNft): &String {
		&nft.description
}

/// Get the NFT's `url`
public fun url(nft: &MyNft): &Url {
		&nft.url
}

/// Get the NFT's `creator`
public fun creator(nft: &MyNft): &String {
        &nft.creator
}

/// Get the current mint count
public fun supply(supply: &NftSupply): u64 {
    supply.count
}

/// Get the max supply
public fun max_supply(_: &NftSupply): u64 {
    MAX_SUPPLY
}

// ===== Entrypoints =====

/// Mint a new MyNft, requires 1 USDC payment and access to the shared NftSupply
public entry fun mint(
		name: vector<u8>,
		description: vector<u8>,
		url: vector<u8>,
        creator: vector<u8>,
		payment: Coin<USDC>,
		supply: &mut NftSupply,
		ctx: &mut TxContext,
) {
		let tx_sender = sender(ctx);

		// Verify payment amount
		assert!(coin::value(&payment) == USDC_MINT_PRICE, EIncorrectPaymentAmount);
		// Verify supply has not reached max
		assert!(supply.count < MAX_SUPPLY, EMaxSupplyReached);

		// Increment supply counter
		supply.count = supply.count + 1;

		// Take the payment
		transfer::public_transfer(payment, supply.publisher);

		// Create the NFT
		let nft = MyNft {
				id: new(ctx),
				name: string::utf8(name),
				description: string::utf8(description),
				url: url::new_unsafe_from_bytes(url),
                creator: string::utf8(creator)
		};

		// Emit mint event
		event::emit(NFTMinted {
				object_id: object::id(&nft),
				minter: tx_sender, // Event minter is the transaction sender
				name: nft.name,
		});

		// Send the NFT to the transaction sender
		public_transfer(nft, tx_sender);
}

/// Transfer `nft` to `recipient`
public entry fun transfer(nft: MyNft, recipient: address, _: &mut TxContext) {
		public_transfer(nft, recipient)
}

/// Update the `description` of `nft` (only owner can call)
public entry fun update_description(
		nft: &mut MyNft,
		new_description: vector<u8>,
		_: &mut TxContext,
) {
		nft.description = string::utf8(new_description)
}

/// Permanently delete `nft` (only owner can call)
public entry fun burn(nft: MyNft, _: &mut TxContext) {
		let MyNft { id, name: _, description: _, url: _, creator: _ } = nft;
		delete(id) // Use object::delete for UID
}