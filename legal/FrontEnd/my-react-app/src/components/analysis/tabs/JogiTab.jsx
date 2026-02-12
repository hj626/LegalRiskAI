// 해결 전략 탭 컴포넌트
// 승소율 /analyze/win-rate

import React, { useState } from "react";
import axios from "axios";

/**
 * - 자체 분석 버튼 보유
 * - /analyze API 호출 후 summary 사용
 * - AI 요약 및 해결책 표시
 * - 저장 기능 추가
 */

// fast apu서버 주소
const API_BASE = "http://localhost:8002"; 

// 백엔드 api주소
const BACKEND_API = "http://localhost:8484";


export default function RiskTab({ inputText }) {
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
            const outputText = `[승소율 분석 결과]

[승소 가능성] ${result.win_rate}%
[AI 피드백]
${result.feedback}
${result.legal_list && result.legal_list.length > 0 ? `
[관련 법률]
${result.legal_list.join(', ')}` : ''}`;

            await axios.post(`${BACKEND_API}/api/jogi/save`, {
                jogi_input: inputText,
                jogi_output: outputText,
                jogi_winrate: result.win_rate,
                jogi_mark: 0
            });

            setSaveSuccess(true);
            setTimeout(() => setSaveSuccess(false), 3000);
        } catch (err) {
            console.error("[승소율 탭] 저장 오류:", err);
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
            console.log("[승소율 탭] 분석 시작.");


            // 2/4추가 hj
            // jogi - main.py에서 /analyze 엔드포인트와 동일하게 story 내용을 받음
             const response = await axios.post(`${API_BASE}/analyze/win-rate`, {

                story: inputText
            });

            const data = response.data;

            if (data.success) {
                // jogi- main.py와 필드명 동일하게 셋팅
                setResult({
                    win_rate: data.win_rate,      // 승소율 (0-100)
                    feedback: data.feedback,      // AI 피드백
                    legal_list: data.legal_list   // 관련 법률 목록
                });
                console.log("[승소율 탭] 분석 완료");
        } else {
            throw new Error(data.feedback || "분석에 실패했습니다.");
        }

    } catch (err) {
        console.error("[승소율 분석 탭] 분석 오류:", err);
        setError("AI 서버(8002) 연결 실패. 서버가 켜져 있는지 확인하세요.");
    } finally {
        setLoading(false);
    }
};



    // 복사 기능
    const handleCopy = async () => {
        const textToCopy = `[승소율 분석 결과]

승소 가능성: ${result.win_rate}%

${result.feedback}

${result.legal_list && result.legal_list.length > 0 ? `관련 법률: ${result.legal_list.join(', ')}` : ''}`;

        try {
            await navigator.clipboard.writeText(textToCopy);
            setCopied(true);
            setTimeout(() => setCopied(false), 2000);
        } catch (err) {
            console.error("복사 실패:", err);
        }
    };

    // 승소율 수준 색상
    const getWinRateStyle = (winRate) => {
        if (winRate >= 70) {
            return { bg: "bg-green-100", text: "text-green-700", border: "border-green-200", label: "높음 (유리)" };
        } else if (winRate >= 40) {
            return { bg: "bg-amber-100", text: "text-amber-700", border: "border-amber-200", label: "중간" };
        } else {
            return { bg: "bg-red-100", text: "text-red-700", border: "border-red-200", label: "낮음 (불리)" };
        }
    };


    // 렌더링
    if (loading) {
        return (
            <div className="flex flex-col items-center justify-center py-24 px-6">
                <div className="relative w-20 h-20 mb-6">
                    <div className="absolute inset-0 border-4 border-emerald-200 rounded-full"></div>
                    <div className="absolute inset-0 border-4 border-emerald-600 rounded-full border-t-transparent animate-spin"></div>
                </div>
                <h3 className="text-lg font-semibold text-slate-800 mb-2">승소율 분석 중...</h3>
                <p className="text-sm text-slate-600">AI가 승소 가능성을 분석하고 있습니다.</p>
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
                <h3 className="text-xl font-semibold text-slate-800 mb-2">승소율 분석</h3>
                <p className="text-slate-600 mb-8">
                    AI가 승소 가능성과 상세한 피드백을 제공합니다.
                </p>

                 <button
                    onClick={handleAnalyze}
                    className="px-8 py-4 bg-gradient-to-r from-green-500 via-emerald-500 to-teal-500 text-white text-base font-semibold rounded-xl transition-all duration-300 hover:shadow-[0_8px_30px_rgba(16,185,129,0.4)] hover:scale-105 active:scale-95"
                >
                    📊 승소율 분석하기
                </button>
            </div>
        );
    }

    // 결과 표시
    const winRateStyle = getWinRateStyle(result.win_rate);

    return (
        <div className="space-y-6 p-6">
            <div className="flex items-center justify-between">
                <h3 className="text-lg font-semibold text-slate-800">📊 승소율 분석 결과</h3>
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

            {/* 승소율 */}
            <div className={`rounded-xl p-6 border ${winRateStyle.bg} ${winRateStyle.border}`}>
                <div className="flex items-center gap-4">
                    <span className="text-4xl">
                        {result.win_rate >= 70 ? "🎯" : result.win_rate >= 40 ? "⚖️" : "📉"}
                    </span>
                    <div className="flex-1">
                        <div className="text-sm text-slate-600 mb-1">승소 가능성</div>
                        <div className={`text-3xl font-bold ${winRateStyle.text}`}>
                            {result.win_rate}%
                        </div>
                        <div className="text-sm text-slate-600 mt-1">
                            승소율 평가: {winRateStyle.label}
                        </div>
                    </div>
                </div>
            </div>


             {/* AI 피드백 */}
            <div className="bg-gradient-to-br from-indigo-50 to-violet-50 rounded-xl p-6 border border-indigo-100">
                <h4 className="text-base font-semibold text-slate-800 mb-4">AI 승소율 분석 피드백</h4>
                <div className="text-sm text-slate-700 leading-relaxed whitespace-pre-line">
                    {result.feedback}
                </div>
            </div>

            {/* 관련 법률 */}
            {result.legal_list && result.legal_list.length > 0 && (
                <div className="bg-blue-50 rounded-xl p-5 border border-blue-100">
                    <h4 className="text-sm font-semibold text-slate-700 mb-3">📚 관련 법률</h4>
                    <div className="flex flex-wrap gap-2">
                        {result.legal_list.map((law, index) => (
                            <span
                                key={index}
                                className="px-3 py-1 bg-blue-100 text-blue-700 rounded-full text-sm font-medium"
                            >
                                {law}
                            </span>
                        ))}
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