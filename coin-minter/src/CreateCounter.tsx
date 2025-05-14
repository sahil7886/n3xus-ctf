import { Transaction } from "@mysten/sui/transactions";
import { Button, Container, Text, Flex, Box, Heading } from "@radix-ui/themes";
import { useSignAndExecuteTransaction, useSuiClient, useCurrentAccount, useSuiClientQuery } from "@mysten/dapp-kit";
import { useNetworkVariable } from "./networkConfig";
import ClipLoader from "react-spinners/ClipLoader";
import { useState } from "react";

export function CreateCounter({
  onCreated,
}: {
  onCreated: (id: string) => void;
}) {
  const counterPackageId = useNetworkVariable("counterPackageId");
  const treasuryCapId = useNetworkVariable("treasuryCapId" as any);
  const account = useCurrentAccount();
  const suiClient = useSuiClient();
  const {
    mutate: signAndExecute,
    isSuccess,
    isPending: isMintPending,
  } = useSignAndExecuteTransaction();
  const [lastDigest, setDigest] = useState<string | null>(null);
  const [burnAmount, setBurnAmount] = useState("");
  const [isBurning, setIsBurning] = useState(false);
  const [burnError, setBurnError] = useState<string | null>(null);
  const [lastBurnDigest, setLastBurnDigest] = useState<string | null>(null);

  const coinType = counterPackageId ? `${counterPackageId}::my_coin::MY_COIN` : null;

  const { data: balanceData, isLoading: isBalanceLoading, error: balanceError, refetch: refetchBalance } = useSuiClientQuery(
    "getBalance",
    {
      owner: account?.address!,
      coinType: coinType!,
    },
    {
      enabled: !!account?.address && !!coinType,
    }
  );

  function mint() {
    const tx = new Transaction();

    tx.moveCall({
      arguments: [
        tx.sharedObjectRef({
          objectId: treasuryCapId,
          initialSharedVersion: "353295263",
          mutable: true,
        }),
        tx.pure.u64(1000000000),
        tx.pure.address(account?.address!),
      ],
      target: `${counterPackageId}::my_coin::mint`,
    });

    signAndExecute(
      {
        transaction: tx,
      },
      {
        onSuccess: async ({ digest }) => {
          setDigest(digest);
          await suiClient.waitForTransaction({
            digest: digest,
          });
          console.log("Minted 1000000000 coins");
          refetchBalance();
        },
        onError: (error) => {
          console.error("Minting failed", error);
        },
      },
    );
  }

  async function handleBurn() {
    if (!account?.address || !coinType || !treasuryCapId) {
      setBurnError("Account, coin type, or treasury cap ID not available.");
      return;
    }
    const amountToBurnNum = parseFloat(burnAmount);
    if (isNaN(amountToBurnNum) || amountToBurnNum <= 0) {
      setBurnError("Please enter a valid positive amount to burn.");
      return;
    }

    const amountToBurnSmallestUnit = BigInt(Math.floor(amountToBurnNum * Math.pow(10, 6)));

    setIsBurning(true);
    setBurnError(null);
    setLastBurnDigest(null);

    try {
      const { data: ownedCoins } = await suiClient.getCoins({
        owner: account.address,
        coinType: coinType,
      });

      if (!ownedCoins || ownedCoins.length === 0) {
        setBurnError("No SAL coins found in your wallet.");
        setIsBurning(false);
        return;
      }

      let sourceCoin = null;
      for (const coin of ownedCoins) {
        if (BigInt(coin.balance) >= amountToBurnSmallestUnit) {
          sourceCoin = coin;
          break;
        }
      }

      if (!sourceCoin) {
        setBurnError(`Insufficient balance. You need at least ${amountToBurnNum} SAL in a single coin object to burn this amount.`);
        setIsBurning(false);
        return;
      }

      const treasuryCapObject = await suiClient.getObject({
        id: treasuryCapId,
        options: { showOwner: true },
      });

      const ownerDetails = treasuryCapObject.data?.owner;
      if (!ownerDetails || typeof ownerDetails !== 'object' || !('Shared' in ownerDetails) || !ownerDetails.Shared?.initial_shared_version) {
        setBurnError("Could not fetch TreasuryCap details, it's not a shared object, or version is missing.");
        setIsBurning(false);
        return;
      }
      const treasuryCapVersion = ownerDetails.Shared.initial_shared_version;

      const tx = new Transaction();
      let coinToBurnArgument;

      if (BigInt(sourceCoin.balance) === amountToBurnSmallestUnit) {
        coinToBurnArgument = tx.object(sourceCoin.coinObjectId);
      } else {
        const [splitCoin] = tx.splitCoins(tx.object(sourceCoin.coinObjectId), [tx.pure.u64(amountToBurnSmallestUnit)]);
        coinToBurnArgument = splitCoin;
      }

      tx.moveCall({
        target: `${counterPackageId}::my_coin::burn`,
        arguments: [
          tx.sharedObjectRef({
            objectId: treasuryCapId,
            initialSharedVersion: treasuryCapVersion,
            mutable: true,
          }),
          coinToBurnArgument,
        ],
      });

      const result = await signAndExecute(
        {
          transaction: tx,
        },
        {
          onSuccess: async ({ digest }) => {
            setLastBurnDigest(digest);
            await suiClient.waitForTransaction({ digest });
            console.log(`${amountToBurnNum} SAL coins burned successfully!`);
            refetchBalance();
            setBurnAmount("");
          },
          onError: (err) => {
            console.error("Burn failed", err);
            setBurnError(err.message || "An unknown error occurred during burning.");
          },
        },
      );
    } catch (error: any) {
      console.error("Error in burn process:", error);
      setBurnError(error.message || "An unexpected error occurred.");
    } finally {
      setIsBurning(false);
    }
  }

  return (
    <Container>
      <Flex direction="column" gap="3">
        <Box>
          <Heading size="3" mb="2">Mint SAL Tokens</Heading>
          <Button
            size="3"
            onClick={() => {
              mint();
            }}
            disabled={!account || isMintPending}
          >
            {isMintPending ? <ClipLoader size={20} /> : "Mint 1,000 SAL"}
          </Button>
          {lastDigest && (
            <div style={{ fontSize: 12, marginTop: 8 }}>
              Tx digest:&nbsp;
              <a
                href={`https://suiexplorer.com/txblock/${lastDigest}?network=testnet`}
                target="_blank"
                rel="noreferrer"
              >
                {lastDigest.slice(0, 10)}…
              </a>
            </div>
          )}
        </Box>

        {account && coinType && (
          <Box mt="4" p="3">
            <Heading size="3" mb="2">Your SAL Balance</Heading>
            {isBalanceLoading && <Text>Loading balance...</Text>}
            {balanceError && <Text color="red">Error fetching balance: {balanceError.message}</Text>}
            {balanceData && !isBalanceLoading && !balanceError && (
              <Text size="5" weight="bold">
                {(parseInt(balanceData.totalBalance, 10) / Math.pow(10, 6)).toLocaleString()}{" "}
                SAL
              </Text>
            )}
            <Button size="1" variant="soft" ml="4" mt="1" onClick={() => refetchBalance()} disabled={isBalanceLoading}>
              Refresh Balance
            </Button>
          </Box>
        )}

        {account && coinType && (
          <Box mt="4" p="3">
            <Heading size="3" mb="2">Burn SAL Tokens</Heading>
            <Flex direction="column" gap="2" maxWidth="300px">
              <input
                type="number"
                value={burnAmount}
                onChange={(e) => setBurnAmount(e.target.value)}
                placeholder="Amount to burn"
                disabled={isBurning}
                style={{ padding: '8px', borderRadius: '4px', border: '1px solid var(--gray-a7)' }}
              />
              <Button
                onClick={handleBurn}
                disabled={isBurning || !burnAmount || isMintPending}
              >
                {isBurning ? <ClipLoader size={20} /> : "Burn SAL"}
              </Button>
            </Flex>
            {isBurning && <Text mt="2">Processing burn...</Text>}
            {burnError && <Text mt="2" color="red">Error: {burnError}</Text>}
            {lastBurnDigest && (
              <div style={{ fontSize: 12, marginTop: 8 }}>
                Burn Tx digest:&nbsp;
                <a
                  href={`https://suiexplorer.com/txblock/${lastBurnDigest}?network=testnet`}
                  target="_blank"
                  rel="noreferrer"
                >
                  {lastBurnDigest.slice(0, 10)}…
                </a>
              </div>
            )}
          </Box>
        )}
      </Flex>
    </Container>
  );
}
