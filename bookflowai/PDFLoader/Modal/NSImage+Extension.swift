import AppKit
import Foundation

extension NSImage {
    func toBase64() throws -> String {
        guard let tiffData = tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let jpegData = bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.8]) else {
            throw GeminiError.invalidImage
        }
        return jpegData.base64EncodedString()
    }
}
