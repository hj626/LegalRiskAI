package com.oracle.Legal.ai;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.reactive.function.client.WebClient;

@Configuration
public class AiConfig {

    @Bean
    public WebClient aiWebClient() {
        return WebClient.builder()
                .baseUrl("http://127.0.0.1:8002") // FastAPI 주소 (8000 -> 8002 수정)
                .build();
    }
}
