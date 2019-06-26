const {app, BrowserWindow} = require('electron')
var util_conf = require('./util_conf.js')
app.util_conf = util_conf

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
let win
let pyProc

function createWindow () {
  win = new BrowserWindow({
    // width: 1100, 
    // height: 660,
    // fullscreen: true,
    show:false,
    title:"配置生成工具",
    webPreferences: {
      nodeIntegration: true
    }});
  if (util_conf.program_setting["dev_mode"]){
    win.loadURL('http://localhost:3000/');
    win.webContents.openDevTools();
  } else {
    win.webContents.loadFile(path.resolve(__dirname, '..', "./render_process/index.html"));
    // win.webContents.openDevTools();
    console.log(path.resolve(__dirname, '..', "./render_process/index.html"))
  }
  win.maximize()
  win.show()

  //创建连接python-server的客户端连接
  var js_client = require('./js_client.js')
  js_client.set_main_win(win)
  js_client.create_menu()
  // js_client.start_query_lang(win)
  
  // 当 window 被关闭，这个事件会被触发。
  win.on('closed', () => { 
    win = null
    js_client.notify_app_exit()
  })
}

// Electron 会在初始化后并准备
// 创建浏览器窗口时，调用这个函数。
// 部分 API 在 ready 事件触发后才能使用。
app.on('ready', createWindow)

// 当全部窗口关闭时退出。
app.on('window-all-closed', () => {
  // 在 macOS 上，除非用户用 Cmd + Q 确定地退出，
  // 否则绝大部分应用及其菜单栏会保持激活。
  if (process.platform !== 'darwin') {
    app.quit()
  }
})

app.on('activate', () => {
  // 在macOS上，当单击dock图标并且没有其他窗口打开时，
  // 通常在应用程序中重新创建一个窗口。
  if (win === null) {
    createWindow()
  }
})

const path=require('path')

const createPyProc = () => {
  console.log('creating python server...')
  let port = util_conf.program_setting["python_port"]
  let excel_src_path = util_conf.excel_src_path
  let config_path = util_conf.cfg_game_config_path
  console.log('port:' + port)
  console.log('excel_src_path:' + excel_src_path)
  console.log('config_path:' + config_path)
  if (util_conf.program_setting["dev_mode"]){
    let script = path.resolve(__dirname, '..', 'py', 'main.py')
    let pypath = path.resolve(__dirname, '..', 'py', '.env', 'Scripts', 'python3.exe')
    // let pypath = path.join('C:/Python36/python3.exe')
    console.log('pypath:' + pypath)
    pyProc = require('child_process').spawn(pypath, [script, port, excel_src_path, config_path])
    // console.log(pyProc)
  }else{
    let exePath = path.join(app.getAppPath(), 'py','main.exe')
    console.log('exePath:' + exePath)
    pyProc=require('child_process').execFile(exePath, [port, excel_src_path, config_path])
  }
  if (pyProc != null) {
    console.log('child process success')
  }

  // 捕获标准输出并将其打印到控制台
  pyProc.stdout.on('data', function (data) {
      console.log('child stdout:\n' + data);
  });

  // 捕获标准错误输出并将其打印到控制台
  pyProc.stderr.on('data', function (data) {
      console.log('child stderr:\n' + data);
  });

  // 注册子进程关闭事件
  pyProc.on('exit', function (code, signal) {
      console.log('child process exit:' + code);
  });
  console.log(`This process is pid ${process.pid}`);
  console.log(`child process is pid ${pyProc.pid}`);
}
const exitPyProc = () => {
  pyProc.kill('SIGKILL')
  require('child_process').spawnSync('taskkill.exe', ['/pid:' + pyProc.pid])
  console.log('python process exit')
  pyProc = null
}

app.on('ready', createPyProc)
app.on('will-quit', exitPyProc)



