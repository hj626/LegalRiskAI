import React, { useState } from "react";
import axios from "axios";

/**
 * 유사 판례 분석 탭 (YusaTab)
 * 
 * - Ai_yusa FastAPI 서버와 연동 (포트 8000)
 * - /precedent/analyze API 호출하여 유사 판례 검색
 * - 결과: 유사 판례 목록, 리스크 레벨, 요약
 * 
 * Props:
 *   - inputText: 분석할 텍스트 (부모에서 전달)
 */

// Ai_yusa 서버 주소 (유사 판례 검색 전용)
const YUSA_API = "http://localhost:8000";

// Spring Boot 백엔드 서버 주소 (결과 저장용)
const BACKEND_API = "http://localhost:8484";

/* =========================
   판례 전문 파싱 유틸
========================= */
const extractSection = (text, title) => {
    if (!text) return null;
    const koreanBracketPattern = new RegExp(
        `【${title}】([\\s\\S]*?)(?=【[^】]+】|$)`,
        "i"
    );
    const englishBracketPattern = new RegExp(
        `\\[${title}\\]([\\s\\S]*?)(?=\\[[^\\]]+\\]|$)`,
        "i"
    );
    return (
        text.match(koreanBracketPattern)?.[1]?.trim() ||
        text.match(englishBracketPattern)?.[1]?.trim() ||
        null
    );
};

const extractSentence = (text) => {
    if (!text) return null;
    const jail = text.match(/징역\s*\d+년(\s*\d+월)?/);
    const fine = text.match(/벌금\s*[\d,]+원/);
    if (jail) return jail[0];
    if (fine) return fine[0];
    return null;
};

export default function YusaTab({ inputText }) {
    // 상태 관리
    const [result, setResult] = useState(null);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);
    const [saving, setSaving] = useState(false);
    const [saveSuccess, setSaveSuccess] = useState(false);

    // 판례 상세 모달
    const [selectedCase, setSelectedCase] = useState(null);
    const [showIssues, setShowIssues] = useState(false);

    // 리스크 매핑
    const riskMap = {
        낮음: { score: 25, bar: "bg-green-500", text: "text-green-600", bgLight: "bg-green-50" },
        중간: { score: 55, bar: "bg-yellow-500", text: "text-yellow-600", bgLight: "bg-yellow-50" },
        높음: { score: 80, bar: "bg-red-500", text: "text-red-600", bgLight: "bg-red-50" },
    };

    // 사건 유형 아이콘
    const caseTypeIcons = {
        형사: "⚖️",
        가사: "👨‍👩‍👧",
        노동: "👷",
        민사: "📋",
        전체: "📋",
    };

    /* =========================
       1️⃣ AI 분석
    ========================= */
    const handleAnalyze = async () => {
        if (!inputText || !inputText.trim()) {
            setError("사건 내용을 먼저 입력해주세요.");
            return;
        }

        if (inputText.trim().length < 10) {
            setError("최소 10자 이상 입력해주세요.");
            return;
        }

        setLoading(true);
        setError(null);

        try {
            console.log("[유사 판례 탭] 분석 시작...");
            console.log("[유사 판례 탭] API:", `${YUSA_API}/precedent/analyze`);

            const response = await axios.post(`${YUSA_API}/precedent/analyze`, {
                case_text: inputText
            });

            console.log("[유사 판례 탭] 응답:", response.data);
            setResult(response.data);
            console.log("[유사 판례 탭] 분석 완료!");

        } catch (err) {
            console.error("[유사 판례 탭] 분석 오류:", err);

            let errorMsg = "분석 중 오류가 발생했습니다.";
            if (err.code === "ERR_NETWORK") {
                errorMsg = "유사 판례 서버에 연결할 수 없습니다. (포트 8000)";
            } else if (err.response?.data?.detail) {
                errorMsg = err.response.data.detail;
            }

            setError(errorMsg);
        } finally {
            setLoading(false);
        }
    };

    /* =========================
       2️⃣ 결과 저장
    ========================= */
    const handleSave = async () => {
        if (!result) {
            setError("저장할 분석 결과가 없습니다.");
            return;
        }

        setSaving(true);
        setSaveSuccess(false);

        try {
            console.log("[유사 판례 탭] 백엔드 저장 시작...");

            const outputText = `[사건유형] ${result.case_type_label}
[리스크] ${result.overall_risk_level}
[요약] ${result.summary}
[유사판례수] ${result.similar_cases?.length || 0}건`;

            const saveData = {
                yusa_input: inputText,
                yusa_output: outputText,
                yusa_mark: 0
            };

            await axios.post(`${BACKEND_API}/api/yusa/save`, saveData, {
                withCredentials: true
            });

            console.log("[유사 판례 탭] 저장 완료!");
            setSaveSuccess(true);
            setTimeout(() => setSaveSuccess(false), 3000);

        } catch (err) {
            console.error("[유사 판례 탭] 저장 오류:", err);

            let errorMsg = "저장 중 오류가 발생했습니다.";
            if (err.code === "ERR_NETWORK") {
                errorMsg = "백엔드 서버에 연결할 수 없습니다. (포트 8484)";
            } else if (err.response?.data?.message) {
                errorMsg = err.response.data.message;
            }

            setError(errorMsg);
        } finally {
            setSaving(false);
        }
    };

    /* =========================
       3️⃣ 판례 상세 조회
    ========================= */
    const handleSelectCase = async (c) => {
        const caseId = c.case_id || c.case_number;
        if (!caseId) {
            setError("전문 조회 불가");
            return;
        }

        try {
            const res = await axios.get(
                `${YUSA_API}/precedent/case/${encodeURIComponent(caseId)}/full`
            );

            setSelectedCase({
                ...res.data,
                summary: res.data.summary || c.xai_reason || "",
            });
            setShowIssues(false);
        } catch {
            setError("판례 전문 로드 실패");
        }
    };

    // =====================
    // 렌더링
    // =====================

    // 1) 로딩 중
    if (loading) {
        return (
            <div className="flex flex-col items-center justify-center py-24 px-6">
                <div className="relative w-20 h-20 mb-6">
                    <div className="absolute inset-0 border-4 border-purple-200 rounded-full"></div>
                    <div className="absolute inset-0 border-4 border-purple-600 rounded-full border-t-transparent animate-spin"></div>
                </div>
                <h3 className="text-lg font-semibold text-slate-800 mb-2">유사 판례 분석 중...</h3>
                <p className="text-sm text-slate-600">AI가 유사한 판례를 검색하고 있습니다.</p>
            </div>
        );
    }

    // 2) 에러 발생
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

    // 3) 결과 없음 (분석 전)
    if (!result) {
        return (
            <div className="flex flex-col items-center justify-center py-16 px-6 text-center">
                <div className="text-6xl mb-4">🔍</div>
                <h3 className="text-xl font-semibold text-slate-800 mb-2">유사 판례 분석</h3>
                <p className="text-slate-600 mb-8 leading-relaxed">
                    입력한 사건 내용과 유사한 실제 판례를<br />
                    AI가 분석하여 비교·정리해드립니다.
                </p>

                <button
                    onClick={handleAnalyze}
                    className="
                        px-8 py-4
                        bg-gradient-to-r from-indigo-500 via-purple-500 to-pink-500
                        text-white text-base font-semibold rounded-xl
                        transition-all duration-300
                        hover:shadow-[0_8px_30px_rgba(99,102,241,0.4)]
                        hover:scale-105
                        active:scale-95
                    "
                >
                    🔍 유사 판례 분석하기
                </button>

                <p className="text-xs text-slate-400 mt-4">
                    Ai_yusa 서버 (포트 8000)
                </p>
            </div>
        );
    }

    // 4) 결과 표시
    const risk = riskMap[result.overall_risk_level] || riskMap["중간"];

    return (
        <div className="space-y-6 p-6">
            {/* 헤더 */}
            <div className="flex items-center justify-between">
                <h3 className="text-lg font-semibold text-slate-800">📊 유사 판례 분석 결과</h3>
                <div className="flex items-center gap-2">
                    {saveSuccess && (
                        <span className="text-sm text-green-600 font-medium">
                            ✅ 저장 완료!
                        </span>
                    )}
                    <button
                        onClick={handleSave}
                        disabled={saving}
                        className={`px-4 py-2 text-sm rounded-lg transition flex items-center gap-1
                            ${saving
                                ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                                : 'bg-green-50 text-green-600 hover:bg-green-100'
                            }`}
                    >
                        {saving ? (
                            <><span className="animate-spin">⏳</span> 저장 중...</>
                        ) : (
                            <>💾 저장하기</>
                        )}
                    </button>
                    <button
                        onClick={handleAnalyze}
                        className="px-4 py-2 text-sm bg-purple-50 text-purple-600 rounded-lg hover:bg-purple-100 transition"
                    >
                        🔄 다시 분석
                    </button>
                </div>
            </div>

            {/* 사건 유형 카드 */}
            <div className="bg-gradient-to-br from-indigo-50 to-purple-50 rounded-xl p-5 border border-indigo-100">
                <div className="flex items-center gap-3 mb-2">
                    <span className="text-3xl">
                        {caseTypeIcons[result.inferred_case_type] || "📋"}
                    </span>
                    <div>
                        <strong className="text-lg text-indigo-800">
                            AI 판단: {result.case_type_label}
                        </strong>
                        <span className="ml-2 text-sm text-indigo-600">
                            (신뢰도: {Math.round(result.case_type_confidence * 100)}%)
                        </span>
                    </div>
                </div>
                <p className="text-sm text-indigo-700 ml-12">
                    {result.case_type_description}
                </p>
            </div>

            {/* 리스크 레벨 */}
            <div className={`rounded-xl p-5 border ${risk.bgLight} border-opacity-50`}>
                <div className="flex items-center justify-between mb-3">
                    <h4 className="text-sm font-semibold text-slate-700">⚠️ 리스크 레벨</h4>
                    <span className={`font-bold text-lg ${risk.text}`}>
                        {result.overall_risk_level}
                    </span>
                </div>
                <div className="bg-gray-200 h-3 rounded-full overflow-hidden">
                    <div
                        className={`${risk.bar} h-3 rounded-full transition-all duration-500`}
                        style={{ width: `${risk.score}%` }}
                    />
                </div>
            </div>

            {/* AI 요약 */}
            <div className="bg-gradient-to-br from-yellow-50 to-amber-50 rounded-xl p-5 border border-yellow-100">
                <h4 className="text-sm font-semibold text-amber-800 mb-3">📝 AI 요약</h4>
                <div className="text-sm text-amber-900 leading-relaxed whitespace-pre-wrap">
                    {result.summary}
                </div>
            </div>

            {/* 유사 판례 목록 */}
            <div className="bg-white rounded-xl border border-slate-200">
                <div className="px-5 py-4 border-b border-slate-100">
                    <h4 className="font-semibold text-slate-800">
                        📂 유사 판례 ({result.similar_cases?.length || 0}건)
                    </h4>
                </div>
                <div className="divide-y divide-slate-100">
                    {result.similar_cases?.map((c, i) => (
                        <div
                            key={i}
                            className="px-5 py-4 hover:bg-slate-50 cursor-pointer transition"
                            onClick={() => handleSelectCase(c)}
                        >
                            <div className="flex items-start justify-between">
                                <div className="flex-1">
                                    <strong className="text-sm text-slate-800 block mb-1">
                                        {c.case_name}
                                    </strong>
                                    <div className="flex items-center gap-2 text-xs text-slate-500">
                                        <span>{c.court}</span>
                                        <span>·</span>
                                        <span>{c.case_number}</span>
                                        <span>·</span>
                                        <span className="text-blue-600 font-medium">
                                            {c.case_type_label}
                                        </span>
                                    </div>
                                </div>
                                <div className="text-right">
                                    <span className="inline-block px-2 py-1 bg-blue-100 text-blue-700 text-xs rounded-full font-medium">
                                        유사도 {Math.round(c.similarity * 100)}%
                                    </span>
                                    <div className="text-xs text-slate-500 mt-1">
                                        {c.decision_result}
                                    </div>
                                </div>
                            </div>
                            {c.xai_reason && (
                                <p className="text-xs text-slate-600 mt-2 bg-slate-50 p-2 rounded">
                                    💡 {c.xai_reason}
                                </p>
                            )}
                        </div>
                    ))}
                </div>
            </div>

            {/* =========================
                판례 상세 모달
            ========================= */}
            {selectedCase && (
                <div className="fixed inset-0 bg-black bg-opacity-50 flex justify-center items-center z-50 p-4">
                    <div className="bg-white rounded-2xl w-full max-w-3xl max-h-[90vh] overflow-hidden flex flex-col">
                        {/* 모달 헤더 */}
                        <div className="px-6 py-4 border-b bg-gradient-to-r from-indigo-500 to-purple-500">
                            <h3 className="font-bold text-xl text-white">
                                {selectedCase.case_name}
                            </h3>
                        </div>

                        {/* 모달 컨텐츠 */}
                        <div className="flex-1 overflow-y-auto p-6 space-y-4">
                            {/* 요약 */}
                            {selectedCase.summary && (
                                <div className="bg-yellow-50 rounded-xl p-4 border border-yellow-200">
                                    <strong className="block mb-2 text-yellow-800">📝 요약</strong>
                                    <pre className="text-sm whitespace-pre-wrap text-yellow-900">
                                        {selectedCase.summary}
                                    </pre>
                                </div>
                            )}

                            {/* 주문 */}
                            {extractSection(selectedCase.full_text, "주\\s*문") && (
                                <div className="bg-red-50 rounded-xl p-4 border-l-4 border-red-500">
                                    <strong className="block mb-2 text-red-800">⚖️ 주 문</strong>
                                    <pre className="text-sm whitespace-pre-wrap text-red-900">
                                        {extractSection(selectedCase.full_text, "주\\s*문")}
                                    </pre>
                                </div>
                            )}

                            {/* 형량 */}
                            {extractSentence(selectedCase.full_text) && (
                                <div className="bg-orange-50 rounded-xl p-4 border border-orange-200">
                                    <strong className="text-orange-800">
                                        ⚠️ 형량: {extractSentence(selectedCase.full_text)}
                                    </strong>
                                </div>
                            )}

                            {/* 판시사항 토글 */}
                            <button
                                onClick={() => setShowIssues(!showIssues)}
                                className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition"
                            >
                                {showIssues ? "📖 판시사항 닫기" : "📖 판시사항 보기"}
                            </button>

                            {showIssues && extractSection(selectedCase.full_text, "판시사항") && (
                                <div className="bg-blue-50 rounded-xl p-4 border border-blue-200">
                                    <strong className="block mb-2 text-blue-800">판시사항</strong>
                                    <pre className="text-sm whitespace-pre-wrap text-blue-900">
                                        {extractSection(selectedCase.full_text, "판시사항")}
                                    </pre>
                                </div>
                            )}

                            {/* 판례 전문 */}
                            <details className="bg-slate-50 rounded-xl border">
                                <summary className="cursor-pointer font-semibold text-slate-700 hover:text-blue-600 px-4 py-3">
                                    📄 판례 전문 보기
                                </summary>
                                <div className="p-4 border-t">
                                    <pre className="text-xs whitespace-pre-wrap text-slate-600 max-h-96 overflow-y-auto">
                                        {selectedCase.full_text}
                                    </pre>
                                </div>
                            </details>
                        </div>

                        {/* 모달 푸터 */}
                        <div className="px-6 py-4 border-t bg-slate-50">
                            <button
                                onClick={() => setSelectedCase(null)}
                                className="w-full bg-slate-800 text-white py-3 rounded-xl hover:bg-slate-900 transition font-medium"
                            >
                                닫기
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}
