const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('petdesk', {
  getManifest: () => ipcRenderer.invoke('pet:manifest'),
  dragStart: () => ipcRenderer.send('pet:drag-start'),
  dragMove: () => ipcRenderer.send('pet:drag-move'),
  dragEnd: () => ipcRenderer.send('pet:drag-end'),
  click: () => ipcRenderer.send('pet:click'),
  hover: () => ipcRenderer.send('pet:hover'),
  dblclick: () => ipcRenderer.send('pet:dblclick'),
  contextMenu: (pos) => ipcRenderer.send('pet:contextmenu', pos),
  onSetState: (cb) =>
    ipcRenderer.on('pet:set-state', (_e, state, ms) => cb(state, ms)),
  onSetFacing: (cb) =>
    ipcRenderer.on('pet:set-facing', (_e, dir) => cb(dir)),
  onSay: (cb) =>
    ipcRenderer.on('pet:say', (_e, text, ms) => cb(text, ms)),
  onScale: (cb) =>
    ipcRenderer.on('pet:scale', (_e, s) => cb(s)),
});
