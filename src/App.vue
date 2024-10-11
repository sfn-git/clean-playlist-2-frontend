<template>
    <div class="w-screen" v-if="isAuthenticated">
      <Nav :isAuthenticated="isAuthenticated"></Nav>
      <div class="container mx-auto">
        <Playlists></Playlists>
      </div>
    </div>
    <div v-else class="mt-3 w-screen"> 
      <Index></Index>
    </div>
</template>

<script setup>
import axios from 'axios'
import Playlists from './components/Playlists.vue'
import Nav from './components/Nav.vue';
import Index from './components/Index.vue';
import { onBeforeMount, ref } from 'vue';
 
axios.defaults.withCredentials = true

const isAuthenticated = ref(false);
let checkAuth = async () =>{
  let url = `${import.meta.env.VITE_API_URL}/spotify/authenticated`
  console.log(url)
  await axios.get(url).then(response => {
    isAuthenticated.value = response.data.authenticated;    
  }).catch(error =>{
    console.log(error);
    isAuthenticated.value = false;
  })
}



onBeforeMount(()=>checkAuth())

// return {updateLoading};

</script>