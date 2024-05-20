//
//  DateUtil.swift
//  SolarCollector
//
//  Created by Ethan Mateja on 5/22/24.
//

import Foundation

enum DateUtil {
	static func date(
		year: Int = 2_024,
		month: Int = 5,
		day: Int = 1,
		hour: Int = 0,
		minutes: Int = 0,
		seconds: Int = 0
	) -> Date {
		Calendar.current.date(from: DateComponents(
			year: year,
			month: month,
			day: day,
			hour: hour,
			minute: minutes,
			second: seconds
		)) ?? Date()
	}

	static func dateDisplayString(date: Date) -> String {
		let formatter = DateFormatter()
		formatter.timeZone = .current
		// formatter.dateFormat = "MMM dd yyyy HH:mm:ss"
		formatter.dateFormat = "EEE, yy, h:mm a"
		return formatter.string(from: date)
	}
}
