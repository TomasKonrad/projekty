<!-- pages/index.vue -->
<template>
  <div class="page-container">
    <section class="hero-section">
      <div class="profile-wrapper">
        <img src="/img/profilovka2.jpg" alt="Rysstar Profil" class="profile-image" />
      </div>

      <p>
        Jsem 21. letý vysokoškolský student IT, který aktuálně studuje zaměření na vývoj mobilních a webových aplikací. Tato stránka slouží jako prezentace mého portfolia uložené na Githubu.
        Níže se můžete podívat vizuálně a mé projekty. Teším se, jaké projekty ať už v týmu nebo samostatně ještě vytvořím.
      </p>
    </section>

    <!-- 2. SEKCE: TECHNOLOGIE -->
    <section class="tech-section">
      <h3 class="section-title">Používané technologie</h3>

      <div class="tech-icons-wrapper">
        <Icon name="logos:kotlin-icon" class="tech-icon" title="Kotlin" />
        <Icon name="logos:android-icon" class="tech-icon" title="Android" />
        <Icon name="logos:material-ui" class="tech-icon" title="Material UI" />
        <Icon name="devicon:swift" class="tech-icon" title="Swift" />
        <Icon name="simple-icons:apple" class="tech-icon apple-icon" title="Apple" />
        <Icon name="logos:vue" class="tech-icon" title="Vue.js" />
        <Icon name="logos:nuxt-icon" class="tech-icon" title="Nuxt" />
        <Icon name="logos:firebase" class="tech-icon" title="Firebase" />
        <Icon name="logos:figma" class="tech-icon" title="Figma" />
        <Icon name="logos:python" class="tech-icon" title="Python" />
        <Icon name="logos:java" class="tech-icon" title="Java" />
        <Icon name="devicon:cplusplus" class="tech-icon" title="C++" />
        <Icon name="logos:tailwindcss-icon" class="tech-icon" title="Tailwind CSS" />
        <Icon name="devicon:php" class="tech-icon" title="PHP" />
        <Icon name="devicon:oracle" class="tech-icon" title="Oracle" />
      </div>
    </section>

    <section id="projekty" class="projects-section">
      <h3 class="section-title">Portfolio</h3>

      <div class="projects-section">
        <div v-if="pending">Načítám projekty...</div>

        <!-- Vykreslení karet -->
        <div v-else class="projects-grid">
          <ProjectCard
              v-for="projekt in projekty"
              :key="projekt.path"
              :title="projekt.title"
              :description="projekt.description"
              :technologies="projekt.meta.technologies"
              :image="projekt.meta.image"
              :link="projekt.path"
          />
        </div>
      </div>
    </section>

  </div>
</template>

<script setup>
const { data: projekty, pending } = await useAsyncData('vsechny-projekty', () => {
  return queryCollection('projekty').all()
})
</script>

<style scoped>
.page-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: var(--space-6) var(--space-4);
}

/* --- PROFILOVÁ FOTKA --- */
.profile-wrapper {
  margin-bottom: 24px;
  display: flex;
  justify-content: center;
  width: 100%;
}

.profile-image {
  width: 250px;
  height: 250px;
  border-radius: 50%;
  object-fit: cover;
}

.hero-section {
  display: flex;
  font-size: medium;
  align-items: center;
  justify-content: center;
  gap: 40px;
  max-width: 900px;
  margin: 60px auto;
  text-align: left;
}

@media (max-width: 768px) {
  .hero-section {
    flex-direction: column;
    text-align: center;
  }
}

/* --- 2. TECH SEKCE --- */
.tech-icons-wrapper {
  display: flex;
  flex-wrap: wrap; /* Zalomí řádek, když dojde místo */
  gap: var(--space-6); /* Mezera mezi ikonami (např. 24px) */
  align-items: center; /* Srovná je na střed řádku */
  justify-content: center;
  margin-top: var(--space-4);
}

/* Velikost ikony a textu */
.tech-icon {
  font-size: 4rem;
}

/* --- 3. PROJEKTY SEKCE --- */
.projects-grid {
  display: grid;
  grid-template-columns: 1fr; /* Na mobilu (výchozí) je 1 sloupec */
  gap: var(--space-5);
}

/* Media Query pro Desktop: jakmile je okno širší než 768px, udělá 2 sloupce */
@media (min-width: 768px) {
  .projects-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}
</style>