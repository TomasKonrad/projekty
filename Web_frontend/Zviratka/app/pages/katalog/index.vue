<template>
  <div class="katalog-page container-fluid py-4 px-4">

    <!-- Nadpis -->
    <div class="mb-4">
      <h1 class="katalog-page__title">Katalog zvířat</h1>
      <p class="text-muted">Najděte zvířata, která vás zajímají podle kategorií a vlastností</p>
    </div>

    <div class="row g-4">

      <!-- 1. Searchbar + tlačítko — přes celou šířku na mobilu, odsazený na desktopu -->
      <div class="col-12 col-lg-9 offset-lg-3">
        <div class="d-flex gap-2">
          <div class="input-group katalog-page__search flex-grow-1">
            <span class="input-group-text bg-white border-end-0">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="#9ca3af" viewBox="0 0 16 16">
                <path d="M11.742 10.344a6.5 6.5 0 1 0-1.397 1.398h-.001q.044.06.098.115l3.85 3.85a1 1 0 0 0 1.415-1.414l-3.85-3.85a1 1 0 0 0-.115-.099zm-5.242 1.156a5.5 5.5 0 1 1 0-11 5.5 5.5 0 0 1 0 11"/>
              </svg>
            </span>
            <input
                v-model="searchQuery"
                type="text"
                class="form-control border-start-0 ps-0"
                placeholder="Hledat podle názvu nebo latinského jména..."
                @input="onSearchInput"
            />
          </div>

          <button
              class="katalog-page__filter-btn btn d-lg-none"
              :class="store.hasActiveFilters ? 'filter-btn--active' : 'filter-btn--inactive'"
              @click="showMobileFilter = !showMobileFilter"
          >
            Filtry
            <span v-if="activeFiltersCount > 0" class="badge bg-white text-dark ms-1">
              {{ activeFiltersCount }}
            </span>
          </button>
        </div>
      </div>

      <!-- 2. Filtr — na mobilu pod searchbarem, na desktopu vlevo -->
      <div
          :class="[
          'col-12 col-lg-3',
          'd-lg-block',
          showMobileFilter ? 'd-block' : 'd-none',
        ]"
      >
        <CatalogFilter
            v-model="filters"
            :has-active-filters="store.hasActiveFilters"
            @reset="onReset"
        />
      </div>

      <!-- 3. Výsledky — na mobilu pod filtrem, na desktopu vpravo -->
      <div class="col-12 col-lg-9">
        <p class="katalog-page__count mb-3">
    <span v-if="filters.animalRegions.length > 1">
      Načteno zvířat: <strong>{{ totalResults }}</strong>
      <span class="text-muted small"> (kombinace více oblastí)</span>
    </span>
          <span v-else>Nalezeno zvířat: <strong>{{ totalResults.toLocaleString('cs-CZ') }}</strong>
    </span>
        </p>
        <!--Spinner pro první načítání -->
        <div v-if="(isLoading && currentPage === 1) || isInitialLoad" class="text-center py-5">
          <div class="spinner-border katalog-spinner" role="status">
            <span class="visually-hidden">Načítání...</span>
          </div>
          <p class="mt-3 text-muted">Hledám zvířata v databázi…</p>
        </div>

        <!-- Chyba -->
        <div v-else-if="apiError" class="alert alert-danger" role="alert">
          <strong>Chyba:</strong> {{ apiError.message }}
        </div>

        <!-- Karty — zobrazí se vždy když data existují, i během načítání další stránky -->
        <div v-if="apiAnimals?.length" class="row row-cols-1 row-cols-md-2 row-cols-xl-3 g-4">
          <div v-for="animal in apiAnimals" :key="animal.id" class="col">
            <AnimalCard :animal="animal" />
          </div>
        </div>

        <!-- Prázdný stav -->
        <div v-else-if="!isLoading && hasSearched" class="text-center py-5">
          <p class="text-muted fs-5">🐾 Žádná zvířata nevyhovují vašemu hledání.</p>
        </div>

        <!-- Tlačítko nebo spinner pro další stránku -->
        <div class="text-center mt-4 mb-2">
          <div v-if="isLoading && currentPage > 1">
            <div class="spinner-border spinner-border-sm katalog-spinner" role="status">
              <span class="visually-hidden">Načítání...</span>
            </div>
          </div>
          <button
              v-else-if="hasMore && apiAnimals?.length"
              class="btn katalog-load-more px-5"
              @click="loadMore"
          >
            Načíst další zvířata
          </button>
        </div>

      </div>

    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch, computed } from 'vue'
import { useAnimalsStore } from '~/stores/animals'
import type { AnimalFilters, Animal } from '~/types/animal'

useHead({ title: 'Katalog zvířat — Svět Zvířat' })

const store = useAnimalsStore()
const { getCatalogAnimals } = useINaturalist()

const filters = ref<AnimalFilters>(JSON.parse(JSON.stringify(store.filters)))
const searchQuery = ref(store.filters.search)

const showMobileFilter = ref(false)
const activeFiltersCount = computed(
    () => filters.value.categories.length + filters.value.animalRegions.length + filters.value.conservationStatuses.length
)

// --- POMOCNÁ FUNKCE PRO HEZKÉ URL ---
function createSlug(text: string) {
  if (!text) return 'zvire'
  return text.toString().toLowerCase()
      .normalize('NFD').replace(/[\u0300-\u036f]/g, '') // Odstraní diakritiku
      .replace(/[^a-z0-9]+/g, '-') // Znaky a mezery nahradí pomlčkou
      .replace(/(^-|-$)+/g, '') // Ořízne okraje
}

const currentPage = ref(1)
const hasMore = ref(true)
const totalResults = ref(0)
const hasSearched = ref(false)
const isInitialLoad = ref(true)

const { data: apiAnimals, pending: isLoading, error: apiError, refresh } = await useAsyncData<Animal[]>(
    'katalog-animals',
    async (): Promise<Animal[]> => {
      try {
        const data: any = await getCatalogAnimals(
            searchQuery.value,
            filters.value.categories,
            filters.value.animalRegions,
            filters.value.conservationStatuses,
            currentPage.value
        )

        if (data && data.results) {
          totalResults.value = data.total_results ?? 0
          hasSearched.value = true
          isInitialLoad.value = false
          const mapped: Animal[] = data.results.map((item: any) => {
            const czName = item.taxon.preferred_common_name || item.taxon.name
            return {
              id: `${item.taxon.id}-${createSlug(czName)}`,
              name: czName,
              latinName: item.taxon.name,
              imageUrl: item.taxon.default_photo?.medium_url || 'https://via.placeholder.com/400',
              animalRegion: undefined,
              conservationStatus: 'lc',
              category: 'mammal'
            }
          })

          // FIX: Tady byla natvrdo zadrátovaná (zaheadkodovaná) stará kontrola:hasMore.value = data.results.length === 15
          hasMore.value = (currentPage.value * 30) < (data.total_results ?? 0)

          // První stránka = nová data, další stránky = přidej k existujícím
          if (currentPage.value === 1) {
            return mapped
          } else {
            return [...(apiAnimals.value ?? []), ...mapped]
          }
        }
        return []
      } catch (e) {
        throw new Error("Nepodařilo se spojit se serverem iNaturalist.")
      }
    },
    { default: (): Animal[] => [],
      server: false
    }
)

async function loadMore() {
  currentPage.value++
  await refresh()
}

let searchTimer: ReturnType<typeof setTimeout>
function onSearchInput() {
  clearTimeout(searchTimer)
  searchTimer = setTimeout(async () => {
    currentPage.value = 1
    hasMore.value = true
    store.setFilters({ search: searchQuery.value })
    await refresh()
  }, 500)
}

function onReset() {
  currentPage.value = 1
  hasMore.value = true
  hasSearched.value = false
  store.resetFilters()
  filters.value = { categories: [], animalRegions: [], conservationStatuses: [], search: '' }
  searchQuery.value = ''
  showMobileFilter.value = false
  refresh()
}

watch(
    filters,
    async (newVal) => {
      currentPage.value = 1
      hasMore.value = true
      store.setFilters({
        search: newVal.search,
        categories: newVal.categories,
        animalRegions: newVal.animalRegions,
        conservationStatuses: newVal.conservationStatuses,
      })
      await refresh()
    },
    { deep: true }
)
</script>

<style scoped>
.katalog-page__title {
  font-size: 2rem;
  font-weight: 800;
  color: var(--color-text);
}

.katalog-page__search .form-control, .katalog-page__search .input-group-text {
  border-color: var(--color-border);
  border-radius: 0.75rem;
  background-color: var(--color-surface);
}

.katalog-page__search .input-group-text {
  border-right: none;
  border-top-right-radius: 0;
  border-bottom-right-radius: 0;
}

.katalog-page__search .form-control {
  border-left: none;
  border-top-left-radius: 0;
  border-bottom-left-radius: 0;
  box-shadow: none;
}

.katalog-page__search .form-control:focus {
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px var(--color-primary-light);
}

.katalog-page__count {
  font-size: 0.9rem;
  color: var(--color-text-muted);
}

.katalog-page__filter-btn {
  white-space: nowrap;
  border-radius: 0.75rem;
  height: 42px;
  padding: 0 1rem;
}

.katalog-load-more {
  border: 2px solid var(--color-primary);
  color: var(--color-primary);
  background-color: transparent;
  border-radius: 0.75rem;
  transition: all 0.2s ease;
}

@media (hover: hover) {
  .katalog-load-more:hover {
    background-color: var(--color-primary);
    color: var(--color-surface);
  }
}

.katalog-spinner {
  color: var(--color-primary);
}

.filter-btn--inactive {
  border: 1px solid var(--color-border);
  color: var(--color-text-muted);
  background-color: var(--color-surface);
}

.filter-btn--active {
  border: 1px solid var(--color-primary);
  color: var(--color-surface);
  background-color: var(--color-primary);
}

@media (hover: hover) {
  .filter-btn--inactive:hover {
    background-color: var(--color-primary-light);
    color: var(--color-primary);
    border-color: var(--color-primary);
  }

  .filter-btn--active:hover {
    background-color: var(--color-primary-hover);
  }
}
</style>