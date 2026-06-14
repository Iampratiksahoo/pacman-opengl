#include <cmath>
#include <cstdio>

#include <glad/gl.h>
#include <GLFW/glfw3.h>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>
#include <imgui.h>
#include <imgui_impl_glfw.h>
#include <imgui_impl_opengl3.h>

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

    GLFWwindow* window = glfwCreateWindow(kInitialWidth, kInitialHeight, "OpenGL Bootstrap", nullptr, nullptr);
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

    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO();
    io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;

    ImGui::StyleColorsDark();
    ImGui_ImplGlfw_InitForOpenGL(window, true);
    ImGui_ImplOpenGL3_Init(kGlslVersion);

    const char* gl_version = reinterpret_cast<const char*>(glGetString(GL_VERSION));
    glm::vec3 clear_color(0.08f, 0.11f, 0.14f);

    while (!glfwWindowShouldClose(window))
    {
        glfwPollEvents();

        const float time = static_cast<float>(glfwGetTime());
        const glm::mat4 transform = glm::rotate(glm::mat4(1.0f), time, glm::vec3(0.0f, 0.0f, 1.0f));
        const float pulse = (std::sin(time) + 1.0f) * 0.5f;
        const glm::vec4 animated = transform * glm::vec4(0.35f + pulse * 0.25f, 0.42f, 0.62f, 1.0f);

        ImGui_ImplOpenGL3_NewFrame();
        ImGui_ImplGlfw_NewFrame();
        ImGui::NewFrame();

        ImGui::Begin("Debug");
        ImGui::Text("OpenGL: %s", gl_version != nullptr ? gl_version : "unknown");
        ImGui::Text("GLFW: %s", glfwGetVersionString());
        ImGui::Text("GLM vec4: %.2f, %.2f, %.2f, %.2f", animated.x, animated.y, animated.z, animated.w);
        ImGui::ColorEdit3("Clear color", glm::value_ptr(clear_color));
        ImGui::Text("Frame time: %.3f ms", 1000.0f / io.Framerate);
        ImGui::End();

        ImGui::Render();

        glClearColor(clear_color.r, clear_color.g, clear_color.b, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());

        glfwSwapBuffers(window);
    }

    ImGui_ImplOpenGL3_Shutdown();
    ImGui_ImplGlfw_Shutdown();
    ImGui::DestroyContext();

    glfwDestroyWindow(window);
    glfwTerminate();

    return 0;
}
