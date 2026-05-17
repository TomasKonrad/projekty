<template>
  <page>
    <h1>Udrž Danův Acer Nitro 15 naživu</h1>

    <div v-if="showIntro" class="intro">
      <div class="intro-content">
        <div class="info-list">
          <h2>Info o hře:</h2>
          <ul>
            <li>Při dosažení 112 stupňů se počítač přehřeje.</li>
            <li>Při dosažení 10 stupňů počítač prochladne.</li>
            <li>Při nabití baterie na 105 stupňů baterie exploduje.</li>
            <li>Chlazení a GTA spotřebovávají více baterie.</li>
            <li>Nabíjení rychle zvyšuje teplotu.</li>
          </ul>
        </div>
        <button @click="closeIntro" class="close-btn">
          Rozumím
        </button>
      </div>
    </div>


    <button @click="startGame()" class="start-btn" v-if="!isGameRunning">Začít hrát</button>
    <br>
    <button @click="endGame()">Ukončit hru</button>

    <!--<img src="/acer_bez_pozadi.png" alt="Acer laptop bez pozadi">-->
    <img :src="typeImage()" alt="Acer laptop bez pozadi">
    <br>

    <div class="statistiky">
      <p>Baterie: <span :class="getBatteryColor()">{{ battery }}%</span></p><span v-if="isGtaRunning && isCooling" title="Vysoká spotřeba baterie">🚀</span>
      <p>Teplota: <span :class="getTemperatureColor()">{{ temperature }}°C</span></p><span v-if="isGtaRunning && isCharging" title="Vysoká zahřívání">🔥</span>
    </div>

    <div class="buttons">
      <button @click="cooler()" :class="{ 'active-btn': isCooling}" :disabled="gameOver">
        {{ isCooling ? 'Vypnout chlazení' : 'Zapnout chlazení' }}</button>

      <button @click="gtaRunning()" :class="{ 'active-btn': isGtaRunning}" :disabled="gameOver">
        {{ isGtaRunning ? 'Ukončit GTA V' : 'Spustit GTA V' }}</button>

      <button @click="charging()" :class="{ 'active-btn' : isCharging}" :disabled="gameOver">
        {{ isCharging ? 'Odpojit nabíječku': 'Připojit nabíječku'}}
      </button>
    </div>

    <!--  okno konec hry -->
    <div v-if="gameOver" class="background-alert">
      <div class="content-alert">
        <h2>KONEC HRY</h2>
        <p class="game-over-message">{{ gameOverMessage }}</p>

        <button @click="closeAlert" class="close-btn">
          Zavřít alert
        </button>
      </div>
    </div>

  </page>
</template>

<script setup lang="ts">
  const temperature=useState<number>('temperature', () => 36)
  const maxTemperature=useState<number>('maxTemperature', () => 112)
  const minTemperature=useState<number>('minTemperature', () => 10)
  const gameOver=useState<boolean>('gameOver', () => false)
  const isCooling=useState<boolean>('isCooling', () => false)

  const battery=useState<number>('battery', () => 100)
  const minBattery=useState<number>('minBattery', () =>1)

  const isGameRunning=useState<boolean>('isGameRunning',() => false)

  const isGtaRunning=useState<boolean>('isGtaRunning', () => false)

  const isCharging=useState<boolean>('isCharging', () => false)

  //Defaultní hodnoty
  const startTemperature=36
  const startBattery=100
  const heatingSpeed=1000
  const batteryDrainSpeed=1500
  const coolingSpeed=500
  const chargingSpeed=300


  //zvýšené hodnoty
  const coolerDrainBattery=1200
  const gtaDrainBattery=700
  const gtaCoolerDrainBattery=400
  const gtaHeating=500
  const chargingheating=200
  const gtaChargingHeating=100

  const gameOverMessage=useState('gameOverMessage', () => '')
  const showIntro=useState('showIntro', () => true)

  //obrázky
  const acer_default='/acer_bez_pozadi.png'
  const acer_gta='acer_gta.png'

  function increaseTemperature(){
    temperature.value +=1
    if (temperature.value >= maxTemperature.value) {
      endGame()
    }
  }

  function decreaseTemperature(){
    temperature.value -=1
    if (temperature.value <= minTemperature.value){
      endGame()
    }
  }

  function decreaseBattery(){
    battery.value -=1
    if (battery.value < minBattery.value){
      endGame()
    }
  }

  //řešení zvýšené spotřeby baterie
  function updateBatteryDrain(){
    if (batteryInterval){
      clearInterval(batteryInterval)
      batteryInterval=null
    }

    if (!isGameRunning.value) return

    let currentSpeed=batteryDrainSpeed

    if (isGtaRunning.value && isCooling.value){
      currentSpeed=gtaCoolerDrainBattery
    } else if (isGtaRunning.value){
      currentSpeed=gtaDrainBattery
    }else if (isCooling.value){
      currentSpeed=coolerDrainBattery
    }

    batteryInterval=setInterval(() => {
      decreaseBattery()
    }, currentSpeed)
  }

  //funkce simuluje větráčky počítače
  let coolingInterval: ReturnType<typeof setInterval> | null = null
  function cooler(){
    if (!isGameRunning.value) return

    if (isCooling.value){
      stopCooling()
    } else {
      startCooling()
    }
  }

  function startCooling(){
    if (!isGameRunning.value) return
    isCooling.value=true
    if (!coolingInterval){
      coolingInterval=setInterval(() => {decreaseTemperature()},coolingSpeed)
    }
    updateBatteryDrain()
  }

  function stopCooling(){
    isCooling.value=false
    if (coolingInterval) {
      clearInterval(coolingInterval)
      coolingInterval=null
    }
    updateBatteryDrain()
  }

  function updateHeating() {
    if (heatingInterval) {
      clearInterval(heatingInterval)
      heatingInterval=null
    }

    if(!isGameRunning.value) return

    let currentSpeed=heatingSpeed

    if (isGtaRunning.value){
      currentSpeed=gtaHeating
    }

    if (isCharging.value && isGtaRunning.value){
      currentSpeed=gtaChargingHeating
    } else if (isCharging.value){
      currentSpeed=chargingheating
    }

    heatingInterval=setInterval(() => {
      increaseTemperature()
    }, currentSpeed)
  }

  function gtaRunning(){
    if (!isGameRunning.value) return

    if (isGtaRunning.value){
      stopGta()
    }else{
      startGta()
    }
  }

  function startGta() {
    if (!isGameRunning.value) return
    isGtaRunning.value=true
    updateHeating()
    updateBatteryDrain()
  }

  function stopGta() {
    isGtaRunning.value=false
    updateHeating()
    updateBatteryDrain()
  }

  let chargingInterval: ReturnType<typeof setInterval> | null = null
  function increaseBattery(){
    battery.value+=1
    if (battery.value >=105) {
      stopCharging()
      endGame()
    }
  }

  function charging(){
    if (!isGameRunning.value) return

    if (isCharging.value) {
      stopCharging()
    } else{
      startCharging()
    }
  }

  function startCharging(){
    if (!isGameRunning.value) return
    isCharging.value=true

    if (!chargingInterval) {
      chargingInterval=setInterval(() => {
        increaseBattery()
      }, chargingSpeed)
    }
    updateHeating()
  }

  function stopCharging(){
    isCharging.value=false

    if (chargingInterval){
      clearInterval((chargingInterval))
      chargingInterval=null
    }

    updateHeating()
  }

  //start hry
  let batteryInterval: ReturnType<typeof setInterval> | null = null
  let heatingInterval: ReturnType<typeof setInterval> | null = null
  function startGame() {
    isGameRunning.value=true
    gameOver.value=false
    isGtaRunning.value=false
    isCooling.value=false
    isCharging.value=false
    resetGame()
    updateHeating()
    updateBatteryDrain()
  }

  function endGame(){
    isGameRunning.value=false
    gameOver.value=true
    isGtaRunning.value=false
    isCooling.value=false
    isCharging.value=false

    if (heatingInterval) {
      clearInterval(heatingInterval)
      heatingInterval=null
    }

    if (batteryInterval) {
      clearInterval(batteryInterval)
      batteryInterval=null
    }

    if (coolingInterval){
      clearInterval(coolingInterval)
      coolingInterval=null
    }

    if (chargingInterval){
      clearInterval(chargingInterval)
      chargingInterval=null
    }

    if (temperature.value >= maxTemperature.value){
      gameOverMessage.value = "Acer se roztavil🔥"
    }else if (temperature.value <=minTemperature.value){
      gameOverMessage.value = "Acer zmrznul❄️"
    }else if (battery.value < minBattery.value){
      gameOverMessage.value = "Došla baterie🪫"
    }else if (battery.value >= 105){
      gameOverMessage.value="Baterie explodovala💥"
    }else {
      gameOverMessage.value = "Hra byla ukončena😥"
    }
  }

  function resetGame(){
    temperature.value=startTemperature
    battery.value=startBattery
  }

  function getTemperatureColor(){
    if (temperature.value >=90) return 'status-danger'
    if (temperature.value >=70) return 'status-warning'
    if (temperature.value <=25) return 'status-cold'
    return 'status-ok'
  }

  function getBatteryColor(){
    if (battery.value <=15 || battery.value >100) return 'status-danger'
    if (battery.value >15 && battery.value <=30) return 'status-warning'

    return 'status-ok'
  }

  function closeAlert() {
    gameOver.value = false
  }

  function typeImage(){
    if(isGameRunning.value && isGtaRunning.value) {
      return acer_gta
    }
    return acer_default
  }

  function closeIntro() {
    showIntro.value=false
  }


</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700&family=Roboto:wght@300;500&display=swap');

:global(body) {
  margin: 0;
  padding: 0;
  background: radial-gradient(circle at center, #1a1a1a 0%, #000000 100%);
  color: #e0e0e0;
  font-family: 'Roboto', sans-serif;
  height: 100vh;
  overflow: hidden; /* Zabrání scrollování */
}

/* Hlavní kontejner */
page {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
}

/* Nadpis */
h1 {
  font-family: 'Orbitron', sans-serif; /* Herní font */
  color: #ff3333; /* Nitro červená */
  text-transform: uppercase;
  letter-spacing: 3px;
  text-shadow: 0 0 15px rgba(255, 51, 51, 0.6);
  margin-bottom: 2rem;
  font-size: 2.5rem;
  border-bottom: 2px solid #ff3333;
  padding-bottom: 10px;
}

h2 {
  font-family: 'Orbitron', sans-serif;
  color: #ff3333;
  text-transform: uppercase;
  letter-spacing: 3px;
  text-shadow: 0 0 15px rgba(255, 51, 51, 0.6);
  margin-bottom: 2rem;
  font-size: 1.5rem;
  border-bottom: 2px solid #ff3333;
  padding-bottom: 10px;
}

/* Obrázek notebooku */
img {
  width: 400px;
  max-width: 90%;
  transition: transform 0.3s ease, filter 0.3s ease;
  filter: drop-shadow(0 0 30px rgba(255, 51, 51, 0.4));
}

/* Statistiky (HUD styl) */
.statistiky {
  display: flex;
  gap: 30px;
  margin: 2rem 0;
  background: rgba(255, 255, 255, 0.05);
  padding: 15px 30px;
  border-radius: 4px;
  border: 1px solid #333;
  box-shadow: inset 0 0 20px rgba(0,0,0,0.5);
}

.statistiky p {
  font-family: 'Orbitron', sans-serif;
  font-size: 1.2rem;
  margin: 0;
  color: #fff;
}

/* Tlačítka */
.buttons {
  display: flex;
  gap: 15px;
}

button {
  background: transparent;
  color: #ff3333;
  border: 2px solid #ff3333;
  padding: 12px 25px;
  font-family: 'Orbitron', sans-serif;
  font-weight: bold;
  text-transform: uppercase;
  cursor: pointer;
  transition: all 0.3s ease;
  clip-path: polygon(10% 0, 100% 0, 100% 70%, 90% 100%, 0 100%, 0 30%); /* Zkosené rohy */
}

button:hover {
  background: #ff3333;
  color: #000;
  box-shadow: 0 0 20px rgba(255, 51, 51, 0.6);
}

/* Aktivní tlačítko (chlazení zapnuto) */
.active-btn {
  background: #ff3333;
  color: #000;
  box-shadow: 0 0 15px rgba(255, 51, 51, 0.8);
  border-color: #ff3333;
}

.start-btn {
  font-size: 1.5rem;
  padding: 15px 40px;
  margin-bottom: 20px;
  clip-path: none;
  border-radius: 4px;
}

.start-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 5px 20px rgba(255, 0, 0, 0.5);
}

/* řešení barev pro baterii a zahřívání */
.status-ok{
  color: #4caf50;
  font-weight: bold;
}

.status-warning {
  color: #ff9800; /* Oranžová */
  font-weight: bold;
}

.status-danger {
  color: #f44336;
  font-weight: bold;
  display: inline-block;
  animation: heat-pulse 0.8s infinite ease-in-out;
}

.status-cold {
  color:lightskyblue;
  font-weight: bold;
}

/* okno pro konec hry */
.background-alert {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.85); /* Tmavé průhledné pozadí */
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
  backdrop-filter: blur(5px); /* Rozmazání pozadí */
}

.content-alert {
  background: #1a1a1a;
  border: 2px solid #ff3333;
  padding: 40px;
  text-align: center;
  box-shadow: 0 50px rgba(255, 51, 51, 0.5);
  max-width: 500px;
  width: 90%;
  clip-path: polygon(5% 0, 100% 0, 100% 95%, 95% 100%, 0 100%, 0 5%);
}

.content-alert h2 {
  color: #ff3333;
  font-family: 'Orbitron', sans-serif;
  font-size: 2.5rem;
  margin-top: 0;
  text-shadow: 0 0 10px rgba(255, 51, 51, 0.8);
}

.game-over-message {
  font-size: 1.5rem;
  margin: 20px 0 40px 0;
  color: #fff;
}

.close-btn {
  background: transparent;
  color: #888;
  border: 1px solid #555;
  padding: 10px 20px;
  font-size: 1rem;
  margin-left: 15px;
}

.close-btn:hover {
  border-color: #fff;
  color: #fff;
}

.intro {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.9);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 2000; /* Vyšší než ostatní prvky */
  backdrop-filter: blur(8px);
}

.intro-content {
  background: #1a1a1a;
  border: 2px solid #ff3333;
  padding: 40px;
  max-width: 600px;
  width: 90%;
  color: #fff;
  text-align: left; /* Text zarovnaný doleva je lépe čitelný */
  box-shadow: 0 0 50px rgba(255, 51, 51, 0.8);
}

.info-list ul {
  list-style-type: square; /* Čtverečkové odrážky */
  padding-left: 20px;
  line-height: 1.6;
}

.info-list li {
  margin-bottom: 10px;
  color: #ccc;
  font-size: 24px;
}

/* Definice animace pulzování */
@keyframes heat-pulse {
  0% {
    transform: scale(1);
    text-shadow: 0 0 10px rgba(255, 51, 51, 0.5);
    color: #ff3333;
  }
  50% {
    transform: scale(1.2); /* Zvětšení o 20% */
    text-shadow: 0 0 25px rgba(255, 0, 0, 1), 0 0 50px rgba(255, 100, 0, 0.8); /* Silná oranžovo-červená záře */
    color: #ff0000; /* Jasně červená */
  }
  100% {
    transform: scale(1);
    text-shadow: 0 0 10px rgba(255, 51, 51, 0.5);
    color: #ff3333;
  }
}


</style>