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

return M
