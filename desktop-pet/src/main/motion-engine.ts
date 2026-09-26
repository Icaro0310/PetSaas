import { BrowserWindow, screen } from 'electron';

const TICK_MS = 16; // ~60fps, unico escritor de posicao
const GRAVITY = 2800; // px/s^2
const BOUNCE = 0.35;
const SETTLE_V = 90; // velocidade abaixo da qual o pet assenta
const WALK_SPEED = 55; // px/s
const STROLL_MIN_MS = 35_000;
const STROLL_MAX_MS = 70_000;
const FACE_DIST = 320; // cursor ate esta distancia -> pet olha
const FACE_HYSTERESIS = 60; // px alem de FACE_DIST p/ desfazer o olhar
const STROLL_DIST_MIN = 140; // passeios curtos parecem erraticos
const STROLL_DIST_MAX = 420;

type Mode = 'idle' | 'walking' | 'dragging' | 'falling';

interface MotionState {
  x: number;
  y: number;
  vx: number;
  vy: number;
  mode: Mode;
  targetX: number | null;
  facing: 1 | -1;
}

export class MotionEngine {
  private win: BrowserWindow;
  private size: number;
  private st: MotionState;
  private timer: NodeJS.Timeout | null = null;
  private strollTimer: NodeJS.Timeout | null = null;
  private dragTrail: { x: number; y: number; t: number }[] = [];
  private onDisplayChange = () => this.clampToWorkArea();
  private lastFacing: 1 | -1 = 1;
  private focusMode = false;

  onModeChange: ((mode: Mode) => void) | null = null;
  onFacing: ((dir: 1 | -1) => void) | null = null;

  constructor(win: BrowserWindow, size: number) {
    this.win = win;
    this.size = size;
    const [x, y] = win.getPosition();
    this.st = {
      x,
      y,
      vx: 0,
      vy: 0,
      mode: 'idle',
      targetX: null,
      facing: 1,
    };
  }

  start(): void {
    this.timer = setInterval(() => this.tick(), TICK_MS);
    this.scheduleStroll();
    screen.on('display-metrics-changed', this.onDisplayChange);
    screen.on('display-added', this.onDisplayChange);
    screen.on('display-removed', this.onDisplayChange);
  }

  stop(): void {
    if (this.timer) clearInterval(this.timer);
    if (this.strollTimer) clearTimeout(this.strollTimer);
    screen.removeListener('display-metrics-changed', this.onDisplayChange);
    screen.removeListener('display-added', this.onDisplayChange);
    screen.removeListener('display-removed', this.onDisplayChange);
  }

  setSize(size: number): void {
    this.size = size;
    this.clampToWorkArea();
  }

  // ---- API publica ----------------------------------------------------

  beginDrag(): void {
    const cursor = screen.getCursorScreenPoint();
    this.setMode('dragging');
    this.st.vx = 0;
    this.st.vy = 0;
    this.dragTrail = [{ ...cursor, t: Date.now() }];
  }

  moveDrag(): void {
    if (this.st.mode !== 'dragging') return;
    const cursor = screen.getCursorScreenPoint();
    this.st.x = cursor.x - this.size / 2;
    this.st.y = cursor.y - this.size / 2;
    this.dragTrail.push({ ...cursor, t: Date.now() });
    if (this.dragTrail.length > 8) this.dragTrail.shift();
    this.write();
  }

  endDrag(): void {
    if (this.st.mode !== 'dragging') return;
    // velocidade de lancamento a partir do trail recente
    const t = this.dragTrail;
    if (t.length >= 2) {
      const a = t[0];
      const b = t[t.length - 1];
      const dt = Math.max((b.t - a.t) / 1000, 0.016);
      this.st.vx = ((b.x - a.x) / dt) * 0.6;
      this.st.vy = ((b.y - a.y) / dt) * 0.6;
      const vmax = 2400;
      this.st.vx = Math.max(-vmax, Math.min(vmax, this.st.vx));
      this.st.vy = Math.max(-vmax, Math.min(vmax, this.st.vy));
    }
    this.setMode('falling');
  }

  strollNow(): void {
    this.pickStrollTarget();
  }

  getMode(): Mode {
    return this.st.mode;
  }

  /** Pomodoro/doze: sem passeios nem gaze enquanto foca/dorme */
  setFocusMode(on: boolean): void {
    this.focusMode = on;
    if (this.strollTimer) {
      clearTimeout(this.strollTimer);
      this.strollTimer = null;
    }
    if (!on) this.scheduleStroll();
  }

  // ---- ticker ---------------------------------------------------------

  private tick(): void {
    const dt = TICK_MS / 1000;
    const s = this.st;

    if (s.mode === 'walking' && s.targetX !== null) {
      const dx = s.targetX - s.x;
      if (Math.abs(dx) < 4) {
        s.vx = 0;
        s.targetX = null;
        this.setMode('idle');
      } else {
        // direcao comprometida: o facing so muda com o alvo, nao com o cursor
        s.vx = Math.sign(dx) * WALK_SPEED;
        s.x += s.vx * dt;
        this.setFacing(Math.sign(dx) as 1 | -1);
      }
    } else if (s.mode === 'falling') {
      s.vy += GRAVITY * dt;
      s.x += s.vx * dt;
      s.y += s.vy * dt;
      s.vx *= 0.995; // atrito do ar

      const floor = this.floorY();
      if (s.y >= floor) {
        s.y = floor;
        if (Math.abs(s.vy) > SETTLE_V) {
          s.vy = -s.vy * BOUNCE;
          s.vx *= 0.7;
        } else {
          s.vy = 0;
          s.vx = 0;
          this.setMode('idle');
        }
      }
    }

    this.clampX();
    this.write();
    this.watchFacing();
  }

  private setMode(mode: Mode): void {
    if (this.st.mode === mode) return;
    this.st.mode = mode;
    this.onModeChange?.(mode);
  }

  private setFacing(dir: 1 | -1): void {
    if (dir === this.st.facing) return;
    this.st.facing = dir;
    this.onFacing?.(dir);
  }

  private watchFacing(): void {
    if (this.st.mode !== 'idle' || this.focusMode) return;
    const cursor = screen.getCursorScreenPoint();
    const cx = this.st.x + this.size / 2;
    const dist = cursor.x - cx;
    const dir = dist >= 0 ? 1 : -1;
    // histerese: olha quando entra em FACE_DIST, mantem ate sair
    // de FACE_DIST+HYSTERESIS - evita flicker no limiar
    const limit =
      this.st.facing === dir ? FACE_DIST : FACE_DIST + FACE_HYSTERESIS;
    if (Math.abs(dist) < limit && dir !== this.st.facing) {
      this.setFacing(dir);
    }
  }

  private floorY(): number {
    const cx = this.st.x + this.size / 2;
    const cy = this.st.y + this.size / 2;
    const d = screen.getDisplayNearestPoint({ x: cx, y: cy });
    return d.workArea.y + d.workArea.height - this.size;
  }

  private clampX(): void {
    const cx = this.st.x + this.size / 2;
    const cy = this.st.y + this.size / 2;
    const d = screen.getDisplayNearestPoint({ x: cx, y: cy });
    const min = d.workArea.x;
    const max = d.workArea.x + d.workArea.width - this.size;
    if (this.st.x < min) {
      this.st.x = min;
      this.st.vx = Math.abs(this.st.vx) * BOUNCE;
    } else if (this.st.x > max) {
      this.st.x = max;
      this.st.vx = -Math.abs(this.st.vx) * BOUNCE;
    }
  }

  clampToWorkArea(): void {
    this.st.y = Math.min(this.st.y, this.floorY());
    this.clampX();
    this.write();
  }

  private write(): void {
    if (this.win.isDestroyed()) return;
    this.win.setPosition(Math.round(this.st.x), Math.round(this.st.y));
  }

  private scheduleStroll(): void {
    const ms =
      STROLL_MIN_MS +
      Math.random() * (STROLL_MAX_MS - STROLL_MIN_MS);
    this.strollTimer = setTimeout(() => {
      if (this.st.mode === 'idle' && !this.focusMode) {
        this.pickStrollTarget();
      }
      if (!this.focusMode) this.scheduleStroll();
    }, ms);
  }

  private pickStrollTarget(): void {
    const cx = this.st.x + this.size / 2;
    const cy = this.st.y + this.size / 2;
    const d = screen.getDisplayNearestPoint({ x: cx, y: cy });
    const min = d.workArea.x;
    const max = d.workArea.x + d.workArea.width - this.size;

    // prefere continuar na direcao atual; vira so' 30% das vezes
    const dir =
      Math.random() < 0.3 ? -this.st.facing : this.st.facing;
    const dist =
      STROLL_DIST_MIN +
      Math.random() * (STROLL_DIST_MAX - STROLL_DIST_MIN);
    let t = this.st.x + dir * dist;

    // se bater na parede, vai na direcao oposta (bounce logico)
    if (t < min) t = Math.min(max, this.st.x + Math.abs(t - min));
    if (t > max) t = Math.max(min, this.st.x - Math.abs(t - max));

    this.st.targetX = t;
    this.setFacing((Math.sign(t - this.st.x) || 1) as 1 | -1);
    this.setMode('walking');
  }
}
