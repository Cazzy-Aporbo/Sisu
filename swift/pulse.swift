#!/usr/bin/env swift
//  A micro-server that keeps the HTML alive.
//  Run with:  swift run pulse.swift
//  It creates three endpoints:
//    POST /pulse   – upload your current DNA
//    GET  /latest  – download the most recent foreign DNA
//    GET  /count   – how many browsers are currently connected
//  All state lives in RAM; rebooting the server == mass extinction.

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct Pulse: Codable { let dna: String; let ts: Double }

var latest = Pulse(dna: "", ts: 0)
var pulses: [String:Double] = [:]  // IP -> timestamp
let lock = NSLock()

// crude URL decoding helper
extension String {
    func urlDecoded() -> String {
        removingPercentEncoding ?? self
    }
}

let server = HttpServer { req in
    lock.lock(); defer { lock.unlock() }
    let ip = req.peerAddress ?? "unknown"
    pulses[ip] = Date().timeIntervalSince1970
    
    switch (req.method, req.path) {
    case ("POST", "/pulse"):
        guard let body = try? JSONDecoder().decode(Pulse.self, from: Data(req.body.utf8)) else {
            return HttpResponse.badRequest("invalid pulse")
        }
        latest = body
        return HttpResponse.ok("thump")
        
    case ("GET", "/latest"):
        guard !latest.dna.isEmpty else { return HttpResponse.notFound("no pulse yet") }
        return HttpResponse.json(latest)
        
    case ("GET", "/count"):
        let cutoff = Date().timeIntervalSince1970 - 15  // 15-second heartbeat
        let alive = pulses.values.filter { $0 > cutoff }.count
        return HttpResponse.json(["count": alive])
        
    default:
        return HttpResponse.notFound("void")
    }
}

print("Serving on http://0.0.0.0:8989")
try server.listen(port: 8989)

// MARK: - Nano HTTP server (no dependencies)
typealias HttpRequest = (method: String, path: String, body: String, peerAddress: String?)
enum HttpResponse {
    case ok(String), json(Codable), badRequest(String), notFound(String)
    var status: String {
        switch self {
        case .ok: return "200 OK"
        case .json: return "200 OK"
        case .badRequest: return "400 Bad Request"
        case .notFound: return "404 Not Found"
        }
    }
    var bodyData: Data {
        switch self {
        case .ok(let s): return Data(s.utf8)
        case .badRequest(let s): return Data(s.utf8)
        case .notFound(let s): return Data(s.utf8)
        case .json(let encodable):
            return (try? JSONEncoder().encode(encodable)) ?? Data()
        }
    }
}

final class HttpServer {
    private let handler: (HttpRequest) -> HttpResponse
    init(handler: @escaping (HttpRequest) -> HttpResponse) { self.handler = handler }
    func listen(port: UInt16) throws {
        let listenSocket = try socket(AF_INET, SOCK_STREAM, 0)
        var addr = sockaddr_in()
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = port.bigEndian
        addr.sin_addr.s_addr = INADDR_ANY.bigEndian
        try withUnsafePointer(to: &addr) { ptr in
            try ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { bptr in
                if bind(listenSocket, bptr, socklen_t(MemoryLayout<sockaddr_in>.size)) != 0 {
                    throw NSError(domain: "bind", code: -1)
                }
            }
        }
        listen(listenSocket, 32)
        while true {
            var clientAddr = sockaddr_in()
            var len = socklen_t(MemoryLayout<sockaddr_in>.size)
            let client = accept(listenSocket, &clientAddr, &len)
            DispatchQueue.global().async { self.handle(client: client) }
        }
    }
    private func handle(client: Int32) {
        var raw = [UInt8](repeating: 0, count: 4096)
        let n = recv(client, &raw, raw.count, 0)
        guard n > 0 else { close(client); return }
        let data = Data(raw[0..<n])
        let lines = String(data: data, encoding: .utf8)?.split(separator: "\r\n") ?? []
        guard let request = lines.first?.split(separator: " ") else { close(client); return }
        let method = String(request[0])
        let path   = String(request[1]).urlDecoded()
        let body   = lines.dropFirst().drop(while: { !$0.isEmpty }).dropFirst().joined(separator: "\r\n")
        let addr   = "unknown"  // crude; real code would parse sockaddr_in
        let resp = handler((method: method, path: path, body: body, peerAddress: addr))
        var reply = "HTTP/1.1 \(resp.status)\r\nContent-Length: \(resp.bodyData.count)\r\n"
        if case .json = resp { reply += "Content-Type: application/json\r\n" }
        reply += "\r\n"
        send(client, reply, reply.utf8.count, 0)
        send(client, resp.bodyData, resp.bodyData.count, 0)
        close(client)
    }
}
