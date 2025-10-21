//
//  TasksViewModel.swift
//  Tasks
//

import Foundation
import SwiftUI

@MainActor
class TasksViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let networkService = NetworkService.shared
    
    func loadTasks() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let loadedTasks = try await networkService.getTasks()
            tasks = loadedTasks.reversed()
        } catch {
            errorMessage = "Ошибка загрузки задач: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func addTask(name: String, completed: Bool, photoBase64: String?) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let updatedTasks = try await networkService.addTask(name: name, completed: completed, photoBase64: photoBase64)
            tasks = updatedTasks.reversed()
        } catch {
            errorMessage = "Ошибка добавления задачи: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func updateTask(id: String, name: String, completed: Bool, photoBase64: String?) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let updatedTasks = try await networkService.updateTask(id: id, name: name, completed: completed, photoBase64: photoBase64)
            tasks = updatedTasks.reversed()
        } catch {
            errorMessage = "Ошибка обновления задачи: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

