import { test, expect } from '@playwright/test'

test('zobrazí zvíře dne', async ({ page }) => {
    await page.goto('/')

    await page.waitForSelector('.hero-title')
    const title = await page.textContent('.hero-title')

    expect(title).not.toBe('Načítám...')
    expect(title?.length).toBeGreaterThan(0)
})

test('tlačítko "Zobrazit více" přejde na detail', async ({ page }) => {
    await page.goto('/')
    await page.waitForSelector('.btn-secondary')
    await page.click('.btn-secondary')
    await expect(page).toHaveURL(/\/katalog\//)
})

test('kliknutí na první kartičku v populární zvířata přejde na detail', async ({ page }) => {
    await page.goto('/')

    // Počkej na načtení populárních zvířat
    await page.waitForSelector('.animal-card')

    // Klikni na první kartičku
    await page.locator('.animal-card').first().click()

    // Zkontroluj že jsme přešli na detail stránku
    await expect(page).toHaveURL(/\/katalog\/\d+/)

    // Zkontroluj že se zobrazil název zvířete
    await page.waitForSelector('.detail-page__name')
    const name = await page.textContent('.detail-page__name')
    expect(name?.length).toBeGreaterThan(0)
})

test('tlačítko Zobrazit u karty Katalog zvířat přejde na katalog', async ({ page }) => {
    await page.goto('/')

    await page.locator('.discovery-card')
        .filter({ hasText: 'Katalog zvířat' })
        .locator('.card-link-btn')
        .click()

    await expect(page).toHaveURL('/katalog')

    // Zkontroluj že se zobrazil nadpis katalogu
    await page.waitForSelector('.katalog-page__title')
    const title = await page.textContent('.katalog-page__title')
    expect(title).toContain('Katalog zvířat')
})