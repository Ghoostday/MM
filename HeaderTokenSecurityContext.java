package com.innology.moonmasons.security;

import java.util.Collection;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.userdetails.UserDetails;

public class HeaderTokenSecurityContext implements SecurityContext {
    private static final long serialVersionUID = 1L;

    private Authentication authentication;

    public HeaderTokenSecurityContext(UserDetails userDetails) {
    	this.authentication = new HeaderTokenAuthentication(userDetails);
    }

    @Override
    public Authentication getAuthentication() {
        return authentication;
    }

    @Override
    public void setAuthentication(Authentication authentication) {
        throw new UnsupportedOperationException("Should not be called by the code path");
    }
    
    public class HeaderTokenAuthentication implements Authentication {
		private static final long serialVersionUID = 1L;
		
		UserDetails userDetails;
		
		public HeaderTokenAuthentication(UserDetails userAccount) {
			this.userDetails = userAccount;
		}

		@Override
		public String getName() {
			return this.userDetails.getUsername();
		}

		@Override
		public Collection<? extends GrantedAuthority> getAuthorities() {
			return this.userDetails.getAuthorities();
		}

		@Override
		public Object getCredentials() {
			return this.userDetails.getPassword();
		}

		@Override
		public Object getDetails() {
			return this.userDetails;
		}

		@Override
		public Object getPrincipal() {
			return this.userDetails;
		}

		@Override
		public boolean isAuthenticated() {
			return this.userDetails != null;
		}

		@Override
		public void setAuthenticated(boolean isAuthenticated) throws IllegalArgumentException {
			if (!isAuthenticated) {
				this.userDetails = null;
			} else {
				throw new IllegalArgumentException("An un-authenticated Authentication cannot be changed. Create a new object with a valid user.");
			}
		}
    }
}
