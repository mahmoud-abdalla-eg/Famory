import React, { useState } from "react";
import { SpeedInsights } from "@vercel/speed-insights/react";
import { translations } from "./constants/translations";
import Navbar from "./components/Navbar";
import Footer from "./components/Footer";
import { Route, Routes } from "react-router-dom";
import Home from "./components/Home/Home";
import Contact from "./components/ContactPage";
import ScrollToHash from "./components/ScrollToHash";

export default function App() {
  const [lang, setLang] = useState("en");
  const [darkMode, setDarkMode] = useState(false);
  const t = translations[lang];
  const isRTL = lang === "ar";

  return (
    <div 
      dir={isRTL ? "rtl" : "ltr"} 
      className={`min-h-screen font-sans antialiased selection:bg-[#3EB6EC]/20 selection:text-[#1A2332] transition-colors duration-300 ${
        darkMode ? "bg-[#0F172A] text-white" : "bg-white text-gray-900"
      }`}
    >
      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Noto+Sans+SC:wght@400;500;700&family=Noto+Sans+Arabic:wght@400;500;700&display=swap');
        :root { font-family: 'Inter', 'Noto Sans SC', 'Noto Sans Arabic', sans-serif; }
        html { scroll-behavior: smooth; }
      `}</style>
      
      <Navbar lang={lang} setLang={setLang} t={t} darkMode={darkMode} setDarkMode={setDarkMode} />
      
      <ScrollToHash />

      <Routes>
         <Route path="/" element={<Home t={t} darkMode={darkMode} />} />
         <Route path="/contact" element={<Contact t={t} darkMode={darkMode} />} />
      </Routes>
      <Footer t={t} darkMode={darkMode} />
      <SpeedInsights />
    </div>
  );
}
