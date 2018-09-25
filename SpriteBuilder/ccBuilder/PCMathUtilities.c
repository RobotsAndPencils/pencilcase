//
//  PCMathUtilities.c
//  PCPlayer
//
//  Created by Cody Rayment on 2014-09-02.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#include "PCMathUtilities.h"
#include <string.h>
#include "CGPointUtilities.h"

CGFloat pc_clampf(CGFloat value, CGFloat min, CGFloat max) {
    if (min > max) {
        PC_SWAP(min, max);
    }
    return value < min ? min : value < max ? value : max;
}

#pragma mark - From Chipmunk

static int pc_QHullPartition(CGPoint *verts, int count, CGPoint a, CGPoint b, CGFloat tol) {
    if(count == 0) return 0;

    CGFloat max = 0;
    int pivot = 0;

    CGPoint delta = pc_CGPointSubtract(b, a);
    CGFloat valueTol = tol*pc_CGPointLength(delta);

    int head = 0;
    for(int tail = count-1; head <= tail;){
        CGFloat value = pc_CGPointCross(delta, pc_CGPointSubtract(verts[head], a));
        if(value > valueTol){
            if(value > max){
                max = value;
                pivot = head;
            }

            head++;
        } else {
            PC_SWAP(verts[head], verts[tail]);
            tail--;
        }
    }

    // move the new pivot to the front if it's not already there.
    if(pivot != 0) PC_SWAP(verts[0], verts[pivot]);
    return head;
}


static int pc_QHullReduce(CGFloat tol, CGPoint *verts, int count, CGPoint a, CGPoint pivot, CGPoint b, CGPoint *result)
{
    if(count < 0){
        return 0;
    } else if(count == 0) {
        result[0] = pivot;
        return 1;
    } else {
        int left_count = pc_QHullPartition(verts, count, a, pivot, tol);
        int index = pc_QHullReduce(tol, verts + 1, left_count - 1, a, verts[0], pivot, result);

        result[index++] = pivot;

        int right_count = pc_QHullPartition(verts + left_count, count - left_count, pivot, b, tol);
        return index + pc_QHullReduce(tol, verts + left_count + 1, right_count - 1, pivot, verts[left_count], b, result + index);
    }
}

void pc_LoopIndexes(CGPoint *verts, int count, int *start, int *end)
{
    (*start) = (*end) = 0;
    CGPoint min = verts[0];
    CGPoint max = min;

    for(int i=1; i<count; i++){
        CGPoint v = verts[i];

        if(v.x < min.x || (v.x == min.x && v.y < min.y)){
            min = v;
            (*start) = i;
        } else if(v.x > max.x || (v.x == max.x && v.y > max.y)){
            max = v;
            (*end) = i;
        }
    }
}


// QuickHull seemed like a neat algorithm, and efficient-ish for large input sets.
// My implementation performs an in place reduction using the result array as scratch space.
int pc_ConvexHull(int count, CGPoint *verts, CGPoint *result, int *first, CGFloat tol) {
    if (result){
        // Copy the line vertexes into the empty part of the result polyline to use as a scratch buffer.
        memcpy(result, verts, count*sizeof(CGPoint));
    } else {
        // If a result array was not specified, reduce the input instead.
        result = verts;
    }

    // Degenerate case, all poins are the same.
    int start, end;
    pc_LoopIndexes(verts, count, &start, &end);
    if(start == end){
        if(first) (*first) = 0;
        return 1;
    }

    PC_SWAP(result[0], result[start]);
    PC_SWAP(result[1], result[end == 0 ? start : end]);

    CGPoint a = result[0];
    CGPoint b = result[1];

    if(first) (*first) = start;
    int resultCount = pc_QHullReduce(tol, result + 2, count - 2, a, b, a, result + 1) + 1;
    return resultCount;
}

void pc_applyRotationToPoints(CGFloat rotation, CGPoint *points, uint count) {
    for (uint pointIndex = 0; pointIndex < count; pointIndex++) {
        points[pointIndex] = pc_rotatePointByRotation(points[pointIndex], rotation);
    }
}
