//
//  TodayExtension.swift
//  TheGreatGame
//
//  Created by Олег on 19.05.17.
//  Copyright © 2017 The Great Game. All rights reserved.
//

import Foundation
import TheGreatKit
import Avenues
import Shallows

final class TodayExtension {
    
    let favoriteTeams: FavoriteTeams
    let api: API
    let apiCache: APICache
    let images: Images
    
    init() {
        self.api = API.gitHub()
        self.apiCache = APICache.inSharedCachesDirectory()
        self.favoriteTeams = FavoriteTeams.inSharedDocumentsDirectory()
        self.images = Images.inSharedCachesDirectory()
        self._provider = apiCache.matches.allFull
            .backed(by: api.matches.allFull, pullingFromBack: true)
            .asReadOnlyCache()
            .mapValues({ $0.content.matches })
            .mainThread()
    }
    
    private let _provider: Retrieve<[Match.Full]>
    
    lazy var provider: Retrieve<[Match.Full]> = {
        return self._provider.mapValues({ $0.filter(self.relevanceFilter()) })
    }()
    
    func relevanceFilter() -> (Match.Full) -> Bool {
        return { match in
            return match.isFavorite(using: self.favoriteTeams.isFavorite(id:))
        }
    }
    
    func relevantMatches(from matches: [Match.Full]) -> [Match.Full] {
        return matches.filter({ (match) -> Bool in
            return match.isFavorite(using: favoriteTeams.isFavorite(id:))
        })
    }
    
}
