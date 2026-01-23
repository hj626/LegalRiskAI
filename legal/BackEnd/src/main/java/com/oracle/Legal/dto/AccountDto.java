package com.oracle.Legal.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AccountDto {
    private Long id;
    private int client_code;
    private String username;
    private String password;
    private String roles;
    private String displayName;

    public String getClient_name() {
        return displayName;
    }
    public void resolveDisplayName(String clientName) {
        if (clientName != null && !clientName.isBlank()) {
            this.displayName = clientName;
        } else {
            this.displayName = this.username;
        }
    }
}
