import { Link } from "react-router-dom";
import { useEffect, useState } from "react";

export default function Boonjang() {
  const [msg, setMsg] = useState("");

  useEffect(() => {
    fetch("/api/boonjang")
      .then((r) => r.text())
      .then(setMsg)
      .catch(() => setMsg("호출 실패"));
  }, []);

  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center">
      <div className="w-full max-w-md bg-white rounded-xl shadow-md p-6 space-y-4">
        {/* 제목 */}
        <h2 className="text-2xl font-bold text-gray-900 text-center">
          Boonjang
        </h2>

        {/* 설명 */}
        <p className="text-sm text-gray-500 text-center">
          분쟁 유형 분석 페이지
        </p>

        {/* API 메시지 영역 */}
        <div className="bg-gray-100 rounded-md p-3 text-center text-gray-700">
          {msg || "데이터를 불러오는 중..."}
        </div>

        {/* 구분선 */}
        <div className="border-t" />

        {/* 홈으로 이동 */}
        <Link
          to="/"
          className="block text-center rounded-md bg-black text-white py-2 hover:bg-gray-800 transition"
        >
          홈으로 돌아가기
        </Link>
      </div>
    </div>
  );
}
