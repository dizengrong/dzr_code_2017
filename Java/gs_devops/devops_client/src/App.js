import React from 'react';
import logo from './logo.svg';
import './App.css';
import { Tabs, Spin } from 'shineout'
import SvrTable from './svr_list.js'

const tabStyle = { padding: '1px 1px' }
const panelStyle = { padding: '0px 1px' }


function App() {
  return (
    <div className="App">
      <Tabs style={tabStyle} defaultActive={0}>
          <Tabs.Panel style={panelStyle} tab="游戏服列表">
            <SvrTable></SvrTable>
          </Tabs.Panel>
        </Tabs>
    </div>
  );
}

export default App;
