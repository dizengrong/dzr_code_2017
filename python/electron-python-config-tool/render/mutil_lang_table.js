import React, { Component } from 'react';
import { Table } from 'shineout'
const {ipcRenderer, remote} = window.require('electron');

const fs = window.require('fs')
const path = window.require('path')
const linkStyle = {color:'black'}

class MutilLangTable extends Component {
  constructor(props) {
    super(props);
    this.init_src_data()
    // console.log(this.src_tab_data)
    this.init_export_data()
  }

  init_src_data() {
    this.src_tab_data = []
    var count = 1
    for (var key in this.props.data['lang_src_dict']) {
      for (var i = this.props.data['lang_src_dict'][key].length - 1; i >= 0; i--) {
        var dict = this.props.data['lang_src_dict'][key][i]
        var data = {
          "id": count,
          "excle_file": key,
          "sheet": dict["sheet"],
          "cols_with_name": dict["cols_with_name"].join(', ')
        }
        for (var j = 0; j < dict["cols_with_name"].length; j++) {
          data['zh_col' + j] = dict["cols_with_name"][j]
        }
        this.src_tab_data.push(data)
        count += 1
      }
    }
  }

  init_export_data() {
    this.export_tab_data = []
    var count = 1
    for (var key in this.props.data['lang_export_files']) {
      var data = {
        "id": count,
        "excle_file": key,
        "tpl": this.props.data['lang_export_files'][key][0]
      }
      this.export_tab_data.push(data)
      count += 1
    }
    console.log(this.export_tab_data)
  }

  get_src_columns() {
    var columns = [
      { 
        title: 'id', 
        render: 'id', 
        align: 'center', 
        width: 100,
      },
      { 
        title: 'Excel文件（点击打开）', 
        render: d => (<a style={linkStyle} onClick={(e) => this.on_open_excel(d, e)}>{d.excle_file}</a>),
      },
      { title: 'Sheet名称', render: 'sheet' },
      { title: '中文列', render: 'cols_with_name' }, //不支持动态类，只能这么做
    ]
    // for (var i = 0; i < this.props.data['max_zh_col_size']; i++) {
    //   var col = { 
    //     title: '中文列' + (i + 1), 
    //     render: d => `${d['zh_col' + i]}`,
    //   }
    //   columns.push(col)
    // }
    return columns
  }

  get_export_columns() {
    var columns = [
      { 
        title: 'id', 
        render: 'id', 
        align: 'center', 
        width: 100,
      },
      { 
        title: 'Excel文件（点击打开）', 
        render: d => (<a style={linkStyle} onClick={(e) => this.on_open_excel(d, e)}>{d.excle_file}</a>),
      },
      { 
        title: '翻译配置(点击导出)', 
        render: d => (<a style={linkStyle} onClick={(e) => this.on_export(d, 'erl', e)}>{d['tpl']}</a>),
      },
    ]
    return columns
  }

  on_open_excel(row_data) {
    ipcRenderer.send('on-open-excel', row_data.excle_file)
  }

  on_export(row_data, file_type) {
    console.log(this.props.data['lang_export_tpl_dict'][row_data.tpl])
    ipcRenderer.send('on-export-lang', this.props.data['lang_export_tpl_dict'][row_data.tpl], file_type)
  }

  render() {
    return (
      <div style={{ height: '100%', marginBottom: 40 }}>
        <Table keygen="id" size="small" columns={this.get_src_columns()} bordered data={this.src_tab_data} />
        <Table keygen="id" size="small" columns={this.get_export_columns()} bordered data={this.export_tab_data} />
      </div>
      )
  }
}

export default MutilLangTable
