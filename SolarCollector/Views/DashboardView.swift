//
//  DashboardView.swift
//  SolarCollector
//
//  Created by Ethan Mateja on 5/20/24.
//

import SwiftUI

struct DashboardView: View {
	@State private var sliderValue: CGFloat = 0
	@StateObject var viewModel: ViewModel

	init() {
		let model = ViewModel()
		_viewModel = StateObject(wrappedValue: model)
	}

	var body: some View {
		VStack {
			VStack(spacing: 20) {
				Text("SOL-9000")
					.font(.title)

				Spacer()

				ChartView(waterPlots: viewModel.waterPlots)
					.padding(.horizontal)
					.frame(maxWidth: .infinity)
					.background(Color(UIColor.secondarySystemGroupedBackground))
					.cornerRadius(8)
					.shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)

				Spacer()

				VStack {
					Slider(
						value: $sliderValue,
						in: 0 ... 0.5,
						step: 0.25
					) {
						Text("Sol Adjustment")
					}
					HStack {
						Image(systemName: "sun.max")
						Spacer()
						Image(systemName: "cloud.sun")
						Spacer()
						Image(systemName: "cloud")
					}
				}
				.padding(.horizontal)
				.padding(.vertical, 30)
				.frame(maxWidth: .infinity)
				.background(Color(UIColor.secondarySystemGroupedBackground))
				.cornerRadius(8)
				.shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)

				Spacer()
			}
			.padding()
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(
			Color(UIColor.systemGroupedBackground)
				.ignoresSafeArea()
		)
		.onChange(of: sliderValue) { _, newValue in
			let radiationFactor = 1 - newValue
			viewModel.generateWaterPlots(radiationFactor: radiationFactor)
		}
	}
}
