#!/bin/bash
# ./bashscript.sh p1

echo -e "Running run.sh ..."
echo -e "option: $1 $2";

if [[ $1 == "once" ]]; then
  echo -e "option" $1
  dfx identity new admin --force --disable-encryption || true
  dfx identity use admin
  dfx identity get-principal

  dfx identity new alice --disable-encryption || true
  dfx identity use alice
  dfx identity get-principal

  dfx identity new bob --disable-encryption || true
  dfx identity use bob
  dfx identity get-principal

  npm install

elif [[ $1 == "0" ]]; then
  echo -e "option" $1
  echo 'cargo check'
  cargo check
  # dfx ping local ||
  dfx start --background --clean
  #sleep 2s
  #echo 'dfx canister create --all'
  #dfx canister create --all
  #dfx canister create dip721_nft_container
  #dfx canister create hello
  #dfx canister create hello_frontend
  dfx identity use admin
  echo 'admin principal'
  dfx identity get-principal

elif [[ $1 == "1" ]]; then
  echo -e "option" $1
  echo 'to deploy hello'
  dfx deploy hello --no-wallet --argument \
  "(record {
      name = \"Hello Canister Name\";
      price = 174;
      custodians = opt vec { principal \"$(dfx identity get-principal)\" };
  })"
  echo 'hello has been deployed'
  dfx canister id hello
  hello_id=$(dfx canister id hello)
  echo 'hello_id:' $hello_id
  echo ''
  echo 'generate hello declaration files'
  dfx generate hello

elif [[ $1 == "2" ]]; then
  echo -e "option" $1
  echo 'to deploy dip721_nft_container'
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
  echo 'dip721_nft_container has been deployed'
  dfx canister id dip721_nft_container
  dip721_nft_container_id=$(dfx canister id dip721_nft_container)
  echo 'dip721_nft_container_id:' $dip721_nft_container_id
  echo ''
  echo 'generate dip721_nft_container declaration files'
  dfx generate dip721_nft_container

elif [[ $1 == "2a" ]]; then
  echo -e "option" $1
  echo 'to re-deploy dip721_nft_container'
  dfx canister install dip721_nft_container --mode reinstall --argument \
  "(record {
      name = \"Gold\";
      symbol = \"GLD\";
      logo = opt record {
          data = \"$(base64 -i ./logo.png)\";
          logo_type = \"image/png\";
      };
      custodians = opt vec { principal \"$(dfx identity get-principal)\" };
  })"
  echo 'dip721_nft_container has been deployed'
  dfx canister id dip721_nft_container
  dip721_nft_container_id=$(dfx canister id dip721_nft_container)
  echo 'dip721_nft_container_id:' $dip721_nft_container_id
  echo ''
  echo 'generate dip721_nft_container declaration files'
  dfx generate dip721_nft_container


elif [[ $1 == "2no_logo" ]]; then
  echo -e "option" $1
  dfx deploy dip721_nft_container --no-wallet --argument \
  "(record {
      name = \"Gold\";
      symbol = \"GLD\";
      logo = null;
      custodians = opt vec { principal \"$(dfx identity get-principal)\" };
  })"

elif [[ $1 == "3" ]]; then
  echo -e "option" $1
  echo 'to deploy hello_frontend'
  dfx deploy hello_frontend
  #--no-wallet
  echo 'hello_frontend has been deployed'

  dfx canister id hello_frontend
  hello_frontend_id=$(dfx canister id hello_frontend)
  echo 'hello_frontend_id:' $hello_frontend_id
  echo ''
  #echo 'generate hello_frontend declaration files'
  #dfx generate hello_frontend
  dfx canister id dip721_nft_container
  dip721_nft_container_id=$(dfx canister id dip721_nft_container)
  echo 'dip721_nft_container_id:' $dip721_nft_container_id
  echo "http://127.0.0.1:4943/?canisterId=${hello_frontend_id}&id=${dip721_nft_container_id}"

elif [[ $1 == "4" ]]; then
  echo -e "option" $1
  dfx canister id dip721_nft_container
  dip721_id=$(dfx canister id dip721_nft_container)
  echo 'dip721_id:' $dip721_id
  dfx canister call dip721_nft_container nameDip721 '()'
  dfx canister call dip721_nft_container symbolDip721 '()'
  echo 'totalSupply:'
  dfx canister call dip721_nft_container totalSupplyDip721 '()'
  #dfx canister call dip721_nft_container logoDip721 '()'
  dfx canister id hello
  hello_id=$(dfx canister id hello)
  echo 'hello_id:' $hello_id
  dfx canister call hello greet 'JohnDoe'
  echo 'call hello get_name()'
  dfx canister call hello get_name '()'
  echo 'call hello get_price()'
  dfx canister call hello get_price '()'

  echo 'call hello set_name()'
  dfx canister call hello set_name 'Silver'
  echo 'call hello get_name()'
  dfx canister call hello get_name '()'

  echo 'call hello set_price()'
  dfx canister call hello set_price '(185:nat64)'
  echo 'call hello get_price()'
  dfx canister call hello get_price '()'

elif [[ $1 == "5" ]]; then
  echo -e "option" $1
  echo 'call get_price from dip721 to hello'
  hello_id=$(dfx canister id hello)
  dfx canister call dip721_nft_container get_price "(principal\"$hello_id\")"

elif [[ $1 == "6" ]]; then
  echo -e "option" $1
  dfx identity use admin
  YOU=$(dfx identity get-principal)
  echo $YOU
  echo '(*) Creating NFT with metadata "nft_name:King-Kong":'
  dfx canister call dip721_nft_container mintDip721 \
      "(principal\"$YOU\",\"nft_name:King-Kong\")"
  echo '(*) Number of NFTs you own:'
  dfx canister call dip721_nft_container balanceOfDip721 "(principal\"$YOU\")"
  echo '(*) Metadata of the newly created NFT:'
  dfx canister call dip721_nft_container get_metadata_v2 '(0:nat64)'

elif [[ $1 == "6b" ]]; then
  echo -e "option" $1
  dfx identity use admin
  YOU=$(dfx identity get-principal)
  echo $YOU
  echo '(*) Number of NFTs you own:'
  dfx canister call dip721_nft_container balanceOfDip721 "(principal\"$YOU\")"
  echo 'Set Metadata of NFT id: 0'
  dfx canister call dip721_nft_container set_metadata "(0:nat64,\"nft_name:Godzilla\")"
  echo 'Metadata of the NFT id: 0'
  dfx canister call dip721_nft_container get_metadata_v2 '(0:nat64)'

elif [[ $1 == "6a" ]]; then
  echo -e "option" $1
  YOU=$(dfx identity get-principal)
  echo 'current identity:' $YOU
  dfx identity use john
  echo 'john principal:'
  dfx identity get-principal
  YOU=$(dfx identity get-principal)

  echo '(*) Creating NFT with metadata "nft_name:Kiwi":'
  dfx canister call dip721_nft_container mintDip721forall \
      "(principal\"$YOU\",\"nft_name:Kiwi\")"
  echo '(*) Number of NFTs you own:'
  dfx canister call dip721_nft_container balanceOfDip721 "(principal\"$YOU\")"
  echo '(*) Metadata of the newly created NFT:'
  dfx canister call dip721_nft_container get_metadata_v2 '(1:nat64)'

elif [[ $1 == "6zz" ]]; then
  echo -e "option" $1
  YOU=$(dfx identity get-principal)
  ALICE=$(dfx --identity alice identity get-principal)
  BOB=$(dfx --identity bob identity get-principal)
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

elif [[ $1 == "7" ]]; then
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

elif [[ $1 == "8" ]]; then
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

elif [[ $1 == "8a" ]]; then
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
