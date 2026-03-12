let
 pkgs = import (fetchTarball "https://github.com/rstats-on-nix/nixpkgs/archive/2025-03-11.tar.gz") {};
 
  rpkgs = builtins.attrValues {
    inherit (pkgs.rPackages) 
     tidymodels
     glmnet
     naniar
     mice;
  };

  system_packages = builtins.attrValues {
    inherit (pkgs)
      glibcLocales
      nix
      R
      quarto
      which
      pandoc
      fontconfig
      dejavu_fonts
      freefont_ttf;
  };

  shell = pkgs.mkShell {
    LOCALE_ARCHIVE = if pkgs.system == "x86_64-linux" then "${pkgs.glibcLocales}/lib/locale/locale-archive" else "";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";

    # Font configuration for ggplot2/ggtext
    FONTCONFIG_FILE = "${pkgs.fontconfig.out}/etc/fonts/fonts.conf";
    FONTCONFIG_PATH = "${pkgs.fontconfig.out}/etc/fonts/";

    # Tell fontconfig where to find the fonts from the Nix store
    shellHook = ''
      export XDG_DATA_DIRS="${pkgs.dejavu_fonts}/share:${pkgs.freefont_ttf}/share:$XDG_DATA_DIRS"
      fc-cache -f 2>/dev/null || true
    '';
  
    buildInputs = [ rpkgs system_packages ];
    
  }; 
in
  {
    inherit pkgs shell;
  }
