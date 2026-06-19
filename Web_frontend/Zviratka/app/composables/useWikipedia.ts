export const useWikipedia = () => {
    // Základní URL pro českou Wikipedii
    const baseUrl = 'https://cs.wikipedia.org/api/rest_v1/page/summary'

    // Funkce, které předáš název zvířete (např. "Lev_pustinný" nebo "Panda_červená")
    const getAnimalSummary = (animalName: string) => {
        // Nahradíme případné mezery podtržítky, jak to Wikipedie vyžaduje v URL
        const formattedName = animalName.replace(/ /g, '_')

        return useFetch(`${baseUrl}/${formattedName}`)
    }

    return {
        getAnimalSummary
    }
}