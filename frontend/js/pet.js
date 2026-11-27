/* ============================================================
   pet.js — 桌面宠物组件（三皮肤切换 + 悬停表情 + 点击互动 + 拖拽）
   ------------------------------------------------------------
   皮肤：初音未来 / 五条悟 / 炭治郎，默认初音未来
   交互：
     · 鼠标移入 → 表情变化（爱心眼 / 星星 / 脸红）+ 轻微跳动
     · 点击桌宠 → 随机台词气泡 + 跳跃反应 + 展开皮肤选择环
     · 点选皮肤 → 切换形象，持久化到 localStorage
     · 按住拖拽 → 自由移动位置，持久化
   ============================================================ */
(function (global) {
  const SKINS = [
    {
      id: 'miku', name: '初音未来', img: 'assets/img/pet/miku.png', color: '#5ecdc1',
      face: '♪', hoverFace: '♥',
      lines: ['喵～今天也要元气满满！', '要听我唱歌吗？♪', '初音酱在这里等你哦～', '不过来一起逛逛吗？', '嘿嘿，被你发现了～']
    },
    {
      id: 'gojo', name: '五条悟', img: 'assets/img/pet/gojo.png', color: '#5b7fe8',
      face: '✦', hoverFace: '★',
      lines: ['哈哈，最强就是我～', '别被眼罩骗了哦，我看得见', '想买什么？我请客～', '你也是来逛谷子的？', '这种程度，当然没问题啦']
    },
    {
      id: 'tanjiro', name: '炭治郎', img: 'assets/img/pet/tanjiro.png', color: '#e0604c',
      face: '✿', hoverFace: '♥',
      lines: ['全集中呼吸！', '嗯！这个味道……是好东西！', '一起加油吧！', '今天也要努力啊！', '我闻到你的热情了！']
    }
  ];

  const DesktopPet = {
    name: 'DesktopPet',
    data() {
      return {
        skins: SKINS,
        skinId: localStorage.getItem('sg_pet_skin') || 'miku',
        hover: false,
        jumping: false,
        showSkins: false,
        bubble: '',
        bubbleKey: 0,
        pos: (() => {
          try { return JSON.parse(localStorage.getItem('sg_pet_pos')) || null; } catch (e) { return null; }
        })(),
        dragging: false,
        dragMoved: false,
        _sx: 0, _sy: 0, _ox: 0, _oy: 0,
        _bubbleTimer: null,
        _jumpTimer: null
      };
    },
    computed: {
      skin() {
        return this.skins.find(s => s.id === this.skinId) || this.skins[0];
      },
      style() {
        if (this.pos) return { left: this.pos.x + 'px', top: this.pos.y + 'px', right: 'auto', bottom: 'auto', '--pet-color': this.skin.color };
        return { right: '96px', bottom: '30px', '--pet-color': this.skin.color };
      }
    },
    mounted() {
      this.say('嗨！我是' + this.skin.name + '，点我换皮肤～');
    },
    beforeUnmount() {
      clearTimeout(this._bubbleTimer);
      clearTimeout(this._jumpTimer);
    },
    methods: {
      say(text) {
        this.bubble = text;
        this.bubbleKey++;
        clearTimeout(this._bubbleTimer);
        this._bubbleTimer = setTimeout(() => { this.bubble = ''; }, 2600);
      },
      react() {
        const list = this.skin.lines;
        this.say(list[Math.floor(Math.random() * list.length)]);
        this.jumping = true;
        clearTimeout(this._jumpTimer);
        this._jumpTimer = setTimeout(() => { this.jumping = false; }, 620);
      },
      onEnter() {
        this.hover = true;
      },
      onLeave() {
        this.hover = false;
      },
      onClick() {
        if (this.dragMoved) return;
        this.react();
        this.showSkins = !this.showSkins;
      },
      pick(id) {
        if (id === this.skinId) { this.showSkins = false; return; }
        this.skinId = id;
        localStorage.setItem('sg_pet_skin', id);
        this.showSkins = false;
        this.hover = false;
        this.react();
        this.say('换好啦！我是' + this.skin.name + '～');
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
      },
      onUp() {
        if (!this.dragging) return;
        this.dragging = false;
        window.removeEventListener('mousemove', this.onMove);
        window.removeEventListener('mouseup', this.onUp);
        if (this.pos) localStorage.setItem('sg_pet_pos', JSON.stringify(this.pos));
        if (this.dragMoved) setTimeout(() => { this.dragMoved = false; }, 60);
      }
    },
    template: `
      <div class="deskpet" :style="style" :class="{'is-hover':hover,'is-jump':jumping,'is-drag':dragging}">
        <!-- 台词气泡 -->
        <div class="pet-bubble" :class="{'with-skins':showSkins}" v-if="bubble" :key="bubbleKey">{{bubble}}</div>

        <!-- 皮肤选择环 -->
        <div class="pet-skins" v-if="showSkins">
          <button v-for="s in skins" :key="s.id" class="pet-skin-btn"
                  :class="{active:s.id===skinId}" :style="{'--sk':s.color}"
                  @click.stop="pick(s.id)" :title="'切换为'+s.name">
            <img :src="s.img" :alt="s.name">
            <span>{{s.name}}</span>
          </button>
        </div>

        <!-- 表情符号层 -->
        <div class="pet-face" :key="skinId+'-'+(hover?'h':'n')">{{hover?skin.hoverFace:skin.face}}</div>
        <div class="pet-sparkles" v-if="hover">
          <i style="--i:0">✦</i><i style="--i:1">♥</i><i style="--i:2">✧</i>
        </div>

        <!-- 角色本体 -->
        <div class="pet-body" @mouseenter="onEnter" @mouseleave="onLeave"
             @mousedown="onDown" @click="onClick">
          <img :src="skin.img" :alt="skin.name" draggable="false">
          <div class="pet-shadow"></div>
        </div>
        <div class="pet-name">{{skin.name}}</div>
      </div>`
  };

  global.Widgets = global.Widgets || {};
  global.Widgets.DesktopPet = DesktopPet;
})(window);
