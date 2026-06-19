<template>
  <div class="pexeso-page container py-5 min-vh-100">
    <div class="text-center mb-5">
      <h1 class="fw-bold" style="color: var(--color-text);">
        Zvířecí Pexeso
        <span v-if="gameState !== 'setup'" class="pexeso-category-name">— {{ currentCategoryName }}</span>
      </h1>
      <p style="color: var(--color-text-muted);">Procvičte si paměť a poznávejte zvířata</p>
    </div>

    <div v-if="gameState === 'setup'" class="setup-box card border-0 shadow-sm rounded-4 mx-auto p-4 p-md-5" style="max-width: 800px; background-color: var(--color-surface); border: 1px solid var(--color-border) !important;">
      <h2 class="h4 fw-bold mb-4 text-center" style="color: var(--color-text);">Nastavení hry</h2>

      <div class="mb-4">
        <label class="form-label fw-bold" style="color: var(--color-text);">Počet hráčů</label>
        <div class="row row-cols-2 row-cols-md-4 g-2 text-center">
          <div v-for="count in [1, 2, 3, 4]" :key="'p'+count" class="col d-flex">
            <button
                :data-testid="`players-${count}`"
                @click="playerCount = count"
                :class="['btn w-100 fw-bold py-2', playerCount === count ? 'pexeso-btn--active' : 'pexeso-btn--inactive']"
            >
              <span class="d-inline d-md-none">{{ count === 1 ? '👤 1' : `👥 ${count}` }}</span>
              <span class="d-none d-md-inline">{{ count === 1 ? '👤 Hraji sám' : `👥 ${count} hráči` }}</span>
            </button>
          </div>
        </div>
      </div>

      <div class="mb-4">
        <label class="form-label fw-bold" style="color: var(--color-text);">Kategorie zvířat</label>

        <select v-model="selectedCategory" class="form-select form-select-lg custom-select" style="background-color: var(--color-bg); color: var(--color-text);" data-testid="category-select">
          <option value="popular">🌟 Nejoblíbenější celosvětově</option>
          <option value="savci">🦁 Savci</option>
          <option value="ptaci">🦅 Ptáci</option>
          <option value="plazi">🦎 Plazi</option>
          <option value="ryby">🐟 Ryby</option>
          <option value="zelvy">🐢 Želvy</option>
          <option value="selmy">🐅 Šelmy (Kočky, lvi, tygři)</option>
          <option value="motyli">🦋 Motýli</option>
          <option value="random">🔀 Náhodný mix</option>
        </select>
      </div>

      <div class="mb-5">
        <label class="form-label fw-bold" style="color: var(--color-text);">Velikost hrací plochy</label>
        <div class="d-flex gap-2 justify-content-center flex-wrap">
          <button
              v-for="count in [16, 30, 42]"
              :key="'c'+count"
              :data-testid="`cards-${count}`"
              @click="selectedCardCount = count"
              :class="['btn flex-fill', selectedCardCount === count ? 'pexeso-btn--active' : 'pexeso-btn--inactive']"
          >
            {{ count }} karet
          </button>
        </div>
      </div>

      <button @click="startGame" data-testid="start-game" class="btn btn-lg w-100 fw-bold rounded-pill shadow-sm py-3 custom-btn">
        ▶ Začít hrát
      </button>
    </div>

    <div v-else-if="gameState === 'loading'" class="text-center py-5 my-5">
      <div class="spinner-border pexeso-spinner" style="width: 3rem; height: 3rem;" role="status"></div>
      <h3 class="mt-4 fw-bold" style="color: var(--color-text);">Míchám karty...</h3>
      <p style="color: var(--color-text-muted);">Stahuji krásné fotky z iNaturalistu</p>
    </div>

    <div v-else-if="gameState === 'playing'">
      <div class="d-flex flex-wrap justify-content-center gap-3 mb-4">
        <div
            v-for="(score, index) in playerScores"
            :key="'score'+index"
            :class="[
            'player-badge px-4 py-2 rounded-pill fw-bold border transition-all d-flex align-items-center gap-2',
            currentPlayerIndex === index
              ? 'pexeso-player--active shadow scale-up'
              : 'pexeso-player--inactive opacity-75'
          ]"
        >
          <span v-if="currentPlayerIndex === index">▶</span>
          Hráč {{ index + 1 }}: <span class="fs-5">{{ score }}</span>
        </div>
      </div>

      <div class="d-flex justify-content-between align-items-center mb-4 p-3 rounded-4 shadow-sm border" style="background-color: var(--color-surface); border: 1px solid var(--color-border) !important;">
        <div v-if="playerCount === 1">
          <span class="text-muted d-block small fw-bold text-uppercase">Tahů</span>
          <span class="fs-4 fw-bold" style="color: var(--color-text);" data-testid="moves-count">{{ moves }}</span>
        </div>
        <div v-else>
          <span class="text-muted d-block small fw-bold text-uppercase">Zbývá párů</span>
          <span class="fs-4 fw-bold" style="color: var(--color-text);">{{ (selectedCardCount / 2) - matchedPairs }}</span>
        </div>

        <button @click="resetToMenu" data-testid="back-to-menu" class="btn btn-sm btn-outline-danger fw-bold rounded-pill px-3">
          Ukončit hru
        </button>
      </div>

      <div :class="['pexeso-grid', `grid-${selectedCardCount}`]" data-testid="pexeso-grid">
        <PexesoCard
            v-for="card in deck"
            :key="card.uniqueId"
            :card="card"
            @flip="flipCard"
        />
      </div>
    </div>

    <div v-if="gameState === 'won'" class="text-center py-5">
      <div class="card border-0 shadow-sm rounded-4 p-5 mx-auto text-center" style="max-width: 550px; background-color: var(--color-surface); border: 1px solid var(--color-border) !important;">
        <span class="display-1 d-block mb-4">🏆</span>
        <h2 class="fw-bold mb-3" style="color: var(--color-text);">Konec hry!</h2>

        <p class="fs-5 mb-4" style="color: var(--color-text-muted);">
          {{ winnerMessage }}
        </p>

        <div class="p-3 rounded-3 mb-5 small text-start" style="background-color: var(--color-bg); color: var(--color-text-muted);">
          💡 <strong>Věděli jste, že:</strong> Hraní paměťových her jako Pexeso pomáhá trénovat krátkodobou paměť a rozpoznávání vizuálních vzorců?
        </div>

        <div class="d-flex flex-column gap-3 mx-auto" style="max-width: 320px;">
          <button @click="resetToMenu" class="btn btn-lg fw-bold rounded-pill shadow custom-btn">
            Hrát znovu
          </button>

          <NuxtLink to="/hry" class="btn btn-lg fw-bold rounded-pill custom-btn-outline">
            Zpět na výběr her
          </NuxtLink>
        </div>
      </div>
    </div>

  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

useHead({ title: 'Pexeso — Svět Zvířat' })

const { getGameAnimals } = useINaturalist()

type GameState = 'setup' | 'loading' | 'playing' | 'won'
export interface PexesoCard {
  uniqueId: number
  animalId: number
  name: string
  imageUrl: string
  isFlipped: boolean
  isMatched: boolean
  isSolved: boolean
}

const gameState = ref<GameState>('setup')
const selectedCategory = ref('popular')
const selectedCardCount = ref(16)
const deck = ref<PexesoCard[]>([])
const flippedCards = ref<PexesoCard[]>([])
const isLocked = ref(false)

const playerCount = ref(1)
const currentPlayerIndex = ref(0)
const playerScores = ref<number[]>([0])
const moves = ref(0)
const matchedPairs = ref(0)

// EMOJI V COMPUTED MAPOVÁNÍ:
// Sjednotila jsem překladové klíče pro nadpis běžící hry. Všechny vrácené řetězce z této
// computed vlastnosti nyní obsahují shodná emoji.
const currentCategoryName = computed(() => {
  const names: Record<string, string> = {
    'popular': '🌟 Nejoblíbenější', 'savci': '🦁 Savci', 'ptaci': '🦅 Ptáci',
    'plazi': '🦎 Plazi', 'ryby': '🐟 Ryby', 'zelvy': '🐢 Želvy',
    'selmy': '🐅 Šelmy', 'motyli': '🦋 Motýli', 'random': '🔀 Náhodný mix'
  }
  return names[selectedCategory.value] || ''
})

const winnerMessage = computed(() => {
  if (playerCount.value === 1) {
    return `Našel jsi všechny páry na ${moves.value} tahů.`
  } else {
    const maxScore = Math.max(...playerScores.value)
    const winners: number[] = []
    playerScores.value.forEach((score, index) => {
      if (score === maxScore) winners.push(index + 1)
    })
    if (winners.length === 1) {
      return `Vyhrál Hráč ${winners[0]} s počtem ${maxScore} bodů!`
    } else {
      return `Remíza! Hráči ${winners.join(' a ')} mají shodně ${maxScore} bodů.`
    }
  }
})

async function startGame() {
  gameState.value = 'loading'
  moves.value = 0
  matchedPairs.value = 0
  currentPlayerIndex.value = 0
  playerScores.value = Array(playerCount.value).fill(0)
  flippedCards.value = []
  deck.value = []

  try {
    const pairsNeeded = selectedCardCount.value / 2
    const response: any = await getGameAnimals(selectedCategory.value, 'pexeso')

    if (!response || !response.results || response.results.length < pairsNeeded) {
      alert('Pro tuto kategorii není v databez dostatek zvířat.')
      gameState.value = 'setup'
      return
    }

    let pool = response.results.map((item: any) => ({
      animalId: item.taxon.id,
      name: item.taxon.preferred_common_name || item.taxon.name,
      imageUrl: item.taxon.default_photo?.medium_url || item.taxon.default_photo?.url?.replace('square', 'medium')
    })).filter((animal: any) => animal.imageUrl)

    if (selectedCategory.value === 'random') {
      pool = pool.sort(() => 0.5 - Math.random())
    }

    pool = pool.slice(0, pairsNeeded)
    const newDeck: PexesoCard[] = []

    pool.forEach((animal: any) => {
      newDeck.push({ uniqueId: Math.random(), animalId: animal.animalId, name: animal.name, imageUrl: animal.imageUrl, isFlipped: false, isMatched: false, isSolved: false })
      newDeck.push({ uniqueId: Math.random(), animalId: animal.animalId, name: animal.name, imageUrl: animal.imageUrl, isFlipped: false, isMatched: false, isSolved: false })
    })

    deck.value = newDeck.sort(() => 0.5 - Math.random())
    gameState.value = 'playing'

  } catch (error) {
    alert('Nastala chyba při načítání dat.')
    gameState.value = 'setup'
  }
}

function flipCard(card: PexesoCard) {
  if (isLocked.value || card.isFlipped || card.isMatched) return
  card.isFlipped = true
  flippedCards.value.push(card)

  if (flippedCards.value.length === 2) {
    moves.value++
    checkMatch()
  }
}

function checkMatch() {
  const card1 = flippedCards.value[0]
  const card2 = flippedCards.value[1]
  if (!card1 || !card2) return

  if (card1.animalId === card2.animalId) {
    card1.isMatched = true
    card2.isMatched = true
    matchedPairs.value++

    const idx = currentPlayerIndex.value
    if (playerScores.value[idx] !== undefined) { playerScores.value[idx]++ }
    flippedCards.value = []

    setTimeout(() => {
      card1.isSolved = true
      card2.isSolved = true
      if (matchedPairs.value === selectedCardCount.value / 2) { gameState.value = 'won' }
    }, 800)

  } else {
    isLocked.value = true
    setTimeout(() => {
      card1.isFlipped = false
      card2.isFlipped = false
      flippedCards.value = []
      currentPlayerIndex.value = (currentPlayerIndex.value + 1) % playerCount.value
      isLocked.value = false
    }, 1500)
  }
}

function resetToMenu() { gameState.value = 'setup' }
</script>

<style scoped>
.pexeso-player--active {
  background-color: var(--color-primary);
  color: white;
  border-color: var(--color-primary);
}

.pexeso-player--inactive {
  background-color: var(--color-surface);
  color: var(--color-text-muted);
  border-color: var(--color-border);
}

.pexeso-category-name {
  color: var(--color-text-muted);
}

.pexeso-spinner {
  color: var(--color-primary);
}

.pexeso-btn--active {
  background-color: var(--color-primary);
  color: white;
  border: 2px solid var(--color-primary);
}

.pexeso-btn--inactive {
  background-color: transparent;
  color: var(--color-text);
  border: 2px solid var(--color-border);
}

.pexeso-btn--inactive,
.pexeso-btn--active {
  transition: all 0.2s ease;
}

@media (hover: hover) {
  .pexeso-btn--inactive:hover {
    background-color: var(--color-primary-light);
    border-color: var(--color-primary);
    color: var(--color-primary);
  }

  .pexeso-btn--active:hover {
    background-color: var(--color-primary-hover);
    border-color: var(--color-primary-hover);
  }
}

.custom-btn {
  background-color: var(--color-primary);
  color: white;
  border: none;
  transition: background-color 0.2s;
}
.custom-btn:hover {
  background-color: var(--color-primary-hover);
  color: white;
}

.custom-btn-outline {
  background-color: transparent;
  color: var(--color-primary);
  border: 2px solid var(--color-primary);
  transition: all 0.2s;
}
.custom-btn-outline:hover {
  background-color: var(--color-primary);
  color: white;
}

.custom-select:focus {
  border-color: var(--color-primary);
  box-shadow: 0 0 0 0.25rem var(--color-primary-light);
}

.transition-all { transition: all 0.3s ease; }
.scale-up { transform: scale(1.05); }
.player-badge { min-width: 120px; justify-content: center; }

.pexeso-grid {
  display: grid;
  gap: 15px;
  perspective: 1000px;
  margin: 0 auto;
  position: relative;
}

.grid-16 { grid-template-columns: repeat(4, 1fr); max-width: 600px; }
.grid-30 { grid-template-columns: repeat(6, 1fr); max-width: 900px; }
.grid-42 { grid-template-columns: repeat(7, 1fr); max-width: 1050px; }

@media (max-width: 768px) {
  .grid-16 { grid-template-columns: repeat(4, 1fr); gap: 8px; }
  .grid-30 { grid-template-columns: repeat(5, 1fr); gap: 8px; }
  .grid-42 { grid-template-columns: repeat(6, 1fr); gap: 6px; }
}
@media (max-width: 480px) {
  .grid-30 { grid-template-columns: repeat(4, 1fr); gap: 5px; }
  .grid-42 { grid-template-columns: repeat(5, 1fr); gap: 5px; }
}
</style>