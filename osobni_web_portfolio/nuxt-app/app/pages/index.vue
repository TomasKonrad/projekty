<!-- pages/index.vue -->
<template>
  <div class="page-container">
    <section class="hero-section">
      <div class="profile-wrapper">
        <img src="/img/profilovka.jpg" alt="Rysstar Profil" class="profile-image" />
      </div>

      <p class="hero-bio">
        Student a vývojář z Prahy. Baví mě tvořit mobilní appky, čisté weby v Nuxtu a propojovat je s cloudem přes Firebase.
        Mám silný základ v matematice a aplikuji statistiku do reálných projektů.
      </p>
    </section>

    <!-- 2. SEKCE: TECHNOLOGIE -->
    <section class="tech-section">
      <h3 class="section-title">/* Můj Tech Stack */</h3>

      <div class="tech-grid">
        <!-- Kotlin -->
        <div class="tech-card">
          <Icon name="logos:kotlin" class="tech-icon" />
          <span>Kotlin</span>
        </div>

        <!-- Android -->
        <div class="tech-card">
          <Icon name="logos:android-icon" class="tech-icon" />
          <span>Android</span>
        </div>

        <!-- Vue.js -->
        <div class="tech-card">
          <Icon name="logos:vue" class="tech-icon" />
          <span>Vue.js</span>
        </div>

        <!-- Nuxt.js -->
        <div class="tech-card">
          <Icon name="logos:nuxt-icon" class="tech-icon" />
          <span>Nuxt 3</span>
        </div>

        <!-- Firebase -->
        <div class="tech-card">
          <Icon name="logos:firebase" class="tech-icon" />
          <span>Firebase</span>
        </div>

        <!-- TypeScript / JavaScript -->
        <div class="tech-card">
          <Icon name="logos:typescript-icon" class="tech-icon" />
          <span>TypeScript</span>
        </div>

        <!-- Figma -->
        <div class="tech-card">
          <Icon name="logos:figma" class="tech-icon" />
          <span>Figma</span>
        </div>

        <!-- Git -->
        <div class="tech-card">
          <Icon name="logos:git-icon" class="tech-icon" />
          <span>Git</span>
        </div>
      </div>
    </section>

    <section id="projekty" class="projects-section">
      <h3 class="section-title">/* Vybrané práce */</h3>

      <div class="projects-grid">
        <!-- První projekt -->
        <ProjectCard
            title="Správce Výdajů"
            description="Mobilní aplikace v Kotlinu pro sledování osobních financí. Obsahuje generování grafů a zálohu do Firebase."
            :technologies="['Kotlin', 'Firebase', 'MVVM']"
            image="/img/vydeje-app.jpg"
            link="#"
        />

        <!-- Druhý projekt -->
        <ProjectCard
            title="Osobní Portfolio"
            description="Webová prezentace s vlastním design systémem postavená na Nuxt 3. Plně responzivní s důrazem na čistý kód."
            :technologies="['Nuxt 3', 'Vue.js', 'CSS']"
            image="/img/portfolio-web.jpg"
            link="#"
        />

      </div>
    </section>

  </div>
</template>

<style scoped>
.page-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: var(--space-6) var(--space-4);
}

/* --- PROFILOVÁ FOTKA --- */
.profile-wrapper {
  margin-bottom: var(--space-4); /* Odstrčí text pod fotkou kousek dolů */
  display: flex;
  justify-content: center; /* Zarovná obsah wrapperu doprostřed */
  width: 100%; /* Zajistí, že se střed počítá z celé šířky obrazovky */
}

.profile-image {
  width: 120px;  /* Šířka fotky */
  height: 120px; /* Výška fotky (musí být stejná jako šířka, abychom měli kruh) */
  border-radius: 50%; /* Tato vlastnost vytvoří dokonalý kruh */
  object-fit: cover; /* Zaručí, že se obdélníková fotka ořízne a nedeformuje */

  /* Stylování rámečku, aby to sedělo do IDE stylu */
  border: 3px solid var(--color-accent);
  background-color: var(--color-surface); /* Kdyby se fotka nenačetla */
  transition: border-color 0.3s ease, transform 0.3s ease;
}

.profile-image:hover {
  border-color: var(--color-accent); /* Při najetí myší se rámeček rozsvítí */
  transform: scale(1.05); /* Lehce se zvětší */
}

/* --- 2. TECH SEKCE --- */
.tech-grid {
  display: grid;
  /* Vytvoří malé čtvercové karty vedle sebe (min. šířka 100px) */
  grid-template-columns: repeat(auto-fill, minmax(100px, 1fr));
  gap: var(--space-3);
}

.tech-card {
  background-color: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  padding: var(--space-4) var(--space-2);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: var(--space-2);
  transition: transform 0.2s ease, border-color 0.2s ease;
}

.tech-card:hover {
  border-color: var(--color-accent);
  transform: translateY(-4px); /* Lehké "vyskočení" nahoru */
}

/* Velikost ikony a textu */
.tech-icon {
  font-size: 6.5rem; /* Zvětšíme ikonu */
}

.tech-card span {
  font-family: var(--font-mono);
  font-size: 0.8rem;
  color: var(--color-text-main);
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