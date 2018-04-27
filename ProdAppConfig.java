package com.innology.moonmasons.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;
import org.springframework.context.annotation.PropertySource;
import org.springframework.context.support.PropertySourcesPlaceholderConfigurer;
import org.springframework.core.env.Environment;
import org.springframework.data.geo.GeoModule;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.jdbc.datasource.DriverManagerDataSource;
import org.springframework.orm.jpa.JpaTransactionManager;
import org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean;
import org.springframework.orm.jpa.vendor.HibernateJpaVendorAdapter;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.transaction.annotation.EnableTransactionManagement;


@Configuration
@EnableScheduling
@ComponentScan({"com.innology.moonmasons.*"})
@EnableJpaRepositories(basePackages = {"com.innology.moonmasons.repo"})
@EnableTransactionManagement
@PropertySource("classpath:application.properties")
@Import({SecurityConfig.class})
public class ProdAppConfig {

	@Value("${db.url}") String dbUrl;
	@Value("${db.user}") String dbUser;
	@Value("${db.password}") String dbPassword;
	@Value("${db.driver}") String dbDriver;
	@Value("${db.showSql}") boolean dbShowSql;
	
	
	@Autowired
    public Environment env;

	@Bean 
	public static PropertySourcesPlaceholderConfigurer propertySourcesPlaceholderConfigurer() {
		return new PropertySourcesPlaceholderConfigurer();
	}
	
	@Bean
	public DatabaseMaintenance databaseMaintenance() {
		return new DatabaseMaintenance();
	}
	
	@Bean
	public JpaTransactionManager transactionManager() {
		JpaTransactionManager transactionManager = new JpaTransactionManager();
		transactionManager.setEntityManagerFactory(entityManagerFactory().getObject());
		return transactionManager; 
	}

	@Bean
	public LocalContainerEntityManagerFactoryBean entityManagerFactory() {
		LocalContainerEntityManagerFactoryBean entityManagerFactory = new LocalContainerEntityManagerFactoryBean();
		entityManagerFactory.setPackagesToScan("com.innology.moonmasons.model");
		entityManagerFactory.setDataSource(dataSource());
		entityManagerFactory.setJpaVendorAdapter(jpaVendorAdapter());
		//entityManagerFactory.setJpaDialect((JpaDialect) PostgreSQL82Dialect.getDialect());
		return entityManagerFactory;
	}

	@Bean
	public HibernateJpaVendorAdapter jpaVendorAdapter() {
		HibernateJpaVendorAdapter adapter = new HibernateJpaVendorAdapter();
		adapter.setGenerateDdl(true);
		adapter.setShowSql(dbShowSql);
		return adapter;
	}

	@Bean
	public DriverManagerDataSource dataSource() {
		DriverManagerDataSource dataSource = new DriverManagerDataSource(dbUrl, dbUser, dbPassword);
		dataSource.setDriverClassName(dbDriver);
		return dataSource;
	}

	@Bean
	public GeoModule geoModule() {
		return new GeoModule();
	}
}