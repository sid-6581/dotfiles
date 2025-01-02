function selectWindowAtCoordinates(xPercent, yPercent) {
  const x = workspace.workspaceWidth * xPercent;
  const y = workspace.workspaceHeight * yPercent;

  const windows = workspace.windowAt({ x, y }, 2);
  console.log(windows.map(w => w.resourceClass));

  if (windows.length > 0) {
    if (workspace.activeWindow === windows[0])
      workspace.activeWindow = windows[1];
    else
      workspace.activeWindow = windows[0];
  }
}

registerShortcut("Tiling: Select Window at Top Left", "Tiling: Select Window at Top Left", "Meta+Q", function() {
  selectWindowAtCoordinates(0.1, 0.1);
});

registerShortcut("Tiling: Select Window at Top Center", "Tiling: Select Window at Top Center", "Meta+W", function() {
  selectWindowAtCoordinates(0.5, 0.1);
});

registerShortcut("Tiling: Select Window at Top Right", "Tiling: Select Window at Top Right", "Meta+E", function() {
  selectWindowAtCoordinates(0.9, 0.1);
});
