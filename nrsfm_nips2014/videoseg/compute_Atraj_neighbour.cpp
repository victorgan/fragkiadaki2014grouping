// function [pi,pj]=compute_Atraj_neighbour(tr, trFrame, cutoffx, cutoffy, samplestep,verbose);
// Input:
// tr     :  structure of trajectories. Each index has field XYTPos
// trFrame:  cell array of space time point.
//           Each cell is #Npts x 3.
//                 #Npts is number of space time point,
//                 columns are (x, y, frameid)
// cutoffx, cutoffy : where to cutout
// samplestep : how much to sample
// verbose : if >=2, display info

// Ouput:
// [pi, pj]        : index pair representation for MATLAB sparse matrix

//  Weiyu Zhang, Jan 13 2012


# include "mex.h"
# include "math.h"
# include "matrix.h"



void mexFunction(int nlhs, mxArray *out[], int nrhs,
        const mxArray *in[]) {
    
    /* declare variables */
    
    
    
    if (nrhs != 6) {
        mexErrMsgTxt("Not correct input arguments!! 6 Input Argument expected");
    }
    
    mwSize nframes;
    mwSize ntr;
    mwIndex index;
    int number_of_fields, field_index;
    double cutoffx, cutoffy;
    int samplestep;
    
    //const char  *field_name;
    
    const mxArray *track_tr;
    const mxArray *frame_ptr;
    const mwSize  *trdim, *framedim;
    
    
    
    
    ntr = mxGetNumberOfElements(in[0]);
    number_of_fields = mxGetNumberOfFields(in[0]);
    //mexPrintf("%d Trajectories, %d Properties\n", ntr,number_of_fields);
    
    nframes = mxGetNumberOfElements(in[1]);
    //mexPrintf("total num of cells = %d\n", nframes);
    
    cutoffx = mxGetScalar(in[2]);
    cutoffy = mxGetScalar(in[3]);
    samplestep = (int) mxGetScalar(in[4]);
    int verbose = (int) mxGetScalar(in[5]);
    
    for (index=0; index<nframes; index++)  {
        
        frame_ptr = mxGetCell(in[1], index);
        if (frame_ptr == NULL) {
            mexPrintf("\t T: %d, Empty Frame\n", index+1);
        } else {
            trdim = mxGetDimensions(frame_ptr);
            //mexPrintf("\t T: %d, %d x %d\n", index+1, trdim[0], trdim[1]);
            if (trdim[1]!=3)
                mexErrMsgTxt("Each Frame need to be npts x 3");
        }
    }
    
    
    
    
    // create new pointer array
    int **neighbour = (int **)mxCalloc(ntr, sizeof(int *));
    int *neighbourgraph = (int*) mxCalloc(ntr, sizeof(int));
    int *total_c    = (int *)mxCalloc(ntr, sizeof(int));
//     // create new book keeping
    
    int framecnt, frameid, i, j;
//     int samplestep = 1;
//     double cutoffx = 100;
//     double cutoffy = 100;
    double *track, *frame;
    
    int cnt = 0;
    int total = 0;
    
    
    for (i=0; i<ntr; i++){
        
        for (index=0; index<ntr;index++)
            neighbourgraph[index] = 0;
        
        field_index = 0;// which field to look at
        
//         field_name = mxGetFieldNameByNumber(in[0],
//                 field_index);
//         mexPrintf(".%s\n", field_name);
        
        track_tr = mxGetFieldByNumber(in[0],
                i,
                field_index);
        trdim = mxGetDimensions(track_tr);
        //mexPrintf("\t Track: %d, %d x %d\n", i+1, trdim[0], trdim[1]);
        
        total_c[i] = 0;
        framecnt = 0;
        
        track = mxGetPr(track_tr);
        
        while(framecnt<trdim[1]){
            frameid = (int) track[2 + framecnt*3] -1;
            frame_ptr = mxGetCell(in[1], frameid);
            framedim = mxGetDimensions(frame_ptr);
            frame = mxGetPr(frame_ptr);
//
            for (j=0; j<framedim[0]; j++){
                if (fabs(frame[j] - track[framecnt*3])<cutoffx && fabs(frame[j+ framedim[0]] - track[1+ framecnt*3])<cutoffy){
                    neighbourgraph[(int) (frame[j + 2*framedim[0]]-1)] = 1;
                }
//                 if (i==14999 || (frame[j + 2*framedim[0]]-1)==14998)
//                 {
//                     mexPrintf("\t Frame %d, line %d\n", frameid+1, j+1);
//                     mexPrintf("\t Track 1: %f, %f \t Track 2: %f, %f\n", frame[j],frame[j+ framedim[0]],track[framecnt*3],track[1+ framecnt*3]);
//                 }
            }
            framecnt = framecnt + samplestep;
        }
        for (j=0; j<ntr; j++){
            if (j==i || (neighbourgraph[j]==0))
                continue;
            total_c[i]++;
            total++;
        }
        
        neighbour[i] = (int*) mxCalloc(total_c[i], sizeof(int));
        cnt = 0;
        for (j=0; j<ntr; j++){
            if (j==i || (neighbourgraph[j]==0))
                continue;
            neighbour[i][cnt] = j;
            cnt ++;
        }
        
        //mexPrintf("\t Track: %d, frame %d\n", i+1, frameid + 1);
    }
    
    // Create Output
    out[0] = mxCreateNumericMatrix(total, 1, mxUINT32_CLASS, mxREAL);
	out[1] = mxCreateNumericMatrix(ntr+1,  1, mxUINT32_CLASS, mxREAL);
    unsigned int *qi = (unsigned int *)mxGetData(out[0]);
	unsigned int *qj = (unsigned int *)mxGetData(out[1]);
    if (in[0]==NULL || in[1]==NULL) {
	    mexErrMsgTxt("Not enough space for the output matrix.");
	}
    
    total = 0;
    for (i=0;i<ntr;i++){
        qj[i] = total;
        for (j=0;j<total_c[i];j++){
            qi[total] = (unsigned int) neighbour[i][j];
            total ++;
        }   
    }
    qj[ntr] = total;

    if (verbose>=2)
        mexPrintf("\t\t\t %d Trajectory, Cutoffx = %f, Cutoffy = %f, %d Neighbours\n", ntr, cutoffx, cutoffy, total);
    mxFree(neighbourgraph);
    for (i=0;i<ntr;i++)
        mxFree(neighbour[i]);
    mxFree(total_c);
    mxFree(neighbour);
    
}
