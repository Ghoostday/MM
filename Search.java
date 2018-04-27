package com.innology.moonmasons.model;

import java.util.Date;

import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.ManyToOne;
import javax.persistence.Table;
import javax.persistence.Transient;
import javax.persistence.Index;



@Entity
@Table(indexes = {
		@Index(name = "idxSearchLatitude", columnList = "latitude"),
		@Index(name = "idxSearchLongitude", columnList = "longitude"),
		@Index(name = "idxSearchDate", columnList = "date")
})
public class Search extends PersistenceEntity {

	@ManyToOne(fetch=FetchType.LAZY)
	UserAccount owner;

	double latitude;
	double longitude;
	double radius;
	boolean active;
	boolean boosted;
	boolean negative;
	boolean alert;
	Date date;
	
	@Transient
	double rank;

	public UserAccount getOwner() {
		return owner;
	}

	public void setOwner(UserAccount owner) {
		if(this.owner == null ? owner == null : this.owner.equals(owner)) {
			return;
		}
		if(this.owner != null) {
			this.owner.removeSearch(this);
		}
		this.owner = owner;
		if(this.owner != null) {
			this.owner.addSearch(this);
		}
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


	
	public double getRadius() {
		return radius;
	}

	public void setRadius(double radius) {
		this.radius = radius;
	}
	
	

	public boolean isActive() {
		return active;
	}

	public void setActive(boolean active) {
		this.active = active;
	}
	
	

	public boolean isBoosted() {
		return boosted;
	}

	public void setBoosted(boolean boosted) {
		this.boosted = boosted;
	}

	
	
	public boolean isNegative() {
		return negative;
	}

	public void setNegative(boolean negative) {
		this.negative = negative;
	}

	
	
	public boolean isAlert() {
		return alert;
	}

	public void setAlert(boolean alert) {
		this.alert = alert;
	}

	
	
	public Date getDate() {
		return date;
	}

	public void setDate(Date date) {
		this.date = date;
	}

	
	
	public double getRank() {
		return rank;
	}

	public void setRank(double rank) {
		this.rank = rank;
	}
}
