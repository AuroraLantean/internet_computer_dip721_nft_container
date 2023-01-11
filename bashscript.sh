#!/bin/bash
# ./bashscript.sh p1

echo -e "Running run.sh ..."
echo -e "option: $1 $2";

if [[ $1 == "1" ]]; then
  echo -e "option" $1
  dfx deploy --no-wallet --argument \
  "(record {
      name = \"Gold\";
      symbol = \"GLD\";
      logo = opt record {
          data = \"$(base64 -i ./logo.png)\";
          logo_type = \"image/png\";
      };
      custodians = opt vec { principal \"$(dfx identity get-principal)\" };
  })"

elif [[ $1 == "1b" ]]; then
  echo -e "option" $1
  dfx deploy --no-wallet --argument \
  "(record {
      name = \"Gold\";
      symbol = \"GLD\";
      logo = null;
      custodians = opt vec { principal \"$(dfx identity get-principal)\" };
  })"

elif [[ $1 == "2" ]]; then
  echo -e "option" $1
  dfx canister id dip721_nft_container
  dfx canister call dip721_nft_container nameDip721 '()'
  dfx canister call dip721_nft_container symbolDip721 '()'
  dfx canister call dip721_nft_container totalSupplyDip721 '()'
  #dfx canister call dip721_nft_container logoDip721 '()'

elif [[ $1 == "3" ]]; then
  echo -e "option" $1
  dfx identity new alice --disable-encryption || true
  dfx identity new bob --disable-encryption || true
  YOU=$(dfx identity get-principal)
  sleep 2s
  echo $YOU
  ALICE=$(dfx --identity alice identity get-principal)
  BOB=$(dfx --identity bob identity get-principal)
  echo '(*) Creating NFT with metadata "nft_name:kingkong":'
  dfx canister call dip721_nft_container mintDip721 \
      "(principal\"$YOU\",\"nft_name:kingkong\")"
  echo '(*) Metadata of the newly created NFT:'
  dfx canister call dip721_nft_container getMetadataDip721 '(0:nat64)'

elif [[ $1 == "3b" ]]; then
  echo -e "option" $1
  dfx identity new alice --disable-encryption || true
  dfx identity new bob --disable-encryption || true
  YOU=$(dfx identity get-principal)
  sleep 2s
  echo $YOU
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
  dfx canister call dip721_nft_container getMetadataDip721 '(0:nat64)'

elif [[ $1 == "99" ]]; then
  echo -e "option" $1
  YOU=$(dfx identity get-principal)
  ALICE=$(dfx --identity alice identity get-principal)
  BOB=$(dfx --identity bob identity get-principal)

  echo '(*) Number of NFTs you own:'
  dfx canister call dip721_nft_container balanceOfDip721 "(principal\"$YOU\")"
  echo '(*) Number of NFTs Alice owns:'
  dfx canister call dip721_nft_container balanceOfDip721 "(principal\"$ALICE\")"
  echo '(*) Number of NFTs Bob owns:'
  dfx canister call dip721_nft_container balanceOfDip721 "(principal\"$BOB\")"

elif [[ $1 == "4" ]]; then
  echo -e "option" $1
  YOU=$(dfx identity get-principal)
  ALICE=$(dfx --identity alice identity get-principal)
  BOB=$(dfx --identity bob identity get-principal)

  dfx canister call dip721_nft_container getMetadataDip721 '(0:nat64)'
  sleep 2s
  echo "(*) Owner of NFT 0 (you are $YOU):"
  dfx canister call dip721_nft_container ownerOfDip721 '(0:nat64)'
  sleep 2s
  echo '(*) Number of NFTs you own:'
  dfx canister call dip721_nft_container balanceOfDip721 "(principal\"$YOU\")"
  sleep 2s
  echo '(*) Number of NFTs Alice owns:'
  dfx canister call dip721_nft_container balanceOfDip721 "(principal\"$ALICE\")"
  sleep 2s
  echo '(*) Total NFTs in existence:'
  dfx canister call dip721_nft_container totalSupplyDip721

elif [[ $1 == "5" ]]; then
  echo -e "option" $1
  YOU=$(dfx identity get-principal)
  ALICE=$(dfx --identity alice identity get-principal)
  BOB=$(dfx --identity bob identity get-principal)

  echo '(*) Transferring the NFT from you to Alice:'
  dfx canister call dip721_nft_container transferFromDip721 "(principal\"$YOU\",principal\"$ALICE\",0:nat64)"
  echo "(*) Owner of NFT 0 (Alice is $ALICE):"
  dfx canister call dip721_nft_container ownerOfDip721 '(0:nat64)'
  echo '(*) Number of NFTs you own:'
  dfx canister call dip721_nft_container balanceOfDip721 "(principal\"$YOU\")"
  echo '(*) Number of NFTs Alice owns:'
  dfx canister call dip721_nft_container balanceOfDip721 "(principal\"$ALICE\")"

elif [[ $1 == "6" ]]; then
  echo -e "option" $1
  YOU=$(dfx identity get-principal)
  ALICE=$(dfx --identity alice identity get-principal)
  BOB=$(dfx --identity bob identity get-principal)

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


else 
  echo -e "not matched command"
fi
# /tmp/repoPath/alice/chains/local_testnet/db/full    
