import React from "react";

export default function LanguageToggle({ lang, setLang, darkMode }) {
  const langs = [
    { code: "en", label: "EN" },
    { code: "zh", label: "中文" },
    { code: "ar", label: "عربي" }
  ];

  const bgClass = darkMode ? "bg-[#334155]" : "bg-[#EAF6FC]";
  const activeClass = "bg-[#3EB6EC]";
  const inactiveClass = darkMode ? "text-gray-400" : "text-gray-500";

  return (
    <div className={`flex items-center gap-1 ${bgClass} rounded-lg p-0.5`}>
      {langs.map((l) => (
        <button
          key={l.code}
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
  );
}