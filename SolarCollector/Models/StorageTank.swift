//
//  StorageTank.swift
//  SolarCollector
//
//  Created by Ethan Mateja on 5/23/24.
//

import Foundation

struct StorageTank {
	// diameter of the tank in feet
	let diameter: Double = 3.0

	// height of the tank in feet
	let height: Double = 4.0

	// in BTU/lb°F
	let specificHeatCapacity: Double = 1.0

	// gallons
	let volume: Double = 100.00

	var radius: Double
	var surfaceArea: Double

	init() {
		radius = diameter / 2.0
		surfaceArea = 2 * Double.pi * radius * (radius + height)
	}
}
