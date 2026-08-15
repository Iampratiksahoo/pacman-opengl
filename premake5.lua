workspace "PacmanOpengl"
    architecture "x64"
    startproject "PacmanOpengl"

    configurations {
        "Debug", 
        "Release"
    }

    outputdir = "%{cfg.buildcfg}-%{cfg.system}-%{cfg.architecture}"

group "Dependencies"

project "GLAD"
    kind "StaticLib"
    language "C"

    targetdir ("bin/" .. outputdir .. "/%{prj.name}")
    objdir ("bin-int/" .. outputdir .. "/%{prj.name}")

    files {
        "vendor/glad/src/gl.c",
        "vendor/glad/include/**.h"
    }

    includedirs {
        "vendor/glad/include"
    }

project "GLFW"
    kind "StaticLib"
    language "C"

    targetdir ("bin/" .. outputdir .. "/%{prj.name}")
    objdir ("bin-int/" .. outputdir .. "/%{prj.name}")

    files {
        "vendor/glfw/include/GLFW/glfw3.h",
        "vendor/glfw/include/GLFW/glfw3native.h",
        "vendor/glfw/src/context.c",
        "vendor/glfw/src/init.c",
        "vendor/glfw/src/input.c",
        "vendor/glfw/src/monitor.c",
        "vendor/glfw/src/null_init.c",
        "vendor/glfw/src/null_joystick.c",
        "vendor/glfw/src/null_monitor.c",
        "vendor/glfw/src/null_window.c",
        "vendor/glfw/src/platform.c",
        "vendor/glfw/src/vulkan.c",
        "vendor/glfw/src/window.c"
    }

    includedirs {
        "vendor/glfw/include",
        "vendor/glfw/src"
    }

    filter "system:windows"
        defines {
            "_CRT_SECURE_NO_WARNINGS",
            "_GLFW_WIN32"
        }
        files {
            "vendor/glfw/src/egl_context.c",
            "vendor/glfw/src/osmesa_context.c",
            "vendor/glfw/src/wgl_context.c",
            "vendor/glfw/src/win32_init.c",
            "vendor/glfw/src/win32_joystick.c",
            "vendor/glfw/src/win32_module.c",
            "vendor/glfw/src/win32_monitor.c",
            "vendor/glfw/src/win32_thread.c",
            "vendor/glfw/src/win32_time.c",
            "vendor/glfw/src/win32_window.c"
        }

    filter "system:linux"
        defines { "_GLFW_X11" }
        files {
            "vendor/glfw/src/egl_context.c",
            "vendor/glfw/src/glx_context.c",
            "vendor/glfw/src/linux_joystick.c",
            "vendor/glfw/src/osmesa_context.c",
            "vendor/glfw/src/posix_module.c",
            "vendor/glfw/src/posix_poll.c",
            "vendor/glfw/src/posix_thread.c",
            "vendor/glfw/src/posix_time.c",
            "vendor/glfw/src/x11_init.c",
            "vendor/glfw/src/x11_monitor.c",
            "vendor/glfw/src/x11_window.c",
            "vendor/glfw/src/xkb_unicode.c"
        }

    filter "system:macosx"
        defines { "_GLFW_COCOA" }
        files {
            "vendor/glfw/src/cocoa_init.m",
            "vendor/glfw/src/cocoa_joystick.m",
            "vendor/glfw/src/cocoa_monitor.m",
            "vendor/glfw/src/cocoa_window.m",
            "vendor/glfw/src/egl_context.c",
            "vendor/glfw/src/macos_time.c",
            "vendor/glfw/src/nsgl_context.m",
            "vendor/glfw/src/osmesa_context.c",
            "vendor/glfw/src/posix_module.c",
            "vendor/glfw/src/posix_thread.c"
        }

    filter {}

project "ImGui"
    kind "StaticLib"
    language "C++"
    cppdialect "C++17"

    targetdir ("bin/" .. outputdir .. "/%{prj.name}")
    objdir ("bin-int/" .. outputdir .. "/%{prj.name}")

    files {
        "vendor/imgui/imgui.cpp",
        "vendor/imgui/imgui_draw.cpp",
        "vendor/imgui/imgui_tables.cpp",
        "vendor/imgui/imgui_widgets.cpp",
        "vendor/imgui/backends/imgui_impl_glfw.cpp",
        "vendor/imgui/backends/imgui_impl_opengl3.cpp",
        "vendor/imgui/*.h",
        "vendor/imgui/backends/*.h"
    }

    includedirs {
        "vendor/imgui",
        "vendor/imgui/backends",
        "vendor/glfw/include",
        "vendor/glad/include"
    }

    defines {
        "IMGUI_IMPL_OPENGL_LOADER_GLAD2"
    }

group ""

project "PacmanOpengl"
    kind "ConsoleApp"
    language "C++"
    cppdialect "C++17"

    targetdir ("bin/" .. outputdir)
    objdir ("bin-int/" .. outputdir .. "/%{prj.name}")

    files {
        "source/**.cpp",
        "source/**.h"
    }

    includedirs {
        "vendor/glad/include",
        "vendor/glfw/include",
        "vendor/glm",
        "vendor/imgui",
        "vendor/imgui/backends"
    }

    defines {
        "IMGUI_IMPL_OPENGL_LOADER_GLAD2"
    }

    links {
        "ImGui",
        "GLFW",
        "GLAD"
    }

    filter "system:windows"
        systemversion "latest"
        links {
            "opengl32",
            "gdi32",
            "user32",
            "winmm",
            "dwmapi",
            "shell32",
            "ole32",
            "uuid",
            "comdlg32"
        }

    filter "system:linux"
        links {
            "GL",
            "X11",
            "Xrandr",
            "Xi",
            "Xinerama",
            "Xcursor",
            "dl",
            "pthread"
        }

    filter "system:macosx"
        links {
            "Cocoa.framework",
            "IOKit.framework",
            "OpenGL.framework"
        }

    filter "configurations:Debug"
        symbols "On"

    filter "configurations:Release"
        optimize "On"
