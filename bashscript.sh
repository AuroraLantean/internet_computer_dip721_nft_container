#!/bin/bash
# ./bashscript.sh p1
echo -e "Running bashscript.sh ..."
echo -e "options: $1 $2";

cd /mnt/sda3/internet_computer/dip721-nft-container
pwd
if [[ $1 == "once" ]]; then
  echo 'once'
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

elif [[ $1 == "test" ]]; then
  echo 'test: bashscript test'

elif [[ $1 == "dfxstop" ]]; then
  echo 'dfxstop: dfx stop'
  dfx stop

elif [[ $1 == "startDfx" ]]; then
  echo 'startDfx: cargo check then start dfx'
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

elif [[ $1 == "deployHello" ]]; then
  echo '1: to deploy hello'
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

elif [[ $1 == "deployDip721" ]]; then
  echo '2: to deploy dip721_nft_container'
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

elif [[ $1 == "deployDip721a" ]]; then
  echo '2a to re-deploy dip721_nft_container'
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


elif [[ $1 == "deployDip721no_logo" ]]; then
  echo '2no_logo'
  dfx deploy dip721_nft_container --no-wallet --argument \
  "(record {
      name = \"Gold\";
      symbol = \"GLD\";
      logo = null;
      custodians = opt vec { principal \"$(dfx identity get-principal)\" };
  })"
  echo 'generate dip721_nft_container declaration files'
  dfx generate dip721_nft_container

elif [[ $1 == "deployHelloFrontend" ]]; then
  echo '3: to deploy hello_frontend'
  dfx deploy hello_frontend
  #--no-wallet
  echo 'hello_frontend has been deployed'
  echo ''
  echo 'generate hello_frontend declaration files'
  dfx generate hello_frontend

  dfx canister id hello_frontend
  hello_frontend_id=$(dfx canister id hello_frontend)
  echo 'hello_frontend_id:' $hello_frontend_id
  echo ''
  dfx canister id dip721_nft_container
  dip721_nft_container_id=$(dfx canister id dip721_nft_container)
  echo 'dip721_nft_container_id:' $dip721_nft_container_id
  echo "http://127.0.0.1:4943/?canisterId=${hello_frontend_id}&id=${dip721_nft_container_id}"
  xdg-open "http://127.0.0.1:4943/?canisterId=${hello_frontend_id}&id=${dip721_nft_container_id}"
  echo 'F12 or Ctrl + Shift + I to open the console'

elif [[ $1 == "callSimpleFunctions" ]]; then
  echo '4: call some simple hello and dip721 canister functions'
  dfx canister id dip721_nft_container
  dip721_id=$(dfx canister id dip721_nft_container)
  echo 'dip721_id:' $dip721_id
  dfx canister call dip721_nft_container nameDip721 '()'
  dfx canister call dip721_nft_container symbolDip721 '()'
  echo 'totalSupply:'
  dfx canister call dip721_nft_container totalSupplyDip721 '()'
  echo 'last nft metadata:'
  dfx canister call dip721_nft_container get_metadata_last "()"
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

elif [[ $1 == "callInterCanister" ]]; then
  echo '5: get_price from dip721 to hello'
  hello_id=$(dfx canister id hello)
  dfx canister call dip721_nft_container get_price "(principal\"$hello_id\")"

elif [[ $1 == "mintNFT" ]]; then
  echo -e "option" $1 'metadata:'$2 'nft_to:' $3
  echo '6: admin calls mintDip721'
  if [ -z "$2" ]
  then
    echo "metadata is empty"
    exit 0
  else
    echo "metadata is valid"
  fi

  echo 'use admin'
  dfx identity use admin
  admin=$(dfx identity get-principal)
  echo 'admin:' $admin
  echo "(*) Creating NFT with metadata $2:"
  dfx canister call dip721_nft_container mintDip721 \
      "(principal\"$admin\",\"$2\")"
  echo '(*) Number of NFTs admin owns:'
  dfx canister call dip721_nft_container balanceOfDip721 "(principal\"$admin\")"
  echo "(*) totalSupply:"
  dfx canister call dip721_nft_container totalSupplyDip721 '()'
  echo '(*) last Metadata:'
  dfx canister call dip721_nft_container get_metadata_last "()"

elif [[ $1 == "getMetadata" ]]; then
  echo -e "option" $1 'nft_id:'$2
  echo 'get_metadata'
  if [ -z "$2" ]
  then
    echo "nft_id is empty"
    exit 0
  else
    echo "nft_id is valid"
  fi
  dfx canister call dip721_nft_container get_metadata_v2 "($2:nat64)"

elif [[ $1 == "setMetadata" ]]; then
  echo '6b: set_metadata' $1 'nft_id:'$2
  if [ -z "$2" ]
  then
    echo "nft_id is empty"
    exit 0
  else
    echo "nft_id is valid"
  fi
  dfx identity use admin
  admin=$(dfx identity get-principal)
  echo 'admin:' $admin
  echo '(*) Number of NFTs admin owns:'
  dfx canister call dip721_nft_container balanceOfDip721 "(principal\"$admin\")"
  echo 'Set Metadata of NFT id: 0'
  dfx canister call dip721_nft_container set_metadata "($2:nat64,\"nft_name:Godzilla\")"
  echo 'Metadata of the NFT id: 0'
  dfx canister call dip721_nft_container get_metadata_v2 "($2:nat64)"

elif [[ $1 == "mintDip721forall" ]]; then
  echo -e "option" $1 'nft_id:'$2
  echo '6a: john calls mintDip721forall'
  if [ -z "$2" ]
  then
    echo "metadata is empty"
    exit 0
  else
    echo "metadata is valid"
  fi
  dfx identity use john
  echo 'john identity:'
  dfx identity get-principal
  john=$(dfx identity get-principal)

  echo '(*) Creating NFT with metadata "$2":'
  dfx canister call dip721_nft_container mintDip721forall \
      "(principal\"$john\",\"$2\")"
  echo '(*) Number of NFTs john owns:'
  dfx canister call dip721_nft_container balanceOfDip721 "(principal\"$john\")"
  echo "(*) totalSupply:"
  dfx canister call dip721_nft_container totalSupplyDip721 '()'
  echo '(*) last Metadata:'
  dfx canister call dip721_nft_container get_metadata_last "()"

elif [[ $1 == "6zz" ]]; then
  echo '6zz: mint NFT with old method'
  dfx identity use admin
  admin=$(dfx identity get-principal)
  ALICE=$(dfx --identity alice identity get-principal)
  BOB=$(dfx --identity bob identity get-principal)
  echo 'admin:' $admin
  ALICE=$(dfx --identity alice identity get-principal)
  BOB=$(dfx --identity bob identity get-principal)
  echo '(*) Creating NFT with metadata "hello":'
  dfx canister call dip721_nft_container mintDip721 \
      "(principal\"$admin\",vec{record{
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
  dfx canister call dip721_nft_container get_metadata_last "()"

elif [[ $1 == "7" ]]; then
  echo '7: get balances of admin, alice, bob'
  dfx identity use admin
  admin=$(dfx identity get-principal)
  ALICE=$(dfx --identity alice identity get-principal)
  BOB=$(dfx --identity bob identity get-principal)

  echo "(*) Owner of NFT 0 (admin are $admin):"
  dfx canister call dip721_nft_container ownerOfDip721 '(0:nat64)'
  sleep 2s
  echo '(*) Number of NFTs admin owns:'
  dfx canister call dip721_nft_container balanceOfDip721 "(principal\"$admin\")"
  sleep 2s
  echo '(*) Number of NFTs Alice owns:'
  dfx canister call dip721_nft_container balanceOfDip721 "(principal\"$ALICE\")"
  sleep 2s
  echo '(*) Number of NFTs Bob owns:'
  dfx canister call dip721_nft_container balanceOfDip721 "(principal\"$BOB\")"
  echo '(*) Total NFTs in existence:'
  dfx canister call dip721_nft_container totalSupplyDip721

elif [[ $1 == "8" ]]; then

  echo 'Transfer one NFT from admin to Alice'
  dfx identity use admin
  admin=$(dfx identity get-principal)
  ALICE=$(dfx --identity alice identity get-principal)
  BOB=$(dfx --identity bob identity get-principal)

  echo '(*) Transferring the NFT from admin to Alice:'
  dfx canister call dip721_nft_container transferFromDip721 "(principal\"$admin\",principal\"$ALICE\",0:nat64)"
  echo "(*) Owner of NFT 0 (Alice is $ALICE):"
  dfx canister call dip721_nft_container ownerOfDip721 '(0:nat64)'
  echo '(*) Number of NFTs admin owns:'
  dfx canister call dip721_nft_container balanceOfDip721 "(principal\"$admin\")"
  echo '(*) Number of NFTs Alice owns:'
  dfx canister call dip721_nft_container balanceOfDip721 "(principal\"$ALICE\")"

elif [[ $1 == "9" ]]; then
  echo 'approveDip721, setApprovalForAllDip721'
  dfx identity use admin
  admin=$(dfx identity get-principal)
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
  echo '(*) admin is a custodian, so admin can transfer the NFT back to itself without approval:'
  dfx canister call dip721_nft_container transferFromDip721 "(principal\"$ALICE\",principal\"$admin\",0:nat64)"


else 
  echo -e "not matched command"
fi
# /tmp/repoPath/alice/chains/local_testnet/db/full    
