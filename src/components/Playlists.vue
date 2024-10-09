<template>
    <Loading v-if="showLoading" :message="loadingMessage"></Loading>
    <div id="all_playlists_view"  v-if="showAllPlaylist">
        <p v-if="!search" class="text-4xl mt-3 text-center md:text-left">Your Spotify Playlists</p>
        <p v-else class="text-4xl mt-3 text-center md:text-left">Search Results for {{ searchInput }}</p>
        <!-- <p v-for="(item, index) in playlists.items" :key="index" v-show="playlists">{{ item.external_urls.spotify }}</p> -->
        <div class="join grid grid-cols-2 my-3">
            <button v-if="page == minPages" class="join-item btn btn-disabled">Previous page</button>
            <button v-else class="join-item btn btn-outline" @click="previousPage()">Previous page</button>
            <button v-if="page == maxPages" class="join-item btn btn-disabled">Next Page</button>
            <button v-else class="join-item btn btn-outline" @click="nextPage()">Next Page</button>
        </div>
        <button v-if="search" class="btn btn-active btn-ghost md:w-2/12 my-2" @click="getPlaylist()">Clear Search Results</button>
        <p>Pages {{ page }}/{{ maxPages }} (Total of {{ playlists.total }} playlists)</p>
        <label class="input input-bordered flex items-center gap-2 my-3">
            <input type="text" class="grow" placeholder="Search Playlists" v-model="searchInput" @input="searchPlaylist"/>
            <svg v-if="!search"
                xmlns="http://www.w3.org/2000/svg"
                viewBox="0 0 16 16"
                fill="currentColor"
                class="h-4 w-4 opacity-70">
                <path
                fill-rule="evenodd"
                d="M9.965 11.026a5 5 0 1 1 1.06-1.06l2.755 2.754a.75.75 0 1 1-1.06 1.06l-2.755-2.754ZM10.5 7a3.5 3.5 0 1 1-7 0 3.5 3.5 0 0 1 7 0Z"
                clip-rule="evenodd" />
            </svg>
        </label>
        <div class="my-3 bg-neutral rounded-lg" v-for="(item, index) in playlists.items" :key="index" v-show="playlists">
            <div class="flex flex-row">
                <img
                :src="getImgURL(item.images)"
                alt="Album" class="w-2/12 h-1/4 my-auto md:w-[150px] md:h-[150px] h-rounded-lg"/>
                <div class="flex flex-row ml-3 my-auto w-full">
                    <div class="w-1/2">
                        <a class="card-title text-sm sm:text-2xl" :href="item.external_urls.spotify" target="_blank">{{item.name}}</a>
                        <p class="text-sm sm:text-lg" target="_blank">Created By: <a :href="item.owner.external_urls.spotify">{{ item.owner.display_name }}</a></p>
                        <!-- <p class="text-base my-2">{{item.description}}</p> -->
                    </div>
                    
                    <div class="card-actions my-auto ml-auto mr-3">
                    <button class="btn md:btn-lg btn-primary" @click="viewPlaylist(item.id)">View Playlist</button>
                </div>
            </div>
            </div>
        </div>
        <p>Pages {{ page }}/{{ maxPages }} (Total of {{ playlists.total }} playlists)</p>
        <div class="join grid grid-cols-2 my-3">
            <button v-if="page == minPages" class="join-item btn btn-disabled">Previous page</button>
            <button v-else class="join-item btn btn-outline" @click="previousPage()">Previous page</button>
            <button v-if="page == maxPages" class="join-item btn btn-disabled">Next Page</button>
            <button v-else class="join-item btn btn-outline" @click="nextPage()">Next Page</button>
        </div>
    </div>
    <!-- Single Playlist View -->
    <div id="single_playlist_view " v-if="showSinglePlaylist">
        <p class="text-4xl text-center md:text-left">{{singlePlaylistName}}</p>
        <p class="text-center md:text-left">There are {{explicitSongs}} explicit songs out of {{totalSongs}} in this playlist.</p>
        <div class="flex mt-3 mx-2 w-full">
            <button v-if="search" class="btn btn-outline mr-1 w-1/4" @click="searchPlaylist()">Back to Search Results</button>
            <button v-else class="btn btn-outline mr-1 w-1/4" @click="getPlaylist()">Back to Playlists</button>
            <button class="btn btn-success mr-1 text-sm w-1/4" v-if="explicitSongs>0" @click="createNewPlaylist()">Create Playlist</button>
            <a class="btn btn-success mr-1 text-sm w-1/4 text-ellipsis overflow-hidden" :href="singlePlaylistURL" target="_blank">Open in Spotify</a>
            <!-- <button class="btn btn-success mr-1 text-sm w-2/12 text-ellipsis overflow-hidden" @click="viewPlaylist()">Refresh</button> -->
        </div>
        <div class="flex mt-3 ml-2" v-if="explicitSongs>0">
            <p class="badge badge-error">Explicit</p>
            <p class="badge badge-secondary ml-2">Exact Match Found</p>
            <p class="badge badge-info ml-2">Alternative Set</p>
        </div>
        
        <div class="mt-3" v-for="(jtems, jndex) in singlePlaylistExplicit">
            <div class="flex flex-row my-2 bg-green-900">
                <img :src="getImgURL(jtems.track.track.album.images)" class="w-1/4 h-1/4 md:w-[150px] md:h-[150px]">
                <div class="flex flex-row items-center ml-2 w-full">
                    <a :href="jtems.track.track.external_urls.spotify" target="_blank" class="text-sm md:text-lg w-full">
                        {{ jtems.track.track.name }}
                        <p class="font-bold">{{jtems.track.track.artists[0]['name']}}</p>
                    </a>
                    <p v-if="jtems.track.track.explicit" class="badge badge-error mx-2">E</p>
                    <a v-if="jtems.exact_match" class="badge badge-secondary text-xs mr-2" :href="jtems.search_results.url" target="_blank">EM</a>
                    <div v-else>
                        <div v-if="jtems.search_results.length > 0">
                            <button v-if="!jtems.alternative_set" class="btn badge-success ml-auto mr-2" @click="showAltModal(jtems.trackID)" >See Alternatives</button>
                            <button v-else class="badge badge-info mr-2">A</button>
                            <dialog id="my_modal_1" class="modal" :class="{ 'modal-open': showModal }">
                                <div class="modal-box">
                                    <h3 class="text-lg">Alternatives to <span class="font-bold">{{modalSongName}}</span></h3>
                                    <div class="flex flex-col" v-for="(ltems, jndex) in modalTracks">
                                        <div class="flex flex-row my-2 bg-green-900">
                                            <img :src="ltems.cover_url.url" class="h-1/4 w-1/4 my-auto">
                                            <div class="flex flex-row items-center my-auto ml-2 w-full md:w-3/4">
                                                <a :href="ltems.url" target="_blank">
                                                    {{ltems.name}}
                                                    
                                                    <p class="font-bold">{{ltems.album_name}}</p>
                                                    <p class="font-bold">{{ltems.artist[0].name}}</p>
                                                </a>
                                                <!-- <p><a :href="ltems.url" target="_blank">{{ltems}}</a></p> -->
                                                <button class="btn btn-success ml-auto mr-2" @click="setAlternativeTrack(currentModalID, `spotify:track:${ltems.id}`)">Set</button>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="modal-action">
                                    <form method="dialog">
                                        <button class="btn" @click="closeAltModal">Close</button>
                                    </form>
                                    </div>
                                </div>
                            </dialog>
                        </div>
                    </div>
                </div>
                
            </div>
        </div>
        <div v-for="(ktems, jndex) in singlePlaylistClean">
            <div class="flex flex-row items-center my-2 bg-green-900">
                <img :src="getImgURL(ktems.track.album.images)" class="w-1/4 h-1/4 md:w-[150px] md:h-[150px]">
                    <a :href="ktems.track.external_urls.spotify" target="_blank" class="text-sm md:text-lg w-full ml-2">
                        {{ ktems.track.name }}
                        <p class="font-bold	">{{ ktems.track.artists[0]['name'] }}</p>
                    </a>
            </div>
        </div>
        <!-- <p>{{singlePlaylist['tracks']}}</p> -->
    </div>
</template>

<script setup>
import axios from 'axios';
import { ref, onMounted } from 'vue';
import Loading from './Loading.vue';

axios.defaults.withCredentials = true
const showLoading = ref(false);
let loadingMessage = ref({});
let showAllPlaylist = ref(true);
let showSinglePlaylist = ref(false);
let playlists = ref([]);
let page = ref(1);
let pageLimit = ref(1);
let maxPages = ref(1);
let minPages = ref(1);
let singlePlaylistName = ref('');
let singlePlaylistURL = ref('ref')
let singlePlaylistExplicit = ref({});
let singlePlaylistClean = ref({});
let explicitSongs = ref(0);
let totalSongs = ref(0);
let newPlaylistSongs = ref([]);
let showModal = ref(false);
let modalTracks = ref([]);
let currentModalID = ref('');
let modalSongName = ref('');
let searchInput = ref('');
let search = ref(false);

// All playlist view
async function getPlaylist(){
    if(search.value){
        page.value = 1;
    }
    showAllPlaylist.value = false;
    search.value = false;
    searchInput.value = '';
    updateLoading(true, "Getting your playlists from Spotify.");
    try{
        const response = await axios.get(`${import.meta.env.VITE_API_URL}/spotify/playlists?page=${page.value}`);
        playlists.value = response.data;
        pageLimit.value = response.data.limit;
        displayPlaylist()
    }catch(error){
        console.log(error);
    }
    window.scrollTo(0,0);
    updateLoading();
}

async function nextPage(){
    page.value++;
    if(search.value){
        showAllPlaylist.value = false;
        updateLoading(true, "Loading search results")
        searchPlaylist(true);
        updateLoading()
    }else{
        getPlaylist();
    }
    
    
}

async function previousPage(){
    page.value--;
    if(search.value){
        showAllPlaylist.value = false;
        updateLoading(true, "Loading search results")
        searchPlaylist(true);
        updateLoading()
    }else{
        getPlaylist();
    }
}

function getImgURL(img){
    if (img == null || img.length == 0){
        return '/img/playlist_cover.png'
    }else{
        return img[0]['url']
    }
    
}

// One playlist view
function resetSinglePlaylist(){

    singlePlaylistName = ref('');
    singlePlaylistURL = ref('');
    singlePlaylistExplicit = ref({});
    singlePlaylistClean = ref({});
    explicitSongs = ref(0);
    totalSongs = ref(0);
    newPlaylistSongs = ref([]);
    showModal = ref(false);
    modalTracks = ref([]);
    currentModalID = ref('')

}

async function viewPlaylist(playlistID){
    window.scrollTo(0,0);
    updateLoading(true, 'Please wait, getting playlist info.');
    resetSinglePlaylist();
    showAllPlaylist.value = false;
    try{
        let explicitTracks = [];
        let cleanTracks = [];
        let tracks = [];
        const response = await axios.get(`${import.meta.env.VITE_API_URL}/spotify/playlists/${playlistID}/tracks`);
        tracks = response.data.items;
        singlePlaylistName = response.data.playlist.name;
        singlePlaylistURL.value = response.data.playlist.external_urls.spotify;
        explicitSongs.value = 0;
        let counter = 0;
        totalSongs.value = response.data.playlist.tracks.total;
        for(var i in tracks){
            updateLoading(true, `Finding clean versions of songs in ${singlePlaylistName}. Checked ${counter} out of ${totalSongs.value} songs in playlist. Explicit Tracks found: ${explicitSongs.value}`);
            counter+=1;
            let trackID = tracks[i]['track']['uri'];
            if(tracks[i]['track']['explicit']){
                const response = await axios.get(`${import.meta.env.VITE_API_URL}/spotify/tracks/${tracks[i]['track']['id']}/clean`);
                let data = response.data;
                let explicit_obj = {
                    trackID,
                    track: tracks[i],
                    exact_match: data.exact_match,
                    alternative_set: false,
                    search_results: data.items
                }
                if(explicit_obj.exact_match){
                    newPlaylistSongs.value.push({
                        'oldID': trackID,
                        'newID': explicit_obj.search_results.uri
                    });
                }else{
                    newPlaylistSongs.value.push({
                        'oldID': trackID,
                        'newID': null
                    });
                }
                explicitTracks.push(explicit_obj);                
                explicitSongs.value += 1;
               
            }else{
                newPlaylistSongs.value.push({
                        'oldID': trackID,
                        'newID': trackID
                    });
                cleanTracks.push(tracks[i]);
            }
        }
        singlePlaylistExplicit.value = explicitTracks;
        singlePlaylistClean.value = cleanTracks;
    }catch(error){
        console.log(error);
    }
    updateLoading();
    showSinglePlaylist.value = true;
}

onMounted(async ()=>{
    getPlaylist();
})

// Loading toggle
function updateLoading(status=false, message){
  showLoading.value = status;
  loadingMessage = message;
}

// Alternative songs view
function showAltModal(id){
    let track = singlePlaylistExplicit.value.find(es => es.trackID === id);
    modalSongName.value = track.track.track.name;
    modalTracks.value = track.search_results;
    showModal.value = !showModal.value;
    currentModalID.value = id;
}

function closeAltModal(){
    showModal.value = !showModal.value;
}

function setAlternativeTrack(id, newid){
    let newTrackIndex = newPlaylistSongs.value.findIndex(item => item.oldID === id);
    newPlaylistSongs.value[newTrackIndex]['newID'] = newid;
    let explicitTrackIndex = singlePlaylistExplicit.value.findIndex(i => i.trackID === id);
    singlePlaylistExplicit.value[explicitTrackIndex].alternative_set = true;
    closeAltModal();
}

async function createNewPlaylist(){
    if(window.confirm('Create playlist?')){
        updateLoading(true, ' Please wait, creating your playlist.');
        let sendID = [];
        for(var i in newPlaylistSongs.value){
            if(newPlaylistSongs.value[i].newID != null){
                sendID.push(newPlaylistSongs.value[i].newID);
            }
        }
        let sendObj = {
            'playlist_name': `${singlePlaylistName} - Clean`,
            'description': '',
            'ids': sendID
        }
        const response = await axios.put(`${import.meta.env.VITE_API_URL}/spotify/playlists`, sendObj);
        viewPlaylist(response.data.playlistID);
    }
}

// Playlist search
async function searchPlaylist(fromPage){
    if (!fromPage){
        page.value=1;
    }
    search.value = true;
    let url = `${import.meta.env.VITE_API_URL}/spotify/playlists/search?q=${searchInput.value}&p=${page.value}`;
    let response = await axios.get(url);
    try {
        playlists.value = response.data.data.playlists;
        pageLimit.value = response.data.data.playlists.limit;
    } catch (error) {
        console.log(error)
    }
    displayPlaylist();
}

function displayPlaylist(){
    maxPages.value = Math.ceil(playlists.value.total/pageLimit.value);
    showAllPlaylist.value = true;
    showSinglePlaylist.value = false;
}
</script>