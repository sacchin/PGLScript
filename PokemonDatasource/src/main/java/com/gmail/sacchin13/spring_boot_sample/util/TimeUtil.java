package com.gmail.sacchin13.spring_boot_sample.util;

import java.sql.Timestamp;
import java.util.Calendar;

public class TimeUtil {

	public static Calendar getToday() {
		return Calendar.getInstance();
	}

	public static Calendar getCalendar(String year, String month, String day,
			String hourOfDay, String minuts) {
		
		Calendar temp = Calendar.getInstance();
		try {
			temp.set(Integer.valueOf(year), Integer.valueOf(month) - 1,
					Integer.valueOf(day), Integer.valueOf(hourOfDay),
					Integer.valueOf(minuts));
			return temp;
		} catch (NumberFormatException e) {
			e.printStackTrace();
		}
		return temp;
	}

	public static Timestamp getTimestamp(String year, String month, String day,
			String hourOfDay, String minuts) {
		return new Timestamp(getCalendar(year, month, day, hourOfDay, minuts).getTimeInMillis());
	}
}
