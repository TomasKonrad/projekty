<template>
  <article class="project-card">

    <!-- OBRÁZEK PROJEKTU (Nyní zaoblený uvnitř) -->
    <NuxtLink :to="link" class="image-link">
      <div class="image-wrapper">
        <img
            :src="image || 'https://via.placeholder.com/600x400/161b22/8b949e?text=Image_Not_Found'"
            :alt="`Náhled projektu ${title}`"
            class="project-image"
        />
      </div>
    </NuxtLink>

    <!-- TEXTOVÁ ČÁST (Bílé pozadí) -->
    <div class="card-body">

      <!-- HLAVIČKA S NÁZVEM -->
      <div class="card-header">
        <div>
          <h3 class="card-title">
            <NuxtLink :to="link">{{ title }}</NuxtLink>
          </h3>
        </div>
      </div>

      <p class="card-desc">{{ description }}</p>

      <!-- SPODNÍ ŘÁDEK: TECHNOLOGIE (pilulky) A TLAČÍTKO "SEE MORE" -->
      <div class="card-footer">

        <!-- Seznam technologií jako štítky (z prvního návrhu) -->
        <div class="tech-stack">
          <span v-for="tech in technologies" :key="tech" class="tech-tag">
            {{ tech }}
          </span>
        </div>

        <!-- ODKAZ JAKO VELKÉ TLAČÍTKO S GRADIENTEM -->
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
/* HLAVNÍ OBRYS KARTY */
.project-card {
  background-color: var(--color-bg);
  border-radius: 24px;
  padding: 12px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
  display: flex;
  flex-direction: column;
  transition: transform 0.3s ease, box-shadow 0.3s ease;
  font-family: var(--font-sans);
}

.project-card:hover {
  transform: translateY(-6px);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.12);
}

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
  padding: 16px 8px 8px 8px; /* Padding okolo textu */
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
  color: #1a1a1a;
}

.card-title a {
  color: inherit;
  text-decoration: none;
}

/* POPIS */
.card-desc {
  color: #666;
  font-size: 0.9rem;
  line-height: 1.5;
  margin: 0 0 24px 0;
  flex: 1;
}

/* PATIČKA (Tech stack + Tlačítko) */
.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center; /* Zarovná tlačítko a tagy na střed */
  gap: 16px;
  margin-top: auto;
}

/* TECHNOLOGIE (Jemné světlé pilulky) */
.tech-stack {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.tech-tag {
  font-family: var(--font-mono, monospace);
  font-size: 0.75rem;
  color: #666;
  background: rgba(0, 0, 0, 0.04);
  border: none;
  padding: 4px 10px;
  border-radius: 99px; /* Tvar pilulky */
}

/* TLAČÍTKO "SEE MORE" (Velká pilulka s modrým gradientem) */
.action-btn {
  /* Tmavě modrá s přechodem do světlejší modré */
  background: linear-gradient(135deg, #1e3a8a 0%, #3b82f6 100%);
  color: white;
  font-weight: 600;
  font-size: 0.95rem;
  text-decoration: none;
  padding: 10px 24px;
  border-radius: 99px; /* Tvar pilulky */
  transition: transform 0.2s ease, box-shadow 0.2s ease;
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3); /* Jemný modrý stín */
  flex-shrink: 0; /* Zaručí, že se tlačítko nezmenší, když bude hodně tagů */
}

.action-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(59, 130, 246, 0.4);
}
</style>