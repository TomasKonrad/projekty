import { test, expect } from '@playwright/test'

test('zobrazí hlavní stránku her a kvízů', async ({ page }) => {
    await page.goto('/hry')

    await page.waitForSelector('text=Hry a kvízy')
    await expect(page.locator('text=Hry a kvízy')).toBeVisible()

    await expect(page.locator('text=Hádej zvíře')).toBeVisible()
    await expect(page.locator('text=Pexeso')).toBeVisible()
    await expect(page.locator('text=Geoguesser zvířat')).toBeVisible()
})