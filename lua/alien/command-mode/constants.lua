local M = {}

---@alias DisplayStrategy "print" | "ui" | "show" | "diff" | "blame" | "mergetool"
M.DISPLAY_STRATEGIES = {
  PRINT = "print",
  UI = "ui",
  SHOW = "show",
  DIFF = "diff",
  BLAME = "blame",
  MERGETOOL = "mergetool",
}

M.PORCELAIN_COMMANDS = {
  "add",
  "rebase",
  "cherry",
  "am",
  "reset",
  "count-objects",
  "archive",
  "revert",
  "difftool",
  "bisect",
  "rm",
  "fsck",
  "branch",
  "shortlog",
  "get-tar-commit-id",
  "bundle",
  "show",
  "help",
  "checkout",
  "stash",
  "instaweb",
  "cherry-pick",
  "status",
  "merge-tree",
  "citool",
  "submodule",
  "rerere",
  "clean",
  "tag",
  "rev-parse",
  "clone",
  "worktree",
  "show-branch",
  "commit",
  "verify-commit",
  "describe",
  "config",
  "verify-tag",
  "diff",
  "fast-export",
  "whatchanged",
  "fetch",
  "fast-import",
  "format-patch",
  "filter-branch",
  "archimport",
  "gc",
  "mergetool",
  "cvsexportcommit",
  "grep",
  "pack-refs",
  "cvsimport",
  "gui",
  "prune",
  "cvsserver",
  "init",
  "reflog",
  "imap-send",
  "log",
  "relink",
  "p4",
  "merge",
  "remote",
  "quiltimport",
  "mv",
  "repack",
  "request-pull",
  "notes",
  "replace",
  "send-email",
  "pull",
  "annotate",
  "svn",
  "push",
  "blame",
}

M.BASE_COMMANDS = {
  "add",
  "rebase",
  "reset",
  "revert",
  "difftool",
  "bisect",
  "rm",
  "branch",
  "show",
  "help",
  "checkout",
  "stash",
  "cherry-pick",
  "status",
  "clean",
  "tag",
  "clone",
  "worktree",
  "commit",
  "diff",
  "fetch",
  "gc",
  "mergetool",
  "grep",
  "init",
  "reflog",
  "log",
  "merge",
  "remote",
  "mv",
  "pull",
  "push",
  "blame",
}

M.SUBCOMMAND_FLAGS = {
  add = {},
  rebase = {},
  reset = {},
  revert = {},
  difftool = {},
  bisect = {},
  rm = {},
  branch = {},
  show = {},
  help = {},
  checkout = {},
  stash = {},
  ["cherry-pick"] = {},
  status = {},
  clean = {},
  tag = {},
  clone = {},
  worktree = {},
  commit = {
    "-a",
    "-p",
    "-C",
    "-c",
    "-F",
    "-m",
    "-t",
    "-e",
    "-s",
    "-S",
    "-n",
    "--amend",
    "--dry-run",
    "--fixup",
    "--squash",
    "--reset-author",
    "--short",
    "--branch",
    "--porcelain",
    "--long",
    "--null",
    "--file",
    "--author",
    "--date",
    "--no-verify",
    "--allow-empty",
    "--allow-empty-message",
    "--cleanup",
    "--status",
    "--no-status",
    "--gpg-sign",
    "--help",
  },
  diff = {},
  fetch = {},
  gc = {},
  mergetool = {},
  grep = {},
  init = {},
  reflog = {},
  log = {},
  merge = {},
  remote = {},
  mv = {},
  pull = {},
  push = {},
  blame = {},
}

return M
