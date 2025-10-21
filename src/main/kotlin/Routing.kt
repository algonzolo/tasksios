package com.quantron.systems.ios

import com.quantron.systems.ios.ext.decodeFromJson
import com.quantron.systems.ios.schemas.input.AddTaskInput
import com.quantron.systems.ios.schemas.input.UpdateTaskInput
import com.quantron.systems.ios.schemas.mapper.mapToTaskResponse
import com.quantron.systems.ios.schemas.output.*
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import io.ktor.server.application.*
import io.ktor.server.plugins.contentnegotiation.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.serialization.json.Json
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

fun Application.configureRouting() {
    val basePath = "/api"
    val mutex = Mutex()

    val tasks = mutableMapOf(
        "1" to TaskResponse(
            id = "1",
            name = "My first tasks",
            photoBase64 = TEST_BASE64,
            completed = false,
            date = getCurrentDate(),
        )
    )

    install(ContentNegotiation) {
        json(Json { prettyPrint = true })
    }

    routing {
        post("$basePath/status") {
            call.respond(
                status = HttpStatusCode.OK,
                message = ServerStatusResponse(status = "ok"),
            )
        }

        post("$basePath/getTasks") {
            mutex.withLock {
                call.respond(
                    status = HttpStatusCode.OK,
                    message = TasksResponse(tasks.map { it.value }),
                )
            }
        }

        post("$basePath/addTask") {
            val bodyData = call.receiveText()
            val input = bodyData.decodeFromJson<AddTaskInput>()
            if (input == null) {
                mutex.withLock {
                    call.respond(
                        status = HttpStatusCode.InternalServerError,
                        message = ServerError(errorMessage = "Fail check body request")
                    )
                }
                return@post
            }

            val updatedTasks = tasks.map { it.value } + listOf(
                TaskResponse(
                    id = "${tasks.size + 1}",
                    name = input.name,
                    date = getCurrentDate(),
                    completed = input.completed,
                    photoBase64 = input.photoBase64.orEmpty()
                )
            )
            tasks.clear()
            updatedTasks.forEach { tasks[it.id] = it }

            mutex.withLock {
                call.respond(
                    status = HttpStatusCode.OK,
                    message = TasksResponse(tasks.map { it.value }),
                )
            }
        }

        post("$basePath/updateTask") {
            val bodyData = call.receiveText()
            val input = bodyData.decodeFromJson<UpdateTaskInput>()
            if (input == null) {
                mutex.withLock {
                    call.respond(
                        status = HttpStatusCode.InternalServerError,
                        message = ServerError(errorMessage = "Fail check body request")
                    )
                }
                return@post
            }
            val updatedTask = tasks[input.id]
            if (updatedTask == null) {
                mutex.withLock {
                    call.respond(
                        status = HttpStatusCode.NotFound,
                        message = ServerError(errorMessage = "Task with id:${input.id} not found")
                    )
                }
                return@post
            }
            tasks[input.id] = input.mapToTaskResponse(updatedTask)

            mutex.withLock {
                call.respond(
                    status = HttpStatusCode.OK,
                    message = TasksResponse(tasks.map { it.value }),
                )
            }
        }
    }
}

private fun getCurrentDate(): String {
    return LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"))
}

const val TEST_BASE64 =
    "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"