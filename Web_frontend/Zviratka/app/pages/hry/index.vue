<template>
  <div class="container py-5 min-vh-100">

    <div class="text-center mb-5 mx-auto" style="max-width: 600px;">
      <h1 class="fw-bold mb-3">Hry a kvízy</h1>
      <p class="text-muted fs-5">
        Otestujte své znalosti o zvířecím světě v zábavných hrách. Vyberte si hru a začněte se učit zábavnou formou!
      </p>
    </div>

    <div class="row g-4 justify-content-center mb-5">

      <div class="col-12 col-md-6 col-lg-4">
        <div class="card border-0 shadow-sm rounded-4 h-100 overflow-hidden game-card">
          <div class="game-cover bg-game-guess d-flex align-items-center justify-content-center position-relative">
            <span class="badge game-badge text-dark position-absolute top-0 end-0 m-3 px-3 py-2 rounded-pill fw-bold shadow-sm">
              Snadné
            </span>
            <span class="display-1 drop-shadow">🦁</span>
          </div>
          <div class="card-body d-flex flex-column p-4">
            <h3 class="h5 fw-bold mb-2">Hádej zvíře</h3>
            <p class="text-muted small mb-4">
              Uhádněte zvíře podle popisu, zvuků a vizuálních nápověd. Otestujte své znalosti o světě fauny!
            </p>
            <NuxtLink to="/hry/hadej-zvire" class="btn game-btn w-100 mt-auto rounded-3 py-2 fw-bold d-flex align-items-center justify-content-center gap-2">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
                <path d="M10.804 8 5 4.633v6.734L10.804 8zm.792-.696a.802.802 0 0 1 0 1.392l-6.363 3.692C4.713 12.69 4 12.345 4 11.692V4.308c0-.653.713-.998 1.233-.696l6.363 3.692z"/>
              </svg>
              Začít hrát
            </NuxtLink>
          </div>
        </div>
      </div>

      <div class="col-12 col-md-6 col-lg-4">
        <div class="card border-0 shadow-sm rounded-4 h-100 overflow-hidden game-card">
          <div class="game-cover bg-game-memory d-flex align-items-center justify-content-center position-relative">
            <span class="badge game-badge text-dark position-absolute top-0 end-0 m-3 px-3 py-2 rounded-pill fw-bold shadow-sm">
              Střední
            </span>
            <span class="display-1 drop-shadow">🃏</span>
          </div>
          <div class="card-body d-flex flex-column p-4">
            <h3 class="h5 fw-bold mb-2">Pexeso</h3>
            <p class="text-muted small mb-4">
              Klasická hra na paměť s kartičkami zvířat. Najděte všechny páry a zlepšete svou koncentraci!
            </p>
            <NuxtLink to="/hry/pexeso" class="btn game-btn w-100 mt-auto rounded-3 py-2 fw-bold d-flex align-items-center justify-content-center gap-2">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
                <path d="M10.804 8 5 4.633v6.734L10.804 8zm.792-.696a.802.802 0 0 1 0 1.392l-6.363 3.692C4.713 12.69 4 12.345 4 11.692V4.308c0-.653.713-.998 1.233-.696l6.363 3.692z"/>
              </svg>
              Začít hrát
            </NuxtLink>
          </div>
        </div>
      </div>

      <div class="col-12 col-md-6 col-lg-4">
        <div class="card border-0 shadow-sm rounded-4 h-100 overflow-hidden game-card">
          <div class="game-cover bg-game-geo d-flex align-items-center justify-content-center position-relative">
            <span class="badge game-badge text-dark position-absolute top-0 end-0 m-3 px-3 py-2 rounded-pill fw-bold shadow-sm">
              Těžké
            </span>
            <span class="display-1 drop-shadow">🌍</span>
          </div>
          <div class="card-body d-flex flex-column p-4">
            <h3 class="h5 fw-bold mb-2">Geoguesser zvířat</h3>
            <p class="text-muted small mb-4">
              Určete, kde zvíře žije podle jeho fotografie. Dozvíte se více o geografickém rozšíření druhů!
            </p>
            <NuxtLink to="/hry/geoguesser" class="btn game-btn w-100 mt-auto rounded-3 py-2 fw-bold d-flex align-items-center justify-content-center gap-2">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
                <path d="M10.804 8 5 4.633v6.734L10.804 8zm.792-.696a.802.802 0 0 1 0 1.392l-6.363 3.692C4.713 12.69 4 12.345 4 11.692V4.308c0-.653.713-.998 1.233-.696l6.363 3.692z"/>
              </svg>
              Začít hrát
            </NuxtLink>
          </div>
        </div>
      </div>

    </div>

    <div class="edu-banner rounded-4 p-4 p-md-5 mx-auto shadow-sm" style="max-width: 900px;">
      <div class="d-flex flex-column flex-md-row gap-4 align-items-md-center mb-4">
        <div class="edu-icon text-white rounded-circle d-flex align-items-center justify-content-center flex-shrink-0 shadow-sm">
          🎓
        </div>
        <div>
          <h3 class="fw-bold mb-2 text-dark">Učte se hrou!</h3>
          <p class="text-muted mb-0" style="line-height: 1.6;">
            Naše hry jsou navrženy tak, aby vám pomohly lépe poznat zvířecí svět. Každá hra se zaměřuje na různé aspekty: od identifikace druhů až po pochopení jejich prostředí.
          </p>
        </div>
      </div>

      <div class="row g-3">
        <div class="col-12 col-sm-4">
          <div class="bg-white rounded-3 p-3 text-center shadow-sm">
            <div class="fs-3 fw-bold game-stat-value">500+</div>
            <div class="text-muted small text-uppercase fw-bold letter-spacing-1">Zvířat</div>
          </div>
        </div>
        <div class="col-12 col-sm-4">
          <div class="bg-white rounded-3 p-3 text-center shadow-sm">
            <div class="fs-3 fw-bold game-stat-value">3</div>
            <div class="text-muted small text-uppercase fw-bold letter-spacing-1">Hry</div>
          </div>
        </div>
        <div class="col-12 col-sm-4">
          <div class="bg-white rounded-3 p-3 text-center shadow-sm">
            <div class="fs-3 fw-bold game-stat-value">∞</div>
            <div class="text-muted small text-uppercase fw-bold letter-spacing-1">Znalostí</div>
          </div>
        </div>
      </div>
    </div>

  </div>
</template>

<script setup lang="ts">
useHead({ title: 'Hry a kvízy — Svět Zvířat' })
</script>

<style scoped>
.game-badge {
  background-color: var(--color-surface);
  color: var(--color-text);
}

.game-btn {
  background-color: var(--color-primary);
  color: var(--color-surface);
  border: none;
  transition: background-color 0.2s ease;
}

@media (hover: hover) {
  .game-btn:hover {
    background-color: var(--color-primary-hover);
    color: var(--color-surface);
  }
}

.game-card {
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}
.game-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1) !important;
}

/* Hlavičky karet (Barvy vytažené z tvého obrázku) */
.game-cover {
  height: 240px;
}
.bg-game-guess {
  /*background: linear-gradient(135deg, #44976c 0%, #2b6a4a 100%);*/
  background-color: var(--color-game-easy);
}
.bg-game-memory {
  /*background: linear-gradient(135deg, #4c63db 0%, #2d3b9e 100%);*/
  background-color: var(--color-game-medium);
}
.bg-game-geo {
  /*background: linear-gradient(135deg, #9b30b4 0%, #d81846 100%);*/
  background-color: var(--color-game-hard);
}

/* Efekty pro emoji */
.drop-shadow {
  filter: drop-shadow(0 10px 15px rgba(0,0,0,0.3));
  transform: scale(1.2);
}

/* Banner dole */
.edu-banner {
  /*background-color: #f0fdf4;
  border: 1px solid #dcfce7;*/
  background-color: var(--color-card-bg);
  border: var(--color-border);
}

.edu-icon {
  background-color: var(--color-primary);
  color: var(--color-surface);
  width: 70px;
  height: 70px;
  font-size: 2rem;
}

.game-stat-value {
  color: var(--color-primary);
  font-size: 1.875rem;
  font-weight: 700;
}

.letter-spacing-1 {
  letter-spacing: 0.05em;
}
</style>