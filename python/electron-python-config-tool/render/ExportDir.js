import { Input, Button } from 'shineout'
import React, { Component } from 'react';
const {ipcRenderer,remote} = window.require('electron')


class ExportDirCtrl extends Component {
    render() {
      return (
        <Input.Group >
          <span>{this.props.type + "导出目录："}</span>
          <Input id={"input_" + this.props.type} readOnly={true} value={remote.app.util_conf.tool_setting[this.props.type]}/>
          <Button type="primary" size="small" onClick={(e) => this.on_setting_dir()}>设置</Button>
        </Input.Group>
      )
  }

  on_setting_dir() {
    ipcRenderer.send('on-setting-dir', this.props.type)
  }
}

ipcRenderer.on('on-setting-dir-return', (event, type, path) => {
  document.getElementById('input_' + type).value = path
  remote.app.util_conf.set_tool_export_dir(type, path)
})

export default ExportDirCtrl
