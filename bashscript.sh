#!/bin/bash
# ./bashscript.sh p1

echo -e "Running run.sh ..."
echo -e "option: $1 $2";

if [[ $1 == "1" ]]; then
  echo -e "option 1"
  dfx deploy --no-wallet --argument \
  "(record {
      name = \"Gold\";
      symbol = \"GLD\";
      logo = null;
      custodians = opt vec { principal \"$(dfx identity get-principal)\" };
  })"

elif [[ $1 == "2" ]]; then
  echo -e "option 2"
  dfx canister id dip721_nft_container
  dfx canister call dip721_nft_container nameDip721 '()'
  dfx canister call dip721_nft_container symbolDip721 '()'
  dfx canister call dip721_nft_container totalSupplyDip721 '()'
  #dfx canister call dip721_nft_container logoDip721 '()'

elif [[ $1 == "3" ]]; then
  echo -e "option 3"
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

elif [[ $1 == "4" ]]; then
  echo -e "option 4"
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

else 
  echo -e "not matched command"
fi
# /tmp/repoPath/alice/chains/local_testnet/db/full    
