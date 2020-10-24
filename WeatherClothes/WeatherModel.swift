//
//  WeatherModel.swift
//  WeatherClothes
//
//  Created by Mousa Alwaraki on 10/11/20.
//

import Foundation

struct ResponseWeather: Codable {
    var location: Location?
    var current: Current?
    var forecast: Forecast?
}

struct Location: Codable {
    var name: String?
    var region: String?
    var country: String?
    var localtime: String?
}

struct Current: Codable {
    var temp_c: Float?
    var temp_f: Float?
    var condition: Condition?
    var wind_mph: Float?
    var wind_kph: Float?
    var wind_dir: String?
    var precip_mm: Float?
    var precip_in: Float?
    var humidity: Float?
    var cloud: Float?
    var feelslike_c: Float?
    var feelslike_f: Float?
    var vis_km: Float?
    var vis_miles: Float?
    var uv: Float?
}

struct Condition: Codable {
    var text: String?
    var icon: String?
}

struct Forecast: Codable {
    var forecastday: [ForecastDay?]
}

struct ForecastDay: Codable {
    var day: Day?
    var astro: Astro?
    var hour: [Hour]?
}

struct Day: Codable {
    var maxtemp_c: Float?
    var maxtemp_f: Float?
    var mFloatemp_c: Float?
    var mFloatemp_f: Float?
    var avgtemp_c: Float?
    var avgtemp_f: Float?
    var maxwind_mph: Float?
    var maxwind_kph: Float?
    var totalprecip_mm: Float?
    var totalprecip_in: Float?
    var avgvis_km: Float?
    var avgvis_miles: Float?
    var avghumidity: Float?
    var daily_will_it_rain: Float?
    var daily_chance_of_rain: String?
    var daily_will_it_snow: Float?
    var daily_chance_of_snow: String?
    var condition: Condition?
    var uv: Float?
}

struct Astro: Codable {
    var sunrise: String?
    var sunset: String?
}

struct Hour: Codable {
    var time: String?
    var temp_c: Float?
    var temp_f: Float?
    var condition: Condition?
    var wind_mph: Float?
    var wind_kph: Float?
    var wind_dir: String?
    var precip_mm: Float?
    var precip_in: Float?
    var humidity: Float?
    var cloud: Float?
    var feelslike_c: Float?
    var feelslike_f: Float?
    var windchill_c: Float?
    var windchill_f: Float?
    var heatindex_c: Float?
    var heatindex_f: Float?
    var will_it_rain: Float?
    var chance_of_rain: String?
    var will_it_snow: Float?
    var chance_of_snow: String?
    var vis_km: Float?
    var vis_miles: Float?
    var uv: Float?
}

struct highestChanceOfRain {
    var chance: Int?
    var hour: Int?
}
