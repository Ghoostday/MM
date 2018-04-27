package com.innology.moonmasons.config;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.ServletRegistration;

import org.springframework.context.annotation.PropertySource;
import org.springframework.web.WebApplicationInitializer;
import org.springframework.web.context.ContextLoaderListener;
import org.springframework.web.context.support.AnnotationConfigWebApplicationContext;
import org.springframework.web.servlet.DispatcherServlet;

@PropertySource("classpath:application.properties")
public class AppInitialIzer implements WebApplicationInitializer {
	
	@Override 
	public void onStartup(ServletContext servletContext) throws ServletException {
        
		Properties prop = new Properties();
        InputStream inputStream = getClass().getClassLoader().getResourceAsStream("application.properties");
        
        try {
			prop.load(inputStream);
		} catch (IOException e) {
			System.err.println("Can't load application.properties");
		}

		 
		AnnotationConfigWebApplicationContext rootCtx = new AnnotationConfigWebApplicationContext();
		rootCtx.register(ProdAppConfig.class);
		servletContext.addListener(new ContextLoaderListener(rootCtx));
		
		
		AnnotationConfigWebApplicationContext webCtx = new AnnotationConfigWebApplicationContext();
		webCtx.register(WebConfig.class);
		DispatcherServlet webServlet = new DispatcherServlet(webCtx);
		ServletRegistration.Dynamic webReg = servletContext.addServlet("web", webServlet);
		webReg.setLoadOnStartup(1);
		webReg.addMapping(prop.getProperty("web.urlMapping"));
		
			
		AnnotationConfigWebApplicationContext restCtx = new AnnotationConfigWebApplicationContext();
		restCtx.register(RestConfig.class);
		DispatcherServlet dispatcherServlet = new DispatcherServlet(restCtx);
		ServletRegistration.Dynamic restReg = servletContext.addServlet("rest", dispatcherServlet);
		restReg.setLoadOnStartup(1);
		restReg.addMapping(prop.getProperty("rest.urlMapping"));
	}
}