#pragma once

#include "modules/planning/planning_interface_base/task_base/common/path_generation.h"
#include "modules/planning/planning_interface_base/task_base/task.h"
#include "modules/planning/proto/planning_config.pb.h"

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

  apollo::common::Status Process(
      Frame* frame,
      ReferenceLineInfo* reference_line_info) override;
};

}  // namespace planning
}  // namespace apollo
