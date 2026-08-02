<template>
  <footer id="kontakt" class="footer">
    <div class="footer-container">
      <b>&copy; {{ new Date().getFullYear() }} Rysstar.</b>
      <div class="social-links">
        <a href="mailto:tomaskonrad2017@gmail.com?subject=Zájem%20o%20spolupráci%20(Portfolio)">
          e-mail
        </a>
        <a href="https://github.com/TomasKonrad/projekty/tree/main" target="_blank">GitHub</a>
        <a href="https://www.linkedin.com/in/tom%C3%A1%C5%A1-konr%C3%A1d-3822b2349/" target="_blank">LinkedIn</a>
      </div>
    </div>
  </footer>
</template>

<style scoped>
.footer {
  border-top: 1px solid #efe5e5;
  padding: 24px;
  margin-top: 64px;
}

.footer-container {
  max-width: 1200px;
  margin: 0 auto;
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 20px;
}

.social-links {
  display: flex;
  gap: 16px;
}

.social-links a {
  color: var(--color-text-main);
  text-decoration: none;
  transition: all 0.3s ease;
  font-size: 0.9rem;
  font-weight: 600;
  padding: 8px 16px;
  border-radius: 99px; /* Pilulkový tvar */
  background-color: #f3f4f6; /* Světle šedé pozadí tlačítka */
}

.social-links a:hover {
  color: var(--color-accent-hover);
  transform: translateY(-2px);
}

@media (max-width: 600px) {
  .footer-container {
    flex-direction: column;
    gap: 16px;
    text-align: center;
  }
}
</style>