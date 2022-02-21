//
//  AltapiManager.swift
//  Pie Schedule
//
//  Created by Krystian Postek on 21/02/2022.
//

import Foundation
import RealmSwift

class AltapiManager {
    private let urlSession = URLSession(configuration: .default)
    private let baseUrl = URL(string: "https://altapi.kpostek.dev/")!
    
    func getEntries(for dateString: String) async throws -> ScheduleEntryResponse? {
        let url = baseUrl.appendingPathComponent("public/timetable/2022-03-07")
        var urlComp = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        urlComp.queryItems = [
            URLQueryItem(name: "groups", value: "WIs I.2 - 46c"),
            URLQueryItem(name: "groups", value: "WIs I.2 - 11c")
        ]
        guard let urlFinal = urlComp.url else { return nil }
        print(urlFinal)
        
        let (data, _) = try await urlSession.data(from: urlFinal)
        return try JSONDecoder().decode(ScheduleEntryResponse.self, from: data)
    }
}
