#include <cmath>
#include <cstdio>
#include <iostream>

#include <glad/gl.h>
#include <GLFW/glfw3.h>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>

#include "utils/file_util.h"
#include "core/texture.h"
#include "core/shader.h"
#include "core/sprite_renderer.h"

namespace
{
  constexpr int kInitialWidth = 1280;
  constexpr int kInitialHeight = 720;
  // constexpr const char* kGlslVersion = "#version 330";

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

// process all input: query GLFW whether relevant keys are pressed/released this frame and react accordingly
// ---------------------------------------------------------------------------------------------------------
void processInput(GLFWwindow *window)
{
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        glfwSetWindowShouldClose(window, true);
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

    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    // const char* gl_version = reinterpret_cast<const char*>(glGetString(GL_VERSION));
    glm::vec4 clear_color(0.08f, 0.11f, 0.14f, 1.f);
    
    Shader defaultShader(
        "assets/shaders/sprite_default.vert",
        "assets/shaders/sprite_default.frag"
    );

    glm::mat4 projection = glm::ortho(
        0.0f,
        static_cast<float>(kInitialWidth),
        static_cast<float>(kInitialHeight),
        0.0f,
        -1.0f,
        1.0f
    );

    defaultShader.Use();
    defaultShader.SetInt("image", 0);
    defaultShader.SetMat4("projection", projection);

    SpriteRenderer renderer(defaultShader);

    Texture appleTexture("assets/sprites/other/apple.png"); 
    if(!appleTexture.isValid) {
        std::cout << "Failed to load texture\n";
        return 1; 
    }   

    while (!glfwWindowShouldClose(window)) {
        
        // input 
        processInput(window); 
        
        // render 
        glClearColor(clear_color.r, clear_color.g, clear_color.b, clear_color.a);
        glClear(GL_COLOR_BUFFER_BIT);

        renderer.DrawSprite(
            appleTexture, 
            glm::vec2(400, 300)
        );
        
        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    // cleanup 
    glfwDestroyWindow(window);
    glfwTerminate();

    return 0;
}