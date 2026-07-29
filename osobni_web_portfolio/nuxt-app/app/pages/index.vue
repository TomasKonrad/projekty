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
        <Icon name="logos:kotlin" class="tech-icon" />
        <Icon name="logos:android-vertical" class="tech-icon" />
        <Icon name="logos:material-ui" class="tech-icon" />
        <Icon name="devicon:swift" class="tech-icon" />
        <Icon name="simple-icons:apple" class="tech-icon" />
        <Icon name="logos:vue" class="tech-icon" />
        <Icon name="logos:nuxt" class="tech-icon" />
        <Icon name="logos:firebase" class="tech-icon" />
        <Icon name="logos:figma" class="tech-icon" />
        <Icon name="logos:python" class="tech-icon" />
        <Icon name="logos:java" class="tech-icon" />
        <Icon name="devicon:cplusplus" class="tech-icon" />
        <Icon name="logos:tailwindcss" class="tech-icon" />
        <Icon name="logos:php" class="tech-icon" />
        <Icon name="logos:oracle" class="tech-icon" />
      </div>
    </section>

    <section id="projekty" class="projects-section">
      <h3 class="section-title">Portfolio</h3>

      <div class="projects-grid">
        <ProjectCard
            v-for="(projekt, index) in seznamProjektu"
            :key="index"
            :title="projekt.title"
            :description="projekt.description"
            :technologies="projekt.technologies"
            :image="projekt.image"
            :link="projekt.link"
        />
      </div>
    </section>

    <section>
      <p>Libí se Vám projekty a máte zájem o moje know-how? Níže na mě najdete kontakt a můžeme se domluvit.</p>
    </section>

  </div>
</template>

<script setup>
const seznamProjektu = [
  {
    title: "Udrž Danův Acer Nitro 15 naživu",
    description: "Webová hra, kde udržujete Danuv notebook při životě.",
    technologies: ['Vue', 'Nuxt'],
    image: "/img/vydeje-app.jpg",
    link: "#"
  },
  {
    title: "Monster Tinder",
    description: "Seznamka inspirovaná mobilní seznamkou Tinder s propojením na api Mockapi.io.",
    technologies: ['Vue', 'Nuxt', 'MockApi'],
    image: "/img/portfolio-web.jpg",
    link: "#"
  },
  {
    title: "Svět zvířat",
    description: "Webová aplikace o zvířatech včetně her",
    technologies: ['Vue', 'Nuxt', 'INaturalist API', 'Wikimedia API', 'Docker'],
    image: "/img/portfolio-web.jpg",
    link: "#"
  },
  {
    title: "Tommy Jeans e-shop",
    description: "Webový e-shop s oblečením značky Tommy Jeans",
    technologies: ['Python', 'RestAPI', 'FlaskAPI'],
    image: "/img/portfolio-web.jpg",
    link: "#"
  },
  {
    title: "Mendle Phone [1]",
    description: "Návrh designu webu mířené pro specifickou skupinu za pomocí nástroje Figma a Affinity",
    technologies: ['Figma'],
    image: "/img/MendlePhone.png",
    link: "#"
  },
  {
    title: "SportApp",
    description: "První jednoduchá Android aplikace zaměřená na zaznamenávání sportovních aktivit ",
    technologies: ['Kotlin', 'Android', 'Material 3'],
    image: "/img/portfolio-web.jpg",
    link: "#"
  },
  {
    title: "GtaGarage",
    description: "Manager Nemovitostí a vozidel pro hru GTA V jako mobilní aplikace",
    technologies: ['Kotlin', 'Android', 'Material 3', 'Figma', 'Firebase'],
    image: "/img/Feathure_graphic.png",
    link: "#"
  },
  {
    title: "Kosher",
    description: "Mobilní aplikace jako pomocník pro třídění odpadu",
    technologies: ['Swift', 'iOS', 'Gemini', 'Figma', 'Firebase'],
    image: "/img/kosher.jpg",
    link: "#"
  },
]
</script>

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