package com.innology.moonmasons.security.authentication;

import java.io.IOException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;

import org.springframework.security.core.userdetails.UsernameNotFoundException;


public class TwitterAuthentication extends AuthenticationProvider {
	
	private static Set<Long> users = new HashSet<Long>();
	
	public long getIdentifier(HttpServletRequest request) throws UsernameNotFoundException {
		long identifier = Long.parseLong(request.getHeader("user_id"));
		if(users.contains(identifier)) {
			return identifier;
		} else {
			logger.info("Twitter: Looking up identifier: " + identifier);
			String url = request.getHeader("url");
			try {
				Map<String, String> headers = new HashMap<String, String>();
				headers.put("Authorization", request.getHeader("Authorization"));
				String result = callGet(url, headers);
				logger.info("Twitter: Lookup ok, result: " + result);
				users.add(identifier);
			} catch (IOException e) {
				logger.info(e.getMessage());
				e.printStackTrace();
				logger.info("Twitter: Identifier not recognized by provider: " + identifier);
				throw new UsernameNotFoundException(identifier + "@" + this.TWITTER);
			}
			return identifier;
		}
	}

	@Override
	public int getProviderIdentifier() {
		return this.TWITTER;
	}
}
