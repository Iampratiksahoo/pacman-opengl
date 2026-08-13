#pragma once 

#include "shader.h"
#include "texture.h"
#include "glm/glm.hpp"
#include "glm/glm.hpp"

class SpriteRenderer
{
public: 
    glm::vec3 position;

private:
    Shader shader; 
    uint quadVAO;

public:
    SpriteRenderer(Shader &shader);
    ~SpriteRenderer();

    void DrawSprite(
        Texture &texture, 
        glm::vec2 size = glm::vec2(10.0f, 10.0f), 
        float rotate = 0.0f, 
        glm::vec3 color = glm::vec3(1.0f));

private:
    void initRenderData();
};