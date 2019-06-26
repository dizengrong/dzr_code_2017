import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';
import App from './App';
import PanelTable from './MyTabPanel.js'
import MutilLangTable from './mutil_lang_table.js'
import * as serviceWorker from './serviceWorker';
import { Button } from 'shineout'
const {ipcRenderer, remote} = window.require('electron');
var path = require('path')

ReactDOM.render(<App />, document.getElementById('root'));

let tab = <PanelTable xml_file={path.join(remote.app.util_conf.cfg_game_config_path, "cfg_game_config.json")}></PanelTable>;

let tab2 = ReactDOM.render(tab, document.getElementById('div_module_data'));

ipcRenderer.on('on-search-return', (event, res) => {
  tab2.update_data(res)
})


// let ctrl = null;
// let ctrl = <Button ></Button>;
ipcRenderer.on('on-lang-is-ready', (event, res) => {
    console.log(res)
    var child=document.getElementById("div_loading");
    child.parentNode.removeChild(child);
    let ctrl = <MutilLangTable data={res}></MutilLangTable>;
    ReactDOM.render(ctrl, document.getElementById('div_lang_data'));
})


// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
