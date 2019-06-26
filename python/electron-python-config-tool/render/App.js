import React, { Component } from 'react';
import './App.css';
import { Tabs, Spin } from 'shineout'
import MapConfTable from './MapTable.js'
import ExportDirCtrl from './ExportDir.js'
import { Grid } from 'shineout'
const {ipcRenderer} = window.require('electron')

const tabStyle = { padding: '1px 1px' }
const panelStyle = { padding: '0px 1px' }
const gridStyle = { padding: '0px 5px 10px 0px' }

class App extends Component {
  handleTabChange(index) {
    console.log(index)
    if (index == 2) { //切换到多语言tab页了，如果它没有初始化，则在这里做
      ipcRenderer.send('on-open-mutil-lang-tab')
    }
  }
  render() {
    return (
      <div className="App">
        <Tabs style={tabStyle} defaultActive={0} onChange={this.handleTabChange}>
          <Tabs.Panel style={panelStyle} tab="游戏功能配置">
            <div className="ExportDir">
              <Grid width={1 / 3} style={gridStyle}>
                <div><ExportDirCtrl type="erl"></ExportDirCtrl></div>
              </Grid> 
              <Grid width={1 / 3} style={gridStyle}>
                <ExportDirCtrl type="lua"></ExportDirCtrl>
              </Grid>
              <Grid width={1 / 3} style={gridStyle}>
                <ExportDirCtrl type="cs"></ExportDirCtrl>
              </Grid>
            </div>
            <div id="div_module_data"></div>
          </Tabs.Panel>
          <Tabs.Panel style={panelStyle} tab="地图配置">
            <div className="ExportDir">
              <Grid width={1 / 3} style={gridStyle}>
                <div><ExportDirCtrl type="c_map"></ExportDirCtrl></div>
              </Grid> 
              <Grid width={1 / 3} style={gridStyle}>
                <ExportDirCtrl type="erl_map"></ExportDirCtrl>
              </Grid>
              <Grid width={1 / 3} style={gridStyle}>
              </Grid>
            </div>
            <MapConfTable></MapConfTable>
          </Tabs.Panel>
          <Tabs.Panel style={panelStyle} tab="多语言翻译配置">
            <div id="div_loading">
              <Spin name="fading-circle" />
            </div>
            <div id="div_lang_data"></div>
          </Tabs.Panel>
        </Tabs>
      </div>
    );
  }
}

export default App;
