// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation

struct KeyValue {
    let key: String
    let value: String
}

@main
struct NotCurl: AsyncParsableCommand {
    @Option(name: [.customShort("X"), .customLong("request")]) var httpMethod: String = "GET"
    @Option(name: [.customShort("H"), .long]) var header: [KeyValue] = []
    @Argument var url: URL
    @Option(name: [.long]) var dataRaw: String?
    
    mutating func run() async throws {
        print("Hello, world!")
        print("request: \(httpMethod)")
        print("Headers: \(header)")
        print("url: \(url.absoluteString)")
        
        let session = URLSession(configuration: .default)
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        for headerElement in header {
            request.addValue(headerElement.value, forHTTPHeaderField: headerElement.key)
        }
        
        request.httpBody = dataRaw?.data(using: .utf8)
        
        let (data, response) = try await session.data(for: request)
        
        print("Response: \(response)")
        
        print("Body:")
        print(String(data: data, encoding: .utf8) ?? "(not utf8)")
    }
    
}

extension URL: ExpressibleByArgument {
    public init?(argument: String) {
        if let url = URL(string: argument) {
            if url.scheme == nil {
                return nil
            }
            self = url
        } else {
            return nil
        }
    }
}


extension KeyValue: ExpressibleByArgument {
    public init?(argument: String) {
        let components = argument.split(separator: ":", maxSplits: 1)
        if components.count != 2 {
            return nil
        }
        
        self.key = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
        self.value = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
