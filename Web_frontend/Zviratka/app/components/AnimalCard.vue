<template>
    <NuxtLink v-if="animal" :to="`/katalog/${animal.id}`" class="animal-card-link">
    <div class="animal-card card h-100 border-0 shadow-sm">
      <div class="animal-card__image-wrapper">
        <img
          :src="animal.imageUrl"
          :alt="animal.name"
          class="animal-card__image card-img-top"
          loading="lazy"
        />
      </div>

      <div class="card-body d-flex flex-column gap-1 p-3">
        <h5 class="animal-card__name card-title mb-0">{{ animal.name }}</h5>
        <p class="animal-card__latin text-muted mb-0">
          <em>{{ animal.latinName }}</em>
        </p>

        <div class="d-flex align-items-center justify-content-between mt-auto pt-2">
          <span v-if="animal.animalRegion" class="animal-card__habitat text-secondary small">
            {{ REGION_LABELS[animal.animalRegion as AnimalRegion] || '' }}
          </span>
          <span :class="['badge', 'animal-card__badge', CONSERVATION_BADGE_CLASS[animal.conservationStatus]]">
            {{ CONSERVATION_LABELS[animal.conservationStatus] }}
          </span>
        </div>
      </div>
    </div>
  </NuxtLink>
</template>

<script setup lang="ts">
import type { Animal } from '~/types/animal'
import {
  AnimalRegion,
  REGION_LABELS,
  CONSERVATION_LABELS,
  CONSERVATION_BADGE_CLASS,
} from '~/types/animal'

defineProps<{
  animal: Animal
}>()
</script>

<style scoped>
.animal-card-link {
  text-decoration: none;
  color: inherit;
  display: block;
}

.animal-card {
  border-radius: 1rem;
  overflow: hidden;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
  cursor: pointer;
  background-color: #fff;
}

@media (hover: hover) {
  .animal-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12) !important;
  }

  .animal-card:hover .animal-card__image {
    transform: scale(1.04);
  }
}

.animal-card__image-wrapper {
  aspect-ratio: 4/3;
  overflow: hidden;
  background-color: #e5e7eb;
}

.animal-card__image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s ease;
}

.animal-card:hover .animal-card__image {
  transform: scale(1.04);
}

.animal-card__name {
  font-size: 1.05rem;
  font-weight: 700;
  color: #1a1a1a;
}

.animal-card__latin {
  font-size: 0.85rem;
}

/* Stavy ochrany — badge barvy */
.badge-success {
  background-color: #d1fae5;
  color: #065f46;
}

.badge-warning {
  background-color: #fef3c7;
  color: #92400e;
}

.badge-danger {
  background-color: #fee2e2;
  color: #991b1b;
}

.badge-dark-danger {
  background-color: #991b1b;
  color: #fff;
}
</style>
