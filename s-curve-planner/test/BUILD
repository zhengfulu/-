load("//tools:cpplint.bzl", "cpplint")

package(default_visibility = ["//visibility:public"])

cc_test(
    name = "s_curve_planner_test",
    srcs = ["s_curve_planner_test.cc"],
    deps = [
        "//modules/planning/tasks/s_curve_planner:s_curve_planner_lib",
        "@com_google_googletest//:gtest_main",
    ],
)

cpplint()
