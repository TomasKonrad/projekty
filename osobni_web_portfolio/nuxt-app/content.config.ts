import { defineContentConfig, defineCollection } from '@nuxt/content'

export default defineContentConfig({
    collections: {
        // Tímto definujeme kolekci "projekty"
        projekty: defineCollection({
            type: 'page',
            source: 'projekty/**/*.md' // Říká, ať hledá v content/projekty/
        })
    }
})