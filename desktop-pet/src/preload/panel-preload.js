const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('panel', {
  getSettings: () => ipcRenderer.invoke('panel:get-settings'),
  listPets: () => ipcRenderer.invoke('panel:list-pets'),
  set: (key, value) => ipcRenderer.send('panel:set', key, value),
  resetPosition: () => ipcRenderer.send('panel:reset-position'),
  quit: () => ipcRenderer.send('panel:quit'),
  installPetpack: () => ipcRenderer.invoke('panel:install-petpack'),
  removePet: (id) => ipcRenderer.invoke('panel:remove-pet', id),
  petsaasSync: () => ipcRenderer.invoke('panel:petsaas-sync'),
  onPetsChanged: (cb) => ipcRenderer.on('panel:pets-changed', () => cb()),
});
