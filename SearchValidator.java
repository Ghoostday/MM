package com.innology.moonmasons.repo;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.validation.Errors;
import org.springframework.validation.Validator;

import com.innology.moonmasons.model.Search;
import com.innology.moonmasons.model.UserAccount;


public class SearchValidator implements Validator {

	private static final Logger logger = LoggerFactory.getLogger(SearchValidator.class);

	@Override
	public boolean supports(Class<?> clazz) {
		return clazz.equals(Search.class);
	}

	@Override
	public void validate(Object target, Errors errors) {
		Search search = (Search) target;
		UserAccount userAccount = (UserAccount) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
		
		logger.info("principal: " + userAccount.getUsername() + " search.owner: " + search.getOwner());
		
		if (search.getOwner() != null && !search.getOwner().equals(userAccount)) {
			errors.reject("Ownership mismatch");			
		}
	}
}
