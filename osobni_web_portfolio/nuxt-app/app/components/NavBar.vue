<template>
  <header class="navbar">
    <div class="nav-container">
      <div class="logo">
        <NuxtLink to="/">Rysstar</NuxtLink>
      </div>

      <nav class="nav-links">
        <NuxtLink to="/#projekty" class="nav-link">projekty</NuxtLink>
        <NuxtLink to="/#kontakt" class="nav-link">kontakt</NuxtLink>
      </nav>
    </div>
  </header>
</template>

<script setup lang="ts">
</script>

<style scoped>
.navbar {
  background-color: var(--color-bg-navbar);
  padding: 4px 24px;
  position: sticky;
  top: 0;
  z-index: 100;
}

.nav-container {
  max-width: 1200px;
  margin: 0 auto;
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 16px;
}

/* LOGO */
.logo a {
  color: var(--color-text-navbar);
  text-decoration: none;
  font-family: 'Bitcount Prop Single', sans-serif;
  font-size: 3rem;
  font-weight: 300;
  transition: all 0.3s ease;
}

.logo a:hover {
  color: var(--color-accent-hover);
}

.nav-links {
  display: flex;
  gap: 32px;
}

.nav-link {
  color: var(--color-text-navbar);
  text-decoration: none;
  padding: 4px 0;
  font-size: 0.95rem;
  transition: all 0.2s ease;
  border-bottom: 2px solid transparent;
}

.nav-link:hover {
  color: var(--color-accent-hover);
}
</style>