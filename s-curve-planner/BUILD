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
        "//proto:s_curve_planner_config_cc_proto",
        "@eigen",
    ],
)

cc_library(
    name = "s_curve_planner",
    srcs = ["plugin_s_curve_planner.cc"],
    hdrs = ["plugin_s_curve_planner.h"],
    copts = ["-DMODULE_NAME=\"s_curve_planner\""],
    deps = [
        ":s_curve_planner_lib",
        "//modules/planning/planning_interface_base/task_base:task",
        "//modules/planning/proto:planning_config_cc_proto",
    ],
    alwayslink = True,
)

install_files(
    src_dir = "conf",
    dst = "etc/apollo/modules/planning/tasks/s_curve_planner",
    files = ["conf/default_conf.pb.txt"],
)

install_files(
    src_dir = "proto",
    dst = "etc/apollo/modules/planning/tasks/s_curve_planner/proto",
    files = ["proto/s_curve_planner_config.proto"],
)

cpplint()
