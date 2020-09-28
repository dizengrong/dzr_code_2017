#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <time.h>
#include "map.h"
#include <erl_nif.h>

#ifdef __GNUC__
#include <unistd.h>
#else
#include <windows.h>
#endif


#define PI 3.1415926

unsigned long int next_seed = 1; 

static struct Face* map_faces[] = {
	NULL,
	Faces_1,
	Faces_2,
	Faces_3
};


static struct Line* map_lines[] = {
	NULL,
	lines_1,
	lines_2,
	lines_3
};

static struct Point* map_points[] = {
	NULL,
	points_1,
	points_2,
	points_3
};

static struct DivideInfo* map_divide_info[] = {
	NULL,
	&divide_info_1,
	&divide_info_2,
	&divide_info_3
};

static struct DivideFaceIndexs* map_divide_face_indexs[] = {
	NULL,
	divide_face_indexs_1,
	divide_face_indexs_2,
	divide_face_indexs_3
};

static int(*fun_get_line_index [])(int, int) = {
	NULL,
	get_line_index_1,
	get_line_index_2,
	get_line_index_3
};

static int(*fun_get_divide_index [])(int, int) = {
	NULL,
	get_divide_index_1,
	get_divide_index_2,
	get_divide_index_3
};

//pre define function
static void find_face(int map_id, struct Point* ptr_point, struct DivideFaceIndexs* face_indexs, 
					  int* ret_code, int* got_face, struct Point* ret_point);
static void check_point_help(int map_id, struct Point* ptr_point, 
							 int* ret_code, int* got_face, struct Point* ret_point);
static void check_line_and_face(struct Point* linepoint1, struct Point* linepoint2, 
								struct Point* facepoint1, struct Point* facepoint2, 
								struct Point* facepoint3, int* ret_code, struct Point* ret_point);

static void print_point(struct Point* point)
{
	printf("x:%f y:%f z:%f\n", point->x, point->y, point->z);

}

static void print_divide_face_indexs(struct DivideFaceIndexs* face_indexs)
{
	printf("divide faces:");
	for (int i = 0; i < face_indexs->size; ++i)
	{
		printf("%d, ", face_indexs->index_arrary[i]);
	}
	printf("\n");
}

// --------------------------------- 点的处理 ----------------------------------
static void cross_ride(struct Point* point1, struct Point* point2, struct Point* ret_point)
{
	ret_point->x = point1->y * point2->z - point1->z * point2->y;
	ret_point->y = point1->z * point2->x - point1->x * point2->z;
	ret_point->z = point1->x * point2->y - point1->y * point2->x;
}

static void dec2(float x1, float y1, float z1, float x2, float y2, float z2, struct Point* ret_point)
{
	ret_point->x = x1 - x2;
	ret_point->y = y1 - y2;
	ret_point->z = z1 - z2;
}
static void dec(struct Point* point1, struct Point* point2, struct Point* ret_point)
{
	ret_point->x = point1->x - point2->x;
	ret_point->y = point1->y - point2->y;
	ret_point->z = point1->z - point2->z;
}

static void add(struct Point* point1, struct Point* point2, struct Point* ret_point)
{
	ret_point->x = point1->x + point2->x;
	ret_point->y = point1->y + point2->y;
	ret_point->z = point1->z + point2->z;
}

static float dot_ride(struct Point* point1, struct Point* point2)
{
	return point1->x * point2->x + point1->y * point2->y + point1->z * point2->z;
}

static void ride(struct Point* point1, float f, struct Point* ret_point)
{
	ret_point->x = point1->x * f;
	ret_point->y = point1->y * f;
	ret_point->z = point1->z * f;
}

static float length_sqrt(struct Point* point)
{
	return sqrt(point->x * point->x + point->y * point->y + point->z * point->z);
}

static float length_power(struct Point* point)
{
	return point->x * point->x + point->y * point->y + point->z * point->z;
}


static void normal(struct Point* point, struct Point* ret_point)
{
	ride(point, 1 / length_sqrt(point), ret_point);
}

static double angle2radian(double angle)
{
	if (angle >= 360)
		return (fmod(angle, 360) / 360) * PI * 2;
	else if (angle < 0)
		return angle2radian((angle + ceil(fmod(-angle, 360)) * 360));
	else 
		return (angle / 360) * PI * 2;
}

static double radian2angle(double r)
{
	if (r >= PI * 2)
		return radian2angle(r - floor(r/2/PI) * 2 * PI);
	else if (r < 0)
		return (r + ceil((-1 * r) / 2 / PI) * 2 * PI) / (PI * 2) * 360;
	else 
		return r / (PI * 2) * 360;
}

static void rotate_radian(struct Point* point, double radian, struct Point* ret_point)
{
	double cos_val = cos(radian), sin_val = sin(radian);
	ret_point->x = point->x * cos_val + point->z * sin_val;
	ret_point->y = point->y;
	ret_point->z = point->z * cos_val + point->x * sin_val;
}

static void get_vect_by_dir(double radian, struct Point* ret_point)
{
	struct Point temp = {0, 0, 1};
	rotate_radian(&temp, radian, ret_point);
}

static double dot_line_dis(struct Point* p1, struct Point* p2)
{
	if (fabs(p1->x) <= 0.000001) 
		return fabs(p2->x);
	else if (fabs(p1->z) <= 0.000001)
		return fabs(p2->z);
	else{
		double val = p1->z/p1->x;
		struct Point temp = {val, 0, 1};
		return fabs(val*p2->x - p2->z) / length_sqrt(&temp);
	}
}
static double get_radian(struct Point* p1, struct Point* p2)
{
	struct Point no_y_p1 = {p1->x, 0, p1->z};
	struct Point no_y_p2 = {p2->x, 0, p2->z};
	double r;
	double val = length_sqrt(p1) * length_sqrt(p2);
	if (val <= 0.000001)
		return 0;
	else {
		r = dot_ride(p1, p2) / val;
		if (r > 1) 
			return acos(1.0);
		else if (r < -1)
			return acos(-1.0);
		else
			return acos(r);
	} 
	return 0.0;
}

static double get_dir_angle(struct Point* point)
{
	struct Point temp_point = {0, 0, 1};
	double a = radian2angle(get_radian(&temp_point, point));
	if (point->x < 0)
		return 360 - a;
	else
		return a;
}
// --------------------------------- 点的处理 ----------------------------------


// -------------------------------- 返回值封装 ---------------------------------
static ERL_NIF_TERM make_point(ErlNifEnv* env, struct Point* p)
{
	return enif_make_tuple3(env, enif_make_double(env, p->x), 
								 enif_make_double(env, p->y), 
								 enif_make_double(env, p->z));
}

static ERL_NIF_TERM make_point_and_int_dir(ErlNifEnv* env, struct Point* p, int dir)
{
	return enif_make_tuple4(env, enif_make_double(env, p->x), 
								 enif_make_double(env, p->y), 
								 enif_make_double(env, p->z),
								 enif_make_int(env, dir));
}
// -------------------------------- 返回值封装 ---------------------------------




static int get_data_index_floor(float data, float from, float to, float per)
{
	if (per == 0)
		return 0;
	// printf("data:%f from:%f to:%f per:%f\n", data, from, to, per);
	return floor((data - from)/per);
}

static int calc_divide_index(int map_id, struct Point* point)
{
	int x, z;
	struct DivideInfo* divide_info = map_divide_info[map_id];

	// print_point(point);
	// print_point(&(divide_info->from));
	// print_point(&(divide_info->to));
	// print_point(&(divide_info->per));
	x = get_data_index_floor(point->x, divide_info->from.x, divide_info->to.x, divide_info->per.x);
	z = get_data_index_floor(point->z, divide_info->from.z, divide_info->to.z, divide_info->per.z);
	// printf("calc_divide_index, x:%d z:%d\n", x, z);
	return fun_get_divide_index[map_id](x, z);
}

static int check_point_in_face(struct Point* ptr_point, struct Point* ptr_fp1, struct Point* ptr_fp2, struct Point* ptr_fp3)
{
	struct Point v0, v1, v2;
	float dot00, dot01, dot02, dot11, dot12, inverdeno, u;
	dec(ptr_fp3, ptr_fp1, &v0);
	dec(ptr_fp2, ptr_fp1, &v1);
	dec(ptr_point, ptr_fp1, &v2);

	// print_point(ptr_fp1);
	// print_point(ptr_fp2);
	// print_point(ptr_fp3);
	// print_point(ptr_point);
		
	dot00 = dot_ride(&v0, &v0);
	dot01 = dot_ride(&v0, &v1);
	dot02 = dot_ride(&v0, &v2);
	dot11 = dot_ride(&v1, &v1);
	dot12 = dot_ride(&v1, &v2);

	inverdeno = 1 / (dot00 * dot11 - dot01 * dot01);
	u = (dot11 * dot02 - dot01 * dot12) * inverdeno;
	// printf("dot00:%f, dot01:%f, dot02:%f, dot11:%f, dot12:%f, inverdeno:%f, u:%f\n", dot00, dot01, dot02, dot11, dot12, inverdeno, u);
	if (u < 0)
		return 0;
	else if (u > 1)
		return 0;
	else{
		float v = (dot00 * dot12 - dot01 * dot02) * inverdeno;
		// printf("check_point_in_face u:%f v:%f\n", u, v);
		if (v < -0.00001)
			return 0;
		else if (v > 1)
			return 0;
		else if (u + v <= 1)
			return 1;
		else
			return 0;
	}

}

static void find_face(int map_id, struct Point* ptr_point, struct DivideFaceIndexs* face_indexs, 
					  int* ret_code, int* got_face, struct Point* ret_point)
{
	struct Point ypoint = {ptr_point->x, ptr_point->y + 1, ptr_point->z};
	struct Point a, b, c;
	struct Face face;

	struct Face* faces = map_faces[map_id];
	struct Point* points = map_points[map_id];

	for (int i = 0; i < face_indexs->size; ++i)
	{
		*got_face = face_indexs->index_arrary[i];
		face = faces[*got_face];
		a = points[face.point1 - 1];
		b = points[face.point2 - 1];
		c = points[face.point3 - 1];

		check_line_and_face(ptr_point, &ypoint, &a, &b, &c, ret_code, ret_point);
		if (ret_code > 0)
		{
			// printf("find_face ret_code:%d\n", *ret_code);
			if (check_point_in_face(ret_point, &a, &b, &c))
				return;
			else
				continue;
		}
	}
	// printf("no face find!!!!!!!!!!!!!!\n");
	*ret_code = 0;
}

static void get_point_award(int map_id, struct Point* ptr_point, struct Point*  dir, 
							float award, int* ret_code, int* got_face, struct Point* ret_point)
{
	struct Point no_y_award_point, temp1, temp2;
	struct Point no_y_point = {ptr_point->x, 0, ptr_point->z};
	struct Point no_y_dir   = {dir->x, 0, dir->z};

	// printf("bbb:ret_code:%d\n", *ret_code);
	normal(&no_y_dir, &temp1);
	ride(&temp1, award, &temp2);
	add(&no_y_point, &temp2, &no_y_award_point);
	check_point_help(map_id, &no_y_award_point, ret_code, got_face, ret_point);
	// printf("bb:ret_code:%d\n", *ret_code);
}

static void get_point_adjust(int map_id, struct Point* ptr_point, struct Point*  dir, 
							 float award, int* ret_code, int* got_face, struct Point* ret_point)
{
	check_point_help(map_id, ptr_point, ret_code, got_face, ret_point);
	// printf("b:ret_code:%d\n", *ret_code);
	if (*ret_code > 0)
		return;
	get_point_award(map_id, ptr_point, dir, award, ret_code, got_face, ret_point);
}

static void get_face_3_line(int map_id, int face_index, int* line1, int* line2, int* line3)
{
	struct Face* faces = map_faces[map_id];
	struct Point* points;
	struct Face face;

	face = faces[face_index];
	*line1 = fun_get_line_index[map_id](face.point1, face.point2);
	*line2 = fun_get_line_index[map_id](face.point2, face.point3);
	*line3 = fun_get_line_index[map_id](face.point1, face.point3);
}

static void check_line_and_face(struct Point* linepoint1, struct Point* linepoint2, 
								struct Point* facepoint1, struct Point* facepoint2, 
								struct Point* facepoint3, int* ret_code, struct Point* ret_point)
{
	struct Point u, w, ret_p1, ret_p2, nop;
	float d, n, adsd, t;
	// print_point(linepoint1);
	// print_point(linepoint2);
	// print_point(facepoint1);
	// print_point(facepoint2);
	// print_point(facepoint3);
	dec(facepoint2, facepoint1, &ret_p1);
	dec(facepoint3, facepoint1, &ret_p2);
	cross_ride(&ret_p1, &ret_p2, &nop);
	// printf("==============================\n");
	// print_point(&ret_p1);
	// print_point(&ret_p2);
	// print_point(&nop);
	// printf("==============================\n");

	dec(linepoint2, linepoint1, &u);
	dec(linepoint1, facepoint1, &w);
	d = dot_ride(&nop, &u);
	n = (-1) * dot_ride(&nop, &w);
	// print_point(&u);
	// print_point(&w);

	adsd = fabs(d);
	// printf("d:%f, adsd:%f, n:%f\n", d, adsd, n);
	if (adsd < 0.0001)
	{
		if (n < 0.00001)
			*ret_code = -1; // {parallel,in}
		else
			*ret_code = -2; // {parallel,out}
	} else {
		t = n / d;
		if (t < 0) 
			*ret_code = 1; // dec_out
		else if (t == 0)
			*ret_code = 2; // start_point
		else if (t == 1)
			*ret_code = 3; // end_point
		else if (t > 1)
			*ret_code = 4; // add_out
		else
			*ret_code = 5; // in
		ride(&u, t, &ret_p1);
		// printf("##################### t:%f\n", t);
		add(linepoint1, &ret_p1, ret_point);
	}
}

static void test_dir_and_points(struct Point* point, struct Point* dir, struct Point* point1, 
								struct Point* point2, int* ret_code, struct Point* ret_point)
{
	struct Point no_y_point = {point->x, 0, point->z};
	struct Point no_y_dir = {dir->x, 0, dir->z};
	struct Point no_y_point1 = {point1->x, 0, point1->z};
	struct Point no_y_point2 = {point2->x, 0, point2->z};
	struct Point no_y_point3, temp = {0, 1, 0};
	add(&no_y_point1, &temp, &no_y_point3);

	add(&no_y_point, &no_y_dir, &temp);
	check_line_and_face(&no_y_point, &temp, &no_y_point1, &no_y_point2, &no_y_point3, ret_code, ret_point);
	// printf("test_dir_and_points, ret_code:%d\n", *ret_code);
	if (*ret_code > 0){
		if (check_point_in_face(ret_point, &no_y_point1, &no_y_point2, &no_y_point3))
			return;
		*ret_code = -1;
	}
}

static void test_lines(int map_id, struct Point* point, struct Point* dir, 
					   int line_index1, int line_index2, int line_index3, int* ret_code, struct Point* ret_point)
{
	struct Line* lines = map_lines[map_id];
	struct Point* points = map_points[map_id];

	struct Point p1, p2;
	struct Line line;
	// 检测line1
	line = lines[line_index1];
	p1 = points[line.point1 - 1];
	p2 = points[line.point2 - 1];
	// print_point(point);
	// print_point(dir);
	// print_point(&p1);
	// print_point(&p2);
	test_dir_and_points(point, dir, &p1, &p2, ret_code, ret_point);
	// printf("test_dir_and_points ret_code:%d\n", *ret_code);
	if (*ret_code > 0 && *ret_code != 1 && *ret_code != 2)
		return;

	// 检测line2
	line = lines[line_index2];
	p1 = points[line.point1 - 1];
	p2 = points[line.point2 - 1];
	test_dir_and_points(point, dir, &p1, &p2, ret_code, ret_point);
	// printf("test_dir_and_points ret_code:%d\n", *ret_code);
	if (*ret_code > 0 && *ret_code != 1 && *ret_code != 2)
		return;

	// 检测line3
	line = lines[line_index3];
	p1 = points[line.point1 - 1];
	p2 = points[line.point2 - 1];
	test_dir_and_points(point, dir, &p1, &p2, ret_code, ret_point);
	// printf("test_dir_and_points ret_code:%d\n", *ret_code);
	if (*ret_code > 0 && *ret_code != 1 && *ret_code != 2)
		return;
	*ret_code = -1;
	return;

}

// ret_code: 1:表示不能继续 2：表示能继续 0或者负数表示失败 
static void find_dir_point(int map_id, struct Point* ptr_point, struct Point* dir, 
						   int face_index, int* ret_code, int* got_face, struct Point* ret_point)
{
	int from_face, from_face2;
	struct Point from_point;
	struct Point ret_point2, ret_point3 = {0,0,0};
	int ret_code2;
	int got_face2;

	if (face_index < 0){
		// printf("before call get_point_adjust, ptr_point->y:%f\n", ptr_point->y);
		get_point_adjust(map_id, ptr_point, dir, 0.1, &ret_code2, &from_face2, &ret_point2);
		// printf("a:ret_code2:%d\n", ret_code2);
		if (ret_code2 > 0){
			from_point = ret_point2;
			from_face = from_face2;
		}
	} else {
		ret_code2 = 1;
		from_point = *ptr_point;
		from_face = face_index;
	}
	// printf("2:ret_code:%d\n", *ret_code);

	if (ret_code2 <= 0){
		*ret_code = ret_code2;
		// printf("3:ret_code:%d\n", *ret_code);
		return;
	}

	// printf("\n=============================from_face:%d\n", from_face);
	get_point_award(map_id, &from_point, dir, 0.1, &ret_code2, &got_face2, &ret_point3);
	// printf("\n================:ret_code2:%d from_face:%d got_face2:%d\n", ret_code2, from_face, got_face2);
	if (ret_code2 <= 0){
		check_point_help(map_id, &from_point, ret_code, got_face, ret_point);
		*ret_code = 1;
		// printf("4:ret_code:%d\n", *ret_code);
	} else {
		if (from_face == got_face2)
		{
			int line1, line2, line3, ret_code3 = 0;
			get_face_3_line(map_id, from_face, &line1, &line2, &line3);
			if (line1 == -1 || line2 == -1 || line3 == -1)
			{
				*ret_code = -1;
				return;
			}
			struct Point no_y_line_point;
			// print_point(&from_point);
			// print_point(dir);
			// printf("line1:%d, line2:%d, line3:%d\n", line1, line2, line3);
			test_lines(map_id, &from_point, dir, line1, line2, line3, &ret_code3, &no_y_line_point);
			if (ret_code3 <= 0){
				*ret_code = ret_code3;
				// printf("6:ret_code:%d\n", *ret_code);
				return;
			}
			get_point_award(map_id, &no_y_line_point, dir, 0.1, ret_code, got_face, ret_point);
			if (*ret_code > 0){
				*ret_code = 2;
				return;
			}
			check_point_help(map_id, &no_y_line_point, &ret_code3, &got_face2, ret_point);
			if (ret_code3 > 0){
				*ret_code = 1;
				*got_face = from_face;
				// printf("7:ret_code:%d\n", *ret_code);
			} else {
				get_point_award(map_id, &no_y_line_point, dir, -0.1, ret_code, got_face, ret_point);
				if (*ret_code > 0)
					*ret_code = 1;
			}

		} else {
			*ret_code = 2;
			*got_face = got_face2;
			ret_point->x = ret_point3.x;
			ret_point->y = ret_point3.y;
			ret_point->z = ret_point3.z;
		}
	}
}

//ret_code > 0 表示成功
static void check_point_help(int map_id, struct Point* ptr_point, int* ret_code, int* got_face, struct Point* ret_point)
{
	int divide_index = calc_divide_index(map_id, ptr_point);
	// printf("divide_index:%d\n", divide_index);
	if (divide_index == -1){
		*ret_code = 0;
		return;
	}

	struct DivideFaceIndexs face_indexs = map_divide_face_indexs[map_id][divide_index];
	// print_divide_face_indexs(&face_indexs);
	find_face(map_id, ptr_point, &face_indexs, ret_code, got_face, ret_point);
}


// ret_code: 1:表示找到一个点，2:表示找到一个点但是无法继续 0或负数表示失败 
static void check_dir_by_point_help(int map_id, struct Point* point, struct Point* dir, 
									struct Point* to_point, int from_face, 
									struct Point from_point, float need_dis, 
									int* ret_code, struct Point* ret_point, int call_times)
{
	if (call_times > 200)
	{
		*ret_code = 0;
		return;
	}

	int next_face = -1;
	struct Point temp_point1, temp_point2, temp_point3;
	struct Point next_point;
	// print_point(point);
	// print_point(dir);
	find_dir_point(map_id, &from_point, dir, from_face, ret_code, &next_face, &next_point);
	// printf("call find_dir_point, ret_code:%d\n", *ret_code);
	if (*ret_code < 1)
		return;

	temp_point1.x = next_point.x;
	temp_point1.y = 0;
	temp_point1.z = next_point.z;

	temp_point2.x = point->x;
	temp_point2.y = 0;
	temp_point2.z = point->z;
	dec(&temp_point1, &temp_point2, &temp_point3);
	float this_dis = length_sqrt(&temp_point3);
	// printf("this_dis:%f need_dis:%f\n", this_dis, need_dis);
	// print_point(&next_point);
	if (this_dis >= need_dis - 0.01)
	{
		int ret_code2, from_face2;
		struct Point ret_point2;
		get_point_adjust(map_id, to_point, dir, -0.01, ret_code, &from_face2, ret_point);
		// printf("end check_dir_by_point_help, ret_code:%d\n", *ret_code);
		if (*ret_code > 0)
			*ret_code = 1;
		return;
	} else {
		if (*ret_code == 2){
			// printf("loop check_dir_by_point_help to next_face:%d\n", next_face); 
			check_dir_by_point_help(map_id, point, dir, to_point, next_face, next_point, need_dis, ret_code, ret_point, call_times + 1);
		}
		else {
			*ret_code = 2;
			ret_point->x = next_point.x;
			ret_point->y = next_point.y;
			ret_point->z = next_point.z;
		}

	}
}

static void check_dir_help(int map_id, struct Point* point, struct Point* dir, float max_dis, 
						   int from_face, struct Point from_point, int* ret_code, struct Point* ret_point, int call_times)
{
	if (call_times > 200)
	{
		*ret_code = -1;
		return;
	}

	int next_face, got_face;
	struct Point next_point;
	struct Point temp_point1, temp_point2, temp_point3, no_y_maxdis_point;
	float this_dis, dir_y = dir->y, point_y = point->y;
	// printf("from_face:%d\n", from_face);
	find_dir_point(map_id, &from_point, dir, from_face, ret_code, &next_face, &next_point);
	if (*ret_code > 0)
	{
		dec2(next_point.x, 0, next_point.z, point->x, 0, point->z, &temp_point1);
		this_dis = length_sqrt(&temp_point1);
		if (this_dis >= max_dis - 0.01)
		{
			dir->y = 0;
			point->y = 0;
			normal(dir, &temp_point2);
			ride(&temp_point2, max_dis, &temp_point3);
			add(point, &temp_point3, &no_y_maxdis_point);
			dir->y = dir_y;
			point->y = point_y;

			get_point_adjust(map_id, &no_y_maxdis_point, dir, -0.01, ret_code, &got_face, ret_point);
		} else {
			if (*ret_code == 2){
				check_dir_help(map_id, point, dir, max_dis, next_face, next_point, ret_code, ret_point, call_times + 1);
			} else {
				ret_point->x = next_point.x;
				ret_point->y = next_point.y;
				ret_point->z = next_point.z;
			}
		}
	}

}


// =============================================================================
// -------------------------- 导出的给Erlang调用的方法 ------------------------- 
static ERL_NIF_TERM check_point(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	int map_id;
	double x, y, z;
	enif_get_int(env, argv[0], &map_id);
	enif_get_double(env, argv[1], &x);
	enif_get_double(env, argv[2], &y);
	enif_get_double(env, argv[3], &z);
	struct Point point = {x, y, z};
	// print_point(&point);
	// printf("call check_point map_id:%d, x1:%f, y1:%f, z1:%f\n", map_id, x, y, z);

	struct Point ret_point;
	int ret_code;
	int got_face;
	check_point_help(map_id, &point, &ret_code, &got_face, &ret_point);
	
	if (ret_code > 0){
		return make_point(env, &ret_point);
	} else {
		return enif_make_int(env, ret_code);
	}
}


static ERL_NIF_TERM check_dir_by_point(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	int map_id;
	const ERL_NIF_TERM* tuple1;
	const ERL_NIF_TERM* tuple2;
	int tpl_arity;
	double x1, y1, z1, x2, y2, z2;
	struct Point point, to_point, dir, temp_point;

	enif_get_int(env, argv[0], &map_id);
	enif_get_tuple(env, argv[1], &tpl_arity, &tuple1);
	enif_get_tuple(env, argv[2], &tpl_arity, &tuple2);

	enif_get_double(env, tuple1[0], &x1);
	enif_get_double(env, tuple1[1], &y1);
	enif_get_double(env, tuple1[2], &z1);

	enif_get_double(env, tuple2[0], &x2);
	enif_get_double(env, tuple2[1], &y2);
	enif_get_double(env, tuple2[2], &z2);
	// printf("call check_dir_by_point map_id:%d, x1:%f, y1:%f, z1:%f, x2:%f, y2:%f, z2:%f\n", map_id, x1, y1, z1, x2, y2, z2);

	point.x = x1;
	point.y = y1;
	point.z = z1;

	to_point.x = x2;
	to_point.y = y2;
	to_point.z = z2;

	// printf("x1:%f y1:%f z1:%f\n", x1, y1, z1);

	dec(&to_point, &point, &dir);
	dir.y = 0;
	if (fabs(dir.x) < 1e-6 && fabs(dir.y) < 1e-6 && fabs(dir.z) < 1e-6)
		return enif_make_int(env, -1);

	float temp_y1 = point.y, temp_y2 = to_point.y;
	point.y = 0;
	to_point.y = 0;
	dec(&to_point, &point, &temp_point);
	float need_dis = length_sqrt(&temp_point);
	point.y = temp_y1;
	to_point.y = temp_y2;

	struct Point from_point = point;
	struct Point ret_point;
	int ret_code = 0;
	check_dir_by_point_help(map_id, &point, &dir, &to_point, -1, from_point, need_dis, &ret_code, &ret_point, 0);
	// printf("map_id:%d\n", map_id);
	// print_point(&ret_point);
	if (ret_code > 0){
		// printf("4444444\n");
		return make_point(env, &ret_point);
	} else {
		// printf("33333333\n");
		return enif_make_int(env, ret_code);
	}
}

static ERL_NIF_TERM check_dir(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	int map_id;
	const ERL_NIF_TERM* tuple1;
	const ERL_NIF_TERM* tuple2;
	int tpl_arity;
	double x1, y1, z1, x2, y2, z2, max_dis;
	struct Point point, dir, temp_point;

	enif_get_int(env, argv[0], &map_id);
	enif_get_double(env, argv[1], &max_dis);
	enif_get_tuple(env, argv[2], &tpl_arity, &tuple1);
	enif_get_tuple(env, argv[3], &tpl_arity, &tuple2);

	enif_get_double(env, tuple1[0], &x1);
	enif_get_double(env, tuple1[1], &y1);
	enif_get_double(env, tuple1[2], &z1);

	enif_get_double(env, tuple2[0], &x2);
	enif_get_double(env, tuple2[1], &y2);
	enif_get_double(env, tuple2[2], &z2);

	// printf("call check_dir map_id:%d, max_dis:%f, x1:%f, y1:%f, z1:%f, x2:%f, y2:%f, z2:%f\n", map_id, max_dis, x1, y1, z1, x2, y2, z2);

	point.x = x1;
	point.y = y1;
	point.z = z1;

	dir.x = x2;
	dir.y = y2;
	dir.z = z2;

	if (max_dis < 0.01)
		return enif_make_int(env, -1);

	struct Point from_point = point;
	struct Point ret_point;
	int ret_code = 0;
	check_dir_help(map_id, &point, &dir, max_dis, -1, from_point, &ret_code, &ret_point, 0);
	if (ret_code > 0){
		return make_point(env, &ret_point);
	} else {
		return enif_make_int(env, ret_code);
	}
}

// 返回1：表示在范围内 0：没有在范围内 
static ERL_NIF_TERM calc_in_rect(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	int map_id;
	const ERL_NIF_TERM* tuple1;
	const ERL_NIF_TERM* tuple2;
	int tpl_arity;
	double src_x, src_y, src_z, target_x, target_y, target_z;
	double dir_val, target_radius;
	double rl, rw, uph, downh;
	struct Point src_point, target_point, vect_dir_point, temp_point;

	enif_get_int(env, argv[0], &map_id);
	enif_get_tuple(env, argv[1], &tpl_arity, &tuple1);
	enif_get_tuple(env, argv[2], &tpl_arity, &tuple2);
	enif_get_double(env, argv[3], &dir_val);
	enif_get_double(env, argv[4], &target_radius);
	enif_get_double(env, argv[5], &rl);
	enif_get_double(env, argv[6], &rw);
	enif_get_double(env, argv[7], &uph);
	enif_get_double(env, argv[8], &downh);

	enif_get_double(env, tuple1[0], &src_x);
	enif_get_double(env, tuple1[1], &src_y);
	enif_get_double(env, tuple1[2], &src_z);

	enif_get_double(env, tuple2[0], &target_x);
	enif_get_double(env, tuple2[1], &target_y);
	enif_get_double(env, tuple2[2], &target_z);

	src_point.x = src_x;
	src_point.y = src_y;
	src_point.z = src_z;

	target_point.x = target_x;
	target_point.y = target_y;
	target_point.z = target_z;

	double diff_height, diff_w, diff_l, radian;
	diff_height = src_point.y - target_point.y;
	if (diff_height >= 0 && diff_height > uph)
		return enif_make_int(env, 0);
	else if (diff_height < 0 && fabs(diff_height) > downh)
		return enif_make_int(env, 0);

	src_point.y = 0;
	target_point.y = 0;
	radian = angle2radian(dir_val);
	get_vect_by_dir(radian, &vect_dir_point);  //方向向量 
	dec(&target_point, &src_point, &temp_point);
	diff_w = dot_line_dis(&vect_dir_point, &temp_point) - target_radius; //方向垂直的距离 
	if (diff_w * 2 > rw)
		return enif_make_int(env, 0);

	radian = angle2radian(dir_val + 90);
	get_vect_by_dir(radian, &vect_dir_point);  //方向垂直向量
	dec(&target_point, &src_point, &temp_point);
	diff_l = dot_line_dis(&vect_dir_point, &temp_point) - target_radius; //方向的距离 
	if (diff_l * 2 > rl)
		return enif_make_int(env, 0); //长度超出 

	return enif_make_int(env, 1);
}


// 返回1：表示在范围内 0：没有在范围内 
static ERL_NIF_TERM calc_in_cir(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	int map_id;
	const ERL_NIF_TERM* tuple1;
	const ERL_NIF_TERM* tuple2;
	int tpl_arity;
	double src_x, src_y, src_z, target_x, target_y, target_z;
	double target_radius;
	double cir_radius, uph, downh;
	struct Point src_point, target_point, vect_dir_point, temp_point;

	enif_get_int(env, argv[0], &map_id);
	enif_get_tuple(env, argv[1], &tpl_arity, &tuple1);
	enif_get_tuple(env, argv[2], &tpl_arity, &tuple2);
	enif_get_double(env, argv[3], &target_radius);
	enif_get_double(env, argv[4], &cir_radius);
	enif_get_double(env, argv[5], &uph);
	enif_get_double(env, argv[6], &downh);

	enif_get_double(env, tuple1[0], &src_x);
	enif_get_double(env, tuple1[1], &src_y);
	enif_get_double(env, tuple1[2], &src_z);

	enif_get_double(env, tuple2[0], &target_x);
	enif_get_double(env, tuple2[1], &target_y);
	enif_get_double(env, tuple2[2], &target_z);

	src_point.x = src_x;
	src_point.y = src_y;
	src_point.z = src_z;

	target_point.x = target_x;
	target_point.y = target_y;
	target_point.z = target_z;

	double diff_height, distance;
	diff_height = src_point.y - target_point.y;
	if (diff_height >= 0 && diff_height > uph)
		return enif_make_int(env, 0);
	else if (diff_height < 0 && fabs(diff_height) > downh)
		return enif_make_int(env, 0);

	src_point.y = 0;
	target_point.y = 0;
	dec(&target_point, &src_point, &temp_point);
	distance = length_sqrt(&temp_point) - target_radius;
	if (distance > cir_radius)
		return enif_make_int(env, 0); //超出范围 

	return enif_make_int(env, 1);
}

// 返回1：表示在范围内 0：没有在范围内 
static ERL_NIF_TERM calc_in_ring(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	int map_id;
	const ERL_NIF_TERM* tuple1;
	const ERL_NIF_TERM* tuple2;
	int tpl_arity;
	double src_x, src_y, src_z, target_x, target_y, target_z;
	double target_radius;
	double oradis, iradis, uph, downh;
	struct Point src_point, target_point, vect_dir_point, temp_point;

	enif_get_int(env, argv[0], &map_id);
	enif_get_tuple(env, argv[1], &tpl_arity, &tuple1);
	enif_get_tuple(env, argv[2], &tpl_arity, &tuple2);
	enif_get_double(env, argv[3], &target_radius);
	enif_get_double(env, argv[4], &oradis);
	enif_get_double(env, argv[5], &iradis);
	enif_get_double(env, argv[6], &uph);
	enif_get_double(env, argv[7], &downh);

	enif_get_double(env, tuple1[0], &src_x);
	enif_get_double(env, tuple1[1], &src_y);
	enif_get_double(env, tuple1[2], &src_z);

	enif_get_double(env, tuple2[0], &target_x);
	enif_get_double(env, tuple2[1], &target_y);
	enif_get_double(env, tuple2[2], &target_z);

	src_point.x = src_x;
	src_point.y = src_y;
	src_point.z = src_z;

	target_point.x = target_x;
	target_point.y = target_y;
	target_point.z = target_z;

	double diff_height, distance;
	diff_height = src_point.y - target_point.y;
	if (diff_height >= 0 && diff_height > uph)
		return enif_make_int(env, 0);
	else if (diff_height < 0 && fabs(diff_height) > downh)
		return enif_make_int(env, 0);

	src_point.y = 0;
	target_point.y = 0;
	dec(&target_point, &src_point, &temp_point);
	distance = length_sqrt(&temp_point) - target_radius;
	if (distance > oradis)
		return enif_make_int(env, 0); //超出范围 
	if (distance < iradis)
		return enif_make_int(env, 0); //超出范围 

	return enif_make_int(env, 1);
}

// 返回1：表示在范围内 0：没有在范围内 
static ERL_NIF_TERM calc_in_sector(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	int map_id;
	const ERL_NIF_TERM* tuple1;
	const ERL_NIF_TERM* tuple2;
	int tpl_arity;
	double src_x, src_y, src_z, target_x, target_y, target_z;
	double dir_val, target_radius;
	double radis, seg_ang, uph, downh;
	struct Point src_point, target_point, vect_dir_point, diff_point, temp_point;

	enif_get_int(env, argv[0], &map_id);
	enif_get_tuple(env, argv[1], &tpl_arity, &tuple1);
	enif_get_tuple(env, argv[2], &tpl_arity, &tuple2);
	enif_get_double(env, argv[3], &dir_val);
	enif_get_double(env, argv[4], &target_radius);
	enif_get_double(env, argv[5], &radis);
	enif_get_double(env, argv[6], &seg_ang);
	enif_get_double(env, argv[7], &uph);
	enif_get_double(env, argv[8], &downh);

	enif_get_double(env, tuple1[0], &src_x);
	enif_get_double(env, tuple1[1], &src_y);
	enif_get_double(env, tuple1[2], &src_z);

	enif_get_double(env, tuple2[0], &target_x);
	enif_get_double(env, tuple2[1], &target_y);
	enif_get_double(env, tuple2[2], &target_z);

	src_point.x = src_x;
	src_point.y = src_y;
	src_point.z = src_z;

	target_point.x = target_x;
	target_point.y = target_y;
	target_point.z = target_z;

	double diff_height;
	diff_height = src_point.y - target_point.y;
	if (diff_height >= 0 && diff_height > uph)
		return enif_make_int(env, 0);
	else if (diff_height < 0 && fabs(diff_height) > downh)
		return enif_make_int(env, 0);

	double distance;
	src_point.y = 0;
	target_point.y = 0;
	dec(&target_point, &src_point, &diff_point);
	distance = length_sqrt(&diff_point) - target_radius;
	if (distance > radis)
		return enif_make_int(env, 0); //超出范围
 
	double radian, radian2, temp_angle;
	radian = angle2radian(dir_val);
	get_vect_by_dir(radian, &vect_dir_point);  //方向向量 
	radian2 = get_radian(&vect_dir_point, &diff_point);
	temp_angle = radian2angle(radian2);
	if (temp_angle * 2 > seg_ang)
		return enif_make_int(env, 0);

	return enif_make_int(env, 1);
}

static ERL_NIF_TERM find_turn_dir_point(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	int map_id;
	const ERL_NIF_TERM* tuple1;
	const ERL_NIF_TERM* tuple2;
	int tpl_arity, dir;
	double src_x, src_y, src_z, target_x, target_y, target_z;
	double distance;
	struct Point src_point, target_point, temp_point, ret_point;

	enif_get_int(env, argv[0], &map_id);
	enif_get_tuple(env, argv[1], &tpl_arity, &tuple1);
	enif_get_tuple(env, argv[2], &tpl_arity, &tuple2);

	enif_get_double(env, tuple1[0], &src_x);
	enif_get_double(env, tuple1[1], &src_y);
	enif_get_double(env, tuple1[2], &src_z);

	enif_get_double(env, tuple2[0], &target_x);
	enif_get_double(env, tuple2[1], &target_y);
	enif_get_double(env, tuple2[2], &target_z);

	src_point.x = src_x;
	src_point.y = src_y;
	src_point.z = src_z;

	target_point.x = target_x;
	target_point.y = target_y;
	target_point.z = target_z;

	temp_point.x = src_x - target_x;
	temp_point.y = 0;
	temp_point.z = src_z - target_z;
	distance = length_sqrt(&temp_point);
	if (distance < 0.2)
	{
		next_seed = next_seed + (int)time(0);
		srand(next_seed);
		dir = rand() % 360;
		// printf("next_seed:%d rand dir:%d\n", next_seed, dir);
	} else {
		dec(&src_point, &target_point, &temp_point);
		dir = floor(get_dir_angle(&temp_point));
	}
	// get_turn_point
	get_vect_by_dir(angle2radian(dir), &temp_point);
	normal(&temp_point, &ret_point);
	ride(&ret_point, 2.0, &temp_point);
	add(&src_point, &temp_point, &ret_point);
	// check_point
	int ret_code;
	int got_face;
	check_point_help(map_id, &ret_point, &ret_code, &got_face, &temp_point);
	
	if (ret_code > 0){
		return make_point_and_int_dir(env, &temp_point, dir);
	} else {
		return make_point_and_int_dir(env, &src_point, dir);
	}

}

static ERL_NIF_TERM hello(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	double x;
	enif_get_double(env, argv[0], &x);
	printf("x:%f\n", x);
	return enif_make_double(env, x);
}

static ERL_NIF_TERM get_point(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	return make_point(env, &(points_1[0]));
}

static ERL_NIF_TERM test_check_point(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	int map_id;
	double x, y, z;
	enif_get_int(env, argv[0], &map_id);
	enif_get_double(env, argv[1], &x);
	enif_get_double(env, argv[2], &y);
	enif_get_double(env, argv[3], &z);

	struct Point point = {x, y, z};
	// int* face_indexs = check_point(&point);
	int divide_index = calc_divide_index(map_id, &point);
	struct DivideFaceIndexs face_indexs = divide_face_indexs_1[divide_index];
	ERL_NIF_TERM res = enif_make_list(env, 0);
	int length = face_indexs.size; 
	// printf("divide_index:%d, length:%d\n", divide_index, length);
	for (int i = 0; i < length; ++i)
	{
		res = enif_make_list_cell(env, enif_make_int(env, face_indexs.index_arrary[i]), res);
	}

	return res;
}

static ERL_NIF_TERM test_sleep(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	int x;
	enif_get_int(env, argv[0], &x);
	#ifdef __GNUC__
	sleep(ceil(x / 1000));
	#else
	Sleep(x);
	#endif
	return enif_make_int(env, 1);
}

static ERL_NIF_TERM test_angle2radian(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	double angle, result;
	enif_get_double(env, argv[0], &angle);
	result = angle2radian(angle);
	return enif_make_double(env, result);
}

static ERL_NIF_TERM test_radian2angle(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	double r, result;
	enif_get_double(env, argv[0], &r);
	result = radian2angle(r);
	return enif_make_double(env, result);
}

static ERL_NIF_TERM test_get_vect_by_dir(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	double r;
	struct Point result;
	enif_get_double(env, argv[0], &r);
	get_vect_by_dir(r, &result);
	return make_point(env, &result);
}


static ErlNifFunc nif_funcs[] =
{
	{ "check_point", 4, check_point },
	{ "check_dir_by_point", 3, check_dir_by_point },
	{ "check_dir", 4, check_dir },
	{ "calc_in_rect", 9, calc_in_rect },
	{ "calc_in_cir", 7, calc_in_cir },
	{ "calc_in_ring", 8, calc_in_ring },
	{ "calc_in_sector", 9, calc_in_sector },
	{ "find_turn_dir_point", 3, find_turn_dir_point },

	{ "test_sleep", 1, test_sleep },
	{ "get_point", 0, get_point },
	{ "test_check_point", 4, test_check_point },
	{ "hello", 1, hello },
	{ "test_angle2radian", 1, test_angle2radian },
	{ "test_radian2angle", 1, test_radian2angle },
	{ "test_get_vect_by_dir", 1, test_get_vect_by_dir }
};

ERL_NIF_INIT(cerl_map_api, nif_funcs, NULL, NULL, NULL, NULL)


int main(int argc, char const *argv[])
{
	int map_id = 2;
	struct Point point, to_point, dir, temp_point;
	point.x = 23.40349769592285;
	point.y = 43.52391815185547;
	point.z = 67.92893981933594;

	to_point.x = 20.797797415013264;
	to_point.y = 43.52391815185547;
	to_point.z = 64.99749097980646;
	float max_dis = 5.0;
	
	// ====================== test check_dir_by_point_help ======================
	dec(&to_point, &point, &dir);
	dir.y = 0;
	if (fabs(dir.x) < 1e-6 && fabs(dir.y) < 1e-6 && fabs(dir.z) < 1e-6)
		return -1;

	float temp_y1 = point.y, temp_y2 = to_point.y;
	point.y = 0;
	to_point.y = 0;
	dec(&to_point, &point, &temp_point);
	float need_dis = length_sqrt(&temp_point);
	point.y = temp_y1;
	to_point.y = temp_y2;

	struct Point from_point = point;
	struct Point ret_point;
	int ret_code = 0;
	check_dir_by_point_help(map_id, &point, &dir, &to_point, -1, from_point, need_dis, &ret_code, &ret_point, 0);

	//========================== test check_dir_help ===========================
	// if (max_dis < 0.01)
	// 	return -1;

	// struct Point from_point = point;
	// struct Point ret_point;
	// int ret_code = 0;
	// check_dir_help(map_id, &point, &to_point, max_dis, -1, from_point, &ret_code, &ret_point);

	//========================== test find_dir_point ===========================
	// int ret_code = 0;
	// int next_face;
	// struct Point next_point;
	// dec(&to_point, &point, &dir);
	// dir.y = 0;
	// find_dir_point(map_id, &point, &dir, 569, &ret_code, &next_face, &next_point);

	// ========================== test check_point_help =========================
	// struct Point ret_point, input_point = {88.98220832055476,0.0,36.11151519637815};
	// int ret_code;
	// int got_face;
	// check_point_help(map_id, &input_point, &ret_code, &got_face, &ret_point);

	// struct Point p={1.906667,0,55.6399},p1={1.906667,0,55.64},p2={12.04667,0,54.86},p3={1.906667,1.0,55.6399};
	// int ret = check_point_in_face(&p,&p1,&p2,&p3);
	return 0;
}