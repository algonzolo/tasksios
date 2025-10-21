package com.quantron.systems.ios.schemas.input

import kotlinx.serialization.Serializable

@Serializable
data class AddTaskInput(
    val name: String,
    val completed: Boolean,
    val photoBase64: String? = null
)