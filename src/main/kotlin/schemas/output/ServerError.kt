package com.quantron.systems.ios.schemas.output

import kotlinx.serialization.Serializable

@Serializable
data class ServerError(
    val errorMessage: String
)