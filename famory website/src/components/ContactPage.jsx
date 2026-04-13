import React, { useState } from "react";
import { motion } from "framer-motion";

export default function Contact({ t, darkMode, goHome }) {
  const [formData, setFormData] = useState({ name: "", email: "", subject: "", message: "" });
  const [submitted, setSubmitted] = useState(false);

  const handleSubmit = (e) => {
    e.preventDefault();
    setTimeout(() => {
      setSubmitted(true);
      setFormData({ name: "", email: "", subject: "", message: "" });
    }, 800);
  };

  const inputClasses = `w-full px-4 py-3 rounded-xl border transition-colors focus:outline-none focus:ring-2 focus:ring-[#3EB6EC]/50 ${
    darkMode ? "bg-[#1E293B] border-[#334155] text-white placeholder-gray-500" : "bg-white border-gray-200 text-gray-900 placeholder-gray-400"
  }`;

  const cardBg = darkMode ? "bg-[#1E293B]" : "bg-white";
  const borderColor = darkMode ? "border-[#334155]" : "border-gray-100";

  return (
    <section className={`pt-32 pb-20 min-h-screen ${darkMode ? "bg-[#0F172A]" : "bg-[#FAFBFC]"}`}>
      <div className="max-w-6xl mx-auto px-6">
        <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="text-center mb-16">
          <button onClick={goHome} className={`inline-flex items-center gap-2 text-sm font-medium mb-6 transition-colors ${darkMode ? "text-gray-400 hover:text-white" : "text-gray-500 hover:text-gray-900"}`}>
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M19 12H5M12 19l-7-7 7-7"/></svg>
            {t.contact.backHome}
          </button>
          <h1 className={`text-3xl md:text-5xl font-bold tracking-tight mb-4 ${darkMode ? "text-white" : "text-[#1A2332]"}`}>
            {t.contact.title}
          </h1>
          <p className={`text-lg max-w-2xl mx-auto ${darkMode ? "text-gray-300" : "text-gray-600"}`}>
            {t.contact.subtitle}
          </p>
        </motion.div>

        <div className="grid lg:grid-cols-2 gap-12">
          {/* Form */}
          <motion.div initial={{ opacity: 0, x: -20 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: 0.1 }} className={`${cardBg} p-8 rounded-3xl border ${borderColor} shadow-sm`}>
            {submitted ? (
              <div className="h-full flex flex-col items-center justify-center text-center py-10">
                <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center text-green-600 mb-4">
                  <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><polyline points="20 6 9 17 4 12"/></svg>
                </div>
                <h3 className={`text-xl font-bold mb-2 ${darkMode ? "text-white" : "text-gray-900"}`}>{t.contact.success}</h3>
                <button onClick={() => setSubmitted(false)} className="mt-4 text-[#3EB6EC] hover:underline font-medium">{t.contact.backHome}</button>
              </div>
            ) : (
              <form onSubmit={handleSubmit} className="space-y-5">
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-5">
                  <div>
                    <label className={`block text-sm font-medium mb-1.5 ${darkMode ? "text-gray-300" : "text-gray-700"}`}>{t.contact.form.name}</label>
                    <input type="text" required className={inputClasses} value={formData.name} onChange={(e) => setFormData({...formData, name: e.target.value})} />
                  </div>
                  <div>
                    <label className={`block text-sm font-medium mb-1.5 ${darkMode ? "text-gray-300" : "text-gray-700"}`}>{t.contact.form.email}</label>
                    <input type="email" required className={inputClasses} value={formData.email} onChange={(e) => setFormData({...formData, email: e.target.value})} />
                  </div>
                </div>
                <div>
                  <label className={`block text-sm font-medium mb-1.5 ${darkMode ? "text-gray-300" : "text-gray-700"}`}>{t.contact.form.subject}</label>
                  <input type="text" required className={inputClasses} value={formData.subject} onChange={(e) => setFormData({...formData, subject: e.target.value})} />
                </div>
                <div>
                  <label className={`block text-sm font-medium mb-1.5 ${darkMode ? "text-gray-300" : "text-gray-700"}`}>{t.contact.form.message}</label>
                  <textarea rows="5" required className={inputClasses} value={formData.message} onChange={(e) => setFormData({...formData, message: e.target.value})} />
                </div>
                <button type="submit" className="w-full py-3.5 bg-[#3EB6EC] text-white font-semibold rounded-xl hover:bg-[#2BA5DA] transition-colors shadow-lg shadow-[#3EB6EC]/20">
                  {t.contact.form.send}
                </button>
              </form>
            )}
          </motion.div>

          {/* Contact Info */}
          <motion.div initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: 0.2 }} className="space-y-6">
            {[
              { icon: "✉️", title: t.contact.info.email, desc: "General Inquiries & Support" },
              { icon: "📍", title: t.contact.info.location, desc: "Jinan University Campus" },
              { icon: "💬", title: t.contact.info.miniProgram, desc: t.contact.info.miniProgramDesc }
            ].map((item, i) => (
              <div key={i} className={`p-6 rounded-2xl border ${borderColor} ${cardBg} hover:border-[#3EB6EC]/50 transition-colors`}>
                <div className="flex items-start gap-4">
                  <span className="text-2xl">{item.icon}</span>
                  <div>
                    <h3 className={`font-bold ${darkMode ? "text-white" : "text-gray-900"}`}>{item.title}</h3>
                    <p className={`text-sm mt-1 ${darkMode ? "text-gray-400" : "text-gray-500"}`}>{item.desc}</p>
                  </div>
                </div>
              </div>
            ))}
            
            {/* Map Placeholder */}
            <div className={`h-48 rounded-2xl overflow-hidden relative ${darkMode ? "bg-[#1E293B]" : "bg-gray-100"}`}>
              <div className="absolute inset-0 flex items-center justify-center">
                <div className="text-center">
                  <svg width="40" height="40" className={`mx-auto mb-2 ${darkMode ? "text-gray-600" : "text-gray-300"}`} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/></svg>
                  <p className={`text-sm font-medium ${darkMode ? "text-gray-500" : "text-gray-400"}`}>Map View</p>
                </div>
              </div>
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  );
}