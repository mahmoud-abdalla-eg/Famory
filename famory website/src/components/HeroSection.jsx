import React from "react";
import { motion } from "framer-motion";
import { easeOut } from "../utils/animations";
import PhoneMockup1 from "./PhoneMockup1";
import PhoneMockup2 from "./PhoneMockup2";

export default function HeroSection({ t, darkMode }) {
  const bgGradient = darkMode 
    ? "bg-gradient-to-br from-[#1E3A5F]/30 via-[#0F172A] to-[#2D3748]/30"
    : "bg-gradient-to-br from-[#EAF6FC] via-white to-[#FFE6D5]/30";

  const badgeClass = darkMode ? "bg-[#3D2E1E] text-[#FF8C42]" : "bg-[#FFE6D5] text-[#FF8C42]";
  const titleClass = darkMode ? "text-white" : "text-[#1A2332]";
  const subtitleClass = darkMode ? "text-gray-300" : "text-gray-600";
  const ctaPrimaryClass = darkMode ? "bg-white text-[#0F172A] hover:bg-gray-100" : "bg-[#1A2332] text-white hover:bg-[#2A3342]";
  const ctaSecondaryClass = "bg-[#4CAF8F] text-white hover:bg-[#3D9A7A]";
  const pulseTextClass = darkMode ? "text-gray-400" : "text-gray-500";

  return (
    <section id="home" className="relative min-h-screen flex items-center pt-16 overflow-hidden" style={{ background: darkMode ? "#0F172A" : "" }}>
      <div className={`absolute inset-0 ${bgGradient}`} />
      <div className={`absolute top-20 right-10 w-72 h-72 ${darkMode ? "bg-[#3EB6EC]/5" : "bg-[#3EB6EC]/10"} rounded-full blur-3xl`} />
      <div className={`absolute bottom-20 left-10 w-96 h-96 ${darkMode ? "bg-[#4CAF8F]/5" : "bg-[#4CAF8F]/10"} rounded-full blur-3xl`} />

      <div className="max-w-7xl mx-auto px-6 relative z-10 w-full">
        <div className="grid lg:grid-cols-2 gap-12 items-center min-h-[calc(100vh-4rem)]">
          {/* Left Content */}
          <div className="space-y-8">
            <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.6, ease: easeOut }}>
              <span className={`inline-flex items-center ${badgeClass} px-4 py-2 rounded-lg text-xs font-bold uppercase tracking-wide`}>
                {t.hero.tagline}
              </span>
            </motion.div>

            <motion.h1 initial={{ opacity: 0, y: 30 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.15, duration: 0.6, ease: easeOut }} className={`text-4xl sm:text-5xl md:text-6xl font-extrabold leading-[1.1] tracking-tight ${titleClass}`}>
              {t.hero.title1}
              <br />
              <span className="text-[#3EB6EC]">{t.hero.title2}</span>
            </motion.h1>

            <motion.p initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 0.25 }} className={`text-lg max-w-lg leading-relaxed ${subtitleClass}`}>
              {t.hero.subtitle}
            </motion.p>

            {/* CTA Buttons */}
            <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.35 }} className="flex flex-wrap gap-3">
              <motion.button whileHover={{ scale: 1.03 }} whileTap={{ scale: 0.97 }} className={`flex items-center gap-3 px-5 py-3 rounded-xl transition-colors ${ctaPrimaryClass}`}>
                <svg width="24" height="24" viewBox="0 0 24 24" fill={darkMode ? "#1A2332" : "white"}><path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/></svg>
                <div className="text-left">
                  <div className="text-[10px] opacity-80 leading-none">Download on the</div>
                  <div className="text-sm font-semibold leading-tight">{t.hero.ctaPrimary}</div>
                </div>
              </motion.button>
              <motion.button whileHover={{ scale: 1.03 }} whileTap={{ scale: 0.97 }} className={`flex items-center gap-3 px-5 py-3 rounded-xl transition-colors ${ctaSecondaryClass}`}>
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M22 12A10 10 0 1112 2a10 10 0 010 20z"/><path d="M12 6v6l4 2"/></svg>
                <div className="text-left">
                  <div className="text-[10px] opacity-80 leading-none">Track Progress</div>
                  <div className="text-sm font-semibold leading-tight">{t.hero.ctaSecondary}</div>
                </div>
              </motion.button>
            </motion.div>

            <motion.p initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 0.45 }} className={`text-xs font-medium flex items-center gap-2 ${pulseTextClass}`}>
              <span className="w-2 h-2 bg-[#4CAF8F] rounded-full animate-pulse" />
              {t.hero.trilingual}
            </motion.p>
          </div>

          {/* Phone Mockups */}
          <motion.div
            initial={{ opacity: 0, x: 60 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.4, duration: 0.8, ease: easeOut }}
            className="relative flex items-center justify-center lg:justify-end"
          >
            <div className="relative flex items-center gap-4">
              <PhoneMockup1 darkMode={darkMode} />
              <PhoneMockup2 darkMode={darkMode} />
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  );
}