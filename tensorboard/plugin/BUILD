package(default_visibility = ["//tensorboard:internal"])

load("//tensorboard/defs:defs.bzl", "tensorboard_webcomponent_library")
load("//tensorboard/defs:web.bzl", "tf_web_library")
load("@npm_bazel_typescript//:index.bzl", "ts_library")
load("@build_bazel_rules_nodejs//:defs.bzl", "rollup_bundle")

licenses(["notice"])  # Apache 2.0

tf_web_library(
    name = "plugin_host",
    srcs = [
        "plugin-host.html",
        "plugin-host.ts",
        "message.ts",
    ],
    path = "/tf-plugin-host",
    deps = [
        "//tensorboard/components/tf_backend",
    ],
)

tf_web_library(
    name = "plugin_guest",
    srcs = [
        "plugin-guest.html",
        "plugin-guest.ts",
    ],
    path = "/tf-plugin-guest",
    visibility = ["//visibility:public"],
    deps = [
    ],
)

ts_library(
    name = "plugin_guest_ts",
    srcs = [
        "plugin-guest.ts",
        "message.ts",
    ],
)

ts_library(
    name = "plugin_guest_tsts",
    srcs = [
        "plugin-guest.ts",
    ],
    deps = [
        ":message_ts",
    ],
)

ts_library(
    name = "message_ts",
    srcs = [
        "message.ts",
    ],
)

rollup_bundle(
    name = "guest_lib",
    entry_point = "tensorboard/plugin/plugin-guest",
    deps = [":plugin-guest"],
)

