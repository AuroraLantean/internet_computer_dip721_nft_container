# DIP721 NFT Container

## Summary

- npm run once: run this once for setting up admin, john, alice, bob identities. john is acting as a hacker. alice and bob are acting as users.
- npm run d0: check Rust code, start dfx environment, use admin identity
- npm run d1: deploy hello canister
- npm run d2: deploy dip721_nft_container canister
- npm run d3: call some simple hello and dip721 canister functions
- npm run d4: call dip721 canister function, which will call hello get_price function for inter-canister calls
- npm run d5: use admin identity to mint
- npm run d5a: use john identity to mint

- npm run d9 : call a NodeJs script to invoke minting
  ... although this will return error message, but when you call this again, it will show both NFT totalSupply and your NFT balance have increased by 1...

Conclusion1: dfinity does not have good or updated support for Rust code, so it cannot auto generate DID files, which are required to generate JavaScript interface files for NodeJs script. That is causing minting from NodeJs difficult.

Conclusion2: I could not use the seed phrases generated from dfx command tool to generate the same identity in the JavaScript. Not sure what is going on... So security tests cannot be performed as the JavaScript library cannot use the same identity that CLI has generated.

## Setup / Installation

- Git
- [DFX] version 0.12.1
- [Rust] version 1.66.0 or later
- [NodeJs] version 19.4.0

## Running Locally

Run the following commands to download and set up the project:

```sh
git clone git@github.com:AuroraLantean/internet_computer_nft.git dip721-nft-container
cd dip721-nft-container
dfx help
dfx canister --help
```

## Update the project Cargo.toml

Add the new canister into the Cargo.toml at the project root

```
[workspace]
members = [
    "src/dip721_nft_container",
    "src/hello",
]
```

## Update dfx.json

Include all the canisters you want to deploy in the dfx.json file. Remember to add canister `rust` type if it is written in Rust, and add `node_compatibility` if you want to call it from NodeJs.

```
      "type": "rust",
      "declarations": {
        "node_compatibility": true
      }
```

## Check Rust canister code

```sh
cargo check
```

## Start the dfinity network:

```sh
dfx start --background --clean
```

## Generate canisters

Then create canisters. That is to creates the .dfx/local directory and adds the canister_ids.json file to that directory.

```sh
dfx canister create --all
```

Or if you just want to create one canister:
`dfx canister create dip721_nft_container`

### Deploy Hello canister

```sh
  dfx deploy hello --no-wallet --argument \
  "(record {
      name = \"Hello Canister Name\";
      price = 174;
      custodians = opt vec { principal \"$(dfx identity get-principal)\" };
  })"
```

### Deploy dip721_nft_container canister

```sh
  dfx deploy dip721_nft_container --no-wallet --argument \
  "(record {
      name = \"Gold\";
      symbol = \"GLD\";
      logo = opt record {
          data = \"$(base64 -i ./logo.png)\";
          logo_type = \"image/png\";
      };
      custodians = opt vec { principal \"$(dfx identity get-principal)\" };
  })"

```

The canister expects a record parameter with the following fields:

- `custodians`: A list of users allowed to manage the canister. If unset, it will default to the caller. If you're using `dfx`, and haven't specified `--no-wallet`, that's your wallet principal, not your own, so be careful!
- `name`: The name of your NFT collection. Required.
- `symbol`: A short slug identifying your NFT collection. Required.
- `logo`: The logo of your NFT collection, represented as a record with fields `data` (the base-64 encoded logo) and `logo_type` (the MIME type of the logo file). If unset, it will default to the Internet Computer logo.

Remove `"type": "module",` in package.json

to deploy without logo:

```sh
dfx deploy --no-wallet --argument \
"(record {
    name = \"Gold\";
    symbol = \"GLD\";
    logo = null;
    custodians = opt vec { principal \"$(dfx identity get-principal)\" };
})"
```

## Make declaration files

if you change any canister function input and/or output, OR add/delete any canister function, OR add new canister, you must update the dip721-nft-container.did file and/or other canister did files manually.

To generate the declaration files.

```
dfx generate dip721_nft_container
dfx generate hello
dfx generate hello_frontend
```

### To Test the canister via Bash

```sh
dfx canister id dip721_nft_container
```

Confirm the result is the same as the one at .dft/local/canister_ids.json

```sh
Function names are inside the query macros
dfx canister call dip721_nft_container nameDip721 '()'
dfx canister call dip721_nft_container symbolDip721 '()'
dfx canister call dip721_nft_container totalSupplyDip721 '()'
dfx canister call dip721_nft_container logoDip721 '()'

dfx canister call dip721_nft_container set_name '("Silver")'
dfx canister call dip721_nft_container set_symbol '("SLV")'
```

```rust
enum MetadataPurpose {
    Preview,
    Rendered,
}
struct MetadataPart {
    purpose: MetadataPurpose,
    key_val_data: HashMap<String, MetadataVal>,
    data: Vec<u8>,
}
type MetadataDesc = Vec<MetadataPart>;
fn mint(
    to: Principal,
    metadata: MetadataDesc,
    blob_content: Vec<u8>,
    ){}
```

How to make argument in shell:

```sh
dfx identity new alice --disable-encryption || true
dfx identity new bob --disable-encryption || true
YOU=$(dfx identity get-principal)
ALICE=$(dfx --identity alice identity get-principal)
BOB=$(dfx --identity bob identity get-principal)
echo '(*) Creating NFT with metadata "hello":'
dfx canister call dip721_nft_container mintDip721 \
    "(principal\"$YOU\",vec{record{
        purpose=variant{Rendered};
        data=blob\"hello\";
        key_val_data=vec{
            record{
                \"contentType\";
                variant{TextContent=\"text/plain\"};
            };
            record{
                \"locationType\";
                variant{Nat8Content=4:nat8}
            };
        }
    }},blob\"hello\")"
echo '(*) Metadata of the newly created NFT:'
```

```sh
dfx canister call dip721_nft_container getMetadataDip721 '(0:nat64)'
echo "(*) Owner of NFT 0 (you are $YOU):"
dfx canister call dip721_nft_container ownerOfDip721 '(0:nat64)'
echo '(*) Number of NFTs you own:'
dfx canister call dip721_nft_container balanceOfDip721 "(principal\"$YOU\")"
echo '(*) Number of NFTs Alice owns:'
dfx canister call dip721_nft_container balanceOfDip721 "(principal\"$ALICE\")"
echo '(*) Total NFTs in existence:'
dfx canister call dip721_nft_container totalSupplyDip721
echo '(*) Transferring the NFT from you to Alice:'
dfx canister call dip721_nft_container transferFromDip721 "(principal\"$YOU\",principal\"$ALICE\",0:nat64)"
echo "(*) Owner of NFT 0 (Alice is $ALICE):"
dfx canister call dip721_nft_container ownerOfDip721 '(0:nat64)'
echo '(*) Number of NFTs you own:'
dfx canister call dip721_nft_container balanceOfDip721 "(principal\"$YOU\")"
echo '(*) Number of NFTs Alice owns:'
dfx canister call dip721_nft_container balanceOfDip721 "(principal\"$ALICE\")"
echo '(*) Alice approves Bob to transfer NFT 0 for her:'
dfx --identity alice canister call dip721_nft_container approveDip721 "(principal\"$BOB\",0:nat64)"
echo '(*) Bob transfers NFT 0 to himself:'
dfx --identity bob canister call dip721_nft_container transferFromDip721 "(principal\"$ALICE\",principal\"$BOB\",0:nat64)"
echo "(*) Owner of NFT 0 (Bob is $BOB):"
dfx canister call dip721_nft_container ownerOfDip721 '(0:nat64)'
echo '(*) Bob approves Alice to operate on any of his NFTs:'
dfx --identity bob canister call dip721_nft_container setApprovalForAllDip721 "(principal\"$ALICE\",true)"
echo '(*) Alice transfers 0 to herself:'
dfx --identity alice canister call dip721_nft_container transferFromDip721 "(principal\"$BOB\",principal\"$ALICE\",0:nat64)"
echo '(*) You are a custodian, so you can transfer the NFT back to yourself without approval:'
dfx canister call dip721_nft_container transferFromDip721 "(principal\"$ALICE\",principal\"$YOU\",0:nat64)"


//dfx canister call dip721_nft_container safeTransferFromDip721 '("$(dfx identity get-principal)",principle "zzz-aaa...",1)'

//dfx canister call dip721_nft_container set_logo '("xyz...")'
//dfx canister call dip721_nft_container set_custodian '("xyz...")'
//dfx canister call dip721_nft_container is_custodian '("xyz...")'

dfx identity list
dfx identity use xyz
dfx identity get-principal


```

### To test the canister via NodeJs

Add `"type": "module",` in package.json
Run in bash: `node --es-module-specifier-resolution=node src/node/index.js`

## Interface

Aside from the standard functions, it has five extra functions:

- `set_name`, `set_symbol`, `set_logo`, and `set_custodian`: Update the collection information of the corresponding field from when it was initialized.
- `is_custodian`: Checks whether the specified user is a custodian.

The canister also supports a certified HTTP interface; going to `/<nft>/<id>` will return `nft`'s metadata file #`id`, with `/<nft>` returning the first non-preview file.

Remember that query functions are uncertified; the result of functions like `ownerOfDip721` can be modified arbitrarily by a single malicious node. If queried information is depended on, for example if someone might send ICP to the owner of a particular NFT to buy it from them, those calls should be performed as update calls instead. You can force an update call by passing the `--update` flag to `dfx` or using the `Agent::update` function in `agent-rs`.

## Minting

Due to size limitations on the length of a terminal command, an image- or video-based NFT would be impossible to send via `dfx`. To that end, there is an experimental [minting tool][mint] you can use to mint a single-file NFT. As an example, to mint the default logo, you would run the following command:

```sh
minting-tool local "$(dfx canister id dip721_nft_container)" --owner "$(dfx identity get-principal)" --file ./logo.png --sha2-auto
```

Minting is restricted to anyone authorized with the `custodians` parameter or the `set_custodians` function. Since the contents of `--file` are stored on-chain, it's important to prevent arbitrary users from minting tokens, or they will be able to store arbitrarily-sized data in the contract and exhaust the canister's cycles. Be careful not to upload too much data to the canister yourself, or the contract will no longer be able to be upgraded afterwards.

## End

```sh
dfx stop
```

## Demo

This example comes with a demo script, `demo.sh`, which runs through an example workflow with minting and trading an NFT between a few users. Meant primarily to be read rather than run, you can use it to see how basic NFT operations are done. For a more in-depth explanation, read the [standard][dip721].

[dfx]: https://smartcontracts.org/docs/developers-guide/install-upgrade-remove.html
[rust]: https://rustup.rs
[dip721]: https://github.com/Psychedelic/DIP721
[mint]: https://github.com/dfinity/experimental-minting-tool

## Security Considerations and Security Best Practices

If you base your application on this example, we recommend you familiarize yourself with and adhere to the [Security Best Practices](https://internetcomputer.org/docs/current/references/security/) for developing on the Internet Computer. This example may not implement all the best practices.

For example, the following aspects are particularly relevant for this app:

- [Inter-Canister Calls and Rollbacks](https://internetcomputer.org/docs/current/references/security/rust-canister-development-security-best-practices/#inter-canister-calls-and-rollbacks), since issues around inter-canister calls can e.g. lead to time-of-check time-of-use or double spending security bugs.
- [Certify query responses if they are relevant for security](https://internetcomputer.org/docs/current/references/security/general-security-best-practices#certify-query-responses-if-they-are-relevant-for-security), since this is essential when e.g. displaying important NFT data in the frontend that may be used by users to decide on future transactions.
- [Use a decentralized governance system like SNS to make a canister have a decentralized controller](https://internetcomputer.org/docs/current/references/security/rust-canister-development-security-best-practices#use-a-decentralized-governance-system-like-sns-to-make-a-canister-have-a-decentralized-controller), since decentralizing control is a fundamental aspect when dealing with NFTs.
