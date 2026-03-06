//
//  PersistenceService.swift
//  Altar
//
//  JSON-based persistence for tasks and session history.
//

import Foundation

final class PersistenceService {
    static let shared = PersistenceService()

    private let fileManager = FileManager.default
    private let tasksFileName = "tasks.json"
    private let historyFileName = "history.json"

    private var appSupportURL: URL {
        let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let dir = urls[0].appendingPathComponent("Altar", isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    private var tasksURL: URL { appSupportURL.appendingPathComponent(tasksFileName) }
    private var historyURL: URL { appSupportURL.appendingPathComponent(historyFileName) }

    private init() {}

    func loadTasks() -> [FocusTask] {
        load(from: tasksURL, as: [FocusTask].self) ?? []
    }

    func saveTasks(_ tasks: [FocusTask]) {
        save(tasks, to: tasksURL)
    }

    func loadHistory() -> [SessionRecord] {
        load(from: historyURL, as: [SessionRecord].self) ?? []
    }

    func saveHistory(_ sessions: [SessionRecord]) {
        save(sessions, to: historyURL)
    }

    private func load<T: Decodable>(from url: URL, as type: T.Type) -> T? {
        guard fileManager.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private func save<T: Encodable>(_ value: T, to url: URL) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        try? data.write(to: url)
    }
}
