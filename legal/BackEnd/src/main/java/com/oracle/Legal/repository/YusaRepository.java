package com.oracle.Legal.repository;

import com.oracle.Legal.domain.Yusa;

public interface YusaRepository {

	//유사판례 분석 저장
	Yusa yusaSave(Yusa yusa);
	//유사판례 찾기
	Yusa findOne(int clientCode, int intValue);

}
