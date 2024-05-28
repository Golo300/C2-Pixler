{
  description = "A simple C2 server with Flask and socket communication";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
  };

  outputs = { self, nixpkgs }: 
  let 
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
  
   in {

    devShells.${system}.default = pkgs.mkShell {
        packages = [
              pkgs.python3
        ];
        buildInputs = [
                      pkgs.python39Packages.flask
                      ];
      };
    };
}
