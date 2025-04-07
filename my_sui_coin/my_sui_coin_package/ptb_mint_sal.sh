#!/usr/bin/env bash

# --- REPLACE THESE VALUES ---
PACKAGE_ID="0x68f1e948ee8805ec89aeacc296b559caec9baf9ba4ac186380c68a25ba6f3f1a"
TREASURY_CAP_ID="0x94d43f39f547c2e42ae69f798600ceacf0823775fc5a4cd1ae1bd021510d2068"
# Address to receive the minted coins
RECIPIENT_ADDRESS="0x58a5963cf005ebbcf7209b20a94d67869a50ab1fc779ac96a4e0f6714a9bd34d"
# Amount to mint (100 SAL, considering 6 decimals)
MINT_AMOUNT=1000
# --- END REPLACE VALUES ---

echo "Building PTB to mint ${MINT_AMOUNT} SAL to ${RECIPIENT_ADDRESS}..."

sui client ptb \
  --move-call "${PACKAGE_ID}::my_coin::mint" \
      ${TREASURY_CAP_ID} \
      ${MINT_AMOUNT} \
      ${RECIPIENT_ADDRESS} \

echo "PTB execution submitted."
