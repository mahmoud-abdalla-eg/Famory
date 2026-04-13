import React from "react";
import { motion } from "framer-motion";
import { colors } from "../../constants/colors";

export default function AboutUsSection({ t, darkMode }) {
  const sectionBg = darkMode ? "bg-[#1E293B]" : "bg-gradient-to-br from-[#EAF6FC] to-[#FFE6D5]/50";
  const titleClass = darkMode ? "text-white" : "text-[#1A2332]";
  const textClass = darkMode ? "text-gray-300" : "text-gray-600";
  const cardClass = darkMode ? "bg-[#0F172A] border-[#334155]" : "bg-white border-gray-100";
  const labelClass = darkMode ? "text-gray-400" : "text-gray-500";
  const statColors = [colors.primaryBlue, colors.softGreen, colors.accentOrange, colors.primaryBlue];

  return (
    <section id="aboutUs" className={`py-20 ${sectionBg}`}>
      <div className="max-w-6xl mx-auto px-6">
        <div className="grid md:grid-cols-2 gap-12 items-center">
          <motion.div initial={{ opacity: 0, x: -30 }} whileInView={{ opacity: 1, x: 0 }} viewport={{ once: true }} className="space-y-5">
            <span className="text-xs font-semibold text-[#4CAF8F] uppercase tracking-widest">{t.aboutUs.subtitle}</span>
            <h2 className={`text-3xl md:text-4xl font-bold tracking-tight ${titleClass}`}>{t.aboutUs.title}</h2>
            <p className={`leading-relaxed ${textClass}`}>{t.aboutUs.p1}</p>
            <p className={`leading-relaxed ${textClass}`}>{t.aboutUs.p2}</p>
            <p className={`leading-relaxed ${textClass}`}>{t.aboutUs.p3}</p>
          </motion.div>

          <motion.div initial={{ opacity: 0, x: 30 }} whileInView={{ opacity: 1, x: 0 }} viewport={{ once: true }} className="grid grid-cols-2 gap-4">
            {t.aboutUs.stats.map((stat, i) => (
              <div key={i} className={`${cardClass} p-6 rounded-2xl border shadow-sm text-center`}>
                <p className="text-3xl font-bold" style={{ color: statColors[i] }}>{stat.value}</p>
                <p className={`text-sm mt-1 ${labelClass}`}>{stat.label}</p>
              </div>
            ))}
          </motion.div>
        </div>
      </div>
    </section>
  );
}