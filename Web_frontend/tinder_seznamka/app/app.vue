<template>
  <div class="desktop-layout">

    <!-- LEVÝ SLOUPEC: NADPIS, POPIS A SWIPOVÁNÍ -->
    <div class="left-column">
      <header class="header">
        <h1 class="logo">Monstermatch</h1>
        <p class="subtitle">Seznamka pro upíry, vlkodlaky a jinou havěť z tohoto světa a okolí.</p>
      </header>

      <!-- KARTA MONSTRA -->
      <div v-if="matchStore.getFilteredQueue.length > 0" class="card-container">
        <div class="monster-card">
          <img :src="matchStore.getFilteredQueue[0].avatar" alt="Avatar" class="card-image" />
          <div class="card-info">
            <div class="card-name">{{ matchStore.getFilteredQueue[0].name }}, <span class="card-age">{{ matchStore.getFilteredQueue[0].age }}</span></div>
            <div class="card-tags">
              <span class="tag" :class="matchStore.getFilteredQueue[0].hasFur ? 'tag-fur' : 'tag-nofur'">
                {{ matchStore.getFilteredQueue[0].hasFur ? '🐺 Srst' : '🦇 Bez srsti' }}
              </span>
            </div>
          </div>
        </div>

        <!-- TLAČÍTKA AKCÍ -->
        <div class="action-buttons">
          <button class="btn-action btn-reject" @click="matchStore.swipe('left', matchStore.getFilteredQueue[0].id)">
            NE
          </button>
          <button class="btn-action btn-match" @click="matchStore.swipe('right', matchStore.getFilteredQueue[0].id)">
            MATCH
          </button>
        </div>
      </div>

      <div v-else class="empty-state">
        <div class="empty-title">Konec fronty</div>
        <p>Všichni byli přeswipováni.</p>
      </div>
    </div>

    <!-- PRAVÝ SLOUPEC: OVLÁDÁNÍ, FILTRY, MATCHE A CHAT -->
    <div class="right-column">

      <!-- HORNÍ OVLÁDACÍ TLAČÍTKA -->
      <div class="top-controls">
        <button class="btn btn-primary" @click="matchStore.loadMonsters()">Načíst data z API</button>
        <button v-if="matchStore.lastAction" class="btn btn-secondary" @click="matchStore.undoLastSwipe()">
          ↩ Vzít tah zpět
        </button>
      </div>

      <!-- PANEL FILTRŮ -->
      <div class="filters-panel">
        <div class="filter-header">Filtrování profilů</div>
        <div class="filter-controls">
          <div class="filter-row">
            <div class="filter-group">
              <label>Min. věk: <b>{{ matchStore.filters.minAge }}</b></label>
              <input type="range" v-model.number="matchStore.filters.minAge" min="0" max="1000" class="range-slider">
            </div>
            <div class="filter-group">
              <label>Max. věk: <b>{{ matchStore.filters.maxAge }}</b></label>
              <input type="range" v-model.number="matchStore.filters.maxAge" min="0" max="1000" class="range-slider">
            </div>
          </div>
          <div class="filter-group checkbox-group">
            <label>
              <input type="checkbox" v-model="matchStore.filters.needFur">
              Vyžaduji monstra se srstí
            </label>
          </div>
        </div>
      </div>

      <!-- SEZNAM MATCHŮ -->
      <div class="matches-panel">
        <h2>Tvoje Matche ({{ matchStore.likedMonsters.length }})</h2>
        <div v-if="matchStore.likedMonsters.length === 0" class="no-matches">
          Zatím nemáš žádné oblíbené monstrum.
        </div>

        <div class="matches-list">
          <div
              v-for="monster in matchStore.likedMonsters"
              :key="monster.id"
              class="match-row"
              :class="{ 'active-match': activeChatMonster?.id === monster.id }"
          >
            <div class="match-info">
              <img :src="monster.avatar" class="match-avatar-small" />
              <span>{{ monster.name }}</span>
            </div>
            <button class="btn-chat-icon" @click="openChat(monster)" title="Otevřít chat">
              💬
            </button>
          </div>
        </div>
      </div>

      <!-- CHAT (S maximální rozumnou výškou) -->
      <div class="chat-panel">
        <div v-if="activeChatMonster" class="chat-interface">
          <div class="chat-header">
            <div class="chat-header-user">
              <img :src="activeChatMonster.avatar" class="chat-avatar-medium" />
              <div>
                <strong>{{ activeChatMonster.name }}</strong>
                <div class="online-status">● Online z hrobky</div>
              </div>
            </div>
            <button class="btn-close" @click="closeChat()">✕</button>
          </div>

          <div class="chat-messages">
            <div
                v-for="(msg, index) in (matchStore.chatHistory?.[activeChatMonster.id] ?? [])"
                :key="index"
                class="message my-message"
            >
              {{ msg }}
            </div>
            <div v-if="!(matchStore.chatHistory?.[activeChatMonster.id]?.length > 0)" class="chat-empty">
              Tady to zeje prázdnotou... Napiš něco!
            </div>
          </div>

          <div class="chat-input-area">
            <input
                v-model="chatInput"
                @keyup.enter="sendMessage"
                type="text"
                placeholder="Napiš zprávu..."
                class="chat-input"
            />
            <button @click="sendMessage" class="btn-send">➤</button>
          </div>
        </div>

        <div v-else class="chat-placeholder">
          <div class="chat-icon-large">👻</div>
          <p>Vyber si match a začni si psát</p>
        </div>
      </div>

    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useMatchStore } from '~/stores/matchStore'
import type { Monster } from '~/types'

const matchStore = useMatchStore()
const activeChatMonster = ref<Monster | null>(null)
const chatInput = ref('')

const openChat = (monster: Monster) => {
  activeChatMonster.value = monster
}

const closeChat = () => {
  activeChatMonster.value = null
}

const sendMessage = () => {
  if (!chatInput.value.trim() || !activeChatMonster.value) return;
  matchStore.chatWithMonster(activeChatMonster.value.id, chatInput.value);
  chatInput.value = '';
}
</script>

<style>
@import url('https://fonts.googleapis.com/css2?family=Metal+Mania&family=Inter:wght@400;700&display=swap');
/* ========================================================
   CSS PROMĚNNÉ (ZDE MĚŇ BARVY CELÉ APLIKACE)
======================================================== */
:root {
  /* Tvoje primární paleta */
  --color-1: #13072e; /* Nejtmavší (Pozadí, inputy, gradienty) */
  --color-2: #565252; /* Tmavá fialová (Panely, ohraničení, tlačítka) */
  --color-3: #720455; /* Střední fialová (Aktivní stavy, štítky) */
  --color-4: #62b622; /* Růžová/Magenta (Zvýraznění, slidery, jména) */
  --color-button: #62b622;
  --color-secondary: #62b62252;
  --chat-input-bg: #a7a7a71a;
  --contact-active: #62b622;
  --match-row-bg:#112106;
  --color-match: #62b622;
  --color-reject: #b62222;
  --color-text-main: #ffffff;
  --color-text-muted: #aaaaaa;
  --panel-bg: #0d0c0d;
  --fur: #b62222;
  --no-fur: #b62222;
}

/* ZABRÁNĚNÍ SCROLLOVÁNÍ CELÉ STRÁNKY */
body {
  margin: 0;
  overflow: hidden;
  background-color: var(--color-1);
}
</style>

<style scoped>
/* CELKOVÝ DESKTOP LAYOUT */
.desktop-layout {
  height: 100vh;
  color: var(--color-text-main);
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
  display: flex;
  padding: 40px;
  gap: 60px;
  max-width: 1300px;
  margin: 0 auto;
  box-sizing: border-box;
  align-items: flex-start;
}

/* LEVÝ A PRAVÝ SLOUPEC */
.left-column, .right-column {
  flex: 1;
  width: 50%;
  display: flex;
  flex-direction: column;
  gap: 20px;
  height: 100%;
}

/* HLAVIČKA VLEVO */
.header { margin-bottom: 5px; }
.logo { font-family: 'Metal Mania', cursive; font-size: 3rem; font-weight: 800; margin: 0 0 5px 0; color: var(--color-4); }
.subtitle { font-size: 1rem; color: var(--color-text-muted); margin: 0; line-height: 1.4; }

/* KARTA MONSTRA (Levý sloupec) */
.card-container { position: relative; margin-top: 10px; }
.monster-card {
  width: 100%;
  height: 60vh;
  max-height: 600px;
  min-height: 400px;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 15px 35px rgba(0,0,0,0.5);
  position: relative;
}
.card-image { width: 100%; height: 100%; object-fit: cover; }
.card-info {
  position: absolute; bottom: 0; left: 0; right: 0;
  padding: 40px 25px 25px 25px;
  background: linear-gradient(transparent, var(--color-1));
}
.card-name { font-size: 2.2rem; font-weight: 700; margin-bottom: 10px; }
.card-age { color: var(--color-text-muted); font-weight: 400; }
.tag { font-size: 0.8rem; padding: 5px 12px; border-radius: 20px; font-weight: 600; }
.tag-fur { background: var(--fur); color: var(--color-text-main); }
.tag-nofur { background: var(--no-fur); color: var(--color-text-main);}

/* SWIPE TLAČÍTKA */
.action-buttons {
  display: flex;
  justify-content: center;
  gap: 40px;
  margin-top: -35px;
  position: relative;
  z-index: 10;
  padding-bottom: 20px;
}
.btn-action {
  width: 80px; height: 80px;
  border-radius: 50%; font-size: 1.2rem; font-weight: bold; border: none; cursor: pointer;
  display: flex; justify-content: center; align-items: center;
  box-shadow: 0 8px 20px rgba(0,0,0,0.4); transition: transform 0.1s;
}
.btn-action:active { transform: scale(0.9); }
.btn-reject { background: var(--color-reject); color: var(--color-text-main); }
.btn-match { background: var(--color-match); color: var(--color-text-main); }

/* OVLÁDACÍ TLAČÍTKA */
.top-controls {
  display: flex;
  gap: 15px;
}
.btn {
  padding: 12px 20px; border: none; border-radius: 8px; font-weight: 600; cursor: pointer;
}
.btn-primary { background: var(--color-button); color: var(--color-text-main); flex: 1; }
.btn-secondary { background: var(--color-secondary); color: var(--color-text-main); }

.btn-send {
  width: 42px;
  height: 42px; /* Dokonalý kruh */
  border-radius: 50%; /* Zakulacení */
  background: var(--color-4); /* Průhledné pozadí místo bílé kostky */
  color: white; /* Barva šipky z tvé palety */
  border: none;
  font-size: 1.5rem; /* Větší ikonka */
  display: flex;
  justify-content: center;
  align-items: center;
  cursor: pointer;
  transition: transform 0.2s, color 0.2s;
}

/* Hover efekt na tlačítku */
.btn-send:hover {
  transform: scale(1.1); /* Lehké zvětšení při najetí myší */
}

/* FILTRY */
.filters-panel {
  background: var(--panel-bg); border-radius: 12px; padding: 15px 20px; border: 2px solid var(--color-4);
}
.filter-header { font-weight: 600; margin-bottom: 10px; color: var(--color-4); font-size: 0.9rem;}
.filter-row { display: flex; gap: 20px; margin-bottom: 15px; }
.filter-group { flex: 1; display: flex; flex-direction: column; gap: 5px; }
.filter-group label { font-size: 0.8rem; color: #ccc; }
.range-slider { accent-color: var(--color-4); width: 100%; cursor: pointer; }
.checkbox-group label { display: flex; align-items: center; gap: 10px; cursor: pointer; font-size: 0.85rem;}

/* SEZNAM MATCHŮ */
.matches-panel {
  background: var(--panel-bg); border-radius: 12px; padding: 15px 20px; border: 2px solid var(--color-4);
  display: flex; flex-direction: column;
}
.matches-panel h2 { margin: 0 0 10px 0; font-size: 1.1rem; color: var(--color-4); }
.no-matches { color: #777; font-style: italic; font-size: 0.9rem;}
.matches-list {
  display: flex; flex-direction: column; gap: 8px;
  max-height: 160px;
  overflow-y: auto;
  padding-right: 5px;
}
.matches-list::-webkit-scrollbar, .chat-messages::-webkit-scrollbar { width: 6px; }
.matches-list::-webkit-scrollbar-thumb, .chat-messages::-webkit-scrollbar-thumb { background: var(--color-4); border-radius: 10px; }

.match-row {
  display: flex; justify-content: space-between; align-items: center;
  padding: 8px 12px; background: var(--match-row-bg); border-radius: 8px;
}
.match-row:hover { background: var(--contact-active);}
.active-match { background: var(--color-secondary) !important; }
.match-info { display: flex; align-items: center; gap: 12px; font-weight: 600; font-size: 0.9rem;}
.match-avatar-small { width: 35px; height: 35px; border-radius: 50%; object-fit: cover; }
.btn-chat-icon { background: none; border: none; font-size: 1.3rem; cursor: pointer; opacity: 0.8; }
.btn-chat-icon:hover { opacity: 1; transform: scale(1.1); }

/* CHAT PANEL */
.chat-panel {
  background: var(--panel-bg); border-radius: 12px; border: 2px solid var(--color-4);
  overflow: hidden; display: flex; flex-direction: column;
  height: 40vh; min-height: 300px; max-height: 500px;
}
.chat-interface { display: flex; flex-direction: column; height: 100%; }
.chat-header {
  padding: 12px 15px; background: var(--color-secondary); display: flex; justify-content: space-between; align-items: center;
}
.chat-header-user { display: flex; align-items: center; gap: 12px; }
.chat-avatar-medium { width: 40px; height: 40px; border-radius: 50%; object-fit: cover; }
.online-status { font-size: 0.7rem; color: var(--color-4); margin-top: 2px; }
.btn-close { background: none; border: none; color: var(--color-text-main); font-size: 1.2rem; cursor: pointer; opacity: 0.7; }
.btn-close:hover { opacity: 1; }
.chat-messages {
  flex: 1; padding: 15px; overflow-y: auto; display: flex; flex-direction: column; gap: 10px;
}
.message { padding: 10px 14px; border-radius: 12px; max-width: 80%; word-wrap: break-word; font-size: 0.9rem;}
.my-message { background: var(--color-4); align-self: flex-end; border-bottom-right-radius: 4px; }
.chat-empty { text-align: center; color: #555; margin: auto; font-size: 0.9rem;}
.chat-input-area {
  padding: 12px; background: var(--panel-bg); display: flex; gap: 10px;
}
.chat-input {
  flex: 1; padding: 10px 15px; border-radius: 20px; border: none;
  background: var(--chat-input-bg); color: var(--color-text-main); outline: none; font-size: 0.9rem;
}
.chat-placeholder {
  height: 100%; display: flex; flex-direction: column; justify-content: center; align-items: center; color: #555;
}
.chat-icon-large { font-size: 3rem; margin-bottom: 10px; opacity: 0.5; }
.empty-state { text-align: center; padding: 50px; border: 2px dashed var(--color-4); border-radius: 16px; margin-top: 20px; color:#aaa;}
.empty-title { font-size: 1.5rem; font-weight: bold; color: var(--color-4); margin-bottom: 10px;}
</style>