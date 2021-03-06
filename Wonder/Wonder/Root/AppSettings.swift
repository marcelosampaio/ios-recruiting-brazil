//
//  AppSettings.swift
//  Wonder
//
//  Created by Marcelo on 06/11/18.
//  Copyright © 2018 Marcelo. All rights reserved.
//

import Foundation

private let shared = AppSettings()


class AppSettings {

    // genres list
    public var genresList = GenresList()
    
    // internet connection status
    public var isConnectedToInternet = false
    
    class var standard: AppSettings {
        return shared
    }
    
    // MARK: - Reachability Helper
    public func updateInternetConnectionStatus(_ status: Bool) {
        self.isConnectedToInternet = status
    }
    
    public func internetConnectionStatus() -> Bool {
        return self.isConnectedToInternet
    }

    // MARK: - Genres List
    public func loadGenresList() {
        let webService = WebService()
        webService.getGenresList { (genresResult) in
            // completion
            self.genresList = genresResult
            let genres : [Genres] = self.genresList.genres
            // remove previous stored data
            self.removeDefualtsCategories()
            
            // persist categories
            for genre in genres {
                self.setDefualtsCategory(id: genre.id, name: genre.name)
                AppSettings.standard.genresList.genres.append(Genres(id: genre.id, name: genre.name))
            }
            
        }
    }

    // MARK: - Distinct Genres Procedures
    public func getDistinctGenres(favoriteMovies: [FavoriteMovies]) -> [String] {
        // get all genres
        let allGenres = self.getAllExistingGenre(favoriteMovies: favoriteMovies)
        // order all genres asc
        let orderedGenres = self.sortArray(allGenres)
        return breakProcessing(orderedGenres)
    }
    private func getAllExistingGenre(favoriteMovies: [FavoriteMovies]) -> [String] {
        var allGenres = [String]()
        for fav in favoriteMovies {
            let components = (fav.genre?.split(separator: ","))!
            
            for item in components {
                let genre = String(item)
                allGenres.append(genre)
            }
        }
        return allGenres
    }
    private func sortArray(_ input: [String]) -> [String] {
        var result = [String]()
        result = input.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
        return result
    }
    private func breakProcessing(_ input: [String]) -> [String] {
        var distinct = [String]()
        var old = ""
        for i in 0...(input.count - 1) {
            if i == 0 {
                old = input[i]
            }
            if input[i] != old {
                distinct.append(old)
                old = input[i]
            }
        }
        if input.count > 0 {
            distinct.append(old)
        }
        return distinct
    }

    
    
    // MARK: - Movie's category persistance
    
    public func getDefualtsGenresList() -> GenresList {
        
        let result : GenresList = GenresList()
        
        for item in UserDefaults.standard.dictionaryRepresentation().keys {
            let index = item.index(item.startIndex, offsetBy: 2)
            let subStr = String(item[..<index])
            if subStr == "id" {
                let userDefaults = UserDefaults.standard
                let value : String = userDefaults.object(forKey: item) as! String
                let key : Int = Int(item.replacingOccurrences(of: "id", with: ""))!
                
                let genre = Genres(id: key, name: value)
                result.genres.append(genre)
            }
        }
        
        return result
    }
    
    
    public func getDefualtsCategory(id: Int) -> String {
        let userDefaults = UserDefaults.standard
        let key = "id" + String(id)
        return userDefaults.string(forKey: key)!
    }
    
    public func setDefualtsCategory(id: Int, name: String) {
        let userDefaults = UserDefaults.standard
        let key = "id" + String(id)
        userDefaults.set(name, forKey: key)
        userDefaults.synchronize()
    }
    
    public func removeDefualtsCategories() {
        for item in UserDefaults.standard.dictionaryRepresentation().keys {
            let index = item.index(item.startIndex, offsetBy: 2)
            let subStr = String(item[..<index])
            if subStr == "id" {
                let userDefaults = UserDefaults.standard
                userDefaults.removeObject(forKey: item)
                userDefaults.synchronize()
            }
        }
    }
    
    // MARK: - Movies Helper
    public func releaseYear(_ releaseData: String) -> String {
        let releaseDate = releaseData.components(separatedBy: "-")
        let year = String(describing: releaseDate[0])
        
        if !year.isEmpty{
            return "℗ " + year + "  "
        }else{
            return ""
        }
    }
    
    public func genreDisplay(genreIdArray:[Int]) -> String{
        
        var resultString = ""
        for genreId in genreIdArray {
            resultString = resultString + " ⚐ " + AppSettings.standard.getDefualtsCategory(id: genreId)
        }
        return resultString
    }
    
    public func genreForDatabase(genreIdArray:[Int]) -> String{
        
        var resultString = ""
        var separator = ""
        for genreId in genreIdArray {
            resultString = resultString + separator + AppSettings.standard.getDefualtsCategory(id: genreId)
            separator = ","
        }
        return resultString
    }
    
    
}
