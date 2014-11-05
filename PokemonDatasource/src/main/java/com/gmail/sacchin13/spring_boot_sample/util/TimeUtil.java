package com.gmail.sacchin13.spring_boot_sample.util;

import java.sql.Timestamp;
import java.util.Calendar;

public class TimeUtil {
	private static Calendar calender = Calendar.getInstance();

	public static Timestamp getTimestamp(String year, String month, String day, 
			String hourOfDay, String minuts){
		try {
			calender.set(Integer.valueOf(year), Integer.valueOf(month) - 1, Integer.valueOf(day), 
					Integer.valueOf(hourOfDay), Integer.valueOf(minuts));
			return new Timestamp(calender.getTimeInMillis());
		} catch (NumberFormatException e) {
			e.printStackTrace();
		}
		return new Timestamp(calender.getTimeInMillis());
	}
}
