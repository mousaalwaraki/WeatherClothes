//
//  ForecastCollectionViewCell.swift
//  WeatherClothes
//
//  Created by Mousa Alwaraki on 10/13/20.
//

import UIKit

class ForecastCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var forecastHourLabel: UILabel!
    @IBOutlet weak var forecastWeatherImageView: UIImageView!
    @IBOutlet weak var forecastWeatherLabel: UILabel!
    
    override class func awakeFromNib() {
        
    }
}
