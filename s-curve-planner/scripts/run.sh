#!/bin/bash

# S-Curve Planner Run Script

set -e

echo "========== S-Curve Planner Run Script =========="

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/build"

echo "Project directory: $PROJECT_DIR"

# Check if built
if [ ! -f "$BUILD_DIR/s_curve_planner" ]; then
    echo "Error: s_curve_planner not found. Please run build.sh first."
    exit 1
fi

# Run with arguments
echo "Running S-Curve Planner..."
"$BUILD_DIR/s_curve_planner" "$@"

echo "========== Execution Complete =========="
