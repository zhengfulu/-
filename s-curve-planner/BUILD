load("//tools:cpplint.bzl", "cpplint")
load("//tools:install_rules.bzl", "install_files")

package(default_visibility = ["//visibility:public"])

cc_library(
    name = "s_curve_planner_lib",
    srcs = [
        "src/s_curve_planner.cc",
        "src/path_planner.cc",
        "src/velocity_planner.cc",
        "src/vehicle_model.cc",
        "src/obstacle_detector.cc",
        "src/collision_checker.cc",
        "src/common.cc",
    ],
    hdrs = [
        "include/s_curve_planner.h",
        "include/path_planner.h",
        "include/velocity_planner.h",
        "include/vehicle_model.h",
        "include/obstacle_detector.h",
        "include/collision_checker.h",
        "include/common.h",
    ],
    copts = ["-DMODULE_NAME=\"s_curve_planner\""],
    deps = [
        "//modules/common/proto:pnc_point_cc_proto",
        "//modules/planning/proto:planning_config_cc_proto",
        "@com_github_gflags_gflags//:gflags",
        "@eigen",
    ],
)

cc_binary(
    name = "s_curve_planner",
    srcs = ["src/main.cc"],
    deps = [":s_curve_planner_lib"],
)

cc_test(
    name = "s_curve_planner_test",
    srcs = ["test/test_path_planner.cc"],
    deps = [
        ":s_curve_planner_lib",
        "@com_google_googletest//:gtest_main",
    ],
)

cc_test(
    name = "collision_checker_test",
    srcs = ["test/test_collision_checker.cc"],
    deps = [
        ":s_curve_planner_lib",
        "@com_google_googletest//:gtest_main",
    ],
)

install_files(
    src_dir = "config",
    dst = "etc/s-curve-planner",
    files = ["config/s_curve_config.yaml"],
)

cpplint()
