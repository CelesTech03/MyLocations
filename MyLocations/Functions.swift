//
//  Functions.swift
//  MyLocations
//
//  Created by Celeste Urena on 10/24/22.
//

import Foundation

func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
  DispatchQueue.main.asyncAfter(
    deadline: .now() + seconds,
    execute: run)
}
