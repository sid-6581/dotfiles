--- @diagnostic disable: undefined-global

require("session"):setup{
  sync_yanked = true,
}

function Linemode:custom()
  local time = os.date("%b %d %Y", (self._file.cha.mtime or 0) // 1)
  local size = self._file:size()
  local perm = self._file.cha:perm() or ""

  return ui.Line(
    string.format(
      " %s %s %s",
      size and ya.readable_size(size):gsub(" ", "") or "-",
      time,
      perm
    )
  )
end

Status:children_add(function()
  local h = cx.active.current.hovered
  if h == nil or ya.target_family() ~= "unix" then
    return ui.Line{}
  end

  return ui.Line{
    ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
    ui.Span(":"),
    ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
    ui.Span(" "),
  }
end, 500, Status.RIGHT)
