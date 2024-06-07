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
    var year: String
    var month: String
    var day: String
    var hour: String
    var minute: String
    var dayPeriod: DayPeriod
    
    init(year: Int, month: Int, day: Int, hour: Int, minute: Int) {
        self.year = String(year)
        self.month = String(month)
        self.day = String(day)
        if hour > 12 {
            self.hour = String(hour - 12)
        } else {
            self.hour = String(hour == 0 ? 12 : hour)
        }
        self.minute = minute < 10 ? "0" + String(minute) : String(minute)
        self.dayPeriod = hour > 12 ? .PM : .AM
    }
    
    enum DayPeriod: String {
        case AM = "오전"
        case PM = "오후"
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
