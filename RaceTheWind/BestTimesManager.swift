//
//  BestTimesManager.swift
//  RaceTheWind
//
//  Created by Patrick Wheeler on 5/1/24.
//  Copyright © 2024 Patrick Wheeler. All rights reserved.
//

import Foundation

class BestTimesManager {
    
//    init() {
////        print("best times manager instantiated")
//    }
    
    static let sharedTimesManager = BestTimesManager()
    
    private init() {
        print("TimesManager private init called")
//        gpt suggests running loadBestTimes() method here
        loadBestTimes()
    }
    
    private let bestTimesKey = "BestTimes"
    // so this identifies the key location in UserDefaults where we store an array of [String: TimeInterval]'s
        
    private var bestTimes: [String: TimeInterval] = [:]
    
    /*
     TODO
     I would really love the data structure to be each length:difficulty could have an array of top 5 or 10 [time:playerInitials]'s
     */
        
    func getBestTime(forCourse course: String) -> TimeInterval? {
        return bestTimes[course]
    }
    
    func setBestTime(_ time: TimeInterval, forCourse course: String) {
        print("setBestTime method called")
        bestTimes[course] = time
        saveBestTimes()
    }
    
    private func loadBestTimes() {
        print("loadBestTimes called")
        if let savedBestTimes = UserDefaults.standard.dictionary(forKey: bestTimesKey) as? [String: TimeInterval] {
            bestTimes = savedBestTimes
            print("print of bestTimes: ")
            print(bestTimes)
        } else {
            print("savedBestTimes doesn't exist, so I should create a blank scores list")
        }
    }
    
    private func saveBestTimes() {
        UserDefaults.standard.set(bestTimes, forKey: bestTimesKey)
        print("saveBestTimes called")
    }

    func resetScoresTest() {
        print("Sample Reset Score method called")
    }
    
    
    func didEnterBackground() {
        print("sharedTimesManager.didEnterBackground method called when App entered background")
        
//  I think this would be to the best time to save scores (and state)
    }
    
    func willEnterForeground() {
        print("sharedTimesManager.willEnterForeground method called when App will enter foreground")
        
//  I think we just reload state here. (not scoree)
    }
    
    func didBecomeActive() {
        print("sharedTimesManager.didBecomeActive method called when App did become active")
        
/*    
    I think this would be the best time to load scores
    Unlike willEnterForeground, didBecomeActive runs at both launch and returns.
 
    Note, gpt's approach was to read scores at app launch, and save them every time a new record was set.
    In that approach, the AppDelegate methods would only be needed to store the state for the game.
*/
    }
    
}
