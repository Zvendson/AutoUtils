cmake_minimum_required(VERSION 3.24)

set(CMAKE_GENERATOR_PLATFORM win32)

project(AutoUtils)

if(MSVC_TOOLSET_VERSION LESS 142)
    message(FATAL_ERROR "Build using Visual Studio 2019 toolset (v142) or higher. Run cmake with `-T142`. You're currently using ${MSVC_TOOLSET_VERSION}")
endif()

if(NOT(CMAKE_SIZEOF_VOID_P EQUAL 4))
    message(FATAL_ERROR "You are configuring a non 32-bit build, this is not supported. Run cmake with `-A Win32`")
endif()

set_property(GLOBAL PROPERTY USE_FOLDERS ON)


add_compile_definitions(
    "NOMINMAX"
    "WIN32_LEAN_AND_MEAN"
)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_library(${PROJECT_NAME} SHARED)
set_target_properties(${PROJECT_NAME} PROPERTIES
    OUTPUT_NAME_DEBUG "AutoUtils_Debug"
    OUTPUT_NAME_RELEASE "AutoUtils"
)

file(GLOB SOURCES
    "cpp/include/*.h"
    "cpp/src/*.h"
    "cpp/src/*.cpp")

target_sources(${PROJECT_NAME} PUBLIC ${SOURCES})
target_precompile_headers(${PROJECT_NAME} PRIVATE "cpp/src/pch.h")


target_compile_options(${PROJECT_NAME} PRIVATE /W4 /WX /ZI)


set_target_properties(${PROJECT_NAME} PROPERTIES
    VS_GLOBAL_RunCodeAnalysis false
    VS_GLOBAL_EnableMicrosoftCodeAnalysis true
    VS_GLOBAL_EnableClangTidyCodeAnalysis false
)

target_include_directories(${PROJECT_NAME} PUBLIC
    "cpp/include/"
    "cpp/src/"
    )

    set_target_properties(${PROJECT_NAME} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY_DEBUG "${PROJECT_SOURCE_DIR}/Tools"
    RUNTIME_OUTPUT_DIRECTORY_RELEASE "${PROJECT_SOURCE_DIR}/Tools"
)

set(CMAKE_CONFIGURATION_TYPES "Release;Debug" CACHE STRING "" FORCE)
mark_as_advanced(CMAKE_CONFIGURATION_TYPES)