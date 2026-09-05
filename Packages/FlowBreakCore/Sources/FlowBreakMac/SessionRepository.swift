import Foundation
import FlowBreakCore

public struct ActivityEvent: Codable, Sendable, Identifiable {
    public var id: UUID
    public var date: Date
    public var kind: String
    public init(date: Date, kind: String) { self.id = UUID(); self.date = date; self.kind = kind }
}

/// Synchronous small atomic writes, called on user actions or a 15-second checkpoint.
public final class SessionRepository {
    public let directory: URL
    public init(directory: URL? = nil) throws {
        self.directory = try directory ?? FileManager.default.url(
            for: .applicationSupportDirectory, in: .userDomainMask,
            appropriateFor: nil, create: true).appendingPathComponent("FlowBreak", isDirectory: true)
        try FileManager.default.createDirectory(at: self.directory, withIntermediateDirectories: true)
    }

    public func loadSnapshot() throws -> SessionSnapshot? { try load("session-v1.json") }
    public func saveSnapshot(_ snapshot: SessionSnapshot) throws { try save(snapshot, "session-v1.json") }
    public func loadEvents() throws -> [ActivityEvent] { try load("events-v1.json") ?? [] }
    public func saveEvents(_ events: [ActivityEvent]) throws { try save(Array(events.suffix(1000)), "events-v1.json") }

    private func load<T: Decodable>(_ name: String) throws -> T? {
        let url = directory.appendingPathComponent(name)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return try JSONDecoder().decode(T.self, from: Data(contentsOf: url))
    }

    private func save<T: Encodable>(_ value: T, _ name: String) throws {
        try JSONEncoder().encode(value).write(to: directory.appendingPathComponent(name), options: .atomic)
    }
}
