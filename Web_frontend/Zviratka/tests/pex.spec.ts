import { test, expect } from '@playwright/test'

test('zobrazí nastavení hry Pexeso', async ({ page }) => {
    await page.goto('/hry/pexeso')

    await page.waitForSelector('text=Zvířecí Pexeso')
    await expect(page.locator('text=Nastavení hry')).toBeVisible()
    await expect(page.locator('[data-testid="start-game"]')).toBeVisible()
})