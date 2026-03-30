import React from 'react';
import { useNavigate } from 'react-router-dom';

const ErrorPage = ({ message = "알 수 없는 오류가 발생했습니다.", code = "error" }) => {
    const navigate = useNavigate();

    return (
        <div style={{
            display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
            height: '100vh', textAlign: 'center', fontFamily: 'sans-serif'
        }}>
            <h1 style={{ fontSize: '4rem', color: '#ff4d4f' }}>!</h1>
            <h2>오류가 발생했습니다</h2>
            <p style={{ color: '#666', marginBottom: '20px' }}>{message}</p>
            <button 
                onClick={() => navigate('/')} 
                style={{
                    padding: '10px 20px', backgroundColor: '#1890ff', color: '#fff',
                    border: 'none', borderRadius: '4px', cursor: 'pointer'
                }}
            >
                홈으로 돌아가기
            </button>
        </div>
    );
};

export default ErrorPage;
