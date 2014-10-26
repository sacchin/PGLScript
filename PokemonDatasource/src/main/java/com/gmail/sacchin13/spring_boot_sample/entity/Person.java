package com.gmail.sacchin13.spring_boot_sample.entity;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;

@Entity
public class Person {

	@Id
	@GeneratedValue
	protected Integer id;
	protected String name;
	protected String tel;
	protected String mail;
	protected String description;

	public Person() {
		super();
	}

	public Person(String name, String tel, String mail, String description) {
		super();
		this.name = name;
		this.tel  = tel;
		this.mail = mail;
		this.description = description;
	}

	// for debug
	public String toString() {
		return "[name:" + name + ", tel:" + tel + ", mail:" + mail + ", description:" + description + "]";
	}
}