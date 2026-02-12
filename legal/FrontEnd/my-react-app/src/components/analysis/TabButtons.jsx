import React from "react";

/**
 * 탭 버튼 컴포넌트
 * - 4개의 탭 버튼 표시 (분쟁유형, 리스크, 유사판례, 해결전략)
 * - 선택된 탭을 파란색으로 하이라이트
 * 
 * Props:
 *   - activeTab: 현재 선택된 탭 ID ("dispute", "risk", "similar", "solution")
 *   - onTabChange: 탭 클릭 시 호출되는 함수
 */

// 탭 정보 배열
const TABS = [
  { id: "similar",  label: "유사 판례",   icon: "🔍" },
  { id: "solution",     label: "승소율 분석", icon: "💡" },
  { id: "risk", label: "위험도 분석",   icon: "⚠️" },
];

export default function TabButtons({ activeTab, onTabChange }) {
  return (
    <div className="flex border-b border-slate-200 bg-slate-50">
      {TABS.map((tab) => (
        <button
          key={tab.id}
          type="button"
          onClick={() => onTabChange(tab.id)}
          className={`
            flex-1 flex items-center justify-center gap-2 
            py-4 px-4 text-sm font-medium 
            transition-all border-b-2
            ${activeTab === tab.id
              ? "border-blue-500 text-blue-600 bg-white"
              : "border-transparent text-slate-600 hover:text-slate-800 hover:bg-slate-100"
            }
          `}
        >
          <span className="text-base">{tab.icon}</span>
          <span>{tab.label}</span>
        </button>
      ))}
    </div>
  );
}

// 탭 정보 export (다른 곳에서 사용 가능)
export { TABS };
