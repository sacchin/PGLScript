package com.gmail.sacchin13.spring_boot_sample;

import java.sql.Timestamp;
import java.util.Calendar;
import java.util.Date;

import javax.servlet.Filter;

import org.json.JSONArray;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.context.embedded.ConfigurableEmbeddedServletContainer;
import org.springframework.boot.context.embedded.EmbeddedServletContainerCustomizer;
import org.springframework.boot.context.embedded.ErrorPage;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.filter.CharacterEncodingFilter;
import org.springframework.boot.SpringApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.http.HttpStatus;

import com.gmail.sacchin13.spring_boot_sample.entity.Person;
import com.gmail.sacchin13.spring_boot_sample.entity.RankingPokemonTrend;
import com.gmail.sacchin13.spring_boot_sample.entity.WazaInfo;
import com.gmail.sacchin13.spring_boot_sample.repository.PersonRepository;
import com.gmail.sacchin13.spring_boot_sample.repository.RankingPokemonTrendRepository;
import com.gmail.sacchin13.spring_boot_sample.repository.WazaInfoRepository;
import com.gmail.sacchin13.spring_boot_sample.util.TimeUtil;

@Controller
@EnableAutoConfiguration
public class MainController {
	@Autowired
	PersonRepository personRepository;
	@Autowired
	WazaInfoRepository wazaInfoRepository;
	@Autowired
	RankingPokemonTrendRepository rankingPokemonTrendRepository;

	@Bean
	public EmbeddedServletContainerCustomizer containerCustomizer(){
		return new MyCustomizer();
	}

	private static class MyCustomizer implements EmbeddedServletContainerCustomizer {
		@Override
		public void customize(ConfigurableEmbeddedServletContainer factory) {
			//factory.addErrorPages(new ErrorPage(HttpStatus.BAD_REQUEST, "/400"));
			//factory.addErrorPages(new ErrorPage(HttpStatus.UNAUTHORIZED, "/401"));
			factory.addErrorPages(new ErrorPage(HttpStatus.NOT_FOUND, "/404"));
			//factory.addErrorPages(new ErrorPage(HttpStatus.INTERNAL_SERVER_ERROR, "/500"));
		}
	}

	@Bean
	public Filter characterEncodingFilter() {
		CharacterEncodingFilter filter = new CharacterEncodingFilter();
		filter.setEncoding("UTF-8");
		filter.setForceEncoding(true);
		return filter;
	}

	@RequestMapping("/pokemon-view")
	public String pokemonView(Model model) {
		Calendar yesterday = TimeUtil.getToday();
		yesterday.add(Calendar.DAY_OF_MONTH, -1);
		yesterday.set(Calendar.HOUR_OF_DAY, 0);
		Date start = yesterday.getTime();
		
		yesterday.set(Calendar.HOUR_OF_DAY, 23);
		Date end = yesterday.getTime();

		Iterable<RankingPokemonTrend> list = rankingPokemonTrendRepository.findHigherRank(start, end);
		model.addAttribute("results", list);
		return "person-view";
	}

	@RequestMapping(value="/search", method=RequestMethod.GET)
	public String pokemonSearch(Model model,
			@RequestParam("pokemon_no") String no,
			@RequestParam("year") String year,
			@RequestParam("month") String month,
			@RequestParam("day") String day) {
		//insert sample
		//Person person = new Person(name, tel, mail, description);
		//personRepository.saveAndFlush(person);
		if(no == null || no.isEmpty()){
			no = "303-0";
		}
		
		Iterable<RankingPokemonTrend> list;
		if(year == null || month == null || day == null || 
				year.isEmpty() || month.isEmpty() || day.isEmpty() ){
			list = rankingPokemonTrendRepository.findLater(no);
			model.addAttribute("results", list);
		}else{
			Timestamp start = TimeUtil.getTimestamp(year, month, day, "00", "00");
			Timestamp end = TimeUtil.getTimestamp(year, month, day, "23", "59");
			System.out.println(start + " , " + end);
			list = rankingPokemonTrendRepository.findByDay(start, end);
			model.addAttribute("results", list);
		}

		return "person-view";
	}

	@RequestMapping("/")
	@ResponseBody
	public String home() {
		return "Hello, Spring Boot Sample Application!";
	}

	// an entry point
	public static void main( String[] args )
	{
		SpringApplication.run(MainController.class, args);
	}

	@RequestMapping("/hello")
	public String hello(@RequestParam(value="name", required=false, defaultValue="World") String name, Model model) {
		model.addAttribute("name", name);
		return "hello";
	}

	// input formを表示
	@RequestMapping("/input")
	public String input() {
		return "input"; // input form
	}

	// inputフォームから受け取ってhello.htmlへ
	@RequestMapping("/send")
	public String send(Model model, @RequestParam("name") String name) {
		model.addAttribute("name", name);
		return "hello";    // View file is templates/hello.html
	}





	@RequestMapping("/404")
	public String notFoundError() {
		return "error/404"; // templates/error/404.html
	} 


	@RequestMapping("/pokemon-json")
	public String pokemonJSON(Model model) {
		Iterable<RankingPokemonTrend> list = rankingPokemonTrendRepository.findLater("303-0");
		JSONArray temp = new JSONArray();
		for (RankingPokemonTrend rankingPokemonTrend : list) {
			temp.put(rankingPokemonTrend.toJSON());
		}
		return temp.toString();
	}




	@RequestMapping(value="/find", method=RequestMethod.POST) 
	public String find(Model model,  @RequestParam("category") String category , @RequestParam("str") String str) {

		Iterable<Person> list = null;

		if (category.equals("name")) {
			list = personRepository.findByName(str);
		}
		else if (category.equals("tel")) {
			list = personRepository.findByTel(str);
		}
		else if (category.equals("mail")) {
			list = personRepository.findByMail(str);
		}
		else if (category.equals("description")) {
			list = personRepository.findByDescription(str);
		}
		else {
			list = null; 
		}

		model.addAttribute("results", list);
		return "person-view";
	}
}