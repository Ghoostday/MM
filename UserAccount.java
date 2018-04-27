package com.innology.moonmasons.model;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.Index;
import javax.persistence.ManyToMany;
import javax.persistence.OneToMany;
import javax.persistence.Table;
import javax.persistence.Transient;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;


@Entity
@Table(indexes = {@Index(name = "idxUserAccountProviderIdentifier", columnList = "provider, identifier")})
public class UserAccount extends PersistenceEntity implements UserDetails {
			
	private static final long serialVersionUID = 1L;

	@Column(unique=true)
	String username;
	
	@ManyToMany(mappedBy = "boostedBy", fetch = FetchType.LAZY)
	List<Photo> boostedPhotos = new ArrayList<Photo>();
	
	@OneToMany(mappedBy = "owner", cascade = CascadeType.ALL)
	List<Search> searches = new ArrayList<Search>();

	int provider;
	long identifier;

	@Transient 
	Set<GrantedAuthority> authorities = new HashSet<GrantedAuthority>();

	
	public UserAccount() {
	}

	public UserAccount(String username) {
		this.username = username;
	}
	
	@Override
	public String toString() {
		return this.username;
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

	
	
	public List<Photo> getBoostedPhotos() {
		return new ArrayList<Photo>(this.boostedPhotos);
	}
	
	public void boostPhoto(Photo photo) {
		if(this.boostedPhotos.contains(photo)) {
			return;
		}
		this.boostedPhotos.add(photo);
		photo.addBoost(this);
	}

	public void unBoostPhoto(Photo photo) {
		if(!this.boostedPhotos.contains(photo)) {
			return;
		}
		this.boostedPhotos.remove(photo);
		photo.removeBoost(this);		
	}
	
	public boolean isBoostingPhoto(Photo photo) {
		return this.boostedPhotos.contains(photo);
	}

	
	
	public List<Search> getSearches() {
		return new ArrayList<Search>(this.searches);
	}

	public void addSearch(Search search) {
		if(this.searches.contains(search)) {
			return;
		}
		this.searches.add(search);
		search.setOwner(this);
	}

	public void removeSearch(Search search) {
		if(!this.searches.contains(search)) {
			return;
		}
		this.searches.remove(search);
		search.setOwner(null);		
	}

	
	
	@Override
	public Collection<? extends GrantedAuthority> getAuthorities() {
		return authorities;
	}

	public void setAuthorities(Set<GrantedAuthority> authorities) {
		this.authorities = authorities;
	}

	@Override
	public String getPassword() {
		return "";
	}

	@Override
	public String getUsername() {
		return this.username;
	}

	@Override
	public boolean isAccountNonExpired() {
		return true;
	}

	@Override
	public boolean isAccountNonLocked() {
		return true;
	}

	@Override
	public boolean isCredentialsNonExpired() {
		return true;
	}

	@Override
	public boolean isEnabled() {
		return true;
	}
}
