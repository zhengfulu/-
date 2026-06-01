# S-Curve Planner Apollo 集成指南

## 📋 集成概述

本指南详细说明如何将 S-Curve Planner 模块集成到 Apollo 自动驾驶平台中，并确保其在实际场景中的稳定运行。

## 🏗️ 集成架构

```
Apollo Planning Module
├── Lane Follow Path (原有模块)
├── S-Curve Planner (新集成模块) ← 你的模块
│   ├── Path Planning Task
│   ├── Velocity Planning Task
│   ├── Collision Checking Task
│   └── Safety Validation Task
└── Other Planning Tasks

Pipeline:
Frame Input → Reference Line Info → S-Curve Planner → Trajectory Output
```

## 📁 Apollo 项目结构中的位置

```
apollo/
├── modules/
│   ├── planning/
│   │   ├── planning_base/
│   │   ├── planning_interface_base/
│   │   ├── tasks/
│   │   │   ├── lane_follow_path/
│   │   │   ├── speed_bounds_priori_decider/
│   │   │   └── s_curve_planner/  ← 集成位置
│   │   │       ├── BUILD
│   │   │       ├── s_curve_planner.h/.cc
│   │   │       ├── path_planner.h/.cc
│   │   │       ├── velocity_planner.h/.cc
│   │   │       ├── vehicle_model.h/.cc
│   │   │       ├── obstacle_detector.h/.cc
│   │   │       ├── collision_checker.h/.cc
│   │   │       ├── common.h/.cc
│   │   │       ├── conf/
│   │   │       │   └── default_conf.pb.txt
│   │   │       ├── proto/
│   │   │       │   ├── BUILD
│   │   │       │   └── s_curve_planner_config.proto
│   │   │       ├── test/
│   │   │       │   ├── s_curve_planner_test.cc
│   │   │       │   └── BUILD
│   │   │       ├── plugin_s_curve_planner.cc  ← 插件实现
│   │   │       └── cyberfile.xml
│   │   ├── scenarios/
│   │   │   └── s_curve/  ← 可选：场景定义
│   │   │       ├── BUILD
│   │   │       └── s_curve_stage.cc/.h
│   │   └── conf/
│   │       └── scenario.conf  ← 场景配置
│   └── common/
└── tools/
```

## 🔧 步骤 1: 准备 Apollo 环境

### 1.1 克隆 Apollo

```bash
# 克隆 Apollo 仓库
git clone https://github.com/ApolloAuto/apollo.git
cd apollo

# 切换到稳定分支 (推荐 9.0 或更新)
git checkout release-9.0.0
```

### 1.2 安装依赖

```bash
# 使用 Apollo 提供的 Docker 环境
bash docker/build_docker.sh apollo_dev:dev9.0

# 或者手动安装依赖
bash apollo.sh build
```

## 📦 步骤 2: 集成 S-Curve Planner 模块

### 2.1 复制模块文件到 Apollo

```bash
# 在 Apollo 仓库中创建目录
mkdir -p apollo/modules/planning/tasks/s_curve_planner
cd apollo/modules/planning/tasks/s_curve_planner

# 从你的仓库复制文件
cp -r /path/to/s-curve-planner/* .
```

### 2.2 更新 BUILD 文件 (Apollo 兼容版本)

创建 `apollo/modules/planning/tasks/s_curve_planner/BUILD`：

```python
load("//tools:cpplint.bzl", "cpplint")
load("//tools:install_rules.bzl", "install_files")
load("//tools/proto_rules:proto.bzl", "proto_library")

package(default_visibility = ["//visibility:public"])

proto_library(
    name = "s_curve_planner_config_proto",
    srcs = ["proto/s_curve_planner_config.proto"],
)

cc_proto_library(
    name = "s_curve_planner_config_cc_proto",
    deps = [":s_curve_planner_config_proto"],
)

cc_library(
    name = "s_curve_planner_lib",
    srcs = [
        "src/common.cc",
        "src/vehicle_model.cc",
        "src/path_planner.cc",
        "src/velocity_planner.cc",
        "src/obstacle_detector.cc",
        "src/collision_checker.cc",
        "src/s_curve_planner.cc",
    ],
    hdrs = [
        "include/common.h",
        "include/vehicle_model.h",
        "include/path_planner.h",
        "include/velocity_planner.h",
        "include/obstacle_detector.h",
        "include/collision_checker.h",
        "include/s_curve_planner.h",
    ],
    copts = ["-DMODULE_NAME=\"s_curve_planner\""],
    deps = [
        ":s_curve_planner_config_cc_proto",
        "//modules/common/proto:pnc_point_cc_proto",
        "//modules/planning/proto:planning_config_cc_proto",
        "//modules/planning/planning_interface_base/task_base:task_base",
        "@eigen",
    ],
)

cc_library(
    name = "s_curve_planner",
    srcs = ["plugin_s_curve_planner.cc"],
    hdrs = ["plugin_s_curve_planner.h"],
    copts = ["-DMODULE_NAME=\"s_curve_planner\""],
    deps = [":s_curve_planner_lib"],
    alwayslink = True,
)

cc_test(
    name = "s_curve_planner_test",
    srcs = ["test/s_curve_planner_test.cc"],
    deps = [
        ":s_curve_planner_lib",
        "@com_google_googletest//:gtest_main",
    ],
)

install_files(
    src_dir = "conf",
    dst = "etc/apollo/modules/planning/tasks/s_curve_planner",
    files = ["conf/default_conf.pb.txt"],
)

cpplint()
```

## 🔌 步骤 3: 创建 Apollo 插件实现

### 3.1 创建插件头文件

创建 `plugin_s_curve_planner.h`：

```cpp
#pragma once

#include "modules/planning/planning_interface_base/task_base/common/path_generation.h
#include "modules/planning/planning_interface_base/task_base/task.h"
#include "modules/planning/proto/planning_config.pb.h"
#include "modules/planning/tasks/s_curve_planner/s_curve_planner.h"

namespace apollo {
namespace planning {

/**
 * @class SCurvePlannerTask
 * @brief S-Curve Path Planning Task for Apollo
 */
class SCurvePlannerTask : public Task {
 public:
  bool Init(const std::string& config_dir,
            const std::string& name,
            const std::shared_ptr<DependencyInjector>& injector) override;

  apollo::common::Status Process(Frame* frame,
                                  ReferenceLineInfo* reference_line_info) override;

 private:
  std::unique_ptr<SCurvePlanner> planner_;
  SCurvePlannerConfig config_;

  // Helper methods
  bool CheckScenarioApplicability(const ReferenceLineInfo& ref_line_info);
  bool ValidateTrajectory(const Trajectory& trajectory,
                         const ReferenceLineInfo& ref_line_info);
};

}  // namespace planning
}  // namespace apollo
```

### 3.2 创建插件实现

创建 `plugin_s_curve_planner.cc`：

```cpp
#include "modules/planning/tasks/s_curve_planner/plugin_s_curve_planner.h"

#include "cyber/plugin_manager/plugin_manager.h"
#include "modules/common/configs/vehicle_config_helper.h"
#include "modules/planning/proto/planning_config.pb.h"

namespace apollo {
namespace planning {

using apollo::common::Status;
using apollo::common::VehicleConfigHelper;

bool SCurvePlannerTask::Init(
    const std::string& config_dir,
    const std::string& name,
    const std::shared_ptr<DependencyInjector>& injector) {
  if (!Task::Init(config_dir, name, injector)) {
    return false;
  }

  // Load S-Curve Planner configuration
  if (!apollo::cyber::common::GetProtoFromFile(
          apollo::cyber::common::GetAbsolutePath(
              config_dir, "s_curve_planner_config.pb.txt"),
          &config_)) {
    AERROR << "Failed to load s_curve_planner_config.pb.txt";
    return false;
  }

  // Initialize the planner
  ScenarioConfig scenario_config;
  scenario_config.road_width = config_.road_width();
  scenario_config.vehicle_width = config_.vehicle_width();
  scenario_config.vehicle_length = config_.vehicle_length();
  scenario_config.wheelbase = config_.wheelbase();
  scenario_config.max_steer_angle = config_.max_steer_angle();
  scenario_config.max_acceleration = config_.max_acceleration();
  scenario_config.max_deceleration = config_.max_deceleration();
  scenario_config.max_velocity = config_.max_velocity();
  scenario_config.max_curvature = config_.max_curvature();
  scenario_config.safety_margin = config_.safety_margin();
  scenario_config.path_resolution = config_.path_resolution();
  scenario_config.time_resolution = config_.time_resolution();

  planner_ = std::make_unique<SCurvePlanner>(scenario_config);

  if (!planner_->initialize()) {
    AERROR << "Failed to initialize S-Curve Planner";
    return false;
  }

  AINFO << "S-Curve Planner Task initialized successfully";
  return true;
}

Status SCurvePlannerTask::Process(
    Frame* frame,
    ReferenceLineInfo* reference_line_info) {
  // 1. Check if scenario is applicable
  if (!CheckScenarioApplicability(*reference_line_info)) {
    ADEBUG << "S-Curve scenario not applicable, skipping";
    return Status::OK();
  }

  // 2. Skip if path already exists
  if (!reference_line_info->path_data().empty() &&
      reference_line_info->path_reusable()) {
    ADEBUG << "Path already exists and is reusable, skipping";
    return Status::OK();
  }

  // 3. Extract obstacles from frame
  std::vector<Obstacle> obstacles;
  for (const auto& obstacle : reference_line_info->path_decision()->obstacles().Items()) {
    Obstacle obs;
    obs.center = Point2D(obstacle->PerceptionBBox().center_x(),
                        obstacle->PerceptionBBox().center_y());
    obs.width = obstacle->PerceptionBBox().width();
    obs.length = obstacle->PerceptionBBox().length();
    obs.is_dynamic = !obstacle->IsStatic();
    obstacles.push_back(obs);
  }

  // 4. Plan trajectory
  VehicleModel::State initial_state;
  initial_state.x = reference_line_info->AdcSlBoundary().start_s();
  initial_state.y = reference_line_info->AdcSlBoundary().start_l();
  initial_state.theta = 0.0;  // Will be determined from vehicle state
  initial_state.v = frame->vehicle_state().linear_velocity();
  initial_state.delta = frame->vehicle_state().steering_angle();

  planner_->setInitialState(initial_state);

  Trajectory trajectory = planner_->plan(obstacles);

  // 5. Validate trajectory
  if (!trajectory.is_feasible) {
    AWARN << "Generated trajectory is not feasible";
    return Status(apollo::common::ErrorCode::PLANNING_ERROR,
                  "S-Curve planner generated infeasible trajectory");
  }

  if (!ValidateTrajectory(trajectory, *reference_line_info)) {
    AWARN << "Generated trajectory failed validation";
    return Status(apollo::common::ErrorCode::PLANNING_ERROR,
                  "S-Curve planner trajectory failed validation");
  }

  // 6. Convert to Apollo PathData
  PathData path_data;
  // TODO: Convert from internal trajectory format to Apollo PathData
  // This requires mapping the trajectory points to Apollo's data structures

  reference_line_info->set_path_data(path_data);

  AINFO << "S-Curve Planner generated path with "
        << trajectory.points.size() << " points";

  return Status::OK();
}

bool SCurvePlannerTask::CheckScenarioApplicability(
    const ReferenceLineInfo& ref_line_info) {
  // Check if this is an S-curve scenario
  // Criteria: High curvature road section
  
  const ReferenceLine& ref_line = ref_line_info.reference_line();
  double total_curvature = 0.0;
  int point_count = 0;
  double curvature_threshold = 0.03;

  for (double s = 0; s < 50.0; s += 1.0) {
    auto ref_point = ref_line.GetNearestReferencePoint(s);
    if (std::abs(ref_point.kappa()) > curvature_threshold) {
      point_count++;
    }
    total_curvature += std::abs(ref_point.kappa());
  }

  // Consider it an S-curve if > 20% of points have high curvature
  return (point_count * 100 / 50) > 20;
}

bool SCurvePlannerTask::ValidateTrajectory(
    const Trajectory& trajectory,
    const ReferenceLineInfo& ref_line_info) {
  // 1. Check trajectory length
  if (trajectory.total_length < 10.0 || trajectory.total_length > 200.0) {
    AWARN << "Trajectory length out of bounds: " << trajectory.total_length;
    return false;
  }

  // 2. Check path continuity
  for (size_t i = 1; i < trajectory.points.size(); i++) {
    double distance = std::hypot(
        trajectory.points[i].pose.x - trajectory.points[i-1].pose.x,
        trajectory.points[i].pose.y - trajectory.points[i-1].pose.y);
    
    if (distance > 1.0) {  // 1 meter max gap
      AWARN << "Path discontinuity detected";
      return false;
    }
  }

  // 3. Check velocity profile
  for (const auto& point : trajectory.points) {
    if (point.v < 0 || point.v > config_.max_velocity()) {
      AWARN << "Velocity out of bounds: " << point.v;
      return false;
    }
  }

  // 4. Check acceleration profile
  for (size_t i = 1; i < trajectory.points.size(); i++) {
    double delta_v = trajectory.points[i].v - trajectory.points[i-1].v;
    double delta_t = trajectory.points[i].t - trajectory.points[i-1].t;
    if (delta_t > 0) {
      double acc = delta_v / delta_t;
      if (std::abs(acc) > config_.max_acceleration()) {
        AWARN << "Acceleration out of bounds: " << acc;
        return false;
      }
    }
  }

  return true;
}

}  // namespace planning
}  // namespace apollo

CYBER_PLUGIN_MANAGER_REGISTER_PLUGIN(
    apollo::planning::SCurvePlannerTask, apollo::planning::Task)
```

## ⚙️ 步骤 4: 配置文件

### 4.1 创建 Proto 配置 (修改)

创建 `proto/s_curve_planner_config.proto`：

```protobuf
syntax = "proto2";

package apollo.planning;

message SCurvePlannerConfig {
  // Road configuration
  optional double road_width = 1 [default = 4.1];
  optional double s_curve_length = 2 [default = 80.0];
  
  // Vehicle configuration
  optional double vehicle_width = 10 [default = 2.9];
  optional double vehicle_length = 11 [default = 5.2];
  optional double wheelbase = 12 [default = 2.7];
  optional double max_steer_angle = 13 [default = 0.436];
  optional double max_acceleration = 14 [default = 3.0];
  optional double max_deceleration = 15 [default = 3.5];
  
  // Planning parameters
  optional double max_velocity = 20 [default = 8.33];
  optional double max_curvature = 21 [default = 0.15];
  optional double safety_margin = 23 [default = 0.7];
  optional double path_resolution = 30 [default = 0.1];
  optional double time_resolution = 31 [default = 0.05];
  
  // Debug parameters
  optional bool enable_logging = 50 [default = true];
  optional bool enable_visualization = 51 [default = false];
}
```

### 4.2 创建默认配置

创建 `conf/default_conf.pb.txt`：

```
road_width: 4.1
s_curve_length: 80.0
vehicle_width: 2.9
vehicle_length: 5.2
wheelbase: 2.7
max_steer_angle: 0.436
max_acceleration: 3.0
max_deceleration: 3.5
max_velocity: 8.33
max_curvature: 0.15
safety_margin: 0.7
path_resolution: 0.1
time_resolution: 0.05
enable_logging: true
enable_visualization: false
```

## 🔧 步骤 5: 场景配置

### 5.1 更新 Planning 配置

修改 `apollo/modules/planning/conf/planning_config.pb.txt`：

```protobuf
# 添加 S-Curve Planner task
stage: {
  name: "S_CURVE_PLANNING_STAGE"
  type: "SCurvePlannerStage"
  enabled: true
  task {
    name: "S_CURVE_PLANNER"
    type: "SCurvePlannerTask"
  }
}
```

### 5.2 创建场景配置 (可选)

创建 `scenarios/s_curve/s_curve_scenario.cc`：

```cpp
// S-Curve specific scenario handling
// This triggers the S-Curve planner when appropriate conditions are met
```

## 🧪 步骤 6: 测试

### 6.1 单元测试

创建 `test/s_curve_planner_test.cc`：

```cpp
#include <gtest/gtest.h>
#include "modules/planning/tasks/s_curve_planner/s_curve_planner.h"

namespace apollo {
namespace planning {

class SCurvePlannerTest : public ::testing::Test {
 protected:
  void SetUp() override {
    config_.road_width = 4.1;
    config_.vehicle_width = 2.9;
    config_.vehicle_length = 5.2;
    config_.wheelbase = 2.7;
    config_.max_velocity = 8.33;
    
    planner_ = std::make_unique<SCurvePlanner>(config_);
  }
  
  ScenarioConfig config_;
  std::unique_ptr<SCurvePlanner> planner_;
};

TEST_F(SCurvePlannerTest, InitializationTest) {
  EXPECT_TRUE(planner_->initialize());
}

TEST_F(SCurvePlannerTest, PathGenerationTest) {
  EXPECT_TRUE(planner_->initialize());
  
  std::vector<Obstacle> obstacles;
  auto trajectory = planner_->plan(obstacles);
  
  EXPECT_TRUE(trajectory.is_feasible);
  EXPECT_GT(trajectory.points.size(), 0);
}

}  // namespace planning
}  // namespace apollo
```

### 6.2 编译测试

```bash
cd apollo
bazel test //modules/planning/tasks/s_curve_planner:s_curve_planner_test
```

### 6.3 集成测试

```bash
# 使用 Apollo 的 Dreamview 进行可视化测试
bash apollo.sh build
bash scripts/dreamview.sh
```

## ⚠️ 稳定性检查清单

### ✅ 内存安全
- [ ] 所有动态分配都使用 unique_ptr/shared_ptr
- [ ] 没有内存泄漏
- [ ] 正确处理边界条件

### ✅ 线程安全
- [ ] 使用互斥锁保护共享数据
- [ ] 避免死锁
- [ ] 异步操作使用消息队列

### ✅ 性能
- [ ] 规划时间 < 100ms (实时要求)
- [ ] 内存使用 < 50MB
- [ ] CPU 使用率 < 25%

### ✅ 容错能力
- [ ] 处理异常输入
- [ ] 优雅降级
- [ ] 错误日志

### ✅ 集成兼容性
- [ ] 与 Apollo 9.0+ 兼容
- [ ] 遵循 Apollo 编码规范
- [ ] 使用 Apollo 提供的接口
- [ ] 正确处理 Proto 消息

## 🚀 部署到生产环境

### 步骤 1: 完整测试

```bash
# 运行所有测试
bazel test //modules/planning/tasks/s_curve_planner:all

# 代码覆盖率检查
bazel coverage //modules/planning/tasks/s_curve_planner:all
```

### 步骤 2: 性能基准

```cpp
// 在测试中添加性能测试
TEST_F(SCurvePlannerTest, PerformanceTest) {
  auto start = std::chrono::high_resolution_clock::now();
  
  for (int i = 0; i < 1000; i++) {
    planner_->plan({});
  }
  
  auto end = std::chrono::high_resolution_clock::now();
  auto duration = std::chrono::duration_cast<std::chrono::milliseconds>
                  (end - start);
  
  double avg_time = duration.count() / 1000.0;
  EXPECT_LT(avg_time, 100.0);  // 100ms limit
}
```

### 步骤 3: 仿真验证

```bash
# 使用 CARLA 或 Apollo 自带的仿真器
bash scripts/simulator.sh
```

### 步骤 4: 灰度发布

1. 在开发环境验证
2. 在测试环境验证
3. 灰度上线 (10% → 50% → 100%)
4. 监控告警设置

## 📊 监控和日志

### 关键指标

```cpp
// 在 S-Curve Planner 中添加指标收集
struct Metrics {
  double planning_time_ms;      // 规划时间
  int trajectory_points;        // 轨迹点数
  double max_acceleration;      // 最大加速度
  double max_curvature;         // 最大曲率
  bool collision_free;          // 是否无碰撞
  std::string failure_reason;   // 失败原因
};
```

### 日志级别

```cpp
AINFO << "S-Curve plan generated: points=" << trajectory.points.size();
AWARN << "Trajectory validation failed: " << reason;
AERROR << "S-Curve planner critical error: " << error;
```

## 🔍 故障排查

### 问题 1: 规划失败
```
原因: 障碍物阻挡或路径过窄
解决: 增加安全距离，尝试避障
```

### 问题 2: 性能下降
```
原因: 过多的轨迹点或复杂算法
解决: 增加采样间隔，优化算法
```

### 问题 3: 轨迹抖动
```
原因: 多次规划结果差异大
解决: 增加轨迹平滑，使用滤波器
```

## 📚 参考资源

- [Apollo Planning Documentation](https://apollo.auto/docs/)
- [Apollo Task Interface](https://github.com/ApolloAuto/apollo/tree/master/modules/planning/planning_interface_base)
- [Proto Buffer Guide](https://developers.google.com/protocol-buffers)
- [Bazel Build System](https://bazel.build/)

---

**最后建议**: 定期对比 Apollo 最新版本的 API 更改，确保向前兼容性。
