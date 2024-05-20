//
//  LoopController.swift
//  SolarCollector
//
//  Created by Ethan Mateja on 5/22/24.
//

import Foundation

class LoopController {
	// constants
	let overnightHours = 8.0
	let overnightLow = 41.0
	let startingStorageTemp = 112.3 // estimatated with an overnight low of 41
	let specificHeatCapacity: Double = 1.0 // specific heat capacity in BTU/lb°F
	let storageTempMax: Double = 140.0
	let timeInterval = 1.0
	let waterWeightPerGallon: Double = 8.34

	// system components
	let pump: Pump = Pump()
	let storageTank: StorageTank = StorageTank()
	let solarCollector: SolarCollector = SolarCollector()
	let weatherObservations: [WeatherObservation] = WeatherReport.observations
	var reports: [LoopReport] = []

	func logWeatherObservations() {
		for observation in weatherObservations {
			let dateString = DateUtil.dateDisplayString(date: observation.date)
			print("\(dateString) - Temp: \(observation.temperature) + Radiation: \(observation.radiation)")
		}
	}

	func logLoopSimulation() {
		for observation in weatherObservations {
			let dateString = DateUtil.dateDisplayString(date: observation.date)
			let collectorTemp = estimatedOutputTemperature(
				startingTemperature: startingStorageTemp,
				timeInCollector: timeInterval,
				solarRadiation: Double(observation.radiation)
			)
			print("\(dateString) - Collector temp: \(collectorTemp)")
		}
	}

	func runLoopSimulation(radiationFactor: Double = 1.0) {
		var isFirstObservation = true
		var isPumpActive = false
		var stagedReports: [LoopReport] = []
		var lastStorageTemp: Double = 0.0

		for observation in weatherObservations {
			let date = observation.date
			let collectorTemp = estimatedOutputTemperature(
				startingTemperature: startingStorageTemp,
				timeInCollector: timeInterval,
				solarRadiation: Double(observation.radiation) * radiationFactor
			)

			var storageTemp: Double = 0.0
			if isFirstObservation {
				storageTemp = startingTankTemperature(
					startingTemperature: startingStorageTemp,
					overnightLow: overnightLow,
					totalHours: overnightHours
				)
				lastStorageTemp = storageTemp
				isFirstObservation = false
			} else {
				storageTemp = temperatureAtBottomOfTank(
					startingTemperature: lastStorageTemp,
					inputTemperature: collectorTemp,
					inputDuration: 1,
					flowRate: pump.flowRate
				)
				lastStorageTemp = storageTemp
			}

			// Don't exceed 140.0 && keep pumping if storage is colder than collector
			isPumpActive = (!isMaxStorageTemp(temp: storageTemp) && storageTemp < collectorTemp)

			let report = LoopReport(
				date: date,
				collectorTemp: collectorTemp,
				storageTemp: storageTemp,
				isPumpActive: isPumpActive
			)

			stagedReports.append(report)
			print(
				"LoopReport - Date:\(DateUtil.dateDisplayString(date: report.date)), Collector Temp: \(report.collectorTemp), Storage Temp: \(report.storageTemp), Pump Status: \(report.isPumpActive)"
			)
		}

		reports = stagedReports
		print("Total Loop Reports: \(reports.count)")
	}

	func generateWaterPlots(radiationFactor: Double = 1.0) -> [WaterPlot] {
		runLoopSimulation(radiationFactor: radiationFactor)

		var solarPlot = WaterPlot(type: .solar)
		var storagePlot = WaterPlot(type: .storage)

		// TODO: Account for radiationFactor
		for report in reports {
			let solarPlotInfo = WaterPlotInfo(x: report.date, y: report.collectorTemp)
			solarPlot.plotData.append(solarPlotInfo)

			let storagePlotInfo = WaterPlotInfo(x: report.date, y: report.storageTemp)
			storagePlot.plotData.append(storagePlotInfo)
		}

		return [solarPlot, storagePlot]
	}

	private func isMaxStorageTemp(temp: Double) -> Bool {
		return temp > storageTempMax
	}

	private func lowestTemperature(in observations: [WeatherObservation]) -> Int? {
		return observations.min(by: { $0.temperature < $1.temperature })?.temperature
	}

	private func estimatedOutputTemperature(
		startingTemperature: Double,
		timeInCollector: Double,
		solarRadiation: Double
	) -> Double {
		// number of collector panels for a household of 2 adults / 2 children
		// taking into account for SF clouds
		let numberOfCollectors: Double = 3
		let totalCollectorArea: Double = solarCollector.area * numberOfCollectors

		// weight of water in pounds
		let waterWeight: Double = solarCollector.waterVolume * waterWeightPerGallon

		// conversion factor from W to BTU/hr
		let powerConversionFactor: Double = 3_600.0 / 1_055.0

		// Calculate power absorbed in BTU/hr
		let powerAbsorbed: Double = solarCollector.efficiency * totalCollectorArea * solarRadiation * powerConversionFactor

		// Calculate energy absorbed in BTUs
		let energyAbsorbed: Double = powerAbsorbed * timeInCollector

		// Calculate temperature increase
		let temperatureIncrease: Double = energyAbsorbed / (waterWeight * specificHeatCapacity)

		// Calculate final output temperature
		let outputTemperature: Double = startingTemperature + temperatureIncrease

		return outputTemperature
	}

	private func startingTankTemperature(
		startingTemperature: Double,
		overnightLow: Double,
		totalHours: Double,
		heatLossCoefficient: Double = 0.5
	) -> Double {
		// Calculate the heat loss rate (BTU/hr°F)
		let heatLossRate: Double = heatLossCoefficient * storageTank.surfaceArea

		// Calculate the temperature difference in °F
		let temperatureDifference: Double = startingTemperature - overnightLow

		// Calculate the total heat loss over the given hours in BTU
		let totalHeatLoss: Double = heatLossRate * temperatureDifference * totalHours

		// Calculate the mass of the water in lbs
		let waterWeight: Double = storageTank.volume * waterWeightPerGallon

		// Calculate the temperature drop in °F
		let temperatureDrop: Double = totalHeatLoss / (waterWeight * specificHeatCapacity)

		// Calculate the final temperature
		let finalTemperature: Double = startingTemperature - temperatureDrop

		return finalTemperature
	}

	private func temperatureAtBottomOfTank(
		startingTemperature: Double,
		inputTemperature: Double,
		inputDuration: Double,
		flowRate: Double
	) -> Double {
		// Calculate the total mass of water in the tank in pounds
		let totalWaterMass: Double = storageTank.volume * waterWeightPerGallon

		// Calculate the mass of the incoming water during the input duration in pounds
		let incomingWaterMass: Double = inputDuration * flowRate * waterWeightPerGallon

		// Calculate the final temperature using the principle of conservation of energy
		let finalTemperature: Double = (startingTemperature * totalWaterMass + inputTemperature * incomingWaterMass) /
			(totalWaterMass + incomingWaterMass)

		return finalTemperature
	}
}
