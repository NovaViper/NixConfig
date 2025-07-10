{
  stdenv,
  lib,
  fetchFromGitHub,
  installShellFiles,
}:
stdenv.mkDerivation rec {
  pname = "zsh-abbr";
  version = "6.3.1";

  src = fetchFromGitHub {
    owner = "olets";
    repo = "zsh-abbr";
    rev = "1e97c6fcc680186f32791cb7c51e95808d7c7c1b";
    hash = "sha256-jumrUkz8L2UETKSipcDPkjstrPsHx4cwPH9sOXKnd0k=";
    fetchSubmodules = true;
  };

  strictDeps = true;
  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
        runHook preInstall

        install *.zsh -Dt $out/share/zsh/zsh-abbr/
        install completions/* -Dt $out/share/zsh/zsh-abbr/completions/

                              install zsh-job-queue/*.zsh -Dt $out/share/zsh/zsh-abbr/zsh-job-queue/
                              install zsh-job-queue/completions/* -Dt $out/share/zsh/zsh-abbr/zsh-job-queue/completions/

    # Required for `man` to find the manpage of abbr, since it looks via PATH
    installManPage man/man1/*

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/olets/zsh-abbr";
    description = "Zsh manager for auto-expanding abbreviations, inspired by fish shell";
    license = with licenses; [
      cc-by-nc-sa-40
      hl3
    ];
    maintainers = with maintainers; [ icy-thought ];
    platforms = platforms.all;
  };
}
