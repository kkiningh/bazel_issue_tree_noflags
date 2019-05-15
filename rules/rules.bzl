load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")

_CPP = """
static_assert(__cplusplus >= 201701L, "Compiled as C++11");
"""

def _compile(ctx, src):
    cc_toolchain = find_cpp_toolchain(ctx)
    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.features,
        unsupported_features = ctx.disabled_features,
    )

    compilation_context, compilation_outputs = cc_common.compile(
        name = ctx.label.name,
        actions = ctx.actions,
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        srcs = [src],
        compilation_contexts = [],
    )

    return [DefaultInfo(
        files = depset(compilation_outputs.object_files(use_pic = False)),
    )]

def _make_cpp_tree(ctx):
    src = ctx.actions.declare_directory(ctx.label.name)
    ctx.actions.run_shell(
        command = "mkdir -p {out} && echo '{cpp}' > {out}/test.cpp".format(
            out = src.path,
            cpp = _CPP,
        ),
        outputs = [src],
    )
    return _compile(ctx, src)

make_cpp_tree = rule(
    attrs = {
        "_cc_toolchain": attr.label(
            default = Label("@bazel_tools//tools/cpp:current_cc_toolchain"),
        ),
    },
    toolchains = ["@bazel_tools//tools/cpp:toolchain_type"],
    fragments = ["cpp"],
    implementation = _make_cpp_tree,
)

def _make_cpp(ctx):
    src = ctx.actions.declare_file(ctx.label.name + ".cpp")
    ctx.actions.run_shell(
        command = "echo '{cpp}' > {out}".format(
            out = src.path,
            cpp = _CPP,
        ),
        outputs = [src],
    )
    return _compile(ctx, src)

make_cpp = rule(
    attrs = {
        "_cc_toolchain": attr.label(
            default = Label("@bazel_tools//tools/cpp:current_cc_toolchain"),
        ),
    },
    toolchains = ["@bazel_tools//tools/cpp:toolchain_type"],
    fragments = ["cpp"],
    implementation = _make_cpp,
)
