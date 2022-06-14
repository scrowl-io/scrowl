import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { Default as Btn } from '@owlui/button';
import style from './styles.module.scss';
import {
  Appearance,
  Preferences,
} from '../../../main/services/internal-storage/handlers/preferences/index.types';

export const PageRoute = '/settings';
export const PageName = 'Settings';

export const PageElement = () => {
  const [preferences, setPreferences] = useState<Preferences>();

  useEffect(() => {
    window.electronAPI.ipcRenderer.invoke('get-preferences-list').then(data => {
      setPreferences(data);
    });
  }, []);

  const handleChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setPreferences({ appearance: event.target.value as Appearance });
  };

  const handleSave = () => {
    window.electronAPI.ipcRenderer.invoke('set-preferences', {
      appearance: preferences?.appearance,
    });
  };

  const RadioButton = ({
    label,
    value,
    checked,
    onChange,
  }: {
    label: string;
    value: Appearance;
    checked: boolean;
    onChange: (event: React.ChangeEvent<HTMLInputElement>) => void;
  }) => {
    return (
      <div className="radio">
        <label>
          <input
            type="radio"
            value={value}
            checked={checked}
            onChange={onChange}
          />
          {label}
        </label>
      </div>
    );
  };

  return (
    <>
      <main className={style.main}>
        <section style={{ padding: '1rem' }}>
          <h1>Settings</h1>
          <h2>Appearance</h2>
          <fieldset>
            <legend>Change the appearance of Scrowl's workspace:</legend>
            <RadioButton
              label="Light"
              value="light"
              checked={preferences?.appearance === 'light'}
              onChange={handleChange}
            />
            <RadioButton
              label="Dark"
              value="dark"
              checked={preferences?.appearance === 'dark'}
              onChange={handleChange}
            />
          </fieldset>
          <div>
            <Btn variant="primary" onClick={handleSave}>
              Save
            </Btn>
            <Btn variant="link">
              <Link to="/">Back to Home</Link>
            </Btn>
          </div>
        </section>
      </main>
    </>
  );
};

export default {
  PageName,
  PageRoute,
  PageElement,
};
