<template>
  <div class="detail-page container py-4 px-4">
    <NuxtLink to="/katalog" class="detail-page__back btn btn-link text-secondary ps-0 mb-4 text-decoration-none">
      ← Zpět na katalog
    </NuxtLink>

    <div v-if="isLoading" class="text-center py-5">
      <div class="spinner-border text-success" role="status">
        <span class="visually-hidden">Načítání...</span>
      </div>
      <p class="mt-3 text-muted">Načítám detail zvířete a sestavuji mapu...</p>
    </div>

    <div v-else-if="apiError" class="alert alert-danger">
      {{ apiError.message }}
    </div>

    <content v-else-if="animalDetail">

      <!-- Jméno -->
      <div class="mb-4">
        <h1 class="detail-page__name mb-1">{{ animalDetail.name }}</h1>
        <p class="detail-page__latin text-muted mb-0">
          <em>{{ animalDetail.latinName }}</em>
        </p>
      </div>

      <!-- Řádek 1 — obrázek + mapa -->
      <div class="row g-4 mb-4">
        <div class="col-12 col-lg-6">
          <div class="detail-page__image-wrapper">
            <img
                :src="animalDetail.imageUrl"
                :alt="animalDetail.name"
                class="detail-page__image"
            />
          </div>
        </div>
        <div class="col-12 col-lg-6">
          <h3 class="fs-5 mb-3 fw-bold">Mapa globálního výskytu</h3>
          <div id="animalMap" class="animal-map"></div>
          <p class="text-muted mt-2" style="font-size: 0.8rem;">
            Zelené body představují reálná pozorování na iNaturalist.
          </p>
        </div>
      </div>

      <!-- Řádek 2 — taxonomie vlevo, statistiky vpravo -->
      <div class="row g-4 mb-4">

        <!-- Taxonomie pod obrázkem -->
        <div class="col-12 col-lg-6">
          <div class="taxonomy-box p-4 rounded-4 bg-light border h-100">
            <h3 class="fs-5 mb-3 fw-bold">Vědecká klasifikace</h3>
            <ul class="list-unstyled mb-0 taxonomy-list">
              <li><strong>Říše:</strong> <span>{{ animalDetail.taxonomy.kingdom }}</span></li>
              <li><strong>Kmen:</strong> <span>{{ animalDetail.taxonomy.phylum }}</span></li>
              <li><strong>Třída:</strong> <span>{{ animalDetail.taxonomy.class }}</span></li>
              <li><strong>Řád:</strong> <span>{{ animalDetail.taxonomy.order }}</span></li>
              <li><strong>Čeleď:</strong> <span>{{ animalDetail.taxonomy.family }}</span></li>
              <li><strong>Rod:</strong> <span>{{ animalDetail.taxonomy.genus }}</span></li>
            </ul>
          </div>
        </div>

        <!-- Statistiky pod mapou -->
        <div class="col-12 col-lg-6">
          <div class="row g-3">
            <div class="col-6">
              <div class="detail-page__stat">
                <span class="detail-page__stat-icon">🗂️</span>
                <p class="detail-page__stat-label">Kategorie</p>
                <p class="detail-page__stat-value">
                  {{ CATEGORY_LABELS[animalDetail?.category as AnimalCategory] || 'Neznámá' }}
                </p>
              </div>
            </div>
            <div class="col-6">
              <div class="detail-page__stat">
                <span class="detail-page__stat-icon">🌍</span>
                <p class="detail-page__stat-label">Prostředí</p>
                <p class="detail-page__stat-value">
                  {{ REGION_LABELS[animalDetail?.animalRegion as AnimalRegion] || 'Dle druhu' }}
                </p>
              </div>
            </div>
            <div class="col-6">
              <div class="detail-page__stat">
                <span class="detail-page__stat-icon">🛡️</span>
                <p class="detail-page__stat-label">Ohrožení</p>
                <p class="detail-page__stat-value text-truncate w-100 px-2"
                   :title="CONSERVATION_LABELS[animalDetail?.conservationStatus as ConservationStatus] || 'Běžný druh'">
                  {{ CONSERVATION_LABELS[animalDetail?.conservationStatus as ConservationStatus] || 'Běžný druh' }}
                </p>
              </div>
            </div>
            <div class="col-6">
              <div class="detail-page__stat">
                <span class="detail-page__stat-icon">📍</span>
                <p class="detail-page__stat-label">Výskyt</p>
                <p class="detail-page__stat-value">{{ animalDetail.occurrence }}</p>
              </div>
            </div>
          </div>
        </div>

      </div>

      <!-- Řádek 3 — dlouhý text -->
      <h2 class="fs-4 fw-bold mb-3">O zvířeti</h2>
      <div class="detail-page__description wiki-content" v-html="animalDetail.description"></div>

    </content>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, nextTick } from 'vue'
import { useRoute } from 'vue-router'
import {
  AnimalCategory,
  AnimalRegion,
  ConservationStatus,
  CATEGORY_LABELS,
  REGION_LABELS,
  CONSERVATION_LABELS,
} from '~/types/animal'
import type * as LeafletType from 'leaflet'

const route = useRoute()
const { getAnimalDetailById } = useINaturalist()

// --- 1. STAŽENÍ DAT (SSR i Klient) ---
const { data: animalDetail, pending: isLoading, error: apiError } = await useAsyncData<any>(
    `animal-detail-${route.params.id}`,
    async () => {
      const fullId: string = Array.isArray(route.params.id)
          ? route.params.id[0] ?? ''
          : (route.params.id as string) ?? ''
      const animalId = fullId.split('-')[0] ?? ''

      if (!animalId) throw new Error('Neplatné ID zvířete.')
      const iNatData: any = await getAnimalDetailById(animalId)

      const taxon = iNatData?.results?.[0]

      if (!taxon) {
        throw new Error('Zvíře nebylo v databázi nalezeno.')
      }

      const czName = taxon.preferred_common_name || taxon.name
      let wikiHtml = '<p>K tomuto zvířeti zatím nemáme encyklopedický popis.</p>'

      // --- WIKIPEDIA ---
      try {
        const formattedName = czName.replace(/ /g, '_')
        const wikiRes: any = await $fetch(`https://cs.wikipedia.org/w/api.php?action=query&format=json&prop=extracts&titles=${formattedName}&utf8=1&origin=*`)
        const pages = wikiRes?.query?.pages as Record<string, { extract?: string }> | undefined
        if (pages) {
          const pageId = Object.keys(pages)[0]
          if (pageId && pageId !== '-1' && pages[pageId]?.extract) {
            wikiHtml = pages[pageId].extract! //TODO hard potvrzení existence "!"
          }
        }
      } catch (e) {
        console.warn("Nahrání dat z Wikipedie se nezdařilo.")
      }

      // --- TAXONOMIE (Rodokmen) ---
      const taxonomy = { kingdom: '-', phylum: '-', class: '-', order: '-', family: '-', genus: '-' }
      if (taxon.ancestors) {
        taxon.ancestors.forEach((anc: any) => {
          const name = anc.preferred_common_name || anc.name
          if (anc.rank === 'kingdom') taxonomy.kingdom = name
          if (anc.rank === 'phylum') taxonomy.phylum = name
          if (anc.rank === 'class') taxonomy.class = name
          if (anc.rank === 'order') taxonomy.order = name
          if (anc.rank === 'family') taxonomy.family = name
          if (anc.rank === 'genus') taxonomy.genus = name
        })
      }

      // katergorie
      const catMap: Record<string, string> = {
        'Mammalia': AnimalCategory.Savci,
        'Aves': AnimalCategory.Ptaci,
        'Reptilia': AnimalCategory.Plazi,
        'Actinopterygii': AnimalCategory.Ryby,
        'Amphibia': AnimalCategory.Savci,
        'Insecta': AnimalCategory.Savci,
      }

      // stav ohrožení
      let dynamicStatus: ConservationStatus = ConservationStatus.Obnoven
      if (taxon.conservation_statuses && taxon.conservation_statuses.length > 0) {
        const iucnCodes = ['LC', 'NT', 'VU', 'EN', 'CR', 'EW', 'EX']

        const statusObj = taxon.conservation_statuses.find(
            (s: any) => !s.place_id && iucnCodes.includes(s.status?.toUpperCase())
        ) || taxon.conservation_statuses.find(
            (s: any) => iucnCodes.includes(s.status?.toUpperCase())
        )

        if (statusObj) {
          const code = statusObj.status.toUpperCase()
          const statusMap: Record<string, ConservationStatus> = {
            'LC': ConservationStatus.Obnoven,
            'NT': ConservationStatus.Obnoven,
            'VU': ConservationStatus.Zranitelny,
            'EN': ConservationStatus.Ohrozeny,
            'CR': ConservationStatus.KritickyOhrozeny,
            'EW': ConservationStatus.KritickyOhrozeny,
            'EX': ConservationStatus.KritickyOhrozeny,
          }
          dynamicStatus = statusMap[code] ?? ConservationStatus.Obnoven
        }
      }

      const obsCount = taxon.observations_count ? new Intl.NumberFormat('cs-CZ').format(taxon.observations_count) + ' záznamů' : 'Globálně'

      const regionMap: Record<number, AnimalRegion> = {
        97392: AnimalRegion.Afrika,
        97389: AnimalRegion.JizniAmerika,
        97394: AnimalRegion.SeverniAmerika,
        97391: AnimalRegion.Evropa,
        97395: AnimalRegion.Asie,
        97393: AnimalRegion.Oceanie,
        7029:  AnimalRegion.CeskaRepublika,
      }

      const animalRegion: AnimalRegion | undefined = taxon.conservation_statuses
          ?.flatMap((status: any) => status.place?.ancestor_place_ids ?? [])
          .map((placeId: number) => regionMap[placeId])
          .find(Boolean)

      return {
        id: taxon.id.toString(),
        name: czName,
        latinName: taxon.name,
        description: wikiHtml,
        imageUrl: taxon.default_photo?.medium_url || taxon.default_photo?.url?.replace('square', 'medium') || 'https://via.placeholder.com/600',
        category: catMap[taxon.iconic_taxon_name] || 'mammal',
        animalRegion: animalRegion,
        conservationStatus: dynamicStatus,
        occurrence: obsCount,
        taxonomy: taxonomy
      }
    }
)

// --- 2. INICIALIZACE MAPY ---
onMounted(async () => {
  if (animalDetail.value && typeof window !== 'undefined') {
    await nextTick()
    const mapElement = document.getElementById('animalMap');
    if (mapElement && !mapElement.classList.contains('leaflet-container')) {

      try {
        const L = (await import('leaflet')).default as typeof LeafletType
        await import('leaflet/dist/leaflet.css')

        const map = L.map('animalMap').setView([20, 0], 1)

        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
          attribution: '&copy; OpenStreetMap',
          maxZoom: 10
        }).addTo(map)

        // I pro mapu musíme poslat jen čisté číslo!
        const cleanId = (route.params.id as string).split('-')[0]
        L.tileLayer(`https://api.inaturalist.org/v1/grid/{z}/{x}/{y}.png?taxon_id=${cleanId}&color=%232e7d32`, {
          attribution: 'Výskyt: iNaturalist',
          opacity: 0.8
        }).addTo(map)

      } catch (e) {
        console.error("Nepodařilo se načíst mapu:", e)
      }
    }
  }
})

useHead(
    computed(() => ({
      title: animalDetail.value ? `${animalDetail.value.name} — Svět Zvířat` : 'Detail zvířete — Svět Zvířat',
      meta: animalDetail.value ? [{ name: 'description', content: `Vědecká klasifikace a globální výskyt pro zvíře ${animalDetail.value.name}.` }] : [],
    }))
)
</script>

<style scoped>
.detail-page__back { font-size: 0.9rem; }
.detail-page__image-wrapper { border-radius: 1.25rem; overflow: hidden; aspect-ratio: 4 / 3; box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1); }
.detail-page__image { width: 100%; height: 100%; object-fit: cover; }
.detail-page__name { font-size: 2.2rem; font-weight: 800; color: #1a1a1a; }
.detail-page__latin { font-size: 1.1rem; }

/* MAPA */
.animal-map {
  width: 100%;
  aspect-ratio: 4/2.7;
  border-radius: 1rem;
  border: 1px solid #e5e7eb;
  z-index: 1;
}

/* TAXONOMIE */
.taxonomy-box { border-color: #e5e7eb !important; }
.taxonomy-list li { padding: 0.5rem 0; border-bottom: 1px dashed #d1d5db; display: flex; justify-content: space-between;}
.taxonomy-list li:last-child { border-bottom: none; }
.taxonomy-list strong { color: #4b5563; font-weight: 600;}
.taxonomy-list span { color: #111827; font-weight: 700; text-align: right;}

/* STATISTIKY */
.detail-page__stat {
  background-color: #f9fafb;
  border: 1px solid #e5e7eb;
  border-radius: 1rem; padding:
    1rem 0.5rem; text-align: center;
  height: 100%; display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  transition: transform 0.2s;
}

.detail-page__stat-icon {
  font-size: 1.8rem;
  margin-bottom: 0.5rem;
}

.detail-page__stat-label {
  font-size: 0.75rem;
  color: #6b7280;
  margin: 0 0 0.25rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  font-weight: 600;
}

.detail-page__stat-value {
  font-size: 0.95rem;
  font-weight: 700;
  color: #111827;
  margin: 0;

}
@media (hover: hover) {
  .detail-page__stat:hover {
    transform: translateY(-3px);
  }
}

/* WIKIPEDIA TEXT ÚPRAVY */
.wiki-content { font-size: 1.05rem; line-height: 1.8; color: #374151; }
:deep(.wiki-content p) { margin-bottom: 1.2rem; text-align: justify; }
:deep(.wiki-content h2), :deep(.wiki-content h3) { margin-top: 2rem; margin-bottom: 1rem; color: #1a1a1a; font-weight: 700; font-size: 1.5rem;}
:deep(.wiki-content ul), :deep(.wiki-content ol) { margin-bottom: 1.5rem; padding-left: 1.5rem; }
:deep(.wiki-content li) { margin-bottom: 0.5rem; }
</style>