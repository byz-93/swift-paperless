//
//  MultiPartFormDataRequest.swift
//  swift-paperless
//
//  Created by Paul Gessinger on 12.03.23.
//

import Foundation
import UniformTypeIdentifiers

enum MultiPartFormDataError: Error {
    case notAFile(url: URL)
    case noMimeType
}

struct MultiPartFormDataRequest {
    typealias Error = MultiPartFormDataError

    private let boundary: String = UUID().uuidString
    let body = NSMutableData()

    func add(name: String, string: String) {
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n")
        body.append("Content-Type: text/plain\r\n")
        body.append("\r\n")
        body.append(string)
        body.append("\r\n")
    }

    func add(name: String, url: URL, mimeType: String? = nil) throws {
        guard url.isFileURL else {
            throw Error.notAFile(url: url)
        }

        guard let mimeType = UTType(filenameExtension: url.pathExtension)?.preferredMIMEType ?? mimeType else {
            throw Error.noMimeType
        }

        let data = try Data(contentsOf: url)

        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"document\"; filename=\"\(url.lastPathComponent)\"\r\n")
        body.append("Content-Type: \(mimeType)\r\n")
        body.append("\r\n")
        body.append(data)
        body.append("\r\n")
    }

    func addTo(request: inout URLRequest) {
        body.append("\r\n")
        body.append("--\(boundary)--")

        request.httpMethod = "POST"
        request.httpBody = body as Data
        request.setValue("multipart/form-data; boundary=\(boundary)",
                         forHTTPHeaderField: "Content-Type")
    }
}
