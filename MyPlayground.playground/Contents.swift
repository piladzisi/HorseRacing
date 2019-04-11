import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

class Horse {
    let name: String
    let maxSpeed: Double
    var distanceTraveled = 0.0
    var currentLap = 1
    
    init(name: String, maxSpeed: Double) {
        self.maxSpeed = maxSpeed
        self.name = name
    }
    
    var currentSpeed: Double {
        let random = Double(arc4random())
        return random.truncatingRemainder(dividingBy: maxSpeed - 13) + 13
    }
}


class Tracker {
    
    struct Keys {
        static let raceStartTime = "raceStartTime"
        static let lapLeader = "leaderForLap"
        static let raceEndTime = "raceEndTime"
        static let winner = "winner"
    }
    
    var stats = [String: Any]()
    
    func updateRaceStart(with time: Date) {
        stats.updateValue(time, forKey: Keys.raceStartTime)
    }
    
    func updateLapLeaderWith(lapNumber number: Int, horse: Horse, time: Date) {
        let lapLead = "Horse: \(horse.name), time: \(time)"
        let lapLeadKey = "\(Keys.lapLeader) \(number)"
        
        stats.updateValue(lapLead, forKey: lapLeadKey)
    }
    
    func updateRaceEndWith(winner: Horse, time: Date) {
        stats.updateValue(winner.name, forKey: Keys.winner)
        stats.updateValue(time, forKey: Keys.raceEndTime)
    }
    
    func printRaceSummary() {
        print("***********")
        
        let raceStartTime = stats[Keys.raceStartTime]!
        print("Race start time: \(raceStartTime)")
        
        for (key, value) in stats where key.contains(Keys.lapLeader) {
            print("\(key): \(value)")
        }
        
        let raceEndTime = stats[Keys.raceEndTime]!
        print("Race end time: \(raceEndTime)")
        
        let winner = stats[Keys.winner]!
        print("Winner: \(winner)")
        
        print("***********")
    }
}

class Race {
    let laps: Int
    let lapLength: Double = 300
    let participants: [Horse]
    
    let tracker = Tracker()

    
    lazy var timer: Timer = Timer(timeInterval: 1, repeats: true) { timer in
        self.updateProgress()
    }
    
    init(laps: Int, participants: [Horse]) {
        self.laps = laps
        self.participants = participants
    }
    
    func start() {
        RunLoop.main.add(timer, forMode: RunLoop.Mode.default)
        tracker.updateRaceStart(with: Date())
        print("Race in progress...")
    }
    
    func updateProgress() {
        print("....")
        for horse in participants {
            horse.distanceTraveled += horse.currentSpeed
            
            if horse.distanceTraveled >= lapLength {
                horse.distanceTraveled = 0
                
                let lapKey = "\(Tracker.Keys.lapLeader) \(horse.currentLap)"
                if !tracker.stats.keys.contains(lapKey) {
                    tracker.updateLapLeaderWith(lapNumber: horse.currentLap, horse: horse, time: Date())
                }
                
                horse.currentLap += 1
                
                if horse.currentLap >= laps + 1 {
                    tracker.updateRaceEndWith(winner: horse, time: Date())
                    stop()
                    break
                }
            }
        }
    }
    
    func stop() {
        print("Race complete!")
        timer.invalidate()
        tracker.printRaceSummary()
    }
}

let jubilee = Horse(name: "Jubilee", maxSpeed: 16)
let sonora = Horse(name: "Sonora", maxSpeed: 17)
let jasper = Horse(name: "Jasper", maxSpeed: 17)

let participants = [jubilee, sonora, jasper]

let race = Race(laps: 1, participants: participants)
race.start()


