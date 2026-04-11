import React from "react";
import { motion, AnimatePresence } from "framer-motion";

export default function ThemeToggle({ darkMode, setDarkMode }) {
  return (
    <motion.button
      whileHover={{ scale: 1.1 }}
      whileTap={{ scale: 0.9 }}
      onClick={() => setDarkMode(!darkMode)}
      className={`relative w-10 h-10 rounded-lg flex items-center justify-center transition-colors ${
        darkMode 
          ? "bg-[#334155] text-yellow-400 hover:bg-[#3D4D66]" 
          : "bg-[#EAF6FC] text-[#3EB6EC] hover:bg-[#D5EDF7]"
      }`}
      aria-label="Toggle dark mode"
    >
      <AnimatePresence mode="wait">
        {darkMode ? (
          <motion.svg
            key="sun"
            initial={{ opacity: 0, rotate: -90 }}
            animate={{ opacity: 1, rotate: 0 }}
            exit={{ opacity: 0, rotate: 90 }}
            width="20"
            height="20"
            viewBox="0 0 24 24"
            fill="currentColor"
          >
            <circle cx="12" cy="12" r="5" />
            <path d="M12 1v2M12 21v2M4.22 4.22l1.42 1.42M18.36 18.36l1.42 1.42M1 12h2M21 12h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42" stroke="currentColor" strokeWidth="2" strokeLinecap="round" fill="none" />
          </motion.svg>
        ) : (
          <motion.svg
            key="moon"
            initial={{ opacity: 0, rotate: 90 }}
            animate={{ opacity: 1, rotate: 0 }}
            exit={{ opacity: 0, rotate: -90 }}
            width="20"
            height="20"
            viewBox="0 0 24 24"
            fill="currentColor"
          >
            <path d="M21 12.79A9 9 0 1111.21 3 7 7 0 0021 12.79z" />
          </motion.svg>
        )}
      </AnimatePresence>
    </motion.button>
  );
}