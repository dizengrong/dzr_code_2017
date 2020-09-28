-module (gen_protocol_of_cs).
-compile([export_all]).


do(GameProtos, CommonProtos) ->
	put({?MODULE, common_protos}, CommonProtos),
	[write_c(P) || P <- GameProtos],
	write_public_class_c(CommonProtos),
	ok.


write_c({MsgName, Fields}) ->
	DataDes = Fields,
	Id = gen_protocol_of_erl:get_msg_code(MsgName),
	CreateClass = MsgName,
	Filename = server_config:get_conf(client_pt_dir) ++ CreateClass ++ ".cs",
	case file:open(Filename, [write, {encoding, utf8}]) of
		{ok, File} ->
			file:write(File, "using System.Collections;\r\n"),
			file:write(File, "using System.Collections.Generic;\r\n"),
			file:write(File, "\r\n"),
			
			file:write(File, "public class " ++ CreateClass ++ " : st.net.NetBase.Pt {\r\n"),
			
			file:write(File, "\tpublic " ++ CreateClass ++ "()\r\n"),
			file:write(File, "\t{\r\n"),
			file:write(File, "\t\tId = 0x" ++ erlang:integer_to_list(Id, 16) ++ ";\r\n"),
			file:write(File, "\t}\r\n"),
			
			file:write(File, "\tpublic override st.net.NetBase.Pt createNew()\r\n"),
			file:write(File, "\t{\r\n"),
			file:write(File, "\t\treturn new " ++ CreateClass ++ "();\r\n"),
			file:write(File, "\t}\r\n"),
	
			FunMakeFun = fun({FieldType,FieldName,FieldDefault}) -> make_c_fun(File,FieldName,FieldType,FieldDefault) end,
			lists:foreach(FunMakeFun, DataDes),
			
			
			make_c_from_binary(File,DataDes),
			file:write(File, "\r\n"),
			
			make_c_to_binary(File,DataDes),
			file:write(File, "\r\n"),
			
			file:write(File, "}\r\n"),
	
			file:close(File);			
		{error, Reason} -> io:format("write file error,filename=~s,r=~p\n",[Filename,Reason])
	end.
make_c_fun(File,ListFieldName,{repeated,"int8"},_ListFieldDefault) ->
	file:write(File, "\tpublic List<byte> " ++ ListFieldName ++ " = new List<byte>();\r\n");
make_c_fun(File,ListFieldName,{repeated,"uint8"},_ListFieldDefault) ->
	file:write(File, "\tpublic List<byte> " ++ ListFieldName ++ " = new List<byte>();\r\n");
make_c_fun(File,ListFieldName,{repeated,"int16"},_ListFieldDefault) ->
	file:write(File, "\tpublic List<short> " ++ ListFieldName ++ " = new List<short>();\r\n");
make_c_fun(File,ListFieldName,{repeated,"uint16"},_ListFieldDefault) ->
	file:write(File, "\tpublic List<ushort> " ++ ListFieldName ++ " = new List<ushort>();\r\n");
make_c_fun(File,ListFieldName,{repeated,"int32"},_ListFieldDefault) ->
	file:write(File, "\tpublic List<int> " ++ ListFieldName ++ " = new List<int>();\r\n");
make_c_fun(File,ListFieldName,{repeated,"uint32"},_ListFieldDefault) ->
	file:write(File, "\tpublic List<uint> " ++ ListFieldName ++ " = new List<uint>();\r\n");
make_c_fun(File,ListFieldName,{repeated,"int64"},_ListFieldDefault) ->
	file:write(File, "\tpublic List<long> " ++ ListFieldName ++ " = new List<long>();\r\n");
make_c_fun(File,ListFieldName,{repeated,"uint64"},_ListFieldDefault) ->
	file:write(File, "\tpublic List<ulong> " ++ ListFieldName ++ " = new List<ulong>();\r\n");
make_c_fun(File,ListFieldName,{repeated,"string"},_ListFieldDefault) ->
	file:write(File, "\tpublic List<string> " ++ ListFieldName ++ " = new List<string>();\r\n");
make_c_fun(File,ListFieldName,{repeated,"float"},_ListFieldDefault) ->
	file:write(File, "\tpublic List<float> " ++ ListFieldName ++ " = new List<float>();\r\n");
make_c_fun(File,ListFieldName,{repeated,"double"},_ListFieldDefault) ->
	file:write(File, "\tpublic List<double> " ++ ListFieldName ++ " = new List<double>();\r\n");
make_c_fun(File,ListFieldName,{repeated,ListDes},_ListFieldDefault) ->
	case lists:keyfind(ListDes, 1, get({?MODULE, common_protos})) of
		false -> skip;
		_ -> 	
			ListDes2 = get_common_short_type(ListDes),
			file:write(File, "\tpublic List<st.net.NetBase." ++ ListDes2 ++ 
						   "> " ++ ListFieldName ++ " = new List<st.net.NetBase." ++ 
						   ListDes2 ++ ">();\r\n")
	end;
make_c_fun(File,FieldName,"int8",_FieldDefault) -> file:write(File, "\tpublic byte " ++ FieldName ++ ";\r\n");
make_c_fun(File,FieldName,"uint8",_FieldDefault) -> file:write(File, "\tpublic byte " ++ FieldName ++ ";\r\n");
make_c_fun(File,FieldName,"int16",_FieldDefault) -> file:write(File, "\tpublic short " ++ FieldName ++ ";\r\n");
make_c_fun(File,FieldName,"uint16",_FieldDefault) -> file:write(File, "\tpublic ushort " ++ FieldName ++ ";\r\n");
make_c_fun(File,FieldName,"int32",_FieldDefault) -> file:write(File, "\tpublic int " ++ FieldName ++ ";\r\n");
make_c_fun(File,FieldName,"uint32",_FieldDefault) -> file:write(File, "\tpublic uint " ++ FieldName ++ ";\r\n");
make_c_fun(File,FieldName,"int64",_FieldDefault) -> file:write(File, "\tpublic long " ++ FieldName ++ ";\r\n");
make_c_fun(File,FieldName,"uint64",_FieldDefault) -> file:write(File, "\tpublic ulong " ++ FieldName ++ ";\r\n");
make_c_fun(File,FieldName,"string",_FieldDefault) -> file:write(File, "\tpublic string " ++ FieldName ++ ";\r\n");
make_c_fun(File,FieldName,"float",_FieldDefault) -> file:write(File, "\tpublic float " ++ FieldName ++ ";\r\n");
make_c_fun(File,FieldName,"double",_FieldDefault) -> file:write(File, "\tpublic double " ++ FieldName ++ ";\r\n");
make_c_fun(_File,_FieldName,_FieldType,_FieldDefault) -> ok.



make_c_from_binary_fun(File,FieldName,"int8") -> file:write(File, "\t\t" ++ FieldName ++ " = reader.Read_byte();\r\n");
make_c_from_binary_fun(File,FieldName,"uint8") -> file:write(File, "\t\t" ++ FieldName ++ " = reader.Read_byte();\r\n");
make_c_from_binary_fun(File,FieldName,"int16") -> file:write(File, "\t\t" ++ FieldName ++ " = reader.Read_short();\r\n");
make_c_from_binary_fun(File,FieldName,"uint16") -> file:write(File, "\t\t" ++ FieldName ++ " = reader.Read_ushort();\r\n");
make_c_from_binary_fun(File,FieldName,"int32") -> file:write(File, "\t\t" ++ FieldName ++ " = reader.Read_int();\r\n");
make_c_from_binary_fun(File,FieldName,"uint32") -> file:write(File, "\t\t" ++ FieldName ++ " = reader.Read_uint();\r\n");
make_c_from_binary_fun(File,FieldName,"int64") -> file:write(File, "\t\t" ++ FieldName ++ " = reader.Read_long();\r\n");
make_c_from_binary_fun(File,FieldName,"uint64") -> file:write(File, "\t\t" ++ FieldName ++ " = reader.Read_ulong();\r\n");
make_c_from_binary_fun(File,FieldName,"string") -> file:write(File, "\t\t" ++ FieldName ++ " = reader.Read_str();\r\n");
make_c_from_binary_fun(File,FieldName,"float") -> file:write(File, "\t\t" ++ FieldName ++ " = reader.Read_float();\r\n");
make_c_from_binary_fun(File,FieldName,"double") -> file:write(File, "\t\t" ++ FieldName ++ " = reader.Read_double();\r\n");
make_c_from_binary_fun(File,FieldName,{repeated,"int8"}) -> 
	file:write(File, "\t\tushort len" ++ FieldName ++ " = reader.Read_ushort();\r\n"),
	file:write(File, "\t\t" ++ FieldName ++ " = new List<byte>();\r\n"),
	file:write(File, "\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t{\r\n"),
	file:write(File, "\t\t\tbyte listData = reader.Read_byte();\r\n"),
	file:write(File, "\t\t\t" ++ FieldName ++ ".Add(listData);\r\n"),
	file:write(File, "\t\t}\r\n");
make_c_from_binary_fun(File,FieldName,{repeated,"uint8"}) -> 
	file:write(File, "\t\tushort len" ++ FieldName ++ " = reader.Read_ushort();\r\n"),
	file:write(File, "\t\t" ++ FieldName ++ " = new List<byte>();\r\n"),
	file:write(File, "\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t{\r\n"),
	file:write(File, "\t\t\tbyte listData = reader.Read_byte();\r\n"),
	file:write(File, "\t\t\t" ++ FieldName ++ ".Add(listData);\r\n"),
	file:write(File, "\t\t}\r\n");
make_c_from_binary_fun(File,FieldName,{repeated,"int16"}) -> 
	file:write(File, "\t\tushort len" ++ FieldName ++ " = reader.Read_ushort();\r\n"),
	file:write(File, "\t\t" ++ FieldName ++ " = new List<short>();\r\n"),
	file:write(File, "\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t{\r\n"),
	file:write(File, "\t\t\tshort listData = reader.Read_short();\r\n"),
	file:write(File, "\t\t\t" ++ FieldName ++ ".Add(listData);\r\n"),
	file:write(File, "\t\t}\r\n");
make_c_from_binary_fun(File,FieldName,{repeated,"uint16"}) -> 
	file:write(File, "\t\tushort len" ++ FieldName ++ " = reader.Read_ushort();\r\n"),
	file:write(File, "\t\t" ++ FieldName ++ " = new List<ushort>();\r\n"),
	file:write(File, "\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t{\r\n"),
	file:write(File, "\t\t\tushort listData = reader.Read_ushort();\r\n"),
	file:write(File, "\t\t\t" ++ FieldName ++ ".Add(listData);\r\n"),
	file:write(File, "\t\t}\r\n");
make_c_from_binary_fun(File,FieldName,{repeated,"int32"}) -> 
	file:write(File, "\t\tushort len" ++ FieldName ++ " = reader.Read_ushort();\r\n"),
	file:write(File, "\t\t" ++ FieldName ++ " = new List<int>();\r\n"),
	file:write(File, "\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t{\r\n"),
	file:write(File, "\t\t\tint listData = reader.Read_int();\r\n"),
	file:write(File, "\t\t\t" ++ FieldName ++ ".Add(listData);\r\n"),
	file:write(File, "\t\t}\r\n");
make_c_from_binary_fun(File,FieldName,{repeated,"uint32"}) -> 
	file:write(File, "\t\tushort len" ++ FieldName ++ " = reader.Read_ushort();\r\n"),
	file:write(File, "\t\t" ++ FieldName ++ " = new List<uint>();\r\n"),
	file:write(File, "\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t{\r\n"),
	file:write(File, "\t\t\tuint listData = reader.Read_uint();\r\n"),
	file:write(File, "\t\t\t" ++ FieldName ++ ".Add(listData);\r\n"),
	file:write(File, "\t\t}\r\n");
make_c_from_binary_fun(File,FieldName,{repeated,"int64"}) -> 
	file:write(File, "\t\tushort len" ++ FieldName ++ " = reader.Read_ushort();\r\n"),
	file:write(File, "\t\t" ++ FieldName ++ " = new List<long>();\r\n"),
	file:write(File, "\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t{\r\n"),
	file:write(File, "\t\t\tlong listData = reader.Read_long();\r\n"),
	file:write(File, "\t\t\t" ++ FieldName ++ ".Add(listData);\r\n"),
	file:write(File, "\t\t}\r\n");
make_c_from_binary_fun(File,FieldName,{repeated,"uint64"}) -> 
	file:write(File, "\t\tushort len" ++ FieldName ++ " = reader.Read_ushort();\r\n"),
	file:write(File, "\t\t" ++ FieldName ++ " = new List<ulong>();\r\n"),
	file:write(File, "\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t{\r\n"),
	file:write(File, "\t\t\tulong listData = reader.Read_ulong();\r\n"),
	file:write(File, "\t\t\t" ++ FieldName ++ ".Add(listData);\r\n"),
	file:write(File, "\t\t}\r\n");
make_c_from_binary_fun(File,FieldName,{repeated,"string"}) -> 
	file:write(File, "\t\tushort len" ++ FieldName ++ " = reader.Read_ushort();\r\n"),
	file:write(File, "\t\t" ++ FieldName ++ " = new List<string>();\r\n"),
	file:write(File, "\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t{\r\n"),
	file:write(File, "\t\t\tstring listData = reader.Read_str();\r\n"),
	file:write(File, "\t\t\t" ++ FieldName ++ ".Add(listData);\r\n"),
	file:write(File, "\t\t}\r\n");
make_c_from_binary_fun(File,FieldName,{repeated,"float"}) -> 
	file:write(File, "\t\tushort len" ++ FieldName ++ " = reader.Read_ushort();\r\n"),
	file:write(File, "\t\t" ++ FieldName ++ " = new List<float>();\r\n"),
	file:write(File, "\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t{\r\n"),
	file:write(File, "\t\t\tfloat listData = reader.Read_float();\r\n"),
	file:write(File, "\t\t\t" ++ FieldName ++ ".Add(listData);\r\n"),
	file:write(File, "\t\t}\r\n");
make_c_from_binary_fun(File,FieldName,{repeated,"double"}) -> 
	file:write(File, "\t\tushort len" ++ FieldName ++ " = reader.Read_ushort();\r\n"),
	file:write(File, "\t\t" ++ FieldName ++ " = new List<double>();\r\n"),
	file:write(File, "\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t{\r\n"),
	file:write(File, "\t\t\tdouble listData = reader.Read_double();\r\n"),
	file:write(File, "\t\t\t" ++ FieldName ++ ".Add(listData);\r\n"),
	file:write(File, "\t\t}\r\n");
make_c_from_binary_fun(File,FieldName,{repeated,ListDes}) -> 
	ListDes2 = get_common_short_type(ListDes),
	file:write(File, "\t\tushort len" ++ FieldName ++ " = reader.Read_ushort();\r\n"),
	file:write(File, "\t\t" ++ FieldName ++ " = new List<st.net.NetBase." ++ ListDes2 ++ ">();\r\n"),
	file:write(File, "\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t{\r\n"),
	file:write(File, "\t\t\tst.net.NetBase." ++ ListDes2 ++ " listData = new st.net.NetBase." ++ ListDes2 ++ "();\r\n"),
	file:write(File, "\t\t\tlistData.fromBinary(reader);\r\n"),
	file:write(File, "\t\t\t" ++ FieldName ++ ".Add(listData);\r\n"),
	file:write(File, "\t\t}\r\n");
make_c_from_binary_fun(_File,_FieldName,_FieldType) -> ok.

make_c_from_binary(File,DataDes) ->
	file:write(File, "\tpublic override void fromBinary(byte[] binary)\r\n"),
	file:write(File, "\t{\r\n"),
	file:write(File, "\t\treader = new st.net.NetBase.ByteReader(binary);\r\n"),
	FunMakeFun = fun({FieldType, FieldName,_FieldDefault}) -> make_c_from_binary_fun(File,FieldName,FieldType) end,
	lists:foreach(FunMakeFun, DataDes),
	file:write(File, "\t}\r\n"),
	ok.

make_c_to_binary_fun(File,FieldName,"int8") -> file:write(File, "\t\twriter.write_byte(" ++ FieldName ++ ");\r\n");
make_c_to_binary_fun(File,FieldName,"uint8") -> file:write(File, "\t\twriter.write_byte(" ++ FieldName ++ ");\r\n");
make_c_to_binary_fun(File,FieldName,"int16") -> file:write(File, "\t\twriter.write_short(" ++ FieldName ++ ");\r\n");
make_c_to_binary_fun(File,FieldName,"uint16") -> file:write(File, "\t\twriter.write_short(" ++ FieldName ++ ");\r\n");
make_c_to_binary_fun(File,FieldName,"int32") -> file:write(File, "\t\twriter.write_int(" ++ FieldName ++ ");\r\n");
make_c_to_binary_fun(File,FieldName,"uint32") -> file:write(File, "\t\twriter.write_int(" ++ FieldName ++ ");\r\n");
make_c_to_binary_fun(File,FieldName,"int64") -> file:write(File, "\t\twriter.write_long(" ++ FieldName ++ ");\r\n");
make_c_to_binary_fun(File,FieldName,"uint64") -> file:write(File, "\t\twriter.write_long(" ++ FieldName ++ ");\r\n");
make_c_to_binary_fun(File,FieldName,"string") -> file:write(File, "\t\twriter.write_str(" ++ FieldName ++ ");\r\n");
make_c_to_binary_fun(File,FieldName,"float") -> file:write(File, "\t\twriter.write_float(" ++ FieldName ++ ");\r\n");
make_c_to_binary_fun(File,FieldName,"double") -> file:write(File, "\t\twriter.write_double(" ++ FieldName ++ ");\r\n");
make_c_to_binary_fun(File,FieldName,{repeated,"int8"}) -> 
	file:write(File, "\t\tushort len" ++ FieldName ++ " = (ushort)" ++ FieldName ++ ".Count;\r\n"),
	file:write(File, "\t\twriter.write_short(len" ++ FieldName ++ ");\r\n"),
	file:write(File, "\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t{\r\n"),
	file:write(File, "\t\t\tbyte listData = " ++ FieldName ++ "[i_" ++ FieldName ++ "];\r\n"),
	file:write(File, "\t\t\twriter.write_byte(listData);\r\n"),
	file:write(File, "\t\t}\r\n");
make_c_to_binary_fun(File,FieldName,{repeated,"uint8"}) -> 
	file:write(File, "\t\tushort len" ++ FieldName ++ " = (ushort)" ++ FieldName ++ ".Count;\r\n"),
	file:write(File, "\t\twriter.write_short(len" ++ FieldName ++ ");\r\n"),
	file:write(File, "\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t{\r\n"),
	file:write(File, "\t\t\tbyte listData = " ++ FieldName ++ "[i_" ++ FieldName ++ "];\r\n"),
	file:write(File, "\t\t\twriter.write_byte(listData);\r\n"),
	file:write(File, "\t\t}\r\n");
make_c_to_binary_fun(File,FieldName,{repeated,"int16"}) -> 
	file:write(File, "\t\tushort len" ++ FieldName ++ " = (ushort)" ++ FieldName ++ ".Count;\r\n"),
	file:write(File, "\t\twriter.write_short(len" ++ FieldName ++ ");\r\n"),
	file:write(File, "\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t{\r\n"),
	file:write(File, "\t\t\tshort listData = " ++ FieldName ++ "[i_" ++ FieldName ++ "];\r\n"),
	file:write(File, "\t\t\twriter.write_short(listData);\r\n"),
	file:write(File, "\t\t}\r\n");
make_c_to_binary_fun(File,FieldName,{repeated,"uint16"}) -> 
	file:write(File, "\t\tushort len" ++ FieldName ++ " = (ushort)" ++ FieldName ++ ".Count;\r\n"),
	file:write(File, "\t\twriter.write_short(len" ++ FieldName ++ ");\r\n"),
	file:write(File, "\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t{\r\n"),
	file:write(File, "\t\t\tushort listData = " ++ FieldName ++ "[i_" ++ FieldName ++ "];\r\n"),
	file:write(File, "\t\t\twriter.write_short(listData);\r\n"),
	file:write(File, "\t\t}\r\n");
make_c_to_binary_fun(File,FieldName,{repeated,"int32"}) -> 
	file:write(File, "\t\tushort len" ++ FieldName ++ " = (ushort)" ++ FieldName ++ ".Count;\r\n"),
	file:write(File, "\t\twriter.write_short(len" ++ FieldName ++ ");\r\n"),
	file:write(File, "\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t{\r\n"),
	file:write(File, "\t\t\tint listData = " ++ FieldName ++ "[i_" ++ FieldName ++ "];\r\n"),
	file:write(File, "\t\t\twriter.write_int(listData);\r\n"),
	file:write(File, "\t\t}\r\n");
make_c_to_binary_fun(File,FieldName,{repeated,"uint32"}) -> 
	file:write(File, "\t\tushort len" ++ FieldName ++ " = (ushort)" ++ FieldName ++ ".Count;\r\n"),
	file:write(File, "\t\twriter.write_short(len" ++ FieldName ++ ");\r\n"),
	file:write(File, "\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t{\r\n"),
	file:write(File, "\t\t\tuint listData = " ++ FieldName ++ "[i_" ++ FieldName ++ "];\r\n"),
	file:write(File, "\t\t\twriter.write_int(listData);\r\n"),
	file:write(File, "\t\t}\r\n");
make_c_to_binary_fun(File,FieldName,{repeated,"int64"}) -> 
	file:write(File, "\t\tushort len" ++ FieldName ++ " = (ushort)" ++ FieldName ++ ".Count;\r\n"),
	file:write(File, "\t\twriter.write_short(len" ++ FieldName ++ ");\r\n"),
	file:write(File, "\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t{\r\n"),
	file:write(File, "\t\t\tlong listData = " ++ FieldName ++ "[i_" ++ FieldName ++ "];\r\n"),
	file:write(File, "\t\t\twriter.write_long(listData);\r\n"),
	file:write(File, "\t\t}\r\n");
make_c_to_binary_fun(File,FieldName,{repeated,"uint64"}) -> 
	file:write(File, "\t\tushort len" ++ FieldName ++ " = (ushort)" ++ FieldName ++ ".Count;\r\n"),
	file:write(File, "\t\twriter.write_short(len" ++ FieldName ++ ");\r\n"),
	file:write(File, "\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t{\r\n"),
	file:write(File, "\t\t\tulong listData = " ++ FieldName ++ "[i_" ++ FieldName ++ "];\r\n"),
	file:write(File, "\t\t\twriter.write_long(listData);\r\n"),
	file:write(File, "\t\t}\r\n");
make_c_to_binary_fun(File,FieldName,{repeated,"string"}) -> 
	file:write(File, "\t\tushort len" ++ FieldName ++ " = (ushort)" ++ FieldName ++ ".Count;\r\n"),
	file:write(File, "\t\twriter.write_short(len" ++ FieldName ++ ");\r\n"),
	file:write(File, "\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t{\r\n"),
	file:write(File, "\t\t\tstring listData = " ++ FieldName ++ "[i_" ++ FieldName ++ "];\r\n"),
	file:write(File, "\t\t\twriter.write_str(listData);\r\n"),
	file:write(File, "\t\t}\r\n");
make_c_to_binary_fun(File,FieldName,{repeated,"float"}) -> 
	file:write(File, "\t\tushort len" ++ FieldName ++ " = (ushort)" ++ FieldName ++ ".Count;\r\n"),
	file:write(File, "\t\twriter.write_short(len" ++ FieldName ++ ");\r\n"),
	file:write(File, "\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t{\r\n"),
	file:write(File, "\t\t\tfloat listData = " ++ FieldName ++ "[i_" ++ FieldName ++ "];\r\n"),
	file:write(File, "\t\t\twriter.write_float(listData);\r\n"),
	file:write(File, "\t\t}\r\n");
make_c_to_binary_fun(File,FieldName,{repeated,"double"}) -> 
	file:write(File, "\t\tushort len" ++ FieldName ++ " = (ushort)" ++ FieldName ++ ".Count;\r\n"),
	file:write(File, "\t\twriter.write_short(len" ++ FieldName ++ ");\r\n"),
	file:write(File, "\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t{\r\n"),
	file:write(File, "\t\t\tdouble listData = " ++ FieldName ++ "[i_" ++ FieldName ++ "];\r\n"),
	file:write(File, "\t\t\twriter.write_double(listData);\r\n"),
	file:write(File, "\t\t}\r\n");
make_c_to_binary_fun(File,FieldName,{repeated,ListDes}) -> 
	ListDes2 = get_common_short_type(ListDes),
	file:write(File, "\t\tushort len" ++ FieldName ++ " = (ushort)" ++ FieldName ++ ".Count;\r\n"),
	file:write(File, "\t\twriter.write_short(len" ++ FieldName ++ ");\r\n"),
	file:write(File, "\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t{\r\n"),
	file:write(File, "\t\t\tst.net.NetBase." ++ ListDes2 ++ " listData = " ++ FieldName ++ "[i_" ++ FieldName ++ "];\r\n"),
	file:write(File, "\t\t\tlistData.toBinary(writer);\r\n"),
	file:write(File, "\t\t}\r\n");
make_c_to_binary_fun(_File,_FieldName,_FieldType) -> ok.

make_c_to_binary(File,DataDes) ->
	file:write(File, "\tpublic override byte[] toBinary()\r\n"),
	file:write(File, "\t{\r\n"),
	file:write(File, "\t\twriter = new st.net.NetBase.ByteWriter();\r\n"),
	FunMakeFun = fun({FieldType,FieldName,_FieldDefault}) -> make_c_to_binary_fun(File,FieldName,FieldType) end,
	lists:foreach(FunMakeFun, DataDes),
	file:write(File, "\t\treturn writer.data;\r\n"),
	file:write(File, "\t}\r\n"),
	ok.	


write_public_class_c(CommonProtos) ->
	CreateClass = "pt_public_class",
	case file:open(server_config:get_conf(client_pt_dir) ++ CreateClass ++ ".cs", [write]) of
		{ok, File} ->
			file:write(File, "using System.Collections;\r\n"),
			file:write(File, "using System.Collections.Generic;\r\n"),
			file:write(File, "\r\n"),
			
			file:write(File, "namespace st.net.NetBase\r\n"),
			file:write(File, "{\r\n"),
			Fun = fun({Classs, Fields}) ->
						  write_des_classs(File,Classs,Fields)
				  end,						 
			lists:foreach(Fun, CommonProtos),
			file:write(File, "}\r\n"),
			file:close(File);
		R -> R
	end.

write_des_classs(File,Class,Des)->
	Class2 = get_common_short_type(Class),
	file:write(File, "\tpublic class " ++ Class2 ++ "\r\n"),
	file:write(File, "\t{\r\n"),
	
	FunMakeFun1 = fun({FieldType,FieldName,FieldDefault}) -> make_c_list_fun(File,FieldName,FieldType,FieldDefault) end,
	lists:foreach(FunMakeFun1, Des),
	
	file:write(File, "\t\tpublic void fromBinary(st.net.NetBase.ByteReader reader)\r\n"),
	file:write(File, "\t\t{\r\n"),
	
	FunMakeFun2 = fun({FieldType,FieldName,FieldDefault}) -> make_c_list_fromBinary(File,FieldName,FieldType,FieldDefault) end,
	lists:foreach(FunMakeFun2, Des),

	file:write(File, "\t\t}\r\n"),
	
	file:write(File, "\t\tpublic void toBinary(st.net.NetBase.ByteWriter writer)\r\n"),
	file:write(File, "\t\t{\r\n"),
	
	FunMakeFun3 = fun({FieldType,FieldName,FieldDefault}) -> make_c_list_toBinary(File,FieldName,FieldType,FieldDefault) end,
	lists:foreach(FunMakeFun3, Des),
	
	file:write(File, "\t\t}\r\n"),
	
	file:write(File, "\t}\r\n"),
	ok.


make_c_list_fun(File,FieldName,"int8",_FieldDefault) -> file:write(File, "\t\tpublic byte " ++ FieldName ++ ";\r\n");
make_c_list_fun(File,FieldName,"uint8",_FieldDefault) -> file:write(File, "\t\tpublic byte " ++ FieldName ++ ";\r\n");
make_c_list_fun(File,FieldName,"int16",_FieldDefault) -> file:write(File, "\t\tpublic short " ++ FieldName ++ ";\r\n");
make_c_list_fun(File,FieldName,"uint16",_FieldDefault) -> file:write(File, "\t\tpublic ushort " ++ FieldName ++ ";\r\n");
make_c_list_fun(File,FieldName,"int32",_FieldDefault) -> file:write(File, "\t\tpublic int " ++ FieldName ++ ";\r\n");
make_c_list_fun(File,FieldName,"uint32",_FieldDefault) -> file:write(File, "\t\tpublic uint " ++ FieldName ++ ";\r\n");
make_c_list_fun(File,FieldName,"int64",_FieldDefault) -> file:write(File, "\t\tpublic long " ++ FieldName ++ ";\r\n");
make_c_list_fun(File,FieldName,"uint64",_FieldDefault) -> file:write(File, "\t\tpublic ulong " ++ FieldName ++ ";\r\n");
make_c_list_fun(File,FieldName,"string",_FieldDefault) -> file:write(File, "\t\tpublic string " ++ FieldName ++ ";\r\n");
make_c_list_fun(File,FieldName,"float",_FieldDefault) -> file:write(File, "\t\tpublic float " ++ FieldName ++ ";\r\n");
make_c_list_fun(File,FieldName,"double",_FieldDefault) -> file:write(File, "\t\tpublic double " ++ FieldName ++ ";\r\n");
make_c_list_fun(File,FieldName,{repeated,"int8"},_FieldDefault) ->
	file:write(File, "\t\tpublic List<byte> " ++ FieldName ++ " = new List<byte>();\r\n");
make_c_list_fun(File,FieldName,{repeated,"uint8"},_FieldDefault) ->
	file:write(File, "\t\tpublic List<byte> " ++ FieldName ++ " = new List<byte>();\r\n");
make_c_list_fun(File,FieldName,{repeated,"int16"},_FieldDefault) ->
	file:write(File, "\t\tpublic List<short> " ++ FieldName ++ " = new List<short>();\r\n");
make_c_list_fun(File,FieldName,{repeated,"uint16"},_FieldDefault) ->
	file:write(File, "\t\tpublic List<ushort> " ++ FieldName ++ " = new List<ushort>();\r\n");
make_c_list_fun(File,FieldName,{repeated,"int32"},_FieldDefault) ->
	file:write(File, "\t\tpublic List<int> " ++ FieldName ++ " = new List<int>();\r\n");
make_c_list_fun(File,FieldName,{repeated,"uint32"},_FieldDefault) ->
	file:write(File, "\t\tpublic List<uint> " ++ FieldName ++ " = new List<uint>();\r\n");
make_c_list_fun(File,FieldName,{repeated,"int64"},_FieldDefault) ->
	file:write(File, "\t\tpublic List<long> " ++ FieldName ++ " = new List<long>();\r\n");
make_c_list_fun(File,FieldName,{repeated,"uint64"},_FieldDefault) ->
	file:write(File, "\t\tpublic List<ulong> " ++ FieldName ++ " = new List<ulong>();\r\n");
make_c_list_fun(File,FieldName,{repeated,"string"},_FieldDefault) ->
	file:write(File, "\t\tpublic List<string> " ++ FieldName ++ " = new List<string>();\r\n");
make_c_list_fun(File,FieldName,{repeated,"float"},_FieldDefault) ->
	file:write(File, "\t\tpublic List<float> " ++ FieldName ++ " = new List<float>();\r\n");
make_c_list_fun(File,FieldName,{repeated,"double"},_FieldDefault) ->
	file:write(File, "\t\tpublic List<double> " ++ FieldName ++ " = new List<double>();\r\n");
make_c_list_fun(File,FieldName,{repeated,ListDes},_FieldDefault) ->
	ListDes2 = get_common_short_type(ListDes),
	file:write(File, "\t\tpublic List<st.net.NetBase." ++ ListDes2 ++ 
				   "> " ++ FieldName ++ " = new List<st.net.NetBase." ++ 
				   ListDes2 ++ ">();\r\n").

make_c_list_fromBinary(File,FieldName,"int8",_FieldDefault) -> file:write(File, "\t\t\t" ++ FieldName ++ " = reader.Read_byte();\r\n");
make_c_list_fromBinary(File,FieldName,"uint8",_FieldDefault) -> file:write(File, "\t\t\t" ++ FieldName ++ " = reader.Read_byte();\r\n");
make_c_list_fromBinary(File,FieldName,"int16",_FieldDefault) -> file:write(File, "\t\t\t" ++ FieldName ++ " = reader.Read_short();\r\n");
make_c_list_fromBinary(File,FieldName,"uint16",_FieldDefault) -> file:write(File, "\t\t\t" ++ FieldName ++ " = reader.Read_ushort();\r\n");
make_c_list_fromBinary(File,FieldName,"int32",_FieldDefault) -> file:write(File, "\t\t\t" ++ FieldName ++ " = reader.Read_int();\r\n");
make_c_list_fromBinary(File,FieldName,"uint32",_FieldDefault) -> file:write(File, "\t\t\t" ++ FieldName ++ " = reader.Read_uint();\r\n");
make_c_list_fromBinary(File,FieldName,"int64",_FieldDefault) -> file:write(File, "\t\t\t" ++ FieldName ++ " = reader.Read_long();\r\n");
make_c_list_fromBinary(File,FieldName,"uint64",_FieldDefault) -> file:write(File, "\t\t\t" ++ FieldName ++ " = reader.Read_ulong();\r\n");
make_c_list_fromBinary(File,FieldName,"string",_FieldDefault) -> file:write(File, "\t\t\t" ++ FieldName ++ " = reader.Read_str();\r\n");
make_c_list_fromBinary(File,FieldName,"float",_FieldDefault) -> file:write(File, "\t\t\t" ++ FieldName ++ " = reader.Read_float();\r\n");
make_c_list_fromBinary(File,FieldName,"double",_FieldDefault) -> file:write(File, "\t\t\t" ++ FieldName ++ " = reader.Read_double();\r\n");
make_c_list_fromBinary(File,FieldName,{repeated,"int8"},_FieldDefault) -> 
	file:write(File, "\t\t\tushort len" ++ FieldName ++ " = reader.Read_ushort();\r\n"),
	file:write(File, "\t\t\t" ++ FieldName ++ " = new List<byte>();\r\n"),
	file:write(File, "\t\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t\t{\r\n"),
	file:write(File, "\t\t\t\tbyte listData = reader.Read_byte();\r\n"),
	file:write(File, "\t\t\t\t" ++ FieldName ++ ".Add(listData);\r\n"),
	file:write(File, "\t\t\t}\r\n");
make_c_list_fromBinary(File,FieldName,{repeated,"uint8"},_FieldDefault) -> 
	file:write(File, "\t\t\tushort len" ++ FieldName ++ " = reader.Read_ushort();\r\n"),
	file:write(File, "\t\t\t" ++ FieldName ++ " = new List<byte>();\r\n"),
	file:write(File, "\t\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t\t{\r\n"),
	file:write(File, "\t\t\t\tbyte listData = reader.Read_byte();\r\n"),
	file:write(File, "\t\t\t\t" ++ FieldName ++ ".Add(listData);\r\n"),
	file:write(File, "\t\t\t}\r\n");
make_c_list_fromBinary(File,FieldName,{repeated,"int16"},_FieldDefault) -> 
	file:write(File, "\t\t\tushort len" ++ FieldName ++ " = reader.Read_ushort();\r\n"),
	file:write(File, "\t\t\t" ++ FieldName ++ " = new List<short>();\r\n"),
	file:write(File, "\t\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t\t{\r\n"),
	file:write(File, "\t\t\t\tshort listData = reader.Read_short();\r\n"),
	file:write(File, "\t\t\t\t" ++ FieldName ++ ".Add(listData);\r\n"),
	file:write(File, "\t\t\t}\r\n");
make_c_list_fromBinary(File,FieldName,{repeated,"uint16"},_FieldDefault) -> 
	file:write(File, "\t\t\tushort len" ++ FieldName ++ " = reader.Read_ushort();\r\n"),
	file:write(File, "\t\t\t" ++ FieldName ++ " = new List<ushort>();\r\n"),
	file:write(File, "\t\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t\t{\r\n"),
	file:write(File, "\t\t\t\tushort listData = reader.Read_ushort();\r\n"),
	file:write(File, "\t\t\t\t" ++ FieldName ++ ".Add(listData);\r\n"),
	file:write(File, "\t\t\t}\r\n");
make_c_list_fromBinary(File,FieldName,{repeated,"int32"},_FieldDefault) -> 
	file:write(File, "\t\t\tushort len" ++ FieldName ++ " = reader.Read_ushort();\r\n"),
	file:write(File, "\t\t\t" ++ FieldName ++ " = new List<int>();\r\n"),
	file:write(File, "\t\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t\t{\r\n"),
	file:write(File, "\t\t\t\tint listData = reader.Read_int();\r\n"),
	file:write(File, "\t\t\t\t" ++ FieldName ++ ".Add(listData);\r\n"),
	file:write(File, "\t\t\t}\r\n");
make_c_list_fromBinary(File,FieldName,{repeated,"uint32"},_FieldDefault) -> 
	file:write(File, "\t\t\tushort len" ++ FieldName ++ " = reader.Read_ushort();\r\n"),
	file:write(File, "\t\t\t" ++ FieldName ++ " = new List<uint>();\r\n"),
	file:write(File, "\t\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t\t{\r\n"),
	file:write(File, "\t\t\t\tuint listData = reader.Read_uint();\r\n"),
	file:write(File, "\t\t\t\t" ++ FieldName ++ ".Add(listData);\r\n"),
	file:write(File, "\t\t\t}\r\n");
make_c_list_fromBinary(File,FieldName,{repeated,"int64"},_FieldDefault) -> 
	file:write(File, "\t\t\tushort len" ++ FieldName ++ " = reader.Read_ushort();\r\n"),
	file:write(File, "\t\t\t" ++ FieldName ++ " = new List<long>();\r\n"),
	file:write(File, "\t\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t\t{\r\n"),
	file:write(File, "\t\t\t\tlong listData = reader.Read_long();\r\n"),
	file:write(File, "\t\t\t\t" ++ FieldName ++ ".Add(listData);\r\n"),
	file:write(File, "\t\t\t}\r\n");
make_c_list_fromBinary(File,FieldName,{repeated,"uint64"},_FieldDefault) -> 
	file:write(File, "\t\t\tushort len" ++ FieldName ++ " = reader.Read_ushort();\r\n"),
	file:write(File, "\t\t\t" ++ FieldName ++ " = new List<ulong>();\r\n"),
	file:write(File, "\t\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t\t{\r\n"),
	file:write(File, "\t\t\t\tulong listData = reader.Read_ulong();\r\n"),
	file:write(File, "\t\t\t\t" ++ FieldName ++ ".Add(listData);\r\n"),
	file:write(File, "\t\t\t}\r\n");
make_c_list_fromBinary(File,FieldName,{repeated,"string"},_FieldDefault) -> 
	file:write(File, "\t\t\tushort len" ++ FieldName ++ " = reader.Read_ushort();\r\n"),
	file:write(File, "\t\t\t" ++ FieldName ++ " = new List<string>();\r\n"),
	file:write(File, "\t\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t\t{\r\n"),
	file:write(File, "\t\t\t\tstring listData = reader.Read_str();\r\n"),
	file:write(File, "\t\t\t\t" ++ FieldName ++ ".Add(listData);\r\n"),
	file:write(File, "\t\t\t}\r\n");
make_c_list_fromBinary(File,FieldName,{repeated,"float"},_FieldDefault) -> 
	file:write(File, "\t\t\tushort len" ++ FieldName ++ " = reader.Read_ushort();\r\n"),
	file:write(File, "\t\t\t" ++ FieldName ++ " = new List<float>();\r\n"),
	file:write(File, "\t\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t\t{\r\n"),
	file:write(File, "\t\t\t\tfloat listData = reader.Read_float();\r\n"),
	file:write(File, "\t\t\t\t" ++ FieldName ++ ".Add(listData);\r\n"),
	file:write(File, "\t\t\t}\r\n");
make_c_list_fromBinary(File,FieldName,{repeated,"double"},_FieldDefault) -> 
	file:write(File, "\t\t\tushort len" ++ FieldName ++ " = reader.Read_ushort();\r\n"),
	file:write(File, "\t\t\t" ++ FieldName ++ " = new List<double>();\r\n"),
	file:write(File, "\t\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t\t{\r\n"),
	file:write(File, "\t\t\t\tdouble listData = reader.Read_double();\r\n"),
	file:write(File, "\t\t\t\t" ++ FieldName ++ ".Add(listData);\r\n"),
	file:write(File, "\t\t\t}\r\n");
make_c_list_fromBinary(File,FieldName,{repeated,ListDes},_FieldDefault) -> 
	ListDes2 = get_common_short_type(ListDes),
	file:write(File, "\t\t\tushort len" ++ FieldName ++ " = reader.Read_ushort();\r\n"),
	file:write(File, "\t\t\t" ++ FieldName ++ " = new List<st.net.NetBase." ++ ListDes2 ++ ">();\r\n"),
	file:write(File, "\t\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t\t{\r\n"),
	file:write(File, "\t\t\t\tst.net.NetBase." ++ ListDes2 ++ " listData = new st.net.NetBase." ++ ListDes2 ++ "();\r\n"),
	file:write(File, "\t\t\t\tlistData.fromBinary(reader);\r\n"),
	file:write(File, "\t\t\t\t" ++ FieldName ++ ".Add(listData);\r\n"),
	file:write(File, "\t\t\t}\r\n").

make_c_list_toBinary(File,FieldName,"int8",_FieldDefault) -> file:write(File, "\t\t\twriter.write_byte(" ++ FieldName ++ ");\r\n");
make_c_list_toBinary(File,FieldName,"uint8",_FieldDefault) -> file:write(File, "\t\t\twriter.write_byte(" ++ FieldName ++ ");\r\n");
make_c_list_toBinary(File,FieldName,"int16",_FieldDefault) -> file:write(File, "\t\t\twriter.write_short(" ++ FieldName ++ ");\r\n");
make_c_list_toBinary(File,FieldName,"uint16",_FieldDefault) -> file:write(File, "\t\t\twriter.write_short(" ++ FieldName ++ ");\r\n");
make_c_list_toBinary(File,FieldName,"int32",_FieldDefault) -> file:write(File, "\t\t\twriter.write_int(" ++ FieldName ++ ");\r\n");
make_c_list_toBinary(File,FieldName,"uint32",_FieldDefault) -> file:write(File, "\t\t\twriter.write_int(" ++ FieldName ++ ");\r\n");
make_c_list_toBinary(File,FieldName,"int64",_FieldDefault) -> file:write(File, "\t\t\twriter.write_long(" ++ FieldName ++ ");\r\n");
make_c_list_toBinary(File,FieldName,"uint64",_FieldDefault) -> file:write(File, "\t\t\twriter.write_long(" ++ FieldName ++ ");\r\n");
make_c_list_toBinary(File,FieldName,"string",_FieldDefault) -> file:write(File, "\t\t\twriter.write_str(" ++ FieldName ++ ");\r\n");
make_c_list_toBinary(File,FieldName,"float",_FieldDefault) -> file:write(File, "\t\t\twriter.write_float(" ++ FieldName ++ ");\r\n");
make_c_list_toBinary(File,FieldName,"double",_FieldDefault) -> file:write(File, "\t\t\twriter.write_double(" ++ FieldName ++ ");\r\n");
make_c_list_toBinary(File,FieldName,{repeated,"int8"},_FieldDefault) -> 
	file:write(File, "\t\t\tushort len" ++ FieldName ++ " = (ushort)" ++ FieldName ++ ".Count;\r\n"),
	file:write(File, "\t\t\twriter.write_short(len" ++ FieldName ++ ");\r\n"),
	file:write(File, "\t\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t\t{\r\n"),
	file:write(File, "\t\t\t\tbyte listData = " ++ FieldName ++ "[i_" ++ FieldName ++ "];\r\n"),
	file:write(File, "\t\t\t\twriter.write_byte(listData);\r\n"),
	file:write(File, "\t\t\t}\r\n");
make_c_list_toBinary(File,FieldName,{repeated,"uint8"},_FieldDefault) -> 
	file:write(File, "\t\t\tushort len" ++ FieldName ++ " = (ushort)" ++ FieldName ++ ".Count;\r\n"),
	file:write(File, "\t\t\twriter.write_short(len" ++ FieldName ++ ");\r\n"),
	file:write(File, "\t\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t\t{\r\n"),
	file:write(File, "\t\t\t\tbyte listData = " ++ FieldName ++ "[i_" ++ FieldName ++ "];\r\n"),
	file:write(File, "\t\t\t\twriter.write_byte(listData);\r\n"),
	file:write(File, "\t\t\t}\r\n");
make_c_list_toBinary(File,FieldName,{repeated,"int16"},_FieldDefault) -> 
	file:write(File, "\t\t\tushort len" ++ FieldName ++ " = (ushort)" ++ FieldName ++ ".Count;\r\n"),
	file:write(File, "\t\t\twriter.write_short(len" ++ FieldName ++ ");\r\n"),
	file:write(File, "\t\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t\t{\r\n"),
	file:write(File, "\t\t\t\tshort listData = " ++ FieldName ++ "[i_" ++ FieldName ++ "];\r\n"),
	file:write(File, "\t\t\t\twriter.write_short(listData);\r\n"),
	file:write(File, "\t\t\t}\r\n");
make_c_list_toBinary(File,FieldName,{repeated,"uint16"},_FieldDefault) -> 
	file:write(File, "\t\t\tushort len" ++ FieldName ++ " = (ushort)" ++ FieldName ++ ".Count;\r\n"),
	file:write(File, "\t\t\twriter.write_short(len" ++ FieldName ++ ");\r\n"),
	file:write(File, "\t\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t\t{\r\n"),
	file:write(File, "\t\t\t\tushort listData = " ++ FieldName ++ "[i_" ++ FieldName ++ "];\r\n"),
	file:write(File, "\t\t\t\twriter.write_short(listData);\r\n"),
	file:write(File, "\t\t\t}\r\n");
make_c_list_toBinary(File,FieldName,{repeated,"int32"},_FieldDefault) -> 
	file:write(File, "\t\t\tushort len" ++ FieldName ++ " = (ushort)" ++ FieldName ++ ".Count;\r\n"),
	file:write(File, "\t\t\twriter.write_short(len" ++ FieldName ++ ");\r\n"),
	file:write(File, "\t\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t\t{\r\n"),
	file:write(File, "\t\t\t\tint listData = " ++ FieldName ++ "[i_" ++ FieldName ++ "];\r\n"),
	file:write(File, "\t\t\t\twriter.write_int(listData);\r\n"),
	file:write(File, "\t\t\t}\r\n");
make_c_list_toBinary(File,FieldName,{repeated,"uint32"},_FieldDefault) -> 
	file:write(File, "\t\t\tushort len" ++ FieldName ++ " = (ushort)" ++ FieldName ++ ".Count;\r\n"),
	file:write(File, "\t\t\twriter.write_short(len" ++ FieldName ++ ");\r\n"),
	file:write(File, "\t\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t\t{\r\n"),
	file:write(File, "\t\t\t\tuint listData = " ++ FieldName ++ "[i_" ++ FieldName ++ "];\r\n"),
	file:write(File, "\t\t\t\twriter.write_int(listData);\r\n"),
	file:write(File, "\t\t\t}\r\n");
make_c_list_toBinary(File,FieldName,{repeated,"int64"},_FieldDefault) -> 
	file:write(File, "\t\t\tushort len" ++ FieldName ++ " = (ushort)" ++ FieldName ++ ".Count;\r\n"),
	file:write(File, "\t\t\twriter.write_short(len" ++ FieldName ++ ");\r\n"),
	file:write(File, "\t\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t\t{\r\n"),
	file:write(File, "\t\t\t\tlong listData = " ++ FieldName ++ "[i_" ++ FieldName ++ "];\r\n"),
	file:write(File, "\t\t\t\twriter.write_long(listData);\r\n"),
	file:write(File, "\t\t\t}\r\n");
make_c_list_toBinary(File,FieldName,{repeated,"uint64"},_FieldDefault) -> 
	file:write(File, "\t\t\tushort len" ++ FieldName ++ " = (ushort)" ++ FieldName ++ ".Count;\r\n"),
	file:write(File, "\t\t\twriter.write_short(len" ++ FieldName ++ ");\r\n"),
	file:write(File, "\t\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t\t{\r\n"),
	file:write(File, "\t\t\t\tulong listData = " ++ FieldName ++ "[i_" ++ FieldName ++ "];\r\n"),
	file:write(File, "\t\t\t\twriter.write_long(listData);\r\n"),
	file:write(File, "\t\t\t}\r\n");
make_c_list_toBinary(File,FieldName,{repeated,"string"},_FieldDefault) -> 
	file:write(File, "\t\t\tushort len" ++ FieldName ++ " = (ushort)" ++ FieldName ++ ".Count;\r\n"),
	file:write(File, "\t\t\twriter.write_short(len" ++ FieldName ++ ");\r\n"),
	file:write(File, "\t\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t\t{\r\n"),
	file:write(File, "\t\t\t\tstring listData = " ++ FieldName ++ "[i_" ++ FieldName ++ "];\r\n"),
	file:write(File, "\t\t\t\twriter.write_str(listData);\r\n"),
	file:write(File, "\t\t\t}\r\n");
make_c_list_toBinary(File,FieldName,{repeated,"float"},_FieldDefault) -> 
	file:write(File, "\t\t\tushort len" ++ FieldName ++ " = (ushort)" ++ FieldName ++ ".Count;\r\n"),
	file:write(File, "\t\t\twriter.write_short(len" ++ FieldName ++ ");\r\n"),
	file:write(File, "\t\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t\t{\r\n"),
	file:write(File, "\t\t\t\tfloat listData = " ++ FieldName ++ "[i_" ++ FieldName ++ "];\r\n"),
	file:write(File, "\t\t\t\twriter.write_float(listData);\r\n"),
	file:write(File, "\t\t\t}\r\n");
make_c_list_toBinary(File,FieldName,{repeated,"double"},_FieldDefault) -> 
	file:write(File, "\t\t\tushort len" ++ FieldName ++ " = (ushort)" ++ FieldName ++ ".Count;\r\n"),
	file:write(File, "\t\t\twriter.write_short(len" ++ FieldName ++ ");\r\n"),
	file:write(File, "\t\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t\t{\r\n"),
	file:write(File, "\t\t\t\tdouble listData = " ++ FieldName ++ "[i_" ++ FieldName ++ "];\r\n"),
	file:write(File, "\t\t\t\twriter.write_double(listData);\r\n"),
	file:write(File, "\t\t\t}\r\n");
make_c_list_toBinary(File,FieldName,{repeated,ListDes},_FieldDefault) -> 
	ListDes2 = get_common_short_type(ListDes),
	file:write(File, "\t\t\tushort len" ++ FieldName ++ " = (ushort)" ++ FieldName ++ ".Count;\r\n"),
	file:write(File, "\t\t\twriter.write_short(len" ++ FieldName ++ ");\r\n"),
	file:write(File, "\t\t\tfor(int i_" ++ FieldName ++ " = 0 ; i_" ++ FieldName ++ " < len" ++ FieldName ++ " ; i_" ++ FieldName ++ " ++)\r\n"),
	file:write(File, "\t\t\t{\r\n"),
	file:write(File, "\t\t\t\tst.net.NetBase." ++ ListDes2 ++ " listData = " ++ FieldName ++ "[i_" ++ FieldName ++ "];\r\n"),
	file:write(File, "\t\t\t\tlistData.toBinary(writer);\r\n"),
	file:write(File, "\t\t\t}\r\n").


get_common_short_type(Type) ->
	string:slice(Type, 10).

