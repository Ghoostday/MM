package com.innology.moonmasons.security;

import java.io.IOException;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.web.filter.GenericFilterBean;

import com.innology.moonmasons.security.authentication.AuthenticationProvider;
import com.innology.moonmasons.security.authentication.AuthenticationProviderFactory;

public class HeaderAuthenticationFilter extends GenericFilterBean {

	private static final Logger logger = LoggerFactory.getLogger(HeaderAuthenticationFilter.class);
	private UserDetailsService userDetailsService;

	@Override
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain filterChain) throws IOException, ServletException {
		
		try {
			HttpServletRequest httpRequest = (HttpServletRequest) request;
			AuthenticationProvider authenticationProvider = AuthenticationProviderFactory.getAuthenticationProvider(httpRequest);

//			Anonymous user
			if(authenticationProvider == null) {
				filterChain.doFilter(request, response);
				return;
			}
			
			long identifier = authenticationProvider.getIdentifier(httpRequest);
//			long identifier = 2809339458L;	//	DELETE 2809339459
			
			UserDetails userDetails = userDetailsService.loadUserByUsername(identifier + "@" + authenticationProvider.getProviderIdentifier());
			SecurityContext contextBeforeChainExecution = new HeaderTokenSecurityContext(userDetails);
			SecurityContextHolder.setContext(contextBeforeChainExecution);
			filterChain.doFilter(request, response);
			
		} catch (Exception e) {
			logger.error(e.getMessage());
			e.printStackTrace();
			throw new ServletException("Invalid authentication");
		}
		finally {
			SecurityContextHolder.clearContext();
		}
	}

	public void userDetailsService(UserDetailsService userDetailsService) {
		this.userDetailsService = userDetailsService;
	}
}
