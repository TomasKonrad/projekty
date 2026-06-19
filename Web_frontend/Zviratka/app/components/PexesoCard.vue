<template>
  <div
      class="pexeso-card"
      :class="{
      'is-flipped': card.isFlipped || card.isMatched,
      'is-solved': card.isSolved
    }"
      @click="$emit('flip', card)"
  >
    <div class="card-face card-front d-flex align-items-center justify-content-center rounded-3 shadow-sm">
      <span class="fs-1 opacity-50">🐾</span>
    </div>
    <div class="card-face card-back rounded-3 shadow-sm">
      <img :src="card.imageUrl" :alt="card.name" class="card-img" />
      <div class="card-name text-truncate px-1">{{ card.name }}</div>
    </div>
  </div>
</template>

<script setup lang="ts">
// Definujeme, jak má karta vypadat, aby nám to IDE hezky napovídalo
interface PexesoCardType {
  uniqueId: number
  animalId: number
  name: string
  imageUrl: string
  isFlipped: boolean
  isMatched: boolean
  isSolved: boolean
}

// Přijímáme data z hlavní hry
defineProps<{
  card: PexesoCardType
}>()

// Posíláme info nahoru, když na kartu hráč klikne
defineEmits(['flip'])
</script>

<style scoped>
/* Přesunuté styly jen pro kartu */
.pexeso-card {
  aspect-ratio: 1 / 1;
  position: relative;
  transform-style: preserve-3d;
  transition: transform 0.6s cubic-bezier(0.4, 0.2, 0.2, 1), opacity 0.5s ease, visibility 0.5s;
  cursor: pointer;
}
.pexeso-card.is-flipped { transform: rotateY(180deg); }
.pexeso-card.is-solved { opacity: 0; visibility: hidden; }

.card-face {
  position: absolute;
  width: 100%;
  height: 100%;
  backface-visibility: hidden;
  overflow: hidden;
}

.card-front {
  background: linear-gradient(
      135deg,
      var(--color-primary),
      var(--color-secondary)
  );
  border: 3px solid var(--color-border-dark);
}

@media (hover: hover) {
  .card-front:hover {
    background: linear-gradient(
        135deg,
        var(--color-secondary),
        var(--color-primary)
    );
  }
}

.card-back {
  background-color: var(--color-surface);
  transform: rotateY(180deg);
  border: 3px solid var(--color-border-dark);
}
.card-img { width: 100%; height: 100%; object-fit: cover; }

.card-name {
  position: absolute;
  bottom: 0; left: 0; width: 100%;
  background: rgba(0, 0, 0, 0.7);
  color: var(--color-surface);
  font-size: 0.7rem;
  padding: 4px;
  text-align: center;
}
</style>