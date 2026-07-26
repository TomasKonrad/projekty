<template>
  <div class="layout-wrapper">
    <NavBar />
    <main class="main-content">
      <slot />
    </main>

    <SiteFooter />
  </div>
</template>

<style scoped>
.layout-wrapper {
  display: flex;
  flex-direction: column;
  min-height: 100vh; /* Zajistí, že stránka zabere vždy aspoň celou výšku okna */
}

.main-content {
  flex: 1; /* Roztáhne obsah, takže footer bude vždy až dole */
  width: 100%;
}
</style>