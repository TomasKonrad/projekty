<!-- pages/index.vue -->
<template>
  <div class="page-container">
    <h1>Vítej na mém portfoliu</h1>
    <p>Tento obsah je obalený NavBaram a Footerem z default layoutu.</p>

    <section class="hero-section">
      <p class="code-comment">// Ahoj světě, jsem</p>
      <h1 class="hero-name">Rysstar_</h1>
      <h2 class="hero-role">Vývojář Android & Web aplikací</h2>

      <p class="hero-bio">
        Student a vývojář z Prahy. Baví mě tvořit mobilní appky, čisté weby v Nuxtu a propojovat je s cloudem přes Firebase.
        Mám silný základ v matematice a aplikuji statistiku do reálných projektů.
      </p>
    </section>

    <section class="tech-section">
      <h3 class="section-title">/* Můj Tech Stack */</h3>

      <div class="tech-grid">
        <span class="tech-item">Kotlin</span>
        <span class="tech-item">Android Studio</span>
        <span class="tech-item">Vue.js / Nuxt 3</span>
        <span class="tech-item">JavaScript / TypeScript</span>
        <span class="tech-item">Firebase</span>
        <span class="tech-item">SQLite</span>
        <span class="tech-item">Statistika</span>
        <span class="tech-item">Figma</span>
      </div>
    </section>

    <ProjectCard
        title="Správce Výdajů"
        description="Mobilní aplikace v Kotlinu pro sledování osobních financí. Obsahuje generování grafů a zálohu do Firebase."
        :technologies="['Kotlin', 'Firebase', 'MVVM']"
        image="/img/muj-projekt.jpg"
        link="#"
    />

  </div>
</template>

<style scoped>
.page-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: var(--space-6) var(--space-4);
}
</style>