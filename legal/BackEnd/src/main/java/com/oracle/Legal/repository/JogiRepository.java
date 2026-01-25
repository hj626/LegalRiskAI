package com.oracle.Legal.repository;

import com.oracle.Legal.domain.Jogi;

public interface JogiRepository {

	//조기위험 분석 저장
	Jogi jogiSave(Jogi jogi);
	//조기위험 찾기 
	Jogi findOne(int clientCode, int intValue);

}
