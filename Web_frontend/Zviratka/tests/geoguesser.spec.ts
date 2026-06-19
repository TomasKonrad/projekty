import { test, expect } from '@playwright/test'

test('zobrazí nastavení hry Geoguesser', async ({ page }) => {
    await page.goto('/hry/geoguesser')

    await page.waitForSelector('text=Zvířecí Geoguesser')
    await expect(page.locator('text=Nastavení expedice')).toBeVisible()
    await expect(page.locator('text=Odstartovat hru')).toBeVisible()
})