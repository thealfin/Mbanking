// src/main.js
import { createApp } from 'vue'
import App from './App.vue'
import router from './router/router.js'
import './style.css' // pastikan tailwind import ada di sini

const app = createApp(App)
app.use(router)
app.mount('#app')