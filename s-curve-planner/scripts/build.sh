#!/bin/bash

# S-Curve Planner Build Script

set -e

echo "========== S-Curve Planner Build Script =========="

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "Project directory: $PROJECT_DIR"

# Parse arguments
BUILD_TYPE="Release"
BUILD_TESTS="ON"
USE_BAZEL="OFF"

while [[ $# -gt 0 ]]; do
    case $1 in
        --debug)
            BUILD_TYPE="Debug"
            shift
            ;;
        --release)
            BUILD_TYPE="Release"
            shift
            ;;
        --no-tests)
            BUILD_TESTS="OFF"
            shift
            ;;
        --bazel)
            USE_BAZEL="ON"
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --debug          Build with debug symbols"
            echo "  --release        Build optimized release (default)"
            echo "  --no-tests       Skip building tests"
            echo "  --bazel          Use Bazel instead of CMake"
            echo "  --help           Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [ "$USE_BAZEL" = "ON" ]; then
    echo "Building with Bazel..."
    cd "$PROJECT_DIR"
    bazel build --compilation_mode=${BUILD_TYPE,,} //...
else
    echo "Building with CMake..."
    
    # Create build directory
    BUILD_DIR="$PROJECT_DIR/build"
    if [ -d "$BUILD_DIR" ]; then
        rm -rf "$BUILD_DIR"
    fi
    mkdir -p "$BUILD_DIR"
    
    cd "$BUILD_DIR"
    
    # Configure CMake
    echo "Configuring CMake with BUILD_TYPE=$BUILD_TYPE..."
    cmake -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
          -DENABLE_TESTS="$BUILD_TESTS" \
          -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
          ..
    
    # Build
    echo "Building..."
    make -j$(nproc)
    
    # Run tests if enabled
    if [ "$BUILD_TESTS" = "ON" ]; then
        echo "Running tests..."
        ctest --output-on-failure
    fi
fi

echo "========== Build Complete =========="
