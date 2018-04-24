// 类型判断js代码
// ObjType.isString
// ObjType.isArray
// ObjType.isNumber

var ObjType = {};
for (var i = 0, type; type = ['String', 'Array', 'Number'][i++];) {
    (function(type) {
        ObjType['is' + type] = function(obj) {
            return Object.prototype.toString.call(obj) === '[object ' + type + ']';
        }
    })(type)
};


