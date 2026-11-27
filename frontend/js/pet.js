/* ============================================================
   pet.js — 桌面宠物（逐帧动画版）
   ------------------------------------------------------------
   皮肤：初音未来 / 五条悟 / 炭治郎，默认初音未来
   动作（真·逐帧，多张图切换）：
     · 原地奔跑 —— 4 张不同跑步姿势的图循环播放（每 130ms 一帧）
     · 跳跃 —— 跳跃期间同样逐帧切换（腿在动）+ CSS 腾空位移
     · 眨眼 / 随机待机动作 / 翻转换肤
   关键设计：帧定时器永不停、帧序号全局共享，currentImg 按当前皮肤取帧，
   所以切换皮肤后动画无缝继续，绝不会出现"切完就不动"。
   保留：台词气泡、皮肤环、点击反应、拖拽与位置持久化、鼠标视角倾斜
   ============================================================ */
(function (global) {
  const SKINS = [
    {
      id: 'miku', name: '初音未来', img: 'assets/img/pet/miku.png', color: '#5ecdc1',
      frames: [1, 2, 3, 4].map(i => 'assets/img/pet/frames/miku-run-' + i + '.png'),
      face: '♪', hoverFace: '♥',
      lines: ['喵～今天也要元气满满！', '要听我唱歌吗？♪', '初音酱在这里等你哦～', '不过来一起逛逛吗？', '嘿嘿，被你发现了～']
    },
    {
      id: 'gojo', name: '五条悟', img: 'assets/img/pet/gojo.png', color: '#5b7fe8',
      frames: [1, 2, 3, 4].map(i => 'assets/img/pet/frames/gojo-run-' + i + '.png'),
      face: '✦', hoverFace: '★',
      lines: ['哈哈，最强就是我～', '别被眼罩骗了哦，我看得见', '想买什么？我请客～', '你也是来逛谷子的？', '这种程度，当然没问题啦']
    },
    {
      id: 'tanjiro', name: '炭治郎', img: 'assets/img/pet/tanjiro.png', color: '#e0604c',
      frames: [1, 2, 3, 4].map(i => 'assets/img/pet/frames/tanjiro-run-' + i + '.png'),
      face: '✿', hoverFace: '♥',
      lines: ['全集中呼吸！', '嗯！这个味道……是好东西！', '一起加油吧！', '今天也要努力啊！', '我闻到你的热情了！']
    }
  ];

  const IDLE_ACTS = ['act-stretch', 'act-tilt', 'act-spin'];

  const DesktopPet = {
    name: 'DesktopPet',
    data() {
      return {
        skins: SKINS,
        skinId: localStorage.getItem('sg_pet_skin') || 'miku',
        hover: false,
        running: true,          // 待机原地奔跑开关
        jumping: false,
        blinking: false,
        flipping: false,
        idleAct: '',
        showSkins: false,
        bubble: '',
        bubbleKey: 0,
        frameIdx: 0,            // 当前帧序号（全局共享，切皮肤不重置）
        rx: 0, ry: 0,           // 鼠标视角倾斜角（度）
        gx: 50,                 // 高光位置百分比
        pos: (() => {
          try { return JSON.parse(localStorage.getItem('sg_pet_pos')) || null; } catch (e) { return null; }
        })(),
        dragging: false,
        dragMoved: false,
        _sx: 0, _sy: 0, _ox: 0, _oy: 0,
        _bubbleTimer: null, _jumpTimer: null, _actTimer: null, _blinkTimer: null,
        _frameTimer: null, _pickTimers: []
      };
    },
    computed: {
      skin() {
        return this.skins.find(s => s.id === this.skinId) || this.skins[0];
      },
      // 跑 / 跳 都逐帧播放；翻转换肤、拖拽、其他待机动作用静态立绘
      isAnimated() {
        return (this.running && !this.flipping && !this.dragging && !this.idleAct) || this.jumping;
      },
      isRun() {
        return this.running && !this.jumping && !this.flipping && !this.dragging && !this.idleAct;
      },
      // 当前显示的图片：动画态取当前皮肤的当前帧，静态态用立绘
      currentImg() {
        return this.isAnimated ? this.skin.frames[this.frameIdx % this.skin.frames.length] : this.skin.img;
      },
      style() {
        const base = this.pos
          ? { left: this.pos.x + 'px', top: this.pos.y + 'px', right: 'auto', bottom: 'auto' }
          : { right: '96px', bottom: '30px' };
        return Object.assign(base, {
          '--pet-color': this.skin.color,
          '--rx': this.rx.toFixed(2) + 'deg',
          '--ry': this.ry.toFixed(2) + 'deg',
          '--gx': this.gx.toFixed(1) + '%'
        });
      },
      faceText() {
        if (this.blinking) return '︶';
        return this.hover ? this.skin.hoverFace : this.skin.face;
      }
    },
    mounted() {
      // 预加载所有帧，避免切换时闪白
      SKINS.forEach(s => s.frames.forEach(src => { const im = new Image(); im.src = src; }));
      // 帧定时器永不停：切皮肤、hover、跳跃都不影响它
      this._frameTimer = setInterval(() => { this.frameIdx++; }, 130);
      window.addEventListener('mousemove', this.onGlobalMove, { passive: true });
      this._blinkTimer = setInterval(() => this.blink(), 3200 + Math.random() * 2000);
      this._actTimer = setInterval(() => this.randomAct(), 8000 + Math.random() * 5000);
      this.say('嗨！我是' + this.skin.name + '，点我换皮肤～');
    },
    beforeUnmount() {
      clearInterval(this._frameTimer);
      window.removeEventListener('mousemove', this.onGlobalMove);
      clearTimeout(this._bubbleTimer);
      clearTimeout(this._jumpTimer);
      clearInterval(this._blinkTimer);
      clearInterval(this._actTimer);
      this.clearPickTimers();
    },
    methods: {
      onGlobalMove(e) {
        if (this.dragging || !this.$refs.pet) return;
        const r = this.$refs.pet.getBoundingClientRect();
        const cx = r.left + r.width / 2, cy = r.top + r.height / 2;
        const dx = e.clientX - cx, dy = e.clientY - cy;
        const dist = Math.sqrt(dx * dx + dy * dy);
        const strength = Math.max(0, 1 - dist / 620);
        const maxX = this.hover ? 16 : 10;
        const maxY = this.hover ? 22 : 14;
        this.ry = Math.max(-1, Math.min(1, dx / 380)) * maxY * strength;
        this.rx = Math.max(-1, Math.min(1, -dy / 380)) * maxX * strength;
        this.gx = 50 + Math.max(-1, Math.min(1, dx / 300)) * 34 * strength;
      },
      blink() {
        if (this.dragging || this.flipping || this.jumping) return;
        this.blinking = true;
        setTimeout(() => { this.blinking = false; }, 150);
      },
      randomAct() {
        if (this.dragging || this.flipping || this.hover || this.jumping) return;
        const act = IDLE_ACTS[Math.floor(Math.random() * IDLE_ACTS.length)];
        this.idleAct = act;
        setTimeout(() => { if (this.idleAct === act) this.idleAct = ''; }, 1400);
      },
      jump() {
        if (this.dragging || this.flipping || this.jumping) return;
        this.idleAct = '';
        this.jumping = true;
        clearTimeout(this._jumpTimer);
        this._jumpTimer = setTimeout(() => { this.jumping = false; }, 780);
      },
      say(text) {
        this.bubble = text;
        this.bubbleKey++;
        clearTimeout(this._bubbleTimer);
        this._bubbleTimer = setTimeout(() => { this.bubble = ''; }, 2600);
      },
      react() {
        const list = this.skin.lines;
        this.say(list[Math.floor(Math.random() * list.length)]);
        this.jump();
      },
      onEnter() { this.hover = true; this.jump(); },
      onLeave() {
        this.hover = false;
        this.rx = 0; this.ry = 0; this.gx = 50;
      },
      onClick() {
        if (this.dragMoved) return;
        this.react();
        this.showSkins = !this.showSkins;
      },
      clearPickTimers() {
        this._pickTimers.forEach(t => clearTimeout(t));
        this._pickTimers = [];
      },
      laterPick(fn, ms) { this._pickTimers.push(setTimeout(fn, ms)); },
      pick(id) {
        if (id === this.skinId) { this.showSkins = false; return; }
        this.clearPickTimers();
        clearTimeout(this._jumpTimer);
        this.showSkins = false;
        this.idleAct = '';
        this.jumping = false;
        this.flipping = true;
        this.laterPick(() => {
          this.skinId = id;
          localStorage.setItem('sg_pet_skin', id);
        }, 350);
        this.laterPick(() => { this.flipping = false; }, 760);
        this.laterPick(() => {
          this.jumping = true;
          clearTimeout(this._jumpTimer);
          this._jumpTimer = setTimeout(() => { this.jumping = false; }, 780);
          this.say('换好啦！我是' + this.skin.name + '～');
        }, 780);
      },
      onDown(e) {
        this.dragging = true;
        this.dragMoved = false;
        const box = this.$refs.pet.getBoundingClientRect();
        this._sx = e.clientX; this._sy = e.clientY;
        this._ox = box.left; this._oy = box.top;
        this.pos = { x: box.left, y: box.top };
        window.addEventListener('mousemove', this.onMove);
        window.addEventListener('mouseup', this.onUp);
      },
      onMove(e) {
        if (!this.dragging) return;
        const dx = e.clientX - this._sx, dy = e.clientY - this._sy;
        if (Math.abs(dx) > 5 || Math.abs(dy) > 5) this.dragMoved = true;
        const x = Math.max(0, Math.min(window.innerWidth - 90, this._ox + dx));
        const y = Math.max(0, Math.min(window.innerHeight - 120, this._oy + dy));
        this.pos = { x, y };
        this.ry = Math.max(-22, Math.min(22, dx / 8));
        this.rx = Math.max(-16, Math.min(16, -dy / 10));
      },
      onUp() {
        if (!this.dragging) return;
        this.dragging = false;
        window.removeEventListener('mousemove', this.onMove);
        window.removeEventListener('mouseup', this.onUp);
        if (this.pos) localStorage.setItem('sg_pet_pos', JSON.stringify(this.pos));
        setTimeout(() => { this.rx = 0; this.ry = 0; }, 200);
        setTimeout(() => { this.dragMoved = false; }, 80);
      }
    },
    template: `
      <div class="deskpet" :style="style" :class="{'is-hover':hover,'is-jump':jumping,
           'is-drag':dragging,'is-blink':blinking,'is-flip':flipping}">
        <div class="pet-bubble" :class="{'with-skins':showSkins}" v-if="bubble" :key="bubbleKey">{{bubble}}</div>
        <div class="pet-skins" v-if="showSkins">
          <button v-for="s in skins" :key="s.id" class="pet-skin-btn"
                  :class="{active:s.id===skinId}" :style="{'--sk':s.color}"
                  @click.stop="pick(s.id)" :title="'切换为'+s.name">
            <img :src="s.img" :alt="s.name">
            <span>{{s.name}}</span>
          </button>
        </div>
        <div class="pet-body" @mouseenter="onEnter" @mouseleave="onLeave"
             @mousedown="onDown" @click="onClick">
          <div class="pet-speed" v-if="isRun"><i></i><i></i><i></i></div>
          <div class="pet-inner" :class="{'is-animated':isAnimated, 'act-stretch':idleAct==='act-stretch',
               'act-tilt':idleAct==='act-tilt','act-spin':idleAct==='act-spin'}">
            <img :src="currentImg" :alt="skin.name" draggable="false">
            <div class="pet-gloss"></div>
          </div>
          <div class="pet-dust" v-if="isRun"><i></i><i></i><i></i><i></i></div>
          <div class="pet-face" :key="skinId+'-'+(hover?'h':'n')">{{faceText}}</div>
          <div class="pet-sparkles" v-if="hover"><i style="--i:0">✦</i><i style="--i:1">♥</i><i style="--i:2">✧</i></div>
          <div class="pet-shadow" :class="{'is-run':isRun}"></div>
        </div>
        <div class="pet-name">{{skin.name}}</div>
      </div>`
  };

  global.Widgets = global.Widgets || {};
  global.Widgets.DesktopPet = DesktopPet;
})(window);
