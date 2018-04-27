package com.innology.moonmasons.config;

import com.innology.moonmasons.security.HeaderAuthenticationFilter;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.repository.query.spi.EvaluationContextExtension;
import org.springframework.data.repository.query.spi.EvaluationContextExtensionSupport;
import org.springframework.http.HttpMethod;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.access.expression.SecurityExpressionRoot;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.config.annotation.web.servlet.configuration.EnableWebMvcSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationSuccessHandler;
import org.springframework.security.web.authentication.logout.LogoutFilter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;

@Configuration
@EnableWebMvcSecurity
public class SecurityConfig extends WebSecurityConfigurerAdapter {

	private static final Logger logger = LoggerFactory.getLogger(SecurityConfig.class);
	private static final String ACCESS_DENIED_JSON = "{\"message\":\"You are not privileged to request this resource.\", \"access-denied\":true,\"cause\":\"AUTHORIZATION_FAILURE\"}";
	private static final String UNAUTHORIZED_JSON = "{\"message\":\"Full authentication is required to access this resource.\", \"access-denied\":true,\"cause\":\"NOT AUTHENTICATED\"}";

	@Autowired
	@Qualifier("userDetailsService")
	UserDetailsService userDetailsService;
	
	@Bean
	EvaluationContextExtension securityExtension() {
		return new EvaluationContextExtensionSupport () {
			@Override
			public String getExtensionId() {
				return "security";
			}

			@Override
			public SecurityExpressionRoot getRootObject() {
				Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
				return new SecurityExpressionRoot(authentication) {};
			}
		};
	}

	@Autowired
	public void configureGlobal(AuthenticationManagerBuilder auth) throws Exception {
		auth.userDetailsService(userDetailsService);
	}

	@Override
	protected void configure(HttpSecurity http) throws Exception {

		logger.info("configure");
		
		HeaderAuthenticationFilter headerAuthenticationFilter = new HeaderAuthenticationFilter();
		headerAuthenticationFilter.userDetailsService(userDetailsService());

		http.
		addFilterBefore(headerAuthenticationFilter, LogoutFilter.class).

		csrf().disable().

		formLogin().successHandler(new CustomAuthenticationSuccessHandler()).
		loginProcessingUrl("/login").

		and().

		logout().
		logoutSuccessUrl("/logout").

		and().

		sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS).

		and().

		exceptionHandling().
		accessDeniedHandler(new CustomAccessDeniedHandler()).
		authenticationEntryPoint(new CustomAuthenticationEntryPoint()).

		and().

		authorizeRequests().
//		antMatchers(HttpMethod.POST, "/login").permitAll().
		antMatchers(HttpMethod.GET, "/").permitAll().
		antMatchers(HttpMethod.GET, "/resources/**").permitAll().
		antMatchers(HttpMethod.POST, "/logout").authenticated().
		antMatchers(HttpMethod.GET, "/**").hasRole("USER").
		antMatchers(HttpMethod.POST, "/**").hasRole("USER").
		antMatchers(HttpMethod.PUT, "/**").hasRole("USER").
		antMatchers(HttpMethod.DELETE, "/**").hasRole("USER").
		anyRequest().authenticated();

	}

	private static class CustomAccessDeniedHandler implements AccessDeniedHandler {
		@Override
		public void handle(HttpServletRequest request, HttpServletResponse response, AccessDeniedException accessDeniedException) throws IOException, ServletException {

			logger.info("Access denied");
			//            response.setContentType(Versions.V1_0);
			response.setStatus(HttpServletResponse.SC_FORBIDDEN);
			PrintWriter out = response.getWriter();
			out.print(ACCESS_DENIED_JSON);
			out.flush();
			out.close();

		}
	}

	private static class CustomAuthenticationEntryPoint implements AuthenticationEntryPoint {
		@Override
		public void commence(HttpServletRequest request, HttpServletResponse response, AuthenticationException authException) throws IOException, ServletException {

			//            response.setContentType(Versions.V1_0);
			response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
			PrintWriter out = response.getWriter();
			out.print(UNAUTHORIZED_JSON);
			out.flush();
			out.close();
		}
	}

	private static class CustomAuthenticationSuccessHandler extends SimpleUrlAuthenticationSuccessHandler {
	}
}
