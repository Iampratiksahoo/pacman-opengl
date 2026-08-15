#pragma once 

#include <string> 
#include <vector> 

#include "texture.h"

class AssetLoader {
public:
    std::vector<Texture> textures; 

private:
    std::vector<const char*> spritePaths = {
        "assets/sprites/Fruit_Apple 1.png",
        "assets/sprites/Fruit_Apple.png",
        "assets/sprites/Fruit_Bell.png",
        "assets/sprites/Fruit_Cherry.png",
        "assets/sprites/Fruit_GalaxianStarship.png",
        "assets/sprites/Fruit_Key.png",
        "assets/sprites/Fruit_Melon.png",
        "assets/sprites/Fruit_Orange.png",
        "assets/sprites/Fruit_Strawberry.png",
        "assets/sprites/Ghost_Body_01.png",
        "assets/sprites/Ghost_Body_02.png",
        "assets/sprites/Ghost_Eyes_Down.png",
        "assets/sprites/Ghost_Eyes_Left.png",
        "assets/sprites/Ghost_Eyes_Right.png",
        "assets/sprites/Ghost_Eyes_Up.png",
        "assets/sprites/Ghost_Vulnerable_Blue_01.png",
        "assets/sprites/Ghost_Vulnerable_Blue_02.png",
        "assets/sprites/Ghost_Vulnerable_White_01.png",
        "assets/sprites/Ghost_Vulnerable_White_02.png",
        "assets/sprites/Node.png",
        "assets/sprites/Pacman_01.png",
        "assets/sprites/Pacman_02.png",
        "assets/sprites/Pacman_03.png",
        "assets/sprites/Pacman_Death_01.png",
        "assets/sprites/Pacman_Death_02.png",
        "assets/sprites/Pacman_Death_03.png",
        "assets/sprites/Pacman_Death_04.png",
        "assets/sprites/Pacman_Death_05.png",
        "assets/sprites/Pacman_Death_06.png",
        "assets/sprites/Pacman_Death_07.png",
        "assets/sprites/Pacman_Death_08.png",
        "assets/sprites/Pacman_Death_09.png",
        "assets/sprites/Pacman_Death_10.png",
        "assets/sprites/Pacman_Death_11.png",
        "assets/sprites/Pellet_Large.png",
        "assets/sprites/Pellet_Medium.png",
        "assets/sprites/Pellet_Small.png",
        "assets/sprites/Wall_00.png",
        "assets/sprites/Wall_01.png",
        "assets/sprites/Wall_02.png",
        "assets/sprites/Wall_03.png",
        "assets/sprites/Wall_04.png",
        "assets/sprites/Wall_05.png",
        "assets/sprites/Wall_06.png",
        "assets/sprites/Wall_07.png",
        "assets/sprites/Wall_08.png",
        "assets/sprites/Wall_09.png",
        "assets/sprites/Wall_10.png",
        "assets/sprites/Wall_11.png",
        "assets/sprites/Wall_12.png",
        "assets/sprites/Wall_13.png",
        "assets/sprites/Wall_14.png",
        "assets/sprites/Wall_15.png",
        "assets/sprites/Wall_16.png",
        "assets/sprites/Wall_17.png",
        "assets/sprites/Wall_18.png",
        "assets/sprites/Wall_19.png",
        "assets/sprites/Wall_20.png",
        "assets/sprites/Wall_21.png",
        "assets/sprites/Wall_22.png",
        "assets/sprites/Wall_23.png",
        "assets/sprites/Wall_24.png",
        "assets/sprites/Wall_25.png",
        "assets/sprites/Wall_26.png",
        "assets/sprites/Wall_27.png",
        "assets/sprites/Wall_28.png",
        "assets/sprites/Wall_29.png",
        "assets/sprites/Wall_30.png",
        "assets/sprites/Wall_31.png",
        "assets/sprites/Wall_32.png",
        "assets/sprites/Wall_33.png",
        "assets/sprites/Wall_34.png",
        "assets/sprites/Wall_35.png",
        "assets/sprites/Wall_36.png",
        "assets/sprites/Wall_37.png"
    }; 

public: 
    AssetLoader() {
        for(const char* spritePath : spritePaths) {
            Texture texture(spritePath);
            if(!texture.isValid) {
                std::cout << "Failed to load texture from path " << spritePath << "\n";
                continue;  
            }
            textures.push_back(texture);
        }
    }
}; 