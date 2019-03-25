package(default_visibility = ["//tensorboard:internal"])

load("@build_bazel_rules_nodejs//:defs.bzl", "nodejs_binary")

licenses(["notice"])  # Apache 2.0

filegroup(
    name = "tf_web_library_default_typings",
    srcs = [
        # Ordering probably matters.
        "@com_microsoft_typescript//:lib.es6.d.ts",
        "@io_angular_clutz//:src/resources/closure.lib.d.ts",
        "clutz.d.ts",
    ],
    visibility = ["//visibility:public"],
)

exports_files(["web_test_python_stub.template.py"])

nodejs_binary(
    name = "rollup",
    configuration_env_vars = ["ROLLUP_BUNDLE_FIXED_CHUNK_NAMES"],
    entry_point = "rollup_deps/node_modules/rollup/bin/rollup",
    install_source_map_support = False,
    node_modules = "@rollup_deps//:node_modules",
)

