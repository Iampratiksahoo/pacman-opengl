# Pacman OpenGL

## Build

Windows:

```bash
vendor/bin/premake/windows/premake5.exe gmake
mingw32-make
```

Linux:

```bash
vendor/bin/premake/linux/premake5 gmake
make
```

macOS:

```bash
vendor/bin/premake/mac/premake5 gmake
make
```

The executable is written to `bin/<config>-<platform>-x86_64/`.

## Visual Studio

```bash
vendor/bin/premake/windows/premake5.exe vs2022
```

Open `OpenglBootstrap.sln` in Visual Studio.

## Project Layout

Premake generates one solution/workspace with these projects:

```text
GLAD              Static library built from vendor/glad
GLFW              Static library built from vendor/glfw
ImGui             Static library built from vendor/imgui
OpenglBootstrap   Application linked against those dependency projects
```

GLM is header-only and included from `vendor/glm`.

Generated project files and build output are ignored by Git.
