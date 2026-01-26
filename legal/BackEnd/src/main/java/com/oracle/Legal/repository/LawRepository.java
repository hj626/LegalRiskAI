package com.oracle.Legal.repository;

import java.util.List;

import com.oracle.Legal.domain.Law;

public interface LawRepository {

	//법적위험 분석 저장
	Law lawSave(Law law);
	//법적위험 찾기
	Law findOne(int clientCode, int intValue);
	//법적위험 리스트
	List<Law> findHistory(int clientCode);

}
