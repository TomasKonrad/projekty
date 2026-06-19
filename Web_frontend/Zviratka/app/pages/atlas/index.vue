<template>
  <div class="atlas-page container-fluid py-4 px-4 min-vh-100">

    <div class="mb-4">
      <h1 class="fw-bold" style="color: var(--color-text);">Atlas zvířat</h1>
      <p style="color: var(--color-text-muted);">Prozkoumejte interaktivní taxonomický strom a objevte přehlednou klasifikaci světa zvířat</p>
    </div>

    <div class="atlas-layout d-flex flex-column flex-lg-row" ref="containerRef">

      <div class="atlas-sidebar mb-4 mb-lg-0 flex-shrink-0 align-self-lg-start" :style="{ width: isDesktop ? leftWidth + 'px' : '100%' }">
        <div class="card border-0 shadow-sm rounded-4 overflow-hidden sticky-lg-top d-flex flex-column" style="top: 24px; max-height: calc(100vh - 48px); background-color: var(--color-surface); border: 1px solid var(--color-border) !important;">
          <div class="card-header border-bottom-0 pt-4 pb-0 px-4 flex-shrink-0" style="background-color: var(--color-surface);">
            <h2 class="h5 fw-bold mb-1" style="color: var(--color-text);">Klasifikace</h2>
            <p class="small" style="color: var(--color-text-muted);">Rozbalujte uzly pro načtení dalších vrstev</p>
          </div>

          <div id="treeScrollContainer" class="card-body px-3 py-3 style-scroll flex-grow-1" style="overflow-y: auto;">
            <AtlasNode v-if="rootNode" :node="rootNode" :selected-node-id="selectedNode?.id" @select="selectNode" @toggle="handleToggle" />
          </div>
        </div>
      </div>

      <div v-if="isDesktop" class="atlas-resizer d-flex align-items-center justify-content-center" :class="{ 'is-dragging': isDragging }" @mousedown.prevent="startDrag">
        <div class="resizer-handle"></div>
      </div>

      <div class="atlas-content flex-grow-1" style="min-width: 0;">
        <div class="card border-0 shadow-sm rounded-4 p-4 p-lg-5 sticky-lg-top" style="top: 24px; min-height: 600px; background-color: var(--color-surface); border: 1px solid var(--color-border) !important;">

          <div v-if="selectedNode" class="animate-fade-in">

            <div class="row mb-4">
              <div class="col-12 col-xl-8">
                <div class="d-flex align-items-center gap-2 mb-3" style="color: var(--color-primary);">
                  <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" viewBox="0 0 16 16">
                    <path d="M8 15A7 7 0 1 1 8 1a7 7 0 0 1 0 14zm0 1A8 8 0 1 0 8 0a8 8 0 0 0 0 16z"/>
                    <path d="m8.93 6.588-2.29.287-.082.38.45.083c.294.07.352.176.288.469l-.738 3.468c-.194.897.105 1.319.808 1.319.545 0 1.178-.252 1.465-.598l.088-.416c-.2.176-.492.246-.686.246-.275 0-.375-.193-.304-.533L8.93 6.588zM9 4.5a1 1 0 1 1-2 0 1 1 0 0 1 2 0z"/>
                  </svg>
                  <span class="fw-bold text-uppercase tracking-wider small">Karta taxonu</span>
                </div>
                <h3 class="fw-bold mb-1 fs-2 text-truncate" :title="selectedNode.name" style="color: var(--color-text);">{{ selectedNode.name }}</h3>
                <p class="fst-italic fs-5 text-truncate" :title="selectedNode.latinName" style="color: var(--color-text-muted);">{{ selectedNode.latinName }}</p>
              </div>

              <div class="col-12 col-xl-4 d-flex gap-3 mt-3 mt-xl-0">
                <div class="rounded-3 p-3 flex-fill text-center d-flex flex-column justify-content-center stats-box">
                  <span class="d-block small fw-bold mb-1" style="color: var(--color-text-muted);">Počet záznamů</span>
                  <span class="fs-4 fw-bold font-monospace" style="color: var(--color-primary);">{{ selectedNode.speciesCount.toLocaleString('cs-CZ') }}</span>
                </div>
                <div class="rounded-3 p-3 flex-fill text-center d-flex flex-column justify-content-center stats-box">
                  <span class="d-block small fw-bold mb-1" style="color: var(--color-text-muted);">Podskupin</span>
                  <span class="fs-4 fw-bold font-monospace" style="color: var(--color-primary);">{{ selectedNode.children ? selectedNode.children.length : 0 }}</span>
                </div>
              </div>
            </div>

            <div class="mb-5">
              <h4 class="h6 fw-bold text-uppercase mb-3" style="color: var(--color-text-muted);">Encyklopedický popis</h4>
              <div v-if="isLoadingWiki" class="d-flex align-items-center gap-2 p-3 rounded-3 stats-box" style="color: var(--color-text-muted);">
                <div class="spinner-border spinner-border-sm" style="color: var(--color-primary);" role="status"></div>
                <small class="fw-bold">Dotazuji encyklopedii Wikipedia...</small>
              </div>
              <p v-else class="lh-lg mb-0 text-justify wiki-p" style="color: var(--color-text);">
                {{ wikiDescription }}
              </p>
            </div>

            <div class="mt-5 pt-4" style="border-top: 1px solid var(--color-border);">
              <h4 class="h5 fw-bold mb-4" style="color: var(--color-text);">Nejznámější zástupci této skupiny</h4>

              <div v-if="isLoadingSpecies" class="text-center py-5 my-4">
                <div class="spinner-border" style="width: 3rem; height: 3rem; color: var(--color-primary);" role="status"></div>
                <p class="mt-3 fw-bold" style="color: var(--color-text-muted);">Načítám oblíbené druhy...</p>
              </div>

              <div v-else-if="popularSpecies.length > 0" class="row row-cols-2 row-cols-md-3 row-cols-xl-4 g-3">
                <div v-for="animal in popularSpecies" :key="animal.id" class="col">
                  <NuxtLink :to="'/katalog/' + animal.id" class="card h-100 border-0 shadow-sm rounded-4 overflow-hidden animal-card text-decoration-none" style="background-color: var(--color-bg); border: 1px solid var(--color-border) !important;">
                    <div class="ratio ratio-4x3 bg-dark border-bottom" style="border-color: var(--color-border) !important;">
                      <img :src="animal.imageUrl" :alt="animal.name" class="object-fit-cover w-100 h-100">
                    </div>
                    <div class="card-body p-3 text-center d-flex flex-column justify-content-center">
                      <h5 class="h6 fw-bold mb-1 text-truncate" style="color: var(--color-text);" :title="animal.name">{{ animal.name }}</h5>
                      <p class="small fst-italic mb-0 text-truncate" style="color: var(--color-text-muted);" :title="animal.latinName">{{ animal.latinName }}</p>
                    </div>
                  </NuxtLink>
                </div>
              </div>

              <div v-else class="text-center py-5 rounded-4 stats-box" style="color: var(--color-text-muted);">
                <span class="display-4 d-block mb-3 opacity-50">🐾</span>
                Pro tuto specifickou skupinu nebyli nalezeni žádní přímí zástupci. Zkuste rozbalit nižší vrstvu stromu.
              </div>
            </div>

          </div>

          <div v-else class="h-100 d-flex flex-column align-items-center justify-content-center text-center opacity-50 py-5">
            <span class="display-1 mb-3">📖</span>
            <h3 class="h5 fw-bold" style="color: var(--color-text);">Průzkumník přírody</h3>
            <p style="color: var(--color-text-muted);">Klikněte na jakoukoliv větev biologického stromu vlevo pro okamžité stažení dat a popisu.</p>
          </div>

        </div>
      </div>

    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted, nextTick } from 'vue'
import { useRoute } from 'vue-router'

useHead({ title: 'Živý Atlas zvířat — Svět Zvířat' })

const route = useRoute()
const { getTaxonChildren, getTopSpeciesForTaxon, getAnimalDetailById } = useINaturalist()

interface TreeNode { id: number; name: string; latinName: string; rank: string; speciesCount: number; isOpen: boolean; isLoading: boolean; children: TreeNode[] }
interface MiniAnimal { id: string; name: string; latinName: string; imageUrl: string }

const containerRef = ref<HTMLElement | null>(null)
const isDesktop = ref(true)
const isDragging = ref(false)
const leftWidth = ref(350)

function checkScreen() { isDesktop.value = window.innerWidth >= 992 }
function startDrag() { isDragging.value = true; document.body.style.cursor = 'ew-resize'; document.body.style.userSelect = 'none' }
function onDrag(e: MouseEvent) {
  if (!isDragging.value || !containerRef.value) return
  const containerRect = containerRef.value.getBoundingClientRect()
  let newWidth = e.clientX - containerRect.left
  if (newWidth < 280) newWidth = 280
  if (newWidth > 800) newWidth = 800
  leftWidth.value = newWidth
}
function stopDrag() { if (isDragging.value) { isDragging.value = false; document.body.style.cursor = ''; document.body.style.userSelect = '' } }

const rootNode = ref<TreeNode>({ id: 1, name: 'Živočichové', latinName: 'Animalia', rank: 'kingdom', speciesCount: 8452132, isOpen: false, isLoading: false, children: [] })
const selectedNode = ref<TreeNode | null>(null)
const wikiDescription = ref<string>('')
const isLoadingWiki = ref<boolean>(false)
const popularSpecies = ref<MiniAnimal[]>([])
const isLoadingSpecies = ref<boolean>(false)

function createSlug(text: string) {
  if (!text) return 'zvire'
  return text.toString().toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)+/g, '')
}

async function expandNode(node: TreeNode) {
  node.isOpen = true
  if (node.children.length === 0 && node.rank !== 'species') {
    node.isLoading = true
    try {
      const data: any = await getTaxonChildren(node.id)
      if (data && data.results) {
        node.children = data.results.map((item: any) => ({
          id: item.id, name: item.preferred_common_name || item.name, latinName: item.name, rank: item.rank, speciesCount: item.observations_count || 0, isOpen: false, isLoading: false, children: []
        }))
      }
    } catch (e) { console.error('Chyba stahování větví:', e) }
    finally { node.isLoading = false }
  }
}

async function handleToggle(node: TreeNode) {
  if (node.isOpen) { node.isOpen = false } else { await expandNode(node) }
}

function selectNode(node: TreeNode) {
  selectedNode.value = node
  fetchWikiDescription(node.name)
  fetchPopularSpecies(node.id)
}

async function fetchWikiDescription(taxonName: string) {
  isLoadingWiki.value = true; wikiDescription.value = ''
  try {
    const formattedName = taxonName.replace(/ /g, '_')
    const response: any = await $fetch(`https://cs.wikipedia.org/w/api.php?action=query&format=json&prop=extracts&titles=${formattedName}&exintro=1&explaintext=1&utf8=1&origin=*`)
    const pages = response?.query?.pages
    if (pages) {
      const pageId = Object.keys(pages)[0]
      if (pageId !== '-1' && pages[pageId].extract) { wikiDescription.value = pages[pageId].extract }
      else { wikiDescription.value = `Biologická skupina ${taxonName} představuje specifickou úroveň v hierarchické klasifikaci živočišné říše.` }
    }
  } catch (error) { wikiDescription.value = 'Popis se nepodařilo načíst.' }
  finally { isLoadingWiki.value = false }
}

async function fetchPopularSpecies(taxonId: number) {
  isLoadingSpecies.value = true; popularSpecies.value = []
  try {
    const response: any = await getTopSpeciesForTaxon(taxonId, 20)
    if (response && response.results) {
      popularSpecies.value = response.results.map((item: any) => {
        const czName = item.taxon.preferred_common_name || item.taxon.name
        return {
          id: `${item.taxon.id}-${createSlug(czName)}`, name: czName, latinName: item.taxon.name, imageUrl: item.taxon.default_photo?.medium_url || item.taxon.default_photo?.url?.replace('square', 'medium') || 'https://via.placeholder.com/400'
        }
      }).filter((animal: MiniAnimal) => animal.name && !animal.imageUrl.includes('placeholder'))
    }
  } catch (error) { console.error(error) }
  finally { isLoadingSpecies.value = false }
}

onMounted(async () => {
  checkScreen()
  window.addEventListener('resize', checkScreen)
  window.addEventListener('mousemove', onDrag)
  window.addEventListener('mouseup', stopDrag)

  await expandNode(rootNode.value)
  selectNode(rootNode.value)

  if (route.query.path && route.query.select) {
    const pathIds = (route.query.path as string).split(',').map(id => parseInt(id)).filter(id => id !== 1)
    const targetId = parseInt(route.query.select as string)
    let currentNode = rootNode.value

    for (const id of pathIds) {
      let foundChild = currentNode.children.find(c => c.id === id)
      if (!foundChild) {
        try {
          const fallbackData: any = await getAnimalDetailById(id.toString())
          if (fallbackData && fallbackData.results && fallbackData.results[0]) {
            const item = fallbackData.results[0]
            foundChild = { id: item.id, name: item.preferred_common_name || item.name, latinName: item.name, rank: item.rank, speciesCount: item.observations_count || 0, isOpen: false, isLoading: false, children: [] }
            currentNode.children.push(foundChild)
          }
        } catch(e) {}
      }
      if (foundChild) {
        currentNode = foundChild
        await expandNode(currentNode)
      } else { break }
    }

    let finalNode = currentNode.id === targetId ? currentNode : currentNode.children.find(c => c.id === targetId) || currentNode
    if (!finalNode && currentNode.id !== targetId) {
      try {
        const fallbackData: any = await getAnimalDetailById(targetId.toString())
        if (fallbackData && fallbackData.results && fallbackData.results[0]) {
          const item = fallbackData.results[0]
          finalNode = { id: item.id, name: item.preferred_common_name || item.name, latinName: item.name, rank: item.rank, speciesCount: item.observations_count || 0, isOpen: false, isLoading: false, children: [] }
          currentNode.children.push(finalNode)
        }
      } catch(e) {}
    }

    if (finalNode) {
      selectNode(finalNode)
      await nextTick()
      setTimeout(() => {
        const selectedEl = document.querySelector('.node-selected')
        const scrollContainer = document.getElementById('treeScrollContainer')
        if (selectedEl && scrollContainer) {
          const containerTop = scrollContainer.getBoundingClientRect().top
          const elemTop = selectedEl.getBoundingClientRect().top
          scrollContainer.scrollTo({ top: (scrollContainer.scrollTop + elemTop) - containerTop - 150, behavior: 'smooth' })
        }
      }, 500)
    }
  }
})

onUnmounted(() => {
  window.removeEventListener('resize', checkScreen)
  window.removeEventListener('mousemove', onDrag)
  window.removeEventListener('mouseup', stopDrag)
})
</script>

<style scoped>
.atlas-resizer { width: 24px; cursor: ew-resize; z-index: 10; transition: background-color 0.2s; }
.resizer-handle { width: 4px; height: 40px; background-color: var(--color-border); border-radius: 4px; transition: all 0.2s ease; }
.atlas-resizer:hover .resizer-handle, .atlas-resizer.is-dragging .resizer-handle { background-color: var(--color-primary); width: 6px; height: 50px; }

/* Rámečky na statistiky využívají tvůj design system */
.stats-box { background-color: var(--color-bg); border: 1px solid var(--color-border); }

.text-justify { text-align: justify; }
.tracking-wider { letter-spacing: 0.08em; }
.wiki-p { font-size: 1.05rem; }

/* Přebarvený scroller stromu do tvého stylu */
.style-scroll::-webkit-scrollbar { width: 6px; height: 6px; }
.style-scroll::-webkit-scrollbar-track { background: var(--color-bg); border-radius: 10px; }
.style-scroll::-webkit-scrollbar-thumb { background: var(--color-border-dark); border-radius: 10px; }
.style-scroll::-webkit-scrollbar-thumb:hover { background: var(--color-primary); }

.animate-fade-in { animation: fadeIn 0.4s ease-out forwards; }
@keyframes fadeIn { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: translateY(0); } }
.animal-card { transition: transform 0.2s ease, box-shadow 0.2s ease; cursor: pointer; }
.animal-card:hover { transform: translateY(-4px); box-shadow: 0 10px 20px rgba(0,0,0,0.08) !important; border-color: var(--color-primary) !important; }
</style>