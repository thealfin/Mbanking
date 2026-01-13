<template>
  <header class="bg-[#E5E9C5] pt-12 pb-24 px-6 rounded-b-[40px] relative z-10 shadow-sm">
    <div class="flex justify-between items-center mb-6">
      <div class="flex items-center gap-2">
        <div class="w-10 h-10 bg-[#016B61] rounded-full flex items-center justify-center text-white font-bold text-xl">M</div>
          <div>
            <p class="text-xs text-gray-600 font-medium">{{ greeting }}</p>
            <h1 class="font-bold text-[#016B61] text-lg truncate w-40">
              {{ user?.full_name || 'Memuat...' }}
            </h1>
          </div>
      </div>
      <div class="flex items-center gap-3">
        <router-link to="/pesan">
          <button class="relative p-2 bg-white/50 rounded-full hover:bg-white transition">
            <span class="absolute top-2 right-2 w-2 h-2 bg-red-500 rounded-full border border-white"></span>
            <i class="ri-notification-3-line text-[#016B61] text-xl"></i>
          </button>
        </router-link>
        <router-link to="/akun">
          <div class="w-10 h-10 rounded-full bg-gray-300 overflow-hidden border-2 border-white">
            <img src="https://i.pravatar.cc/150?img=11" alt="Profile" class="w-full h-full object-cover">
          </div>
        </router-link>
      </div>
    </div>
  </header>

  <div class="px-6 -mt-16 pb-32 z-20 relative">
    
    <div class="bg-gradient-to-br from-[#016B61] to-[#70B2B2] rounded-3xl p-6 shadow-xl text-white mb-8 relative overflow-hidden group">
      <div class="absolute -right-6 -top-6 w-32 h-32 bg-white/10 rounded-full blur-2xl group-hover:bg-white/20 transition duration-700"></div>
      <div class="relative z-10">
        <div class="flex justify-between items-start mb-2">
          <div>
            <p class="text-xs text-green-100 mb-1">Rekening Bank HAWKINS</p>
            <p class="text-sm opacity-80 font-mono tracking-widest">
              {{ account?.account_number || '---- ----' }}
            </p>
          </div>
          <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/4/41/Visa_Logo.png/640px-Visa_Logo.png" class="h-4 opacity-70 bg-white/90 px-1 rounded" alt="Visa">
        </div>
        <div class="mt-6">
          <p class="text-xs text-green-100 mb-1">Saldo Aktif</p>
          <div class="flex items-center gap-3">
            <h2 class="text-3xl font-bold tracking-tight">
              {{ showBalance ? formatRupiah(account?.balance || 0) : 'Rp •••••••••' }}
            </h2>
            <button @click="showBalance = !showBalance" class="text-green-200 hover:text-white transition">
              <i :class="showBalance ? 'ri-eye-line' : 'ri-eye-off-line'" class="text-xl"></i>
            </button>
          </div>
        </div>
      </div>
    </div>

    <div class="grid grid-cols-4 gap-y-6 gap-x-2 mb-8">
      <div 
        v-for="(menu, index) in menus" 
        :key="index" 
        @click="navigateTo(menu.path)"
        class="flex flex-col items-center gap-2 cursor-pointer group"
      >
        <div class="w-14 h-14 rounded-2xl flex items-center justify-center shadow-sm text-2xl transition transform group-hover:scale-110 group-active:scale-95" :class="menu.color">
          <i :class="menu.icon"></i>
        </div>
        <span class="text-[10px] font-medium text-gray-600 text-center leading-tight">{{ menu.name }}</span>
      </div>
    </div>

    <div class="mb-8">
      <div class="flex justify-between items-center mb-3">
        <h3 class="font-bold text-[#016B61] text-lg">Link E-Wallet</h3>
        <a href="#" class="flex items-center gap-1 text-[#016B61] text-xs font-bold hover:underline transition">
          Hubungkan <i class="ri-links-line"></i>
        </a>
      </div>
      <div class="grid grid-cols-5 gap-2 bg-white p-4 rounded-3xl shadow-sm border border-gray-50">
        <div v-for="wallet in ewallets" :key="wallet.name" class="flex flex-col items-center gap-2">
          <div class="w-12 h-12 rounded-2xl overflow-hidden border border-gray-100 p-2 bg-white flex items-center justify-center shadow-inner">
            <img :src="wallet.logo" :alt="wallet.name" class="w-full h-full object-contain transition transform hover:scale-110 cursor-pointer">
          </div>
          <span class="text-[8px] font-bold text-[#016B61] uppercase text-center">{{ wallet.name }}</span>
        </div>
      </div>
    </div>

    <div class="mb-8">
       <div class="bg-[#014d46] rounded-3xl p-5 text-white flex justify-between items-center relative overflow-hidden shadow-lg border border-[#016B61]">
          <div class="z-10 relative">
             <p class="text-[10px] uppercase tracking-wider text-green-200 font-bold">Eksklusif Untukmu</p>
             <h4 class="text-lg font-bold leading-tight mt-1">Kartu Kredit <br> Platinum Pro</h4>
             <button class="mt-3 px-4 py-1.5 bg-[#E5E9C5] text-[#016B61] rounded-full text-[10px] font-bold shadow-md hover:bg-white transition">Ajukan Sekarang</button>
          </div>
          <div class="w-24 h-16 bg-gradient-to-tr from-gray-200 to-gray-400 rounded-lg transform rotate-12 shadow-2xl relative z-10 flex flex-col p-2">
             <div class="w-4 h-3 bg-yellow-400 rounded-sm mb-2"></div>
             <div class="mt-auto text-[6px] font-mono text-gray-800">4541 2234 **** ****</div>
          </div>
          <div class="absolute -right-4 -bottom-4 w-24 h-24 bg-white/5 rounded-full blur-xl"></div>
       </div>
    </div>

    <div class="mb-8">
      <div class="flex justify-between items-end mb-3">
        <h3 class="font-bold text-[#016B61] text-lg">Pasar Saham</h3>
        <span class="text-xs text-[#70B2B2] font-semibold">Cek Portfolio</span>
      </div>
      <div class="bg-white rounded-3xl border border-gray-100 shadow-sm overflow-hidden">
        <div v-for="stock in stocks" :key="stock.ticker" class="flex justify-between items-center p-4 border-b border-gray-50 last:border-0 hover:bg-gray-50 transition">
           <div class="flex items-center gap-3">
              <div class="w-8 h-8 rounded-lg bg-gray-100 flex items-center justify-center font-bold text-[#016B61] text-[10px]">{{ stock.ticker[0] }}</div>
              <div>
                 <p class="text-xs font-bold text-gray-800">{{ stock.ticker }}</p>
                 <p class="text-[9px] text-gray-400">{{ stock.company }}</p>
              </div>
           </div>
           <div class="text-right">
              <p class="text-xs font-bold text-gray-800">{{ formatRupiah(stock.price) }}</p>
              <p class="text-[9px]" :class="stock.change >= 0 ? 'text-green-500' : 'text-red-500'">
                 {{ stock.change >= 0 ? '▲' : '▼' }} {{ Math.abs(stock.change) }}%
              </p>
           </div>
        </div>
      </div>
    </div>

    <div class="mb-12">
       <h3 class="font-bold text-[#016B61] text-lg mb-4">Produk Pilihan</h3>
       <div class="grid grid-cols-2 gap-4">
          <div v-for="prod in products" :key="prod.title" class="bg-white p-4 rounded-3xl border border-gray-100 shadow-sm flex flex-col gap-3 hover:border-[#70B2B2] transition cursor-pointer">
             <div class="w-10 h-10 rounded-xl flex items-center justify-center text-xl" :class="prod.bg">
                <i :class="prod.icon"></i>
             </div>
             <div>
                <p class="text-xs font-bold text-gray-800">{{ prod.title }}</p>
                <p class="text-[9px] text-gray-400 mt-0.5 leading-tight">{{ prod.desc }}</p>
             </div>
          </div>
       </div>
    </div>

    <div>
      <h3 class="font-bold text-[#016B61] text-lg mb-4">Transaksi Terakhir</h3>
      
      <div v-if="isLoading" class="text-center text-gray-400 text-sm py-4">
        <i class="ri-loader-4-line animate-spin text-2xl"></i>
        <p>Memuat data...</p>
      </div>

      <div v-else class="space-y-4">
        <div v-for="trx in recentTransactions" :key="trx.id" class="flex justify-between items-center p-4 bg-white border border-gray-100 rounded-2xl shadow-sm hover:shadow-md transition">
          <div class="flex items-center gap-4">
            <div class="w-10 h-10 rounded-full bg-gray-50 flex items-center justify-center text-[#016B61]">
              <i v-if="trx.type === 'TRANSFER'" class="ri-arrow-left-right-line text-lg"></i>
              <i v-else-if="trx.type === 'TOPUP'" class="ri-wallet-3-line text-lg"></i>
              <i v-else-if="trx.type === 'PAYMENT'" class="ri-bill-line text-lg"></i>
              <i v-else class="ri-exchange-dollar-line text-lg"></i>
            </div>
            <div>
              <p class="font-bold text-gray-800 text-sm">{{ trx.description }}</p>
              <p class="text-xs text-gray-500">{{ trx.type }} • {{ trx.date }}</p>
            </div>
          </div>
          <span :class="trx.is_income ? 'text-green-600' : 'text-red-500'" class="font-bold text-sm">
            {{ trx.is_income ? '+' : '-' }}{{ formatRupiah(trx.amount) }}
          </span>
        </div>
        
        <div v-if="recentTransactions.length === 0" class="text-center text-gray-400 text-xs py-2">
            Belum ada transaksi terbaru.
        </div>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router'; 
import { supabase } from '@/lib/supabase';

// --- ROUTER SETUP ---
const router = useRouter(); 

const navigateTo = (path) => {
  if (path) {
    router.push(path);
  }
};

// 1. Definisikan State Lokal
const user = ref({});
const account = ref({});
const recentTransactions = ref([]);
const isLoading = ref(true);
const showBalance = ref(false);
const greeting = ref("");
const userId = 4; // Tetap gunakan ID 4 (Mike Wheeler) sesuai data m-banking.sql

// 2. Fungsi Fetch Data via Supabase
const fetchData = async () => {
    try {
        isLoading.value = true;
        
        // 1. Ambil data User & Account (Join)
        const { data: accountData, error: accountError } = await supabase
            .from('accounts')
            .select(`
                *,
                users (
                    full_name,
                    email
                )
            `)
            .eq('user_id', userId)
            .single();

        if (accountError) throw accountError;

        if (accountData) {
            user.value = {
                full_name: accountData.users.full_name,
                email: accountData.users.email
            };
            account.value = accountData;
        }

        // 2. Ambil Mutasi Terakhir
        const { data: mutationData, error: mutationError } = await supabase
            .from('account_mutations')
            .select(`
                *,
                transactions (
                    transaction_type,
                    description
                )
            `)
            .eq('account_id', accountData.account_id)
            .order('created_at', { ascending: false })
            .limit(5);

        if (mutationError) throw mutationError;

        if (mutationData) {
            recentTransactions.value = mutationData.map(m => {
                return {
                    id: m.mutation_id,
                    type: m.transactions?.transaction_type || (m.mutation_type === 'CREDIT' ? 'TOPUP' : 'PAYMENT'),
                    description: m.transactions?.description || (m.mutation_type === 'CREDIT' ? 'Transfer Masuk' : 'Transfer Keluar'),
                    amount: parseFloat(m.amount),
                    date: formatDateShort(m.created_at),
                    is_income: m.mutation_type === 'CREDIT'
                };
            });
        }
        
    } catch (error) {
        console.error("Gagal ambil data home dari Supabase:", error.message);
    } finally {
        isLoading.value = false;
    }
};

// --- DATA STATIS ---
// UPDATE: Menambahkan 'path' pada object Menu
const menus = [
  { name: 'Transfer', path: '/transfer', icon: 'ri-arrow-left-right-line', color: 'bg-green-100 text-[#016B61]' },
  { name: 'Virtual Account', path: null, icon: 'ri-wallet-line', color: 'bg-[#016B61] text-white' },
  { name: 'Top Up', path: null, icon: 'ri-wallet-3-line', color: 'bg-green-100 text-[#016B61]' },
  { name: 'E-Money', path: null, icon: 'ri-bank-card-line', color: 'bg-[#016B61] text-white' },
  { name: 'Tarik Tunai', path: null, icon: 'ri-money-dollar-circle-line', color: 'bg-green-100 text-[#016B61]' },
  { name: 'Payment', path: null, icon: 'ri-mastercard-line', color: 'bg-[#016B61] text-white' },
  { name: 'Invest', path: null, icon: 'ri-line-chart-line', color: 'bg-green-100 text-[#016B61]' },
  { name: 'Lainnya', path: null, icon: 'ri-more-fill', color: 'bg-[#016B61] text-white' },
];

const ewallets = [
  { name: 'Gopay', logo: 'https://cdn.brandfetch.io/idQqAF303b/w/400/h/400/theme/dark/icon.jpeg?c=1dxbfHSJFAPEGdCLU4o5B' },
  { name: 'LinkAja', logo: 'https://i.pinimg.com/736x/43/27/4e/43274e40524c1ffc73e847b3b5f16ceb.jpg' },
  { name: 'Dana', logo: 'https://1000logos.net/wp-content/uploads/2021/03/Dana-logo.png' },
  { name: 'Shopee', logo: 'https://i.pinimg.com/736x/d0/19/16/d019163d861908ed0046391ebfa42ce1.jpg' },
  { name: 'Ovo', logo: 'https://i.pinimg.com/1200x/41/25/e1/4125e1126d4042dfd278b30f20482926.jpg' }
];

const stocks = [
  { ticker: 'BBCA', company: 'Bank Central Asia', price: 9850, change: 1.2 },
  { ticker: 'BBRI', company: 'Bank Rakyat Indonesia', price: 6150, change: -0.5 },
  { ticker: 'TLKM', company: 'Telkom Indonesia', price: 3920, change: 0.8 }
];

const products = [
  { title: 'KPR', desc: 'Bunga mulai 3.5%', icon: 'ri-home-7-line', bg: 'bg-blue-50 text-blue-600' },
  { title: 'Tabungan Rencana', desc: 'Wujudkan impianmu', icon: 'ri-calendar-todo-line', bg: 'bg-purple-50 text-purple-600' },
  { title: 'Buka Baru', desc: 'Hanya butuh 5 menit', icon: 'ri-add-circle-line', bg: 'bg-orange-50 text-orange-600' },
  { title: 'Deposito', desc: 'Bunga kompetitif 5%', icon: 'ri-safe-2-line', bg: 'bg-green-50 text-green-600' }
];

const formatRupiah = (number) => {
  return new Intl.NumberFormat('id-ID', {
    style: 'currency', currency: 'IDR', minimumFractionDigits: 0
  }).format(number);
};

const formatDateShort = (dateString) => {
    if(!dateString) return "";
    const date = new Date(dateString);
    return new Intl.DateTimeFormat('id-ID', { day: '2-digit', month: 'short' }).format(date);
};

onMounted(() => {
  const hour = new Date().getHours();
  if (hour < 12) greeting.value = "Selamat Pagi";
  else if (hour < 18) greeting.value = "Selamat Siang";
  else greeting.value = "Selamat Malam";

  fetchData();
});
</script>

<style>
.no-scrollbar::-webkit-scrollbar {
    display: none;
}
.no-scrollbar {
    -ms-overflow-style: none;
    scrollbar-width: none;
}
</style>