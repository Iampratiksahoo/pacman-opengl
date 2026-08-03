#pragma once 

#include "glad/gl.h"
#include "../utils/file_util.h"

class Shader {

private:
    unsigned int vertexShader;
    int vertSuccess; 

    unsigned int fragmentShader;
    int fragSuccess; 

    unsigned int shaderProgram;

public: 
    Shader(const char* vertexShaderPath, const char* fragmentShaderPath) {

        // vertex 
        const char *vertexShaderSource = FileUtil::ReadFile(vertexShaderPath);
        vertexShader = glCreateShader(GL_VERTEX_SHADER);
        glShaderSource(vertexShader, 1, &vertexShaderSource, NULL);
        glCompileShader(vertexShader);
        glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &vertSuccess);

        if (!vertSuccess) {
            std::cout << "Failed to vertex shader\n";
            return; 
        }

        // fragment 
        const char *fragmentShaderSource = FileUtil::ReadFile(fragmentShaderPath);
        fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
        glShaderSource(fragmentShader, 1, &fragmentShaderSource, NULL);
        glCompileShader(fragmentShader);
        glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, &fragSuccess);
        if (!fragSuccess) {
            std::cout << "Failed to vertex shader\n";
            return;  
        }

        // shader program
        shaderProgram = glCreateProgram();
        glAttachShader(shaderProgram, vertexShader);
        glAttachShader(shaderProgram, fragmentShader);
        glLinkProgram(shaderProgram);
    }

    ~Shader() { 
        if(vertSuccess) glDeleteShader(vertexShader);
        if(fragSuccess) glDeleteShader(fragmentShader); 
    }

    void Use() {
        if (!IsValid()) return; 
        glUseProgram(shaderProgram); 
    }

private: 
    bool IsValid() {
        return vertSuccess && fragSuccess; 
    }
}; 