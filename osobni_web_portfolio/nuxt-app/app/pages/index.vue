<!-- pages/index.vue -->
<template>
  <div class="page-container">
    <section class="hero-section">
      <div class="profile-wrapper">
        <img src="/img/profilovka.jpg" alt="Rysstar Profil" class="profile-image" />
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
        <!-- U ikon, kde byl text, je použita přípona -icon nebo jiná sada -->
        <Icon name="logos:kotlin-icon" class="tech-icon" title="Kotlin" />
        <Icon name="logos:android-icon" class="tech-icon" title="Android" />
        <Icon name="logos:material-ui" class="tech-icon" title="Material UI" />
        <Icon name="devicon:swift" class="tech-icon" title="Swift" />
        <!-- Apple ikonka bude díky CSS níže bílá, aby byla vidět na temném pozadí -->
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

    <section>
      <p>Libí se Vám projekty a máte zájem o moje know-how? Níže na mě najdete kontakt a můžeme se domluvit.</p>
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

/* --- PROFILOVÁ FOTKA (Space Glassmorphism) --- */
.profile-wrapper {
  margin-bottom: 24px; /* Odstrčí text pod fotkou kousek dolů */
  display: flex;
  justify-content: center;
  width: 100%;
}

.profile-image {
  width: 140px;  /* Zvětšil jsem fotku ze 120px na 140px, aby v hero sekci více vynikla */
  height: 140px;
  border-radius: 50%;
  object-fit: cover;

  /* Odstraněn tvrdý plný rámeček.
     Místo něj poloprůhledná bílá linka tvořící dojem "skleněného" okraje */
  border: 2px solid rgba(255, 255, 255, 0.2);

  /* Pozadí pod fotkou s mírným blur efektem pro případ načítání */
  background-color: rgba(15, 23, 42, 0.4);
  backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px);

  /* Jemný stín, který ukotví fotku v prostoru (mírně modrý nádech) */
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.5), 0 0 15px rgba(59, 130, 246, 0.1);

  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
}

.profile-image:hover {
  /* Při najetí se bílý "skleněný" rámeček změní na tvou akcentní modrou */
  border-color: rgba(59, 130, 246, 0.8);

  /* Vznesení fotky */
  transform: translateY(-5px) scale(1.05);

  /* Efekt neonové záře do prostoru (vesmírný hologram) */
  box-shadow: 0 15px 40px rgba(0, 0, 0, 0.6), 0 0 25px rgba(59, 130, 246, 0.5);
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