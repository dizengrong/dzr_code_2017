// 杂项方法模块

function getFileExtension(file){
  var filename=file;
  var index1=filename.lastIndexOf(".");
  var index2=filename.length;
  var type=filename.substring(index1 + 1,index2);
  return type;
}


module.exports = {
  getFileExtension: getFileExtension
}

