package com.quantron.systems.ios.schemas.output

import kotlinx.serialization.Serializable

@Serializable
data class TaskResponse(
    val id: String,
    val name: String,
    val completed: Boolean,
    val photoBase64: String,
    val date: String
)