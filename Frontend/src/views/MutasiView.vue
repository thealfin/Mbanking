<template>
  <div class="pt-8 px-6 pb-32 min-h-screen bg-gray-50">
    <div class="mb-6 flex justify-between items-end gap-2">
      <div class="flex-1 min-w-0">
        <h1 class="text-2xl font-bold text-[#016B61]">Mutasi Rekening</h1>
        <p class="text-sm text-gray-500 truncate">
          {{ accountName ? accountName : 'Memuat...' }}
        </p>
      </div>
      
      <div class="relative w-[35%] max-w-[150px] shrink-0">
        <select 
          v-model="selectedType" 
          class="block w-full pl-3 pr-8 py-2 text-[10px] font-bold text-gray-700 bg-white border border-gray-200 rounded-lg focus:outline-none focus:border-[#016B61] shadow-sm appearance-none cursor-pointer"
        >
          <option value="ALL">Semua Tipe</option>
          <option 
            v-for="(type, index) in transactionTypes" 
            :key="index" 
            :value="type"
          >
            {{ type }}
          </option>
        </select>
        
        <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center px-2 text-gray-700">
          <i class="ri-filter-3-line text-[#016B61] text-xs"></i>
        </div>
      </div>
    </div>

    <div v-if="loading" class="flex flex-col items-center justify-center py-20">
        <div class="animate-spin rounded-full h-10 w-10 border-b-2 border-[#016B61]"></div>
        <p class="text-xs text-gray-400 mt-2">Sinkronisasi data bank...</p>
    </div>

    <div v-else class="space-y-4">
      <div 
        v-for="(item, index) in filteredTransactions" 
        :key="index" 
        @click="viewDetail(item)"
        class="bg-white p-4 rounded-2xl shadow-sm border border-gray-100 flex justify-between items-center transition hover:shadow-md active:scale-95 cursor-pointer"
      >
        
        <div class="flex items-center gap-4 overflow-hidden">
          <div class="w-12 h-12 shrink-0 rounded-xl flex items-center justify-center text-xl font-bold transition-colors"
               :class="item.mutation_type === 'CREDIT' ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'">
             <i :class="item.mutation_type === 'CREDIT' ? 'ri-arrow-down-line' : 'ri-arrow-up-line'"></i>
          </div>
          
          <div class="min-w-0">
             <h3 class="font-bold text-gray-800 text-sm truncate pr-2">{{ item.description }}</h3>
             <p class="text-[10px] text-gray-400 truncate">{{ formatDate(item.created_at || item.transaction_date) }}</p>
             
             <span class="text-[10px] px-2 py-0.5 rounded bg-gray-100 text-gray-500 font-medium uppercase tracking-wide mt-1 inline-block">
               {{ item.transaction_type }}
             </span>
          </div>
        </div>

        <div class="text-right shrink-0 ml-2">
           <p class="font-bold text-sm" :class="item.mutation_type === 'CREDIT' ? 'text-green-600' : 'text-red-500'">
             {{ item.mutation_type === 'CREDIT' ? '+' : '-' }} {{ formatRupiah(item.amount) }}
           </p>
           <p class="text-[10px] text-gray-400 uppercase font-medium">{{ item.label }}</p>
        </div>
      </div>

      <div v-if="filteredTransactions.length === 0" class="text-center py-10 text-gray-400">
        <div class="bg-gray-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-3">
            <i class="ri-file-list-3-line text-2xl text-gray-400"></i>
        </div>
        <p class="text-sm font-medium">Tidak ada transaksi ditemukan.</p>
        <p class="text-xs mt-1">Coba ubah filter atau lakukan transaksi.</p>
      </div>
    </div>

    <!-- MODAL DETAIL TRANSAKSI -->
    <div v-if="showDetail" class="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4 animate-fade-in">
        <div class="bg-white w-full max-w-sm rounded-[30px] overflow-hidden shadow-2xl animate-scale-up relative">
            <!-- Header Background & Icon -->
            <div class="bg-[#016B61] p-8 text-center relative overflow-hidden">
                <div class="absolute top-0 left-0 w-full h-full opacity-10 bg-[url('https://www.transparenttextures.com/patterns/cubes.png')]"></div>
                <div class="w-16 h-16 bg-white/20 rounded-full flex items-center justify-center mx-auto mb-4 backdrop-blur-sm border-2 border-white/30">
                    <i class="ri-history-line text-3xl text-white"></i>
                </div>
                <h2 class="text-xl font-bold text-white mb-1">Detail Transaksi</h2>
                <p class="text-xs text-teal-100 opacity-90">{{ selectedTransaction.transaction_code }}</p>
            </div>

            <!-- Content Area -->
            <div class="p-6 relative">
                <!-- Status Badge -->
                <div class="absolute -top-4 left-1/2 -translate-x-1/2 px-6 py-2 bg-white rounded-full shadow-lg border border-gray-100 flex items-center gap-2">
                    <div class="w-2 h-2 rounded-full" :class="selectedTransaction.transaction_status === 'SUCCESS' ? 'bg-green-500' : 'bg-orange-500'"></div>
                    <span class="text-[10px] font-bold text-gray-600 uppercase tracking-widest">{{ selectedTransaction.transaction_status }}</span>
                </div>

                <div class="mt-4 space-y-4">
                    <!-- Amount Section -->
                    <div class="text-center py-4 border-b border-gray-100">
                        <p class="text-[10px] text-gray-400 uppercase font-bold tracking-widest mb-1">Nominal Transaksi</p>
                        <h3 class="text-2xl font-black text-gray-800" :class="selectedTransaction.mutation_type === 'CREDIT' ? 'text-green-600' : 'text-red-500'">
                            {{ selectedTransaction.mutation_type === 'CREDIT' ? '+' : '-' }} {{ formatRupiah(selectedTransaction.amount) }}
                        </h3>
                    </div>

                    <!-- Details List -->
                    <div class="space-y-3">
                        <div class="flex justify-between items-start">
                            <span class="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Pengirim</span>
                            <div class="text-right">
                                <p class="text-xs font-bold text-gray-700">{{ selectedTransaction.sender_name }}</p>
                                <p class="text-[9px] font-medium text-gray-500">{{ selectedTransaction.sender_account }}</p>
                            </div>
                        </div>

                        <div class="flex justify-between items-start">
                            <span class="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Penerima</span>
                            <div class="text-right">
                                <p class="text-xs font-bold text-gray-700">{{ selectedTransaction.recipient_name }}</p>
                                <p class="text-[9px] font-medium text-gray-400">{{ selectedTransaction.bank_name }} ({{ selectedTransaction.bank_id }})</p>
                                <p class="text-[9px] font-medium text-gray-500">{{ selectedTransaction.recipient_account }}</p>
                            </div>
                        </div>

                        <div class="flex justify-between items-center">
                            <span class="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Tipe</span>
                            <span class="text-xs font-bold text-[#016B61]">{{ selectedTransaction.transaction_type }}</span>
                        </div>

                        <div class="flex justify-between items-start">
                            <span class="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Catatan</span>
                            <p class="text-xs font-medium text-gray-600 text-right max-w-[150px] italic">"{{ selectedTransaction.description || '-' }}"</p>
                        </div>

                        <div class="flex justify-between items-center">
                            <span class="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Waktu</span>
                            <span class="text-[10px] font-bold text-gray-600">{{ formatDate(selectedTransaction.created_at) }}</span>
                        </div>
                    </div>

                    <!-- Action Button -->
                    <button 
                        @click="showDetail = false" 
                        class="w-full mt-4 py-3 bg-[#016B61] text-white font-bold rounded-xl text-sm shadow-lg shadow-teal-900/20 hover:bg-[#005a52] transition active:scale-95"
                    >
                        Tutup
                    </button>
                </div>
            </div>
        </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { supabase } from '@/lib/supabase';

// 1. State
const transactions = ref([]);
const accountName = ref('');
const loading = ref(false);
const selectedType = ref('ALL');
const showDetail = ref(false);
const selectedTransaction = ref(null);

// Hardcode User ID (Sesuai database dummy)
const userId = 4; 

// List Tipe Transaksi
const transactionTypes = ['TRANSFER', 'TOPUP', 'PAYMENT', 'PENARIKAN', 'DEPOSIT'];

// 2. Fetch Data
const getMutationData = async () => {
    loading.value = true;
    try {
        // 1. Ambil Data Akun User
        const { data: accountData, error: accountError } = await supabase
            .from('accounts')
            .select(`
                account_id,
                users (full_name)
            `)
            .eq('user_id', userId)
            .single();

        if (accountError) throw accountError;
        
        if (accountData) {
            accountName.value = accountData.users.full_name;
            const myAccountId = accountData.account_id;

            // 2. Ambil Mutasi dengan Join Transaksi & Akun
            const { data: mutasiData, error: mutasiError } = await supabase
                .from('account_mutations')
                .select(`
                    *,
                    transactions (
                        *,
                        ref_banks (bank_name),
                        source:accounts!transactions_source_account_id_fkey (
                            account_number,
                            users (full_name)
                        ),
                        destination:accounts!transactions_destination_account_id_fkey (
                            account_number,
                            users (full_name)
                        )
                    )
                `)
                .eq('account_id', myAccountId)
                .order('created_at', { ascending: false });

            if (mutasiError) throw mutasiError;

            if (mutasiData) {
                transactions.value = mutasiData.map(m => {
                    const t = m.transactions;
                    return {
                        ...m,
                        transaction_code: t.transaction_code,
                        transaction_type: t.transaction_type,
                        transaction_status: t.status,
                        description: t.description || (m.mutation_type === 'CREDIT' ? 'Transfer Masuk' : 'Transfer Keluar'),
                        amount: parseFloat(m.amount),
                        label: m.mutation_type === 'CREDIT' ? 'Masuk' : 'Keluar',
                        // Data untuk Detail
                        sender_name: t.source?.users?.full_name || 'System',
                        sender_account: t.source?.account_number || '-',
                        recipient_name: t.destination?.users?.full_name || t.account_destination || 'Penerima Luar',
                        recipient_account: t.destination?.account_number || t.account_destination || '-',
                        bank_name: t.ref_banks?.bank_name || 'Bank Lain',
                        bank_id: t.bank_code || '-'
                    };
                });
            }
        }
    } catch (error) {
        console.error("Gagal mengambil data dari Supabase:", error.message);
    } finally {
        loading.value = false;
    }
};

// 3. View Detail
const viewDetail = (item) => {
    selectedTransaction.value = item;
    showDetail.value = true;
};

// 4. Computed Property Filter
const filteredTransactions = computed(() => {
    if (selectedType.value === 'ALL') {
        return transactions.value;
    }
    return transactions.value.filter(t => t.transaction_type === selectedType.value);
});

// 4. Helper Formatting
const formatRupiah = (number) => {
    return new Intl.NumberFormat('id-ID', { 
        style: 'currency', 
        currency: 'IDR', 
        minimumFractionDigits: 0 
    }).format(number);
};

const formatDate = (dateString) => {
    if(!dateString) return "-";
    const date = new Date(dateString);
    return new Intl.DateTimeFormat('id-ID', { 
        day: 'numeric', 
        month: 'short', 
        year: 'numeric', 
        hour: '2-digit', 
        minute: '2-digit' 
    }).format(date);
};

// 5. Jalankan saat mounted
onMounted(() => {
    getMutationData();
});
</script>