import { test, expect } from '@playwright/test'

test('zobrazí nastavení pexesa', async ({ page }) => {
    await page.goto('/hry/pexeso')

    await page.waitForSelector('text=Nastavení hry')
    await expect(page.locator('text=Nastavení hry')).toBeVisible()

    await expect(page.locator('text=Hraji sám')).toBeVisible()
    await expect(page.locator('text=Začít hrát')).toBeVisible()
})

test('spustí hru s výchozím nastavením', async ({ page }) => {
    await page.goto('/hry/pexeso')

    await page.waitForSelector('text=Nastavení hry')

    await page.click('text=Začít hrát')

    await page.waitForSelector('.spinner-border', { state: 'hidden' })

    await page.waitForSelector('.pexeso-card')
    const cards = await page.locator('.pexeso-card').count()
    expect(cards).toBe(16)
})

test.use({
    video: 'on',
    screenshot: 'on',
})

test('výběr kategorie funguje', async ({ page }) => {
    await page.goto('/hry/pexeso')
    await page.waitForSelector('text=Nastavení hry')

    const defaultValue = await page.locator('[data-testid="category-select"]').inputValue()
    expect(defaultValue).toBe('popular')

    await page.locator('[data-testid="category-select"]').selectOption('savci')
    await page.waitForTimeout(300)

    const newValue = await page.locator('[data-testid="category-select"]').inputValue()
    expect(newValue).toBe('savci')
})

test('funguje hraní pexesa', async ({ page }) => {
    await page.setViewportSize({ width: 1280, height: 800 })
    await page.goto('/hry/pexeso')
    await page.waitForSelector('text=Nastavení hry')

    await page.locator('[data-testid="start-game"]').click()

    await page.waitForSelector('[data-testid="pexeso-grid"]', {
        state: 'visible',
        timeout: 20000
    })
    await page.screenshot({ path: 'test-results/02-po-startu.png' })

    const cards = await page.locator('[data-testid="pexeso-grid"] > *').count()
    expect(cards).toBe(16)

    await page.locator('[data-testid="pexeso-grid"] > *').nth(0).click()
    await page.waitForTimeout(500)
    await page.locator('[data-testid="pexeso-grid"] > *').nth(1).click()
    await page.waitForTimeout(2000)

    await page.screenshot({ path: 'test-results/03-after-count.png' })

    const moves = await page.textContent('[data-testid="moves-count"]')
    expect(Number(moves)).toBeGreaterThan(0)
    await page.screenshot({ path: 'test-results/04-final-game.png' })
})