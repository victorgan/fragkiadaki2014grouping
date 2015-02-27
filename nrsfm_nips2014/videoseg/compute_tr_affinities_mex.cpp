// function A=compute_tr_affinities_mex(X,T,tr_start, tr_end, ntr, sigma, pi, pj);
// Input:
// X (double)      : space time point x
// Y (double)      : space time point y
// T (double)         : space time point t
// npoint          : number of points
// tr_start(double)   : the space time point start index of all tracks
// tr_end(double)     : the space time point end index of all tracks
// ntr             : number of tracks
// aff_var         : affinity variance
// verbose         : if 2, display info

// Out:
//  A = affinity with max velocity difference and max distance difference at [pi,pj]


# include "mex.h"
# include "math.h"

double max(double a, double b) {
    double big;
    if(a>b)
        big = a;
    else
        big = b;
    return big;
}

double min(double a, double b) {
    double small;
    if(a<b)
        small = a;
    else
        small = b;
    return small;
}


double compute_affinities(double *X, double *Y,  double *T, double *V,
        double* tr_start, double* tr_end, double sigma,
        int np, int nd,  int tr1, int tr2) {
    
    double euk_dist_c, euk_dist_max, Du_dist_max, Du_dist, Du_dist_t, Ut1, Vt1, Ut2, Vt2,
            Dut, Vart1, Vart2;
    int st1c, st2c, tf;
    double aff;
    
    //compute tf
    tf=min(T[(int) tr_end[tr1]]-T[(int) tr_start[tr1]],T[(int) tr_end[tr2]]-T[(int) tr_start[tr2]]);
    tf=min(tf,5);
    //mexPrintf("tf = %d\n",tf);
    if (tf<3)
            return 0;
   
    int common_start = (int) max(T[(int) tr_start[tr1]], T[(int) tr_start[tr2]]);
    int common_end   = (int) min(T[(int) tr_end[tr1]]-tf, T[(int) tr_end[tr2]]-tf);
    int common_len    = common_end - common_start + 1;
    //mexPrintf("common_len = %d\n",common_len);
    if (common_len<=0)   
    {
        aff=0;
     return aff;
    }
    
    
//find the max euk_dist
//     euk_dist_max = 0;
//     for (int frameindex = common_start; frameindex<=common_end; frameindex++){
//         st1c  = (int)tr_start[tr1] + frameindex - (int)T[(int) tr_start[tr1]] ;
//         st2c  = (int)tr_start[tr2] + frameindex - (int)T[(int) tr_start[tr2]] ;
//         euk_dist_c=sqrt(pow(X[st1c]-X[st2c], 2)+pow(Y[st1c]-Y[st2c], 2));
//         if (euk_dist_c>euk_dist_max)
//             euk_dist_max = euk_dist_c;
//     }
  //   mexPrintf("euk_dist_max = %f\n",euk_dist_max);
//find the max traj distance
    euk_dist_max = 0;
    Du_dist_max = 0;
    Du_dist = 0;
    for (int frameindex = common_start; frameindex<=common_end; frameindex++) {
        st1c  = (int)tr_start[tr1] + frameindex - (int)T[(int) tr_start[tr1]] ;
        st2c  = (int)tr_start[tr2] + frameindex - (int)T[(int) tr_start[tr2]] ;
           euk_dist_c=sqrt(pow(X[st1c]-X[st2c], 2)+pow(Y[st1c]-Y[st2c], 2));
        if (euk_dist_c>euk_dist_max)
            euk_dist_max = euk_dist_c;
        Ut1=X[st1c+tf]-X[st1c];
        Ut2=X[st2c+tf]-X[st2c];
        Vt1=Y[st1c+tf]-Y[st1c];
        Vt2=Y[st2c+tf]-Y[st2c];
        Dut=(pow(Ut1-Ut2,2)+pow(Vt1-Vt2,2))/tf;
        //mexPrintf("Dut = %f\n",Dut);
        Vart1=0;
        Vart2=0;
        for (int k=1; k<=tf; k++){
            Vart1=Vart1+V[st1c+k];
            Vart2=Vart2+V[st2c+k];
        }
        Du_dist_t=Dut /min(Vart1, Vart2);
        if (Du_dist_t>Du_dist)
            Du_dist=Du_dist_t;
        //mexPrintf("Du_dist_t = %f\n denom=%f",Du_dist_t,min(Vart1, Vart2));
    }
    //mexPrintf("Du_dist = %f\n",Du_dist);
    aff = exp(-sigma * Du_dist*euk_dist_max);
    if (aff<0.0001)
            aff=0;
    
    return aff;
}



void mexFunction(int nlhs, mxArray *plhs[], int nrhs,
        const mxArray *prhs[]) {
    /* declare variables */
    double *X, *Y, *T, *V, *tr_start, *tr_end, sigma;
    int    ntr, np, nd, npairs;
    int    i, j, k, total, tf;
    unsigned int *pi, *pj;
    double * w;
    mwIndex *ir, *jc;
    
    
//     if (nrhs != 14) {
//         mexErrMsgTxt("Not enough input arguments!! 13 Input Argument expected");
//     }
    
    X=mxGetPr(prhs[0]);
    np = (int)mxGetM(prhs[0]);
    nd = (int)mxGetN(prhs[0]);
  //  mexPrintf("np = %d , \t nd=%d \t", np, nd);
    Y=mxGetPr(prhs[1]);
    T=mxGetPr(prhs[2]);
    V=mxGetPr(prhs[3]);
    
    tr_start = mxGetPr(prhs[4]);
    tr_end   = mxGetPr(prhs[5]);
    ntr      = (int) mxGetScalar(prhs[6]);
    sigma   = mxGetScalar(prhs[7]);
    
    
    
    
    pi = (unsigned int*)mxGetData(prhs[8]);
    pj = (unsigned int*)mxGetData(prhs[9]);
      if (!mxIsUint32(prhs[8]) | !mxIsUint32(prhs[9])) {
        mexErrMsgTxt("Index pair shall be of type UINT32");
    }
    npairs      = (int) mxGetScalar(prhs[10]);
  //  mexPrintf("\t\t\t %d comparisons \n", npairs);

   
    
  
    
    
//     return;
    
//     /* Check Input */
//     int nx = mxGetM(prhs[0]);
//     if (nx!= npoint)
//         mexErrMsgTxt("problem in the length of input X");
//
//     int ny = mxGetM(prhs[1]);
//     if (ny!= npoint)
//         mexErrMsgTxt("problem in the length of input Y");
//
//     int nt = mxGetM(prhs[2]);
//     if (nt!= npoint)
//         mexErrMsgTxt("problem in the length of input T");
//
//     int nux = mxGetM(prhs[3]);
//     if (nux!= npoint)
//         mexErrMsgTxt("problem in the length of input Ux");
//
//     int nuy = mxGetM(prhs[4]);
//     if (nuy!= npoint)
//         mexErrMsgTxt("problem in the length of input Uy");
//
//     int nstart = mxGetM(prhs[6]);
//     if (nstart!= ntr)
//         mexErrMsgTxt("problem in the length of input trajectory start");
//
//     int nend = mxGetM(prhs[7]);
//     if (nend!= ntr)
//         mexErrMsgTxt("problem in the length of input trajectory end");
//
//
//     if (verbose>=2)
//         mexPrintf("\t\t\t %d Trajectory, %d XYT, VarEuk = %f \n", ntr, npoint,my_var_euk);
//
//
//     return;
    
    
    
    
//     if (nlhs>0){
//         plhs[0] = mxCreateSparse(ntr, ntr, pj[ntr], mxREAL);
//     }
//     if (plhs[0]==NULL) {
//         mexErrMsgTxt("Not enough memory for the plhsput matrix");
//     }
//     w = mxGetPr(plhs[0]);
//     ir = mxGetIr(plhs[0]);
//     jc = mxGetJc(plhs[0]);
//
//
//     /* computation */
//     total=0;
//     for(j=0; j<ntr; j++){
//         jc[j] = total;
//         for (k=pj[j]; k<pj[j+1]; k++) {
//             i = pi[k];
//             if (i==j){
//                 continue;
//             }
//             ir[total] = i;
//             w[total] = compute_affinities(X, T, tr_start, tr_end, sigma, np, nd, i, j);
//             //w[total] = 0.1;
//             total = total + 1;
//         }/*i*/
//     }/*j*/
//     //mexPrintf("j = %d \t, pj(end) = %d \t, Total =  %d \n",j, pj[j], total);
//     jc[ntr] = total;
    
    if (nlhs>0){
        plhs[0] = mxCreateDoubleMatrix(npairs, 1, mxREAL);
    }
    if (plhs[0]==NULL) {
        mexErrMsgTxt("Not enough memory for the plhsput matrix");
    }
    w = mxGetPr(plhs[0]);
    total=0;
    for(k=0; k<npairs; k++){
        w[total] = compute_affinities(X, Y, T,V, tr_start, tr_end, sigma, np, nd, pi[k], pj[k]);
        total = total + 1;
    }
}
