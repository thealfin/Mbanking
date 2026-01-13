<template>
  <div class="bg-gray-50 min-h-screen pb-32 relative font-sans">
    
    <header class="bg-[#005e54] text-white pt-10 pb-6 px-6 relative z-10 rounded-b-[30px] shadow-md transition-all duration-300">
      <div class="flex items-center gap-4">
        <button @click="handleBack" class="p-2 hover:bg-white/10 rounded-full transition">
          <i class="ri-arrow-left-line text-xl"></i>
        </button>
        <h1 class="text-lg font-bold flex-1 text-center pr-10">
          {{ headerTitle }}
        </h1>
      </div>

      <div v-if="step === 1" class="mt-6 flex justify-center gap-2">
        <button class="px-4 py-1.5 bg-[#059c8e] text-white rounded-full text-xs font-bold border border-[#70B2B2]">Transfer Bank</button>
        <button class="px-4 py-1.5 text-gray-200 hover:text-white rounded-full text-xs font-medium">Upside Down</button>
      </div>
    </header>

    <div class="px-0 relative z-20 -mt-4">

      <div v-if="step === 1" class="px-4 animate-fade-in">
        
        <div class="mb-6 bg-white p-4 rounded-2xl shadow-sm border border-gray-100">
          <h3 class="font-bold text-[#016B61] text-sm mb-3">Transfer Terakhir</h3>
          <div class="flex gap-3 overflow-x-auto no-scrollbar pb-2">
            <div @click="goToStep(2)" class="flex-shrink-0 w-16 flex flex-col items-center gap-2 cursor-pointer group">
               <div class="w-12 h-12 rounded-full border-2 border-dashed border-[#016B61] flex items-center justify-center text-[#016B61] group-hover:bg-[#016B61] group-hover:text-white transition">
                 <i class="ri-add-line text-xl"></i>
               </div>
               <span class="text-[10px] text-center font-medium text-[#016B61]">Baru</span>
            </div>
            
            <div v-for="recent in recentTransfers" :key="recent.id" @click="selectRecent(recent)" class="flex-shrink-0 w-32 p-3 border border-gray-100 rounded-xl bg-white shadow-sm flex items-center gap-3 cursor-pointer hover:border-[#016B61] transition">
               <div class="w-8 h-8 rounded-full bg-[#E5E9C5] text-[#016B61] flex items-center justify-center font-bold text-xs">
                 {{ getInitials(recent.name) }}
               </div>
               <div class="overflow-hidden">
                 <p class="text-[10px] font-bold text-gray-800 truncate">{{ recent.name }}</p>
                 <p class="text-[8px] text-gray-500 truncate">{{ recent.bank }}</p>
               </div>
            </div>
          </div>
        </div>

        <div class="mx-4 mb-6 bg-gradient-to-r from-red-50 to-white p-4 rounded-xl border border-red-100 flex items-center justify-between shadow-sm">
           <div>
             <h4 class="text-xs font-bold text-gray-800">Gabung Hellfire Club!</h4>
             <p class="text-[10px] text-gray-500">Dapatkan promo dadu D&D setiap transfer.</p>
           </div>
           <i class="ri-fire-line text-red-500 text-xl"></i>
        </div>

        <div class="bg-white min-h-[400px] rounded-t-3xl shadow-[0_-4px_20px_rgba(0,0,0,0.05)] p-6">
          <div class="flex justify-between items-center mb-4">
            <h3 class="font-bold text-[#016B61] text-lg">Daftar Tersimpan</h3>
            <button @click="goToStep(2)" class="text-[#016B61] flex items-center gap-1 text-xs font-bold hover:underline">
              <i class="ri-add-line"></i> Tambah
            </button>
          </div>
          
          <div class="relative mb-4">
            <i class="ri-search-line absolute left-3 top-2.5 text-gray-400"></i>
            <input type="text" placeholder="Cari Daftar Tersimpan..." class="w-full pl-10 pr-4 py-2 bg-gray-50 border border-gray-200 rounded-lg text-sm focus:outline-none focus:border-[#016B61] transition">
          </div>

          <div v-if="savedContacts.length === 0" class="text-center py-10">
             <i class="ri-ghost-line text-4xl text-gray-200 mb-2"></i>
             <p class="text-xs text-gray-400">Belum ada kontak tersimpan.</p>
          </div>

          <div class="space-y-4 pb-20">
            <div v-for="contact in savedContacts" :key="contact.id" @click="selectSaved(contact)" class="flex items-center justify-between cursor-pointer group hover:bg-gray-50 p-2 rounded-lg transition -mx-2">
               <div class="flex items-center gap-3">
                 <div class="w-10 h-10 rounded-full bg-blue-600 text-white flex items-center justify-center font-bold text-sm group-hover:bg-[#016B61] transition shadow-sm">
                   {{ getInitials(contact.name) }}
                 </div>
                 <div>
                   <p class="font-bold text-gray-800 text-sm">{{ contact.name }}</p>
                   <p class="text-xs text-gray-500">{{ contact.bank }} • {{ contact.number }}</p>
                 </div>
               </div>
               
               <button @click.stop="promptDelete(contact)" class="bg-red-400 hover:bg-red-600 text-white px-2 py-1 rounded-lg transition-colors shadow-sm">
                 <i class="ri-delete-bin-line text-lg"></i>
               </button>

            </div>
          </div>
        </div>
        
        <div class="fixed bottom-6 left-0 w-full px-6 z-30">
          <button @click="goToStep(2)" class="w-full bg-[#007cc3] hover:bg-[#005e54] text-white font-bold py-3 rounded-lg shadow-lg transition flex justify-center items-center gap-2">
            Kirim ke Akun Baru
          </button>
        </div>
      </div>

      <div v-if="step === 2" class="bg-white min-h-screen animate-fade-in pt-4 px-4">
        <div class="relative mb-4">
           <i class="ri-search-line absolute left-3 top-3 text-gray-400"></i>
           <input v-model="searchBank" type="text" placeholder="Cari Bank..." class="w-full pl-10 pr-4 py-3 bg-white border border-gray-300 rounded-lg text-sm focus:outline-none focus:border-[#016B61]">
        </div>

        <div class="space-y-1 pb-20">
          <div v-for="bank in filteredBanks" :key="bank.code" @click="selectBank(bank)" class="p-4 border-b border-gray-100 hover:bg-gray-50 cursor-pointer flex justify-between items-center transition">
             <div class="flex items-center gap-3">
                <i class="ri-bank-line text-gray-400 text-xl"></i>
                <span class="font-bold text-gray-700 text-sm uppercase">{{ bank.name }}</span>
             </div>
             <i class="ri-arrow-right-s-line text-gray-300"></i>
          </div>
        </div>
      </div>

      <div v-if="step === 3" class="px-4 pt-6 animate-fade-in">
        <div class="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
           
           <div class="mb-4">
             <label class="block text-xs font-bold text-gray-500 mb-1">Tujuan Transfer</label>
             <div class="flex items-center justify-between p-3 bg-gray-50 rounded-lg border border-gray-200">
               <div class="flex items-center gap-2">
                 <i class="ri-bank-line text-[#016B61]"></i>
                 <span class="text-sm font-bold text-gray-800">{{ form.bankName }}</span>
               </div>
               <button @click="goToStep(2)" class="text-[#007cc3] text-xs font-bold">Ubah</button>
             </div>
           </div>

           <div class="mb-4">
             <label class="block text-xs font-bold text-gray-500 mb-1">Nomor Rekening</label>
             <div class="relative">
                <input v-model="form.accountNumber" type="number" placeholder="Contoh: 1234567890" class="w-full p-3 pl-3 pr-10 border border-gray-300 rounded-lg text-sm focus:outline-none focus:border-[#016B61] focus:ring-1 focus:ring-[#016B61] font-mono">
                <div v-if="isLoading" class="absolute right-3 top-3">
                    <i class="ri-loader-4-line animate-spin text-[#016B61]"></i>
                </div>
             </div>
           </div>
           
           <div v-if="inquiryResult" class="mt-4 p-4 bg-green-50 rounded-xl border border-green-100 animate-fade-in">
              <div class="flex items-center gap-3 mb-3">
                  <div class="w-10 h-10 bg-green-200 rounded-full flex items-center justify-center text-[#005e54] font-bold">
                    <i class="ri-user-check-line"></i>
                  </div>
                  <div>
                      <p class="text-[10px] text-gray-500 uppercase font-bold">Pemilik Rekening</p>
                      <p class="text-sm font-bold text-gray-800">{{ inquiryResult.full_name }}</p>
                  </div>
              </div>

              <div class="pt-3 border-t border-green-200/50">
                  <div class="flex items-center gap-2 mb-2">
                      <input type="checkbox" id="saveContact" v-model="isSaveContactChecked" class="w-4 h-4 text-[#005e54] rounded focus:ring-[#005e54]">
                      <label for="saveContact" class="text-xs font-bold text-gray-600">Simpan ke Daftar Tersimpan?</label>
                  </div>
                  
                  <div v-if="isSaveContactChecked" class="animate-fade-in pl-6">
                      <input v-model="contactAlias" type="text" placeholder="Nama Panggilan (Alias)" class="w-full p-2 text-xs border border-gray-300 rounded bg-white focus:border-[#005e54] focus:outline-none mb-2">
                      <button @click="saveContactToDb" :disabled="isSaving" class="px-3 py-1.5 bg-[#005e54] text-white text-[10px] font-bold rounded shadow-sm hover:bg-[#004d44] transition">
                          <span v-if="isSaving">Menyimpan...</span>
                          <span v-else>Simpan Sekarang</span>
                      </button>
                  </div>
              </div>
           </div>

           <p v-else class="text-[10px] text-gray-400 mt-4">Pastikan nomor rekening benar agar tidak tersasar.</p>
        </div>

        <div class="fixed bottom-0 left-0 w-full p-6 bg-white border-t border-gray-100 z-30 flex flex-col gap-3">
          <button v-if="!inquiryResult" @click="validateAccount" :disabled="!form.accountNumber || isLoading" :class="!form.accountNumber ? 'bg-gray-300' : 'bg-[#007cc3]'" class="w-full text-white font-bold py-3.5 rounded-lg shadow-lg transition flex justify-center items-center">
            <span v-if="isLoading">Mencari...</span>
            <span v-else>Cek Rekening</span>
          </button>

          <button v-else @click="goToStep(4)" class="w-full bg-[#005e54] text-white font-bold py-3.5 rounded-lg shadow-lg transition flex justify-center items-center">
              Lanjut Transfer <i class="ri-arrow-right-line ml-2"></i>
          </button>
          
          <button @click="cancelTransaction" class="w-full text-red-500 font-bold py-2 text-sm hover:bg-red-50 rounded-lg transition">
            Batalkan
          </button>
        </div>
      </div>

      <div v-if="step === 4" class="px-4 pt-4 animate-fade-in pb-40">
        
        <div class="bg-white p-4 rounded-xl shadow-sm border-l-4 border-[#016B61] mb-4 flex items-center gap-3">
           <div class="w-10 h-10 rounded-full bg-[#E5E9C5] text-[#016B61] flex items-center justify-center font-bold">
              {{ getInitials(form.recipientName) }}
           </div>
           <div>
              <p class="font-bold text-gray-800 text-sm uppercase">{{ form.recipientName }}</p>
              <p class="text-xs text-gray-500">{{ form.bankName }} - {{ form.accountNumber }}</p>
           </div>
        </div>

        <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 mb-4">
           <label class="block text-xs font-bold text-gray-600 mb-2">Jumlah Uang</label>
           <div class="flex items-center border-b-2 border-gray-200 focus-within:border-[#016B61] transition pb-2 mb-2">
              <span class="text-lg font-bold text-gray-500 mr-2">Rp</span>
              <input v-model="form.amount" type="number" placeholder="0" class="w-full text-3xl font-bold text-gray-800 focus:outline-none placeholder-gray-300 bg-transparent">
           </div>
           <p class="text-[10px] text-gray-400 mb-4">Min. Rp 10.000</p>

           <div class="flex items-center gap-2 bg-gray-50 p-2 rounded-lg">
             <i class="ri-chat-3-line text-gray-400"></i>
             <input v-model="form.description" type="text" placeholder="Catatan transaksi..." class="w-full bg-transparent text-xs focus:outline-none">
           </div>
        </div>

        <div class="bg-white p-4 rounded-xl border border-gray-100 shadow-sm relative overflow-hidden">
            <h5 class="text-xs font-bold text-gray-800 mb-3">Sumber Dana</h5>
            <div class="flex items-center gap-3 relative z-10">
               <div class="w-10 h-6 bg-blue-600 rounded flex items-center justify-center text-[8px] text-white font-bold italic">DEBIT</div>
               <div>
                  <p class="text-xs font-bold text-gray-800">Saldo Utama</p>
                  <p class="text-sm font-bold text-[#016B61]">Rp {{ formatNumber(userBalance) }}</p>
               </div>
            </div>
        </div>
        
        <div class="fixed bottom-0 left-0 w-full p-6 bg-white border-t border-gray-100 z-30 flex flex-col gap-3">
           <button @click="submitTransfer" :disabled="isLoading || form.amount < 10000" class="w-full bg-[#007cc3] disabled:bg-gray-300 text-white font-bold py-3.5 rounded-lg shadow-lg hover:bg-[#005e54] transition flex justify-center items-center gap-2">
             <span v-if="isLoading"><i class="ri-loader-4-line animate-spin"></i> Memproses...</span>
             <span v-else>Konfirmasi Transfer</span>
           </button>
        </div>

      </div>

    </div>

    <div v-if="showSuccess" class="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
      <div class="bg-white w-full max-w-sm rounded-[30px] overflow-hidden shadow-2xl animate-scale-up relative">
         <div class="bg-[#005e54] p-8 text-center relative overflow-hidden">
             <div class="absolute top-0 left-0 w-full h-full opacity-10 bg-[url('https://www.transparenttextures.com/patterns/cubes.png')]"></div>
             <div class="w-16 h-16 bg-white/20 rounded-full flex items-center justify-center mx-auto mb-4 backdrop-blur-sm border-2 border-white/30">
               <i class="ri-check-line text-3xl text-white"></i>
             </div>
             <h2 class="text-xl font-bold text-white mb-1">Transfer Berhasil!</h2>
             <p class="text-xs text-green-100 opacity-80">{{ successData.date }}</p>
         </div>

         <div class="p-6 relative">
            <div class="text-center mb-6">
               <p class="text-xs text-gray-500 font-bold uppercase tracking-wider mb-1">Total Nominal</p>
               <h1 class="text-3xl font-extrabold text-[#005e54]">Rp {{ formatNumber(successData.amount) }}</h1>
            </div>

            <div class="bg-gray-50 rounded-xl p-4 border border-gray-100 space-y-3 mb-6">
                <div class="flex justify-between items-start text-xs border-b border-gray-200 pb-2">
                   <span class="text-gray-500">No. Referensi</span>
                   <span class="font-mono font-bold text-gray-700 text-right">{{ successData.trxCode }}</span>
                </div>
                <div class="flex justify-between items-start text-xs">
                   <span class="text-gray-500">Penerima</span>
                   <div class="text-right">
                      <p class="font-bold text-gray-800">{{ successData.recipient }}</p>
                      <p class="text-[10px] text-gray-500">{{ successData.bank }} - {{ successData.account }}</p>
                   </div>
                </div>
            </div>

            <button @click="resetForm" class="w-full py-3 bg-[#005e54] text-white font-bold rounded-xl text-sm shadow-lg hover:bg-[#004d44] transition">
               Selesai
            </button>
         </div>
      </div>
    </div>

    <div v-if="showDeleteModal" class="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4 animate-fade-in">
      <div class="bg-white w-full max-w-sm rounded-[30px] overflow-hidden shadow-2xl animate-scale-up relative">
         
         <div class="bg-red-600 p-8 text-center relative overflow-hidden">
             <div class="absolute top-0 left-0 w-full h-full opacity-10 bg-[url('https://www.transparenttextures.com/patterns/cubes.png')]"></div>
             
             <div class="w-16 h-16 bg-white/20 rounded-full flex items-center justify-center mx-auto mb-4 backdrop-blur-sm border-2 border-white/30">
               <i class="ri-delete-bin-5-line text-3xl text-white"></i>
             </div>
             
             <h2 class="text-xl font-bold text-white mb-1">Hapus Kontak?</h2>
             <p class="text-xs text-red-100 opacity-90">Tindakan ini tidak bisa dibatalkan.</p>
         </div>

         <div class="p-6 relative">
            <div class="bg-red-50 rounded-xl p-4 border border-red-100 mb-6 text-center">
                <p class="text-xs text-gray-500 mb-1">Anda akan menghapus:</p>
                <p class="font-bold text-gray-800 text-lg">{{ itemToDelete?.name }}</p>
                <p class="text-xs text-gray-500 mt-1">{{ itemToDelete?.bank }} - {{ itemToDelete?.number }}</p>
            </div>

            <div class="flex gap-3">
               <button @click="showDeleteModal = false" class="flex-1 py-3 bg-gray-100 text-gray-600 font-bold rounded-xl text-sm hover:bg-gray-200 transition">
                  Batal
               </button>
               
               <button @click="confirmDelete" :disabled="isDeleting" class="flex-1 py-3 bg-red-600 text-white font-bold rounded-xl text-sm shadow-lg hover:bg-red-700 transition flex justify-center items-center gap-2">
                  <span v-if="isDeleting"><i class="ri-loader-4-line animate-spin"></i> Hapus...</span>
                  <span v-else>Ya, Hapus</span>
               </button>
            </div>
         </div>
      </div>
    </div>

    <!-- Modal Sukses Simpan Kontak -->
    <div v-if="showSaveSuccess" class="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4 animate-fade-in">
      <div class="bg-white w-full max-w-sm rounded-[30px] overflow-hidden shadow-2xl animate-scale-up relative">
         <div class="bg-[#005e54] p-8 text-center relative overflow-hidden">
             <div class="absolute top-0 left-0 w-full h-full opacity-10 bg-[url('https://www.transparenttextures.com/patterns/cubes.png')]"></div>
             <div class="w-16 h-16 bg-white/20 rounded-full flex items-center justify-center mx-auto mb-4 backdrop-blur-sm border-2 border-white/30">
               <i class="ri-check-double-line text-3xl text-white"></i>
             </div>
             <h2 class="text-xl font-bold text-white mb-1">Berhasil Disimpan!</h2>
             <p class="text-xs text-green-100 opacity-80">Kontak kini ada di daftar tersimpan.</p>
         </div>

         <div class="p-6 relative">
            <div class="bg-gray-50 rounded-xl p-4 border border-gray-100 space-y-3 mb-6">
                <div class="flex justify-between items-start text-xs border-b border-gray-200 pb-2">
                   <span class="text-gray-500">Nama Alias</span>
                   <p class="font-bold text-gray-800 text-right">{{ contactAlias }}</p>
                </div>
                <div class="flex justify-between items-start text-xs border-b border-gray-200 pb-2">
                   <span class="text-gray-500">Nomor Rekening</span>
                   <p class="font-bold text-gray-800 text-right font-mono">{{ form.accountNumber }}</p>
                </div>
                 <div class="flex justify-between items-start text-xs">
                   <span class="text-gray-500">Bank</span>
                   <p class="font-bold text-gray-800 text-right">{{ form.bankName }}</p>
                </div>
            </div>

            <button @click="showSaveSuccess = false" class="w-full py-3 bg-[#005e54] text-white font-bold rounded-xl text-sm shadow-lg hover:bg-[#004d44] transition">
               OK
            </button>
         </div>
      </div>
    </div>

    <!-- Modal Konfirmasi Batal -->
    <div v-if="showCancelModal" class="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4 animate-fade-in">
      <div class="bg-white w-full max-w-sm rounded-[30px] overflow-hidden shadow-2xl animate-scale-up relative">
         <div class="bg-orange-500 p-8 text-center relative overflow-hidden">
             <div class="absolute top-0 left-0 w-full h-full opacity-10 bg-[url('https://www.transparenttextures.com/patterns/cubes.png')]"></div>
             <div class="w-16 h-16 bg-white/20 rounded-full flex items-center justify-center mx-auto mb-4 backdrop-blur-sm border-2 border-white/30">
               <i class="ri-question-line text-3xl text-white"></i>
             </div>
             <h2 class="text-xl font-bold text-white mb-1">Batalkan Transaksi?</h2>
             <p class="text-xs text-orange-100 opacity-90">Data yang diisi akan hilang.</p>
         </div>

         <div class="p-6 relative">
            <div class="flex gap-3">
               <button @click="showCancelModal = false" class="flex-1 py-3 bg-gray-100 text-gray-600 font-bold rounded-xl text-sm hover:bg-gray-200 transition">
                  Tidak
               </button>
               <button @click="confirmCancel" class="flex-1 py-3 bg-orange-500 text-white font-bold rounded-xl text-sm shadow-lg hover:bg-orange-600 transition">
                  Ya, Batalkan
               </button>
            </div>
         </div>
      </div>
    </div>

    <!-- Generic Alert Modal -->
    <div v-if="alertModal.show" class="fixed inset-0 z-[60] flex items-center justify-center bg-black/60 backdrop-blur-sm p-4 animate-fade-in">
      <div class="bg-white w-full max-w-sm rounded-[30px] overflow-hidden shadow-2xl animate-scale-up relative">
         <div :class="alertModal.type === 'error' ? 'bg-red-500' : 'bg-[#005e54]'" class="p-6 text-center relative overflow-hidden transition-colors duration-300">
             <div class="absolute top-0 left-0 w-full h-full opacity-10 bg-[url('https://www.transparenttextures.com/patterns/cubes.png')]"></div>
             
             <div class="w-14 h-14 bg-white/20 rounded-full flex items-center justify-center mx-auto mb-3 backdrop-blur-sm border-2 border-white/30">
               <i v-if="alertModal.type === 'error'" class="ri-error-warning-line text-2xl text-white"></i>
               <i v-else class="ri-information-line text-2xl text-white"></i>
             </div>
             
             <h2 class="text-lg font-bold text-white mb-1">{{ alertModal.title }}</h2>
         </div>

         <div class="p-6 relative text-center">
            <p class="text-sm text-gray-600 mb-6 leading-relaxed">{{ alertModal.message }}</p>

            <button @click="alertModal.show = false" :class="alertModal.type === 'error' ? 'bg-red-500 hover:bg-red-600' : 'bg-[#005e54] hover:bg-[#004d44]'" class="w-full py-3 text-white font-bold rounded-xl text-sm shadow-lg transition">
               OK
            </button>
         </div>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();

// --- STATE MANAGEMENT ---
const step = ref(1);
const isLoading = ref(false);
const isSaving = ref(false); 
const showSuccess = ref(false);
const userBalance = ref(0);

// --- STATE MODAL DELETE ---
const showDeleteModal = ref(false);
const showCancelModal = ref(false);
const showSaveSuccess = ref(false); // New state for save success popup
const itemToDelete = ref(null);
const isDeleting = ref(false);

// --- STATE GENERIC ALERT MODAL ---
const alertModal = ref({
    show: false,
    title: '',
    message: '',
    type: 'error' // 'error', 'warning', 'info'
});

const showAlert = (title, message, type = 'error') => {
    alertModal.value = {
        show: true,
        title,
        message,
        type
    };
};

const userId = 4; // Hardcoded user
const accountId = ref(null); 

const form = ref({
  bankCode: '',
  bankName: '',
  accountNumber: '',
  recipientName: '', 
  recipientId: null, 
  amount: '',
  description: ''
});

// State untuk Logic Simpan Kontak
const inquiryResult = ref(null); 
const isSaveContactChecked = ref(false);
const contactAlias = ref('');

// Object Data Struk
const successData = ref({
    trxCode: '',
    amount: 0,
    date: '',
    recipient: '',
    bank: '',
    account: '',
    description: ''
});

const searchBank = ref('');
const recentTransfers = ref([]); 
const savedContacts = ref([]); 
const banks = ref([]);

// --- WATCHERS ---
let debounceTimer = null;

watch(() => form.value.accountNumber, (newVal, oldVal) => {
    // 1. Reset hasil inquiry jika input berubah
    // Ini menangani "ketika no rekening di hapus atau di ubah 1 angka saja maka status nama reking... otomatis berubah"
    if (newVal !== oldVal) {
        inquiryResult.value = null;
        form.value.recipientName = '';
        form.value.recipientId = null;
        isSaveContactChecked.value = false;
        contactAlias.value = '';
    }

    // 2. Clear timer yang sedang berjalan
    if (debounceTimer) clearTimeout(debounceTimer);

    // 3. Auto validation (Debounce 800ms)
    // Jika user berhenti mengetik selama 800ms, otomatis cek rekening
    if (newVal && newVal.length >= 8) { // Asumsi panjang rekening minimal 8 digit
        debounceTimer = setTimeout(() => {
            validateAccount();
        }, 800);
    }
});

// --- COMPUTED ---
const headerTitle = computed(() => {
  if (step.value === 1) return 'Transfer';
  if (step.value === 2) return 'Pilih Bank';
  if (step.value === 3) return 'Cek Tujuan';
  if (step.value === 4) return 'Jumlah Uang';
  return 'Transfer';
});

const filteredBanks = computed(() => {
  if (!searchBank.value) return banks.value; 
  return banks.value.filter(b => b.name.toLowerCase().includes(searchBank.value.toLowerCase()));
});

// --- METHODS ---
const goToStep = (n) => {
  step.value = n;
  window.scrollTo(0,0);
};

const handleBack = () => {
  if (step.value === 1) {
     if(router) router.push('/'); 
  } else if (step.value === 3) {
     inquiryResult.value = null;
     form.value.accountNumber = '';
     step.value = 2;
  } else {
     step.value--; 
  }
};

const cancelTransaction = () => {
  showCancelModal.value = true;
};

const confirmCancel = () => {
  showCancelModal.value = false;
  resetForm();
};

const selectBank = (bank) => {
  form.value.bankName = bank.name;
  form.value.bankCode = bank.code; 
  goToStep(3);
};

// --- LOGIC SELECT DATA ---
const selectRecent = (recent) => {
  form.value.recipientName = recent.name;
  form.value.bankName = recent.bank;
  form.value.accountNumber = recent.number.toString().replace(/\D/g,'');
  form.value.recipientId = recent.destinationId; 

  inquiryResult.value = { full_name: recent.name }; 
  goToStep(4);
};

const selectSaved = async (contact) => {
  form.value.bankCode = contact.code;
  form.value.accountNumber = contact.number;
  
  await validateAccount();

  if (form.value.recipientId) {
     goToStep(4);
  }
};

// --- LOGIC DELETE BARU (MODAL) ---
const promptDelete = (contact) => {
  itemToDelete.value = contact;
  showDeleteModal.value = true;
};

const confirmDelete = async () => {
  if (!itemToDelete.value) return;

  try {
    isDeleting.value = true;
    await fetch(`/api/beneficiaries/delete/${itemToDelete.value.id}`, { 
        method: 'DELETE' 
    });
    
    await loadTransferData();
    showDeleteModal.value = false;
    itemToDelete.value = null;
    
  } catch (e) {
    console.error(e);
    showAlert("Gagal Hapus", "Terjadi kesalahan saat menghapus kontak.", "error");
  } finally {
    isDeleting.value = false;
  }
};

// --- API LOGIC ---

const loadTransferData = async () => {
    try {
        const resBanks = await fetch('/api/banks');
        const dataBanks = await resBanks.json();
        if(dataBanks.status === 'success') {
            banks.value = dataBanks.data.map(b => ({
                code: b.bank_code,
                name: b.bank_name
            }));
        }

        const resRecent = await fetch(`/api/transactions/recent/${userId}`);
        const dataRecent = await resRecent.json();
        if(dataRecent.status === 'success') {
            recentTransfers.value = dataRecent.data.map(r => ({
                id: r.transaction_id,
                name: r.beneficiary_name,
                bank: r.bank_name,
                number: r.account_destination,
                destinationId: r.destination_account_id 
            }));
        }

        const resSaved = await fetch(`/api/beneficiaries/${userId}`);
        const dataSaved = await resSaved.json();
        if(dataSaved.status === 'success') {
             savedContacts.value = dataSaved.data.map(s => ({
                id: s.id,
                code: s.bank_code,
                name: s.alias_name,
                bank: s.bank_name, 
                number: s.account_number
             }));
        }
    } catch (error) {
        console.error("Gagal memuat data:", error);
    }
};

const validateAccount = async () => {
  if (!form.value.accountNumber) return;
  try {
    isLoading.value = true;
    const response = await fetch(`/api/transactions/inquiry/${form.value.accountNumber}`);
    const result = await response.json();

    if (result.status === 'success') {
       inquiryResult.value = result.data;
       
       form.value.recipientName = result.data.full_name;
       form.value.recipientId = result.data.account_id; 
       
       isSaveContactChecked.value = false;
       contactAlias.value = result.data.full_name; 
       
    } else {
       showAlert("Gagal Menemukan", "Rekening tidak ditemukan.", "error");
       inquiryResult.value = null;
    }
  } catch (e) {
    showAlert("Koneksi Error", "Gagal menghubungi server.", "error");
  } finally {
    isLoading.value = false;
  }
};

const saveContactToDb = async () => {
    if(!contactAlias.value) return showAlert("Perhatian", "Nama panggilan tidak boleh kosong", "warning");
    
    // Validasi duplikasi: Cek apakah nomor rekening sudah ada di savedContacts
    // Menggunakan loose equality (==) untuk mengantisipasi perbedaan tipe (string vs number)
    const isDuplicate = savedContacts.value.some(contact => contact.number == form.value.accountNumber);
    
    if (isDuplicate) {
        showAlert("Sudah Tersimpan", "Nomor rekening ini sudah tersimpan di daftar kontak!", "warning");
        return;
    }

    try {
        isSaving.value = true;
        const payload = {
            user_id: userId,
            bank_code: form.value.bankCode || '001', 
            account_number: form.value.accountNumber,
            alias_name: contactAlias.value
        };

        const response = await fetch('/api/beneficiaries/save', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });
        
        const result = await response.json();
        if(result.status === 'success'){
            // Tampilkan popup sukses alih-alih alert
            showSaveSuccess.value = true;
            isSaveContactChecked.value = false; 
            loadTransferData(); 
        } else {
            showAlert("Gagal Simpan", result.message, "error");
        }
    } catch (e) {
        showAlert("Error", "Gagal menyimpan kontak", "error");
    } finally {
        isSaving.value = false;
    }
};

const submitTransfer = async () => {
  if (!accountId.value) return showAlert("Error Akun", "Akun pengirim tidak valid.", "error");
  if (!form.value.recipientId) return showAlert("Data Invalid", "Data penerima tidak valid, coba ulangi.", "error"); 
  
  try {
    isLoading.value = true;
    const payload = {
      from_account_id: accountId.value,
      to_account_id: form.value.recipientId, 
      amount: parseFloat(form.value.amount),
      description: form.value.description
    };

    const response = await fetch('/api/transactions/transfer', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });

    const result = await response.json();

    if (result.status === 'success') {
      successData.value = {
          trxCode: result.data.transaction_code,
          amount: parseFloat(form.value.amount),
          date: new Date().toLocaleString('id-ID'),
          recipient: form.value.recipientName,
          bank: form.value.bankName,
          account: form.value.accountNumber,
          description: form.value.description
      };
      
      userBalance.value = parseFloat(result.data.balance_remaining);
      showSuccess.value = true;
      loadTransferData(); 
    } else {
      showAlert("Transfer Gagal", result.message, "error");
    }

  } catch (error) {
    showAlert("Server Error", "Terjadi kesalahan saat memproses transfer.", "error");
  } finally {
    isLoading.value = false;
  }
};

const resetForm = () => {
  showSuccess.value = false;
  step.value = 1;
  form.value.amount = '';
  form.value.description = '';
  form.value.recipientId = null;
  form.value.recipientName = '';
  form.value.accountNumber = '';
  inquiryResult.value = null;
  fetchUserData(); 
};

const getInitials = (name) => {
  if(!name) return '??';
  const parts = name.split(' ');
  if (parts.length >= 2) return (parts[0][0] + parts[1][0]).toUpperCase();
  return name.slice(0, 2).toUpperCase();
};

const formatNumber = (num) => {
  return new Intl.NumberFormat('id-ID').format(num);
};

const fetchUserData = async () => {
    try {
        const response = await fetch('/api/dashboard/all');
        const result = await response.json();
        if (result.status === 'success') {
            const foundAccount = result.data.accounts.find(a => a.user_id == userId);
            if(foundAccount) {
                userBalance.value = foundAccount.balance;
                accountId.value = foundAccount.account_id;
            }
        }
    } catch (error) {
        console.error("Gagal ambil saldo:", error);
    }
};

onMounted(() => {
  fetchUserData();    
  loadTransferData(); 
});
</script>

<style scoped>
/* Sama seperti sebelumnya */
.no-scrollbar::-webkit-scrollbar { display: none; }
.no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }
.animate-fade-in { animation: fadeIn 0.3s ease-in-out; }
.animate-scale-up { animation: scaleUp 0.3s ease-out; }
@keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
@keyframes scaleUp { from { opacity: 0; transform: scale(0.9); } to { opacity: 1; transform: scale(1); } }
</style>