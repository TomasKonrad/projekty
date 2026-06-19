import { test, expect } from '@playwright/test'

test('zobrazí hlavní stránku atlasu zvířat', async ({ page }) => {
    await page.goto('/atlas')

    await page.waitForSelector('text=Atlas zvířat')
    await expect(page.locator('text=Atlas zvířat')).toBeVisible()

    await expect(page.locator('text=Průzkumník přírody')).toBeVisible()
})