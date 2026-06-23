{
  description = "Repository for learnjapanese.moe (TheMoeWay)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };

      mkdocs-open-in-new-tab = with pkgs.python3Packages; buildPythonPackage rec {
        pname = "mkdocs-open-in-new-tab";
        version = "1.0.8";
        pyproject = true;

        src = pkgs.fetchPypi {
          pname = "mkdocs_open_in_new_tab";
          inherit version;
          hash = "sha256-Pg2tCMyZOLCxMJe+jgqkNZGd4e6y0aZI5mtd7o1X4Eg=";
        };

        postPatch = ''
          echo "mkdocs" > requirements.txt
          touch devdeps.txt
        '';

        build-system = [ setuptools ];
        dependencies = [ mkdocs ];
        pythonImportsCheck = [ "open_in_new_tab" ];
      };

      pythonEnv = pkgs.python3.withPackages (ps: [
        ps.mkdocs-material
        mkdocs-open-in-new-tab
      ]);
    in {
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        name = "themoeway";

        src = ./.;

        nativeBuildInputs = [ pythonEnv ];

        installPhase = ''
          runHook preInstall
          mkdocs build --strict --site-dir "$out"
          runHook postInstall
        '';
      };

      devShells.${system}.default = pkgs.mkShell {
        inputsFrom = [ self.packages.${system}.default ];
      };
    };
}
