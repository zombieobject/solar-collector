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
		VStack {
			Spacer()
				.frame(height: 100)

			if let (minDate, maxDate) = getChartScale() {
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
				.chartXSelection(value: $selectedDate)
				.chartXScale(domain: minDate ... maxDate)
				.padding(.horizontal)
				.padding(.bottom)
			}
		}
	}

	@ViewBuilder
	var selectionPopover: some View {
		if let selectedDate,
		   let solarPlotInfo = getTemperature(for: .solar, on: selectedDate, in: waterPlots),
		   let storagePlotInfo = getTemperature(for: .storage, on: selectedDate, in: waterPlots) {
			let solarTemp = String(format: "%.2f", solarPlotInfo.y)
			let storageTemp = String(format: "%.2f", storagePlotInfo.y)
			let pumpStatue = String(storagePlotInfo.isPumpActive ? "ON" : "OFF")

			VStack(alignment: .leading) {
				Text(selectedDate, style: Text.DateStyle.time)
					.foregroundStyle(Color.gray)
				Text("Solar: \(solarTemp)")
					.foregroundStyle(Color.blue)
				Text("Storage: \(storageTemp)")
					.foregroundStyle(Color.green)
				Text("Pump Status: " + pumpStatue)
					.foregroundStyle(Color.black)
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

	func getTemperature(for type: PlotType, on date: Date, in waterPlots: [WaterPlot]) -> WaterPlotInfo? {
		let calendar = Calendar.current
		let targetComponents = calendar.dateComponents([.year, .month, .day, .hour], from: date)

		for waterPlot in waterPlots where waterPlot.type == type {
			if let plotInfo = waterPlot.plotData.first(where: {
				let plotComponents = calendar.dateComponents([.year, .month, .day, .hour], from: $0.x)
				return plotComponents == targetComponents
			}) {
				return plotInfo
			}
		}
		return nil
	}

	func getChartScale() -> (Date, Date)? {
		if let waterPlot = waterPlots.first {
			let plotData = waterPlot.plotData
			if let firstPlotInfo = plotData.first,
			   let lastPlotInfo = plotData.last {
				return (firstPlotInfo.x, lastPlotInfo.x)
			}
		}
		return nil
	}
}
