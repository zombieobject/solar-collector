//
//  WaterPlot.swift
//  SolarCollector
//
//  Created by Ethan Mateja on 5/21/24.
//

import Foundation

enum PlotType: String {
	case solar = "Solar"
	case storage = "Storage"
}

struct WaterPlotInfo: Identifiable {
	let id = UUID()
	let x: Date
	let y: Double
}

struct WaterPlot: Identifiable {
	let type: PlotType
	var plotData: [WaterPlotInfo] = []

	var id: PlotType { type }
}
