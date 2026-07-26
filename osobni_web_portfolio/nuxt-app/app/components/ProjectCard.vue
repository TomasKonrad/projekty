<template>
  <article class="project-card">

    <!-- OBRÁZEK PROJEKTU -->
    <NuxtLink :to="link" class="image-link">
      <div class="image-wrapper">
        <!-- Zástupný obrázek, dokud nepošleš skutečnou prop 'image' -->
        <img
            :src="image || 'https://via.placeholder.com/600x400/161b22/8b949e?text=Image_Not_Found'"
            :alt="`Náhled projektu ${title}`"
            class="project-image"
        />
        <!-- Malý překryv v rohu evokující příponu souboru -->
        <span class="file-badge">{{ title.toLowerCase().replace(/\s+/g, '_') }}.exe</span>
      </div>
    </NuxtLink>

    <!-- TEXTOVÁ ČÁST -->
    <div class="card-body">
      <h3 class="card-title">
        <NuxtLink :to="link">{{ title }}</NuxtLink>
      </h3>

      <p class="card-desc">{{ description }}</p>

      <!-- SEZNAM TECHNOLOGIÍ -->
      <div class="tech-stack">
        <span v-for="tech in technologies" :key="tech" class="tech-tag">
          {{ tech }}
        </span>
      </div>

      <!-- ODKAZ -->
      <NuxtLink :to="link" class="card-action">
        spustit_projekt() <span>&rarr;</span>
      </NuxtLink>
    </div>

  </article>
</template>

<script setup>
// Definice vlastností (Props), které karta přijímá zvenčí
defineProps({
  title: {
    type: String,
    required: true
  },
  description: {
    type: String,
    required: true
  },
  technologies: {
    type: Array,
    required: true
  },
  image: {
    type: String,
    default: '' // Není povinný, máme fallback
  },
  link: {
    type: String,
    default: '#' // Zatím odkaz nikam
  }
})
</script>

<style scoped>
/* HLAVNÍ OBRYS KARTY */
.project-card {
  background-color: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  overflow: hidden; /* Aby obrázek nepřetekl přes zakulacené rohy */
  display: flex;
  flex-direction: column;
  transition: transform 0.2s ease, border-color 0.2s ease;
}

.project-card:hover {
  border-color: var(--color-accent);
  transform: translateY(-4px); /* Efekt mírného nadzvednutí při najetí myší */
}

/* OBRÁZEK */
.image-link {
  display: block;
  overflow: hidden;
  border-bottom: 1px solid var(--color-border);
}

.image-wrapper {
  position: relative;
  aspect-ratio: 16 / 9; /* Vynutí poměr stran 16:9 pro všechny obrázky */
  width: 100%;
}

.project-image {
  width: 100%;
  height: 100%;
  object-fit: cover; /* Obrázek vyplní obdélník a neořízne se zdeformovaně */
  transition: transform 0.4s ease;
}

/* Efekt přiblížení obrázku po najetí myší na kartu */
.project-card:hover .project-image {
  transform: scale(1.05);
}

/* Malý štítek přes obrázek */
.file-badge {
  position: absolute;
  bottom: var(--space-2);
  right: var(--space-2);
  background-color: rgba(13, 17, 23, 0.85); /* Poloprůhledné pozadí */
  color: var(--color-text-muted);
  font-family: var(--font-mono);
  font-size: 0.7rem;
  padding: 2px 6px;
  border-radius: var(--radius-sm);
  border: 1px solid var(--color-border);
  backdrop-filter: blur(4px);
}

/* TEXTOVÁ ČÁST */
.card-body {
  padding: var(--space-4);
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
  flex: 1; /* Roztáhne se na max výšku v gridu */
}

.card-title {
  margin: 0;
  font-size: 1.25rem;
}

.card-title a {
  color: var(--color-text-main);
  text-decoration: none;
  font-family: var(--font-mono);
}

.card-title a:hover {
  color: var(--color-accent);
}

.card-desc {
  color: var(--color-text-muted);
  font-size: 0.95rem;
  line-height: 1.5;
  margin: 0;
  flex: 1; /* Odtlačí technologie a odkaz dolů */
}

/* TECHNOLOGIE */
.tech-stack {
  display: flex;
  flex-wrap: wrap;
  gap: var(--space-2);
  margin-top: var(--space-2);
}

.tech-tag {
  font-family: var(--font-mono);
  font-size: 0.75rem;
  color: var(--color-text-main);
  background: var(--color-bg);
  border: 1px solid var(--color-border);
  padding: 4px 8px;
  border-radius: var(--radius-sm);
}

/* AKČNÍ ODKAZ */
.card-action {
  font-family: var(--font-mono);
  color: var(--color-accent);
  text-decoration: none;
  font-size: 0.9rem;
  align-self: flex-start;
  margin-top: var(--space-2);
  display: flex;
  align-items: center;
  gap: 4px;
}

.card-action span {
  transition: transform 0.2s ease;
}

.project-card:hover .card-action span {
  transform: translateX(4px); /* Šipka popojede doprava */
}
</style>