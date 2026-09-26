/* PetDeskSaas renderer: flipbook (linha=estado, coluna=frame).
 * O main process e' a autoridade: movimento (modo), reacoes e fala
 * chegam via IPC; o renderer faz playback + distingue gestos. */

let manifest = null;
let scale = 1;
let facing = 1;
let stateName = 'idle';
let persistentState = 'idle'; // estado "de fundo" p/ reverter temporarios
let state = null;
let frame = 0;
let timer = null;
let tempUntil = 0;
let lastClickAt = 0;
let lastHoverAt = 0;

const petEl = document.getElementById('pet');
const bubbleEl = document.getElementById('bubble');

function applyTransform() {
  petEl.style.transform = `scale(${scale}) scaleX(${facing})`;
}

function applyFrame() {
  const [w, h] = manifest.frameSize;
  petEl.style.backgroundPosition =
    `-${frame * w}px -${state.row * h}px`;
}

function play(name) {
  const next = manifest.states[name] || manifest.states.idle;
  stateName = manifest.states[name] ? name : 'idle';
  if (state === next) return;
  state = next;
  frame = 0;
  applyFrame();
  clearInterval(timer);
  if (state.frames > 1) {
    timer = setInterval(() => {
      frame = (frame + 1) % state.frames;
      applyFrame();
    }, 1000 / state.fps);
  }
}

function setState(name, ms) {
  if (ms) {
    tempUntil = Date.now() + ms;
    play(name);
    setTimeout(() => {
      if (Date.now() >= tempUntil) play(persistentState);
    }, ms + 30);
  } else {
    tempUntil = 0;
    persistentState = name;
    play(name);
  }
}

function say(text, ms) {
  bubbleEl.textContent = text;
  bubbleEl.hidden = false;
  clearTimeout(say._t);
  say._t = setTimeout(() => {
    bubbleEl.hidden = true;
  }, ms || 2000);
}

function setupInput() {
  let downAt = 0;
  let downX = 0;
  let downY = 0;
  let dragged = false;

  window.addEventListener('mousedown', (e) => {
    if (e.button === 2) return; // botao direito -> contextmenu
    downAt = Date.now();
    downX = e.screenX;
    downY = e.screenY;
    dragged = false;
    // dragStart so' depois de movimento real (>6px)
  });

  window.addEventListener('mousemove', (e) => {
    if (e.buttons & 1) {
      const dx = e.screenX - downX;
      const dy = e.screenY - downY;
      if (!dragged && Math.hypot(dx, dy) > 6) {
        dragged = true;
        window.petdesk.dragStart();
      }
      if (dragged) window.petdesk.dragMove();
    } else {
      // hover sem botoes -> petted (throttle 2s)
      const now = Date.now();
      if (now - lastHoverAt > 2000) {
        lastHoverAt = now;
        window.petdesk.hover();
      }
    }
  });

  window.addEventListener('mouseup', () => {
    if (dragged) {
      window.petdesk.dragEnd();
      dragged = false;
      return;
    }
    if (Date.now() - downAt < 300) {
      const now = Date.now();
      if (now - lastClickAt < 400) {
        lastClickAt = 0;
        window.petdesk.dblclick();
      } else {
        lastClickAt = now;
        window.petdesk.click();
      }
    }
  });

  window.addEventListener('contextmenu', (e) => {
    e.preventDefault();
    window.petdesk.contextMenu({ x: e.screenX, y: e.screenY });
  });
}

async function init() {
  const data = await window.petdesk.getManifest();
  manifest = data.manifest;
  scale = data.scale || 1;

  const [w, h] = manifest.frameSize;
  petEl.style.width = `${w}px`;
  petEl.style.height = `${h}px`;
  petEl.style.marginLeft = `-${w / 2}px`;
  petEl.style.marginTop = `-${h / 2}px`;
  petEl.style.backgroundImage = `url("${data.spriteUrl}")`;
  applyTransform();

  window.petdesk.onSetState((s, ms) => setState(s, ms));
  window.petdesk.onSetFacing((dir) => {
    facing = dir;
    applyTransform();
  });
  window.petdesk.onSay((t, ms) => say(t, ms));
  window.petdesk.onScale((s) => {
    scale = s;
    applyTransform();
  });

  play('idle');
  setupInput();
}

init();
