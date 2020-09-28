-define(RBYTE(V), proto_helper:rbyte(V)).
-define(RBOOL(V), proto_helper:rbool(V)).
-define(RINT16(V), proto_helper:rint16(V)).
-define(RUINT16(V), proto_helper:ruint16(V)).
-define(RINT32(V), proto_helper:rint32(V)).
-define(RUINT32(V), proto_helper:ruint32(V)).
-define(RINT64(V), proto_helper:rint64(V)).
-define(RUINT64(V), proto_helper:ruint64(V)).
-define(RFLOAT(V), proto_helper:rfloat(V)).
-define(RSTRING(V), proto_helper:rstring(V)).
-define(RTUPLE(V, Type), proto_helper:rtuple(V, Type)).
-define(RLIST(V, Type), proto_helper:rlist(V, Type)). 


-define(WBYTE(V), (proto_helper:wbyte(V))/binary).
-define(WBOOL(V), (proto_helper:wbool(V))/binary).
-define(WINT16(V), (proto_helper:wint16(V))/binary).
-define(WUINT16(V), (proto_helper:wuint16(V))/binary).
-define(WINT32(V), (proto_helper:wint32(V))/binary).
-define(WUINT32(V), (proto_helper:wuint32(V))/binary).
-define(WINT64(V), (proto_helper:wint64(V))/binary).
-define(WUINT64(V), (proto_helper:wuint64(V))/binary).
-define(WFLOAT(V), (proto_helper:wfloat(V))/binary).
-define(WSTRING(V), (proto_helper:wstring(V))/binary).
-define(WTUPLE(V, Type), (proto_helper:wtuple(V, Type))/binary).
-define(WLIST(V, Type), (proto_helper:wlist(V, Type))/binary). 

