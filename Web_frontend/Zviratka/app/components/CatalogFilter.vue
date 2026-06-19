<template>
  <aside class="catalog-filter card border-0 shadow-sm p-3">
    <div class="d-flex align-items-center justify-content-between mb-3">
      <span class="catalog-filter__title">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16" class="me-2">
          <path d="M6 10.5a.5.5 0 0 1 .5-.5h3a.5.5 0 0 1 0 1h-3a.5.5 0 0 1-.5-.5zm-2-3a.5.5 0 0 1 .5-.5h7a.5.5 0 0 1 0 1h-7a.5.5 0 0 1-.5-.5zm-2-3a.5.5 0 0 1 .5-.5h11a.5.5 0 0 1 0 1h-11a.5.5 0 0 1-.5-.5z"/>
        </svg>
        Filtry
      </span>
      <button
        v-if="hasActiveFilters"
        class="btn btn-link btn-sm text-secondary p-0 text-decoration-none"
        @click="$emit('reset')"
      >
        Vymazat všechny filtry
      </button>
    </div>

    <!-- Kategorie -->
    <div class="catalog-filter__section">
      <p class="catalog-filter__section-title">Kategorie</p>
      <div
        v-for="(label, value) in CATEGORY_LABELS"
        :key="value"
        class="form-check mb-1"
      >
        <input
          :id="`cat-${value}`"
          class="form-check-input"
          type="checkbox"
          :value="value"
          :checked="localFilters.categories.includes(value as AnimalCategory)"
          @change="toggleFilter('categories', value as AnimalCategory)"
        />
        <label :for="`cat-${value}`" class="form-check-label">{{ label }}</label>
      </div>
    </div>

    <hr class="my-3" />

    <!-- Oblast výskytu -->
    <div class="catalog-filter__section">
      <p class="catalog-filter__section-title">Oblast výskytu</p>
      <div v-for="(label, value) in REGION_LABELS" :key="value" class="form-check mb-1">
        <input
          :id="`hab-${value}`"
          class="form-check-input"
          type="checkbox"
          :value="value"
          :checked="localFilters.animalRegions.includes(value as AnimalRegion)"
          @change="toggleFilter('animalRegions', value as AnimalRegion)"
        />
        <label :for="`hab-${value}`" class="form-check-label">{{ label }}</label>
      </div>
    </div>

    <hr class="my-3" />

    <!-- Stav ochrany -->
    <div class="catalog-filter__section">
      <p class="catalog-filter__section-title">Stav ochrany</p>
      <div
        v-for="(label, value) in CONSERVATION_LABELS"
        :key="value"
        class="form-check mb-1"
      >
        <input
          :id="`con-${value}`"
          class="form-check-input"
          type="checkbox"
          :value="value"
          :checked="localFilters.conservationStatuses.includes(value as ConservationStatus)"
          @change="toggleFilter('conservationStatuses', value as ConservationStatus)"
        />
        <label :for="`con-${value}`" class="form-check-label">{{ label }}</label>
      </div>
      <p class="catalog-filter__note mt-2 mb-0">
        ⚠️ Stav ochrany může být regionálně odlišný od globálního hodnocení.
      </p>

    </div>
  </aside>
</template>

<script setup lang="ts">
import { reactive, watch } from 'vue'
import type { AnimalFilters } from '~/types/animal'
import {
  AnimalCategory,
  AnimalRegion,
  ConservationStatus,
  CATEGORY_LABELS,
  REGION_LABELS,
  CONSERVATION_LABELS,
} from '~/types/animal'

const props = defineProps<{
  modelValue: AnimalFilters
  hasActiveFilters: boolean
}>()

const emit = defineEmits<{
  (e: 'update:modelValue', value: AnimalFilters): void
  (e: 'reset'): void
}>()

// Lokální kopie — emitujeme změny výše
const localFilters = reactive<AnimalFilters>({ ...props.modelValue })

watch(
  () => props.modelValue,
  (val) => Object.assign(localFilters, val),
  { deep: true },
)

function toggleFilter(
  key: 'categories' | 'animalRegions' | 'conservationStatuses',
  value: AnimalCategory | AnimalRegion | ConservationStatus,
) {
  const arr = localFilters[key] as string[]
  const idx = arr.indexOf(value)
  if (idx === -1) {
    arr.push(value)
  } else {
    arr.splice(idx, 1)
  }
  emit('update:modelValue', { ...localFilters })
}
</script>

<style scoped>
.catalog-filter {
  border-radius: 1rem !important;
  background-color: var(--color-surface);
  position: sticky;
  top: 94px;
}

.catalog-filter__title {
  font-weight: 700;
  font-size: 1rem;
  color: var(--color-text);
  display: flex;
  align-items: center;
}

.catalog-filter__section-title {
  font-weight: 600;
  font-size: 0.85rem;
  color: var(--color-text-muted);
  margin-bottom: 0.5rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.form-check-label {
  font-size: 0.9rem;
  color: var(--color-text-muted);
  cursor: pointer;
}

.form-check-input:checked {
  background-color: var(--color-primary);
  border-color: var(--color-primary);
}

.catalog-filter__note {
  font-size: 0.75rem;
  color: var(--color-text-muted);
  line-height: 1.4;
}
</style>
