import React from "react";

export default function PhoneMockup2({ darkMode }) {
  const phoneBg = darkMode ? "#1E293B" : "#FFFFFF";
  const phoneText = darkMode ? "#F1F5F9" : "#1A2332";
  const headerBorder = darkMode ? "bg-[#1E293B] border-[#334155]" : "bg-white border-gray-100";
  const cardBg = darkMode ? "bg-[#1E293B] border-[#334155]" : "bg-gray-50 border-gray-100";
  const tabInactive = darkMode ? "bg-[#334155] text-gray-400" : "bg-gray-100 text-gray-600";
  const tagSecondary = darkMode ? "bg-[#334155] text-gray-400" : "bg-gray-200 text-gray-600";

  return (
    <div className="relative w-[260px] h-[520px] bg-[#1A2332] rounded-[40px] p-[10px] shadow-2xl shadow-[#1A2332]/20 border border-gray-700" style={{ transform: "rotate(3deg)", marginTop: "20px" }}>
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[120px] h-[28px] bg-[#1A2332] rounded-b-2xl z-10" />
      <div className="w-full h-full rounded-[32px] overflow-hidden relative" style={{ backgroundColor: phoneBg }}>
        {/* Header */}
        <div className={`${headerBorder} border-b px-4 pt-10 pb-3`}>
          <div className="flex items-center justify-between">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke={darkMode ? "#94A3B8" : "#374151"} strokeWidth="2"><path d="M19 12H5M12 19l-7-7 7-7"/></svg>
            <span className="text-sm font-medium" style={{ color: phoneText }}>Family Polls</span>
            <div className="w-5" />
          </div>
        </div>
        {/* Content */}
        <div className="p-3">
          <div className="mb-3">
            <h3 className="text-base font-bold mb-1" style={{ color: phoneText }}>Manage Your Polls</h3>
            <p className="text-[10px] text-gray-500">Vote and see real-time family decisions.</p>
          </div>
          <div className="flex gap-1 mb-3">
            {["All", "Today", "Week"].map((tab, i) => (
              <button key={i} className={`px-3 py-1 rounded-full text-[10px] font-medium ${i === 0 ? "bg-[#3EB6EC] text-white" : tabInactive}`}>{tab}</button>
            ))}
          </div>
          <div className="space-y-2">
            <div className={`${cardBg} rounded-xl p-3 border`}>
              <p className="text-xs font-semibold mb-2" style={{ color: phoneText }}>🍕 Dinner tonight?</p>
              <div className="space-y-1.5">
                {["Italian", "Chinese", "Arabic"].map((option, idx) => (
                  <div key={option}>
                    <div className="flex justify-between text-[10px] mb-0.5">
                      <span className="text-gray-500">{option}</span>
                      <span className="text-gray-500">{3 - idx} votes</span>
                    </div>
                    <div className="h-2 bg-gray-700 rounded-full overflow-hidden">
                      <div className="h-full bg-[#FF8C42] rounded-full" style={{ width: `${(3 - idx) * 25}%` }} />
                    </div>
                  </div>
                ))}
              </div>
            </div>
            <div className={`${cardBg} rounded-xl p-3 border`}>
              <p className="text-xs font-semibold mb-2" style={{ color: phoneText }}>🏖️ Weekend plans?</p>
              <div className="flex gap-1.5">
                <span className="text-[10px] bg-[#4CAF8F]/20 text-[#4CAF8F] px-2 py-0.5 rounded-full">Beach (4)</span>
                <span className={`text-[10px] ${tagSecondary} px-2 py-0.5 rounded-full`}>Park (2)</span>
              </div>
            </div>
          </div>
          <div className="mt-3 bg-[#3EB6EC]/10 rounded-xl p-3 flex items-center gap-2">
            <div className="w-8 h-8 bg-[#3EB6EC] rounded-lg flex items-center justify-center">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2"><path d="M12 5v14M5 12h14"/></svg>
            </div>
            <p className="text-[10px] font-medium" style={{ color: phoneText }}>Create new poll...</p>
          </div>
        </div>
      </div>
    </div>
  );
}