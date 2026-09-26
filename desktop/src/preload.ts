import { contextBridge } from 'electron';

// Bridge minima: expoe apenas metadados da shell. Toda a logica fica na app web.
contextBridge.exposeInMainWorld('petsaasShell', {
  platform: process.platform,
  version: process.env.npm_package_version ?? '0.1.0',
  isDesktop: true,
});
