import React, { useState } from "react";
import { translations } from "./constants/translations";
import Navbar from "./components/Navbar";
import HeroSection from "./components/HeroSection";
import FeaturesSection from "./components/FeaturesSection";
import AboutUsSection from "./Components/AboutUsSection";
import FAQSection from "./components/FAQSection";
import CTASection from "./components/CTASection";
import Footer from "./components/Footer";

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
      <HeroSection t={t} darkMode={darkMode} />
      <FeaturesSection t={t} darkMode={darkMode} />
      <AboutUsSection t={t} darkMode={darkMode} />
      <FAQSection t={t} darkMode={darkMode} />
      <CTASection t={t} darkMode={darkMode} />
      <Footer t={t} darkMode={darkMode} />
    </div>
  );
}
