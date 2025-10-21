package com.quantron.systems.ios.schemas.output

import kotlinx.serialization.Serializable

@Serializable
data class TasksResponse(
    val values: List<TaskResponse>
)