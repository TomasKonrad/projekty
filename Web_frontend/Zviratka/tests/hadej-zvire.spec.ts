import { test, expect } from '@playwright/test'

test('zobrazí nastavení hry Hádej zvíře', async ({ page }) => {
    await page.goto('/hry/hadej-zvire')

    await page.waitForSelector('text=Hádej zvíře')
    await expect(page.locator('text=Jste připraveni?')).toBeVisible()
    await expect(page.locator('text=Začít hrát')).toBeVisible()
})