//
//  AppDelegate.swift
//  iBeaconTestKontaktSwift3
//
//  Created by Patrick Steiner on 17.11.16.
//  Copyright © 2016 Mopius. All rights reserved.
//

import UIKit
import KontaktSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    fileprivate var beaconManager: KTKBeaconManager!
    
    fileprivate var region: KTKBeaconRegion!
    let beaconUUID = "90dc5409-c9f4-4854-bc38-94367885850e"
    let mainRegionIdentifier = "MainRegion"
    
    // using custom class, because hashable extension of CLBeacon doesn't find compare to CLBeacons via (uuid, major and minor
    var discoveredBeacons = Set<Beacon>()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Kontakt.setAPIKey("---")
        
        let proximityUUID = UUID(uuidString: beaconUUID)
        region = KTKBeaconRegion(proximityUUID: proximityUUID!, identifier: mainRegionIdentifier)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        region.notifyEntryStateOnDisplay = true
        
        beaconManager = KTKBeaconManager(delegate: self)
        beaconManager.requestLocationAlwaysAuthorization()
        
        beaconManager.stopMonitoringForAllRegions()
        
        return true
    }
    
    fileprivate func regionFromBeacon(_ beacon: CLBeacon) -> KTKBeaconRegion {
        let uuid = beacon.proximityUUID
        let major = beacon.major as CLBeaconMajorValue
        let minor = beacon.minor as CLBeaconMinorValue
        let identifier = "SubRegion-\(major)-\(minor)"
        
        return KTKBeaconRegion(proximityUUID: uuid, major: major, minor: minor, identifier: identifier)
    }
    
    fileprivate func startMonitoringForRegion(beacon: CLBeacon) {
        print("Start Monitoring for SubRegion: major: \(beacon.major) minor: \(beacon.minor)")
        
        let region = regionFromBeacon(beacon)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        region.notifyEntryStateOnDisplay = true
        
        beaconManager.startMonitoring(for: region)
    }
}

extension AppDelegate: KTKBeaconManagerDelegate {
    
    func beaconManager(_ manager: KTKBeaconManager, didChangeLocationAuthorizationStatus status: CLAuthorizationStatus) {
        var message = "DidChangeLocationAuthorizationState"
        
        switch status {
        case .authorizedAlways:
            message += " status: AuthorizedAlways"
            
            // Start Monitoring and Ranging
            beaconManager.startMonitoring(for: region)
        case .authorizedWhenInUse:
            message += " status: AuthorizedWhenInUse"
        case .denied:
            message += " status: Denied"
        case .notDetermined:
            message += " status: Not Determined"
        case .restricted:
            message += " status: Restricted"
        }
        
        print(message)
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didDetermineState state: CLRegionState, for region: KTKBeaconRegion) {
        var message = "DidDetermineState"
        
        switch state {
        case .inside:
            message += " state: Inside"
            
            if region.identifier == mainRegionIdentifier {
                beaconManager.startRangingBeacons(in: region)
            }
        case .outside:
            message += " state: Outside"
            
            if region.identifier == mainRegionIdentifier {
                beaconManager.startRangingBeacons(in: region)
            }
        case .unknown:
            message += " state: Unknown"
        }
        
        print(message)
    }
    
    func beaconManager(_ manager: KTKBeaconManager, monitoringDidFailFor region: KTKBeaconRegion?, withError error: Error?) {
        print("\(#function) error: \(error.debugDescription)")
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didStartMonitoringFor region: KTKBeaconRegion) {
        print(#function)
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didEnter region: KTKBeaconRegion) {
        print("Enter region \(region)")
        
        if region.identifier == mainRegionIdentifier {
            print("ENTERING MAIN REGION")
        }
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didExitRegion region: KTKBeaconRegion) {
        print("Exit region \(region)")
        
        if region.identifier == mainRegionIdentifier {
            print("EXITING MAIN REGION")
        }
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didRangeBeacons beacons: [CLBeacon], in region: KTKBeaconRegion) {
        print("Ranged beacons count: \(beacons.count) in region: major: \(region.major) minor: \(region.minor)")
        print("Monitored regions count: \(beaconManager.monitoredRegions.count) Ranged regions count: \(beaconManager.rangedRegions.count)")
        
        for beacon in beacons {
            let b = Beacon(clbeacon: beacon)
            if discoveredBeacons.contains(b) {
                print("Already discovered beacon")
            } else {
                print("Adding new beacon and starting monitoring")
                discoveredBeacons.insert(b)
                startMonitoringForRegion(beacon: beacon)
            }
        }
    }
    
    func beaconManager(_ manager: KTKBeaconManager, rangingBeaconsDidFailFor region: KTKBeaconRegion?, withError error: Error?) {
        print(#function)
    }
}

