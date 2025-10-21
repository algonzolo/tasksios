package com.quantron.systems.ios.ext

import kotlinx.serialization.json.Json
import kotlinx.serialization.SerializationException

inline fun <reified T> String?.decodeFromJson(): T? {
    if (this.isNullOrEmpty()) return null
    val jsonBuilder = Json { ignoreUnknownKeys = true }
    return try {
        val json = this
        jsonBuilder.decodeFromString<T>(json)
    } catch (e: SerializationException) {
        null
    } catch (e: IllegalArgumentException) {
        null
    }
}