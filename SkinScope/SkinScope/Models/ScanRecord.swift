import Foundation

/// A single captured close-up image and its metadata.
struct ScanRecord: Identifiable, Codable, Hashable {
    let id: UUID
    var date: Date
    var bodyLocation: String
    var note: String
    var imageFileName: String
    /// Millimeters represented by the width of the on-screen reference grid at
    /// capture time, if the user had a scale reference visible. Nil when unknown.
    var referenceWidthMM: Double?

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        bodyLocation: String,
        note: String = "",
        imageFileName: String,
        referenceWidthMM: Double? = nil
    ) {
        self.id = id
        self.date = date
        self.bodyLocation = bodyLocation
        self.note = note
        self.imageFileName = imageFileName
        self.referenceWidthMM = referenceWidthMM
    }
}

