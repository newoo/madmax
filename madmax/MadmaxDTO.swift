//
//  MadmaxDTO.swift
//  madmax
//
//  Created by Taeheon Woo on 11/8/24.
//

import Foundation

struct MadmaxRealtimeAPI: Codable {
    let info: String
    let version: String
    let timestamp: String
    let docs: String
    let heartbeatEnabled: Bool
    let limit: Limit

    struct Limit: Codable {
        let remaining: Int
    }
}

struct MadmaxSubscriptionResponse: Codable {
    let success: Bool
    let subscribe: String
    let request: Request

    struct Request: Codable {
        let op: String
        let args: [String]
    }
}

struct MadmaxOrderBook: Codable {
    let table: String
    let action: String
    let keys: [String]?
    let types: [String: String]?
    let filter: Filter?
    let data: [OrderData]

    struct Filter: Codable {
        let symbol: String
    }

    struct OrderData: Codable {
        let symbol: String
        let id: Int
        let side: String
        let size: Int
        let price: Double
        let timestamp: String
        let transactTime: String
    }
}
