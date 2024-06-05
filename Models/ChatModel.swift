//
//  ChatModel.swift
//  WeMap
//
//  Created by Lee Soheun on 6/1/24.
//

import Foundation
import FirebaseDatabase

struct ChatModel {
    var user: UserViewModel
    var content: String
    var time: DateTime
    
    init(user: UserViewModel, content: String, timeStatmp: Int64) {
        self.user = user
        self.content = content
        self.time = getTimeByTimeStamp(timeStamp: timeStatmp)
    }
}

struct DateTime: Equatable {
    var year: Int
    var month: Int
    var day: Int
    var hour: Int
    var minute: Int
    
    init(year: Int, month: Int, day: Int, hour: Int, minute: Int) {
        self.year = year
        self.month = month
        self.day = day
        self.hour = hour
        self.minute = minute
    }
}

func getTimeByTimeStamp(timeStamp: Int64) -> DateTime {
    let date = Date(timeIntervalSince1970: TimeInterval(timeStamp) / 1000)
    let calendar = Calendar.current
    let year = calendar.component(.year, from: date)
    let month = calendar.component(.month, from: date)
    let day = calendar.component(.day, from: date)
    let hour = calendar.component(.hour, from: date)
    let minute = calendar.component(.minute, from: date)
    return DateTime(year: year, month: month, day: day, hour: hour, minute: minute)
}
