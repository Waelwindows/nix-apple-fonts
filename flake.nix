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
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};

      sources = {
        sf-compact = {
          url = "https://devimages-cdn.apple.com/design/resources/download/SF-Compact.dmg";
          sha256 = "sha256-Ot/p5Wo84AibMjEjesdTDj/MpzYE1XNECsUH2aszR/o=";
        };

        sf-pro = {
          url = "https://devimages-cdn.apple.com/design/resources/download/SF-Pro.dmg";
          sha256 = "sha256-o1Zis9kymOicTyDdTPGON2A5LNpDbgOD1XtyQOdxc0M=";
        };
        sf-mono = {
          url = "https://devimages-cdn.apple.com/design/resources/download/SF-Mono.dmg";
          sha256 = "sha256-jnhTTmSy5J8MJotbsI8g5hxotgjvyDbccymjABwajYw=";
        };
        sf-arabic = {
          url = "https://devimages-cdn.apple.com/design/resources/download/SF-Arabic.dmg";
          sha256 = "sha256-99vnv+z3liEhaHw4rqdGcAOe74fPuWmMiBmLLd3/DP0=";
        };
        new-york = {
          url = "https://devimages-cdn.apple.com/design/resources/download/NY.dmg";
          sha256 = "sha256-Rr0UpJa7kemczCqNn6b8HNtW6PiWO/Ez1LUh/WNk8S8=";
        };
      };
    in rec {
      packages =
        flake-utils.lib.flattenTree (pkgs.lib.mapAttrs (name: value:
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
          })
        sources)
        // {
          default = packages.sf-mono;
        };
      overlays.default = final: prev: packages;
    });
}
