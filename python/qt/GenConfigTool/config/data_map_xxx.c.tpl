#include <stdio.h>
#include "map.h"
#include "erl_nif.h"  


struct DivideInfo divide_info_${map_id} = {
    {${from_point[0]}, ${from_point[1]}, ${from_point[2]}},
    {${to_point[0]}, ${to_point[1]}, ${to_point[2]}},
    {${per_point[0]}, ${per_point[1]}, ${per_point[2]}}
};


struct Point points_${map_id}[] = {
<?py for point_index in point_dict: ?>
    {${point_dict[point_index][0]}, ${point_dict[point_index][1]}, ${point_dict[point_index][2]}},
<?py #endfor ?>
    {1.0, 0, 1.0}
};


struct Line lines_${map_id}[] = {
<?py for line in line_arrary: ?>
    {${line.p1}, ${line.p2}, {${line.centre_point[0]}, ${line.centre_point[1]}, ${line.centre_point[2]}}, 1, 2},
<?py #endfor ?>
    {0, 1, {25.9, 7.208993, 25.6}, 1, 2}
};

int get_line_index_${map_id}(int p1, int p2)
{
    int t;
    if (p1 > p2){
        t = p1;
        p1 = p2;
        p2 = t;
    }
    int val = p1 * 10000 + p2;
    switch (val){
<?py for index in line_index_dict: ?>
        case ${index}: return ${line_index_dict[index]};
<?py #endfor ?>
        default: return -1;
    }
}


struct Face Faces_${map_id}[] = {
<?py for face in face_arrary: ?>
    {${face.p1}, ${face.p2}, ${face.p3}, {${face.mini_point[0]}, ${face.mini_point[1]}, ${face.mini_point[2]}}, {${face.max_point[0]}, ${face.max_point[1]}, ${face.max_point[2]}}},
<?py #endfor ?>
    {0, 0, 0, {0, 0, 0}, {0, 0, 0}}
};

int get_face_index_${map_id}(int p1, int p2, int p3)
{
    int t;
    if(p1>p2)
    {
        t = p1;
        p1 = p2;
        p2 = t;
    }
    if(p1>p3)
    {
        t = p1;
        p1 = p3;
        p3 = t;
    }
    if(p2>p3)
    {
        t = p2;
        p2 = p3;
        p3 = t;
    }
    int val = p1 * 100000 + p2 * 100 + p3;
    switch (val){
<?py for index in face_index_dict: ?>
        case ${index}: return ${face_index_dict[index]};
<?py #endfor ?>
        default: return -1;
    }
}


struct DivideFaceIndexs divide_face_indexs_${map_id}[] = {
<?py for divide in divide_arrary: ?>
    {${len(divide)}, {${', '.join(divide)}}},
<?py #endfor ?>
    {0, {0}}
};

int get_divide_index_${map_id}(int cell_x, int cell_z)
{
    int val = cell_x * 1000 + cell_z;
    switch (val){
<?py for index in divide_index_dict: ?>
        case ${index}: return ${divide_index_dict[index]};
<?py #endfor ?>
        default: return -1;
    }
}
