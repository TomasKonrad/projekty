import { useLocalStorage } from '@vueuse/core';
import type {Filters, Monster, SwipeDirection} from "~/types";


export const useMatchStore = defineStore('match', () => {
    const discoveryQueue = ref<Monster[]>([]);
    //const likedMonsters = ref<Monster[]>([]);
    const likedMonsters = useLocalStorage<Monster[]>('liked-monsters', []);
    const filters = ref<Filters>({ needFur: false, minAge: 0, maxAge: 1000}); //počáteční podmínky monstra

    //state pro řešení undo last match
    const lastAction = ref<{ monster: Monster, direction: SwipeDirection} | null>(null) //buď objekt monster nebo null

    const getFilteredQueue = computed(() => {
        return discoveryQueue.value.filter(monster => {
            const matchAge = monster.age >= filters.value.minAge
                && monster.age <= filters.value.maxAge;
            const matchFur = !filters.value.needFur || monster.hasFur;
            return matchAge && matchFur;
        });
    });

    async function loadMonsters() {
        //zamezení zbytečnému načítání
        if (discoveryQueue.value.length > 0) return;

        const { data, error } =
            await useFetch<Monster[]>('https://69c7b32f63393440b31704ee.mockapi.io/monsters');

        if (error.value) {
            console.error('swipe fuction error', error.value)
            return;
        }

        discoveryQueue.value = data.value || [];
    };

    async function swipe(direction: SwipeDirection, monsterId: string) {
        const index = discoveryQueue.value.findIndex(idx => idx.id === monsterId);
        if (index === -1) return;

        const removedArray = discoveryQueue.value.splice(index, 1);
        const monster = removedArray[0]!; //nezapomenout na ten vykřičník, není to správně

        lastAction.value = {
            monster: monster,
            direction: direction
        };

        // Pokud swipne doprava, přidáme do oblíbených
        if (direction === 'right') {
            likedMonsters.value.push(monster);
        }
    }

    function undoLastSwipe(){
        if (!lastAction.value) return;

        const { monster, direction } = lastAction.value;
        discoveryQueue.value.unshift(monster)
        if (direction === 'right') {
            likedMonsters.value = likedMonsters.value
                .filter(idx => idx.id !== monster.id);
        }
        lastAction.value = null;
    }

    const chatHistory = ref<Record<string, string[]>>({});

    function chatWithMonster(monsterId: string, message: string) {
        if (!chatHistory.value[monsterId]) {
            chatHistory.value[monsterId] = [];
        }

        chatHistory.value[monsterId].push(message)
    }

    //vracíme celý objekt, nezapomenout sem napsat vše!
    return {
        discoveryQueue,
        likedMonsters,
        filters,
        getFilteredQueue,
        lastAction,
        loadMonsters,
        swipe,
        undoLastSwipe,
        chatHistory,
        chatWithMonster
    };
});