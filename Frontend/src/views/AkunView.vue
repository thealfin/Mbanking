<template>
  <div class="min-h-screen bg-gray-50 pb-32 relative">
    <div class="h-48 bg-[#016B61] rounded-b-[40px] relative z-0"></div>

    <div class="px-6 -mt-32 relative z-10">
        <div class="bg-white rounded-3xl shadow-xl p-6 text-center">
            <div class="w-24 h-24 bg-gray-200 rounded-full mx-auto border-4 border-white shadow-md overflow-hidden -mt-16 mb-4">
                 <img src="https://i.pravatar.cc/150?img=11" class="w-full h-full object-cover">
            </div>
            
            <h2 class="text-xl font-bold text-gray-800">
                {{ user?.full_name || 'Memuat...' }}
            </h2>
            <p class="text-sm text-gray-500">
                {{ user?.email || '...' }}
            </p>
            <p class="text-xs text-[#016B61] mt-1 font-medium">
                {{ user?.phone_number || '-' }}
            </p>

            <div class="mt-6 bg-gradient-to-r from-gray-800 to-gray-700 rounded-xl p-4 text-white text-left shadow-lg relative overflow-hidden">
                <i class="ri-visa-line text-4xl opacity-50 absolute right-4 bottom-2"></i>
                <p class="text-[10px] text-gray-300">Debit Card</p>
                <p class="font-mono text-lg tracking-widest mt-1 mb-3">
                    {{ formatCard(account?.card_number) }}
                </p>
                <div class="flex justify-between text-[10px]">
                    <span>EXP 12/28</span>
                    <span>CVV ***</span>
                </div>
            </div>
        </div>

        <div class="mt-6 space-y-3">
             <button class="w-full bg-white p-4 rounded-xl shadow-sm flex justify-between items-center hover:bg-gray-50">
                 <div class="flex items-center gap-3 text-gray-700">
                     <i class="ri-lock-password-line text-xl text-[#016B61]"></i>
                     <span class="text-sm font-medium">Ubah Kata Sandi</span>
                 </div>
                 <i class="ri-arrow-right-s-line text-gray-400"></i>
             </button>
             
             <button class="w-full bg-white p-4 rounded-xl shadow-sm flex justify-between items-center hover:bg-gray-50">
                 <div class="flex items-center gap-3 text-gray-700">
                     <i class="ri-customer-service-2-line text-xl text-[#016B61]"></i>
                     <span class="text-sm font-medium">Pusat Bantuan</span>
                 </div>
                 <i class="ri-arrow-right-s-line text-gray-400"></i>
             </button>

             <button class="w-full bg-red-50 p-4 rounded-xl shadow-sm flex justify-between items-center mt-6">
                 <div class="flex items-center gap-3 text-red-600">
                     <i class="ri-logout-box-r-line text-xl"></i>
                     <span class="text-sm font-bold">Keluar Aplikasi</span>
                 </div>
             </button>
        </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { supabase } from '@/lib/supabase';

// 1. Definisikan State Lokal
const user = ref({});
const account = ref({});
const userId = 4; // ID statis sesuai request sebelumnya (bisa diubah nanti ambil dari login)

// 2. Fungsi Fetch Data Lokal
const fetchData = async () => {
    try {
        const { data, error } = await supabase
            .from('accounts')
            .select(`
                *,
                users (*)
            `)
            .eq('user_id', userId)
            .single();
        
        if (error) throw error;
        
        if (data) {
            account.value = data;
            user.value = data.users;
        }
    } catch (error) {
        console.error("Gagal ambil data profil dari Supabase:", error.message);
    }
};

// 3. Jalankan saat komponen dimuat
onMounted(() => {
    fetchData();
});

// 4. Helper Function
const formatCard = (num) => {
    if(!num) return '•••• •••• •••• ••••';
    return num.replace(/(\d{4})(?=\d)/g, '$1 ');
}
</script>