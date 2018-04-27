package com.innology.moonmasons.security.authentication;

import java.io.IOException;
import java.util.HashSet;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;

import org.springframework.security.core.userdetails.UsernameNotFoundException;


public class InstagramAuthentication extends AuthenticationProvider {
	
	private static Set<Long> users = new HashSet<Long>();
	
	public long getIdentifier(HttpServletRequest request) throws UsernameNotFoundException {
		long identifier = Long.parseLong(request.getHeader("user_id"));
		if(users.contains(identifier)) {
			return identifier;
		} else {
			logger.info("Instagram: Looking up identifier: " + identifier);
			String accessToken = request.getHeader("access_token");
			String url = "https://api.instagram.com/v1/users/" + identifier + "/?access_token=" + accessToken;
			try {
				String result = callGet(url);
				logger.info("Instagram: Lookup ok, result: " + result);
				users.add(identifier);
			} catch (IOException e) {
				logger.info("Instagram: Identifier not recognized by provider: " + identifier);
				throw new UsernameNotFoundException(identifier + "@" + this.INSTAGRAM);
			}
			return identifier;
		}
	}

	@Override
	public int getProviderIdentifier() {
		return this.INSTAGRAM;
	}
}
