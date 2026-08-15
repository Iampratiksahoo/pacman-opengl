#pragma once 

#include "shader.h"
#include "texture.h"
#include "glm/glm.hpp"
#include "glm/glm.hpp"

class SpriteRenderer
{
public: 
    Texture& texture; 
    glm::vec3 position;
    glm::vec2 size = glm::vec2(10.f, 10.f);
    float rotate = 0.f; 
    glm::vec3 color = glm::vec3(1.f); 

private:
    Shader shader; 
    GLuint quadVAO;

public:
    SpriteRenderer(Texture& texture, Shader &shader);
    ~SpriteRenderer();

    void Draw(float deltaTime);

private:
    void initRenderData();
};