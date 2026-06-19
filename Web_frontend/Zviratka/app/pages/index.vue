<template>
  <div>
    <section class="hero-section">
      <div class="container hero-container">
        <div class="hero-text">
          <span class="hero-badge">Zvíře dne</span>
          <h1 class="hero-title">
            {{ animalOfTheDay?.preferred_common_name || animalOfTheDay?.name || 'Načítám...' }}
          </h1>
          <p class="hero-latin">
            <em>{{ animalOfTheDay?.name }}</em>
          </p>
          <p class="hero-desc" v-html="animalOfTheDayDescription"></p>
          <div class="hero-actions">
            <NuxtLink
                to="/hry"
                class="btn btn-primary"
            >
              ▶ Začít hrát
            </NuxtLink>
            <NuxtLink
                v-if="animalOfTheDaySlug"
                :to="`/katalog/${animalOfTheDaySlug}`"
                class="btn btn-secondary"
            >
              🔍 Zobrazit více
            </NuxtLink>
          </div>
        </div>

        <div class="hero-image-wrapper">
          <img
              :src="animalOfTheDay?.default_photo?.medium_url || 'https://via.placeholder.com/600'"
              :alt="animalOfTheDay?.preferred_common_name || animalOfTheDay?.name"
              class="hero-img"
          />
          <div class="status-badge">
            <span class="status-label">Ohrožení</span>
            <span class="status-value">
              <span class="status-value">{{ animalOfTheDayStatus }}</span>
            </span>
          </div>
        </div>
      </div>
    </section>

    <section class="container section-spacing">
      <h2 class="section-title">Objevujte svět zvířat</h2>
      <div class="discovery-grid">
        <div v-for="card in discoveryCards" :key="card.title" class="discovery-card">
          <div class="card-banner">
            <span class="card-banner-icon">{{ card.icon }}</span>
          </div>
          <div class="card-body">
            <h3>{{ card.title }}</h3>
            <p>{{ card.desc }}</p>
            <div class="card-footer-meta">
              <span class="meta-tag">{{ card.meta }}</span>
              <NuxtLink :to="card.to" class="card-link-btn">
                Zobrazit →
              </NuxtLink>
            </div>
          </div>
        </div>
      </div>
    </section>

    <section class="container section-spacing">
      <h2 class="section-title">Populární zvířata</h2>
      <div class="animals-grid">

        <div v-if="popularLoading" class="loading">Načítám populární zvířata...</div>

        <div v-else-if="error" class="error">Nepodařilo se načíst data: {{ error.message }}</div>

        <template v-else>
          <AnimalCard
              v-for="item in apiData?.results"
              :key="item.taxon?.id"
              :animal="{
                // TADY JE ZMĚNA:
                id: `${item.taxon?.id}-${createSlug(item.taxon?.preferred_common_name || item.taxon?.name)}`,
                name: item.taxon?.preferred_common_name || item.taxon?.name,
                latinName: item.taxon?.name,
                imageUrl: item.taxon?.default_photo?.medium_url || 'https://via.placeholder.com/400',
                animalRegion: undefined,
                conservationStatus: 'lc',
                category: 'mammal'
              } as any"
          />
        </template>

      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { ConservationStatus, CONSERVATION_LABELS } from '~/types/animal'
const { getTopPopularAnimals, getAnimalOfTheDay } = useINaturalist()

const { data: animalOfTheDay } = await useAsyncData(
    'animal-of-the-day',
    () => getAnimalOfTheDay()
)

function createSlug(text: string) {
  if (!text) return 'zvire'
  return text.toString().toLowerCase()
      .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/(^-|-$)+/g, '')
}

const animalOfTheDayStatus = computed(() => {
  if (!animalOfTheDay.value) return 'Načítám...'

  const statusMap: Record<string, ConservationStatus> = {
    'LC': ConservationStatus.Obnoven,
    'NT': ConservationStatus.Obnoven,
    'VU': ConservationStatus.Zranitelny,
    'EN': ConservationStatus.Ohrozeny,
    'CR': ConservationStatus.KritickyOhrozeny,
    'EW': ConservationStatus.KritickyOhrozeny,
    'EX': ConservationStatus.KritickyOhrozeny,
  }

  const statuses = animalOfTheDay.value.conservation_statuses
  if (!statuses || statuses.length === 0) return 'Běžný druh'

  const statusObj = statuses.find((s: any) => !s.place_id) || statuses[0]
  const code = statusObj?.status?.toUpperCase()
  const mapped = statusMap[code]

  return mapped ? CONSERVATION_LABELS[mapped] : 'Běžný druh'
})

const animalOfTheDaySlug = computed(() => {
  if (!animalOfTheDay.value) return ''
  const name = animalOfTheDay.value.preferred_common_name || animalOfTheDay.value.name
  return `${animalOfTheDay.value.id}-${createSlug(name)}`
})

const animalOfTheDayDescription = computed(() => {
  if (!animalOfTheDay.value) return 'Načítám...'
  return animalOfTheDay.value.wikipedia_summary
      || 'Pro toto zvíře zatím nemáme encyklopedický popis.'
})

// Načteme reálná data z API pro 4 populární zvířata dole
const { data: apiData, pending: popularLoading, error } = await getTopPopularAnimals()

// Karty pro sekci "Objevujte svět zvířat"
const discoveryCards = [
  {
    title: 'Atlas zvířat',
    desc: 'Prozkoumejte evoluční strom a klasifikaci všech druhů zvířat.',
    meta: '500+ druhů',
    icon: '🗺️',
    //color: '#047857',
    to: '/atlas'
  },
  {
    title: 'Katalog zvířat',
    desc: 'Prohlížejte a filtrujte zvířata podle různých kategorií.',
    meta: 'Pohodlné filtry',
    icon: '📖',
    //color: '#3b82f6',
    to: '/katalog'
  },
  {
    title: 'Hry a kvízy',
    desc: 'Otestujte své znalosti o zvířecím světě v zábavných hrách.',
    meta: '3 hry',
    icon: '🎮',
    //color: '#a855f7',
    to: '/hry'
  }
];
</script>

<style scoped>
/* Globální odsazení sekcí */
.section-spacing {
  padding-top: 32px;
  padding-bottom: 32px;
}

.section-title {
  font-size: 1.5rem;
  font-weight: 700;
  /*color: #111827;*/
  color: var(--color-text);
  margin-bottom: 1.5rem;
}

/* STYLOVÁNÍ HERO SEKCE */
.hero-section {
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-secondary) 100%);
  color: var(--color-surface);
  /*background: linear-gradient(135deg, #065f46 0%, #0ea5e9 100%);
  color: #ffffff; */
}

.hero-container {
  display: flex;
  align-items: center;
  gap: 32px;
  padding-top: 32px;
  padding-bottom: 32px;
}

.hero-text {
  flex: 1;
}

.hero-badge {
  background: rgba(255, 255, 255, 0.2);
  padding: 0.25rem 0.75rem;
  border-radius: 9999px;
  font-size: 0.85rem;
}

@media (max-width: 768px) {
  .hero-text {
    text-align: center;
  }

  .hero-badge {
    display: inline-block;
  }
}

.hero-title {
  font-size: 3rem;
  margin: 1rem 0 0.25rem 0;
  font-weight: 800;
}

.hero-latin {
  font-style: italic;
  opacity: 0.8;
  margin: 0 0 1.5rem 0;
}

.hero-desc {
  line-height: 1.6;
  opacity: 0.9;
  margin-bottom: 2rem;
}

.hero-actions {
  display: flex;
  gap: 1rem;
}

@media (max-width: 768px) {
  .hero-actions {
    justify-content: center;
    flex-wrap: wrap;
  }

  .hero-actions .btn {
    flex: 1;
    text-align: center;
    min-width: 140px;
  }
}

.btn {
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  font-weight: 600;
  border: none;
  cursor: pointer;
}

.btn-primary {
  /*background: #ffffff;
  color: #065f46;*/
  background: var(--color-surface);
  color: var(--color-primary);
}

.btn-secondary {
  /*background: rgba(255, 255, 255, 0.15);
  color: #ffffff;
  border: 1px solid rgba(255, 255, 255, 0.3);*/
  /*background: rgba(255, 255, 255, 0.15);
  color: var(--color-surface);
  border: 1px solid rgba(255, 255, 255, 0.3);*/
  background: var(--color-secondary-bg);
  color: var(--color-secondary-text);
  border: 1px solid var(--color-secondary-border);

}

.hero-image-wrapper {
  flex: 1;
  position: relative;
}

.hero-img {
  width: 100%;
  border-radius: 16px;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.2);
}

.status-badge {
  position: absolute;
  bottom: -15px;
  right: -15px;
  background: var(--color-surface);
  color: var(--color-text);
  padding: 0.5rem 1rem;
  border-radius: 12px;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
  display: flex;
  flex-direction: column;
}

@media (max-width: 768px) {
  .status-badge {
    bottom: 12px;
    right: 12px;
  }
}

.status-label {
  font-size: 0.75rem;
  /*color: #6b7280;*/
  color: var(--color-text-muted);
}

.status-value {
  font-weight: 700;
  /*color: #b45309;  Oranžovo-hnědá pro varování */
  color: var(--color-primary);
}

/* STYLOVÁNÍ SEKCE OBIEVŮ */
.discovery-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1.5rem;
}

.discovery-card {
  background: var(--color-surface);
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
}

.card-banner {
  height: 160px;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: var(--color-card-bg);
}

.card-banner-icon {
  font-size: 3rem;
}

.card-body {
  padding: 1.25rem;
}

.card-body h3 {
  margin: 0 0 0.5rem 0;
  font-size: 1.15rem;
}

.card-body p {
  /*color: #4b5563;*/
  color: var(--color-text-muted);
  font-size: 0.9rem;
  margin: 0 0 1.5rem 0;
  min-height: 40px;
}

.card-footer-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.meta-tag {
  font-size: 0.85rem;
  /*color: #059669;*/
  color: var(--color-primary);
  font-weight: 600;
}

.card-link-btn {
  display: inline-flex;
  align-items: center;
  gap: 0.25rem;
  font-size: 0.85rem;
  font-weight: 600;
  /*color: #fdfdff;*/
  color: var(--color-surface);
  text-decoration: none;
  padding: 0.4rem 0.75rem;
  border-radius: 9999px;
  /*background-color: #198653;*/
  background-color: var(--color-primary);
  transition: background-color 0.2s ease;
}

@media (hover: hover) {
  .card-link-btn:hover {
    /*background-color: #1eaf6a;*/
    background-color: var(--color-primary-hover);
  }
}

/* STYLOVÁNÍ POPULÁRNÍCH ZVÍŘAT */
.animals-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 1.5rem;
}

/* Responzivita pro menší monitory a mobily */
@media (max-width: 768px) {
  .hero-container {
    flex-direction: column;
  }
  .discovery-grid {
    grid-template-columns: 1fr;
  }
  .animals-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}
</style>