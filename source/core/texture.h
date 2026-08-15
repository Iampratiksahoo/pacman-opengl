#pragma once

#include <iostream> 
#include "glad/gl.h"
#include "stb_image.h"


class Texture {
public:
    GLuint ID = -1;
    int width = -1; 
    int height = -1; 
    int nrChannels = -1;
    bool isValid = false; 
    
public: 
    Texture(const char* path) {
        glGenTextures(1, &ID);  
        glBindTexture(GL_TEXTURE_2D, ID);  
        // set the texture wrapping parameters
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);	// set texture wrapping to GL_REPEAT (default wrapping method)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        // set texture filtering parameters
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        stbi_set_flip_vertically_on_load(true);  
        unsigned char *data = stbi_load(path, &width, &height, &nrChannels, 0);
        if (data)
        {
            GLenum format;
            switch (nrChannels)
            {
            case 1:
                format = GL_RED; 
                break;
            case 3:
                format = GL_RGB; 
                break;
            case 4:
                format = GL_RGBA; 
                break;
            default:
                break;
            }

            glTexImage2D(GL_TEXTURE_2D, 0, format, width, height, 0, format, GL_UNSIGNED_BYTE, data);
            glGenerateMipmap(GL_TEXTURE_2D);
        }
        else
        {
            std::cout << "Failed to load texture" << std::endl;
        }
        isValid = data != nullptr; 
        stbi_image_free(data);
    }

    void Bind() {
        glBindTexture(GL_TEXTURE_2D, ID);
    }
};
