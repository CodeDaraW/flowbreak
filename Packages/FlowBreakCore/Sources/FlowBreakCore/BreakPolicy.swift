import Foundation

/// All durations are seconds. This value is also the versioned settings payload.
public struct BreakPolicy: Codable, Equatable, Sendable {
    public var eyeInterval: TimeInterval = 20 * 60
    public var eyeDuration: TimeInterval = 20
    public var movementSoftInterval: TimeInterval = 40 * 60
    public var movementStrongInterval: TimeInterval = 60 * 60
    public var movementDuration: TimeInterval = 3 * 60
    public var idlePauseThreshold: TimeInterval = 2 * 60
    public var naturalRestThreshold: TimeInterval = 5 * 60
    public var mergeWindow: TimeInterval = 3 * 60
    public var sharingRecoveryDelay: TimeInterval = 20

    public init() {}

    public var isValid: Bool {
        let values = [eyeInterval, eyeDuration, movementSoftInterval,
                      movementStrongInterval, movementDuration, idlePauseThreshold,
                      naturalRestThreshold, mergeWindow, sharingRecoveryDelay]
        return values.allSatisfy { $0.isFinite && $0 > 0 }
            && movementSoftInterval < movementStrongInterval
            && idlePauseThreshold < naturalRestThreshold
            && eyeDuration <= movementDuration
            && mergeWindow < eyeInterval
    }
}
