<template>
    <div class="hero bg-base-200 min-h-screen">
        <div class="hero-content text-center">
            <div class="max-w-md">
            <h1 class="text-5xl font-bold">Clean Playlist 2.0</h1>
            <p class="py-6">
                A tool to help you remove explicit songs from your playlists. Login to your Spotify to view your playlists.
            </p>
            <a v-if="backendUp" class="btn btn-success my-3 mx-auto" :href="auth_url">Login to Spotify</a>
            <span v-else>
                <p>Waiting for server. Checking in {{ currentCountDown }}s</p>
                <p>Attempts {{ checkAttempts }}</p>
                <span class="loading loading-spinner loading-lg mt-2"></span>
            </span>
            </div>
        </div>
    </div>    
</template>

<script setup>
import {onMounted, ref} from 'vue';
import axios from 'axios';
const auth_url = ref(`${import.meta.env.VITE_API_URL}/spotify/auth`);
let backendUp = ref(false);
const maxCountDown = 10;
let currentCountDown = ref(maxCountDown)
let checkAttempts = ref(1);

const countdown = async () => {
    currentCountDown.value--;
    if (currentCountDown.value <= 0){
        let result = await checkServer();
        if(result == true){
            checkAttempts.value = 1;
            backendUp.value = true;
            return;
        }else{
            checkAttempts.value++
            backendUp.value = false;
        }
        currentCountDown.value = maxCountDown;
    }
    setTimeout(countdown, 1000) // Update every second
}

const checkServer = async ()=>{
    try {
        await axios.get(`${import.meta.env.VITE_API_URL}`, {timeout: 1000});
        return true;
    } catch (error) {
        return false;
    }
    
}

onMounted(async ()=>{
    let result = await checkServer();
    console.log(result);
    if(result == true){
        backendUp.value = true;
    }else{
        countdown();
    }
})

</script>