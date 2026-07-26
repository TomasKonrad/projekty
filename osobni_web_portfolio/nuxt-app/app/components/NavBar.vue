<!-- components/NavBar.vue -->
<template>
  <header class="navbar">
    <div class="nav-container">
      <!-- Logo / Název -->
      <div class="logo">
        <NuxtLink to="/">rysstar@portfolio:~$</NuxtLink>
      </div>

      <!-- Navigační odkazy (ve stylu souborů) -->
      <nav class="nav-links">
        <NuxtLink to="/" class="nav-link">index.html</NuxtLink>
        <NuxtLink to="/projects" class="nav-link">projekty.vue</NuxtLink>
      </nav>
    </div>
  </header>
</template>

<style scoped>
.navbar {
  background-color: var(--color-surface);
  border-bottom: 1px solid var(--color-border);
  padding: var(--space-3) var(--space-4);
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
  flex-wrap: wrap; /* Na mobilu hodí odkazy pod logo, pokud není místo */
  gap: var(--space-3);
}

.logo a {
  font-family: var(--font-mono);
  color: var(--color-accent);
  text-decoration: none;
  font-weight: 700;
  font-size: 1.1rem;
}

.nav-links {
  display: flex;
  gap: var(--space-4);
}

.nav-link {
  font-family: var(--font-mono);
  color: var(--color-text-muted);
  text-decoration: none;
  padding: var(--space-1) 0;
  transition: color 0.2s ease;
}

.nav-link:hover {
  color: var(--color-text-main);
}

/* Nuxt automaticky přidá třídu 'router-link-active' odkazu, na kterém zrovna jsi */
.router-link-active {
  color: var(--color-text-main);
  border-bottom: 2px solid var(--color-accent);
}
</style>