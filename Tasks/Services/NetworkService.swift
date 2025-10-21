//
//  NetworkService.swift
//  Tasks
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    case serverError(String)
}

class NetworkService {
    static let shared = NetworkService()
    private let baseURL = "http://localhost:8080/api"
    
    private init() {}
    
    func getTasks() async throws -> [Task] {
        guard let url = URL(string: "\(baseURL)/getTasks") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        do {
            let tasksResponse = try JSONDecoder().decode(TasksResponse.self, from: data)
            return tasksResponse.values
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func addTask(name: String, completed: Bool, photoBase64: String?) async throws -> [Task] {
        guard let url = URL(string: "\(baseURL)/addTask") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = AddTaskRequest(name: name, completed: completed, photoBase64: photoBase64)
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        do {
            let tasksResponse = try JSONDecoder().decode(TasksResponse.self, from: data)
            return tasksResponse.values
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func updateTask(id: String, name: String, completed: Bool, photoBase64: String?) async throws -> [Task] {
        guard let url = URL(string: "\(baseURL)/updateTask") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = UpdateTaskRequest(id: id, name: name, completed: completed, photoBase64: photoBase64)
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        do {
            let tasksResponse = try JSONDecoder().decode(TasksResponse.self, from: data)
            return tasksResponse.values
        } catch {
            throw NetworkError.decodingError
        }
    }
}

