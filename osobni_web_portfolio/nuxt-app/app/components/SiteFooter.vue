<template>
  <footer class="footer">
    <div class="footer-container">
      <p>&copy; {{ new Date().getFullYear() }} Rysstar.</p>
      <div class="social-links">
        <a href="https://github.com/tvuj-profil" target="_blank">GitHub</a>
        <a href="https://linkedin.com/in/tvuj-profil" target="_blank">LinkedIn</a>
      </div>
    </div>
  </footer>
</template>

<style scoped>
.footer {
  border-top: 1px solid var(--color-border);
  padding: var(--space-4);
  background-color: var(--color-surface);
}

.footer-container {
  max-width: 1200px;
  margin: 0 auto;
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-family: var(--font-mono);
  color: var(--color-text-muted);
  font-size: 0.9rem;
}

.social-links {
  display: flex;
  gap: var(--space-4);
}

.social-links a {
  color: var(--color-text-muted);
  text-decoration: none;
}

.social-links a:hover {
  color: var(--color-accent);
}

/* Úprava pro mobilní zobrazení */
@media (max-width: 600px) {
  .footer-container {
    flex-direction: column;
    gap: var(--space-3);
  }
}
</style>