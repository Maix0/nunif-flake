{
  description = "Waifu2x's flake setup";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.waifu2x-src.url = "github:nagadomi/nunif";
  inputs.waifu2x-src.flake = false;

  inputs.onnx-model.url = "https://github.com/nagadomi/nunif/releases/download/0.0.0/waifu2x_onnx_models_20230504.zip";
  inputs.onnx-model.flake = false;
  inputs.pytorch-model.url = "https://github.com/nagadomi/nunif/releases/download/0.0.0/waifu2x_pretrained_models_20230504.zip";
  inputs.pytorch-model.flake = false;

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    waifu2x-src,
    onnx-model,
    pytorch-model,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        waifu2x = pkgs.stdenv.mkDerivation {
          srcs = [waifu2x-src onnx-model pytorch-model];
          setSourceRoot = ''
            export sourceRoot="."
            ${pkgs.tree}/bin/tree -ifFC .
          '';
          InstallPhase = ''


          '';
          nativeBuildInputs = [pkgs.unzip];
        };
      in {
        devShell = let
          py-env = pkgs.python311.buildEnv {
            extraLibs = let
              ps = pkgs.python311Packages;
            in [
              ps.torchvision
              ps.pytorch
              ps.numpy
              ps.pillow
              ps.tqdm
              ps.wand
              ps.fonttools
              ps.scipy
              ps.waitress
              ps.bottle
              ps.diskcache
              ps.flake8
              ps.psutil
              ps.pyyaml
              ps.onnx
              ps.packaging
              ps.wxPython_4_2
              ps.av
            ];
          };
        in
          pkgs.mkShell {
            packages = [py-env];

            shellHook = ''
              export WAIFU_DIRECTORY='${waifu2x}';
            '';
          };
      }
    );
}
