package com.quantron.systems.ios.schemas.mapper

import com.quantron.systems.ios.schemas.input.UpdateTaskInput
import com.quantron.systems.ios.schemas.output.TaskResponse

fun UpdateTaskInput.mapToTaskResponse(updatedTask: TaskResponse) = TaskResponse(
    id = id,
    name = name,
    completed = completed,
    photoBase64 = photoBase64 ?: updatedTask.photoBase64,
    date = updatedTask.date
)