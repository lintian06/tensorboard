load("@build_bazel_rules_nodejs//internal/common:collect_es6_sources.bzl", _collect_es2015_sources = "collect_es6_sources")
load("@build_bazel_rules_nodejs//internal/rollup:rollup_bundle.bzl", "write_rollup_config", "run_rollup", "run_terser", "rollup_module_mappings_aspect", "collect_node_modules_aspect")

def _rollup_bundle(ctx):

    rollup_config = write_rollup_config(ctx,
       plugins = [
          "require('rollup-plugin-replace')({'process.env.NODE_ENV': JSON.stringify('production')})",
       ],
    )
    # rollup_config = write_rollup_config(ctx)
    run_rollup(ctx, _collect_es2015_sources(ctx), rollup_config, ctx.outputs.build_es5)
    source_map = run_terser(ctx, ctx.outputs.build_es5, ctx.outputs.build_es5_min)
    files = [ctx.outputs.build_es5_min, source_map]

    return DefaultInfo(files = depset(files), runfiles = ctx.runfiles(files))

# Expose our list of aspects so derivative rules can override the deps attribute and
# add their own additional aspects.
# If users are in a different repo and load the aspect themselves, they will create
# different Provider symbols (e.g. NodeModuleInfo) and we won't find them.
# So users must use these symbols that are load'ed in rules_nodejs.
ROLLUP_DEPS_ASPECTS = [rollup_module_mappings_aspect, collect_node_modules_aspect]

ROLLUP_ATTRS = {
    "srcs": attr.label_list(
        doc = """JavaScript source files from the workspace.
        These can use ES2015 syntax and ES Modules (import/export)""",
        allow_files = [".js"],
    ),
    "additional_entry_points": attr.string_list(
        doc = """Additional entry points of the application for code splitting, passed as the input to rollup.
        These should be a path relative to the workspace root.
        When additional_entry_points are specified, rollup_bundle
        will split the bundle in multiple entry points and chunks.
        There will be a main entry point chunk as well as entry point
        chunks for each additional_entry_point. The file names
        of these entry points will correspond to the file names
        specified in entry_point and additional_entry_points.
        There will also be one or more common chunks that are shared
        between entry points named chunk-<HASH>.js. The number
        of common chunks is variable depending on the code being
        bundled.
        Entry points and chunks will be outputted to folders:
        - <label-name>_chunks_es2015 // es2015
        - <label-name>_chunks // es5
        - <label-name>_chunks_min // es5 minified
        - <label-name>_chunks_min_debug // es5 minified debug
        The following files will be outputted that contain the
        SystemJS boilerplate to map the entry points to their file
        names and load the main entry point:
        flavors:
        - <label-name>.es2015.js // es2015 with EcmaScript modules
        - <label-name>.js // es5 syntax with CJS modules
        - <label-name>.min.js // es5 minified
        - <label-name>.min_debug.js // es5 minified debug
        NOTE: additional_entry_points MUST be in the same folder or deeper than
        the main entry_point for the SystemJS boilerplate/entry point to
        be valid. For example, if the main entry_point is
        `src/main` then all additional_entry_points must be under
        `src/**` such as `src/bar` or `src/foo/bar`. Alternate
        additional_entry_points configurations are valid but the
        SystemJS boilerplate/entry point files will not be usable and
        it is up to the user in these cases to handle the SystemJS
        boilerplate manually.
        It is sufficient to load one of these SystemJS boilerplate/entry point
        files as a script in your HTML to load your application""",
    ),
    "entry_point": attr.string(
        doc = """The starting point of the application, passed as the `--input` flag to rollup.
        This should be a path relative to the workspace root.
        """,
        mandatory = True,
    ),
    "global_name": attr.string(
        doc = """A name given to this package when referenced as a global variable.
        This name appears in the bundle module incantation at the beginning of the file,
        and governs the global symbol added to the global context (e.g. `window`) as a side-
        effect of loading the UMD/IIFE JS bundle.
        Rollup doc: "The variable name, representing your iife/umd bundle, by which other scripts on the same page can access it."
        This is passed to the `output.name` setting in Rollup.""",
    ),
    "globals": attr.string_dict(
        doc = """A dict of symbols that reference external scripts.
        The keys are variable names that appear in the program,
        and the values are the symbol to reference at runtime in a global context (UMD bundles).
        For example, a program referencing @angular/core should use ng.core
        as the global reference, so Angular users should include the mapping
        `"@angular/core":"ng.core"` in the globals.""",
        default = {},
    ),
    "license_banner": attr.label(
        doc = """A .txt file passed to the `banner` config option of rollup.
        The contents of the file will be copied to the top of the resulting bundles.
        Note that you can replace a version placeholder in the license file, by using
        the special version `0.0.0-PLACEHOLDER`. See the section on stamping in the README.""",
        allow_single_file = [".txt"],
    ),
    "node_modules": attr.label(
        doc = """Dependencies from npm that provide some modules that must be
        resolved by rollup.
        This attribute is DEPRECATED. As of version 0.13.0 the recommended approach
        to npm dependencies is to use fine grained npm dependencies which are setup
        with the `yarn_install` or `npm_install` rules. For example, in a rollup_bundle
        target that used the `node_modules` attribute,
        ```
        rollup_bundle(
          name = "bundle",
          ...
          node_modules = "//:node_modules",
        )
        ```
        which specifies all files within the `//:node_modules` filegroup
        to be inputs to the `bundle`. Using fine grained npm dependencies,
        `bundle` is defined with only the npm dependencies that are
        needed:
        ```
        rollup_bundle(
          name = "bundle",
          ...
          deps = [
              "@npm//foo",
              "@npm//bar",
              ...
          ],
        )
        ```
        In this case, only the `foo` and `bar` npm packages and their
        transitive deps are includes as inputs to the `bundle` target
        which reduces the time required to setup the runfiles for this
        target (see https://github.com/bazelbuild/bazel/issues/5153).
        The @npm external repository and the fine grained npm package
        targets are setup using the `yarn_install` or `npm_install` rule
        in your WORKSPACE file:
        yarn_install(
          name = "npm",
          package_json = "//:package.json",
          yarn_lock = "//:yarn.lock",
        )
        """,
        default = Label("@build_bazel_rules_nodejs//:node_modules_none"),
    ),
    "deps": attr.label_list(
        doc = """Other rules that produce JavaScript outputs, such as `ts_library`.""",
        aspects = ROLLUP_DEPS_ASPECTS,
    ),
    "_no_explore_html": attr.label(
        default = Label("@build_bazel_rules_nodejs//internal/rollup:no_explore.html"),
        allow_single_file = True,
    ),
    "_rollup": attr.label(
        executable = True,
        cfg = "host",
        default = Label("//tensorboard/defs:rollup"),
    ),
    "_rollup_config_tmpl": attr.label(
        default = Label("@build_bazel_rules_nodejs//internal/rollup:rollup.config.js"),
        allow_single_file = True,
    ),
    "_source_map_explorer": attr.label(
        executable = True,
        cfg = "host",
        default = Label("@build_bazel_rules_nodejs//internal/rollup:source-map-explorer"),
    ),
    "_system_config_tmpl": attr.label(
        default = Label("@build_bazel_rules_nodejs//internal/rollup:system.config.js"),
        allow_single_file = True,
    ),
    "_terser_wrapped": attr.label(
        executable = True,
        cfg = "host",
        default = Label("@build_bazel_rules_nodejs//internal/rollup:terser-wrapped"),
    ),
    "_tsc": attr.label(
        executable = True,
        cfg = "host",
        default = Label("@build_bazel_rules_nodejs//internal/rollup:tsc"),
    ),
    "_tsc_directory": attr.label(
        executable = True,
        cfg = "host",
        default = Label("@build_bazel_rules_nodejs//internal/rollup:tsc-directory"),
    ),
}

ROLLUP_OUTPUTS = {
    "build_es5": "%{name}.js",
    "build_es5_min": "%{name}.min.js",
}

rollup_bundle = rule(
    implementation = _rollup_bundle,
    attrs = ROLLUP_ATTRS,
    outputs = ROLLUP_OUTPUTS,
)

