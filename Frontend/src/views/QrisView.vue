<template>
  <div class="h-screen bg-black relative flex flex-col items-center justify-center overflow-hidden">
     
     <div class="absolute inset-0 z-20 flex flex-col justify-between py-12 px-6 pointer-events-none">
         <div class="flex justify-between items-center text-white pointer-events-auto">
             <router-link to="/" class="bg-white/20 p-2 rounded-full backdrop-blur-md hover:bg-white/30 transition">
                 <i class="ri-close-line text-2xl"></i>
             </router-link>
             <h2 class="font-bold text-lg">Scan QRIS</h2>
             <button @click="toggleFlash" class="bg-white/20 p-2 rounded-full backdrop-blur-md hover:bg-white/30 transition pointer-events-auto">
                 <i :class="flashOn ? 'ri-flashlight-fill' : 'ri-flashlight-line'" class="text-2xl"></i>
             </button>
         </div>

         <div class="text-center text-white mb-20">
             <p class="text-sm opacity-80" v-if="!processing">Arahkan kamera ke kode QR</p>
             <p class="text-sm font-bold animate-pulse text-yellow-300" v-else>Memproses Pembayaran...</p>
             
             <p class="text-[10px] mt-2 text-[#E5E9C5]">
                {{ account ? `Rekening Aktif: ${account.account_number}` : 'Memuat data akun...' }}
             </p>
         </div>
     </div>

     <div class="w-64 h-64 border-4 border-[#E5E9C5] rounded-3xl relative z-10 flex items-center justify-center box-glow pointer-events-none">
         <div v-if="!processing" class="w-full h-1 bg-red-500 absolute top-0 scan-line shadow-[0_0_15px_rgba(255,0,0,0.8)]"></div>
         <i v-else class="ri-loader-4-line animate-spin text-6xl text-white"></i>
     </div>

     <div class="absolute inset-0 z-0 bg-black">
        <div id="reader" class="w-full h-full object-cover"></div>
     </div>

     <div v-if="message" class="absolute bottom-10 z-50 px-6 w-full">
        <div class="p-4 rounded-xl text-center font-bold shadow-lg transition-all transform duration-300"
             :class="isError ? 'bg-red-500 text-white' : 'bg-green-500 text-white'">
            {{ message }}
        </div>
     </div>

  </div>
</template>

<script setup>
import { onMounted, onUnmounted, ref } from 'vue';
import { Html5Qrcode } from "html5-qrcode";
import { useRouter } from 'vue-router';

// 1. State & Router
const router = useRouter();
// HAPUS INJECT GLOBAL STATE
// const globalState = inject('globalState'); 

// GANTI DENGAN LOCAL STATE
const account = ref(null); 
const userId = 4; // Hardcode ID sesuai request sebelumnya (bisa diubah nanti ambil dari login)

const processing = ref(false);
const message = ref("");
const isError = ref(false);
const flashOn = ref(false);
let html5QrCode = null;

// 2. Fungsi Fetch Data Akun (Local)
const fetchAccountData = async () => {
    try {
        const response = await fetch('/api/dashboard/all');
        const result = await response.json();
        
        if (result.status === 'success') {
            // Cari akun milik user ID 4
            const foundAccount = result.data.accounts.find(a => a.user_id == userId);
            account.value = foundAccount || null;
        }
    } catch (error) {
        console.error("Gagal memuat data akun:", error);
        isError.value = true;
        message.value = "Gagal memuat data rekening. Cek koneksi.";
    }
};

// 3. Fungsi Proses Pembayaran
const processPayment = async (qrDataString) => {
    // Pastikan data akun sudah terload sebelum bayar
    if (!account.value) {
        isError.value = true;
        message.value = "Data akun belum siap. Tunggu sebentar...";
        return;
    }

    if(html5QrCode) {
        await html5QrCode.stop();
        html5QrCode = null;
    }

    processing.value = true;

    try {
        // A. Parse JSON QR
        let qrData;
        try {
            qrData = JSON.parse(qrDataString);
        } catch (e) {
            throw new Error("Format QR Code salah (Bukan JSON)");
        }

        // B. Validasi Isi QR
        if (!qrData.amount || !qrData.merchant_name) {
            throw new Error("QR Code tidak valid (Kurang data)");
        }

        // C. Kirim ke Backend (Gunakan ID dari Local State)
        const payload = {
            source_account_id: account.value.account_id, // AMBIL DARI LOCAL STATE
            amount: qrData.amount,
            merchant_name: qrData.merchant_name
        };

        const response = await fetch('/api/qris/pay', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });

        const result = await response.json();

        if (result.status === 'success') {
            isError.value = false;
            message.value = `Berhasil bayar Rp ${qrData.amount}`;
            
            setTimeout(() => {
                router.push('/');
            }, 2000);
        } else {
            throw new Error(result.message || "Pembayaran Gagal");
        }

    } catch (error) {
        isError.value = true;
        message.value = error.message;
        
        setTimeout(() => {
            window.location.reload(); 
        }, 3000);
    } finally {
        processing.value = false;
    }
};

// 4. Inisialisasi (Fetch Data & Start Camera)
onMounted(async () => {
    // A. Ambil Data Akun dulu
    await fetchAccountData();

    // B. Baru nyalakan kamera
    html5QrCode = new Html5Qrcode("reader");
    const config = { fps: 10, qrbox: { width: 250, height: 250 } };
    
    html5QrCode.start(
        { facingMode: "environment" }, 
        config, 
        (decodedText) => {
            processPayment(decodedText);
        },
        (errorMessage) => {
            // ignore error scanning frame
        }
    ).catch(err => {
        isError.value = true;
        message.value = "Kamera error: " + err;
    });
});

onUnmounted(() => {
    if (html5QrCode) {
        html5QrCode.stop().catch(err => console.error(err));
    }
});

const toggleFlash = () => {
   flashOn.value = !flashOn.value;
};
</script>

<style scoped>
.scan-line {
    animation: scan 2s infinite linear;
}

@keyframes scan {
    0% { top: 0%; opacity: 0; }
    10% { opacity: 1; }
    90% { opacity: 1; }
    100% { top: 100%; opacity: 0; }
}

.box-glow {
    box-shadow: 0 0 0 1000px rgba(0,0,0,0.6);
}

:deep(#reader) {
    width: 100%;
    height: 100%;
    overflow: hidden;
}
:deep(#reader video) {
    object-fit: cover;
    width: 100% !important;
    height: 100% !important;
    border-radius: 0 !important;
}
</style>