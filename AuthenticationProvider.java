Copyright jdc

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.userdetails.UsernameNotFoundException;

public abstract class AuthenticationProvider {

	protected static final Logger logger = LoggerFactory.getLogger(AuthenticationProvider.class);
	
	public final int INSTAGRAM = 1;
	public final int TWITTER = 2;
	
	public abstract long getIdentifier(HttpServletRequest request) throws UsernameNotFoundException;
	public abstract int getProviderIdentifier();

	protected String callGet(String urlToRead) throws IOException {
		return callGet(urlToRead, null);
	}
	
	protected String callGet(String urlToRead, Map<String, String> headers) throws IOException {
		URL url;
		HttpURLConnection conn;
		BufferedReader rd;
		String line;
		String result = "";
		url = new URL(urlToRead);
		conn = (HttpURLConnection) url.openConnection();
		conn.setRequestMethod("GET");
		
		if(headers != null) {
			for(String key : headers.keySet()) {
				conn.setRequestProperty(key, headers.get(key));
			}
		}
		
		rd = new BufferedReader(new InputStreamReader(conn.getInputStream()));
		while ((line = rd.readLine()) != null) {
			result += line;
		}
		rd.close();
		return result;					
	}
}