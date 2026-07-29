<template>
  <article class="project-card">

    <!-- OBRÁZEK PROJEKTU -->
    <NuxtLink :to="link" class="image-link">
      <div class="image-wrapper">
        <img
            :src="image || 'https://via.placeholder.com/600x400/161b22/8b949e?text=Image_Not_Found'"
            :alt="`Náhled projektu ${title}`"
            class="project-image"
        />
      </div>
    </NuxtLink>

    <!-- TEXTOVÁ ČÁST (Dark Glassmorphism) -->
    <div class="card-body">

      <!-- HLAVIČKA -->
      <div class="card-header">
        <div>
          <h3 class="card-title">
            <NuxtLink :to="link">{{ title }}</NuxtLink>
          </h3>
        </div>
      </div>

      <p class="card-desc">{{ description }}</p>

      <!-- PATIČKA (Tech stack + Tlačítko) -->
      <div class="card-footer">

        <div class="tech-stack">
          <span v-for="tech in technologies" :key="tech" class="tech-tag">
            {{ tech }}
          </span>
        </div>

        <NuxtLink :to="link" class="action-btn">
          See more
        </NuxtLink>

      </div>
    </div>

  </article>
</template>

<script setup>
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
    default: ''
  },
  link: {
    type: String,
    default: '#'
  }
})
</script>

<style scoped>
/* HLAVNÍ OBRYS KARTY - TMAVÉ SKLO */
.project-card {
  /* Tmavě modro-černé poloprůhledné pozadí */
  background-color: rgba(15, 23, 42, 0.4);

  /* Efekt rozostření pozadí (mlhovina se pod kartou rozmaže) */
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);

  /* Jemný poloprůhledný světlý rámeček simulující odlesk hrany skla */
  border: 1px solid rgba(255, 255, 255, 0.1);

  border-radius: 24px;
  padding: 12px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3); /* Hlubší tmavý stín */
  display: flex;
  flex-direction: column;
  transition: transform 0.3s ease, box-shadow 0.3s ease, border-color 0.3s ease;
  font-family: var(--font-sans, system-ui, sans-serif);
}

.project-card:hover {
  transform: translateY(-6px);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4);
  border-color: rgba(59, 130, 246, 0.4); /* Rámeček při najetí lehce zmodrá */
}

/* OBRÁZEK */
.image-link {
  display: block;
  overflow: hidden;
  border-radius: 16px 16px 4px 4px;
}

.image-wrapper {
  position: relative;
  aspect-ratio: 16 / 9;
  width: 100%;
}

.project-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.5s ease;
}

.project-card:hover .project-image {
  transform: scale(1.03);
}

/* TEXTOVÁ ČÁST */
.card-body {
  padding: 16px 8px 8px 8px;
  display: flex;
  flex-direction: column;
  flex: 1;
}

/* HLAVIČKA */
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 12px;
}

.card-title {
  margin: 0 0 4px 0;
  font-size: 1.35rem;
  font-weight: 700;
  color: #ffffff; /* Bílý text pro nadpis */
  text-shadow: 0 2px 10px rgba(0,0,0,0.5); /* Lepší čitelnost na skle */
}

.card-title a {
  color: inherit;
  text-decoration: none;
  transition: color 0.2s ease;
}

.card-title a:hover {
  color: #60a5fa; /* Světle modrá při najetí */
}

/* POPIS */
.card-desc {
  color: #cbd5e1; /* Světle šedá/stříbrná pro popis */
  font-size: 0.9rem;
  line-height: 1.5;
  margin: 0 0 24px 0;
  flex: 1;
}

/* PATIČKA */
.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
  margin-top: auto;
}

/* TECHNOLOGIE (Pilulky pro tmavý režim) */
.tech-stack {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.tech-tag {
  font-family: var(--font-mono, monospace);
  font-size: 0.75rem;
  color: #e2e8f0; /* Velmi světle šedá */
  background: rgba(255, 255, 255, 0.1); /* Poloprůhledná bílá */
  border: 1px solid rgba(255, 255, 255, 0.05);
  padding: 4px 10px;
  border-radius: 99px;
  backdrop-filter: blur(4px);
}

/* TLAČÍTKO "SEE MORE" (Záře v temnotě) */
.action-btn {
  /* Původní modrý gradient se k vesmíru hodí perfektně */
  background: linear-gradient(135deg, #1e3a8a 0%, #3b82f6 100%);
  color: white;
  font-weight: 600;
  font-size: 0.95rem;
  text-decoration: none;
  padding: 10px 24px;
  border-radius: 99px;
  transition: transform 0.2s ease, box-shadow 0.2s ease;

  /* Přidal jsem "neonový" stín, aby tlačítko ve vesmíru svítilo */
  box-shadow: 0 4px 15px rgba(59, 130, 246, 0.4);
  flex-shrink: 0;
}

.action-btn:hover {
  transform: translateY(-2px);
  /* Silnější neonová záře při najetí */
  box-shadow: 0 6px 20px rgba(59, 130, 246, 0.6);
}
</style>