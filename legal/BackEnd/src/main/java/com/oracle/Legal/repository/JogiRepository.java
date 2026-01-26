package com.oracle.Legal.repository;

import java.util.List;

import com.oracle.Legal.domain.Jogi;

public interface JogiRepository {

	//조기위험 분석 저장
	Jogi jogiSave(Jogi jogi);
	//조기위험 찾기 
	Jogi findOne(int clientCode, int intValue);
	//조기위험 리스트
	List<Jogi> findHistory(int clientCode);
}
