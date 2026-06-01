load("//tools/proto_rules:proto.bzl", "proto_library")

package(default_visibility = ["//visibility:public"])

proto_library(
    name = "s_curve_planner_config_proto",
    srcs = ["s_curve_planner_config.proto"],
)

cc_proto_library(
    name = "s_curve_planner_config_cc_proto",
    deps = [":s_curve_planner_config_proto"],
)
