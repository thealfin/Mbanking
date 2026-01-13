<template>
  <div class="min-h-screen bg-gray-50 flex justify-center">
    <main class="flex-1 overflow-y-auto no-scrollbar bg-white relative">
        <router-view />
        
        <Navbar v-if="!route.meta.hideNavbar" />
      </main>
    </div>
</template>

<script setup>
import Navbar from './components/Navbar.vue';
import { useRoute } from 'vue-router'; // 1. Import useRoute

const route = useRoute(); // 2. Inisialisasi route
</script>