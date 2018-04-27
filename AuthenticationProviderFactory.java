package com.innology.moonmasons.security.authentication;

import javax.servlet.http.HttpServletRequest;

public class AuthenticationProviderFactory {
	
	public static AuthenticationProvider getAuthenticationProvider(HttpServletRequest request) throws ClassNotFoundException, InstantiationException, IllegalAccessException {
		String authProvider = request.getHeader("AuthProvider");
		if(authProvider == null) {
			return null;
		}
		
		return (AuthenticationProvider) Class.forName(authProvider).newInstance();
	}
}
