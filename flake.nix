{
  description = "Latex Nix Script";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    with flake-utils.lib;
    eachSystem allSystems (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        # Using full scheme because I am too lazy to figure out what packages I need
        tex = pkgs.texlive.combined.scheme-full;
      in
      rec {
        packages = {
          document = pkgs.stdenvNoCC.mkDerivation rec {
            name = "latex-document";
            src = self;
            buildInputs = [
              pkgs.coreutils
              tex
            ];
            phases = [
              "unpackPhase"
              "buildPhase"
              "installPhase"
            ];
            buildPhase = ''
              export PATH="${pkgs.lib.makeBinPath buildInputs}";
              mkdir -p .cache/texmf-var
              env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var \
                latexmk -interaction=nonstopmode -pdf -lualatex \
                main.tex
            '';
            installPhase = ''
              mkdir -p $out
              cp main.pdf $out/
            '';
          };
        };
        defaultPackage = packages.document;
      }
    );
}
