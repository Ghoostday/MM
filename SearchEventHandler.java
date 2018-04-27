package com.innology.moonmasons.repo;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.rest.core.event.AbstractRepositoryEventListener;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import com.innology.moonmasons.model.Search;
import com.innology.moonmasons.model.UserAccount;

@Component
public class SearchEventHandler extends AbstractRepositoryEventListener<Search> {
	
	private static final Logger logger = LoggerFactory.getLogger(SearchEventHandler.class);
	
	@Autowired
	private UserAccountRepo userAccountRepo;

	@Override
	protected void onBeforeCreate(Search search) {
		logger.info("onBeforeCreate: " + search);
		UserAccount userAccount = (UserAccount) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
		userAccount = userAccountRepo.findByUsername(userAccount.getUsername());
		search.setOwner(userAccount);
	}
	
	@Override
	protected void onBeforeSave(Search search) {
		logger.info("onBeforeSave: " + search);
	}
}
