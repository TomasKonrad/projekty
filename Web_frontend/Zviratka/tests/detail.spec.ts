import { test, expect } from '@playwright/test'

test('zobrazí mapu výskytu', async ({ page }) => {
    await page.goto('/katalog/47219-vcela-medonosna')
    await page.waitForSelector('#animalMap')

    const map = await page.locator('#animalMap')
    await expect(map).toBeVisible()
})

test('tlačítko zpět funguje', async ({ page }) => {
    await page.goto('/katalog/47219-vcela-medonosna')
    await page.click('text=Zpět na katalog')
    await expect(page).toHaveURL('/katalog')
})