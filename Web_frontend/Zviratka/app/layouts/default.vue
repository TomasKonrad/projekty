<script setup lang="ts">

</script>

<template>
  <div class="app-layout">
    <NuxtLoadingIndicator color="var(--color-primary)" :height="3" />
    <Navigation />
    <main class="main-content">
      <NuxtPage keepalive />
    </main>
    <Footer />
  </div>
</template>

<style scoped>

</style>