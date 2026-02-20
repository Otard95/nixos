let
  # --- Helpers ---
  extRules = action: exts:
    builtins.listToAttrs (map (ext: {
      name = "*.${ext}";
      value = action;
    }) exts);

  globRules = action: patterns:
    builtins.listToAttrs (map (p: {
      name = p;
      value = action;
    }) patterns);

  # Produces both "prefix cmd" and "prefix cmd *" entries
  cmdRules = action: prefix: cmds:
    builtins.listToAttrs (builtins.concatMap (cmd:
      let full = if prefix == "" then cmd else "${prefix} ${cmd}";
      in [
        { name = full; value = action; }
        { name = "${full} *"; value = action; }
      ]
    ) cmds);

  # Shorthands
  allowExts = extRules "allow";
  # denyExts = extRules "deny";
  allowGlobs = globRules "allow";
  denyGlobs = globRules "deny";
  allowCmds = cmdRules "allow";
  denyCmds = cmdRules "deny";

  # --- Extension groups ---
  sourceExts = [
    "ts" "tsx" "js" "jsx" "mjs" "cjs"
    "go"
    "php"
    "sh" "bash" "zsh"
    "sql"
    "css" "scss" "less"
    "html" "htm"
    "lua"
    "c" "cpp" "h" "hpp"
    "nix"
    "graphql" "gql"
    "json" "yaml" "yml" "ini"
  ];

  docExts = [ "md" "mdx" "txt" "rst" "csv" ];

  configExts = [ "json" "yaml" "yml" "toml" "xml" ];

  buildExts = [ "lock" "sum" "mod" "hcl" "tf" "dockerfile" ];

  secretPatterns = [
    "*.env" "*.env.*"
    "*.pem" "*.key"
    "*credentials*" "*secret*"
  ];

in {
  "*" = "ask";

  read = { "*" = "ask"; }
    // allowExts (sourceExts ++ configExts ++ docExts ++ buildExts)
    // allowGlobs [ "**/Makefile" "**/Dockerfile" "docker-compose*" "*.env.example" ]
    // denyGlobs secretPatterns;

  edit = { "*" = "ask"; }
    // allowExts (sourceExts ++ configExts ++ docExts)
    // allowGlobs [ "**/Makefile" "**/Dockerfile" ]
    // denyGlobs (secretPatterns ++ [ "*.lock" "*.sum" ]);

  bash = { "*" = "ask"; }
    // allowCmds "git" [
      "status" "diff" "add" "log" "show" "branch" "remote"
      "rev-parse" "ls-files" "blame" "tag" "stash list"
    ]
    // allowCmds "" [
      "ls" "pwd" "whoami" "date" "uname" "env"
      "wc" "file" "which" "type" "grep" "find"
    ]
    // allowCmds "pnpm" [ "list" "why" "build" "test" "lint" "lint:fix" ]
    // allowCmds "go" [ "list" "version" "env" ]
    // denyCmds "" [ "cat" "less" "more" "bat" ]
    // denyGlobs [ "rm -rf *" "sudo *" "chmod 777 *" ];

  glob = "allow";
  grep = "allow";
  list = "allow";
  lsp = "allow";
  todoread = "allow";
  todowrite = "allow";
  skill = "allow";
  task = "allow";

  webfetch = "ask";
  websearch = "ask";
  codesearch = "ask";

  doom_loop = "ask";
  external_directory = "ask";
}
