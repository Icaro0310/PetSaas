/* Control panel: bidirectional settings binding via preload API. */

const $ = (id) => document.getElementById(id);

async function refreshPets() {
  const s = await window.panel.getSettings();
  const pets = await window.panel.listPets();
  $('pet').innerHTML = pets
    .map((p) => `<option value="${p.id}">${p.displayName || p.id}</option>`)
    .join('');
  $('pet').value = s.activePet;
  $('remove').disabled = s.activePet === 'chihuahua-pixel';
}

async function init() {
  const s = await window.panel.getSettings();
  await refreshPets();

  $('scale').value = s.scale;
  $('scaleVal').textContent = `${Math.round(s.scale * 100)}%`;
  $('opacity').value = s.opacity;
  $('opacityVal').textContent = `${Math.round(s.opacity * 100)}%`;
  $('top').checked = s.alwaysOnTop;
  $('pass').checked = s.mousePassthrough;
  $('lock').checked = s.lockDragging;
  $('pause').checked = s.pauseInteractions;
  $('login').checked = s.launchAtLogin;
  $('lang').value = s.lang;
  $('token').value = s.petsaasToken || '';

  $('pet').onchange = () => window.panel.set('activePet', $('pet').value);
  $('scale').oninput = () => {
    $('scaleVal').textContent = `${Math.round($('scale').value * 100)}%`;
    window.panel.set('scale', parseFloat($('scale').value));
  };
  $('opacity').oninput = () => {
    $('opacityVal').textContent = `${Math.round($('opacity').value * 100)}%`;
    window.panel.set('opacity', parseFloat($('opacity').value));
  };
  $('top').onchange = () => window.panel.set('alwaysOnTop', $('top').checked);
  $('pass').onchange = () =>
    window.panel.set('mousePassthrough', $('pass').checked);
  $('lock').onchange = () =>
    window.panel.set('lockDragging', $('lock').checked);
  $('pause').onchange = () =>
    window.panel.set('pauseInteractions', $('pause').checked);
  $('login').onchange = () =>
    window.panel.set('launchAtLogin', $('login').checked);
  $('lang').onchange = () => window.panel.set('lang', $('lang').value);

  $('reset').onclick = () => window.panel.resetPosition();
  $('quit').onclick = () => window.panel.quit();

  $('install').onclick = async () => {
    const r = await window.panel.installPetpack();
    $('petMsg').textContent = r.ok
      ? `Pet "${r.petId}" instalado.`
      : r.error || 'Cancelado.';
  };

  $('remove').onclick = async () => {
    const r = await window.panel.removePet($('pet').value);
    $('petMsg').textContent = r.ok ? 'Pet removido.' : r.error || 'Erro.';
  };

  $('token').onchange = () =>
    window.panel.set('petsaasToken', $('token').value.trim());

  $('sync').onclick = async () => {
    $('sync').disabled = true;
    $('syncMsg').textContent = 'A sincronizar...';
    try {
      const r = await window.panel.petsaasSync();
      $('syncMsg').textContent = r.ok
        ? `${r.pets.length} pet(s): ${r.pets.map((p) => p.name).join(', ')}` +
          (r.photosSaved.length ? ` — ${r.photosSaved.length} foto(s)` : '')
        : r.error;
    } finally {
      $('sync').disabled = false;
    }
  };

  window.panel.onPetsChanged(() => refreshPets());
}

init();
