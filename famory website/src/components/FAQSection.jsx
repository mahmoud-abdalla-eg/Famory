import React, { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";

export default function FAQSection({ t, darkMode }) {
  const [open, setOpen] = useState(null);
  
  const sectionBg = darkMode ? "bg-[#0F172A]" : "bg-white";
  const titleClass = darkMode ? "text-white" : "text-[#1A2332]";
  const cardClass = darkMode ? "bg-[#1E293B] border-[#334155]" : "bg-white border-gray-200";
  const questionClass = darkMode ? "text-white" : "text-[#1A2332]";
  const answerClass = darkMode ? "text-gray-300" : "text-gray-600";
  const hoverClass = darkMode ? "hover:bg-[#2A3548]" : "hover:bg-gray-50";

  return (
    <section id="faq" className={`py-20 ${sectionBg}`}>
      <div className="max-w-3xl mx-auto px-6">
        <motion.div initial={{ opacity: 0, y: 30 }} whileInView={{ opacity: 1, y: 0 }} viewport={{ once: true }} className="text-center mb-12">
          <h2 className={`text-3xl md:text-4xl font-bold tracking-tight ${titleClass}`}>{t.faq.title}</h2>
        </motion.div>
        <div className="space-y-3">
          {t.faq.items.map((item, i) => (
            <div key={i} className={`${cardClass} rounded-xl overflow-hidden border`}>
              <button onClick={() => setOpen(open === i ? null : i)} className={`w-full flex items-center justify-between p-5 text-left transition-colors ${hoverClass}`}>
                <span className={`text-sm font-semibold ${questionClass}`}>{item.q}</span>
                <motion.svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" animate={{ rotate: open === i ? 45 : 0 }} className="flex-shrink-0 text-[#3EB6EC]"><line x1="12" y1="5" x2="12" y2="19" /><line x1="5" y1="12" x2="19" y2="12" /></motion.svg>
              </button>
              <AnimatePresence>
                {open === i && (
                  <motion.div initial={{ height: 0, opacity: 0 }} animate={{ height: "auto", opacity: 1 }} exit={{ height: 0, opacity: 0 }} transition={{ duration: 0.25 }} className={`px-5 pb-5 text-sm leading-relaxed ${answerClass}`}>{item.a}</motion.div>
                )}
              </AnimatePresence>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}