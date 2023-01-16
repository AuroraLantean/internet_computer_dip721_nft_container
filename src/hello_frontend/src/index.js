import { dip721_nft_container } from '../../declarations/dip721_nft_container';
//in that file: export const dip721_nft_container = createActor(canisterId);

document.querySelector('form').addEventListener('submit', async (e) => {
  e.preventDefault();
  const button = e.target.querySelector('button');

  const nft_id = document.getElementById('nft_id').value.toString();

  button.setAttribute('disabled', true);

  const metadata = await dip721_nft_container.get_metadata_v2(nft_id);

  button.removeAttribute('disabled');

  document.getElementById('metadata').innerText = metadata;

  return false;
});
