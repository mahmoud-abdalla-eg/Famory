import React from "react";
import logolight from "../assets/light-famory-logo.png";
import logodark from "../assets/dark-famory-logo.png";


export default function Footer({ t, darkMode, goContact }) {
  const sectionBg = darkMode ? "bg-[#0F172A]" : "bg-white";
  const containerBg = darkMode ? "bg-[#1E293B]" : "bg-[#EAF6FC]";
  const titleClass = darkMode ? "text-white" : "text-[#1A2332]";
  const textClass = darkMode ? "text-gray-300" : "text-gray-600";
  const linkClass = darkMode ? "text-gray-300 hover:text-[#3EB6EC]" : "text-gray-600 hover:text-[#3EB6EC]";
  const borderClass = darkMode ? "border-[#334155]" : "border-[#3EB6EC]/20";
  const copyrightClass = darkMode ? "text-gray-400" : "text-gray-500";

  return (
    <section className={`py-16 px-6 ${sectionBg}`}>
      <div className="max-w-6xl mx-auto">
        <div className={`${containerBg} rounded-3xl p-8 md:p-12`}>
          <div className="grid md:grid-cols-[1fr_auto_auto] gap-10 md:gap-16">
            {/* Brand Column */}
            <div className="space-y-6">
              <div className="flex items-center gap-2.5">
                          <img src={(darkMode ? logodark : logolight)} alt="One Famory Logo" className="h-16 " darkMode={darkMode}/>
                <span className={`text-xl font-bold tracking-tight ${titleClass}`}>One Famory</span>
              </div>
              <p className={`text-sm leading-relaxed max-w-xs ${textClass}`}>
                {t.footer.desc}
              </p>
              {/* Social Icons */}
              <div className="flex items-center gap-4">
                <a href="#" className="text-[#3EB6EC] hover:text-[#2BA5DA] transition-colors">
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/></svg>
                </a>
                <a href="#" className="text-[#3EB6EC] hover:text-[#2BA5DA] transition-colors">
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><rect x="2" y="2" width="20" height="20" rx="5"/><circle cx="12" cy="12" r="5"/><circle cx="17.5" cy="6.5" r="1.5" fill="currentColor" stroke="none"/></svg>
                </a>
                <a href="#" className="text-[#3EB6EC] hover:text-[#2BA5DA] transition-colors">
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><circle cx="12" cy="12" r="10"/><path d="M8 11.857c0-2.14 1.27-3.857 2.857-3.857S13.714 9.717 13.714 11.857v.286h-5.714z"/><path d="M13.714 12.143v.571c0 2.14 1.27 3.857 2.857 3.857s2.857-1.717 2.857-3.857v-.571h-5.714z" strokeWidth="1.5"/><path d="M16.571 11.857a4.286 4.286 0 00-4.285-4.285A4.286 4.286 0 008 11.857v.286h8.571z" strokeWidth="1.5"/></svg>
                </a>
              </div>
            </div>

            {/* Pages Column */}
            <div className="space-y-4">
              <h4 className={`text-sm font-semibold ${titleClass}`}>{t.footer.pages}</h4>
              <ul className="space-y-3">
                {[
                  { key: "home", href: "#home" },
                  { key: "features", href: "#features" },
                  { key: "aboutUs", href: "#aboutUs" },
                  { key: "faq", href: "#faq" },
                  { key: "contact", href: {goContact} }
                ].map((item) => (
                  <li key={item.key}>
                    <a href={item.href} className={`text-sm transition-colors ${linkClass}`}>
                      {t.footer.links[item.key]}
                    </a>
                  </li>
                ))}
              </ul>
            </div>

            {/* Other Pages Column */}
            <div className="space-y-4">
              <h4 className={`text-sm font-semibold ${titleClass}`}>{t.footer.otherPages}</h4>
              <ul className="space-y-3">
                {[
                  { key: "terms", href: "#" },
                  { key: "privacy", href: "#" },
                  { key: "delete", href: "#" }
                ].map((item) => (
                  <li key={item.key}>
                    <a href={item.href} className={`text-sm transition-colors ${linkClass}`}>
                      {t.footer.otherLinks[item.key]}
                    </a>
                  </li>
                ))}
              </ul>
            </div>
          </div>

          <div className={`border-t mt-10 pt-6 text-center ${borderClass}`}>
            <p className={`text-sm ${copyrightClass}`}>
              {t.footer.copyright}
            </p>
          </div>
        </div>
      </div>
    </section>
  );
}