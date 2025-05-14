module my_sui_coin_package::my_coin;

use std::option;
use sui::coin::{Self, Coin, TreasuryCap};
use sui::transfer;
use sui::tx_context::{Self, TxContext};

public struct MY_COIN has drop {}

fun init(witness: MY_COIN, ctx: &mut TxContext) {
		let (treasury, metadata) = coin::create_currency(
				witness,
				6,
				b"SAL",
				b"",
				b"",
				option::none(),
				ctx,
		);
		transfer::public_freeze_object(metadata);
		transfer::public_share_object(treasury);
}

public entry fun mint(
		treasury_cap: &mut TreasuryCap<MY_COIN>,
		amount: u64,
		recipient: address,
		ctx: &mut TxContext,
) {
		let coin = coin::mint(treasury_cap, amount, ctx);
		transfer::public_transfer(coin, recipient)
}

/// Public entry function to burn (destroy) coins.
/// Requires the TreasuryCap object and the Coin object to burn.
public entry fun burn(
    treasury_cap: &mut TreasuryCap<MY_COIN>,
    coin_to_burn: Coin<MY_COIN>
) {
    coin::burn(treasury_cap, coin_to_burn);
}