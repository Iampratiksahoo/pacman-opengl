#include <cmath>
#include <cstdio>
#include <iostream>

#include <glad/gl.h>
#include <GLFW/glfw3.h>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>

#include "util/file_handler.h"

namespace
{
  constexpr int kInitialWidth = 1280;
  constexpr int kInitialHeight = 720;
  constexpr const char* kGlslVersion = "#version 330";

  void glfw_error_callback(int error, const char* description)
  {
      std::fprintf(stderr, "GLFW error %d: %s\n", error, description);
  }

  void framebuffer_size_callback(GLFWwindow*, int width, int height)
  {
      glViewport(0, 0, width, height);
  }

  GLADapiproc load_gl_function(const char* name)
  {
      return reinterpret_cast<GLADapiproc>(glfwGetProcAddress(name));
  }
}

int main()
{
    glfwSetErrorCallback(glfw_error_callback);

    if (!glfwInit())
    {
        return 1;
    }

    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

    GLFWwindow* window = glfwCreateWindow(kInitialWidth, kInitialHeight, "Pac Man", nullptr, nullptr);
    if (window == nullptr)
    {
        glfwTerminate();
        return 1;
    }

    glfwMakeContextCurrent(window);
    glfwSwapInterval(1);
    glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);

    if (!gladLoadGL(load_gl_function))
    {
        std::fprintf(stderr, "Failed to initialize GLAD.\n");
        glfwDestroyWindow(window);
        glfwTerminate();
        return 1;
    }

    const char* gl_version = reinterpret_cast<const char*>(glGetString(GL_VERSION));
    glm::vec3 clear_color(0.08f, 0.11f, 0.14f);
    
    // CREATE SHADERS AND SHADER PROGRAM
    const char *vertexShaderSource = PacmanUtil::ReadFile("assets/shaders/default.vert");
    unsigned int vertexShader;
    vertexShader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertexShader, 1, &vertexShaderSource, NULL);
    glCompileShader(vertexShader);

    const char *fragmentShaderSource = PacmanUtil::ReadFile("assets/shaders/default.frag");
    unsigned int fragmentShader;
    fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragmentShader, 1, &fragmentShaderSource, NULL);
    glCompileShader(fragmentShader);

    unsigned int shaderProgram;
    shaderProgram = glCreateProgram();
    glAttachShader(shaderProgram, vertexShader);
    glAttachShader(shaderProgram, fragmentShader);
    glLinkProgram(shaderProgram);

    float vertices[] = {
        -0.5f, -0.5f, 0.0f,
        0.5f, -0.5f, 0.0f,
        0.0f,  0.5f, 0.0f
    };  


    // BIND THE VERTEX DATA 
    unsigned int VAO;
    glGenVertexArrays(1, &VAO);  
    glBindVertexArray(VAO);
    
    unsigned int VBO;
    glGenBuffers(1, &VBO);  
    glBindBuffer(GL_ARRAY_BUFFER, VBO);  
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
    glEnableVertexAttribArray(0);


    while (!glfwWindowShouldClose(window))
    {
        glfwPollEvents();

        // render 
        glClearColor(clear_color.r, clear_color.g, clear_color.b, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);

        // draw our triangle
        glUseProgram(shaderProgram);
        glBindVertexArray(VAO); // seeing as we only have a single VAO there's no need to bind it every time, but we'll do so to keep things a bit more organized
        glDrawArrays(GL_TRIANGLES, 0, 3);

        glfwSwapBuffers(window);
    }

    // cleanup 
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader); 
    glfwDestroyWindow(window);
    glfwTerminate();

    return 0;
}
