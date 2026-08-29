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

/// Common body-location presets, editable/extendable by the user via a custom entry.
enum BodyLocationPreset: String, CaseIterable, Identifiable {
    case scalp = "Scalp"
    case face = "Face"
    case neck = "Neck"
    case chest = "Chest"
    case back = "Back"
    case leftArm = "Left Arm"
    case rightArm = "Right Arm"
    case leftHand = "Left Hand"
    case rightHand = "Right Hand"
    case abdomen = "Abdomen"
    case leftLeg = "Left Leg"
    case rightLeg = "Right Leg"
    case leftFoot = "Left Foot"
    case rightFoot = "Right Foot"
    case other = "Other"

    var id: String { rawValue }
}
