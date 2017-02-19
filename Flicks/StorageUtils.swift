//
//  StorageUtils.swift
//  Flicks
//
//  Created by john on 2/19/17.
//  Copyright © 2017 doannx. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    func saveViewOption(viewOption: Int) {
        UserDefaults.standard.set(viewOption, forKey: Const.View_Option_Key)
    }
    
    func loadViewOption() -> Int {
        if let _ = UserDefaults.standard.object(forKey: Const.View_Option_Key) {
            return UserDefaults.standard.integer(forKey: Const.View_Option_Key);
        }
        return Const.View_Option_Default_Value
    }
    
    func loadSearchValue() -> String {
        let lastActive = UserDefaults.standard.integer(forKey: Const.Last_Active_Key)
        let now = Date()
        
        if(Int(now.timeIntervalSince1970) - lastActive <= Const.Time_Out_Value) {
            return UserDefaults.standard.string(forKey: Const.Search_Value_Key)!
        }
        return ""
    }
    
    func saveSearchValue(lastSearchValue: String) {
        let defaults = UserDefaults.standard
        defaults.set(lastSearchValue, forKey: Const.Search_Value_Key)
        
        let date = Date()
        let timeSecond = Int(date.timeIntervalSince1970)
        
        defaults.set(timeSecond, forKey: Const.Last_Active_Key)
        
        defaults.synchronize()
    }
    
    func saveSelectedTabBar(tabBarId: Int) {
        UserDefaults.standard.set(tabBarId, forKey: Const.Info_Option_Key)
    }
    
    func loadSelectedTabBar() -> Int {
        if let _ = UserDefaults.standard.object(forKey: Const.Info_Option_Key) {
            return UserDefaults.standard.integer(forKey: Const.Info_Option_Key);
        }
        return Const.Info_Option_Default_Value
    }
}
