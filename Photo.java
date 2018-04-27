package com.innology.moonmasons.model;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.ManyToMany;
import javax.persistence.MapKey;
import javax.persistence.Table;
import javax.persistence.Transient;
import javax.persistence.Index;

@Entity
@Table(indexes = {
		@Index(name = "idxPhotoDate", columnList = "date"),
		@Index(name = "idxPhotoProviderIdentifier", columnList = "provider, identifier")
})
public class Photo extends PersistenceEntity {

	String url;
	double latitude;
	double longitude;
	Date date;
	String username;
	
	int provider;
	long identifier;
	
	@MapKey(name="id")
	@ManyToMany(fetch=FetchType.LAZY)
	List<UserAccount> boostedBy = new ArrayList<UserAccount>();

	@Transient double rank;
	
	
	public String getUrl() {
		return url;
	}

	public void setUrl(String url) {
		this.url = url;
	}

	
	
	public void addBoost(UserAccount userAccount) {
		if(this.boostedBy.contains(userAccount)) {
			return;
		}
		this.boostedBy.add(userAccount);
		userAccount.boostPhoto(this);
	}
	
	public void removeBoost(UserAccount userAccount) {
		if(!this.boostedBy.contains(userAccount)) {
			return;
		}
		this.boostedBy.remove(userAccount);
		userAccount.unBoostPhoto(this);
	}
	
	public boolean isBoosted(UserAccount userAccount) {
		return this.boostedBy.contains(userAccount);
	}
	
	public int getNumberOfBoosts() {
		return this.boostedBy.size();
	}

	
	
	public double getLatitude() {
		return latitude;
	}

	public void setLatitude(double latitude) {
		this.latitude = latitude;
	}

	
	
	public double getLongitude() {
		return longitude;
	}

	public void setLongitude(double longitude) {
		this.longitude = longitude;
	}

	
	
	public String getUsername() {
		return username;
	}

	public void setUsername(String username) {
		this.username = username;
	}

	
	
	public Date getDate() {
		return date;
	}

	public void setDate(Date date) {
		this.date = date;
	}
	

	
	public double getRank() {
		return this.rank;
	}
	
	public void setRank(double rank) {
		this.rank = rank;
	}

	
	
	public int getProvider() {
		return provider;
	}

	public void setProvider(int provider) {
		this.provider = provider;
	}

	
	
	public long getIdentifier() {
		return identifier;
	}

	public void setIdentifier(long identifier) {
		this.identifier = identifier;
	}
}
