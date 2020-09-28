#ifndef MY_INCLUDE_MAP_H
#define MY_INCLUDE_MAP_H

struct Point 
{
	float x;
	float y;
	float z;
};

struct Line 
{
	int point1;
	int point2;
	struct Point centre_point;
	int connect_face1;  	//face index
	int connect_face2;		//face index
};

struct Face 
{
	int point1;
	int point2;
	int point3;
	struct Point mini_point;
	struct Point max_point;
};

struct DivideInfo 
{
	struct Point from;
	struct Point to;
	struct Point per;
};


struct DivideFaceIndexs 
{
	int size;
	int index_arrary[100];
};


// 1
extern struct Point points_1[];
extern struct Line lines_1[];
extern struct Face Faces_1[];
extern struct DivideInfo divide_info_1;
extern struct DivideFaceIndexs divide_face_indexs_1[];
int get_line_index_1(int p1, int p2);
int get_divide_index_1(int x, int z);

// 2
extern struct Point points_2[];
extern struct Line lines_2[];
extern struct Face Faces_2[];
extern struct DivideInfo divide_info_2;
extern struct DivideFaceIndexs divide_face_indexs_2[];
int get_line_index_2(int p1, int p2);
int get_divide_index_2(int x, int z);

// 3
extern struct Point points_3[];
extern struct Line lines_3[];
extern struct Face Faces_3[];
extern struct DivideInfo divide_info_3;
extern struct DivideFaceIndexs divide_face_indexs_3[];
int get_line_index_3(int p1, int p2);
int get_divide_index_3(int x, int z);

#endif