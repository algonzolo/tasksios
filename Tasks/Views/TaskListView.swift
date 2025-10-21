//
//  TaskListView.swift
//  Tasks
//

import SwiftUI

struct TaskListView: View {
    @StateObject private var viewModel = TasksViewModel()
    @State private var showingAddTask = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading && viewModel.tasks.isEmpty {
                    ProgressView("Загрузка задач...")
                } else if viewModel.tasks.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "checklist")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("Нет задач")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Text("Нажмите + чтобы добавить задачу")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                } else {
                    List {
                        ForEach(viewModel.tasks) { task in
                            NavigationLink(destination: TaskDetailView(task: task, viewModel: viewModel)) {
                                TaskRowView(task: task)
                            }
                        }
                    }
                    .refreshable {
                        await viewModel.loadTasks()
                    }
                }
                
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingAddTask = true
                        }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Задачи")
            .sheet(isPresented: $showingAddTask) {
                AddTaskView(viewModel: viewModel, isPresented: $showingAddTask)
            }
            .alert(
                "Ошибка",
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { if !$0 { viewModel.errorMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .task {
                await viewModel.loadTasks()
            }
        }
    }
}

struct TaskRowView: View {
    let task: Task
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundColor(task.completed ? .green : .gray)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(task.date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if let base64 = task.photoBase64, !base64.isEmpty,
               let data = Data(base64Encoded: base64),
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
                    .clipped()
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    TaskListView()
}

