// 读取配置的工具方法模块
const {app} = require('electron')

var fs = require('fs')
var path = require('path')

const tool_setting_path = path.join(app.getPath("home"), ".config_tool_setting.json")

function load_json_file(path) {
    var result = {}
    try {
        result = JSON.parse(fs.readFileSync(path))
    } catch(e) {
        console.log(e.name + ' : ' + e.message);
    }
    return result
}


var program_setting = load_json_file(path.join(app.getAppPath(), 'program_setting.json'))
var tool_setting = load_json_file(tool_setting_path)

const cfg_game_config_path = path.join(app.getAppPath(), "config")
const excel_src_path = path.resolve(app.getAppPath(), program_setting["excel_src_path"]) //策划的excel配置目录
const map_obj_path = path.join(excel_src_path, "map")  //.obj文件所在目录
const map_conf_path = path.join(cfg_game_config_path, "map_conf.json")


var map_conf_setting = load_json_file(map_conf_path)


function set_tool_export_dir(file_type, dir) {
    tool_setting[file_type] = dir
    fs.writeFileSync(tool_setting_path, JSON.stringify(tool_setting, null, '\t'), 'utf8')
}


exports.program_setting      = program_setting
exports.tool_setting         = tool_setting
exports.map_conf_setting     = map_conf_setting
exports.set_tool_export_dir  = set_tool_export_dir
exports.cfg_game_config_path = cfg_game_config_path
exports.map_conf_path        = map_conf_path
exports.map_obj_path         = map_obj_path
exports.excel_src_path       = excel_src_path


