import { dip721_nft_container } from '../../declarations/dip721_nft_container';
import { Principal } from '@dfinity/principal';

export const log1 = console.log;
export const isEmpty = (value) =>
  value === undefined ||
  value === null ||
  (typeof value === 'object' && Object.keys(value).length === 0) ||
  (typeof value === 'string' && value.trim().length === 0) ||
  (typeof value === 'string' && value === 'undefined');

document.querySelector('form').addEventListener('submit', async (e) => {
  e.preventDefault();
  log1('----------== submit button clicked');
  const buttonId = document.activeElement.id;
  log1('buttonId:', buttonId, typeof buttonId);
  let outText = '';

  if (buttonId === 'get-metadata') {
    log1('--== get-metadata detected');
    const button = e.target.querySelector('#get-metadata');

    const nft_id = document.getElementById('nft_id').value.toString();
    log1('nft_id:', nft_id);
    if (isEmpty(nft_id)) {
      outText = 'input is empty';
    } else if (isNaN(nft_id)) {
      outText = 'input is not a number';
    } else {
      log1('input is valid');
      button.setAttribute('disabled', true);
      const input = Number(nft_id);
      log1('input:', input, typeof input);
      const metadata = await dip721_nft_container.get_metadata_v2(input);
      outText = metadata.Ok;
      log1('metadata:', metadata, ', outText:', outText);
      button.removeAttribute('disabled');
    }
  } else if (buttonId === 'mint-nft') {
    log1('--== mint-nft detected');
    const button = e.target.querySelector('#mint-nft');
    const nft_metadata = document
      .getElementById('nft_metadata')
      .value.toString();
    log1('nft_metadata:', nft_metadata);

    const nft_to = document.getElementById('nft_to').value.toString();
    log1('nft_to:', nft_to);
    const nft_to_principal = Principal.fromText(nft_to);
    //const john = 'hvnpv-7tz4x-urwpp-mtaw3-75xzo-v5mwr-b43ba-qgrtn-pc4kv-zy2dg-tqe';
    button.setAttribute('disabled', true);
    const out = await dip721_nft_container.mintDip721forall(
      nft_to_principal,
      nft_metadata
    );
    button.removeAttribute('disabled');
    outText =
      'Minting Success! New NFT id:' +
      out.Ok.id +
      ', token_id:' +
      out.Ok.token_id;
    log1('out:', out);
  } else {
  }
  log1('outText:', outText);
  document.getElementById('metadata').innerText = outText;

  return false;
});
