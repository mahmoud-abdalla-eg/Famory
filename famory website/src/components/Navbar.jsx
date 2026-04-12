import React, { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import LanguageToggle from "./LanguageToggle";
import ThemeToggle from "./ThemeToggle";
import logolight from "../assets/light-famory-logo.png";
import logodark from "../assets/dark-famory-logo.png";

export default function Navbar({ lang, setLang, t, darkMode, setDarkMode }) {
  const [scrolled, setScrolled] = useState(false);
  const [mobileOpen, setMobileOpen] = useState(false);

  useEffect(() => {
    const handleScroll = () => setScrolled(window.scrollY > 10);
    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  const headerBg = darkMode 
    ? scrolled ? "bg-[#0F172A]/90 backdrop-blur-md border-b border-[#334155]" : "bg-transparent"
    : scrolled ? "bg-white/90 backdrop-blur-md border-b border-gray-100 shadow-sm" : "bg-transparent";

  const navLinkClass = darkMode 
    ? "text-gray-300 hover:text-[#3EB6EC]" 
    : "text-gray-600 hover:text-[#3EB6EC]";

  const logoTextClass = darkMode ? "text-white" : "text-gray-800";
  const mobileLinkClass = darkMode ? "text-gray-300 hover:bg-[#1E293B]" : "text-gray-700 hover:bg-gray-50";
  const iconClass = darkMode ? "text-gray-300" : "text-gray-600";

  return (
    <header className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${headerBg} pt-2 pb-2`}>
      <div className="max-w-7xl mx-auto px-6 h-16 flex items-center justify-between">
        {/* Logo */}
        <a href="#" className="flex items-center gap-2.5">
          <img src={(darkMode ? logodark : logolight)} alt="One Famory Logo" className="h-16 " darkMode={darkMode}/>
          <span className={`text-xl font-bold tracking-tight ${logoTextClass}`}>One Famory</span>
        </a>

        {/* Desktop Nav */}
        <nav className="hidden md:flex items-center gap-8">
          {["features", "aboutUs", "faq"].map((key) => (
            <a key={key} href={`#${key}`} className={`text-sm font-medium transition-colors ${navLinkClass}`}>
              {t.nav[key]}
            </a>
          ))}
        </nav>

        {/* Desktop Actions */}
        <div className="hidden md:flex items-center gap-3">
          <LanguageToggle lang={lang} setLang={setLang} darkMode={darkMode} />
          <ThemeToggle darkMode={darkMode} setDarkMode={setDarkMode} />
          <motion.button
            whileHover={{ scale: 1.03 }}
            whileTap={{ scale: 0.97 }}
            className="bg-[#3EB6EC] text-white px-5 py-2.5 rounded-xl text-sm font-semibold hover:bg-[#2BA5DA] transition-colors flex items-center gap-2"
          >
            {t.contactBtn}
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><path d="M5 12h14M12 5l7 7-7 7" /></svg>
          </motion.button>
        </div>

        {/* Mobile Toggle */}
        <div className="md:hidden flex items-center gap-2">
          <LanguageToggle lang={lang} setLang={setLang} darkMode={darkMode} />
          <ThemeToggle darkMode={darkMode} setDarkMode={setDarkMode} />
          <button onClick={() => setMobileOpen(!mobileOpen)} className={`p-2 ${iconClass}`}>
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              {mobileOpen ? <path d="M6 18L18 6M6 6l12 12" /> : <path d="M3 12h18M3 6h18M3 18h18" />}
            </svg>
          </button>
        </div>
      </div>

      {/* Mobile Menu */}
      <AnimatePresence>
        {mobileOpen && (
          <motion.div 
            initial={{ opacity: 0, height: 0 }} 
            animate={{ opacity: 1, height: "auto" }} 
            exit={{ opacity: 0, height: 0 }} 
            className={`md:hidden border-t ${darkMode ? "bg-[#0F172A] border-[#334155]" : "bg-white border-gray-100"}`}
          >
            <div className="flex flex-col p-4 gap-2">
              {["features", "aboutUs", "faq"].map((key) => (
                <a key={key} href={`#${key}`} onClick={() => setMobileOpen(false)} className={`text-sm font-medium py-2.5 px-3 rounded-lg ${mobileLinkClass}`}>
                  {t.nav[key]}
                </a>
              ))}
              <button className="mt-2 bg-[#3EB6EC] text-white px-5 py-2.5 rounded-xl text-sm font-semibold flex items-center justify-center gap-2">
                {t.contactBtn}
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><path d="M5 12h14M12 5l7 7-7 7" /></svg>
              </button>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </header>
  );
}