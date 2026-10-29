-- RFile's configuration: the bookmarks and mappings of vifmrc, where RFile's own keys differ.

-- ------------------------------------------------------------------------------
-- Bookmarks
-- ------------------------------------------------------------------------------

local marks = {
  a = "/data",
  c = "~/.config",
  C = "~/Code",
  d = "~/Downloads",
  D = "~/Documents",
  h = "~",
  l = "~/.local",
  m = "/mnt",
  M = "/mnt/minio",
  o = "~/.dotfiles",
  O = "/mnt/OneDrive",
  Q = "/mnt/qnap64",
  r = "/",
  t = "~/Temp",
  T = "/tmp",
  w = "~/Documents/Work",
}

-- :mark needs a client, so the marks are set when the first one attaches, once for each daemon,
-- as vifm sets them when it starts.
local marked = false

rfile.on("attach", function()
  if marked then
    return
  end

  marked = true

  for letter, directory in pairs(marks) do
    rfile.cmd(("mark %s %s"):format(letter, directory))
  end
end)

-- ------------------------------------------------------------------------------
-- Mappings
-- ------------------------------------------------------------------------------

-- Shell
rfile.map("n", "s", ":!nu -i<CR>")

-- Quit
rfile.map("n", "q", ":q<CR>")

-- Display sorting dialog
rfile.map("n", "S", ":sort<CR>")

-- Toggle the preview in the other pane from visual mode, as w does in normal mode
rfile.map("v", "w", ":view<CR>gv")

-- Open file using xdg-open
rfile.map("n", "o", function()
  local entry = rfile.current()

  if entry then
    rfile.run({ "xdg-open", entry.path })
  end
end, { desc = "open with xdg-open" })

-- Extract archives to current directory, or to the other pane's
rfile.map("nv", "x", ":extract .<CR>")
rfile.map("nv", "X", ":extract<CR>")

-- Yank current file path into the clipboard; yd and yn yank the directory and the name
rfile.map("n", "yf", "yp")

-- Yank root of current file's name into the clipboard
rfile.map("n", "yr", function()
  local entry = rfile.current()

  if entry then
    rfile.run({ "wl-copy", "--", entry.name:match("^(.+)%.[^.]*$") or entry.name })
  end
end, { desc = "yank the name without its extension" })

-- Mappings for faster renaming
rfile.map("n", "I", "cw<C-a>")
rfile.map("n", "cc", "cw<C-u>")
rfile.map("n", "A", "cw")

-- Edit this configuration; it applies with the next daemon, or at once after :source
rfile.map("n", ",c", ":edit ~/.config/rfile/init.lua<CR>")

-- Go to root, home
rfile.map("n", ",/", ":cd /<CR>")
rfile.map("n", ",'", ":cd ~<CR>")

-- Select all files
rfile.map("n", "<A-a>", "ggVG")

-- Copy, move selected files to the other pane, as <F5> and <F6> do
rfile.map("nv", "C", ":copy<CR>")
rfile.map("nv", "M", ":move<CR>")

-- Delete selected files permanently, where <F8> trashes them
rfile.map("n", "<F8>", "DD")
rfile.map("v", "<F8>", "D")
rfile.map("n", "D", "DD")

-- Open, close tab
rfile.map("nv", "<C-t>", ":tabnew<CR>")
rfile.map("nv", "Q", ":tabclose<CR>")

-- Next, previous tab
rfile.map("n", "]t", "gt")
rfile.map("n", "[t", "gT")

-- Open current directory, directory under cursor in the other pane
rfile.map("nv", "<A-i>", ":sync<CR>")
rfile.map("nv", "<A-o>", ":sync %c<CR>")

-- Swap panes
rfile.map("n", "<A-u>", "<C-w>x")

-- Completion navigation
rfile.map("c", "<C-j>", "<Tab>")
rfile.map("c", "<C-k>", "<S-Tab>")
