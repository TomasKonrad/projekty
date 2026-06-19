<template>
  <NuxtLayout>
    <NuxtPage />
  </NuxtLayout>
</template>

<style>
/* POZOR: Zde záměrně nepoužíváme 'scoped', chceme upravit i pozadí celé stránky */

html, body {
  margin: 0;
  padding: 0;
  font-family: sans-serif;
  background-color: #f9fafb; /* Světle šedé pozadí podle tvého návrhu */
}

/* Hlavní kontejner, který vynutí výšku přes celý monitor */
.app-layout {
  display: flex;
  flex-direction: column;
  min-height: 100vh; /* 100vh = 100 % výšky okna prohlížeče */
}

/* Klíčový trik: flex: 1 řekne hlavnímu obsahu, aby se roztáhl */
.main-content {
  flex: 1;
}
</style>