//
//  ChartView.swift
//  SolarCollector
//
//  Created by Ethan Mateja on 5/20/24.
//

import Charts
import SwiftUI

struct ChartView: View {
	let waterPlots: [WaterPlot]
	@State private var selectedDate: Date? = nil

	var body: some View {
		Chart(waterPlots) { waterPlot in
			ForEach(waterPlot.plotData) { plot in
				LineMark(
					x: .value("", plot.x, unit: .hour),
					y: .value("", plot.y)
				)
				.foregroundStyle(by: .value("", waterPlot.type.rawValue))
				.interpolationMethod(.monotone)
			}

			if let selectedDate {
				RuleMark(x: .value("", selectedDate, unit: .hour))
					.annotation(
						position: .top,
						spacing: 0,
						overflowResolution: .init(
							x: .fit(to: .chart),
							y: .disabled
						)
					) {
						selectionPopover
					}
			}
		}
		.aspectRatio(1, contentMode: .fit)
		.frame(height: 440)
		.chartXSelection(value: $selectedDate)
	}

	@ViewBuilder
	var selectionPopover: some View {
		if let selectedDate,
		   let solarTemp = getTemperature(for: .solar, on: selectedDate, in: waterPlots),
		   let storageTemp = getTemperature(for: .storage, on: selectedDate, in: waterPlots) {
			VStack(alignment: .leading) {
				Text(selectedDate, style: Text.DateStyle.time)
					.foregroundStyle(Color.gray)
				Text("Solar: \(solarTemp)")
					.foregroundStyle(Color.blue)
				Text("Storage: \(storageTemp)")
					.foregroundStyle(Color.green)
			}
			.font(.caption)
			.padding(6)
			.background {
				RoundedRectangle(cornerRadius: 4)
					.fill(Color.white)
					.shadow(color: .blue, radius: 2)
			}
			.allowsTightening(true)
		}
	}

	func getTemperature(for type: PlotType, on date: Date, in waterPlots: [WaterPlot]) -> String? {
		let calendar = Calendar.current
		let targetComponents = calendar.dateComponents([.year, .month, .day, .hour], from: date)

		for waterPlot in waterPlots where waterPlot.type == type {
			if let plotInfo = waterPlot.plotData.first(where: {
				let plotComponents = calendar.dateComponents([.year, .month, .day, .hour], from: $0.x)
				return plotComponents == targetComponents
			}) {
				return String(format: "%.2f", plotInfo.y)
			}
		}
		return nil
	}
}
