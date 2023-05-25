import Foundation

class KalmanFilter {
    var cov: Float = Float.nan
    var x: Float = Float.nan
    
    var A: Float = 1
    var B: Float = 0
    var C: Float = 1
    
    var R: Float
    var Q: Float
    
    init(R: Float, Q: Float) {
        self.R = R
        self.Q = Q
    }
    
    func filter(measurement: Float) -> Float {
        let u: Float = 0
        
        if x.isNaN {
            x = (1 / C) * measurement
            cov = (1 / C) * Q * (1 / C)
        } else {
            let predX = (A * x) + (B * u)
            let predCov = ((A * cov) * A) + R
            
            let K = predCov * C * (1 / ((C * predCov * C) + Q))
            
            x = predX + K * (measurement - (C * predX))
            cov = predCov - (K * C * predCov)
        }
        
        return x
    }
    
    func lastMeasurement() -> Float {
        return x
    }
    
    func setMeasurementNoise(noise: Float) {
        Q = noise
    }
    
    func setProcessNoise(noise: Float) {
        R = noise
    }
}
