{
  description = "A simple C2 server with Flask and socket communication";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, treefmt-nix }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
      treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;

      python-script = pkgs.python311Packages.buildPythonApplication {
        pname = "c2-pixler";
        version = "0.1";
        doCheck = false;
        src = ./.;
        propagatedBuildInputs = with pkgs; [
          python311Packages.flask
        ];
        installPhase = ''
          install -Dm755 ${./server.py} $out/bin/server.py
          install -Dm755 ${./templates/index.html} $out/bin/templates/index.html
        '';
      };

      containerImage = pkgs.dockerTools.buildLayeredImage {
        name = "ghcr.io/golo300/c2-pixler";
        tag = "unstable";
        contents = with pkgs; [ cacert ];
        config = {
          Labels = {
            "org.opencontainers.image.source" = "https://github.com/Golo300/C2-Pixler";
            "org.opencontainers.image.description" = "C2-Pixler Server image, follow golo300 on GitHub!!!";
            "org.opencontainers.image.licenses" = "UNKNOWN";
          };
          Entrypoint = [ "${python-script}/bin/server.py" ];
          Env = [ "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" "PYTHONUNBUFFERED=1" ];
        };
      };
    in
    {
      formatter.${system} = treefmtEval.config.build.wrapper;
      checks.${system}.formatter = treefmtEval.config.build.check self;

      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.python3
        ];
        buildInputs = [
          pkgs.python39Packages.flask
        ];
      };

      packages.${system} = {
        default = pkgs.writeShellScriptBin "c2-pixler" ''
          ${python-script}/bin/server.py "''${@:1}"
        '';
        containerImage = containerImage;
      };
    };
}
