// 법적 리스크 탭 컴포넌트
// 위험도   /analyze/legal-risk API 호출

import React, { useState } from "react";
import axios from "axios";

/**
* - 자체 분석 버튼 보유
 * - AI 요약 및 해결책 표시
 * - 저장 기능 추가
 */

// fast apu서버 주소
const API_BASE = "http://localhost:8002"; 

// 백엔드 api주소
const BACKEND_API = "http://localhost:8484";


export default function SolutionTab({ inputText }) {
    const [result, setResult] = useState(null);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);
    const [copied, setCopied] = useState(false);
    const [saving, setSaving] = useState(false);
    const [saveSuccess, setSaveSuccess] = useState(false);

    // 저장 함수
    const handleSave = async () => {
        if (!result) {
            setError("저장할 분석 결과가 없습니다.");
            return;
        }

        setSaving(true);
        setSaveSuccess(false);

        try {
            const outputText = `[법적 리스크 분석 결과]

[위험도] ${result.risk}%
[사건 유형] ${result.case_type}
[예상 형량] ${result.sentence}
[예상 벌금] ${result.fine.toLocaleString()}원`;

            await axios.post(`${BACKEND_API}/api/law/save`, {
                law_input: inputText,
                law_output: outputText,
                law_mark: 0
            });

            setSaveSuccess(true);
            setTimeout(() => setSaveSuccess(false), 3000);
        } catch (err) {
            console.error("[법적 리스크 탭] 저장 오류:", err);
            setError("저장 중 오류가 발생했습니다.");
        } finally {
            setSaving(false);
        }
    };


    const handleAnalyze = async () => {
        if (!inputText || !inputText.trim()) {
            setError("사건 내용을 먼저 입력해주세요.");
            return;
        }

        if (inputText.trim().length < 50) {
            setError("최소 50자 이상 입력해주세요.");
            return;
        }

        setLoading(true);
        setError(null);

        try {
            console.log("[위험도 분석 탭] 분석 시작.");


            // 2/4추가 hj
            // jogi - main.py에서 /analyze 엔드포인트와 동일하게 story 내용을 받음
            const response = await axios.post(`${API_BASE}/analyze/legal-risk`, {
                story: inputText
            });

            const data = response.data;

            if (data.success) {
                // jogi- main.py와 필드명 동일하게 셋팅
                setResult({
                    risk: data.risk,           // 위험도 (0-100)
                    sentence: data.sentence,   // 예상 형량
                    fine: data.fine,           // 예상 벌금
                    case_type: data.case_type  // 사건 종류
                });
            console.log("[법적 리스크 탭] 분석 완료");
        } else {
            throw new Error("분석에 실패했습니다.");
        }

    } catch (err) {
        console.error("[법적 리스크 탭] 분석 오류:", err);
        setError("AI 서버(8002) 연결 실패. 서버가 켜져 있는지 확인하세요.");
    } finally {
        setLoading(false);
    }
};


    // 복사 기능
    const handleCopy = async () => {
        const textToCopy = `[법적 리스크 분석 결과]

위험도: ${result.risk}%
사건 유형: ${result.case_type}
예상 형량: ${result.sentence}
예상 벌금: ${result.fine.toLocaleString()}원`;

        try {
            await navigator.clipboard.writeText(textToCopy);
            setCopied(true);
            setTimeout(() => setCopied(false), 2000);
        } catch (err) {
            console.error("복사 실패:", err);
        }
    };

    // 위험 수준 색상
    const getRiskLevelStyle = (riskValue) => {
        if (riskValue >= 70) {
            return { bg: "bg-red-100", text: "text-red-700", border: "border-red-200", label: "높음 (긴급)" };
        } else if (riskValue >= 40) {
            return { bg: "bg-amber-100", text: "text-amber-700", border: "border-amber-200", label: "중간" };
        } else {
            return { bg: "bg-green-100", text: "text-green-700", border: "border-green-200", label: "낮음" };
        }
    };


    // =====================
    // 렌더링
    // =====================

    if (loading) {
        return (
            <div className="flex flex-col items-center justify-center py-24 px-6">
                <div className="relative w-20 h-20 mb-6">
                    <div className="absolute inset-0 border-4 border-emerald-200 rounded-full"></div>
                    <div className="absolute inset-0 border-4 border-emerald-600 rounded-full border-t-transparent animate-spin"></div>
                </div>
                <h3 className="text-lg font-semibold text-slate-800 mb-2">법적 리스크 분석 중...</h3>
                <p className="text-sm text-slate-600">위험도, 형량, 벌금을 분석하고 있습니다.</p>
            </div>
        );
    }


    if (error) {
        return (
            <div className="p-6">
                <div className="bg-red-50 border border-red-200 rounded-xl p-6 text-center">
                    <span className="text-4xl mb-4 block">❌</span>
                    <p className="text-red-600 font-medium">{error}</p>
                    <button
                        onClick={() => setError(null)}
                        className="mt-4 px-4 py-2 bg-red-100 text-red-700 rounded-lg hover:bg-red-200 transition"
                    >
                        다시 시도
                    </button>
                </div>
            </div>
        );
    }

    if (!result) {
        return (
            <div className="flex flex-col items-center justify-center py-16 px-6 text-center">
                <div className="text-6xl mb-4">⚖️</div>
                <h3 className="text-xl font-semibold text-slate-800 mb-2">법적 리스크 분석</h3>
                <p className="text-slate-600 mb-8">
                    AI가 위험도, 예상 형량, 예상 벌금을 분석합니다.
                </p>

                <button
                    onClick={handleAnalyze}
                    className="px-8 py-4 bg-gradient-to-r from-green-500 via-emerald-500 to-teal-500 text-white text-base font-semibold rounded-xl transition-all duration-300 hover:shadow-[0_8px_30px_rgba(16,185,129,0.4)] hover:scale-105 active:scale-95"
                >
                    💡 법적 리스크 분석하기
                </button>
            </div>
        );
    }

    // 결과 표시
    const riskStyle = getRiskLevelStyle(result.risk);

    return (
        <div className="space-y-6 p-6">
            <div className="flex items-center justify-between">
                <h3 className="text-lg font-semibold text-slate-800">💡 법적 리스크 분석결과</h3>
                <div className="flex gap-2">
                    <button
                        onClick={handleSave}
                        disabled={saving}
                        className="px-4 py-2 text-sm bg-green-50 text-green-600 rounded-lg hover:bg-green-100 transition disabled:opacity-50"
                    >
                        {saving ? "저장 중." : saveSuccess ? "✅ 저장됨" : "💾 저장"}
                    </button>
                    <button
                        onClick={handleCopy}
                        className="px-4 py-2 text-sm bg-slate-50 text-slate-600 rounded-lg hover:bg-slate-100 transition"
                    >
                        {copied ? "✅ 복사됨!" : "📋 복사"}
                    </button>
                    <button
                        onClick={handleAnalyze}
                        className="px-4 py-2 text-sm bg-emerald-50 text-emerald-600 rounded-lg hover:bg-emerald-100 transition"
                    >
                        🔄 다시 분석
                    </button>
                </div>
            </div>

            {/* 저장 성공 메시지 */}
            {saveSuccess && (
                <div className="bg-green-50 border border-green-200 rounded-lg p-3 text-green-700 text-sm">
                    ✅ 분석 결과가 저장되었습니다.
                </div>
            )}

            {/* 위험도 */}
            <div className={`rounded-xl p-6 border ${riskStyle.bg} ${riskStyle.border}`}>
                <div className="flex items-center gap-4">
                    <span className="text-4xl">
                        {result.risk >= 70 ? "🔴" : result.risk >= 40 ? "🟡" : "🟢"}
                    </span>
                    <div className="flex-1">
                        <div className="text-sm text-slate-600 mb-1">법적 위험도</div>
                        <div className={`text-3xl font-bold ${riskStyle.text}`}>
                            {result.risk}%
                        </div>
                        <div className="text-sm text-slate-600 mt-1">
                            위험 수준: {riskStyle.label}
                        </div>
                    </div>
                </div>
            </div>


            {/* 예상 형량 */}
            <div className="bg-gradient-to-br from-purple-50 to-pink-50 rounded-xl p-6 border border-purple-100">
                <h4 className="text-base font-semibold text-slate-800 mb-3">⏱️ 예상 형량</h4>
                <div className="text-2xl font-bold text-purple-700">
                    {result.sentence}
                </div>
            </div>

            {/* 예상 벌금 */}
            <div className="bg-gradient-to-br from-orange-50 to-red-50 rounded-xl p-6 border border-orange-100">
                <h4 className="text-base font-semibold text-slate-800 mb-3">💰 예상 벌금</h4>
                <div className="text-2xl font-bold text-orange-700">
                    {result.fine.toLocaleString()}원
                </div>
            </div>



           {/* 다음 단계 가이드 */}
            <div className="bg-slate-50 rounded-xl p-6 border border-slate-200">
                <h4 className="text-base font-semibold text-slate-800 mb-4">📋 권장 다음 단계</h4>
                <ul className="space-y-3">
                    <li className="flex items-start gap-3">
                        <span className="flex-shrink-0 w-6 h-6 bg-blue-100 text-blue-700 rounded-full flex items-center justify-center text-sm font-medium">1</span>
                        <span className="text-sm text-slate-600">관련 자료 및 증거를 정리해주세요</span>
                    </li>
                    <li className="flex items-start gap-3">
                        <span className="flex-shrink-0 w-6 h-6 bg-blue-100 text-blue-700 rounded-full flex items-center justify-center text-sm font-medium">2</span>
                        <span className="text-sm text-slate-600">법률 전문가에게 상담을 받아보세요</span>
                    </li>
                    <li className="flex items-start gap-3">
                        <span className="flex-shrink-0 w-6 h-6 bg-blue-100 text-blue-700 rounded-full flex items-center justify-center text-sm font-medium">3</span>
                        <span className="text-sm text-slate-600">유사 판례의 판결 결과를 참고해주세요</span>
                    </li>
                </ul>
            </div>
        </div>
    );
}