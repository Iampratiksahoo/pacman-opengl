#pragma once 

#include "glm/glm.hpp"

struct Transform {
    glm::vec2 position;
    glm::vec2 size = glm::vec2(10.0f, 10.0f);
    float rotate = 0.0f; 
};