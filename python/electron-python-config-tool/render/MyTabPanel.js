import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import { Input } from 'shineout'
import { Table,Tag } from 'shineout'
var mod_util = require('./mod_util.js')
const {ipcRenderer, remote} = window.require('electron')
const {Menu, MenuItem} = remote;

const fs = window.require('fs')

const searchtrlStyle = { width: '100%' }
const linkStyle = {color:'black'}

let tab_origin_datas = []


class PanelTable extends Component {
  constructor(props) {
    super(props);
    this.last_search = ''
    this.get_data_from_json()
    this.state = {data: tab_origin_datas};
    PanelTable.update_data = this.update_data = this.update_data.bind(this);
  }

  componentDidMount() {
  }

  componentWillUnmount() {
  }

  get_data_from_json() {
    // console.log(this.props.xml_file)
    var datas = JSON.parse(fs.readFileSync(this.props.xml_file))
    var count = 0
    var result_dict = {}
    for (var i = 0, len = datas['files'].length; i < len; i++) {
      var exports_list = datas['files'][i]["export"]
      for (var j = 0, export_len = exports_list.length; j < export_len; j++) {
        for (var k = 0, dict_len = exports_list[j]["dict"].length; k < dict_len; k++) {
          var file_key = datas['files'][i]["excle_file"] + "|" + exports_list[j]["dict"][k].sheet
          var dict
          if (result_dict[file_key]) {
            dict = result_dict[file_key]
          } else {
            dict = {
              "id": count + 1, 
              "export_num": 0,
              "excle_file": datas['files'][i]["excle_file"],
              "sheet": exports_list[j]["dict"][k].sheet
            }
            count = count + 1
            result_dict[file_key] = dict
          }
          var cur_export_num = dict["export_num"]
          var tpl = exports_list[j]["tpl"]
          tpl = tpl.substring(0, tpl.length - 4)
          var extension = mod_util.getFileExtension(tpl)
          dict["export_" + extension] = {
            "tpl": tpl,
            "dict": exports_list[j]["dict"]
          }
          dict["export_num"] = cur_export_num + 1
          // console.log(dict)
        }
      }
    }
    // 将结果的字典转成字典的数组
    // var result_array = []
    for (var key in result_dict) {
      tab_origin_datas.push(result_dict[key])
    }
    // return result_array
  }

  get_columns() {
    var columns = [
      { 
        title: 'id', 
        render: 'id', 
        align: 'center', 
        width: 40,
        sorter: order => (a, b) => {
          if (order === 'asc') 
            return a.id - b.id
          return b.id - a.id
        }
      },
      { 
        title: 'Excel文件（点击打开）', 
        render: d => (<a style={linkStyle} onClick={(e) => this.on_open_excel(d, e)}>{d.excle_file}</a>),
        sorter: order => (a, b) => {
          if (order === 'asc') 
            return a.excle_file.localeCompare(b.excle_file)
          return b.excle_file.localeCompare(a.excle_file)
        },
        rowSpan: (a, b) => a.excle_file === b.excle_file,
      },
      { title: 'Sheet名称', render: 'sheet' },
      // { title: 'erl配置（点击导出）', render: (d, i) => (d.export_erl ? <a style={linkStyle} onClick={(e) => this.on_open_tpl(d.export_erl.tpl)}>{d.export_erl.tpl}</a> : "")},
      // { title: 'lua配置（点击导出）', render: (d, i) => (d.export_lua ? <a style={linkStyle} onClick={(e) => this.on_open_tpl(d.export_lua.tpl)}>{d.export_lua.tpl}</a> : "")},
      // { title: 'c#配置（点击导出）', render: (d, i) => (d.export_cs ? <a style={linkStyle} onClick={(e) => this.on_open_tpl(d.export_lua.tpl)}>{d.export_cs.tpl}</a> : "")},
      { title: 'erl配置（点击导出）', render: (d, i) => (this.render_erl_cell(d))},
      { title: 'lua配置（点击导出）', render: (d, i) => (this.render_lua_cell(d))},
      { title: 'c#配置（点击导出）', render: (d, i) => (this.render_cs_cell(d))},
      { title: '操作', render: (d, i) => (<a onClick={(e) => this.on_export_by_sheet(d, d.sheet, e)}>导出该行配置</a>)},
      // { 
      //   title: '操作', 
      //   render: (d, i) => (<a onClick={(e) => this.on_export_by_file(d, i, e)}>导出此Excle配置</a>),
      //   rowSpan: (a, b) => a.excle_file === b.excle_file,
      // },
    ]
    return columns
  }

  render_erl_cell(d) {
    if (d.export_erl) {
      return <span>
        <Tag  onClick={() => this.on_open_tpl(d.export_erl.tpl)}>打开tpl</Tag> 
        <a style={linkStyle} onClick={(e) => this.on_export(d, 'erl', e)}>{d.export_erl.tpl}</a>
      </span>
    } else{
      return ""
    }
  }

  render_lua_cell(d) {
    if (d.export_lua) {
      return <span>
        <Tag  onClick={() => this.on_open_tpl(d.export_lua.tpl)}>打开tpl</Tag> 
        <a style={linkStyle} onClick={(e) => this.on_export(d, 'lua', e)}>{d.export_lua.tpl}</a>
      </span>
    } else{
      return ""
    }
  }

  render_cs_cell(d) {
    if (d.export_cs) {
      return <span>
        <Tag  onClick={() => this.on_open_tpl(d.export_cs.tpl)}>打开tpl</Tag> 
        <a style={linkStyle} onClick={(e) => this.on_export(d, 'cs', e)}>{d.export_cs.tpl}</a>
      </span>
    } else{
      return ""
    }
  }

  on_open_excel(row_data) {
    ipcRenderer.send('on-open-excel', row_data.excle_file)
  }

  on_export(row_data, file_type) {
    console.log(row_data)
    ipcRenderer.send('on-export-file', row_data, file_type)
  }

  on_open_tpl(file) {
    ipcRenderer.send('on-show-tpl-file-in-dir', file + '.tpl')

  }

  on_export_by_sheet(row_data, sheet) {
    console.log(row_data)
    ipcRenderer.send('on-export-by-sheet', row_data, sheet)
  }

  on_export_by_file(row_data, col) {
    console.log(col)
    console.log(row_data)
  }

  on_click(row_data, index) {
    // const menu = new Menu()
    // menu.append(new MenuItem({
    //     label: '打开' + row_data.export_erl.tpl + "所在目录",
    //     click:function() {}
    // }))
    // menu.popup({ window: remote.getCurrentWindow()})
  }

  do_search(d) {
    if (d.length > 0) {
      ipcRenderer.send('on-search', d, tab_origin_datas)
    } else {
      this.update_data(tab_origin_datas)
    }
  }

  update_data(res) {
    this.setState({data: res})
  }

  render() {
    return (
      <div>
        <Input.Group style={searchtrlStyle}>
          <Input placeholder="模糊匹配搜索" delay={200} onChange={(d) => (this.do_search(d))}/>
        </Input.Group>
        <div id="div_for_conf_tab" style={{ height: '100%', marginBottom: 40 }}>
          <Table keygen="id" size="small" columns={this.get_columns()} onRowClick={this.on_click} bordered data={this.state.data}></Table>
        </div>
      </div>
      )
  }
}


export default PanelTable

