import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import tailwindcss from '@tailwindcss/vite';

const withFallback = (primary, fallback) => primary ?? fallback;

const envDefine = {
  'import.meta.env.VITE_STRAPI_HOST': JSON.stringify(
    withFallback(process.env.VITE_STRAPI_HOST, process.env.STRAPI_HOST),
  ),
  'import.meta.env.VITE_CMS_API_ENDPOINT': JSON.stringify(
    withFallback(process.env.VITE_CMS_API_ENDPOINT, process.env.CMS_API_ENDPOINT),
  ),
  'import.meta.env.VITE_CMS_API_KEY': JSON.stringify(
    withFallback(process.env.VITE_CMS_API_KEY, process.env.CMS_API_KEY),
  ),
  'import.meta.env.VITE_COUPON_SYS_ENDPOINT': JSON.stringify(
    withFallback(process.env.VITE_COUPON_SYS_ENDPOINT, process.env.COUPON_SYS_ENDPOINT),
  ),
  'import.meta.env.VITE_EMAIL_API_ENDPOINT': JSON.stringify(
    withFallback(process.env.VITE_EMAIL_API_ENDPOINT, process.env.EMAIL_API_ENDPOINT),
  ),
  'import.meta.env.VITE_OPENAI_API_URL': JSON.stringify(
    withFallback(process.env.VITE_OPENAI_API_URL, process.env.OPENAI_API_URL),
  ),
};

export default defineConfig({
  plugins: [react(), tailwindcss()],
  define: envDefine,
  server: {
    host: '0.0.0.0',  
    port: 3000,
  },
});