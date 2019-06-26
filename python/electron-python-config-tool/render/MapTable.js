import React, { Component } from 'react';
import { Table } from 'shineout'
const {ipcRenderer,remote} = window.require("electron");

const fs = window.require('fs')
const path = window.require('path')
const linkStyle = {color:'black'}

let tab_data = []

class MapConfTable extends Component {
  constructor(props) {
    super(props);
    this.get_datas();
    console.log(tab_data)
    this.state = {data: tab_data};
  }

  get_datas() {
    var map_conf_dict = remote.app.util_conf.map_conf_setting
    var files = fs.readdirSync(remote.app.util_conf.map_obj_path)
    for (var i = files.length - 1; i >= 0; i--) {
        if(path.extname(files[i]) === '.obj'){
            var basename = path.basename(files[i], '.obj')
            var c_val
            var map_id
            if (map_conf_dict[basename]) {
                c_val = 'data_map_' + map_conf_dict[basename] + '.c'
                map_id = map_conf_dict[basename]
            } else {
                c_val = basename + "没有添加配置，无法导出"
                map_id = 0
            }
            var dict = {
                'map_id': map_id,
                'obj': files[i],
                'erl': basename + '.erl',
                'c': c_val
            }
            tab_data.push(dict)
        }
    }
  }

  get_columns() {
    var columns = [
      { 
        title: 'map_id', 
        render: 'map_id', 
        align: 'center', 
        width: 100,
        sorter: order => (a, b) => {
          if (order === 'asc') 
            return a.map_id - b.map_id
          return b.map_id - a.map_id
        },
      },
      { title: '地图源文件', render: 'obj', align: 'center'},
      { 
        title: '导出的Erlang文件', 
        align: 'center',
        render: 
          (d, i) => (<a style={linkStyle} onClick={(e) => this.on_export_erl_map(d.obj, d.erl, e)}>{d.erl}</a>)
      },
      { 
        title: '导出的C文件', 
        align: 'center',
        render: 
          (d, i) => (<a style={linkStyle} onClick={(e) => this.on_export_c_map(d.obj, d.c, e)}>{d.c}</a>)
      },
    ]
    return columns
  }

  on_export_erl_map(obj, map_name){
    obj = path.join(remote.app.util_conf.map_obj_path, obj)
    ipcRenderer.send('on-export-erl-map', obj, map_name)
  }

  on_export_c_map(obj, map_name){
    obj = path.join(remote.app.util_conf.map_obj_path, obj)
    console.log(obj)
    ipcRenderer.send('on-export-c-map', obj, map_name)
  }

  render() {
    return (
      <div style={{ height: '100%', marginBottom: 40 }}>
        <Table  keygen="map_id" size="small" columns={this.get_columns()} bordered data={this.state.data} />
      </div>
      )
  }
}

export default MapConfTable
