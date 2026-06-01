# S 弯规划模块

## 📋 项目概述

本项目实现了用于自动驾驶车辆在 S 弯道路场景中的完整规划模块，包括路径规划、障碍物避障、动力学约束处理和速度规划。

### 场景参数

- **道路宽度**: 4.0 ~ 4.2 米
- **前半弯道直径**: 约 30 米
- **后半弯道直径**: 约 22 米
- **主车宽度**: 2.9 米
- **限速**: 30 km/h (8.33 m/s)
- **安全距离**: 0.7 米

## 📁 项目结构

```
s-curve-planner/
├── README.md                                    # 项目说明
├── BUILD                                        # Bazel 编译配置
├── WORKSPACE                                    # Bazel 工作区配置
├── CMakeLists.txt                              # CMake 构建配置
│
├── include/                                     # 头文件
│   ├── common.h                                # 通用数据结构
│   ├── vehicle_model.h                         # 车辆模型
│   ├── path_planner.h                          # 路径规划
│   ├── velocity_planner.h                      # 速度规划
│   ├── obstacle_detector.h                     # 障碍物检测
│   ├── collision_checker.h                     # 碰撞检测
│   └── s_curve_planner.h                       # 主规划器
│
├── src/                                         # 源文件
│   ├── common.cc
│   ├── vehicle_model.cc
│   ├── path_planner.cc
│   ├── velocity_planner.cc
│   ├── obstacle_detector.cc
│   ├── collision_checker.cc
│   ├── s_curve_planner.cc
│   └── main.cc                                 # 演示程序
│
├── proto/                                       # Protocol Buffer 定义
│   ├── BUILD
│   └── s_curve_config.proto                    # 配置数据结构
│
├── conf/                                        # 配置文件
│   └── default_conf.pb.txt                     # 默认配置
│
├── config/                                      # YAML 配置
│   └── s_curve_config.yaml
│
├── test/                                        # 单元测试
│   ├── test_path_planner.cc
│   └── test_collision_checker.cc
│
├── docs/                                        # 文档
│   ├── architecture.md                         # 架构说明
│   ├── module_description.md                   # 模块说明
│   ├── algorithm_explanation.md                # 算法说明
│   ├── usage_guide.md                          # 使用指南
│   └── lane_follow_path_analysis.md            # Apollo 代码分析
│
├── scripts/                                     # 辅助脚本
│   ├── build.sh
│   ├── run.sh
│   ├── visualize.py
│   └── plot_results.py
│
├── plugin_s_curve_planner_description.xml      # 插件描述文件
├── cyberfile.xml                               # 版本信息
└── .gitignore
```

## 🏗️ 系统架构

```
┌─────────────────────────────────────────────────┐
│          S-Curve Planning System                │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌──────────────┐  ┌──────────────┐            │
│  │Path Planning │  │ Velocity     │            │
│  │Module        │  │ Planning     │            │
│  └──────────────┘  └──────────────┘            │
│         │                  │                    │
│         └──────┬───────────┘                    │
│                │                                │
│         ┌──────▼──────┐                         │
│         │ Trajectory  │                         │
│         │ Generation  │                         │
│         └──────┬──────┘                         │
│                │                                │
│  ┌─────────────┼─────────────┐                  │
│  │             │             │                  │
│  ▼             ▼             ▼                  │
│┌────────┐ ┌──────────┐ ┌────────────┐          │
││Obstacle│ │Collision │ │Vehicle     │          │
││Detector│ │Checker   │ │Dynamics    │          │
│└────────┘ └──────────┘ └────────────┘          │
│                                                 │
└─────────────────────────────────────────────────┘
```

## 📦 核心模块

### 1. 通用模块 (common.h/cc)
- 二维/三维点数据结构
- 轨迹点、障碍物、轨迹容器
- 场景配置参数
- 工具函数

### 2. 车辆模型 (vehicle_model.h/cc)
- 自行车运动学模型
- 欧拉法/RK4 积分
- 转向角与曲率转换
- 车辆包络线计算

### 3. 路径规划器 (path_planner.h/cc)
- S 弯参数曲线生成
- Bezier 曲线插值
- 样条曲线插值
- 避障路径生成
- 路径平滑处理

### 4. 速度规划器 (velocity_planner.h/cc)
- 基于曲率的速度规划
- 障碍物感知速度调整
- 加速度/减速度曲线
- 速度平滑处理

### 5. 障碍物检测器 (obstacle_detector.h/cc)
- 障碍物管理
- 路径碰撞检测
- 障碍物位置分类

### 6. 碰撞检测器 (collision_checker.h/cc)
- 轨迹与障碍物碰撞检测
- 轨迹与道路边界碰撞检测
- 最小距离计算

### 7. 主规划器 (s_curve_planner.h/cc)
- 模块整合
- 无障碍规划
- 有障碍规划
- 安全性评估

## 🚀 快速开始

### 使用 CMake 编译

```bash
cd s-curve-planner
mkdir build
cd build
cmake ..
make
```

### 使用 Bazel 编译

```bash
bazel build //s-curve-planner:s_curve_planner
```

### 运行

```bash
./build/s_curve_planner
# 或
bazel run //s-curve-planner:s_curve_planner
```

## 🧪 运行测试

```bash
# CMake 测试
cd build
make test

# Bazel 测试
bazel test //s-curve-planner:all
```

## 📊 配置参数

配置文件位置: `conf/default_conf.pb.txt`

关键参数:
- `road_width`: 道路宽度
- `first_curve_diameter`: 前半弯直径
- `second_curve_diameter`: 后半弯直径
- `vehicle_width`: 车宽
- `max_velocity`: 最大速度
- `safety_margin`: 安全距离

## 🔧 编译系统

本项目支持两种编译系统:

1. **CMake** - 通用 C++ 构建系统
2. **Bazel** - Google 开源构建系统（与 Apollo 兼容）

### BUILD 文件说明

- `cc_library`: 编译 C++ 库
- `cc_binary`: 编译可执行文件
- `cc_test`: 编译测试
- `install_files`: 安装配置文件

## 📚 文档

- [架构设计](docs/architecture.md)
- [模块详解](docs/module_description.md)
- [算法原理](docs/algorithm_explanation.md)
- [使用指南](docs/usage_guide.md)
- [Apollo 代码分析](docs/lane_follow_path_analysis.md)

## 🎯 应用场景

1. **无障碍通过** - 车辆按参考路径平滑通过
2. **弯道中心障碍** - 检测并绕过中心障碍物
3. **弯道外侧障碍** - 保持安全距离通过

## 🔗 依赖

- Eigen3 (矩阵操作)
- Gflags (命令行参数)
- Protobuf (数据序列化)
- CMake >= 3.10
- C++ 17

## 📄 许可证

MIT

## 👥 贡献

欢迎提交 Issue 和 Pull Request！

---

**版本**: 1.0.0  
**最后更新**: 2026-06-01
