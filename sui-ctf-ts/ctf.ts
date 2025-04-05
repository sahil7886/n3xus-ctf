import { getFullnodeUrl, SuiClient } from '@mysten/sui/client';
import { Transaction } from '@mysten/sui/transactions';
import { Ed25519Keypair } from '@mysten/sui/keypairs/ed25519';
import { decodeSuiPrivateKey } from '@mysten/sui/cryptography';

async function main() {
  // --- Step 1: Connect to the Sui Network ---
  const suiClient = new SuiClient({ url: getFullnodeUrl('testnet') });
  const MY_ADDRESS = '0x58a5963cf005ebbcf7209b20a94d67869a50ab1fc779ac96a4e0f6714a9bd34d';

  // --- Step 2: Initialize Your Signer ---
  const bech32key = '';
  const secretKey = decodeSuiPrivateKey(bech32key).secretKey
  const keypair = Ed25519Keypair.fromSecretKey(secretKey);
  const derivedAddress = keypair.getPublicKey().toSuiAddress();
  console.log('Derived Address:', derivedAddress);
  console.log('Expected Address:', MY_ADDRESS);

  // --- Step 3: Build the Transaction Block ---
  const tx = new Transaction();

  // 3a. Create a new Key object by calling key::new.
  const key = tx.moveCall({
    target: '0x684c26d5fedd570bbb3196e31f6053e7af904fdae3be9097976c13649a6e2a46::key::new',
    arguments: [],
  });

  // 3b. Set the Key's code to 2476.
  // Note: key::set_code returns nothing, so we don’t assign its output.
  tx.moveCall({
    target: '0x684c26d5fedd570bbb3196e31f6053e7af904fdae3be9097976c13649a6e2a46::key::set_code',
    arguments: [key, tx.pure.u64(2476)],
  });

  // 3c. Withdraw from the vault using the updated Key.
  // Use tx.sharedObject to mark the vault as a shared object.
  const flag = tx.moveCall({
    target: '0x684c26d5fedd570bbb3196e31f6053e7af904fdae3be9097976c13649a6e2a46::vault::withdraw',
    arguments: [
      tx.object('0x666d8afc1f7b440ec2b2e8521f26bac53b8bc380bcb8aab30e9fe5815c89cc96'),
      key,
    ],
  });

  // 3d. Transfer the newly created Flag to your address.
  tx.transferObjects([flag], MY_ADDRESS);

  // --- Step 4: Sign and Execute the Transaction ---
  try {
    const result = await suiClient.signAndExecuteTransaction({
      signer: keypair,
      transaction: tx,
      requestType: 'WaitForLocalExecution',
      options: {
        showEffects: true,
      },
    });
    console.log('Transaction executed successfully:', result);
  } catch (error) {
    console.error('Transaction execution failed:', error);
  }
}

main().catch((error) => {
  console.error('Error in main execution:', error);
});