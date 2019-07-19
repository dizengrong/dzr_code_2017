import React, { Component } from 'react';
// import ReactDOM from 'react-dom';
import { Table, Tag } from 'shineout'
import axios from 'axios';

// const linkStyle = {color:'blue'}

class SvrTable extends Component {
  constructor(props) {
    super(props);
    this.state = {data: []};
    this.fetch_svr_list()
    SvrTable.update_data = this.update_data = this.update_data.bind(this);
  }

  componentDidMount() {
  }

  componentWillUnmount() {
  }

  fetch_svr_list() {
    axios.get('http://localhost:8080/v1/svr_list')
      .then(res => {
        console.log(res.data)
        this.update_data(res.data.data)
      });
  }

  get_columns() {
    var columns = [
      { 
        title: 'id', 
        render: 'id', 
        align: 'center', 
        sorter: order => (a, b) => {
          if (order === 'asc') 
            return a.id - b.id
          return b.id - a.id
        }
      },
      { 
        title: '游戏服ServerID', 
        render: 'svr_no', 
        align: 'center', 
        sorter: order => (a, b) => {
          if (order === 'asc') 
            return a.svr_no - b.svr_no
          return b.svr_no - a.svr_no
        }
      },
      { title: '游戏服名称', render: 'name' },
      { title: '内网地址', render: 'inner_ip' },
      { title: '连接端口', render: 'net_port' },
      { title: '后台web端口', render: 'web_port' },
      { title: '操作', render: (d, i) => (this.render_status_cell(d))},
    ]
    return columns
  }

  render_status_cell(d) {
    return <span>
      <a  onClick={(e) => this.on_fetch_status(d.svr_no)}>获取状态</a>
      <Tag type="success">状态：{d.status}</Tag> 
    </span>
  }

  on_fetch_status(server_id) {
    console.log(server_id)
    axios.get('http://localhost:8080/v1/svr_status?server_id=' + server_id)
      .then(res => {
        console.log(res.data)
        for (var i = this.state.data.length - 1; i >= 0; i--) {
          if (this.state.data[i].svr_no == server_id) {
            this.state.data[i].status = res.data.status
          }
        }
        this.update_data(this.state.data)
      });
  }

  update_data(res) {
    this.setState({data: res})
  }

  render() {
    return (
      <div>
        <div id="div_for_conf_tab" style={{ height: '100%', marginBottom: 40 }}>
          <Table keygen="id" size="small" columns={this.get_columns()} onRowClick={this.on_click} bordered data={this.state.data}></Table>
        </div>
      </div>
      )
  }
}


export default SvrTable

