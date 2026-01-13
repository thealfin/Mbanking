<template>
  <nav class="fixed bottom-0 left-1/2 -translate-x-1/2 w-full max-w-md lg:max-w-4xl bg-[#016B61] h-[88px] rounded-t-[30px] shadow-[0_-5px_20px_rgba(0,0,0,0.15)] z-50 transition-all duration-300">
    
    <div class="flex justify-between items-end px-6 pb-4 h-full w-full max-w-2xl mx-auto">
      
      <router-link to="/" class="flex flex-col items-center gap-1 w-16 group">
        <div 
          class="w-10 h-10 rounded-full flex items-center justify-center transition-all duration-300"
          :class="isActive('/') ? 'bg-[#E5E9C5] -translate-y-2 shadow-md' : 'bg-transparent'"
        >
          <i class="ri-home-5-fill text-2xl transition-colors"
             :class="isActive('/') ? 'text-[#016B61]' : 'text-[#70B2B2] group-hover:text-white'"></i>
        </div>
        <span class="text-[10px] font-medium transition-colors"
              :class="isActive('/') ? 'text-white' : 'text-[#70B2B2]'">Beranda</span>
      </router-link>

      <router-link to="/mutasi" class="flex flex-col items-center gap-1 w-16 group">
        <div 
          class="w-10 h-10 rounded-full flex items-center justify-center transition-all duration-300"
          :class="isActive('/mutasi') ? 'bg-[#E5E9C5] -translate-y-2 shadow-md' : 'bg-transparent'"
        >
          <i class="ri-file-list-3-fill text-2xl transition-colors"
             :class="isActive('/mutasi') ? 'text-[#016B61]' : 'text-[#70B2B2] group-hover:text-white'"></i>
        </div>
        <span class="text-[10px] font-medium transition-colors"
              :class="isActive('/mutasi') ? 'text-white' : 'text-[#70B2B2]'">Mutasi</span>
      </router-link>

      <div class="relative -top-8 w-16 flex flex-col items-center justify-start h-full">
         <div class="w-[72px] h-[72px] bg-[#016B61] rounded-full flex items-center justify-center absolute -top-1">
            <router-link to="/qris" class="w-16 h-16 bg-[#E5E9C5] rounded-full flex items-center justify-center shadow-lg border-4 border-gray-50 cursor-pointer transform hover:scale-105 transition active:scale-95 group">
              <i class="ri-qr-scan-2-line text-3xl text-[#016B61] group-hover:rotate-90 transition-transform duration-500"></i>
            </router-link>
        </div>
         <span class="text-[10px] font-medium text-white absolute -bottom-1">QRIS</span>
      </div>

      <router-link to="/pesan" class="flex flex-col items-center gap-1 w-16 group">
        <div 
          class="w-10 h-10 rounded-full flex items-center justify-center transition-all duration-300"
          :class="isActive('/pesan') ? 'bg-[#E5E9C5] -translate-y-2 shadow-md' : 'bg-transparent'"
        >
          <i class="ri-mail-fill text-2xl transition-colors"
             :class="isActive('/pesan') ? 'text-[#016B61]' : 'text-[#70B2B2] group-hover:text-white'"></i>
        </div>
        <span class="text-[10px] font-medium transition-colors"
              :class="isActive('/pesan') ? 'text-white' : 'text-[#70B2B2]'">Pesan</span>
      </router-link>

      <router-link to="/akun" class="flex flex-col items-center gap-1 w-16 group">
        <div 
          class="w-10 h-10 rounded-full flex items-center justify-center transition-all duration-300"
          :class="isActive('/akun') ? 'bg-[#E5E9C5] -translate-y-2 shadow-md' : 'bg-transparent'"
        >
          <i class="ri-user-settings-fill text-2xl transition-colors"
             :class="isActive('/akun') ? 'text-[#016B61]' : 'text-[#70B2B2] group-hover:text-white'"></i>
        </div>
        <span class="text-[10px] font-medium transition-colors"
              :class="isActive('/akun') ? 'text-white' : 'text-[#70B2B2]'">Akun</span>
      </router-link>

    </div>
  </nav>
</template>
<script setup>
import { useRoute } from 'vue-router';

// Gunakan route untuk mendeteksi menu yang aktif
const route = useRoute();

// Fungsi cek aktif (untuk styling)
const isActive = (path) => route.path === path;
</script>
