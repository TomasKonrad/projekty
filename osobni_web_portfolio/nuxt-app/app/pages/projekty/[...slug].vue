<template>
  <main class="project-detail">
    <div v-if="project">
      <header class="detail-header">
        <h1>{{ project.title }}</h1>
        <p class="description">{{ project.description }}</p>
        <a
            v-if="project.meta.github"
            :href="project.meta.github"
            target="_blank"
            class="github-text-link"
        >
          Zdrojový kód projektu (GitHub) &rarr;
        </a>
      </header>

      <div class="content-body">
        <!-- Zobrazení samotného textu z Markdownu -->
        <ContentRenderer :value="project" />
      </div>
    </div>

    <!-- Pokud uživatel zadá špatnou URL -->
    <div v-else class="error-page">
      <h2>Projekt nebyl nalezen</h2>
      <NuxtLink to="/#projekty" class="back-link">Zpět na projekty</NuxtLink>
    </div>
  </main>
</template>

<script setup>
import { useRoute } from 'vue-router'

const route = useRoute()

const { data: project } = await useAsyncData(route.path, () => {
  return queryCollection('projekty').path(route.path).first()
})
</script>

<style scoped>
.project-detail {
  max-width: 800px;
  margin: 0 auto;
  padding: 40px 20px;
}

.detail-header h1 {
  color: var(--color-text-main);
}

.description {
  font-size: 1.1rem;
  color: var(--color-text-main);
}

/* STYL PRO TEXTOVÝ ODKAZ NA GITHUB */
.github-text-link {
  display: inline-block;
  color: var(--color-accent); /* Tvá modrá barva */
  font-size: 0.95rem;
  font-weight: 600;
  text-decoration: none;
  border-bottom: 1px solid transparent;
  transition: all 0.2s ease;
}

.github-text-link:hover {
  color: var(--color-accent-hover);
  border-bottom: 1px solid var(--color-accent-hover);
  transform: translateX(4px);
}

.content-body {
  margin-top: 16px;
  margin-bottom: 16px;
}

.error-page {
  text-align: center;
  padding: 100px 20px;
}

.back-link {
  color: var(--color-accent-hover);
  text-decoration: none;
  font-weight: bold;
}
</style>