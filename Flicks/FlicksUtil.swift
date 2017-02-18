//
//  FlicksUtil.swift
//  Flicks
//
//  Created by john on 2/18/17.
//  Copyright © 2017 doannx. All rights reserved.
//

import Foundation

class FlicksUtil {
    
    static func getImageUrl(posterPath: String, res: String) -> String {
        return Const.Poster_Base_Url + res + posterPath
    }
    
    static func getApiUrl(endPoint: String) -> String {
        return Const.Api_Url + endPoint + "?api_key=" + Const.Api_Key
    }
}
