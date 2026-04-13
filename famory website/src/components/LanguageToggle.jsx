import React, { useEffect, useRef, useState } from "react";

export default function LanguageToggle({ lang, setLang, darkMode }) {
  const [open, setOpen] = useState(false);
  const wrapperRef = useRef(null);

  const langs = [
    { code: "en", label: "EN" },
    { code: "zh", label: "中文" },
    { code: "ar", label: "عربي" },
  ];

  const currentLang = langs.find((l) => l.code === lang) || langs[0];

  const bgClass = darkMode ? "bg-[#334155]" : "bg-[#EAF6FC]";
  const activeClass = "bg-[#3EB6EC]";
  const inactiveClass = darkMode ? "text-gray-400" : "text-gray-500";

  const menuClass = darkMode
    ? "bg-[#1E293B] border border-[#475569] shadow-xl"
    : "bg-white border border-[#D9E8F2] shadow-xl";

  const menuItemClass = darkMode
    ? "text-white hover:bg-[#334155]"
    : "text-gray-700 hover:bg-[#F3FAFE]";

  useEffect(() => {
    function handleClickOutside(e) {
      if (wrapperRef.current && !wrapperRef.current.contains(e.target)) {
        setOpen(false);
      }
    }

    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const handleSelect = (code) => {
    setLang(code);
    setOpen(false);
  };

  return (
    <>
      {/* Mobile dropdown */}
      <div className="sm:hidden relative" ref={wrapperRef}>
        <button
          type="button"
          onClick={() => setOpen((prev) => !prev)}
          className={`flex items-center justify-between gap-2 min-w-[78px] h-10 px-3 rounded-xl ${bgClass}`}
        >
          <span className={`text-sm font-bold ${darkMode ? "text-white" : "text-gray-700"}`}>
            {currentLang.label}
          </span>

          <svg
            className={`w-4 h-4 transition-transform duration-200 ${
              open ? "rotate-180" : ""
            } ${darkMode ? "text-white" : "text-gray-600"}`}
            viewBox="0 0 20 20"
            fill="currentColor"
          >
            <path
              fillRule="evenodd"
              d="M5.23 7.21a.75.75 0 011.06.02L10 11.17l3.71-3.94a.75.75 0 111.08 1.04l-4.25 4.5a.75.75 0 01-1.08 0l-4.25-4.5a.75.75 0 01.02-1.06z"
              clipRule="evenodd"
            />
          </svg>
        </button>

        {open && (
          <div className={`absolute right-0 top-[calc(100%+8px)] z-[999] w-32 rounded-xl overflow-hidden ${menuClass}`}>
            {langs.map((l) => {
              const active = lang === l.code;

              return (
                <button
                  key={l.code}
                  type="button"
                  onClick={() => handleSelect(l.code)}
                  className={`w-full text-left px-4 py-3 text-sm font-semibold transition-colors ${
                    active
                      ? `${activeClass} text-white`
                      : menuItemClass
                  }`}
                >
                  {l.label}
                </button>
              );
            })}
          </div>
        )}
      </div>

      {/* Desktop segmented toggle */}
      <div className={`hidden sm:flex items-center gap-1 ${bgClass} rounded-lg p-0.5`}>
        {langs.map((l) => (
          <button
            key={l.code}
            type="button"
            onClick={() => setLang(l.code)}
            className={`px-3 py-1.5 rounded-md text-xs font-bold transition-all duration-200 ${
              lang === l.code
                ? `${activeClass} text-white shadow-sm`
                : `${inactiveClass} hover:text-gray-800 dark:hover:text-white`
            }`}
          >
            {l.label}
          </button>
        ))}
      </div>
    </>
  );
}