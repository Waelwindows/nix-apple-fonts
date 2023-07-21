{
  description = "Apple fonts";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    sf-compact = {
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Compact.dmg";
      flake = false;
    };
    sf-pro = {
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Pro.dmg";
      flake = false;
    };
    sf-mono = {
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Mono.dmg";
      flake = false;
    };
    sf-arabic = {
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Arabic.dmg";
      flake = false;
    };
    new-york = {
      url = "https://devimages-cdn.apple.com/design/resources/download/NY.dmg";
      flake = false;
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
    ...
  }: let
    sources = with inputs; {inherit sf-compact sf-pro sf-mono sf-arabic new-york;};
    mkFont = pkgs: (name: src:
      pkgs.stdenv.mkDerivation {
        inherit src;

        pname = "${name}-font";
        version = "1.0";

        nativeBuildInputs = [pkgs.p7zip];

        unpackCmd = ''
          7z x $curSrc
          find . -name "*.pkg" -print -exec 7z x {} \;
          find . -name "Payload~" -print -exec 7z x {} \;
        '';

        sourceRoot = "./Library/Fonts";

        dontBuild = true;

        installPhase = ''
          find . -name '*.ttf' -exec install -m444 -Dt $out/share/fonts/truetype {} \;
          find . -name '*.otf' -exec install -m444 -Dt $out/share/fonts/opentype {} \;
        '';

        meta = with pkgs.lib; {
          homepage = "https://developer.apple.com/fonts/";
          description = "Apple fonts";
          # license = licenses.unfree;
          maintainers = [maintainers.pinpox];
        };
      });
  in
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in rec {
      packages =
        flake-utils.lib.flattenTree (pkgs.lib.mapAttrs (mkFont pkgs) sources)
        // {
          default = packages.sf-mono;
        };
      formatter = pkgs.alejandra;
    })
    // {
      overlays.default = final: prev: prev.lib.mapAttrs (mkFont final) sources;
    };
}
