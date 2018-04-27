package com.innology.moonmasons.model;

import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.MappedSuperclass;

@MappedSuperclass
public class PersistenceEntity {

	@Id
	@GeneratedValue(strategy = GenerationType.AUTO)
	protected Long id;
	
	public Long getId() {
		return id;
	}
	
	public void setId(Long id) {
		this.id = id;
	}
	
	public boolean equals(Object e) {
		if(super.equals(e)) {
			return true;
		} 
		try {
			PersistenceEntity entity = (PersistenceEntity) e;
			
			if(this.getId() == null ^ entity.getId() == null) {
				return false;
			} else if(this.getId() == null && entity.getId() == null) {
				return true;
			}

			return this.getId().equals(entity.getId());
		} catch(Exception exception) {
			return false;
		}
	}
}
