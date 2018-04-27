package com.innology.moonmasons.controller;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import com.innology.moonmasons.model.Coordinate;
import com.innology.moonmasons.model.GeoTranslate;
import com.innology.moonmasons.model.Search;
import com.innology.moonmasons.model.UserAccount;
import com.innology.moonmasons.repo.SearchRepo;
import com.innology.moonmasons.repo.UserAccountRepo;


/**
 * Handles requests for the application home page.
 */
@Controller
public class SearchController {
	
	private static final Logger logger = LoggerFactory.getLogger(SearchController.class);

	@Autowired
	private SearchRepo searchRepo;
	
	@Autowired
	private UserAccountRepo userAccountRepo;
	
	@Value("${cache.promoted.expiration}") 
	long cacheExpires;

	@Transactional
	@ResponseBody
	@RequestMapping(value = "/test", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_VALUE, consumes = MediaType.APPLICATION_JSON_VALUE)
	public void test(UserAccount userAccount) {
		logger.info("test(" + userAccount + ")");
	}
	
	@Transactional
	@ResponseBody
	@RequestMapping(value = "/boostSearch", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_VALUE, consumes = MediaType.APPLICATION_JSON_VALUE)
	public void boostSearch(@RequestBody Search search, UserAccount userAccount) {
		logger.info("boostSearch(" + userAccount + ")");
		List<Search> currentSearch = searchRepo.findByLatitudeLongitude(search.getLatitude(), search.getLongitude());
		
		if (currentSearch.size() == 0) {
			search.setDate(new Date());
			searchRepo.save(search);
		}
	}
	
	@Transactional
	@ResponseBody
	@RequestMapping(value = "/unBoostSearch", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_VALUE, consumes = MediaType.APPLICATION_JSON_VALUE)
	public void unBoostSearch(@RequestBody Search search, UserAccount userAccount) {
		List<Search> currentSearch = searchRepo.findByLatitudeLongitude(search.getLatitude(), search.getLongitude());
		if(currentSearch.size() > 0) {
			searchRepo.delete(currentSearch.get(0));
		}
	}
	
	@ResponseBody
	@RequestMapping(value = "/isSearchBoosted", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_VALUE, consumes = MediaType.APPLICATION_JSON_VALUE)
	public boolean isSearchBoosted(@RequestBody Search search, UserAccount userAccount) {
		List<Search> currentSearch = searchRepo.findByLatitudeLongitude(search.getLatitude(), search.getLongitude());
		
		if (currentSearch.size() == 0) {
			return false;
		}
		return true;
	}
	
	@Transactional
	@ResponseBody
	@RequestMapping(value = "/promotedSearches", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_VALUE, consumes = MediaType.APPLICATION_JSON_VALUE)
	public List<Search> promotedSearches(@RequestBody Search[] searches, HttpServletResponse response) {
		Map<Long, Search> promoted = new HashMap<Long, Search>();
		for(Search search : searches) {
			if(search.isActive() && !search.isNegative()) {
				Coordinate sw = GeoTranslate.move(search.getLatitude(), search.getLongitude(), -search.getRadius(), -search.getRadius());
				Coordinate ne = GeoTranslate.move(search.getLatitude(), search.getLongitude(), search.getRadius(), search.getRadius());
				List<Search> matches = searchRepo.findByGrid(sw.latitude, sw.longitude, ne.latitude, ne.longitude, new PageRequest(0, 10));
				logger.info("search.size() = " + matches.size());
				for(Search match : matches) {
					if(GeoTranslate.distance(search.getLatitude(), search.getLongitude(), match.getLatitude(), match.getLongitude()) <= search.getRadius()) {
						if(match.getDate() != null) {
							double radiusScore = GeoTranslate.radiusScore(match.getRadius());
		                    double distanceScore = GeoTranslate.bestDistanceScore(Arrays.asList(searches),  match.getLatitude(),  match.getLongitude());
							double timeScore = GeoTranslate.timeScore(match.getDate());
							logger.info("adding search: radiusScore = " + radiusScore + ", distanceScore = " + distanceScore + ", timeScore = " + timeScore);
		                    match.setRank(distanceScore * radiusScore * timeScore);
		                    if(match.getRank() > 0) {
		                    	promoted.put(match.getId(), match);
		                    }
						}
					}
				}
			}
		}
		
		List<Search> promotedList = new ArrayList<Search>(promoted.values());
		Collections.sort(promotedList, new Comparator<Search>() {
			@Override
			public int compare(Search arg0, Search arg1) {
				if(arg0.getRank() > arg1.getRank()) {
					return -1;
				} else if(arg0.getRank() < arg1.getRank()) {
					return 1;
				}
				return 0;
			}
		});	
		
		response.setDateHeader("Expires", (new Date()).getTime() + cacheExpires);

		return promotedList;
	}
}
