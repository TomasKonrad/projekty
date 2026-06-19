import {test, expect, devices} from '@playwright/test'

test('zobrazí seznam zvířat funguje', async ({ page }) => {
    await page.goto('/katalog')

    // Počkej na načtení karet
    await page.waitForSelector('.animal-card')
    const cards = await page.locator('.animal-card').count()

    expect(cards).toBeGreaterThan(0)
})

test('filtr funguje na desktopu', async ({ page }) => {
    await page.setViewportSize({ width: 1280, height: 800 })
    await page.goto('/katalog')

    await page.waitForSelector('.katalog-spinner', { state: 'hidden' })
    await page.waitForSelector('.animal-card')

    await page.click('label[for="cat-savci"]')
    await page.click('label[for="hab-evropa"]')

    await page.waitForSelector('.katalog-spinner', { state: 'visible' })
    await page.waitForSelector('.katalog-spinner', { state: 'hidden' })

    const cards = await page.locator('.animal-card').count()
    expect(cards).toBeGreaterThan(0)
    await expect(page.locator('#cat-savci')).toBeChecked()
})

test('filtr funguje na mobilu', async ({ browser }) => {
    const context = await browser.newContext({
        ...devices['iPhone 13'],
    })
    const page = await context.newPage()

    await page.goto('/katalog')
    await page.waitForSelector('.katalog-spinner', { state: 'hidden' })

    await page.click('.katalog-page__filter-btn')
    await page.waitForSelector('.catalog-filter', { state: 'visible' })

    await page.click('label[for="cat-savci"]')
    await page.click('label[for="hab-evropa"]')

    await page.waitForSelector('.katalog-spinner', { state: 'visible' })
    await page.waitForSelector('.katalog-spinner', { state: 'hidden' })

    const cards = await page.locator('.animal-card').count()
    expect(cards).toBeGreaterThan(0)

    await context.close()
})

test('vyhledávání funguje', async ({ page }) => {
    await page.goto('/katalog')

    await page.fill('input[placeholder*="Hledat"]', 'Kočka')

    await page.waitForTimeout(1000)

    await page.waitForSelector('.katalog-spinner', { state: 'hidden' })

    const cards = await page.locator('.animal-card').count()
    expect(cards).toBeGreaterThan(0)
})

test('tlačítko "načíst další" funguje', async ({ page }) => {
    await page.goto('/katalog')
    await page.waitForSelector('.animal-card')

    const initialCount = await page.locator('.animal-card').count()

    await page.click('.katalog-load-more')
    await page.waitForSelector('.spinner-border-sm', { state: 'hidden' })

    const newCount = await page.locator('.animal-card').count()
    expect(newCount).toBeGreaterThan(initialCount)
})

test('zobrazí detail zvířete', async ({ page }) => {
    await page.goto('/katalog')
    await page.waitForSelector('.animal-card')

    await page.click('.animal-card:first-child')

    await expect(page).toHaveURL(/\/katalog\/\d+/)

    await page.waitForSelector('.detail-page__name')
    const name = await page.textContent('.detail-page__name')
    expect(name?.length).toBeGreaterThan(0)
})