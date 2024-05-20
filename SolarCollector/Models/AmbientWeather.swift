//
//  AmbientWeather.swift
//  SolarCollector
//
//  Created by Ethan Mateja on 5/22/24.
//

import Foundation

struct WeatherObservation: Identifiable, Equatable {
	let id: UUID = UUID()
	let date: Date
	let temperature: Int
	let radiation: Int
}

struct WeatherReport: Identifiable, Equatable {
	let id: UUID = UUID()

	static var observations = [
		WeatherObservation(date: DateUtil.date(hour: 6), temperature: 41, radiation: 0),
		WeatherObservation(date: DateUtil.date(hour: 7), temperature: 44, radiation: 55),
		WeatherObservation(date: DateUtil.date(hour: 8), temperature: 52, radiation: 253),
		WeatherObservation(date: DateUtil.date(hour: 9), temperature: 58, radiation: 429),
		WeatherObservation(date: DateUtil.date(hour: 10), temperature: 64, radiation: 611),
		WeatherObservation(date: DateUtil.date(hour: 11), temperature: 70, radiation: 771),
		WeatherObservation(date: DateUtil.date(hour: 12), temperature: 72, radiation: 883),
		WeatherObservation(date: DateUtil.date(hour: 13), temperature: 75, radiation: 948),
		WeatherObservation(date: DateUtil.date(hour: 14), temperature: 76, radiation: 959),
		WeatherObservation(date: DateUtil.date(hour: 15), temperature: 77, radiation: 915),
		WeatherObservation(date: DateUtil.date(hour: 16), temperature: 75, radiation: 813),
		WeatherObservation(date: DateUtil.date(hour: 17), temperature: 74, radiation: 668),
		WeatherObservation(date: DateUtil.date(hour: 18), temperature: 68, radiation: 345),
		WeatherObservation(date: DateUtil.date(hour: 19), temperature: 64, radiation: 50),
		WeatherObservation(date: DateUtil.date(hour: 20), temperature: 55, radiation: 28),
		WeatherObservation(date: DateUtil.date(hour: 21), temperature: 50, radiation: 0)
	]
}
