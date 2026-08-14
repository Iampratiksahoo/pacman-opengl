#pragma once 

#include "shader.h"
#include "texture.h"
#include "glm/glm.hpp"
#include "glm/glm.hpp"

class SpriteRenderer
{
public: 
    glm::vec3 position;
    glm::vec2 size = glm::vec2(10.f, 10.f);
    float rotate = 0.f; 
    glm::vec3 color = glm::vec3(1.f); 

private:
    Shader shader; 
    uint quadVAO;

public:
    SpriteRenderer(Shader &shader);
    ~SpriteRenderer();

    void Draw(Texture& texture);

private:
    void initRenderData();
};