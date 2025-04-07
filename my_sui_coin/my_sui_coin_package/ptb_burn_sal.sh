#!/usr/bin/env bash

# --- REPLACE THESE VALUES ---
PACKAGE_ID="0x68f1e948ee8805ec89aeacc296b559caec9baf9ba4ac186380c68a25ba6f3f1a"
TREASURY_CAP_ID="0x94d43f39f547c2e42ae69f798600ceacf0823775fc5a4cd1ae1bd021510d2068"
# !!! IMPORTANT !!!
# Replace this with the Object ID of the specific Coin<...> object you want to burn.
# You must get this ID *after* minting, using `sui client objects`.
COIN_TO_BURN_ID="0xSPECIFIC_COIN_OBJECT_ID_TO_BURN"
# --- END REPLACE VALUES ---

echo "Building PTB to burn coin object ${COIN_TO_BURN_ID}..."

sui client ptb \
  --move-call "${PACKAGE_ID}::my_coin::burn" \
      ${TREASURY_CAP_ID} \
      ${COIN_TO_BURN_ID} \

echo "PTB execution submitted."
