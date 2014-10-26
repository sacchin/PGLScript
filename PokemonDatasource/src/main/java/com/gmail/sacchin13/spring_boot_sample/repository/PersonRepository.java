package com.gmail.sacchin13.spring_boot_sample.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.gmail.sacchin13.spring_boot_sample.entity.Person;
 
@Repository
public interface PersonRepository extends JpaRepository<Person, Integer> {
	  // find methods
	  public List<Person> findByName(String name);
	  public List<Person> findByTel(String tel);
	  public List<Person> findByMail(String mail);
	  public List<Person> findByDescription(String description);
}