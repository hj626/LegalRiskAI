package com.oracle.Legal.repository;

import java.util.List;
import com.oracle.Legal.domain.Yusa;

public interface YusaRepository {

	//유사판례 분석 저장
	Yusa yusaSave(Yusa yusa);
	//유사판례 찾기
	Yusa findOne(int clientCode, int intValue);
	//유사판례 리스트
	List<Yusa> findHistory(int clientCode);

}
