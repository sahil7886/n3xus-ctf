# My Sui Dev Journal

## Challenge 0
1. The download process was quick and was pretty straightforward. 
2. Pretty much just had to add the Move extension to my IDE
3. Was a bit confusing. Didn't understand what the keypair scheme flag is. I ran `sui client` first and it asked me whether I wanted to connect to a full node server, which I wasn't sure about. 
4. I used the website. It was annoying that it rate-limited me after just 1 dispense. I waited a bit and got another token.
5. The `sui move new` command worked perfect. Understanding the structure of the package and how it worked was a bit confusing since I'm new to Move/Rust.
6. I had an 'insufficient gas' issue when using the gas budget argument. However, when I tried running just `sui client publish`, it worked perfectly.

### Summary
The setup was fairly easy, considering it was my first time using Move. Had a few minor issues but overall, pretty smooth.

### Deliverables
- Transaction Digest: GUqUusfEBe8hszF9i6VP9dQgBAMnDekaq8MqMcPQ4fkk

## Challenge 1
1. Reading and understanding the repo was fairly easy. I used Suiscan to find the vault code and object id.
2. Implementing this was difficult. I repeatedly got the 'UnusedValueWithoutDrop' error and faced a lot of bugs. In the end though, when I finally got it, it was very satisfying!
3. Ran into a lot of typescript/node/ESM module not found and compatibility issues with '@mysten/sui.js'. It was also a bit tricky to fetch my keypair from my address to sign and execute the transaction.

### Summary
Logic and execution was fairly easy to figure out but syntax, finding which functions and which libraries to use and debugging took a while. 

### Deliverables
- cli flag: 0xf31b8049b977afe0c59b44092f149e4f164637b7379ab498235a129ab63236db
- ts sdk flag: 0x889cdbd0469689e459b3c08c5123cf5f456fa0eab7415ab8e404bf07de1afafd


## Challenge 2
1. Creating the token was pretty easy. Made a new package, used the code from the docs and published the package. 
2. Adding the mint function was straightforward. Docs had clear instructions.
3. This was easy too. Just added another function. The cli call to burn was very similar to the one to mint as well.
4. Wasn't sure exactly what I had to do, but a little bit of browsing around and figured that you just had to put the cli call in a bash script, which was pretty easy.

### Summary
Fairly straightforward.

### Deliverables
- coins sent: BEyyFTooAHA1392YUougXrUfMNxzx28DkopJH4w6qfmL
- github repo: https://github.com/sahil7886/n3xus-ctf
- transaction digest of minting coins: EWksNQyiQenMYrP1KynkbjJvLRZCdBTp5YCejnvrm9DH
- transaction digest of burning coins: 9zckDAniXDm2UX3XHRVZKQA82yo3ctpViVhbWm8eVfk1

## Challenge 3
1. Walrus wasn't working so I used Pinata instead and got a url to the image.
2. Code for this was a bit difficult to figure out but the documentation helped a lot!
3. This was fairly straightforward. 
4. Adding a counter logic and logic to limit minting at max supply was also a bit tricky.
5. Was a bit complicated but worked after a bit of browsing the web.

### Summary
Creating the NFT was very easy. Did face a few bugs but sorted them out fairly quickly.

### Deliverables
- Minted the t0m nft to that address.
- github repo: https://github.com/sahil7886/n3xus-ctf
- Transaction digest of minting NFT: 3sorwU5xjh6dSMTZVEiCFkm6H8TykvzJcQmFARSdHYnf

## Challenge 4
1. Very simple setup. Pretty much just 1 command.
2. Very simple again. Just copied the flow from Challenge 0. (Package ID: 0xe52ebbcb8c17c487b74a72e814c8cb62189f9d40e286171cc1582d2e55a3f61a)
3. copy-paste; very easy
4. Used bun. Very easy.
5. Got the website started easily but was having issues testing it. Turns out I was using a wallet that doesn't support the Sui Testnet (Phantom). Switched to Slush and it was seamless.
6. Simple.

### Summary
Overall, one of the most straightforward challenges. Barely faced any friction.

### Deliverables
- github repo: https://github.com/sahil7886/n3xus-ctf
- https://n3xus-ctf.vercel.app/

## Challenge 5
1. Simple. 1 command.
2. Pretty tricky. Had to change the smart contract, republish it. Changing the UI to mint tokens instead of creating a counter was a bit tricky. Had an issue with the contract not recognising the treasury cap because I put in the full address (0x2::coin::TreasuryCap<0xb2d4593dd2c4e2a47a085d750c84a2a4f7a5e90b0fe7b7ae079aadecd5ee557b::my_coin::MY_COIN>) instead of just the relevant part (0xb2d4593dd2c4e2a47a085d750c84a2a4f7a5e90b0fe7b7ae079aadecd5ee557b).
3. Fairly straighforward. Involved adding another button to fetch the balance and a hook to call the sui client function.
4. The mechanism to burn a specific amount of tokenswas a bit tricky to figure out since the burn function in the move contract burns an entire coin object. I had to first check the address if they hold that amount in a single coin object and then split and burn that amount. 
5. Simple.

### Summary
Overall, one of the most straightforward challenges. Barely faced any friction.

### Deliverables
- github repo: https://github.com/sahil7886/n3xus-ctf
- https://sal-dashboard.vercel.app/