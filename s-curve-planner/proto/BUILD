load("//tools:proto_rules.bzl", "proto_library")

package(default_visibility = ["//visibility:public"])

proto_library(
    name = "s_curve_config_proto",
    srcs = ["s_curve_config.proto"],
    deps = [],
)

cc_proto_library(
    name = "s_curve_config_cc_proto",
    deps = [":s_curve_config_proto"],
)

py_proto_library(
    name = "s_curve_config_py_proto",
    deps = [":s_curve_config_proto"],
)
