{
  description = "Apple fonts";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    let
      sources = {
        sf-compact = {
          url = "https://devimages-cdn.apple.com/design/resources/download/SF-Compact.dmg";
          sha256 = "sha256-7gRJxuB+DOxS6bzHXFNjNH2X4kmO1MhJN2zK5he2XRU=";
        };

        sf-pro = {
          url = "https://devimages-cdn.apple.com/design/resources/download/SF-Pro.dmg";
          sha256 = "sha256-HtJ/KdIVOdYocuzQ8qkzTAm7bMITCq3Snv+Bo9WO9iA=";
        };
        sf-mono = {
          url = "https://devimages-cdn.apple.com/design/resources/download/SF-Mono.dmg";
          sha256 = "sha256-ulmhu5kXy+A7//frnD2mzBs6q5Jx8r6KwwaY7gmoYYM=";
        };
        sf-arabic = {
          url = "https://devimages-cdn.apple.com/design/resources/download/SF-Arabic.dmg";
          sha256 = "sha256-8382K8rq/Myas47Pe0SZ6ZpmQljz2ut+X8Orkm1yemo=";
        };
        new-york = {
          url = "https://devimages-cdn.apple.com/design/resources/download/NY.dmg";
          sha256 = "sha256-Rr0UpJa7kemczCqNn6b8HNtW6PiWO/Ez1LUh/WNk8S8=";
        };
      };
      mkFont = pkgs: (name: value:
          pkgs.stdenv.mkDerivation {
            pname = "${name}-font";
            version = "1.0";

            src = pkgs.fetchurl {
              url = value.url;
              sha256 = value.sha256;
            };

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
    }) // {
      overlays.default = final: prev: prev.lib.mapAttrs (mkFont final) sources;
    };
}
