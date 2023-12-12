{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
          site = pkgs.stdenv.mkDerivation {
            name = "site";
            src = ./.;
            buildPhase = ''${pkgs.hugo}/bin/hugo --minify '';
            installPhase = ''cp -r public $out '';
            meta = with pkgs.lib; {
              description = ''the ii.nz blog'';
              platforms = platforms.all;
            };
          };
      in {
        packages =  {
          site = site;
          default = site;
        };
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [ hello cowsay hugo];
        };
      });
}
