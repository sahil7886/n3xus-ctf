#!/bin/bash

# --- Define your NFT details and IDs ---
PACKAGE_ID="0xcdbe50600a1522286e063540e56548077a3be7077aa5cccc86123247f7013bc5"
SUPPLY_OBJECT_ID="0xcf691a6c851479d8a610f6be6f485f835f02c6ce749662616d1676f086a5b83d"
# !!! REPLACE THIS WITH YOUR ACTUAL COIN ID HOLDING EXACTLY 1 USDC !!!
YOUR_EXACT_1_USDC_COIN_ID="<YOUR_EXACT_1_USDC_COIN_ID>"
NFT_NAME="t0m"
NFT_DESCRIPTION="Just Tom."
NFT_IMAGE_URL="https://amethyst-naval-peacock-516.mypinata.cloud/ipfs/bafkreigo6hjahh2xtfmfhc4jsbyrz7txiprviigjozobdvlrvp6s4mhb2m"
NFT_CREATOR="Sal"

# --- Construct and Execute the PTB ---
sui client ptb --json - <<EOF
{
    "version": 1,
    "inputs": [
      { "type": "object", "objectId": "$PACKAGE_ID" },
      { "type": "pure", "value": "$NFT_NAME" },
      { "type": "pure", "value": "$NFT_DESCRIPTION" },
      { "type": "pure", "value": "$NFT_IMAGE_URL" },
      { "type": "pure", "value": "$NFT_CREATOR" },
      { "type": "object", "objectId": "$YOUR_EXACT_1_USDC_COIN_ID" },
      { "type": "object", "objectId": "$SUPPLY_OBJECT_ID" }
    ],
    "transactions": [
      {
        "kind": "MoveCall",
        "command": {
          "package": { "Input": 0 },
          "module": "first_nft",
          "function": "mint",
          "type_arguments": [],
          "arguments": [
            { "Input": 1 },
            { "Input": 2 },
            { "Input": 3 },
            { "Input": 4 },
            { "Input": 5 },
            { "Input": 6 }
          ]
        }
      }
    ]
}
EOF \
--gas-budget 80000000 # Adjust gas budget if needed (might be slightly lower without split)
