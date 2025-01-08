function selectWindowAtCoordinates(xPercent, yPercent) {
  // console.log(workspace.stackingOrder.filter(w => w.desktops.some(d => d.id == workspace.currentDesktop.id)));
  // console.log(workspace.stackingOrder.map(w => JSON.stringify({ x: w.x, y: w.y, class: w.resourceClass })));
  // console.log(workspace.clientArea(KWin.WorkArea, workspace.activeScreen, workspace.currentDesktop));

  const dimensions = workspace.clientArea(KWin.WorkArea, workspace.activeScreen, workspace.currentDesktop);

  const x = dimensions.width * xPercent;
  const y = dimensions.height * yPercent;

  const windows = workspace.windowAt({ x, y }, -1).filter(w => w.normalWindow);

  if (windows.length > 0) {
    if (workspace.activeWindow === windows[0] && windows.length > 1)
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
