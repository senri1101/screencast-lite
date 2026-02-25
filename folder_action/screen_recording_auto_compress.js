function shellQuote(value) {
  return "'" + String(value).replace(/'/g, "'\\''") + "'";
}

function addingFolderItemsTo(thisFolder, addedItems) {
  var app = Application.currentApplication();
  app.includeStandardAdditions = true;

  var quotedPaths = [];
  for (var i = 0; i < addedItems.length; i += 1) {
    quotedPaths.push(shellQuote(addedItems[i].toString()));
  }

  if (quotedPaths.length === 0) {
    return;
  }

  var command =
    '/bin/zsh "$HOME/Library/Scripts/Folder Action Scripts/screen_recording_auto_compress.sh" ' +
    quotedPaths.join(' ');

  app.doShellScript(command);
}
