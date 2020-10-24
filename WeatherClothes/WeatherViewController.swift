//
//  WeatherViewController.swift
//  WeatherClothes
//
//  Created by Mousa Alwaraki on 10/11/20.
//

import UIKit
import CoreLocation

var onceOnly = false

class WeatherViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var forecastCollectionView: UICollectionView!
    @IBOutlet weak var clothesImageView: UIImageView!
    @IBOutlet weak var clothesCheckLabel: UILabel!
    @IBOutlet weak var clothesCheckYesButton: UIButton!
    @IBOutlet weak var clothesCheckNoButton: UIButton!
    @IBOutlet weak var degreesLabel: UILabel!
    @IBOutlet weak var changeDegreesButton: UIButton!
    @IBOutlet weak var windView: UIView!
    @IBOutlet weak var rainView: UIView!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var rainPercentageLabel: UILabel!
    @IBOutlet weak var tempDataView: UIView!
    
    var locationManager: CLLocationManager?
    var location: Location?
    var current: Current?
    var forecast: Forecast?
    var forecastDay: ForecastDay?
    let gradientLayer = CAGradientLayer()
    var currentTime = ""
    var currentHourString = ""
    var currentHour: Int?
    var willItRain: Float?
    var chanceOfRain: Int = 0
    var willItSnow: Float?
    var chanceOfSnow: Int?
    var highestChanceOfRainChance: Int?
    var highestChanceOfRainHour: Int?
    var jacketUserRating: Int?
    var longSleeveUserRating: Int?
    var feelsLike: Int?
    var celciusDegrees: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        checkLocation()
        
        forecastCollectionView.delegate = self
        forecastCollectionView.dataSource = self

        NotificationCenter.default.addObserver(self, selector: #selector(reloadVC(_:)), name: Notification.Name(rawValue: "StartingPointCollection"), object: nil)
                
        jacketUserRating = UserDefaults.standard.value(forKey: "JacketUserRating") as? Int
        longSleeveUserRating = UserDefaults.standard.value(forKey: "LongSleeveUserRating") as? Int
        
        
        
        celciusDegrees = UserDefaults.standard.value(forKey: "CelciusDegrees") as? Bool
        
        setDegreesButtonTitle()
        setCards()
        
        tempDataView.backgroundColor = UIColor(red: 66/255, green: 123/255, blue: 255/255, alpha: 1.0)
        tempDataView.layer.shadowRadius = 12
        tempDataView.layer.shadowOffset = .init(width: 2, height: 2)
        tempDataView.layer.shadowOpacity = 1
        tempDataView.layer.masksToBounds = false
        
        addTopBorder(with: .white, andWidth: 0.5, view: rainView)
        addTopBorder(with: .white, andWidth: 0.5, view: windView)
        addRightBorder(with: .white, andWidth: 0.5, view: windView)
        
        
    }
    
    @objc func reloadVC(_ notification: Notification) {
        highestChanceOfRainChance = 0
        onceOnly = false
        setCollectionViewStartingPoint()
        setImage()
        setLabelText()
    }
    
    func invertImage() {
        let beginImage = CIImage(image: clothesImageView.image!)
        if let filter = CIFilter(name: "CIColorInvert") {
            filter.setValue(beginImage, forKey: kCIInputImageKey)
            let newImage = UIImage(ciImage: filter.outputImage!)
            clothesImageView.image = newImage
        }
    }
    
    func setCards() {
        tempDataView.layer.cornerRadius = 12
    }
    
    func addTopBorder(with color: UIColor?, andWidth borderWidth: CGFloat, view: UIView) {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        border.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: borderWidth)
        view.addSubview(border)
    }

    func addRightBorder(with color: UIColor?, andWidth borderWidth: CGFloat, view: UIView) {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleHeight, .flexibleLeftMargin]
        border.frame = CGRect(x: view.frame.size.width - borderWidth, y: 0, width: borderWidth, height: view.frame.size.height)
        view.addSubview(border)
    }
    
    func setDegreesButtonTitle() {
        if celciusDegrees == false {
            changeDegreesButton.setTitle("°F", for: .normal)
        } else {
            changeDegreesButton.setTitle("°C", for: .normal)
        }
    }
    
    @IBAction func changeDegreesButtonTapped(_ sender: Any) {
        if celciusDegrees == true {
            celciusDegrees = false
        } else {
            celciusDegrees = true
        }
        
        UserDefaults.standard.setValue(celciusDegrees, forKey: "CelciusDegrees")
        setLabelText()
        forecastCollectionView.reloadData()
    }
    
    @IBAction func clothesCheckYesButtonTapped(_ sender: Any) {
        if clothesCheckNoButton.backgroundColor != .clear {
            changeButtonBackgroundColor(clothesCheckNoButton, true)
            
            if clothesImageView.image == UIImage(named: "jacket") {
                changeJacketRating("positive")
            } else if clothesImageView.image == UIImage(named: "longSleeve") {
                changeLongSleeveRating("positive")
            }
        }
        
        if clothesCheckYesButton.backgroundColor == .clear {
            changeButtonBackgroundColor(clothesCheckYesButton, false)
            
            if clothesImageView.image == UIImage(named: "longSleeve") {
                changeJacketRating("positive")
            } else if clothesImageView.image == UIImage(named: "shortSleeve") {
                changeLongSleeveRating("positive")
            }
        } else {
            changeButtonBackgroundColor(clothesCheckYesButton, true)
            
            if clothesImageView.image == UIImage(named: "longSleeve") {
                changeJacketRating("negative")
            } else if clothesImageView.image == UIImage(named: "shortSleeve") {
                changeLongSleeveRating("negative")
            }
        }
    }
    
    func changeButtonBackgroundColor(_ button: UIButton, _ wasSelected: Bool) {
        if wasSelected == true {
            button.backgroundColor = .clear
            button.alpha = 1
        } else {
            button.backgroundColor = .systemYellow
            button.layer.cornerRadius = clothesCheckYesButton.frame.width/2
            button.alpha = 0.5
        }
    }
    
    func changeLongSleeveRating(_ change: String) {
        if change == "positive" {
            longSleeveUserRating! += 1
        } else {
            longSleeveUserRating! -= 1
        }
        UserDefaults.standard.set(longSleeveUserRating, forKey: "LongSleeveUserRating")
    }
    
    func changeJacketRating(_ change: String) {
        if change == "positive" {
            jacketUserRating! += 1
        } else {
            jacketUserRating! -= 1
        }
        UserDefaults.standard.set(jacketUserRating, forKey: "JacketUserRating")
    }
    
    @IBAction func clothesCheckNoButtonTapped(_ sender: Any) {
        if clothesCheckYesButton.backgroundColor != .clear {
            changeButtonBackgroundColor(clothesCheckYesButton, true)
            
            if clothesImageView.image == UIImage(named: "longSleeve") {
                changeJacketRating("negative")
            } else if clothesImageView.image == UIImage(named: "shortSleeve") {
                changeLongSleeveRating("negative")
            }
        }
        
        if clothesCheckNoButton.backgroundColor == .clear {
            changeButtonBackgroundColor(clothesCheckNoButton, false)
            
            if clothesImageView.image == UIImage(named: "jacket") {
                changeJacketRating("negative")
            } else if clothesImageView.image == UIImage(named: "longSleeve") {
                changeLongSleeveRating("negatiive")
            }
        } else {
            changeButtonBackgroundColor(clothesCheckNoButton, true)
            
            if clothesImageView.image == UIImage(named: "jacket") {
                changeJacketRating("positiive")
            } else if clothesImageView.image == UIImage(named: "longSleeve") {
                changeLongSleeveRating("positive")
            }
        }
    }
    
    func setImage() {
        if (feelsLike ?? 1) + (jacketUserRating ?? 1) < 12 {
            clothesImageView.image = UIImage(named: "jacket")
            clothesCheckLabel.text = "Did you need a jacket today?"
        } else if (feelsLike ?? 1) + (longSleeveUserRating ?? 1) < 18 {
            clothesImageView.image = UIImage(named: "longSleeve")
            clothesCheckLabel.text = "Did you need a jacket today?"
        } else {
            clothesImageView.image = UIImage(named: "shortSleeve")
            clothesCheckLabel.text = "Did you need a jumper today?"
        }
        invertImage()
    }
    
    func setCollectionViewStartingPoint() {
        if !onceOnly && currentHour != nil {
          let indexToScrollTo = IndexPath(item: currentHour ?? 0, section: 0)
          self.forecastCollectionView.scrollToItem(at: indexToScrollTo, at: .left, animated: false)
          onceOnly = true
        }
    }
    
    func setBackground() {
        view.layer.insertSublayer(gradientLayer, at: 0)
        if traitCollection.userInterfaceStyle == .light {
            setBlueGradientBackground()
        } else {
            setGreyGradientBackground()
        }
    }
    
    func setBlueGradientBackground() {
        let bottomColor = UIColor(red: 72.0/255.0, green: 114.0/255.0, blue: 184.0/255.0, alpha: 1.0).cgColor
        let topColor = UIColor(red: 0/255, green: 87/255, blue: 175/255, alpha: 1.0).cgColor
        gradientLayer.frame = tempDataView.bounds
        gradientLayer.colors = [topColor, bottomColor]
    }
    
    func setGreyGradientBackground() {
        let bottomColor = UIColor(red: 150.0/255.0, green: 150.0/255.0, blue: 150.0/255.0, alpha: 1.0).cgColor
        let topColor = UIColor(red: 72.0/255.0, green: 72.0/255.0, blue: 72.0/255.0, alpha: 1.0).cgColor
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [topColor, bottomColor]
    }
    
    func checkLocation() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager?.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager?.startUpdatingLocation()
        }
    }
    
    func setLabelText() {
        
        tempLabel.text = "\(feelsLike ?? 0)"
        if celciusDegrees == false {
            tempLabel.text = "\((feelsLike ?? 0 * (9/5)) + 32)"
        }
        
        rainPercentageLabel.text = "\(highestChanceOfRainHour ?? 0)"
        
        if celciusDegrees == true {
            degreesLabel.text = "°C"
            changeDegreesButton.setTitle("°F", for: .normal)
        } else {
            degreesLabel.text = "°F"
            changeDegreesButton.setTitle("°C", for: .normal)
        }
        
        cityNameLabel.text = "\(location?.name ?? ""), "
        countryNameLabel.text = location?.country
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation :CLLocation = locations[0] as CLLocation
        
        let lat = (userLocation.coordinate.latitude)
        let long = (userLocation.coordinate.longitude)
        
        let weatherUrl = "https://api.weatherapi.com/v1/forecast.json?key=ef3a754202ae4be6946122815201110&q=\(lat),\(long)&days=1"
        
        APIManager().weatherAPICall(weatherUrl) { [self] (weatherData: ResponseWeather) in
            location = weatherData.location
            current = weatherData.current
            forecast = weatherData.forecast
            forecastDay = forecast?.forecastday[0]
            
            willItRain = forecastDay?.day?.daily_will_it_rain
            willItSnow = weatherData.forecast?.forecastday[0]?.day?.daily_will_it_snow
            chanceOfRain = Int((weatherData.forecast?.forecastday[0]?.day?.daily_chance_of_rain)!)!
            
            
            feelsLike = Int(weatherData.current?.feelslike_c ?? 0)
            if celciusDegrees == false {
                feelsLike = (feelsLike ?? 0 * (9/5)) + 32
            }
            
            currentTime = location?.localtime?.substring(fromIndex: 11) ?? ""
            currentHourString = currentTime.components(separatedBy: ":")[0]
            currentHour = Int(currentHourString)
            
            DispatchQueue.main.async { [self] in
                setImage()
                setLabelText()
                forecastCollectionView.reloadData()
            }
        }
    }
}

extension WeatherViewController:  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        forecast?.forecastday[0]?.hour?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ForecastCell", for: indexPath) as! ForecastCollectionViewCell
        let url = "https:" + (forecast?.forecastday[0]?.hour?[indexPath.row].condition?.icon ?? "")
        let timeStr = forecast?.forecastday[0]?.hour?[indexPath.row].time
        var temp = Int(forecast?.forecastday[0]?.hour?[indexPath.row].temp_c ?? 0.0)
        
        cell.backgroundColor = .white
        cell.forecastHourLabel.textColor = UIColor(red: 66/255, green: 123/255, blue: 255/255, alpha: 1.0)
        cell.forecastWeatherLabel.textColor = UIColor(red: 66/255, green: 123/255, blue: 255/255, alpha: 1.0)
        cell.forecastHourLabel.text = timeStr?.substring(fromIndex: 11)
        cell.forecastWeatherImageView.downloaded(from: url)
        
        cell.forecastWeatherLabel.text = "\(temp)°C"
        if celciusDegrees == false {
            temp = (temp * (9/5) + 32)
            cell.forecastWeatherLabel.text = "\(temp)°F"
        }
        
        cell.layer.borderWidth = 0.5
        cell.layer.cornerRadius = 12
        cell.layer.borderColor = UIColor.black.cgColor
       
        cell.layer.shadowPath = UIBezierPath(rect: cell.bounds).cgPath
        cell.layer.shadowRadius = 5
        cell.layer.shadowOffset = .init(width: 2, height: 2)
        cell.layer.shadowOpacity = 0.2
        cell.layer.masksToBounds = false
        
        
        if indexPath.row > currentHour ?? 0 && (Int((forecast?.forecastday[0]?.hour?[indexPath.row].chance_of_rain)!)! > highestChanceOfRainChance ?? 0) {
            highestChanceOfRainChance = Int((forecast?.forecastday[0]?.hour?[indexPath.row].chance_of_rain)!)!
            highestChanceOfRainHour = indexPath.row
        }
        
        if indexPath.row == currentHour ?? 0 {
            cell.backgroundColor = UIColor(red: 66/255, green: 123/255, blue: 255/255, alpha: 1.0)
            cell.forecastHourLabel.textColor = .white
            cell.forecastWeatherLabel.textColor = .white
            cell.layer.shadowOpacity = 0.8
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.size.width/5) - 10, height: 100)
        }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
      setCollectionViewStartingPoint()
    }
}
