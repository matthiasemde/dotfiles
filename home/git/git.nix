{ config, lib, pkgs, ... }:

with lib;
let
  gitalias = pkgs.fetchFromGitHub {
    owner = "GitAlias";
    repo = "gitalias";
    rev = "7b27ef766a3557a5708086734559f6a14bb97744";
    hash = "sha256-IvHM6mRtoeVm01cUmTkKqjm6/n3Izau89B7MT69Afo0=";
  };
in
{
  home.packages = with pkgs; [ git-absorb ];

  programs.git = {
    aliases = {
      # Debug a command or alias - preceed it with `debug`.
      debug = "!set -x; GIT_TRACE=2 GIT_CURL_VERBOSE=2 GIT_TRACE_PERFORMANCE=2 GIT_TRACE_PACK_ACCESS=2 GIT_TRACE_PACKET=2 GIT_TRACE_PACKFILE=2 GIT_TRACE_SETUP=2 GIT_TRACE_SHALLOW=2 git";
      lg1 = log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' -n 8;
      lg2 = log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all -n 8;
      lg = !"git lg1";
    };
    enable = true;
    extraConfig = {
      advice = {
        addIgnoredFile = false;
        detachedHead = false;
      };
      branch.sort = "-committerdate";
      color.ui = "auto";
      column.ui = "auto";
      commit = {
        gpgSing = true
      };
      core.editor = config.home.sessionVariables."EDITOR" or "vim";
      diff = {
        tool = vscode;
        colorMoved = plain;
        mnemonicPrefix = true;
        renames = true;
        algorithm = histogram;
      };
      difftool = {
        vscode.cmd = "code --wait --diff \$LOCAL \$REMOTE";
      };
      fetch = {
        all = true;
        prune = true;
        pruneTags = true;
        writeCommitGraph = true;
      };
      filter.lfs = {
        smudge = git-lfs smudge -- %f;
        process = git-lfs filter-process;
        required = true;
        clean = git-lfs clean -- %f;
      };
      gpg.program = "gpg2";
      init.defaultBranch = "main";
      help.autocorrect = "prompt";
      merge.conflictStyle = "zdiff3";
      pull.rebase = true;
      push = {
        autoSetupRemote = true;
        default = "current";
        followTags = true;
      };
      status = {
        showStash = true;
        submoduleSummary = true;
      };
      stash.showPatch = true;
      submodule = {
        fetchJobs = 4;
        recurse = false;
      };
      rebase = {
        autosquash = true;
        autostash = true;
        updateRefs = true;
      };
      rerere = {
        enable = true;
        autoupdate = true;
      };
      tag = {
        gpgSign = true;
        sort = "version:refname";
      };
      user.useConfigOnly = true;
    };
    ignores = [
      # Compiled source
      "*.com"
      "*.class"
      "*.dll"
      "*.exe"
      "*.o"
      "*.so"

      # OS generated files
      ".DS_Store"
      ".DS_Store?"
      "._*"
      ".Spotlight-V100"
      ".Trashes"
      "ehthumbs.db"
      "Thumbs.db"

      # ctags
      "tags"
      "tags.temp"
      "tags.lock"
      "tags.files"

      # Vim
      "Session.vim"

      # GDB
      ".gdb_history"

      # Ripgrep
      ".rgignore"

      # C/C++
      "compile_commands.json"
    ];
    includes = [{ path = "${gitalias}/gitalias.txt"; }];
    lfs = {
      enable = true;
      skipSmudge = false;
    };
    package = pkgs.gitAndTools.gitFull;
    user = {
      signingkey = "B553F8169E97D0E33563F977DE0DBC6804FF7C75";
      email = "matthias.emde@mvtec.com";
      name = "Matthias Emde";
    };
  };
}
