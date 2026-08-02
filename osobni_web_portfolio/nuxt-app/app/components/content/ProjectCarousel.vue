<template>
  <div class="carousel-container">
    <div class="carousel-track" :style="{ transform: `translateX(-${currentIndex * 100}%)` }">
      <div v-for="(img, index) in images" :key="index" class="carousel-slide">
        <img :src="img" alt="Ukázka projektu" />
      </div>
    </div>

    <!-- Skleněná navigační tlačítka -->
    <button v-if="images.length > 1" @click="prev" class="nav-btn prev-btn">❮</button>
    <button v-if="images.length > 1" @click="next" class="nav-btn next-btn">❯</button>

    <!-- Tečky dole -->
    <div v-if="images.length > 1" class="carousel-dots">
      <span
          v-for="(_, index) in images"
          :key="'dot-'+index"
          class="dot"
          :class="{ active: currentIndex === index }"
          @click="currentIndex = index"
      ></span>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const props = defineProps({
  images: {
    type: Array,
    required: true
  }
})

const currentIndex = ref(0)

const next = () => {
  currentIndex.value = (currentIndex.value + 1) % props.images.length
}

const prev = () => {
  currentIndex.value = (currentIndex.value - 1 + props.images.length) % props.images.length
}
</script>

<style scoped>
.carousel-container {
  position: relative;
  width: 100%;
  border-radius: 16px;
  overflow: hidden;
  margin: 32px 0;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.4);
  /* Vesmírný rámeček */
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.carousel-track {
  display: flex;
  transition: transform 0.4s ease-in-out;
  align-items: center;
}

.carousel-slide {
  min-width: 100%;
  justify-content: center;
}

.carousel-slide img {
  min-width: 100%;
  display: flex;
  justify-content: center; /* Vycentruje úzké mobilní obrázky horizontálně */
}

.carousel-slide img {
  /* Odstraněno: width: 100% a aspect-ratio: 16/9 */
  max-width: 100%;
  height: auto; /* Výška se přizpůsobí přirozenému poměru stran obrázku */

  /* POJISTKA: Aby nudlovitý mobilní screenshot na velkém desktop monitoru
     neroztáhl stránku na 2 metry na výšku. 75vh = 75 % výšky obrazovky. */
  max-height: 75vh;

  object-fit: contain;
  display: block;
}

/* Glassmorphism navigační tlačítka */
.nav-btn {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  background: rgba(15, 23, 42, 0.5);
  backdrop-filter: blur(8px);
  color: white;
  border: 1px solid rgba(255, 255, 255, 0.2);
  width: 40px;
  height: 40px;
  border-radius: 50%;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.2rem;
  transition: all 0.3s ease;
}

.nav-btn:hover {
  background: rgba(59, 130, 246, 0.6);
  border-color: rgba(255, 255, 255, 0.4);
}

.prev-btn { left: 16px; }
.next-btn { right: 16px; }

/* Skleněné tečky */
.carousel-dots {
  position: absolute;
  bottom: 16px;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  gap: 8px;
  background: rgba(0, 0, 0, 0.3);
  padding: 6px 12px;
  border-radius: 20px;
  backdrop-filter: blur(4px);
}

.dot {
  width: 8px;
  height: 8px;
  background: rgba(255, 255, 255, 0.3);
  border-radius: 50%;
  cursor: pointer;
  transition: all 0.3s ease;
}

.dot.active {
  background: #3b82f6;
  box-shadow: 0 0 8px #3b82f6;
}
</style>