import React, { useState } from "react";

// 분리된 컴포넌트들 import
import {
    TabButtons,
    BoonjangTab,
    RiskTab,
    YusaTab,
    JogiTab
} from "../components/analysis";

/**
 * AI 사건 분석 페이지
 * 
 * 레이아웃: 기존 스타일 유지
 * - 왼쪽: 입력 폼 + 분석 버튼
 * - 오른쪽: 탭 결과 (각 탭에서 개별 분석 가능)
 */
export default function AIAnalysis() {
    const [inputText, setInputText] = useState("");
    const [activeTab, setActiveTab] = useState("similar");

    // 탭별 컴포넌트 렌더링
    const renderTabContent = () => {
        const commonProps = { inputText };

        switch (activeTab) {
            case "dispute":
                return <BoonjangTab {...commonProps} />;
            case "risk":
                return <RiskTab {...commonProps} />;
            case "similar":
                return <YusaTab {...commonProps} />;
            case "solution":
                return <JogiTab {...commonProps} />;
            default:
                return <BoonjangTab {...commonProps} />;
        }
    };

    return (
        <div className="min-h-[calc(100vh-64px)] bg-slate-50 px-4 md:px-10 lg:px-20 py-6 md:py-10 lg:py-15">
            {/* 페이지 헤더 */}
            <div className="flex items-center gap-3.5 mb-6 md:mb-8 max-w-[1450px] mx-auto">
                <div className="w-10 h-10 md:w-13 md:h-13 bg-gradient-to-br from-blue-500 to-blue-600 rounded-[14px] flex items-center justify-center shadow-[0_2px_10px_rgba(59,130,246,0.25)] flex-shrink-0">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                        <path d="M17 3a2.828 2.828 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5L17 3z" />
                    </svg>
                </div>
                <div>
                    <h1 className="text-xl md:text-[26px] font-bold text-slate-800 m-0">AI 사건 분석</h1>
                    <p className="text-xs md:text-sm text-slate-600 mt-1 md:mt-1.5 m-0">사건의 사실관계를 입력하여 법률 리스크를 진단하세요.</p>
                </div>
            </div>

            {/* 메인 컨텐츠 - 반응형 그리드 */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-4 md:gap-6 max-w-[1450px] mx-auto">
                {/* 왼쪽: 입력 영역 */}
                <div className="bg-white rounded-[18px] shadow-[0_2px_8px_rgba(0,0,0,0.06)] overflow-hidden min-h-[400px] lg:min-h-[850px] p-5 md:p-7 flex flex-col">
                    <div className="flex items-center gap-2.5 text-base md:text-[17px] font-semibold text-slate-800 mb-4">
                        <span className="text-xl text-blue-500">✏️</span>
                        <span>사실관계 입력</span>
                    </div>

                    <textarea
                        className="w-full flex-1 min-h-[250px] md:min-h-[400px] lg:min-h-[580px] p-4 md:p-4.5 border border-slate-200 rounded-xl text-sm md:text-[15px] leading-relaxed resize-y bg-slate-50 transition-all focus:outline-none focus:border-blue-400 focus:bg-white focus:shadow-[0_0_0_3px_rgba(59,130,246,0.1)]"
                        placeholder="사건의 구체적인 내용을 자유롭게 작성해주세요.&#10;(예: 계약 일시, 당사자, 피해 금액, 현재 상황 등)"
                        value={inputText}
                        onChange={(e) => setInputText(e.target.value)}
                    />

                    <div className="flex justify-between items-center mt-3 mb-4">
                        <span className="text-xs text-slate-500">{inputText.length}자 입력됨</span>
                        {inputText.length > 0 && inputText.length < 50 && (
                            <span className="text-xs text-amber-500">최소 50자 이상 권장</span>
                        )}
                    </div>

                    {/* 안내 박스 */}
                    <div className="bg-blue-50 rounded-xl p-4 border border-blue-100 mb-4">
                        <h4 className="text-sm font-semibold text-blue-800 mb-2">💡 사용 방법</h4>
                        <ol className="text-xs md:text-sm text-blue-700 space-y-1">
                            <li>1. 왼쪽에 사건 내용을 입력</li>
                            <li>2. 오른쪽에서 원하는 탭 선택</li>
                            <li>3. 탭 안의 <strong>분석 버튼</strong> 클릭</li>
                        </ol>
                    </div>
                </div>

                {/* 오른쪽: 결과 영역 */}
                <div className="bg-white rounded-[18px] shadow-[0_2px_8px_rgba(0,0,0,0.06)] overflow-hidden min-h-[400px] lg:min-h-[850px] flex flex-col">
                    {/* 탭 버튼 */}
                    <TabButtons
                        activeTab={activeTab}
                        onTabChange={setActiveTab}
                    />

                    {/* 탭 내용 */}
                    <div className="flex-1 overflow-y-auto">
                        {renderTabContent()}
                    </div>
                </div>
            </div>
        </div>
    );
}
