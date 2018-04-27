package com.innology.moonmasons.security;

import java.util.HashSet;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.innology.moonmasons.model.UserAccount;
import com.innology.moonmasons.repo.UserAccountRepo;


@Service("userDetailsService")
public class UserAccountService implements UserDetailsService {

	@Autowired
	private UserAccountRepo userAccountRepo;

	@Override
	public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
		
		String[] components = username.split("@");
		int provider = Integer.parseInt(components[1]);
		long identifier = Long.parseLong(components[0]);
		UserAccount user = userAccountRepo.findByProviderAndIdentifier(provider, identifier);		
		if(user == null) {
			user = new UserAccount(username);
			user.setIdentifier(identifier);
			user.setProvider(provider);
			user = userAccountRepo.save(user);
		}
		
		Set<GrantedAuthority> setAuths = new HashSet<GrantedAuthority>();
		setAuths.add(new SimpleGrantedAuthority("ROLE_USER"));
		user.setAuthorities(setAuths);
		
		return user;
	}
}
