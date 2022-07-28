/* eslint-disable react-hooks/exhaustive-deps */
import React from 'react';
import { Link } from 'react-router-dom';
import style from './styles.module.scss';
import { Button, Card, Icon, NavigationDrawer as Nav, Table } from '@owlui/lib';
import { Outline } from '../../components/accordion';
import { CardGrid } from '../../components/cardgrid';
import { sidebarItems, cards, filesList, topOutlineItems } from './data';
import { Project } from '../../models';

export const PageRoute = '/';
export const PageName = 'Home';

const TemplatesList = () => {
  const tempTemplatesQty = 6;

  return Array.from(Array(tempTemplatesQty), (e, i) => {
    return (
      <div key={i} className="owlui-grid-col-xs-2">
        <Card
          className={style.template}
          style={{ height: '110px', cursor: 'pointer' }}
        ></Card>
      </div>
    );
  });
};

const project = new Project();

export const PageElement = () => {
  project.ready();

  const isProcessing = project.useProcessing();
  const activeProject = project.useProjectData();
  const lastImport = project.useLastImport();

  const importFile = () => {
    project.importFile(['image']);
  };

  const Header = (
    <>
      <div>
        <h1 className={style.navTitle}>
          <Icon
            className={style.navTitleIcon}
            icon="school"
            aria-hidden="true"
          />
          <span>Scrowl</span>
        </h1>
      </div>
      <div className={style.navActions}>
        <div>
          <Button variant="link">
            <Link to="/settings">Settings</Link>
          </Button>
        </div>
        <div className={style.navDivider} />
        <div>
          <Button
            onClick={importFile}
            disabled={activeProject && activeProject.workingDir ? false : true}
          >
            Import Image
          </Button>
          {lastImport && (
            <>
              <div className={style.navDivider} />
              <img
                src={lastImport}
                alt="Example"
                style={{ width: 'auto', height: '100px' }}
              />
            </>
          )}
        </div>
      </div>
    </>
  );

  return (
    <>
      <div className="left-panel" style={{ overflowY: 'scroll' }}>
        <Outline items={topOutlineItems} />
        <Nav className={style.nav} header={Header} items={sidebarItems} />
      </div>
      <main className={style.main}>
        <section>
          <div>{isProcessing ? <div>WORKING ON IT</div> : ''}</div>
          <div>
            <CardGrid cards={cards} />
          </div>
        </section>
        <section className={style.filesList}>
          <div>
            <h2 className={style.sectionTitle}>Your Files</h2>
            <Table tableData={filesList} />
          </div>
        </section>
        <section className={style.templatesList}>
          <div>
            <h2 className={style.sectionTitle}>Templates</h2>
            <div className="owlui-grid-row">{TemplatesList()}</div>
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
