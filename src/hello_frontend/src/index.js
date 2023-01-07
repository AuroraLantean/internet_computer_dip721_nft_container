import { dip721_nft_container } from '../../declarations/dip721_nft_container';

document.querySelector('form').addEventListener('submit', async (e) => {
  e.preventDefault();
  const button = e.target.querySelector('button');

  const name = document.getElementById('name').value.toString();

  button.setAttribute('disabled', true);

  // Interact with foo actor, calling the greet method
  const greeting = await dip721_nft_container.greet(name);

  button.removeAttribute('disabled');

  document.getElementById('greeting').innerText = greeting;

  return false;
});
