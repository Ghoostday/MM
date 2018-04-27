package com.innology.moonmasons.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class PageController {

	@RequestMapping(value = "/")
	public String homePage() {
		return "HomePage";
	}
}
