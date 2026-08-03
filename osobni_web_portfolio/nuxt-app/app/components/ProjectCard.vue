<template>
  <article class="project-card">
    <NuxtLink :to="link" class="image-link">
      <div class="image-wrapper">
        <img
            :src="image || 'https://via.placeholder.com/600x400/161b22/8b949e?text=Image_Not_Found'"
            :alt="`Náhled projektu ${title}`"
            class="project-image"
        />
      </div>
    </NuxtLink>
    <div class="card-body">
      <div class="card-header">
        <div>
          <h3 class="card-title">
            <NuxtLink :to="link">{{ title }}</NuxtLink>
          </h3>
        </div>
      </div>
      <p class="card-desc">{{ description }}</p>
      <div class="card-footer">
        <div class="tech-stack">
          <span v-for="tech in technologies" :key="tech" class="tech-tag">
            {{ tech }}
          </span>
        </div>
        <NuxtLink :to="link" class="action-btn">
          See more
        </NuxtLink>
      </div>
    </div>
  </article>
</template>

<script setup>
defineProps({
  title: {
    type: String,
    required: true
  },
  description: {
    type: String,
    required: true
  },
  technologies: {
    type: Array,
    required: true
  },
  image: {
    type: String,
    default: ''
  },
  link: {
    type: String,
    default: '#'
  }
})
</script>

<style scoped>
.project-card {
  background-color: var(--color-bg);

  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);

  border-radius: 24px;
  padding: 12px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
  display: flex;
  flex-direction: column;
  transition: transform 0.3s ease, box-shadow 0.3s ease, border-color 0.3s ease;
}

.image-link {
  display: block;
  overflow: hidden;
  border-radius: 16px 16px 4px 4px;
}

.image-wrapper {
  position: relative;
  aspect-ratio: 16 / 9;
  width: 100%;
}

.project-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.5s ease;
}

.card-body {
  padding: 16px 8px 8px 8px;
  display: flex;
  flex-direction: column;
  flex: 1;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 12px;
}

.card-title {
  margin: 0 0 4px 0;
  font-size: 1.35rem;
  font-weight: 700;
  color: var(--color-text-main);
}

.card-title a {
  color: inherit;
  text-decoration: none;
  transition: color 0.2s ease;
}

.card-desc {
  color: var(--color-text-main);
  font-size: 0.9rem;
  line-height: 1.5;
  margin: 0 0 24px 0;
  flex: 1;
}

.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
  margin-top: auto;
}

.tech-stack {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.tech-tag {
  font-size: 1rem;
  color: var(--color-text-navbar);
  background: var(--color-bg-tag);
  padding: 6px 12px;
  border-radius: 99px;
}

.action-btn {
  background: var(--color-accent);
  color: var(--color-text-main);
  font-weight: 700;
  text-decoration: none;
  padding: 10px 24px;
  border-radius: 99px;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

@media (min-width: 768px) {
  .project-card:hover {
    transform: translateY(-6px);
    box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4);
    border-color: rgba(59, 130, 246, 0.4);
  }

  .project-card:hover .project-image {
    transform: scale(1.03);
  }

  .card-title a:hover {
    color: var(--color-accent-hover);
  }

  .action-btn:hover {
    background: var(--color-accent-hover);
    transform: translateY(-2px);
  }
}
</style>