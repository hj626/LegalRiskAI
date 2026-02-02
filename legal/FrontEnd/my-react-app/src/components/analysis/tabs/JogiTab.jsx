import React, { useState } from "react";
import axios from "axios";

/**
 * 해결 전략 탭 컴포넌트
 * - 자체 분석 버튼 보유
 * - /analyze API 호출 후 summary 사용
 * - AI 요약 및 해결책 표시
 * 
 * Props:
 *   - inputText: 분석할 텍스트 (부모에서 전달)
 */

const API_BASE = "http://localhost:8000";

export default function SolutionTab({ inputText }) {
    const [result, setResult] = useState(null);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);
    const [copied, setCopied] = useState(false);

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
            console.log("[해결전략 탭] 분석 시작...");

            // 두 API 동시 호출
            const [analyzeRes, riskRes] = await Promise.all([
                axios.post(`${API_BASE}/analyze`, { case_text: inputText }),
                axios.post(`${API_BASE}/risk-analyze`, { case_text: inputText }).catch(() => ({ data: null }))
            ]);

            setResult({
                summary: analyzeRes.data.summary,
                overallRisk: analyzeRes.data.overall_risk_level,
                feedback: riskRes.data?.feedback,
                classification: analyzeRes.data.classification
            });

            console.log("[해결전략 탭] 분석 완료");

        } catch (err) {
            console.error("[해결전략 탭] 분석 오류:", err);
            setError(err.response?.data?.detail || "해결 전략 분석 중 오류가 발생했습니다.");
        } finally {
            setLoading(false);
        }
    };

    // 복사 기능
    const handleCopy = async () => {
        const textToCopy = `[해결 전략 분석 결과]\n\n위험 수준: ${result.overallRisk}\n\n${result.summary}\n\n${result.feedback || ""}`;

        try {
            await navigator.clipboard.writeText(textToCopy);
            setCopied(true);
            setTimeout(() => setCopied(false), 2000);
        } catch (err) {
            console.error("복사 실패:", err);
        }
    };

    // 위험 수준 색상
    const getRiskLevelStyle = (level) => {
        switch (level) {
            case "높음":
                return { bg: "bg-red-100", text: "text-red-700", border: "border-red-200" };
            case "중간":
                return { bg: "bg-amber-100", text: "text-amber-700", border: "border-amber-200" };
            case "낮음":
                return { bg: "bg-green-100", text: "text-green-700", border: "border-green-200" };
            default:
                return { bg: "bg-slate-100", text: "text-slate-700", border: "border-slate-200" };
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
                <h3 className="text-lg font-semibold text-slate-800 mb-2">해결 전략 분석 중...</h3>
                <p className="text-sm text-slate-600">AI가 최적의 해결책을 찾고 있습니다.</p>
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
                <div className="text-6xl mb-4">💡</div>
                <h3 className="text-xl font-semibold text-slate-800 mb-2">해결 전략 분석</h3>
                <p className="text-slate-600 mb-8">
                    AI가 사건을 종합 분석하여 최적의 해결책을 제시합니다.
                </p>

                <button
                    onClick={handleAnalyze}
                    className="
            px-8 py-4 
            bg-gradient-to-r from-green-500 via-emerald-500 to-teal-500 
            text-white text-base font-semibold rounded-xl 
            transition-all duration-300 
            hover:shadow-[0_8px_30px_rgba(16,185,129,0.4)] 
            hover:scale-105
            active:scale-95
          "
                >
                    💡 해결 전략 분석하기
                </button>
            </div>
        );
    }

    // 결과 표시
    const riskStyle = getRiskLevelStyle(result.overallRisk);

    return (
        <div className="space-y-6 p-6">
            <div className="flex items-center justify-between">
                <h3 className="text-lg font-semibold text-slate-800">💡 해결 전략 분석 결과</h3>
                <div className="flex gap-2">
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

            {/* 위험 수준 */}
            <div className={`rounded-xl p-5 border ${riskStyle.bg} ${riskStyle.border}`}>
                <div className="flex items-center gap-3">
                    <span className="text-2xl">
                        {result.overallRisk === "높음" ? "🔴" : result.overallRisk === "중간" ? "🟡" : "🟢"}
                    </span>
                    <div>
                        <div className="text-sm text-slate-600">종합 위험 수준</div>
                        <div className={`text-xl font-bold ${riskStyle.text}`}>
                            {result.overallRisk}
                        </div>
                    </div>
                </div>
            </div>

            {/* 분쟁 유형 요약 */}
            {result.classification && (
                <div className="bg-blue-50 rounded-xl p-5 border border-blue-100">
                    <h4 className="text-sm font-semibold text-slate-700 mb-2">📌 분쟁 유형</h4>
                    <p className="text-base text-blue-700 font-medium">
                        {result.classification.inferred_type}
                        <span className="text-sm text-blue-500 ml-2">
                            (신뢰도 {((result.classification.confidence || 0) * 100).toFixed(0)}%)
                        </span>
                    </p>
                </div>
            )}

            {/* AI 요약 */}
            <div className="bg-gradient-to-br from-emerald-50 to-teal-50 rounded-xl p-6 border border-emerald-100">
                <h4 className="text-base font-semibold text-slate-800 mb-4">📝 AI 종합 분석</h4>
                <div className="text-sm text-slate-700 leading-relaxed whitespace-pre-line">
                    {result.summary}
                </div>
            </div>

            {/* Gemini 피드백 */}
            {result.feedback && (
                <div className="bg-gradient-to-br from-indigo-50 to-violet-50 rounded-xl p-6 border border-indigo-100">
                    <h4 className="text-base font-semibold text-slate-800 mb-4">🤖 AI 해결 제안 (Gemini)</h4>
                    <div className="text-sm text-slate-700 leading-relaxed whitespace-pre-line">
                        {result.feedback}
                    </div>
                </div>
            )}

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
