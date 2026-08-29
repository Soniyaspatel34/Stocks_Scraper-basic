import SwiftUI
import UIKit

/// Local-only persistence for scan records and their images.
///
/// Everything lives in the app's Documents directory as JPEGs plus a JSON
/// index. Nothing is uploaded anywhere; this is a personal photo journal,
/// not a cloud service.
@MainActor
final class ScanStore: ObservableObject {
    @Published private(set) var records: [ScanRecord] = []

    private let indexURL: URL
    private let imagesDirectory: URL
    private let fileManager = FileManager.default

    init() {
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        imagesDirectory = documents.appendingPathComponent("Images", isDirectory: true)
        indexURL = documents.appendingPathComponent("index.json")

        try? fileManager.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
        load()
    }

    var sortedRecords: [ScanRecord] {
        records.sorted { $0.date > $1.date }
    }

    func records(for bodyLocation: String) -> [ScanRecord] {
        records
            .filter { $0.bodyLocation == bodyLocation }
            .sorted { $0.date < $1.date }
    }

    var distinctBodyLocations: [String] {
        Array(Set(records.map(\.bodyLocation))).sorted()
    }

    @discardableResult
    func addScan(image: UIImage, bodyLocation: String, note: String, referenceWidthMM: Double?) -> ScanRecord? {
        guard let data = image.jpegData(compressionQuality: 0.92) else { return nil }

        let fileName = "\(UUID().uuidString).jpg"
        let fileURL = imagesDirectory.appendingPathComponent(fileName)

        do {
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("SkinScope: failed to write image — \(error)")
            return nil
        }

        let record = ScanRecord(
            bodyLocation: bodyLocation,
            note: note,
            imageFileName: fileName,
            referenceWidthMM: referenceWidthMM
        )
        records.append(record)
        save()
        return record
    }

    func updateNote(for record: ScanRecord, note: String) {
        guard let index = records.firstIndex(where: { $0.id == record.id }) else { return }
        records[index].note = note
        save()
    }

    func delete(_ record: ScanRecord) {
        let fileURL = imagesDirectory.appendingPathComponent(record.imageFileName)
        try? fileManager.removeItem(at: fileURL)
        records.removeAll { $0.id == record.id }
        save()
    }

    func deleteAll() {
        for record in records {
            try? fileManager.removeItem(at: imagesDirectory.appendingPathComponent(record.imageFileName))
        }
        records.removeAll()
        save()
    }

    func image(for record: ScanRecord) -> UIImage? {
        UIImage(contentsOfFile: imagesDirectory.appendingPathComponent(record.imageFileName).path)
    }

    // MARK: - Disk I/O

    private func load() {
        guard let data = try? Data(contentsOf: indexURL) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        records = (try? decoder.decode([ScanRecord].self, from: data)) ?? []
    }

    private func save() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(records) else { return }
        try? data.write(to: indexURL, options: .atomic)
    }
}
