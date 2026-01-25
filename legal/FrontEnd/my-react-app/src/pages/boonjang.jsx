import React, { useState } from "react";
import axios from "axios";
import { Link } from "react-router-dom";

export default function Boonjang() {
  // Input Status
  const [inputText, setInputText] = useState("");

  // Output Status (For DB testing)
  const [outputText, setOutputText] = useState("");
  const [isFavorite, setIsFavorite] = useState(false);

  // Status Message
  const [saveStatus, setSaveStatus] = useState(null); // { success: boolean, message: string }

  // Sample Text
  const handleSampleText = () => {
    setInputText(`안녕하세요, 저는 온라인 쇼핑몰에서 전자제품을 구매했습니다.
제품 수령 후 3일 만에 청약철회를 요청했으나, 판매자가 개봉제품이라는 이유로 환불을 거부하고 있습니다.
전자상거래법에 따르면 7일 이내 청약철회가 가능한 것으로 알고 있는데, 판매자는 자체 규정을 근거로 반품 불가를 주장합니다.
이로 인해 50만원의 손해가 발생했으며, 부당한 청구라고 생각합니다.
소비자보호원에 신고할 예정이며, 필요시 법적 조치도 고려하고 있습니다.`);
  };

  // Analyze & Save Function
  const handleAnalyzeAndSave = async () => {
    if (!inputText.trim()) {
      alert("분쟁 내용을 입력해주세요.");
      return;
    }

    setSaveStatus(null);

    // 1. Mock Analysis Logic (Simple rule-based or dummy)
    // In a real scenario, this might call an AI endpoint.
    // For now, we populate the Output field if it's empty, or use existing value.
    let targetOutput = outputText;
    if (!targetOutput.trim()) {
      targetOutput = "분석된 결과: 해당 분쟁은 '민사 - 소비자' 유형으로 분류됩니다.\n\n" +
        "주요 쟁점: 전자상거래법상 청약철회 가능 여부 및 판매자의 반품 거부 사유의 정당성.\n" +
        "관련 법령: 전자상거래 등에서의 소비자보호에 관한 법률, 소비자기본법.";
      setOutputText(targetOutput);
    }

    // 2. Prepare DB Save Request
    const saveRequest = {
      boonjang_input: inputText,
      boonjang_output: targetOutput,
      boonjang_mark: isFavorite ? 1 : 0
    };

    // 3. Send Request
    try {
      const response = await axios.post("/api/boonjang/save", saveRequest, { withCredentials: true });

      if (response.status === 200 || response.status === 201) {
        // Assuming the server returns the saved code or ID
        const code = response.data;
        setSaveStatus({
          success: true,
          message: `저장 완료! boonjang_code = ${code}`
        });
      }
    } catch (error) {
      console.error("Save Error:", error);
      if (error.response && error.response.status === 401) {
        setSaveStatus({
          success: false,
          message: "로그인이 필요합니다."
        });
        // Optional: Redirect to login
      } else {
        setSaveStatus({
          success: false,
          message: "저장 실패: 서버 오류가 발생했습니다."
        });
      }
    }
  };

  return (
    <div className="bg-gray-50 min-h-screen">
      {/* Page Header */}
      <div className="max-w-7xl mx-auto px-6 pt-10 pb-6">
        <div className="flex items-center gap-4">
          <div className="flex-shrink-0">
            <span className="text-4xl">📋</span>
          </div>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">
              분쟁 유형 분류 AI
            </h1>
            <p className="text-gray-500 mt-1">
              분쟁 텍스트를 분석하고 DB 저장 기능을 테스트합니다.
            </p>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <main className="px-6 pb-12 max-w-7xl mx-auto">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">

          {/* Left Panel: Input */}
          <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6 flex flex-col h-[600px]">
            <h2 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
              📝 분쟁 내용 입력
            </h2>

            <textarea
              className="w-full flex-1 p-4 border rounded-lg resize-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 bg-gray-50"
              placeholder="분쟁 상황을 상세히 입력해주세요..."
              value={inputText}
              onChange={(e) => setInputText(e.target.value)}
            />

            <div className="flex justify-between items-center mt-3 mb-4 text-sm text-gray-500">
              <span>{inputText.length}자</span>
              <button
                onClick={handleSampleText}
                className="text-blue-500 hover:underline font-medium"
                type="button"
              >
                샘플 텍스트 입력
              </button>
            </div>

            <button
              onClick={handleAnalyzeAndSave}
              className="w-full py-4 bg-blue-500 text-white rounded-lg font-bold hover:bg-blue-600 transition shadow-sm flex items-center justify-center gap-2 text-lg"
              type="button"
            >
              ⚡ 유형 분석 및 저장 실행
            </button>
          </div>

          {/* Right Panel: Output & Result */}
          <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6 flex flex-col h-[600px]">
            <h2 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
              📊 분석 결과
            </h2>

            <textarea
              className="w-full flex-1 p-4 border rounded-lg resize-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-700 leading-relaxed"
              placeholder="분석된 결과가 이곳에 표시됩니다..."
              value={outputText}
              onChange={(e) => setOutputText(e.target.value)}
            />

            {/* Favorites & Home Link */}
            <div className="flex justify-between items-center mt-4 pb-2">
              <div className="flex items-center gap-2">
                <input
                  type="checkbox"
                  id="favCheck"
                  className="w-5 h-5 rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                  checked={isFavorite}
                  onChange={(e) => setIsFavorite(e.target.checked)}
                />
                <label htmlFor="favCheck" className="text-gray-600 font-medium cursor-pointer">
                  즐겨찾기 추가
                </label>
              </div>
              <Link to="/" className="text-gray-400 hover:text-gray-600 text-sm">
                홈으로 이동
              </Link>
            </div>

            {/* Status Message Area */}
            {saveStatus && (
              <div className={`mt-3 p-4 rounded-lg text-center font-bold text-sm border ${saveStatus.success
                ? "bg-blue-50 text-blue-600 border-blue-100"
                : "bg-red-50 text-red-600 border-red-100"
                }`}>
                {saveStatus.success ? "✅ " : "❌ "}
                {saveStatus.message}
              </div>
            )}

            {/* Placeholder for spacing when no message */}
            {!saveStatus && (
              <div className="mt-3 p-4 rounded-lg bg-transparent border border-transparent">
                <span className="invisible">Placeholder</span>
              </div>
            )}

          </div>
        </div>
      </main>
    </div>
  );
}
