//
//  Task.swift
//  Tasks
//

import Foundation

struct Task: Identifiable, Codable {
    let id: String
    var name: String
    var completed: Bool
    var photoBase64: String?
    var date: String
}

// API Response models
struct TasksResponse: Codable {
    let values: [Task]
}

// API Request models
struct AddTaskRequest: Codable {
    let name: String
    let completed: Bool
    let photoBase64: String?
}

struct UpdateTaskRequest: Codable {
    let id: String
    let name: String
    let completed: Bool
    let photoBase64: String?
}

