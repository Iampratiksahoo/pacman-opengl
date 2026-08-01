#include <string> 
#include <fstream>
#include <filesystem>
#include <string>
#include <sstream>


namespace PacmanUtil { 

    static const char* ReadFile(const char* filePath) {
        // static ensures the string persists in memory after the function exits
        static std::string shaderCode; 
        shaderCode.clear(); // Clear any previous contents on subsequent calls
        
        std::ifstream shaderFile;
        shaderFile.exceptions(std::ifstream::failbit | std::ifstream::badbit);

        try {
            shaderFile.open(filePath);
            std::stringstream shaderStream;
            
            // Read file buffer into stream
            shaderStream << shaderFile.rdbuf();
            shaderFile.close();
            
            // Store content in our persistent string
            shaderCode = shaderStream.str();
        }
        catch (std::ifstream::failure& e) {
            std::cerr << "ERROR::SHADER::FILE_NOT_SUCCESSFULLY_READ: " << filePath << " | " << e.what() << std::endl;
            return nullptr;
        }

        // Return the safe, persistent raw C-string pointer
        return shaderCode.c_str();
    }

}