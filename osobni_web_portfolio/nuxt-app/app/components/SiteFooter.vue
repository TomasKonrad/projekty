<template>
  <footer class="footer">
    <div class="footer-container">
      <p>&copy; {{ new Date().getFullYear() }} Rysstar.</p>
      <div class="social-links">
        <a href="https://github.com/TomasKonrad/projekty/tree/main" target="_blank">GitHub</a>
        <a href="https://www.linkedin.com/in/tom%C3%A1%C5%A1-konr%C3%A1d-3822b2349/" target="_blank">LinkedIn</a>
      </div>
    </div>
  </footer>
</template>

<style scoped>
/* PATIČKA - DARK GLASSMORPHISM */
.footer {
  /* Skleněný odlesk na horní hraně */
  border-top: 1px solid rgba(255, 255, 255, 0.1);
  padding: 24px;

  /* Tmavé poloprůhledné pozadí */
  background-color: rgba(10, 15, 30, 0.6);

  /* Efekt rozostření pozadí pod patičkou */
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);

  /* Přidáme stín směřující nahoru, pro lepší oddělení od obsahu */
  box-shadow: 0 -4px 30px rgba(0, 0, 0, 0.2);

  /* Vytvoří hezký odstup od zbytku stránky, pokud není nastavený jinde */
  margin-top: 64px;
}

.footer-container {
  max-width: 1200px;
  margin: 0 auto;
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-family: var(--font-mono, monospace);
  color: #cbd5e1; /* Světle stříbrná barva pro text */
  font-size: 0.9rem;
}

.social-links {
  display: flex;
  gap: 24px;
}

.social-links a {
  color: #cbd5e1;
  text-decoration: none;
  transition: all 0.3s ease;
}

.social-links a:hover {
  /* Při najetí zmodrá a získá jemnou neonovou záři */
  color: #3b82f6;
  text-shadow: 0 0 10px rgba(59, 130, 246, 0.4);
}

/* Úprava pro mobilní zobrazení */
@media (max-width: 600px) {
  .footer-container {
    flex-direction: column;
    gap: 16px;
    text-align: center;
  }
}
</style>