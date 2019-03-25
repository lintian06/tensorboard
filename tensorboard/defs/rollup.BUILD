load("@build_bazel_rules_nodejs//:defs.bzl", "nodejs_binary")


nodejs_binary(
    name = "rollup",
    configuration_env_vars = ["ROLLUP_BUNDLE_FIXED_CHUNK_NAMES"],
    entry_point = "rollup_deps/node_modules/rollup/bin/rollup",
    install_source_map_support = False,
    node_modules = "@rollup_deps//:node_modules",
)

