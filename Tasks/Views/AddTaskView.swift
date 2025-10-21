//
//  AddTaskView.swift
//  Tasks
//

import SwiftUI
import PhotosUI

struct AddTaskView: View {
    @ObservedObject var viewModel: TasksViewModel
    @Binding var isPresented: Bool
    
    @State private var taskName: String = ""
    @State private var isCompleted: Bool = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoBase64: String?
    @State private var photoImage: UIImage?
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Название задачи", text: $taskName)
                    
                    Toggle("Выполнено", isOn: $isCompleted)
                } header: {
                    Text("Информация о задаче")
                }
                
                Section {
                    Group {
                        if let image = photoImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .cornerRadius(8)
                        }
                        
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
                            }
                        }
                    }
                        
                        if photoImage != nil {
                            Button(role: .destructive) {
                                photoImage = nil
                                photoBase64 = nil
                                selectedPhoto = nil
                            } label: {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Удалить фото")
                                }
                            }
                        }
                    }
                } header: {
                    Text("Фотография")
                }
                
                Section {
                    Button(action: {
                        _Concurrency.Task {
                            await viewModel.addTask(name: taskName, completed: isCompleted, photoBase64: photoBase64)
                            isPresented = false
                        }
                    }) {
                        HStack {
                            Spacer()
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            } else {
                                Text("Добавить задачу")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(taskName.isEmpty || viewModel.isLoading)
                }
            }
            .navigationTitle("Новая задача")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

