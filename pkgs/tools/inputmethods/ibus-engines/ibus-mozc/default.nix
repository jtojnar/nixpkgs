{ lib
, stdenv
, buildBazelPackage
, bazel_6
, runCommand
, patchutils
, fetchFromGitHub
, fetchgit
, which
, ninja
, pkg-config
, abseil-cpp
, protobuf
, ibus
, gtk2
, zinnia
, qt6
, libxcb
, tegaki-zinnia-japanese
, python3Packages
}:

buildBazelPackage rec {
  pname = "ibus-mozc";
  version = "2.29.5268.102";

  src = fetchFromGitHub {
    owner = "google";
    repo = "mozc";
    rev = "refs/tags/${version}";
    hash = "sha256-B7hG8OUaQ1jmmcOPApJlPVcB8h1Rw06W5LAzlTzI9rU=";
    fetchSubmodules = true;
  };

  # See https://github.com/google/jax/blob/main/.bazelversion for the latest.
  bazel = bazel_6;

  nativeBuildInputs = [
    # which
    # python3Packages.python
    # python3Packages.six
    pkg-config
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    abseil-cpp
    protobuf
    ibus
    gtk2
    zinnia
    qt6.qtbase
    libxcb
  ];

  bazelTargets = [
    "renderer/qt:mozc_renderer"
    "unix/ibus:ibus_mozc unix/icons"
  ];

  targetRunFlags = [
    "--config=oss_linux"
    "--compilation_mode=opt"
    # "--output_path=$out"
    # "--cpu=${arch}"
  ];

  # removeRulesCC = false;

  # GCC_HOST_COMPILER_PREFIX = lib.optionalString cudaSupport "${cudatoolkit_cc_joined}/bin";
  # GCC_HOST_COMPILER_PATH = lib.optionalString cudaSupport "${cudatoolkit_cc_joined}/bin/gcc";

  # # The version is automatically set to ".dev" if this variable is not set.
  # # https://github.com/google/jax/commit/e01f2617b85c5bdffc5ffb60b3d8d8ca9519a1f3
  # JAXLIB_RELEASE = "1";

  postPatch = ''
    # substituteInPlace src/renderer/qt/BUILD.bazel \
    #   --replace '"//bazel:qt.bzl",' ' '
  '';

  preConfigure = ''
    cd src
  '';

  #   # dummy ldconfig
  #   mkdir dummy-ldconfig
  #   echo "#!${stdenv.shell}" > dummy-ldconfig/ldconfig
  #   chmod +x dummy-ldconfig/ldconfig
  #   export PATH="$PWD/dummy-ldconfig:$PATH"
  #   cat <<CFG > ./.jax_configure.bazelrc
  #   build --strategy=Genrule=standalone
  #   build --repo_env PYTHON_BIN_PATH="${python}/bin/python"
  #   build --action_env=PYENV_ROOT
  #   build --python_path="${python}/bin/python"
  #   build --distinct_host_configuration=false
  #   build --define PROTOBUF_INCLUDE_PATH="${pkgs.protobuf}/include"
  # '' + lib.optionalString (stdenv.hostPlatform.avxSupport && stdenv.hostPlatform.isUnix) ''
  #   build --config=avx_posix
  # '' + lib.optionalString mklSupport ''
  #   build --config=mkl_open_source_only
  # '' + lib.optionalString cudaSupport ''
  #   build --action_env CUDA_TOOLKIT_PATH="${cudatoolkit_joined}"
  #   build --action_env CUDNN_INSTALL_PATH="${cudnn}"
  #   build --action_env TF_CUDA_PATHS="${cudatoolkit_joined},${cudnn},${nccl}"
  #   build --action_env TF_CUDA_VERSION="${lib.versions.majorMinor cudatoolkit.version}"
  #   build --action_env TF_CUDNN_VERSION="${lib.versions.major cudnn.version}"
  #   build:cuda --action_env TF_CUDA_COMPUTE_CAPABILITIES="${builtins.concatStringsSep "," cudaFlags.realArches}"
  # '' + ''
  #   CFG
  # '';

  # # Make sure Bazel knows about our configuration flags during fetching so that the
  # # relevant dependencies can be downloaded.
  # bazelFlags = [
  #   "-c opt"
  # ] ++ lib.optionals stdenv.cc.isClang [
  #   # bazel depends on the compiler frontend automatically selecting these flags based on file
  #   # extension but our clang doesn't.
  #   # https://github.com/NixOS/nixpkgs/issues/150655
  #   "--cxxopt=-x"
  #   "--cxxopt=c++"
  #   "--host_cxxopt=-x"
  #   "--host_cxxopt=c++"
  # ];

  # We intentionally overfetch so we can share the fetch derivation across all the different configurations
  fetchAttrs = {
  #   TF_SYSTEM_LIBS = lib.concatStringsSep "," tf_system_libs;
  #   # we have to force @mkl_dnn_v1 since it's not needed on darwin
  #   bazelTargets = [ bazelRunTarget "@mkl_dnn_v1//:mkl_dnn" ];
  #   bazelFlags = bazelFlags ++ [
  #     "--config=avx_posix"
  #   ] ++ lib.optionals cudaSupport [
  #     # ideally we'd add this unconditionally too, but it doesn't work on darwin
  #     # we make this conditional on `cudaSupport` instead of the system, so that the hash for both
  #     # the cuda and the non-cuda deps can be computed on linux, since a lot of contributors don't
  #     # have access to darwin machines
  #     "--config=cuda"
  #   ] ++ [
  #     "--config=mkl_open_source_only"
  #   ];

    sha256 = "";
    # /(if cudaSupport then {
  #     x86_64-linux = "sha256-q2wRaoCGnISEdtF6jDMk9Wccy/wTmLusVBI7dDATwi4=";
  #   } else {
  #     x86_64-linux = "sha256-0cDJ27HCi3J5xeT6TkTtfUzF/yESBYmEVG1r14kPdRs=";
  #     aarch64-linux = "sha256-WbaN8VYjeW0mDthmtoSTttqd4K/Z8dP5+VkTo10pLtU=";
  #   }).${stdenv.system} or (throw "jaxlib: unsupported system: ${stdenv.system}");
  };

  buildAttrs = {
    outputs = [ "out" ];

  #   TF_SYSTEM_LIBS = lib.concatStringsSep "," (tf_system_libs ++ lib.optionals (!stdenv.isDarwin) [
  #     "nsync" # fails to build on darwin
  #   ]);

  #   # Note: we cannot do most of this patching at `patch` phase as the deps are not available yet.
  #   # 1) Link protobuf from nixpkgs (through TF_SYSTEM_LIBS when using gcc) to prevent crashes on
  #   #    loading multiple extensions in the same python program due to duplicate protobuf DBs.
  #   # 2) Patch python path in the compiler driver.
  #   preBuild = lib.optionalString cudaSupport ''
  #     patchShebangs ../output/external/xla/third_party/gpus/crosstool/clang/bin/crosstool_wrapper_driver_is_not_gcc.tpl
  #   '' + lib.optionalString stdenv.isDarwin ''
  #     # Framework search paths aren't added by bintools hook
  #     # https://github.com/NixOS/nixpkgs/pull/41914
  #     export NIX_LDFLAGS+=" -F${IOKit}/Library/Frameworks"
  #     substituteInPlace ../output/external/rules_cc/cc/private/toolchain/osx_cc_wrapper.sh.tpl \
  #       --replace "/usr/bin/install_name_tool" "${cctools}/bin/install_name_tool"
  #     substituteInPlace ../output/external/rules_cc/cc/private/toolchain/unix_cc_configure.bzl \
  #       --replace "/usr/bin/libtool" "${cctools}/bin/libtool"
  #   '';
  };

  meta = with lib; {
    isIbusEngine = true;
    description = "Japanese input method from Google";
    homepage = "https://github.com/google/mozc";
    license = licenses.free;
    platforms = platforms.linux;
    maintainers = with maintainers; [ gebner ericsagnes ];
  };
}

/*
  stdenv.mkDerivation rec {
  pname = "ibus-mozc";
  version = "2.29.5268.102";

  src = fetchFromGitHub {
  owner = "google";
  repo = "mozc";
  rev = "refs/tags/${version}";
  hash = "sha256-B7hG8OUaQ1jmmcOPApJlPVcB8h1Rw06W5LAzlTzI9rU=";
  fetchSubmodules = true;
  };

  patches =
  let
      # Fedora patches
      fedoraSrc = fetchgit {
        url = "https://src.fedoraproject.org/rpms/mozc.git";
        rev = "2f3d6bf3b31dc4f42026ac3b9eb0067b7d3a771e";
        hash = "sha256-30t36O9zvToK73ruSvhDJ4MecrbxFryjKOmDKAiKWZM=";
      };

      fixFedoraPatch =
        patch:
        runCommand
          (builtins.baseNameOf patch)
          {
            nativeBuildInputs = [
              patchutils
            ];
            inherit patch;
          }
          ''
            filterdiff \
              --strip=1 \
              --addoldprefix=a/src/ \
              --addnewprefix=b/src/ \
              --clean \
              "$patch" > "$out"
          '';
  in
  [
      (fixFedoraPatch "${fedoraSrc}/mozc-build-ninja.patch")
      ## to avoid undefined symbols with clang.
      # (fixFedoraPatch "${fedoraSrc}/mozc-build-gcc.patch")
      (fixFedoraPatch "${fedoraSrc}/mozc-build-verbosely.patch")
      (fixFedoraPatch "${fedoraSrc}/mozc-build-id.patch")
      # (fixFedoraPatch "${fedoraSrc}/mozc-build-gcc-common.patch")
      # (fixFedoraPatch "${fedoraSrc}/mozc-use-system-abseil-cpp.patch")
      (fixFedoraPatch "${fedoraSrc}/mozc-build-gyp.patch")
      # (fixFedoraPatch "${fedoraSrc}/mozc-build-new-abseil.patch")
  ];


  nativeBuildInputs = [
  which
  ninja
  python3Packages.python
  python3Packages.six
  python3Packages.gyp
  pkg-config
  qt5.wrapQtAppsHook
  ];

  buildInputs = [
  abseil-cpp
  protobuf
  ibus
  gtk2
  zinnia
  qt5.qtbase
  libxcb
  ];

  postUnpack = lib.optionalString stdenv.isLinux ''
  # sed -i 's/-lc++/-lstdc++/g' $sourceRoot/src/gyp/common.gypi

  # Avoid accidentally using vendored deps.
  rm -rf third_party/abseil-cpp
  '';

  configurePhase = ''
  runHook preConfigure

  export GYP_DEFINES="document_dir=$out/share/doc/mozc use_libzinnia=1 use_libprotobuf=1 ibus_mozc_path=$out/lib/ibus-mozc/ibus-engine-mozc zinnia_model_file=${tegaki-zinnia-japanese}/share/tegaki/models/zinnia/handwriting-ja.model"
  cd src && python build_mozc.py gyp --gypdir=${python3Packages.gyp}/bin --server_dir=$out/lib/mozc

  runHook postConfigure
  '';

  buildPhase = ''
  runHook preBuild

  PYTHONPATH="$PWD:$PYTHONPATH" python build_mozc.py build -c Release \
      unix/ibus/ibus.gyp:ibus_mozc \
      unix/emacs/emacs.gyp:mozc_emacs_helper \
      server/server.gyp:mozc_server \
      gui/gui.gyp:mozc_tool \
      renderer/renderer.gyp:mozc_renderer

  runHook postBuild
  '';

  installPhase = ''
  runHook preInstall

  install -d        $out/share/licenses/mozc
  head -n 29 server/mozc_server.cc > $out/share/licenses/mozc/LICENSE
  install -m 644    data/installer/*.html $out/share/licenses/mozc/

  install -D -m 755 out_linux/Release/mozc_server $out/lib/mozc/mozc_server
  install    -m 755 out_linux/Release/mozc_tool   $out/lib/mozc/mozc_tool
  wrapQtApp $out/lib/mozc/mozc_tool

  install -d        $out/share/doc/mozc
  install -m 644    data/installer/*.html $out/share/doc/mozc/

  install -D -m 755 out_linux/Release/ibus_mozc           $out/lib/ibus-mozc/ibus-engine-mozc
  install -D -m 644 out_linux/Release/gen/unix/ibus/mozc.xml $out/share/ibus/component/mozc.xml
  install -D -m 644 data/images/unix/ime_product_icon_opensource-32.png $out/share/ibus-mozc/product_icon.png
  install    -m 644 data/images/unix/ui-tool.png          $out/share/ibus-mozc/tool.png
  install    -m 644 data/images/unix/ui-properties.png    $out/share/ibus-mozc/properties.png
  install    -m 644 data/images/unix/ui-dictionary.png    $out/share/ibus-mozc/dictionary.png
  install    -m 644 data/images/unix/ui-direct.png        $out/share/ibus-mozc/direct.png
  install    -m 644 data/images/unix/ui-hiragana.png      $out/share/ibus-mozc/hiragana.png
  install    -m 644 data/images/unix/ui-katakana_half.png $out/share/ibus-mozc/katakana_half.png
  install    -m 644 data/images/unix/ui-katakana_full.png $out/share/ibus-mozc/katakana_full.png
  install    -m 644 data/images/unix/ui-alpha_half.png    $out/share/ibus-mozc/alpha_half.png
  install    -m 644 data/images/unix/ui-alpha_full.png    $out/share/ibus-mozc/alpha_full.png
  install -D -m 755 out_linux/Release/mozc_renderer       $out/lib/mozc/mozc_renderer
  install -D -m 755 out_linux/Release/mozc_emacs_helper   $out/lib/mozc/mozc_emacs_helper

  runHook postInstall
  '';

  meta = with lib; {
  isIbusEngine = true;
  description = "Japanese input method from Google";
  homepage = "https://github.com/google/mozc";
  license = licenses.free;
  platforms = platforms.linux;
  maintainers = with maintainers; [ gebner ericsagnes ];
  };
  }
*/
