//
//  TaskDetailView.swift
//  Tasks
//

import SwiftUI
import PhotosUI

struct TaskDetailView: View {
    let task: Task
    @ObservedObject var viewModel: TasksViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var taskName: String
    @State private var isCompleted: Bool
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoBase64: String?
    @State private var photoImage: UIImage?
    @State private var hasChanges = false
    @State private var photoChanged = false
    
    init(task: Task, viewModel: TasksViewModel) {
        self.task = task
        self.viewModel = viewModel
        _taskName = State(initialValue: task.name)
        _isCompleted = State(initialValue: task.completed)
        _photoBase64 = State(initialValue: task.photoBase64)
        
        if let base64 = task.photoBase64, !base64.isEmpty {
            if let data = Data(base64Encoded: base64) {
                _photoImage = State(initialValue: UIImage(data: data))
            }
        }
    }
    
    var body: some View {
        Form {
            taskInfoSection
            dateSection
            photoSection
            saveSection
        }
        .navigationTitle("Детали задачи")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Sections
    
    private var taskInfoSection: some View {
        Section {
            TextField("Название задачи", text: $taskName)
                .onChange(of: taskName) { _, _ in hasChanges = true }
            
            Toggle("Выполнено", isOn: $isCompleted)
                .onChange(of: isCompleted) { _, _ in hasChanges = true }
        } header: {
            Text("Информация о задаче")
        }
    }
    
    private var dateSection: some View {
        Section {
            Text(task.date)
                .foregroundColor(.secondary)
        } header: {
            Text("Дата создания")
        }
    }
    
    private var photoSection: some View {
        Section {
            photoPreview
            photoPicker
            deletePhotoButton
        } header: {
            Text("Фотография")
        }
    }
    
    @ViewBuilder
    private var photoPreview: some View {
        if let image = photoImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 200)
                .cornerRadius(8)
        }
    }
    
    private var photoPicker: some View {
        PhotosPicker(selection: $selectedPhoto, matching: .images) {
            HStack {
                Image(systemName: "photo.on.rectangle.angled")
                    .foregroundColor(.blue)
                Text(photoImage == nil ? "Добавить фото" : "Изменить фото")
            }
        }
        .onChange(of: selectedPhoto) { _, newValue in
            _Concurrency.Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    photoImage = UIImage(data: data)
                    photoBase64 = data.base64EncodedString()
                    hasChanges = true
                    photoChanged = true
                }
            }
        }
    }
    
    @ViewBuilder
    private var deletePhotoButton: some View {
        if photoImage != nil {
            Button(role: .destructive) {
                photoImage = nil
                photoBase64 = ""
                selectedPhoto = nil
                hasChanges = true
                photoChanged = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Удалить фото")
                }
            }
        }
    }
    
    private var saveSection: some View {
        Section {
            Button(action: saveTask) {
                HStack {
                    Spacer()
                    saveButtonContent
                    Spacer()
                }
            }
            .disabled(!hasChanges || taskName.isEmpty || viewModel.isLoading)
        }
    }
    
    @ViewBuilder
    private var saveButtonContent: some View {
        if viewModel.isLoading {
            ProgressView()
        } else {
            Text("Сохранить изменения")
                .fontWeight(.semibold)
        }
    }
    
    // MARK: - Actions
    
    private func saveTask() {
        _Concurrency.Task {
            let photoToSend = photoChanged ? photoBase64 : nil
            await viewModel.updateTask(
                id: task.id,
                name: taskName,
                completed: isCompleted,
                photoBase64: photoToSend
            )
            dismiss()
        }
    }
}

