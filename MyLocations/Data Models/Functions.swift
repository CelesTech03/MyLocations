//
//  Functions.swift
//  MyLocations
//
//  Created by Celeste Urena on 10/24/22.
//

import Foundation

// Creates a new global constant (applicationDocumentsDirectory) which contains the path to the app's Documents directory
let applicationDocumentsDirectory: URL = {
    let paths = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask)
    return paths[0]
}()

let dataSaveFailedNotification = Notification.Name(
    rawValue: "DataSaveFailedNotification")

// Global function for handling fata Core Data errors
func fatalCoreDataError(_ error: Error) {
    print("*** Fatal error: \(error)")
    NotificationCenter.default.post(
        name: dataSaveFailedNotification,
        object: nil)
}

func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(
        deadline: .now() + seconds,
        execute: run)
}


