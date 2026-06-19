<template>
  <div class="geoguesser-page container py-5 min-vh-100">
    <div class="text-center mb-5">
      <h1 class="fw-bold" style="color: var(--color-text);">Zvířecí Geoguesser</h1>
      <p style="color: var(--color-text-muted);">Poznejte, na kterých kontinentech a místech žijí divoká zvířata</p>
    </div>

    <!-- 1. OBRAZOVKA: Nastavení -->
    <div v-if="gameState === 'setup' || gameState === 'loading_game'" class="text-center py-5">
      <div v-if="gameState === 'loading_game'" class="spinner-border mb-3" style="width: 3rem; height: 3rem; color: var(--color-primary);"></div>
      <div v-else class="card border-0 shadow-sm rounded-4 p-4 p-md-5 mx-auto text-start" style="max-width: 600px; background-color: var(--color-surface); border: 1px solid var(--color-border) !important;">
        <h2 class="h4 fw-bold mb-4 text-center" style="color: var(--color-text);">Nastavení expedice</h2>

        <div class="mb-4">
          <label class="form-label fw-bold" style="color: var(--color-text);">Kategorie zvířat</label>
          <select v-model="selectedCategory" class="form-select form-select-lg border-0 shadow-sm custom-select" style="background-color: var(--color-bg); color: var(--color-text);">
            <option value="random1">🌍 Náhodná zvířata (Top 200 nejznámějších)</option>
            <option value="random2">🧭 Náhodná zvířata (Vzácnější, Top 201 - 400)</option>
            <option value="savci">🦁 Savci</option>
            <option value="ptaci">🦅 Ptáci</option>
            <option value="plazi">🦎 Plazi</option>
            <option value="ryby">🐟 Ryby</option>
            <option value="hmyz">🦋 Hmyz</option>
          </select>
        </div>

        <div class="mb-5 p-4 rounded-4 shadow-sm" style="background-color: var(--color-bg);">
          <div class="d-flex justify-content-between align-items-center mb-2">
            <label class="form-label fw-bold mb-0" style="color: var(--color-text);">Počet kol</label>
            <span class="badge fs-6 px-3 py-2 rounded-pill" style="background-color: var(--color-primary); color: white;">{{ maxRounds }}</span>
          </div>
          <input
              type="range"
              class="form-range custom-range"
              min="1"
              max="20"
              v-model.number="maxRounds"
              id="roundsSlider"
          >
          <div class="d-flex justify-content-between small mt-1 fw-bold" style="color: var(--color-text-muted);">
            <span>1 kolo</span>
            <span>20 kol</span>
          </div>
        </div>

        <button @click="initGame" class="btn btn-lg w-100 fw-bold py-3 rounded-pill shadow-sm custom-btn">
          Odstartovat hru
        </button>
      </div>
    </div>

    <!-- 2. OBRAZOVKA: Hraní -->
    <div v-show="gameState === 'playing' || gameState === 'result'" class="row g-4">

      <!-- Levý sloupec (Zvíře) -->
      <div class="col-12 col-lg-4 d-flex flex-column">
        <!-- Skóre -->
        <div class="card border-0 shadow-sm rounded-4 p-3 mb-4 d-flex flex-row justify-content-around text-center" style="background-color: var(--color-surface); border: 1px solid var(--color-border) !important;">
          <div>
            <span class="d-block small fw-bold text-uppercase" style="color: var(--color-text-muted);">Kolo</span>
            <span class="fs-4 fw-bold" style="color: var(--color-text);">{{ round }} / {{ maxRounds }}</span>
          </div>
          <div class="vr" style="background-color: var(--color-border);"></div>
          <div>
            <span class="d-block small fw-bold text-uppercase" style="color: var(--color-text-muted);">Uhodnuto</span>
            <span class="fs-4 fw-bold" style="color: var(--color-primary);">{{ score }}</span>
          </div>
        </div>

        <!-- Zvíře Info -->
        <div class="card border-0 shadow-sm rounded-4 overflow-hidden" style="background-color: var(--color-surface); border: 1px solid var(--color-border) !important;">
          <div class="position-relative" style="height: 250px;">
            <img v-if="currentAnimal" :src="currentAnimal.imageUrl" :alt="currentAnimal.name" class="w-100 h-100 object-fit-cover" />
          </div>
          <div class="card-body p-4 text-center">
            <span class="small text-uppercase fw-bold letter-spacing-1" style="color: var(--color-text-muted);">Kde žije toto zvíře?</span>
            <h2 class="h3 fw-bold my-2" style="color: var(--color-text);">{{ currentAnimal?.name }}</h2>
            <p class="fst-italic small mb-0" style="color: var(--color-text-muted);">{{ currentAnimal?.latinName }}</p>
          </div>
        </div>

        <!-- Stav (Načítání / Výsledek kola) -->
        <div v-if="isChecking" class="text-center mt-4 p-4 card border-0 shadow-sm rounded-4" style="background-color: var(--color-bg);">
          <div class="spinner-border mb-2" style="color: var(--color-primary);" role="status"></div>
          <p class="fw-bold mb-0" style="color: var(--color-text-muted);">Ověřuji výskyt v databázi...</p>
        </div>

        <div v-else-if="gameState === 'result'" class="mt-4 animate-fade-in">
          <div class="alert border-0 shadow-sm rounded-4 p-4 text-center" :class="isHit ? 'hit-alert' : 'miss-alert'">
            <span class="display-4 d-block mb-2">{{ isHit ? '🎉 Zásah!' : '❌ Vedle!' }}</span>
            <p class="fw-bold mb-2" style="color: var(--color-text);">
              {{ isHit ? 'Skvěle! Tady se toto zvíře opravdu vyskytuje.' : 'Bohužel, v této oblasti iNaturalist toto zvíře neeviduje.' }}
            </p>
            <p class="small mb-4" style="color: var(--color-text-muted);">Zelená plocha na mapě nyní odhalila reálná místa výskytu.</p>

            <button @click="nextRound" class="btn btn-lg w-100 fw-bold rounded-pill py-2 custom-btn-secondary">
              {{ round < maxRounds ? 'Další zvíře ➔' : 'Zobrazit celkové vyhodnocení' }}
            </button>
          </div>
        </div>
      </div>

      <!-- Pravý sloupec (Mapa) -->
      <div class="col-12 col-lg-8">
        <div class="card border-0 shadow-sm rounded-4 overflow-hidden h-100" style="min-height: 500px; background-color: var(--color-surface); border: 1px solid var(--color-border) !important;">
          <div class="card-header border-0 py-3 px-4 d-flex justify-content-between align-items-center" style="background-color: var(--color-surface);">
            <span class="fw-bold" style="color: var(--color-text-muted);">
              {{ gameState === 'playing' ? '👇 Klikněte do mapy pro váš odhad' : '🗺️ Analýza rozšíření druhu' }}
            </span>
            <button @click="resetToMenu" class="btn btn-sm btn-outline-danger fw-bold rounded-pill px-3">Ukončit hru</button>
          </div>
          <div class="card-body p-0 position-relative" style="height: 550px;">
            <div id="geoMap" class="w-100 h-100" style="z-index: 1;"></div>
          </div>
        </div>
      </div>
    </div>

    <!-- 3. OBRAZOVKA: Konec hry -->
    <div v-if="gameState === 'gameover'" class="text-center py-5">
      <div class="card border-0 shadow-sm rounded-4 p-5 mx-auto text-center" style="max-width: 550px; background-color: var(--color-surface); border: 1px solid var(--color-border) !important;">
        <span class="display-1 d-block mb-4">🏆</span>
        <h2 class="fw-bold mb-3" style="color: var(--color-text);">Expedice dokončena!</h2>

        <p class="fs-5 mb-4" style="color: var(--color-text-muted);">
          Dokázali jste správně lokalizovat <strong>{{ score }} z {{ maxRounds }}</strong> zvířat v kategorii <br>
          <strong style="color: var(--color-text);">{{ currentCategoryName }}</strong>.
        </p>

        <div class="p-3 rounded-3 mb-5 small text-start" style="background-color: var(--color-bg); color: var(--color-text-muted);">
          💡 <strong>Tip pro příště:</strong> Všímejte si detailů na fotkách! Krajina, stromy nebo sníh v pozadí vám mohou napovědět, zda zvíře patří do savany, džungle nebo arktického pásma.
        </div>

        <div class="d-flex flex-column gap-3">
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
import { ref, onUnmounted, nextTick, computed } from 'vue'

useHead({ title: 'Geoguesser — Svět Zvířat' })

const { getGameAnimals, checkAnimalLocation } = useINaturalist()

type GameState = 'setup' | 'loading_game' | 'playing' | 'result' | 'gameover'
interface GeoAnimal {
  id: number
  name: string
  latinName: string
  imageUrl: string
}

const gameState = ref<GameState>('setup')

const selectedCategory = ref('random1')
const maxRounds = ref(5)

const isChecking = ref(false)
const round = ref(1)
const score = ref(0)
const animalPool = ref<GeoAnimal[]>([])
const currentAnimal = ref<GeoAnimal | null>(null)
const isHit = ref(false)

let map: any = null
let playerMarker: any = null
let resultGridLayer: any = null
let L: any = null

const currentCategoryName = computed(() => {
  const names: Record<string, string> = {
    'random1': 'Náhodná zvířata (Top 200)', 'random2': 'Náhodná zvířata (Vzácnější)',
    'savci': 'Savci', 'ptaci': 'Ptáci', 'plazi': 'Plazi', 'ryby': 'Ryby', 'hmyz': 'Hmyz'
  }
  return names[selectedCategory.value] || 'Neznámá kategorie'
})

async function initGame() {
  gameState.value = 'loading_game'
  round.value = 1
  score.value = 0
  animalPool.value = []

  try {
    const response: any = await getGameAnimals(selectedCategory.value, 'geoguesser')

    if (response && response.results) {
      animalPool.value = response.results.map((item: any) => ({
        id: item.taxon.id,
        name: item.taxon.preferred_common_name || item.taxon.name,
        latinName: item.taxon.name,
        imageUrl: item.taxon.default_photo?.medium_url || item.taxon.default_photo?.url?.replace('square', 'medium')
      })).filter((a: any) => a.imageUrl && a.name)

      if (animalPool.value.length === 0) throw new Error("Žádná data")
      setupRound()
    } else {
      throw new Error("API selhalo")
    }
  } catch (e) {
    alert('Nepodařilo se stáhnout data pro tuto kategorii. Zkuste to prosím znovu.')
    gameState.value = 'setup'
  }
}

function setupRound() {
  gameState.value = 'playing'
  isHit.value = false
  isChecking.value = false

  const randomIndex = Math.floor(Math.random() * animalPool.value.length)
  currentAnimal.value = animalPool.value[randomIndex]
  animalPool.value.splice(randomIndex, 1)

  if (map) {
    if (playerMarker) map.removeLayer(playerMarker)
    if (resultGridLayer) map.removeLayer(resultGridLayer)
    map.setView([25, 0], 1.5)
  } else {
    nextTick(async () => { await initMap() })
  }
}

async function initMap() {
  if (typeof window === 'undefined') return
  try {
    L = (await import('leaflet')).default
    await import('leaflet/dist/leaflet.css')

    map = L.map('geoMap', { center: [25, 0], zoom: 1.5, minZoom: 1, maxZoom: 7, worldCopyJump: true })
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { attribution: '&copy; OpenStreetMap' }).addTo(map)
    map.on('click', onMapClick)

    setTimeout(() => { map.invalidateSize() }, 300)
  } catch (e) { console.error('Chyba při inicializaci mapy:', e) }
}

async function onMapClick(e: any) {
  if (gameState.value !== 'playing' || !currentAnimal.value || isChecking.value) return

  const { lat, lng } = e.latlng
  if (playerMarker) map.removeLayer(playerMarker)

  playerMarker = L.circleMarker([lat, lng], { radius: 10, fillColor: '#fd7e14', color: '#fff', weight: 3, fillOpacity: 1 }).addTo(map)
  isChecking.value = true

  try {
    const checkRes: any = await checkAnimalLocation(currentAnimal.value.id, lat, lng)

    if (checkRes && checkRes.total_results > 0) {
      isHit.value = true
      score.value++
    } else {
      isHit.value = false
    }

    if (resultGridLayer) map.removeLayer(resultGridLayer)
    // Barevná vrstva z iNat přebarvená tak, aby ladila aspoň trochu s naší primární barvou
    resultGridLayer = L.tileLayer(`https://api.inaturalist.org/v1/grid/{z}/{x}/{y}.png?taxon_id=${currentAnimal.value.id}&color=%230369a1`, { opacity: 0.8 }).addTo(map)
    gameState.value = 'result'
  } catch (err) {
    alert("Chyba při ověřování lokace.")
  } finally {
    isChecking.value = false
  }
}

function nextRound() {
  if (round.value < maxRounds.value) { round.value++; setupRound() }
  else { gameState.value = 'gameover' }
}

function resetToMenu() {
  gameState.value = 'setup'
  if (map) { map.remove(); map = null }
}

onUnmounted(() => { if (map) map.remove() })
</script>

<style scoped>
.animate-fade-in {
  animation: fadeIn 0.4s ease-out forwards;
}
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}
.letter-spacing-1 {
  letter-spacing: 0.06em;
}
:deep(.leaflet-container) {
  cursor: crosshair !important;
}

/* Vlastní stylování tlačítek pomocí proměnných */
.custom-btn {
  background-color: var(--color-primary);
  color: white;
  border: none;
  transition: background-color 0.2s;
}
.custom-btn:hover {
  background-color: var(--color-primary-hover);
}

.custom-btn-secondary {
  background-color: var(--color-border-dark);
  color: white;
  border: none;
  transition: background-color 0.2s;
}
.custom-btn-secondary:hover {
  background-color: var(--color-text);
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

/* Stylování selectu */
.custom-select:focus {
  border-color: var(--color-primary);
  box-shadow: 0 0 0 0.25rem var(--color-primary-light);
}

/* Úprava slideru (range) */
.custom-range::-webkit-slider-thumb {
  background: var(--color-primary);
}
.custom-range::-moz-range-thumb {
  background: var(--color-primary);
}

/* Boxy s výsledkem kola (Zásah / Vedle) */
.hit-alert {
  background-color: var(--color-primary-light);
  border: 1px solid var(--color-primary) !important;
}
.miss-alert {
  background-color: var(--color-negative-light);
  border: 1px solid var(--color-text-negative) !important;
}
</style>