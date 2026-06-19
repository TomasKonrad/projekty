import { defineStore } from 'pinia'
import type { Animal, AnimalFilters } from '~/types/animal'

interface AnimalsState {
  animals: Animal[]
  selectedAnimal: Animal | null
  total: number
  loading: boolean
  error: string | null
  filters: AnimalFilters
  page: number
  perPage: number
}

export const useAnimalsStore = defineStore('animals', {
  state: (): AnimalsState => ({
    animals: [],
    selectedAnimal: null,
    total: 0,
    loading: false,
    error: null,
    filters: {
      search: '',
      categories: [],
      animalRegions: [],
      conservationStatuses: [],
    },
    page: 1,
    perPage: 20,
  }),

  getters: {
    hasActiveFilters: (state): boolean =>
      state.filters.search !== '' ||
      state.filters.categories.length > 0 ||
      state.filters.animalRegions.length > 0 ||
      state.filters.conservationStatuses.length > 0,
  },

  actions: {
    setFilters(newFilters: Partial<AnimalFilters>) {
      this.filters = { ...this.filters, ...newFilters }
      this.page = 1
    },

    resetFilters() {
      this.filters = {
        search: '',
        categories: [],
        animalRegions: [],
        conservationStatuses: [],
      }
      this.page = 1
    },
  },
})
