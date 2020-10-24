//
//  APIManager.swift
//  WeatherClothes
//
//  Created by Mousa Alwaraki on 10/11/20.
//

import Foundation

class APIManager {
    
    func weatherAPICall(_ weatherURL : String, completion: @escaping (ResponseWeather) -> ()) {
        let taskWeather = URLSession.shared.dataTask(with: URL(string: weatherURL)!) { (data, response, error) in
            
            guard let data = data, error == nil else {
                print("Something went wrong")
                return
            }
            
            var result: ResponseWeather?
            
            do {
                result = try JSONDecoder().decode(ResponseWeather.self, from: data)
                completion(result!)
                
            } catch {
                print("failed to convert: \(error)")
            }
        }
        taskWeather.resume()
    }
}
