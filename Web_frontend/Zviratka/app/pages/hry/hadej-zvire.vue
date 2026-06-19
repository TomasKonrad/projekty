<template>
  <div class="guess-page container py-5 min-vh-100">
    <div class="text-center mb-5">
      <h1 class="fw-bold" style="color: var(--color-text);">Hádej zvíře</h1>
      <p style="color: var(--color-text-muted);">Poznejte zvíře podle postupných nápověd. Čím méně nápověd, tím více bodů!</p>
    </div>

    <!-- UKONČIT HRU (Během hraní) -->
    <div v-if="gameState === 'playing' || gameState === 'loading_round'" class="d-flex justify-content-end mb-4">
      <button @click="resetToMenu" class="btn btn-sm btn-outline-danger fw-bold rounded-pill px-3">
        Ukončit hru
      </button>
    </div>

    <!-- Nastavení / Start -->
    <div v-if="gameState === 'setup' || gameState === 'loading_game'" class="text-center py-5">
      <div v-if="gameState === 'loading_game'" class="spinner-border mb-3" style="width: 3rem; height: 3rem; color: var(--color-primary);"></div>
      <div v-else class="card border-0 shadow-sm rounded-4 p-4 p-md-5 mx-auto text-start" style="max-width: 500px; background-color: var(--color-surface); border: 1px solid var(--color-border) !important;">
        <div class="text-center">
          <span class="display-1 d-block mb-4 drop-shadow">🕵️‍♂️</span>
          <h2 class="h4 fw-bold mb-3" style="color: var(--color-text);">Jste připraveni?</h2>
          <p style="color: var(--color-text-muted);" class="small mb-4">
            Hra se skládá z 5 kol. V každém kole máte k dispozici 3 nápovědy. Za uhodnutí bez nápovědy získáte 100 bodů, každá nápověda vás stojí body.
          </p>
        </div>
        <div class="d-flex flex-column gap-3">
          <button @click="initGame" class="btn btn-lg w-100 fw-bold py-3 rounded-3 shadow-sm custom-btn">
            Začít hrát
          </button>
          <NuxtLink to="/hry" class="btn btn-lg fw-bold rounded-pill text-center custom-btn-outline">
            Zpět na výběr her
          </NuxtLink>
        </div>
      </div>
    </div>

    <!-- Hraní -->
    <div v-else-if="gameState === 'playing' || gameState === 'loading_round'" class="row justify-content-center">
      <div class="col-12 col-lg-8">

        <div class="d-flex justify-content-between align-items-center mb-4 p-3 rounded-4 shadow-sm" style="background-color: var(--color-surface); border: 1px solid var(--color-border) !important;">
          <div>
            <span class="d-block small fw-bold text-uppercase" style="color: var(--color-text-muted);">Kolo</span>
            <span class="fs-4 fw-bold" style="color: var(--color-text);">{{ round }} / 5</span>
          </div>
          <div class="text-center">
            <span class="d-block small fw-bold text-uppercase" style="color: var(--color-text-muted);">Aktuální body za kolo</span>
            <span class="fs-4 fw-bold text-success">{{ currentPoints }} b</span>
          </div>
          <div class="text-end">
            <span class="d-block small fw-bold text-uppercase" style="color: var(--color-text-muted);">Celkové skóre</span>
            <span class="fs-4 fw-bold" style="color: var(--color-primary);">{{ totalScore }}</span>
          </div>
        </div>

        <div v-if="gameState === 'loading_round'" class="text-center py-5">
          <div class="spinner-border" style="color: var(--color-primary);" role="status"></div>
          <p class="mt-3 fw-bold" style="color: var(--color-text-muted);">Připravuji hádanku...</p>
        </div>

        <div v-else>
          <div class="card border-0 shadow-sm rounded-4 mb-4 overflow-hidden" style="background-color: var(--color-surface); border: 1px solid var(--color-border) !important;">

            <!-- ROZMAZANÁ FOTKA:
                 Z tagu <img> níže jsem úplně odstranila původní dynamickou třídu ':class="blur-img"',
                 která fotku nechávala nečitelnou i po kliknutí na její odhalení. Teď se po změně stavu
                 ukáže 100% čistý obrázek přirozeně zarovnaný přes 'object-fit-contain'. -->
            <div class="position-relative bg-dark d-flex align-items-center justify-content-center" style="height: 350px;">
              <img
                  v-if="isHint3Revealed || showResult"
                  :src="targetAnimal?.imageUrl"
                  class="w-100 h-100 object-fit-contain animate-fade-in"
              />
              <div v-else class="text-white text-center opacity-50">
                <span class="display-3 d-block mb-2">📸</span>
                <p class="fw-bold text-uppercase tracking-widest">Fotografie skryta</p>
              </div>
            </div>

            <div class="card-body p-4 p-md-5">
              <div class="mb-4">
                <h3 class="h6 fw-bold text-uppercase mb-2" style="color: var(--color-text-muted);">Nápověda 1: Zařazení</h3>
                <div class="d-flex gap-2 flex-wrap">
                  <span class="badge border px-3 py-2 fs-6" style="background-color: var(--color-bg); color: var(--color-text);">Kategorie: {{ targetAnimal?.categoryLabel }}</span>
                  <span v-if="targetAnimal?.family" class="badge border px-3 py-2 fs-6" style="background-color: var(--color-bg); color: var(--color-text);">Čeleď: {{ targetAnimal?.family }}</span>
                </div>
              </div>

              <!-- OTEVÍRÁNÍ VŠEH NÁPOVED NARÁZ:
                   Místo původní číselné osy (např. 'hintsRevealed >= 2') jsem stav rozdělila
                   do dvou nezávislých flagů. Kliknutí na toto tlačítko odhalí ČISTĚ JEN text
                   z Wikipedie a neovlivní stav skryté fotografie. -->
              <div class="mb-4">
                <div class="d-flex justify-content-between align-items-center mb-2">
                  <h3 class="h6 fw-bold text-uppercase mb-0" style="color: var(--color-text-muted);">Nápověda 2: Encyklopedie</h3>
                  <button v-if="!isHint2Revealed && !showResult" @click="revealHint(2)" class="btn btn-sm fw-bold px-3 custom-btn">
                    Odkrýt text (-30 bodů)
                  </button>
                  <span v-else-if="isHint2Revealed && !showResult" class="badge py-2 px-3 fs-6 rounded-3" style="background-color: var(--color-primary-light); color: var(--color-primary);">Odhaleno</span>
                </div>
                <div v-if="isHint2Revealed || showResult" class="p-3 rounded-3 animate-fade-in fst-italic lh-lg wiki-text" style="background-color: var(--color-bg); color: var(--color-text);" v-html="censoredWikiText"></div>
                <div v-else class="p-3 rounded-3 text-center blur-text py-4" style="background-color: var(--color-bg); color: var(--color-text-muted);">
                  Tento text obsahuje detailní popis zvířete z Wikipedie.
                </div>
              </div>

              <!-- Kliknutí sem aktivuje pouze samostatný příznak 'isHint3Revealed' určený pro fotografii. -->
              <div>
                <div class="d-flex justify-content-between align-items-center">
                  <h3 class="h6 fw-bold text-uppercase mb-0" style="color: var(--color-text-muted);">Nápověda 3: Fotografie</h3>
                  <button v-if="!isHint3Revealed && !showResult" @click="revealHint(3)" class="btn btn-sm fw-bold px-3 custom-btn">
                    Odkrýt fotku (-40 bodů)
                  </button>
                  <span v-else class="badge py-2 px-3 fs-6 rounded-3" style="background-color: var(--color-primary-light); color: var(--color-primary);">Odhaleno</span>
                </div>
              </div>
            </div>
          </div>

          <h4 class="fw-bold mb-3 text-center" style="color: var(--color-text);">Které je to zvíře?</h4>
          <div class="row g-3">
            <div v-for="option in options" :key="option.id" class="col-12 col-md-6">

              <!-- Původní řešení míchalo statické a dynamické třídy Bootstrapu dohromady, což na konci
                   kola spojilo bílé pozadí a bílý text (text byl nečitelný). Kompletně jsem to přepsala
                   do čistého reaktivního větvení. Před kliknutím držíme tmavý outline. Po vyhodnocení
                   se třída 'bg-white' odstraní a nahradí ji plnohodnotné 'btn-success' nebo 'btn-danger'. -->
              <button
                  @click="checkAnswer(option)"
                  class="btn w-100 py-3 fw-bold fs-5 border-2 shadow-sm btn-hover-scale"
                  :class="[
                    showResult
                      ? (option.id === targetAnimal?.id
                          ? 'btn-success text-white border-success'
                          : (selectedOption?.id === option.id ? 'btn-danger text-white border-danger' : 'btn-light opacity-50 text-dark border-light'))
                      : 'btn-outline-dark bg-white text-dark'
                  ]"
                  :disabled="showResult"
              >
                {{ option.name }}
              </button>
            </div>
          </div>

          <div v-if="showResult" class="text-center mt-5 animate-fade-in">
            <p class="fs-5 fw-bold mb-3" :class="isCorrect ? 'text-success' : 'text-danger'">
              {{ isCorrect ? `Správně! Získáváš ${currentPoints} bodů.` : `Špatně! Správná odpověď byla ${targetAnimal?.name}.` }}
            </p>
            <button @click="nextRound" class="btn btn-lg px-5 rounded-pill fw-bold shadow custom-btn">
              {{ round < 5 ? 'Pokračovat na další kolo ➔' : 'Zobrazit výsledek hry' }}
            </button>
          </div>

        </div>
      </div>
    </div>

    <!-- Konec hry -->
    <div v-if="gameState === 'gameover'" class="text-center py-5">
      <div class="card border-0 shadow-sm rounded-4 p-5 mx-auto text-center" style="max-width: 550px; background-color: var(--color-surface); border: 1px solid var(--color-border) !important;">
        <span class="display-1 d-block mb-4">🏆</span>
        <h2 class="fw-bold mb-3" style="color: var(--color-text);">Hra dokončena!</h2>

        <p class="mb-1 text-uppercase fw-bold small" style="color: var(--color-text-muted);">Vaše celkové skóre</p>
        <p class="display-3 fw-bold mb-4" style="color: var(--color-primary);">{{ totalScore }} <span class="fs-4" style="color: var(--color-text-muted);">bodů</span></p>

        <p class="mb-4" style="color: var(--color-text-muted);">
          {{ totalScore >= 400 ? 'Fantastický výsledek! Jste opravdový znalec zvířat.' : 'Dobrá práce! Svět fauny je obrovský a vy jste na dobré cestě ho poznat.' }}
        </p>

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
import { ref } from 'vue'

useHead({ title: 'Hádej zvíře — Svět Zvířat' })

const { getGameAnimals, getAnimalDetailById } = useINaturalist()

type GameState = 'setup' | 'loading_game' | 'loading_round' | 'playing' | 'gameover'
interface QuizAnimal {
  id: number
  name: string
  latinName: string
  imageUrl: string
  category: string
  categoryLabel: string
  family?: string
}

const gameState = ref<GameState>('setup')
const round = ref(1)
const totalScore = ref(0)
const currentPoints = ref(100)
const animalPool = ref<QuizAnimal[]>([])

const targetAnimal = ref<QuizAnimal | null>(null)
const options = ref<QuizAnimal[]>([])
const censoredWikiText = ref('')
const showResult = ref(false)
const isCorrect = ref(false)
const selectedOption = ref<QuizAnimal | null>(null)

// PROBLÉM - ARCHITEKTURA STAVŮ:
// Zrušila jsem původní lineární proměnnou 'hintsRevealed' a stav nápověd jsem kompletně
// izolovala do dvou samostatných booleovských proměnných. Tím se chování nápověd stalo plně modulární.
const isHint2Revealed = ref(false)
const isHint3Revealed = ref(false)

const CAT_LABELS: Record<string, string> = {
  'Mammalia': 'Savec', 'Aves': 'Pták', 'Reptilia': 'Plaz',
  'Actinopterygii': 'Ryba', 'Amphibia': 'Obojživelník', 'Insecta': 'Hmyz'
}

async function initGame() {
  gameState.value = 'loading_game'
  round.value = 1
  totalScore.value = 0
  animalPool.value = []

  try {
    const response: any = await getGameAnimals('random1', 'geoguesser')

    if (response && response.results) {
      animalPool.value = response.results.map((item: any) => ({
        id: item.taxon.id,
        name: item.taxon.preferred_common_name || item.taxon.name,
        latinName: item.taxon.name,
        imageUrl: item.taxon.default_photo?.medium_url || item.taxon.default_photo?.url?.replace('square', 'medium'),
        category: item.taxon.iconic_taxon_name,
        categoryLabel: CAT_LABELS[item.taxon.iconic_taxon_name] || 'Neznámá'
      })).filter((a: any) => a.imageUrl && a.name && !/[0-9]/.test(a.name))

      setupRound()
    } else {
      throw new Error()
    }
  } catch (e) {
    alert('Nepodařilo se načíst data pro hru.')
    gameState.value = 'setup'
  }
}

async function setupRound() {
  gameState.value = 'loading_round'
  // Vynulování stavu obou nezávislých nápověd před startem nového kola
  isHint2Revealed.value = false
  isHint3Revealed.value = false
  currentPoints.value = 100
  showResult.value = false
  selectedOption.value = null
  censoredWikiText.value = 'Tento text obsahuje detailní popis zvířete...'

  const shuffledPool = [...animalPool.value].sort(() => 0.5 - Math.random())
  options.value = shuffledPool.slice(0, 4)
  targetAnimal.value = options.value[0]
  animalPool.value = animalPool.value.filter(a => a.id !== targetAnimal.value?.id)
  options.value.sort(() => 0.5 - Math.random())

  try {
    const detailData: any = await getAnimalDetailById(targetAnimal.value.id.toString())
    const taxon = detailData?.results?.[0]

    if (taxon && taxon.ancestors) {
      const familyNode = taxon.ancestors.find((a: any) => a.rank === 'family')
      if (familyNode) targetAnimal.value.family = familyNode.preferred_common_name || familyNode.name
    }

    const formattedName = targetAnimal.value.name.replace(/ /g, '_')
    const wikiRes: any = await $fetch(`https://cs.wikipedia.org/w/api.php?action=query&format=json&prop=extracts&titles=${formattedName}&exintro=1&explaintext=1&utf8=1&origin=*`)
    const pages = wikiRes?.query?.pages
    if (pages) {
      const pageId = Object.keys(pages)[0]
      if (pageId !== '-1' && pages[pageId].extract) {
        let text = pages[pageId].extract
        const firstWord = targetAnimal.value.name.split(' ')[0]
        const regex = new RegExp(firstWord.slice(0, -1) + '[a-záčďéěíňóřšťúůýž]*', 'gi')
        censoredWikiText.value = text.replace(regex, '<strong>[***]</strong>')
      } else {
        censoredWikiText.value = 'K tomuto zvířeti nebyl na Wikipedii nalezen encyklopedický popis. Zkuste odhalit fotku.'
      }
    }
  } catch (e) {
    censoredWikiText.value = 'Popis se nepodařilo načíst.'
  }

  gameState.value = 'playing'
}

function revealHint(level: number) {
  if (level === 2 && !isHint2Revealed.value) {
    isHint2Revealed.value = true
    currentPoints.value -= 30
  }
  if (level === 3 && !isHint3Revealed.value) {
    isHint3Revealed.value = true
    currentPoints.value -= 40
  }
}

function checkAnswer(option: QuizAnimal) {
  selectedOption.value = option
  showResult.value = true

  isHint2Revealed.value = true
  isHint3Revealed.value = true

  if (option.id === targetAnimal.value?.id) {
    isCorrect.value = true
    totalScore.value += currentPoints.value
  } else {
    isCorrect.value = false
    currentPoints.value = 0
  }
}

function nextRound() {
  if (round.value < 5) {
    round.value++
    setupRound()
  } else {
    gameState.value = 'gameover'
  }
}

function resetToMenu() {
  gameState.value = 'setup'
}
</script>

<style scoped>
.drop-shadow { filter: drop-shadow(0 10px 15px rgba(0,0,0,0.2)); }
.tracking-widest { letter-spacing: 0.15em; }
.btn-hover-scale { transition: transform 0.2s ease, box-shadow 0.2s ease; }
.btn-hover-scale:hover:not(:disabled) { transform: translateY(-3px); box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1) !important; }
.blur-text { filter: blur(4px); user-select: none; }
.wiki-text { font-size: 1.05rem; }
.animate-fade-in { animation: fadeIn 0.4s ease-out forwards; }
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(5px); }
  to { opacity: 1; transform: translateY(0); }
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
</style>