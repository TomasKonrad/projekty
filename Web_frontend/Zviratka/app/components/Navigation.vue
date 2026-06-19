<script setup lang="ts">
</script>
<template>
  <!--
    Bootstrap třída "navbar" zde koliduje s vlastní třídou,
    proto používáme "navbar" pouze jako vlastní třídu a Bootstrap
    navbar strukturu stavíme uvnitř.
  -->
  <header class="app-navbar">
    <div class="container-fluid px-4">
      <nav class="navbar navbar-expand-lg px-0">

        <!-- Logo — vždy viditelné -->
        <NuxtLink to="/" class="navbar-brand logo-text d-flex align-items-center gap-2">
          <img src="/ikonka.png" alt="Logo Svět Zvířat" width="32" height="32" />
          <span style="line-height: 1;">Svět Zvířat</span>
        </NuxtLink>

        <!--
          Hamburger tlačítko — d-lg-none zajišťuje Bootstrap automaticky
          přes navbar-expand-lg. Zobrazí se pouze na mobilu/tabletu.
          data-bs-toggle a data-bs-target jsou Bootstrap JS atributy
          pro ovládání collapse panelu.
        -->
        <button
            class="navbar-toggler border-0 shadow-none"
            type="button"
            data-bs-toggle="collapse"
            data-bs-target="#navMenu"
            aria-controls="navMenu"
            aria-expanded="false"
            aria-label="Otevřít menu"
        >
          <span class="navbar-toggler-icon"></span>
        </button>

        <!--
          Collapse panel — na desktopu vždy viditelný (navbar-expand-lg),
          na mobilu se rozbalí/sbalí přes hamburger tlačítko.
        -->
        <div id="navMenu" class="collapse navbar-collapse">
          <!--
            ms-auto — margin-left: auto → odsune odkazy doprava na desktopu
            Na mobilu se zobrazí jako svislý seznam
          -->
          <div class="nav-links ms-auto d-flex flex-column flex-lg-row gap-1">
            <NuxtLink to="/" class="nav-link-item">
              <span class="icon">🏠</span> Domů
            </NuxtLink>

            <NuxtLink to="/atlas" class="nav-link-item">
              <span class="icon">🗺️</span> Atlas
            </NuxtLink>

            <NuxtLink to="/katalog" class="nav-link-item">
              <span class="icon">📖</span> Katalog
            </NuxtLink>

            <NuxtLink to="/hry" class="nav-link-item">
              <span class="icon">🎮</span> Hry
            </NuxtLink>
          </div>
        </div>

      </nav>
    </div>
  </header>
</template>

<style scoped>
.app-navbar {
  position: sticky;
  top: 0;
  z-index: 1000;
  background-color: var(--color-bg);
  border-bottom: 1px solid var(--color-border);
}

.logo-text {
  font-weight: 700;
  font-size: 1.25rem;
  color: #1a1a1a;
  text-decoration: none;
}

.logo-text:hover {
  color: #1a1a1a;
}

/* ── Navigační odkazy ───────────────────────────────────────────────────── */
.nav-link-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1rem;
  text-decoration: none;
  color: #6b7280;
  font-weight: 500;
  font-size: 0.95rem;
  border-radius: 9999px;
  transition: all 0.2s ease;
  white-space: nowrap;
}

.nav-link-item.router-link-active {
  background-color: var(--color-primary-light);  /* světle modrá */
  color: var(--color-primary);                   /* tmavě modrá */
}

.nav-link-item:hover:not(.router-link-active) {
  background-color: var(--color-primary-light);
  color: var(--color-text);
}

/* ── Mobilní menu ───────────────────────────────────────────────────────── */

/* Rozbalený stav na mobilu — přidá mezeru nad a pod seznam odkazů */
.navbar-collapse.show .nav-links,
.navbar-collapse.collapsing .nav-links {
  padding: 0.75rem 0;
}

/* Na mobilu zarovná každý odkaz doleva a odstraní pill border-radius */
@media (max-width: 991.98px) {
  .nav-link-item {
    border-radius: 0.5rem;
    width: 100%;
  }
}

/* Hamburger ikona — přebarvení na vlastní barvu */
.navbar-toggler-icon {
  background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 30 30'%3e%3cpath stroke='%236b7280' stroke-linecap='round' stroke-miterlimit='10' stroke-width='2' d='M4 7h22M4 15h22M4 23h22'/%3e%3c/svg%3e");
}
</style>
