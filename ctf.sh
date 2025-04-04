#!/usr/bin/env bash

# ctf.sh

# Vault shared object: 0x666d8afc1f7b440ec2b2e8521f26bac53b8bc380bcb8aab30e9fe5815c89cc96
# Vault's required code: 2476

sui client ptb \
  --move-call 0x684c26d5fedd570bbb3196e31f6053e7af904fdae3be9097976c13649a6e2a46::key::new \
  --assign key \
  --move-call 0x684c26d5fedd570bbb3196e31f6053e7af904fdae3be9097976c13649a6e2a46::key::set_code key 2476 \
  --move-call 0x684c26d5fedd570bbb3196e31f6053e7af904fdae3be9097976c13649a6e2a46::vault::withdraw \
      @0x666d8afc1f7b440ec2b2e8521f26bac53b8bc380bcb8aab30e9fe5815c89cc96 key \
  --assign flag \
  --transfer-objects "[flag]" @0x58a5963cf005ebbcf7209b20a94d67869a50ab1fc779ac96a4e0f6714a9bd34d