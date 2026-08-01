<template>
  <main class="project-detail">
    <!-- Kontrola, zda se data načetla -->
    <div v-if="project">
      <header class="detail-header">
        <h1>{{ project.title }}</h1>
        <p class="description">{{ project.description }}</p>
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

// Nový způsob načítání dat v Nuxt Content v3
// 'projekty' je název kolekce z content.config.ts
const { data: project } = await useAsyncData(route.path, () => {
  return queryCollection('projekty').path(route.path).first()
})
</script>

<style scoped>
.project-detail {
  max-width: 800px;
  margin: 0 auto;
  padding: 40px 20px;
  color: #cbd5e1;
}

.detail-header h1 {
  font-size: 2.5rem;
  color: #ffffff;
  text-shadow: 0 2px 10px rgba(0,0,0,0.5);
  margin-bottom: 16px;
}

.description {
  font-size: 1.1rem;
  color: #94a3b8;
  margin-bottom: 40px;
  line-height: 1.6;
}

.content-body :deep(h2) {
  color: #ffffff;
  margin-top: 40px;
  margin-bottom: 16px;
}

.content-body :deep(p) {
  line-height: 1.7;
  margin-bottom: 24px;
}

.error-page {
  text-align: center;
  padding: 100px 20px;
}

.back-link {
  color: #3b82f6;
  text-decoration: none;
  font-weight: bold;
}
</style>