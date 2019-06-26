var util_conf = require('./util_conf.js')
const zerorpc = require("zerorpc")
let connection = new zerorpc.Client({'timeout': 20000})
connection.connect("tcp://127.0.0.1:" + util_conf.program_setting["python_port"])
exports.connection = connection
const {app, BrowserWindow, ipcMain, dialog, shell} = require('electron')

var util_conf = require('./util_conf.js')
let lang_is_ready = false

let main_win

function set_main_win(win) {
  main_win = win
}
exports.set_main_win = set_main_win


function notify_app_exit() {
  console.log("call notify_app_exit")
  main_win = null
  connection.invoke("app_exit")
}
exports.notify_app_exit = notify_app_exit

// app.on('will-quit', notify_app_exit)


// 创建菜单
let menu_template = [{
    label: '工具',
    submenu: [
      {
        label: '导出所有Erl功能配置',
        click: (item, focusedWindow) => {
          connection.invoke("export_all", "erl", util_conf.tool_setting["erl"], "cfg_game_config.json", (error, res) => {
            if(error) {
              console.error(error)
            } else {
              show_export_result_dialog(res)
            }
          })
        }
      },
      {
        label: '导出所有Lua功能配置',
        click: (item, focusedWindow) => {
          connection.invoke("export_all", "lua", util_conf.tool_setting["lua"], "cfg_game_config.json", (error, res) => {
            if(error) {
              console.error(error)
            } else {
              show_export_result_dialog(res)
            }
          })
        }
      },
      {
        label: '导出所有cs功能配置',
        click: (item, focusedWindow) => {
          connection.invoke("export_all", "cs", util_conf.tool_setting["cs"], "cfg_game_config.json", (error, res) => {
            if(error) {
              console.error(error)
            } else {
              show_export_result_dialog(res)
            }
          })
        }
      },
    ]
  },
  {
    label: '',
    type: 'separator'
  },
  {
    label: '重新加载数据',
    click: (item, focusedWindow) => {
      BrowserWindow.getFocusedWindow().reload()
      lang_is_ready = false
    }
  },
  {
    label: '测试',
    submenu: [
      {
        label: '开发者工具',
        click: function (item, focusedWindow) {
          if (focusedWindow) {
            focusedWindow.toggleDevTools()
          }
        }
      },
      {
        label: 'app目录',
        click: function (item, focusedWindow) {
          if (focusedWindow) {
            show_tips_dialog(app.getAppPath())
          }
        }
      },
      {
        label: '关闭python服务',
        click: function (item, focusedWindow) {
          connection.invoke("app_exit")
        }
      }
    ]
  }
]

function create_menu() {
    const { Menu } = require('electron')
    // const { remote } = require('electron') 在index.html页面中才能这样创建菜单
    // const { Menu, MenuItem } = remote
    const menu = Menu.buildFromTemplate(menu_template)
    Menu.setApplicationMenu(menu)
}

exports.create_menu = create_menu

let query_timer = null

// 查询多语言解析是否就绪了
function start_query_lang() {
  query_timer = setInterval(() =>
    connection.invoke("query_lang_is_ready", (error, res) => {
      if(error) {
        show_tips_dialog('查询多语言解析是否就绪出错啦：' + error.toString())
        clearInterval(query_timer)
        return
      }
      if (res === 'wait') {
        return
      }
      clearInterval(query_timer)
      main_win.send('on-lang-is-ready', res);
      lang_is_ready = true
    }), 2000
  )
}
exports.start_query_lang = start_query_lang

// ================================== 事件处理 ==================================
//设置每种配置的保存路径
ipcMain.on('on-setting-dir', (event, file_type) => {
  const options = {
    properties: ["openFile", "openDirectory"]
  }
  dialog.showOpenDialog(main_win, options, (dir) => {
    console.log(dir)
    if (dir == null)
      return
    event.sender.send('on-setting-dir-return', file_type, dir[0])
    util_conf.set_tool_export_dir(file_type, dir[0])
  })
})


ipcMain.on('on-show-tpl-file-in-dir', (event, filename) => {
  var path = require('path')
  // shell.openExternal(`file://${path.join(util_conf.cfg_game_config_path,filename)}`)
  var full_path = path.join(util_conf.cfg_game_config_path,filename)
  console.log(full_path)
  shell.showItemInFolder(`file://${full_path}`)
})
// 导出单个文件
ipcMain.on('on-export-file', (event, export_dict, file_type) => {
  if (!util_conf.tool_setting[file_type]) {
    show_tips_dialog("请先设置导出目录")
    return
  }
  connection.invoke("export_one_file", util_conf.tool_setting[file_type], export_dict, file_type, (error, res) => {
    if(error) {
      show_export_fail_dialog(error)
      return
    } 
    show_export_result_dialog(res)
  })
})

//导出sheet里的所有配置文件
ipcMain.on('on-export-by-sheet', (event, export_dict, sheet) => {
  connection.invoke("export_by_sheet", util_conf.tool_setting, export_dict, sheet, (error, res) => {
    if(error) {
      show_export_fail_dialog(error)
      return
    } 
    show_export_result_dialog(res)
  })
})

ipcMain.on('on-open-excel', (event, excle_file) => {
  console.log(app.getAppPath())
  var path = require('path')
  shell.openItem(path.join(util_conf.excel_src_path, excle_file))
})

//导出erl地图掩码文件
ipcMain.on('on-export-erl-map', (event, obj, map_name) => {
  if (!util_conf.tool_setting['c_map']) {
    show_tips_dialog("请先设置导出目录")
    return
  }
  connection.invoke("export_erl_map", util_conf.tool_setting['erl_map'], obj, map_name, (error, res) => {
    if(error) {
      show_export_fail_dialog(error)
      return
    } 
    show_export_result_dialog(res)
  })
})

//导出c地图掩码文件
ipcMain.on('on-export-c-map', (event, obj, map_name) => {
  if (!util_conf.tool_setting['c_map']) {
    show_tips_dialog("请先设置导出目录")
    return
  }
  connection.invoke("export_c_map", util_conf.tool_setting['c_map'], obj, map_name, (error, res) => {
    if(error) {
      show_export_fail_dialog(error)
    } else{
      show_export_result_dialog(res)
    }
  })
})

// 导出多语言
ipcMain.on('on-export-lang', (event, export_dict, file_type) => {
  if (!util_conf.tool_setting[file_type]) {
    show_tips_dialog("请先设置导出目录")
    return
  }
  connection.invoke("export_lang_file", util_conf.tool_setting[file_type], export_dict, file_type, (error, res) => {
    if(error) {
      show_export_fail_dialog(error)
      return
    } 
    show_export_result_dialog(res)
  })
})

//搜索
ipcMain.on('on-search', (event, searchstr, tab_datas) => {
  connection.invoke("do_search", searchstr, tab_datas, (error, res) => {
    if(error) {
      console.log(error.toString())
    } else{
      if (res === 0) 
        return
      event.sender.send('on-search-return', res)
    }
  })
})

//做多语言分页的初始化
ipcMain.on('on-open-mutil-lang-tab', (event) => {
  if (!lang_is_ready) {
    start_query_lang()
  }
})

function show_export_result_dialog(res) {
  if(res[0] == 0) {
      const info_options = {
        type: 'error',
        title: '导出失败',
        message: res[1].toString(),
        buttons: ['Ok']
      }
      dialog.showMessageBox(main_win, info_options)
    } else {
      const info_options = {
        type: 'info',
        title: '导出成功',
        message: "已保存到：" + res[1].toString(),
        buttons: ['Ok']
      }
      dialog.showMessageBox(main_win, info_options)
    }
}

function show_export_fail_dialog(error) {
  const info_options = {
    type: 'error',
    title: '导出失败',
    message: error.toString(),
    buttons: ['Ok']
  }
  dialog.showMessageBox(main_win, info_options)
}

function show_tips_dialog(tips) {
  const info_options = {
    type: 'info',
    title: '提示',
    message: tips,
    buttons: ['Ok']
  }
  dialog.showMessageBox(main_win, info_options)
}
