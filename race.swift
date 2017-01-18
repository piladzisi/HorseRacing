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
        RunLoop.main.add(timer, forMode: .defaultRunLoopMode)
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
