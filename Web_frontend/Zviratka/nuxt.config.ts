// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },
  modules: ['@pinia/nuxt', '@bootstrap-vue-next/nuxt'],
  css: ['bootstrap/dist/css/bootstrap.min.css', '~/assets/css/colors.css',],
  runtimeConfig: {
      public: { apiBase: process.env.NUXT_PUBLIC_API_BASE }
  },
  plugins: ['~/plugins/bootstrap.client.ts'],
})