// src/router/router.js
import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'
import MutasiView from '../views/MutasiView.vue'
import PesanView from '../views/PesanView.vue'
import AkunView from '../views/AkunView.vue'
import QrisView from '../views/QrisView.vue' 
import TransferView from '../views/Transfer.vue'; 

const routes = [
  { path: '/', name: 'Home', component: HomeView },
  { path: '/mutasi', name: 'Mutasi', component: MutasiView },
  { path: '/qris',
    name: 'Qris', 
    component: QrisView,     
    // 👇 TAMBAHKAN INI
    meta: { hideNavbar: true }  },
  { path: '/pesan', name: 'Pesan', component: PesanView },
  { path: '/akun', name: 'Akun', component: AkunView },
  { 
    path: '/transfer', 
    name: 'Transfer', 
    component: TransferView,
    // 👇 TAMBAHKAN INI
    meta: { hideNavbar: true } 
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router