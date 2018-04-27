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
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import com.innology.moonmasons.model.Coordinate;
import com.innology.moonmasons.model.GeoTranslate;
import com.innology.moonmasons.model.Photo;
import com.innology.moonmasons.model.Search;
import com.innology.moonmasons.model.UserAccount;
import com.innology.moonmasons.repo.PhotoRepo;
import com.innology.moonmasons.repo.UserAccountRepo;


@Controller
public class PhotoController {
	
	private static final Logger logger = LoggerFactory.getLogger(PhotoController.class);

	@Autowired
	private PhotoRepo photoRepo;
	
	@Autowired
	private UserAccountRepo userAccountRepo;
	
	@Value("${cache.promoted.expiration}") 
	long cacheExpires;
	
	@Transactional
	@ResponseBody
	@RequestMapping(value = "/boostPhoto", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_VALUE, consumes = MediaType.APPLICATION_JSON_VALUE)
	public void boostPhoto(@RequestBody Photo photo, UserAccount userAccount) {
		logger.debug("boostPhoto(" + userAccount + ")");
		Photo currentPhoto = photoRepo.findByProviderAndIdentifier(photo.getProvider(), photo.getIdentifier());
		if (currentPhoto == null) {
			currentPhoto = photo;
			photoRepo.save(currentPhoto);
		}

		userAccount = userAccountRepo.findByUsername(userAccount.getUsername());
		currentPhoto.addBoost(userAccount);
		photoRepo.save(currentPhoto);
	}
	
	@Transactional
	@ResponseBody
	@RequestMapping(value = "/unBoostPhoto", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_VALUE, consumes = MediaType.APPLICATION_JSON_VALUE)
	public void unBoostPhoto(@RequestBody Photo photo, UserAccount userAccount) {
		logger.info("unBoostPhoto(" + photo.getUrl() + ")");
		photo = photoRepo.findByProviderAndIdentifier(photo.getProvider(), photo.getIdentifier());
		
		if (photo == null) {
			logger.info("Photo does not exist");
			return;
		}
		
		userAccount = userAccountRepo.findByUsername(userAccount.getUsername());
		photo.removeBoost(userAccount);
		photoRepo.save(photo);
		
		if(photo.getNumberOfBoosts() == 0) {
			photoRepo.delete(photo);
			logger.info("Deleted photo: " + photo.getUrl() + " the photo exist: " + photoRepo.exists(photo.getId()));
		} else {
			photoRepo.save(photo);			
			logger.info("Updated photo: " + photo.getUrl());
		}
	}
	
	@Transactional
	@ResponseBody
	@RequestMapping(value = "/isPhotoBoosted", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_VALUE, consumes = MediaType.APPLICATION_JSON_VALUE)
	public boolean isPhotoBoosted(@RequestBody Photo photo, UserAccount userAccount) {
		photo = photoRepo.findByProviderAndIdentifier(photo.getProvider(), photo.getIdentifier());
		
		if (photo == null) {
			logger.info("isPhotoBoosted: Photo does not exist");
			return false;
		}

		logger.info("photo.isBoosted(userAccount): " + photo.isBoosted(userAccount));
		return photo.isBoosted(userAccount);
	}

	@Transactional
	@ResponseBody
	@RequestMapping(value = "/promotedPhotos", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_VALUE, consumes = MediaType.APPLICATION_JSON_VALUE)
	public List<Photo> promotedPhotos(@RequestBody Search[] searches, HttpServletResponse response) {
		logger.info("Search: " + searches.length);
		Map<Long, Photo> promoted = new HashMap<Long, Photo>();
		for(Search search : searches) {
			if(search.isActive() && !search.isNegative()) {
				Coordinate sw = GeoTranslate.move(search.getLatitude(), search.getLongitude(), -search.getRadius(), -search.getRadius());
				Coordinate ne = GeoTranslate.move(search.getLatitude(), search.getLongitude(), search.getRadius(), search.getRadius());
				List<Photo> photos = photoRepo.findByGrid(sw.latitude, sw.longitude, ne.latitude, ne.longitude);
				logger.info("photo.size() = " + photos.size());
				for(Photo photo : photos) {
					if(GeoTranslate.distance(search.getLatitude(), search.getLongitude(), photo.getLatitude(), photo.getLongitude()) <= search.getRadius()) {
						if(photo.getDate() != null) {
							double distanceScore = GeoTranslate.bestDistanceScore(Arrays.asList(searches),  photo.getLatitude(),  photo.getLongitude());
							double timeScore = GeoTranslate.timeScore(photo.getDate());
							photo.setRank(distanceScore * timeScore * photo.getNumberOfBoosts() * 0.1);
							if(photo.getRank() > 0) {
								promoted.put(photo.getId(), photo);
							}
						}
					}
				}
			}
		}
				
		List<Photo> promotedList = new ArrayList<Photo>(promoted.values());
		Collections.sort(promotedList, new Comparator<Photo>() {
			@Override
			public int compare(Photo arg0, Photo arg1) {
				if(arg0.getRank() > arg1.getRank()) {
					return -1;
				} else if(arg0.getRank() < arg1.getRank()) {
					return 1;
				}
				return 0;
			}
		});
		
		response.setDateHeader("Expires", (new Date()).getTime() + cacheExpires);
		
		return promotedList.subList(0, Math.min(3, promoted.size()));
	}
}
