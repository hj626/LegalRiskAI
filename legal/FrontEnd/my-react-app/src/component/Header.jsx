import { NavLink } from "react-router-dom";
import { useState, useEffect } from "react";
import axios from "axios";

const navItems = [
  { to: "/boonjang", label: "분쟁유형", icon: "⚖️" },
  { to: "/law", label: "법적위험", icon: "⚠️" },
  { to: "/yusa", label: "유사판례", icon: "🔍" },
  { to: "/jogi", label: "조기위험", icon: "💡" },
];

export default function Header() {
  const [user, setUser] = useState(null);

  useEffect(() => {
    /**
     * [Session Check] - 컴포넌트 마운트 시 사용자 인증 정보 조회
     * GET /api/user/me
     * - Success: 로그인된 사용자 정보(AccountDto)를 받아 상태 업데이트
     * - Failure: 401 Unauthorized 등 에러 발생 시 비로그인 상태(null) 유지
     */
    axios
      .get("/api/user/me")
      .then((res) => {
        setUser(res.data);
      })
      .catch((err) => {
        // 세션이 없거나 만료된 경우 (로그인 필요)
        setUser(null);
      });
  }, []);
  return (
    <header className="bg-white border-b border-gray-200">
      <div className="max-w-7xl mx-auto px-6">
        <div className="flex h-16 items-center gap-8">
          {/* 
            [Logo Link] - Server-side Routing
            Spring Boot(JSP)의 메인 페이지("/")로 이동하기 위해 React Router의 Link 대신 
            <a> 태그를 사용하여 브라우저 전체 새로고침(Full Reload)을 트리거함.
          */}
          <a
            href="/"
            className="flex items-center gap-2 hover:opacity-90 transition"
          >
            <div className="w-9 h-9 rounded-2xl bg-blue-600 flex items-center justify-center shadow-sm">
              <span className="text-xl text-white">⚖️</span>
            </div>
            <span className="text-xl font-semibold text-gray-900 tracking-tight">
              LegalRisk <span className="text-blue-600">AI</span>
            </span>
          </a>

          {/* 네비게이션 영역 */}
          <nav className="flex-1 flex items-center gap-2 ml-6">
            {navItems.map((item) => (
              <NavLink
                key={item.to}
                to={item.to}
                className={({ isActive }) =>
                  [
                    "flex items-center gap-2 px-3 py-2 rounded-xl text-sm md:text-base",
                    "transition-colors",
                    isActive
                      ? "bg-blue-50 text-blue-700 font-semibold"
                      : "text-gray-600 hover:bg-gray-50 hover:text-gray-900",
                  ].join(" ")
                }
              >
                <span className="text-lg">{item.icon}</span>
                <span>{item.label}</span>
              </NavLink>
            ))}
          </nav>

          {/* 로그인/회원가입 영역 */}
          <div className="flex items-center gap-2">
            {user ? (
              <>
                <span className="text-gray-700 font-medium px-2">👋 {user.username}님</span>
                <a
                  href="/logout"
                  className="px-3 py-2 text-xs md:text-sm text-gray-500 rounded-md
                             hover:bg-red-50 hover:text-red-600 transition-colors"
                >
                  로그아웃
                </a>
              </>
            ) : (
              <>
                <a
                  href="/login"
                  className="px-3 py-2 text-xs md:text-sm text-gray-600 rounded-md
                             hover:bg-gray-50 hover:text-blue-600 transition-colors"
                >
                  로그인
                </a>
                <a
                  href="/client/join"
                  className="px-4 py-2 text-xs md:text-sm font-medium text-white
                             bg-blue-600 rounded-xl shadow-sm
                             hover:bg-blue-700 hover:shadow-md
                             active:scale-[0.98]
                             transition-transform transition-shadow transition-colors"
                >
                  회원가입
                </a>
              </>
            )}
          </div>
        </div>
      </div>
    </header>
  );
}
