import React, { useState } from "react";
import axios from "axios";

/**
 * 분쟁유형 탭 컴포넌트 (BoonjangTab)
 * 
 * - Ai_boon FastAPI 서버와 연동 (포트 8001)
 * - /classify API 호출하여 분쟁 유형 분류
 * - 결과: 대분류, 세부분류, 당사자, 분쟁내용, 법적성격
 * 
 * Props:
 *   - inputText: 분석할 텍스트 (부모에서 전달)
 */

// Ai_boon 서버 주소 (분쟁 유형 분류 전용)
const BOONJANG_API = "http://localhost:8001";

// Spring Boot 백엔드 서버 주소 (결과 저장용)
const BACKEND_API = "http://localhost:8484";

export default function BoonjangTab({ inputText }) {
    // 이 탭만의 상태
    const [result, setResult] = useState(null);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);
    const [saving, setSaving] = useState(false);
    const [saveSuccess, setSaveSuccess] = useState(false);

    // 백엔드 저장 함수
    const handleSave = async () => {
        if (!result) {
            setError("저장할 분석 결과가 없습니다.");
            return;
        }

        setSaving(true);
        setSaveSuccess(false);

        try {
            console.log("[분쟁유형 탭] 백엔드 저장 시작...");

            // Spring Boot 백엔드로 저장 요청 (BoonjangDto 형식)
            // 유사(Yusa)처럼 읽기 좋은 텍스트 형식으로 저장
            const outputText = `[대분류] ${result.대분류}
[세부분류] ${result.세부분류}
[당사자] ${result.당사자}
[분쟁내용] ${result.분쟁내용}
[법적성격] ${result.법적성격}${result.분류이유 ? `
[분류이유] ${result.분류이유}` : ''}${result.키워드?.length > 0 ? `
[키워드] ${result.키워드.join(', ')}` : ''}`;

            const saveData = {
                boonjang_input: inputText,
                boonjang_output: outputText,
                boonjang_mark: 0
            };

            await axios.post(`${BACKEND_API}/api/boonjang/save`, saveData);

            console.log("[분쟁유형 탭] 저장 완료!");
            setSaveSuccess(true);

            // 3초 후 성공 메시지 숨김
            setTimeout(() => setSaveSuccess(false), 3000);

        } catch (err) {
            console.error("[분쟁유형 탭] 저장 오류:", err);

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

    // 분석 실행 함수
    const handleAnalyze = async () => {
        // 입력 검증
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
            console.log("[분쟁유형 탭] 분석 시작...");
            console.log("[분쟁유형 탭] API:", `${BOONJANG_API}/classify`);

            // Ai_boon /classify API 호출
            const response = await axios.post(`${BOONJANG_API}/classify`, {
                case_text: inputText
            });

            console.log("[분쟁유형 탭] 응답:", response.data);

            // 응답 저장
            setResult(response.data);
            console.log("[분쟁유형 탭] 분석 완료!");

        } catch (err) {
            console.error("[분쟁유형 탭] 분석 오류:", err);

            // 에러 메시지 처리
            let errorMsg = "분석 중 오류가 발생했습니다.";
            if (err.code === "ERR_NETWORK") {
                errorMsg = "분쟁 분류 서버에 연결할 수 없습니다. (포트 8001)";
            } else if (err.response?.data?.detail) {
                errorMsg = err.response.data.detail;
            }

            setError(errorMsg);
        } finally {
            setLoading(false);
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
                    <div className="absolute inset-0 border-4 border-blue-200 rounded-full"></div>
                    <div className="absolute inset-0 border-4 border-blue-600 rounded-full border-t-transparent animate-spin"></div>
                </div>
                <h3 className="text-lg font-semibold text-slate-800 mb-2">분쟁 유형 분석 중...</h3>
                <p className="text-sm text-slate-600">AI가 사건 유형을 분류하고 있습니다.</p>
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
                <div className="text-6xl mb-4">⚖️</div>
                <h3 className="text-xl font-semibold text-slate-800 mb-2">분쟁 유형 분석</h3>
                <p className="text-slate-600 mb-8">
                    사건의 법적 성격을 규명하고 핵심 쟁점을 도출합니다.
                </p>

                {/* ⭐ 이 탭만의 분석 버튼 */}
                <button
                    onClick={handleAnalyze}
                    className="
                        px-8 py-4 
                        bg-gradient-to-r from-blue-500 via-blue-600 to-indigo-600 
                        text-white text-base font-semibold rounded-xl 
                        transition-all duration-300 
                        hover:shadow-[0_8px_30px_rgba(59,130,246,0.4)] 
                        hover:scale-105
                        active:scale-95
                    "
                >
                    ⚖️ 분쟁 유형 분석하기
                </button>

                <p className="text-xs text-slate-400 mt-4">
                    Ai_boon 서버 (포트 8001)
                </p>
            </div>
        );
    }

    // 4) 결과 표시 - 테이블 형식
    return (
        <div className="space-y-6 p-6">
            <div className="flex items-center justify-between">
                <h3 className="text-lg font-semibold text-slate-800">📋 분쟁 유형 분석 결과</h3>
                <div className="flex items-center gap-2">
                    {/* 저장 성공 메시지 */}
                    {saveSuccess && (
                        <span className="text-sm text-green-600 font-medium">
                            ✅ 저장 완료!
                        </span>
                    )}
                    {/* 백엔드 저장 버튼 */}
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
                            <>
                                <span className="animate-spin">⏳</span> 저장 중...
                            </>
                        ) : (
                            <>💾 저장하기</>
                        )}
                    </button>
                    {/* 다시 분석 버튼 */}
                    <button
                        onClick={handleAnalyze}
                        className="px-4 py-2 text-sm bg-blue-50 text-blue-600 rounded-lg hover:bg-blue-100 transition"
                    >
                        🔄 다시 분석
                    </button>
                </div>
            </div>

            {/* 분류 결과 테이블 */}
            <div className="bg-gradient-to-br from-blue-50 to-indigo-50 rounded-xl overflow-hidden border border-blue-100">
                <table className="w-full">
                    <tbody>
                        <tr className="border-b border-blue-100">
                            <td className="px-4 py-3 bg-blue-100/50 font-semibold text-blue-800 w-28">대분류</td>
                            <td className="px-4 py-3">
                                <span className={`inline-block px-3 py-1 rounded-full font-semibold text-sm ${result.대분류 === "민사"
                                    ? "bg-blue-100 text-blue-700"
                                    : result.대분류 === "형사"
                                        ? "bg-red-100 text-red-700"
                                        : "bg-green-100 text-green-700"
                                    }`}>
                                    {result.대분류}
                                </span>
                            </td>
                        </tr>
                        <tr className="border-b border-blue-100">
                            <td className="px-4 py-3 bg-blue-100/50 font-semibold text-blue-800">세부분류</td>
                            <td className="px-4 py-3 text-slate-800">{result.세부분류}</td>
                        </tr>
                        <tr className="border-b border-blue-100">
                            <td className="px-4 py-3 bg-blue-100/50 font-semibold text-blue-800">당사자</td>
                            <td className="px-4 py-3 text-slate-800">{result.당사자}</td>
                        </tr>
                        <tr className="border-b border-blue-100">
                            <td className="px-4 py-3 bg-blue-100/50 font-semibold text-blue-800">분쟁내용</td>
                            <td className="px-4 py-3 text-slate-800">{result.분쟁내용}</td>
                        </tr>
                        <tr>
                            <td className="px-4 py-3 bg-blue-100/50 font-semibold text-blue-800">법적성격</td>
                            <td className="px-4 py-3 text-slate-800">{result.법적성격}</td>
                        </tr>
                    </tbody>
                </table>
            </div>

            {/* 분류 이유 */}
            {result.분류이유 && (
                <div className="bg-gradient-to-br from-green-50 to-emerald-50 rounded-xl p-5 border border-green-100">
                    <h4 className="text-sm font-semibold text-green-800 mb-2">💡 분류 근거</h4>
                    <p className="text-sm text-green-700 leading-relaxed">
                        {result.분류이유}
                    </p>
                </div>
            )}

            {/* 관련 키워드 */}
            {result.키워드 && result.키워드.length > 0 && (
                <div className="bg-gradient-to-br from-purple-50 to-pink-50 rounded-xl p-5 border border-purple-100">
                    <h4 className="text-sm font-semibold text-purple-800 mb-3">🏷️ 관련 키워드</h4>
                    <div className="flex flex-wrap gap-2">
                        {result.키워드.map((keyword, i) => (
                            <span
                                key={i}
                                className="px-3 py-1 bg-purple-100 text-purple-700 text-sm rounded-full"
                            >
                                {keyword}
                            </span>
                        ))}
                    </div>
                </div>
            )}
        </div>
    );
}
