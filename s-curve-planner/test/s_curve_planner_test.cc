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
    config_.safety_margin = 0.7;
    config_.path_resolution = 0.1;
  }
  
  ScenarioConfig config_;
};

TEST_F(SCurvePlannerTest, ConfigInitialization) {
  EXPECT_EQ(config_.road_width, 4.1);
  EXPECT_EQ(config_.vehicle_width, 2.9);
  EXPECT_EQ(config_.wheelbase, 2.7);
}

TEST_F(SCurvePlannerTest, VehicleWidthCheck) {
  EXPECT_LT(config_.vehicle_width, config_.road_width);
}

}  // namespace planning
}  // namespace apollo
