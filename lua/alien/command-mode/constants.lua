local M = {}

---@alias DisplayStrategy "print" | "ui" | "show" | "diff" | "blame" | "interactive"
M.DISPLAY_STRATEGIES = {
  PRINT = "print",
  UI = "ui",
  SHOW = "show",
  DIFF = "diff",
  BLAME = "blame",
  INTERACTIVE = "interactive",
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

return M