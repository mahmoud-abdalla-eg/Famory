import React from "react";

export default function CTASection({ t }) {
  return (
    <section className="py-20 bg-gradient-to-r from-[#3EB6EC] to-[#4CAF8F] text-white">
      <div className="max-w-4xl mx-auto px-6 text-center">
        <h2 className="text-3xl md:text-4xl font-bold mb-4">{t.hero.title1}</h2>
        <p className="text-white/80 mb-8 text-lg">{t.hero.subtitle}</p>
        <div className="flex flex-col sm:flex-row items-center justify-center gap-3">
          <button className="px-8 py-3 bg-white text-[#1A2332] rounded-xl font-semibold hover:bg-gray-50 transition-colors flex items-center gap-2">
            {t.hero.ctaPrimary}
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><path d="M5 12h14M12 5l7 7-7 7" /></svg>
          </button>
          <button className="px-8 py-3 bg-white/20 border border-white/30 text-white rounded-xl font-semibold hover:bg-white/30 transition-colors">
            {t.hero.ctaSecondary}
          </button>
        </div>
      </div>
    </section>
  );
}