{ pkgs, lib, config, inputs, ... }:

let
  pkgs-unstable = import inputs.nixpkgs-unstable { system = pkgs.stdenv.system; };
in

{
  # https://devenv.sh/basics/
  env.GREET = "devenv";

  # https://devenv.sh/packages/
  packages = [ 
    pkgs.git
    pkgs.just
    pkgs.pre-commit
    pkgs.podman
    pkgs.minikube
    pkgs.kubectl
    pkgs-unstable.tailwindcss_4
    pkgs.air
  ];

  languages.go.enable = true;
  languages.go.enableHardeningWorkaround = true;


  # https://devenv.sh/processes/
  processes = {
    start-local-cluster.exec = "just start-k8s";
  };

  # https://devenv.sh/services/
  # services.postgres.enable = true;

  # https://devenv.sh/scripts/
  scripts.wellcome-msg.exec = ''
    echo "Devenv started!"
  '';

  enterShell = ''
    wellcome-msg
    go version
    git --version
  '';

  # https://devenv.sh/tasks/
  # tasks = {};

  # https://devenv.sh/tests/
  enterTest = ''
    echo "Running tests"
    git --version | grep --color=auto "${pkgs.git.version}"
  '';

  # https://devenv.sh/git-hooks/
  # git-hooks.hooks.shellcheck.enable = true;

  # See full reference at https://devenv.sh/reference/options/
}
