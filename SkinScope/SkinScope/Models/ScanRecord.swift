import Foundation

/// A single captured close-up image and its metadata.
struct ScanRecord: Identifiable, Codable, Hashable {
    let id: UUID
    var date: Date
    var bodyLocation: String
    var note: String
    var imageFileName: String
    /// An optional normal (non-microscope) photo taken just before plugging
    /// in the microscope — a wide reference shot of the same zone, for
    /// context alongside the close-up. Nil when the user skipped it.
    var contextImageFileName: String?
    /// Millimeters represented by the width of the on-screen reference grid at
    /// capture time, if the user had a scale reference visible. Nil when unknown.
    var referenceWidthMM: Double?

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        bodyLocation: String,
        note: String = "",
        imageFileName: String,
        contextImageFileName: String? = nil,
        referenceWidthMM: Double? = nil
    ) {
        self.id = id
        self.date = date
        self.bodyLocation = bodyLocation
        self.note = note
        self.imageFileName = imageFileName
        self.contextImageFileName = contextImageFileName
        self.referenceWidthMM = referenceWidthMM
    }
}

