//
//  DashboardViewModel.swift
//  SolarCollector
//
//  Created by Ethan Mateja on 5/23/24.
//

import Foundation

extension DashboardView {
	class ViewModel: NSObject, ObservableObject {
		@Published var waterPlots: [WaterPlot] = []
		var loopController: LoopController = LoopController()

		override init() {
			super.init()
			generateWaterPlots(radiationFactor: 1.0)
		}

		func generateWaterPlots(radiationFactor: Double) {
			waterPlots = loopController.generateWaterPlots(radiationFactor: radiationFactor)
		}
	}
}
