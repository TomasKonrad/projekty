export const useINaturalist = () => {
    const baseUrl = 'https://api.inaturalist.org/v1'

    const getAnimalsByIds = (ids: string) => useFetch<any>(`${baseUrl}/taxa/${ids}?locale=cs`)
    const getAnimalsByCategory = (category: string) => useFetch<any>(`${baseUrl}/taxa?iconic_taxa=${category}&locale=cs&per_page=12`)
    const getPopularInCzechia = () => useFetch<any>(`${baseUrl}/observations/species_counts?place_id=7029&locale=cs&per_page=8`)
    const searchAnimal = (query: string) => useFetch<any>(`${baseUrl}/taxa?q=${query}&locale=cs&per_page=5`)
    const getTopPopularAnimals = () => useFetch<any>(`${baseUrl}/observations/species_counts?iconic_taxa=Mammalia&locale=cs&per_page=4`)
    const getAnimalDetailById = async (id: string) => await $fetch(`${baseUrl}/taxa/${id}?locale=cs`)

// --- API PRO KATALOG (OPRAVENO: Odfiltrovány rostliny a prázdné záznamy) ---
    const getCatalogAnimals = async (
        query: string = '',
        categories: string[] = [],
        animalRegions: string[] = [],
        conservationStatuses: string[] = [],
        page: number = 1
    ) => {
        let url = `${baseUrl}/observations/species_counts?locale=cs&per_page=30&page=${page}` // Zvýšeno na 30, protože budeme filtrovat rostliny a houby

        if (query.trim() !== '') {
            try {
                const searchRes: any = await $fetch(`${baseUrl}/taxa?q=${query}&locale=cs&per_page=1`)
                if (searchRes && searchRes.results && searchRes.results.length > 0) {
                    url += `&taxon_id=${searchRes.results[0].id}`
                } else {
                    url += `&q=${query}`
                }
            } catch (e) {
                url += `&q=${query}`
            }
        }

        const catMapping: Record<string, string> = {
            'savci': 'Mammalia',
            'ptaci': 'Aves',
            'plazi': 'Reptilia',
            'ryby': 'Actinopterygii',
            'hmyz': 'Insecta',
            'obojzivelnici': 'Amphibia',
            'pavoukovci': 'Arachnida',
            'mekkysci': 'Mollusca',
            'mammal': 'Mammalia',
            'bird': 'Aves',
            'reptile': 'Reptilia',
            'fish': 'Actinopterygii',
            'amphibian': 'Amphibia',
            'insect': 'Insecta'
        }
        if (categories && categories.length > 0) {

            const mappedCategories = categories.map(cat => {
                const normalized = cat.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "")
                return catMapping[normalized] || cat
            }).filter(Boolean)
            if (mappedCategories.length > 0) {
                url += `&iconic_taxa=${mappedCategories.join(',')}`
            }
        } else if (query.trim() === '') {
            url += '&iconic_taxa=Mammalia,Aves,Reptilia,Actinopterygii,Amphibia,Insecta,Arachnida,Mollusca'
        }

        if (animalRegions && animalRegions.length > 0) {
            const placeMapping: Record<string, string> = {
                'afrika':       '97392',
                'jizniamerika': '97389',
                'severniamerika': '97394',
                'evropa':       '6753',
                'asie':         '97395',
                'oceanie':    '97393',
                'ceskarepublika': '7029',
            }
            const mappedPlaces = animalRegions.map(h => placeMapping[h.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "")] || null).filter(Boolean)
            if (mappedPlaces.length > 0) {
                url += `&place_id=${mappedPlaces.join(',')}`
            }
        }

        if (conservationStatuses && conservationStatuses.length > 0) {
            const csMapping: Record<string, string> = { 'obnoven': 'LC', 'zranitelny': 'VU', 'ohrozeny': 'EN', 'kriticky_ohrozeny': 'CR' }
            const mappedCs = conservationStatuses.map(cs =>
                csMapping[cs.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "")] || null
            ).filter(Boolean)
            if (mappedCs.length > 0) { url += `&csi=${mappedCs.join(',')}` }
        }

        const response: any = await $fetch(url)

        if (response && response.results) {
            // FIX: Zachováme originální velký total z API před filtrací
            const originalTotalFromApi = response.total_results ?? 0

            response.results = response.results.filter((item: any) => {
                const taxon = item.taxon
                if (!taxon) return false

                const hasPhoto = taxon.default_photo?.medium_url || taxon.default_photo?.url
                const hasName = taxon.preferred_common_name || taxon.name
                const isNotPlantOrFungus = taxon.iconic_taxon_name !== 'Plantae' && taxon.iconic_taxon_name !== 'Fungi'

                return hasPhoto && hasName && isNotPlantOrFungus
            })

            // FIX: Pokud po vyfiltrování nezůstalo vůbec nic (hledala se houba) – zapíšeme 0 výsledků.
            // Pokud ale zvířata existují, necháme původní celkový počet (total) z API, aby stránkování vidělo, kolik stránek zbývá!

            if (response.results.length === 0) {
                response.total_results = 0
            } else {
                response.total_results = originalTotalFromApi
            }
        }
        return response
    }

// --- API PRO HRY (OPRAVENO: Garantuje kompletní zvířata bez nulových polí) ---
    const getGameAnimals = async (category: string, gameType: 'pexeso' | 'geoguesser') => {
        let url = `${baseUrl}/observations/species_counts?locale=cs`

        if (gameType === 'pexeso') {
            url += '&per_page=60'
            const taxonIds: Record<string, string> = {
                savci: '40151', ptaci: '26', plazi: '26036', ryby: '47178',
                zelvy: '39532', selmy: '41944', motyli: '47157'
            }
            if (taxonIds[category]) {
                url += `&taxon_id=${taxonIds[category]}`
            } else if (category === 'popular') {
                url += '&iconic_taxa=Mammalia,Aves,Reptilia'
            }
        } else if (gameType === 'geoguesser') {
            url += '&per_page=200'
            const categoryConfig: Record<string, { taxon: string, page: number }> = {
                random1: { taxon: '40151', page: 1 }, // OPRAVA: Změněno z '1' (všechno) na '40151' (Savci), aby nepadaly rostliny!
                random2: { taxon: '26', page: 1 },    // OPRAVA: Změněno na '26' (Ptáci)
                savci: { taxon: '40151', page: 1 },
                ptaci: { taxon: '26', page: 1 },
                plazi: { taxon: '26036', page: 1 },
                ryby: { taxon: '47178', page: 1 },
                hmyz: { taxon: '47158', page: 1 }
            }
            const config = categoryConfig[category] || { taxon: '40151', page: 1 }
            url += `&taxon_id=${config.taxon}&page=${config.page}`
        }

        const response: any = await $fetch(url)

        if (response && response.results) {
            // 1. ODSTRANĚNÍ ROSTLIN A CHYBNÝCH DAT
            response.results = response.results.filter((item: any) => {
                const taxon = item.taxon
                if (!taxon) return false

                const hasPhoto = taxon.default_photo?.medium_url || taxon.default_photo?.url
                const hasName = taxon.preferred_common_name || taxon.name
                const isNotPlantOrFungus = taxon.iconic_taxon_name !== 'Plantae' && taxon.iconic_taxon_name !== 'Fungi'

                return hasPhoto && hasName && isNotPlantOrFungus
            })

            // CRITICAL FIX: Aktualizujeme celkový počet výsledků podle našeho vyčištěného pole,
            // aby uživatelské rozhraní neukazovalo původní matoucí počet nalezených hub/rostlin z API.
            response.total_results = response.results.length
        }
        return response
    }

    const checkAnimalLocation = async (taxonId: number, lat: number, lng: number) => {
        // Okruh 1 00km pro Geoguesser
        return await $fetch(`${baseUrl}/observations?taxon_id=${taxonId}&lat=${lat}&lng=${lng}&radius=100&per_page=1`)
    }

    const getTaxonChildren = async (parentId: number) => {
        // Stáhne podskupiny (max 100 naráz), seřazené podle úspěšnosti/populárnosti
        return await $fetch(`${baseUrl}/taxa?parent_id=${parentId}&locale=cs&per_page=100`)
    }

    const getTopSpeciesForTaxon = async (taxonId: number, limit: number = 20) => {
        // Vytáhne nejpopulárnější konkrétní druhy (zástupce) patřící pod jakoukoliv biologickou skupinu
        return await $fetch(`${baseUrl}/observations/species_counts?taxon_id=${taxonId}&locale=cs&per_page=${limit}`)
    }

    const getAnimalOfTheDay = async () => {
        const dayOfYear = Math.floor(
            (Date.now() - new Date(new Date().getFullYear(), 0, 0).getTime()) / 86400000
        )
        const data: any = await $fetch(
            `${baseUrl}/observations/species_counts?iconic_taxa=Mammalia&locale=cs&per_page=1&page=${dayOfYear}`
        )
        const taxon = data?.results?.[0]?.taxon
        if (!taxon) return null

        // 2. Dograb plný detail včetně wikipedia_summary
        const detail: any = await $fetch(
            `${baseUrl}/taxa/${taxon.id}?locale=cs`
        )

        return detail?.results?.[0] ?? null
    }

    return {
        getAnimalsByIds,
        getAnimalsByCategory,
        getPopularInCzechia,
        searchAnimal,
        getTopPopularAnimals,
        getCatalogAnimals,
        getAnimalDetailById,
        getGameAnimals,
        checkAnimalLocation,
        getAnimalOfTheDay,
        getTaxonChildren,
        getTopSpeciesForTaxon,
    }
}