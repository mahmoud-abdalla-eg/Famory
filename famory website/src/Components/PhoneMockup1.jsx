import React from "react";

export default function PhoneMockup1({ darkMode }) {
  const phoneBg = darkMode ? "#1E293B" : "#FFFFFF";
  const phoneText = darkMode ? "#F1F5F9" : "#1A2332";
  
  const memberBgClasses = darkMode 
    ? ["bg-[#334155]", "bg-[#3EB6EC]/30", "bg-[#4CAF8F]/30", "bg-[#FF8C42]/20"]
    : ["bg-[#FFE6D5]", "bg-[#3EB6EC]/30", "bg-[#4CAF8F]/30", "bg-[#FF8C42]/20"];

  return (
    <div className="relative w-[260px] h-[520px] bg-[#1A2332] rounded-[40px] p-[10px] shadow-2xl shadow-[#1A2332]/20 border border-gray-700" style={{ transform: "rotate(-3deg)" }}>
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[120px] h-[28px] bg-[#1A2332] rounded-b-2xl z-10" />
      <div className="w-full h-full rounded-[32px] overflow-hidden relative" style={{ backgroundColor: phoneBg }}>
        {/* Header */}
        <div className="bg-[#3EB6EC] px-4 pt-10 pb-4">
          <div className="flex items-center justify-between">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2"><path d="M19 12H5M12 19l-7-7 7-7"/></svg>
            <span className="text-white text-sm font-medium">Saved Albums</span>
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2"><path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9M13.73 21a2 2 0 01-3.46 0"/></svg>
          </div>
        </div>
        {/* Content */}
        <div className="p-3">
          <div className="text-center mb-3">
            <div className="w-16 h-16 bg-gradient-to-br from-[#3EB6EC] to-[#4CAF8F] rounded-full mx-auto flex items-center justify-center text-white text-xl mb-2">👨‍👦</div>
            <p className="text-xs font-semibold" style={{ color: phoneText }}>Moments that matter</p>
            <p className="text-[10px] text-[#3EB6EC]">Created by Chen Family</p>
            <p className="text-[10px] text-gray-400 mt-1">Love, laughter, and the moments</p>
            <p className="text-[10px] text-gray-400">that bring our family together.</p>
          </div>
          <div className="flex gap-2 overflow-hidden mb-3">
            {["James", "Ming", "Sara", "Ali"].map((name, i) => (
              <div key={i} className="flex-shrink-0 text-center">
                <div className={`w-10 h-10 rounded-full ${memberBgClasses[i]} flex items-center justify-center text-[10px] font-bold text-gray-700`}>
                  {name[0]}
                </div>
                <p className="text-[8px] text-gray-500 mt-0.5">{name}</p>
              </div>
            ))}
          </div>
          <p className="text-[10px] font-semibold" style={{ color: phoneText }}>Media</p>
          <div className="grid grid-cols-2 gap-1.5">
            <div className="aspect-square bg-gradient-to-br from-[#3EB6EC]/20 to-[#3EB6EC]/40 rounded-lg flex items-center justify-center">
              <div className="flex gap-0.5 items-end h-6">
                {[40,60,35,70,45].map((h, j) => (
                  <div key={j} className="w-1 bg-[#3EB6EC] rounded-full" style={{ height: `${h}%` }} />
                ))}
              </div>
            </div>
            <div className="aspect-square bg-gradient-to-br from-[#4CAF8F]/20 to-[#4CAF8F]/30 rounded-lg flex items-center justify-center text-xl">🏖️</div>
            <div className="aspect-square bg-gradient-to-br from-[#FF8C42]/20 to-[#FF8C42]/30 rounded-lg flex items-center justify-center text-xl">🎂</div>
            <div className="aspect-square bg-gradient-to-br from-[#FFE6D5] to-[#FFE6D5] rounded-lg flex items-center justify-center text-xl">🌅</div>
          </div>
        </div>
      </div>
    </div>
  );
}