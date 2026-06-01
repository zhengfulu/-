# Apollo S-Curve Planner 集成部署脚本

#!/bin/bash

set -e

echo "========== Apollo S-Curve Planner Integration Script =========="

# 检查 Apollo 环境
if [ -z "$APOLLO_ROOT_DIR" ]; then
    echo "Error: APOLLO_ROOT_DIR is not set"
    echo "Please source the Apollo environment: source apollo/scripts/apollo_base.sh"
    exit 1
fi

echo "Apollo root directory: $APOLLO_ROOT_DIR"

# 复制模块文件
echo "Copying S-Curve Planner module to Apollo..."
mkdir -p "$APOLLO_ROOT_DIR/modules/planning/tasks/s_curve_planner"
cp -r . "$APOLLO_ROOT_DIR/modules/planning/tasks/s_curve_planner/"

echo "Module copied successfully"

# 编译
echo "Building S-Curve Planner with Apollo..."
cd "$APOLLO_ROOT_DIR"
bazel build //modules/planning/tasks/s_curve_planner:all

echo "========== Integration Complete =========="
echo "Next steps:"
echo "1. Update planning config: apollo/modules/planning/conf/planning_config.pb.txt"
echo "2. Run tests: bazel test //modules/planning/tasks/s_curve_planner:all"
echo "3. Test with Dreamview: bash scripts/dreamview.sh"
