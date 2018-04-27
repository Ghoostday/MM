package com.innology.moonmasons.config;

import java.util.Date;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.env.Environment;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.transaction.annotation.Transactional;

import com.innology.moonmasons.model.Photo;
import com.innology.moonmasons.model.Search;
import com.innology.moonmasons.repo.PhotoRepo;
import com.innology.moonmasons.repo.SearchRepo;


public class DatabaseMaintenance {
	
	private static final Logger logger = LoggerFactory.getLogger(DatabaseMaintenance.class);
	
	@Value("${db.deleteOldRecords.maxAge}")
	long maxAge = 21600000;

	@Autowired
    public Environment env;

	@Autowired
	PhotoRepo photoRepo;
	
	@Autowired
	SearchRepo searchRepo;
	
	
	@Transactional
	@Scheduled(fixedDelayString = "${db.deleteOldRecords.period}")
	public void deleteOldRecords() {
		logger.debug("Deleting records older than " + maxAge + " ms");
		
		Date threshold = new Date();
		threshold.setTime(threshold.getTime() - maxAge);
		
		
		List<Photo> photos = photoRepo.findByDateLessThan(threshold);
		for(Photo photo : photos) {
			photoRepo.delete(photo);
		}

		List<Search> searches = searchRepo.findByDateLessThan(threshold);
		for(Search search : searches) {
			searchRepo.delete(search);
		}
	}
}
