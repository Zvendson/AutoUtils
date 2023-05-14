@echo off
cd ..
cmake --build cpp/build --config Debug
cmake --build cpp/build --config Release
PAUSE