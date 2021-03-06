import { MenuItemConstructorOptions } from 'electron';
import { MenuItemEventsFile, MenuItemEventsApp } from '../service-menu.types';
import * as menuApp from './service-menu-items-app';
import * as menuFile from './service-menu-items-file';

export const createMenu = (
  isMacOs: boolean
): {
  template: MenuItemConstructorOptions[];
  EVENTS: Partial<MenuItemEventsFile> & Partial<MenuItemEventsApp>;
} => {
  let EVENTS = {};
  const template = [];

  if (isMacOs) {
    template.push(menuApp.template);
    menuApp.init();
    EVENTS = Object.assign(EVENTS, menuApp.EVENTS);
  }

  template.push(menuFile.template);
  menuFile.init();
  EVENTS = Object.assign(EVENTS, menuFile.EVENTS);

  return {
    template,
    EVENTS,
  };
};

export default {
  createMenu,
};
