package com.innology.moonmasons.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.data.rest.core.event.ValidatingRepositoryEventListener;
import org.springframework.data.rest.webmvc.config.RepositoryRestMvcConfiguration;

import com.innology.moonmasons.repo.SearchValidator;

@Configuration
public class RestConfig extends RepositoryRestMvcConfiguration {
	
	@Override
	protected void configureValidatingRepositoryEventListener(ValidatingRepositoryEventListener validatingListener) {
		validatingListener.addValidator("beforeCreate", new SearchValidator());
		validatingListener.addValidator("beforeSave", new SearchValidator());		
	}
}
