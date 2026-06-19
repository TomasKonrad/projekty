<template>
  <div class="tree-node-wrapper">
    <div
        class="tree-node d-flex align-items-center justify-content-between p-2 rounded-3 transition-all cursor-pointer my-1"
        :class="{ 'node-selected': selectedNodeId === node.id }"
        @click="$emit('select', node)"
    >
      <div class="d-flex align-items-center gap-2">
        <button
            v-if="node.rank !== 'species'"
            @click.stop="$emit('toggle', node)"
            class="btn btn-sm btn-link p-0 d-flex align-items-center justify-content-center"
            style="width: 24px; height: 24px; color: var(--color-text);"
        >
          <span v-if="node.isLoading" class="spinner-border spinner-border-sm" style="color: var(--color-primary);" role="status"></span>
          <template v-else>
            <svg v-if="node.isOpen" width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path fill-rule="evenodd" d="M1.646 4.646a.5.5 0 0 1 .708 0L8 10.293l5.646-5.647a.5.5 0 0 1 .708.708l-6 6a.5.5 0 0 1-.708 0l-6-6a.5.5 0 0 1 0-.708z"/></svg>
            <svg v-else width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path fill-rule="evenodd" d="M4.646 1.646a.5.5 0 0 1 .708 0l6 6a.5.5 0 0 1 0 .708l-6 6a.5.5 0 0 1-.708-.708L10.293 8 4.646 2.354a.5.5 0 0 1 0-.708z"/></svg>
          </template>
        </button>
        <span v-else class="ms-4"></span>

        <div>
          <div class="node-title" :style="{ color: isMainRank(node.rank) ? 'var(--color-text)' : 'var(--color-text-muted)', fontWeight: isMainRank(node.rank) ? 'bold' : 'normal' }">
            {{ node.name }}
          </div>
          <div class="small fst-italic lh-1" style="color: var(--color-text-muted);" :style="{ opacity: isMainRank(node.rank) ? 1 : 0.7 }">
            {{ node.latinName }}
            <span class="badge-rank ms-1" :class="isMainRank(node.rank) ? 'main-rank' : 'sub-rank'">
              {{ translateRank(node.rank) }}
            </span>
          </div>
        </div>
      </div>

      <span class="badge border font-monospace small count-badge">
        {{ formatNumber(node.speciesCount) }}
      </span>
    </div>

    <div v-if="node.isOpen && node.children && node.children.length > 0" class="tree-children ps-3 border-start ms-3">
      <AtlasNode
          v-for="child in node.children"
          :key="child.id"
          :node="child"
          :selected-node-id="selectedNodeId"
          @select="$emit('select', $event)"
          @toggle="$emit('toggle', $event)"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
interface TreeNode {
  id: number
  name: string
  latinName: string
  rank: string
  speciesCount: number
  isOpen: boolean
  isLoading: boolean
  children: TreeNode[]
}

defineProps<{
  node: TreeNode
  selectedNodeId: number | undefined
}>()

defineEmits(['select', 'toggle'])

function isMainRank(rank: string): boolean {
  return ['kingdom', 'phylum', 'class', 'order', 'family', 'genus', 'species'].includes(rank)
}

function translateRank(rank: string): string {
  const ranks: Record<string, string> = {
    kingdom: 'říše', phylum: 'kmen', subphylum: 'podkmen',
    superclass: 'nadtřída', class: 'třída', subclass: 'podtřída', infraclass: 'infratřída',
    superorder: 'nadřád', order: 'řád', suborder: 'podřád', infraorder: 'infrařád',
    superfamily: 'nadčeleď', family: 'čeleď', subfamily: 'podčeleď',
    tribe: 'seskupení', genus: 'rod', species: 'druh'
  }
  return ranks[rank] || rank
}

function formatNumber(num: number): string {
  if (num >= 1_000_000) return (num / 1_000_000).toFixed(1) + 'M'
  if (num >= 1_000) return (num / 1_000).toFixed(1) + 'k'
  return num.toString()
}
</script>

<style scoped>
.transition-all { transition: all 0.2s ease; }
.cursor-pointer { cursor: pointer; }

/* Barva při najetí myší - tvůj světlý background */
.tree-node:hover {
  background-color: var(--color-bg);
}

.node-title {
  font-size: 0.95rem;
}

/* Počet druhů vpravo */
.count-badge {
  background-color: var(--color-surface);
  color: var(--color-text);
  border-color: var(--color-border) !important;
}

/* Styly pro štítky */
.badge-rank {
  font-size: 0.65rem;
  padding: 1px 5px;
  border-radius: 4px;
  text-transform: uppercase;
  font-weight: bold;
  font-style: normal;
}

.main-rank {
  background-color: var(--color-primary-light);
  color: var(--color-primary);
}

.sub-rank {
  color: var(--color-text-muted);
  border: 1px solid var(--color-border);
}

/* Vybraný uzel stromu */
.node-selected {
  background-color: var(--color-primary-light) !important;
  border-left: 4px solid var(--color-primary);
}
.node-selected .node-title {
  color: var(--color-primary) !important;
  font-weight: bold !important;
}

.tree-children {
  border-color: var(--color-border) !important;
}
</style>