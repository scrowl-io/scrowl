import { IpcMainInvokeEvent } from 'electron';
import { ModelEventProps } from '../index';
import {
  dialogSave,
  archive,
  dirTempSync,
  fileWriteSync,
  fileTempSync,
  AllowedFiles,
  getDialogMediaFilters,
  dialogOpen,
  FileData,
} from '../../services/file-system/index';
import { PROJECT_IPC_EVENTS } from './events';

export const create = function (event: IpcMainInvokeEvent, project: unknown) {
  const dirPrefix = 'scrowl';
  const projectFileName = 'scrowl.project';
  const tempDir = dirTempSync(dirPrefix);

  if (tempDir.error) {
    return tempDir;
  }

  const filename = `${tempDir.pathName}/${projectFileName}`;

  return fileWriteSync(filename, project);
};

const write = function (source: string, filename: string): FileData {
  if (!source) {
    return {
      error: true,
      message: 'project requires a source',
    };
  }

  if (!filename) {
    return {
      error: true,
      message: 'project requires a filename',
    };
  }

  return archive(source, filename);
};

export const save = async function (
  event: IpcMainInvokeEvent,
  projectTempPath: string,
  isSaveAs: boolean,
  projectPath: string
) {
  const dialogOptions = {
    title: 'Scrowl - Save Project',
    filters: [
      {
        name: 'Scrowl Project',
        extensions: ['scrowl'],
      },
    ],
  };

  if (!projectPath || isSaveAs) {
    const dialogResult = await dialogSave(dialogOptions);

    if (dialogResult.error) {
      return dialogResult;
    }

    if (dialogResult.filePath) {
      projectPath = dialogResult.filePath;
    }
  }

  return write(projectTempPath, projectPath);
};

export const importFile = async function (
  event: IpcMainInvokeEvent,
  fileTypes: Array<AllowedFiles>,
  projectTempPath: string
) {
  const filters = getDialogMediaFilters(fileTypes);

  if (!filters.length) {
    return {
      error: true,
      message: 'valid file types need to be declared for importing',
    };
  }

  const dialogOptions = {
    title: 'Scrowl - Import File',
    filters,
  };
  const dialogResult = await dialogOpen(dialogOptions);

  if (dialogResult.error) {
    return dialogResult;
  }

  if (!dialogResult.filePaths.length) {
    return {
      error: true,
      message: 'no files found/selected',
    };
  }

  return fileTempSync(dialogResult.filePaths[0], projectTempPath);
};

export const EVENTS: ModelEventProps[] = [
  {
    name: PROJECT_IPC_EVENTS.new,
    fn: create,
    type: 'invoke',
  },
  {
    name: PROJECT_IPC_EVENTS.save,
    fn: save,
    type: 'invoke',
  },
  {
    name: PROJECT_IPC_EVENTS.importFile,
    fn: importFile,
    type: 'invoke',
  },
];

export default {
  EVENTS,
  create,
  save,
  importFile,
};
