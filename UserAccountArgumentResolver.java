package com.innology.moonmasons.controller;

import org.springframework.core.MethodParameter;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.support.WebDataBinderFactory;
import org.springframework.web.context.request.NativeWebRequest;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.method.support.ModelAndViewContainer;

import com.innology.moonmasons.model.UserAccount;

public class UserAccountArgumentResolver implements HandlerMethodArgumentResolver {

//	private static final Logger logger = LoggerFactory.getLogger(UserAccountArgumentResolver.class);
			
	@Override
	public boolean supportsParameter(MethodParameter parameter) {
		//logger.info("supportsParameter(" + parameter + ")");
		return parameter.getParameterType().equals(UserAccount.class);
	}

	@Override
	public Object resolveArgument(MethodParameter parameter, ModelAndViewContainer mavContainer, NativeWebRequest webRequest, WebDataBinderFactory binderFactory) throws Exception {
		UserAccount userAccount = (UserAccount) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
		//logger.info("Sucessfully retrieved user object: " + userAccount);
		return userAccount;
	}
}
