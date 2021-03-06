package(default_visibility = ["//tensorboard:internal"])

load("//tensorboard/defs:defs.bzl", "tensorboard_webcomponent_library")
load("//tensorboard/defs:web.bzl", "tf_web_library")

licenses(["notice"])  # Apache 2.0

tf_web_library(
    name = "tf_dashboard_common",
    srcs = [
        "array-update-helper.html",
        "array-update-helper.ts",
        "dashboard-style.html",
        "data-loader-behavior.html",
        "data-loader-behavior.ts",
        "run-color-style.html",
        "scrollbar-style.html",
        "tensorboard-color.html",
        "tf-dashboard-layout.html",
        "tf-downloader.html",
        "tf-dropdown-trigger.html",
        "tf-filterable-checkbox-dropdown.html",
        "tf-filterable-checkbox-dropdown.ts",
        "tf-filterable-checkbox-list.html",
        "tf-filterable-checkbox-list.ts",
        "tf-multi-checkbox.html",
        "tf-multi-checkbox.ts",
        "tf-no-data-warning.html",
        "tf-option-selector.html",
    ],
    path = "/tf-dashboard-common",
    visibility = ["//visibility:public"],
    deps = [
        "//tensorboard/components/tf_backend",
        "//tensorboard/components/tf_color_scale",
        "//tensorboard/components/tf_imports:d3",
        "//tensorboard/components/tf_imports:lodash",
        "//tensorboard/components/tf_imports:polymer",
        "//tensorboard/components/tf_storage",
        "//tensorboard/components/vz_sorting",
        "@org_polymer_iron_ajax",
        "@org_polymer_iron_behaviors",
        "@org_polymer_iron_collapse",
        "@org_polymer_iron_flex_layout",
        "@org_polymer_iron_icon",
        "@org_polymer_iron_icons",
        "@org_polymer_paper_button",
        "@org_polymer_paper_checkbox",
        "@org_polymer_paper_dialog",
        "@org_polymer_paper_dropdown_menu",
        "@org_polymer_paper_icon_button",
        "@org_polymer_paper_input",
        "@org_polymer_paper_item",
        "@org_polymer_paper_menu_button",
        "@org_polymer_paper_menu",
        "@org_polymer_paper_slider",
        "@org_polymer_paper_spinner",
        "@org_polymer_paper_styles",
        "@org_polymer_paper_toggle_button",
    ],
)

tf_web_library(
    name = "demo",
    srcs = [
        "tf-multi-checkbox-demo.html",
    ],
    path = "/tf-dashboard-common",
    deps = [
        ":tf_dashboard_common",
        "//tensorboard/components/tf_color_scale",
        "@org_polymer_iron_demo_helpers",
        "@org_polymer_paper_styles",
    ],
)

tensorboard_webcomponent_library(
    name = "legacy",
    srcs = [":tf_dashboard_common"],
    destdir = "tf-dashboard-common",
    deps = [
        "//tensorboard/components/tf_imports_google:lib",
        "//tensorboard/components/tf_storage:legacy",
        "//tensorboard/components/vz_sorting:legacy",
        "//third_party/javascript/polymer/v1/iron-ajax:lib",
        "//third_party/javascript/polymer/v1/iron-collapse:lib",
        "//third_party/javascript/polymer/v1/iron-icons:lib",
        "//third_party/javascript/polymer/v1/paper-button:lib",
        "//third_party/javascript/polymer/v1/paper-checkbox:lib",
        "//third_party/javascript/polymer/v1/paper-dialog:lib",
        "//third_party/javascript/polymer/v1/paper-dropdown-menu:lib",
        "//third_party/javascript/polymer/v1/paper-icon-button:lib",
        "//third_party/javascript/polymer/v1/paper-input:lib",
        "//third_party/javascript/polymer/v1/paper-item:lib",
        "//third_party/javascript/polymer/v1/paper-menu:lib",
        "//third_party/javascript/polymer/v1/paper-slider:lib",
        "//third_party/javascript/polymer/v1/paper-spinner:lib",
        "//third_party/javascript/polymer/v1/paper-styles:lib",
        "//third_party/javascript/polymer/v1/paper-toggle-button:lib",
        "//third_party/javascript/polymer/v1/polymer:lib",
    ],
)
