<template>
  <header class="navbar">
    <div class="nav-container">
      <!-- Logo / Název -->
      <div class="logo">
        <NuxtLink to="/">rysstar</NuxtLink>
      </div>

      <!-- Navigační odkazy -->
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
/* NAVIGAČNÍ LIŠTA - DARK GLASSMORPHISM */
.navbar {
  /* Tmavé poloprůhledné pozadí místo plné barvy */
  background-color: rgba(10, 15, 30, 0.6);

  /* Efekt mléčného skla (rozmaže pozadí za lištou) */
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);

  /* Skleněný odlesk na spodní hraně */
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);

  padding: 16px 24px;
  position: sticky;
  top: 0;
  z-index: 100;

  /* Jemný stín, který oddělí lištu od obsahu pod ní */
  box-shadow: 0 4px 30px rgba(0, 0, 0, 0.3);
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
  font-family: var(--font-mono, monospace);
  /* Tvá elektrická modrá barva */
  color: #3b82f6;
  text-decoration: none;
  font-weight: 700;
  font-size: 1.2rem;
  transition: all 0.3s ease;
  /* Malá neonová záře kolem loga */
  text-shadow: 0 0 10px rgba(59, 130, 246, 0.4);
}

.logo a:hover {
  color: #60a5fa;
  text-shadow: 0 0 15px rgba(96, 165, 250, 0.6);
}

/* NAVIGAČNÍ ODKAZY */
.nav-links {
  display: flex;
  gap: 32px; /* Větší mezera mezi odkazy pro čistší vzhled */
}

.nav-link {
  font-family: var(--font-mono, monospace);
  color: #cbd5e1; /* Světle stříbrná barva pro neaktivní odkazy */
  text-decoration: none;
  padding: 4px 0;
  font-size: 0.95rem;
  transition: all 0.2s ease;
  border-bottom: 2px solid transparent; /* Příprava pro linku při najetí */
}

.nav-link:hover {
  color: #ffffff; /* Při najetí zbělá */
  /* text-shadow: 0 0 8px rgba(255, 255, 255, 0.4); */
}

/* AKTIVNÍ ODKAZ (Nuxt automaticky přidává tuto třídu) */
.router-link-active {
  color: #ffffff;
  /* Modrá linka pod aktivním odkazem se záři */
  border-bottom: 2px solid #3b82f6;
  box-shadow: 0 2px 0 rgba(59, 130, 246, 0.4); /* Falešná záře pod linkou */
}
</style>