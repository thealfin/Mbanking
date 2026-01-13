<template>
  <div class="pt-8 px-6 pb-32 min-h-screen bg-gray-50">
    <div class="mb-6 flex justify-between items-center">
      <div>
        <h1 class="text-2xl font-bold text-[#016B61]">Kotak Masuk</h1>
        <p class="text-xs text-gray-400">Notifikasi aktivitas akun Anda</p>
      </div>
      
      <span class="text-xs bg-red-100 text-red-600 px-3 py-1 rounded-full font-bold shadow-sm" v-if="logs.length > 0">
        {{ logs.length }} Pesan
      </span>
    </div>

    <div v-if="loading" class="flex flex-col items-center justify-center py-20">
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-[#016B61]"></div>
        <p class="text-xs text-gray-400 mt-2">Sinkronisasi pesan...</p>
    </div>

    <div v-else-if="logs.length === 0" class="flex flex-col items-center justify-center py-16 text-gray-400">
        <div class="bg-gray-100 p-4 rounded-full mb-3">
             <i class="ri-mail-open-line text-3xl opacity-50"></i>
        </div>
        <p class="text-sm font-medium">Belum ada pesan masuk.</p>
    </div>

    <div v-else class="space-y-3">
      <div v-for="(log, index) in logs" :key="index" class="bg-white p-4 rounded-xl shadow-sm border-l-4 border-[#016B61] flex gap-3 transition hover:shadow-md hover:translate-x-1 duration-200">
         
         <div class="mt-1 shrink-0">
             <div class="w-8 h-8 rounded-full bg-teal-50 flex items-center justify-center text-[#016B61]">
                <i :class="getIcon(log.activity_type)"></i>
             </div>
         </div>

         <div class="flex-1 min-w-0">
             <div class="flex justify-between items-start">
                 <h3 class="font-bold text-gray-800 text-sm capitalize truncate pr-2">
                    {{ formatTitle(log.activity_type) }}
                 </h3>
                 <span class="text-[10px] text-gray-400 whitespace-nowrap">{{ formatDate(log.created_at) }}</span>
             </div>
             <p class="text-xs text-gray-500 mt-1 leading-relaxed line-clamp-2">{{ log.description }}</p>
         </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';

// 1. State
const logs = ref([]);
const loading = ref(false);
const userId = 4; // user ID statis sesuai request sebelumnya (bisa diubah nanti ambil dari login)

// 2. Fetch Data (Pake endpoint khusus pesan, lebih cepat)
const fetchLogs = async () => {
    loading.value = true;
    try {
        const response = await fetch(`/api/messages/${userId}`);
        const result = await response.json();
        
        if (result.status === 'success') {
            logs.value = result.data;
        }
    } catch (e) {
        console.error("Pesan: Gagal mengambil data", e);
    } finally {
        loading.value = false;
    }
};

// 3. Helper Formatting
const formatDate = (dateStr) => {
    if (!dateStr) return '-';
    // Format tanggal yang lebih "manusiawi" (contoh: 10 Jan, 14:00)
    return new Intl.DateTimeFormat('id-ID', { 
        day: 'numeric', 
        month: 'short', 
        hour: '2-digit',
        minute: '2-digit'
    }).format(new Date(dateStr));
};

const formatTitle = (text) => {
    if(!text) return 'Info Sistem';
    // Hapus underscore dan rapikan huruf
    return text.replace(/_/g, ' ').toLowerCase().replace(/\b\w/g, l => l.toUpperCase());
};

// Helper Icon biar variatif
const getIcon = (type) => {
    if (!type) return 'ri-information-line';
    const t = type.toUpperCase();
    if (t.includes('LOGIN')) return 'ri-shield-user-line';
    if (t.includes('TRANSFER') || t.includes('PAYMENT')) return 'ri-wallet-3-line';
    if (t.includes('SECURITY') || t.includes('ALERT')) return 'ri-alarm-warning-line';
    return 'ri-notification-3-line';
};

// 4. Jalankan
onMounted(() => {
    fetchLogs();
});
</script>