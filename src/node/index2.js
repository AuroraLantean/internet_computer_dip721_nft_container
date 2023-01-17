import { dip721_nft_container } from '../../declarations/dip721_nft_container';
import { Principal } from '@dfinity/principal';

const log1 = console.log;
export const isEmpty = (value) =>
  value === undefined ||
  value === null ||
  (typeof value === 'object' && Object.keys(value).length === 0) ||
  (typeof value === 'string' && value.trim().length === 0) ||
  (typeof value === 'string' && value === 'undefined');

log1('checkpoint 1');

const nft_to =
  'hvnpv-7tz4x-urwpp-mtaw3-75xzo-v5mwr-b43ba-qgrtn-pc4kv-zy2dg-tqe';
log1('nft_to:', nft_to);
const nft_to_principal = Principal.fromText(nft_to);
log1('checkpoint 2'); //http://127.0.0.1:4943/
const out = await dip721_nft_container.mintDip721forall(
  nft_to_principal,
  nft_metadata
);
outText =
  'Minting Success! New NFT id:' + out.Ok.id + ', token_id:' + out.Ok.token_id;
log1('out:', out);

log1('end');
