* Open File *
 
GET DATA 
  /TYPE=TXT 
  /FILE="D:\Dropbox\phD\analysis\results\results\spss\group bridging\584_group_bridging.csv" 
  /DELCASE=LINE 
  /DELIMITERS="," 
  /ARRANGEMENT=DELIMITED 
  /FIRSTCASE=2 
  /IMPORTCASE=ALL 
  /VARIABLES= 
  Name A29 
  FF_bin_degree F15.13 
  FF_bin_in_degree F16.14 
  FF_bin_out_degree F16.14 
  FF_volume_in F7.1 
  FF_volume_out F7.1 
  FF_bin_betweeness F17.15 
  FF_bin_closeness F14.12 
  FF_bin_pagerank F17.15 
  FF_bin_c_size F16.14 
  FF_bin_c_density F16.14 
  FF_bin_c_hierarchy F17.15 
  FF_bin_c_index F15.13 
  AT_bin_degree F16.14 
  AT_bin_in_degree F16.14 
  AT_bin_out_degree F16.14 
  AT_bin_betweeness F17.15 
  AT_bin_closeness F14.12 
  AT_bin_pagerank F17.15 
  AT_bin_c_size F16.14 
  AT_bin_c_density F17.15 
  AT_bin_c_hierarchy F17.15 
  AT_bin_c_index F16.14 
  AT_volume_in F7.1 
  AT_volume_out F7.1 
  RT_volume_in F6.1 
  RT_volume_out F7.1. 
CACHE. 
EXECUTE.

* Graph all Distributions *

GRAPH
	/HISTOGRAM(NORMAL)=FF_bin_degree.
GRAPH
	/HISTOGRAM(NORMAL)=FF_bin_in_degree.
GRAPH
	/HISTOGRAM(NORMAL)=FF_bin_out_degree.
GRAPH
	/HISTOGRAM(NORMAL)=FF_volume_in.
GRAPH
	/HISTOGRAM(NORMAL)=FF_volume_out.
GRAPH
	/HISTOGRAM(NORMAL)=FF_bin_betweeness.
GRAPH
	/HISTOGRAM(NORMAL)=FF_bin_closeness.
GRAPH
	/HISTOGRAM(NORMAL)=FF_bin_pagerank.
GRAPH
	/HISTOGRAM(NORMAL)=FF_bin_c_size.
GRAPH
	/HISTOGRAM(NORMAL)=FF_bin_c_density.
GRAPH
	/HISTOGRAM(NORMAL)=FF_bin_c_hierarchy.
GRAPH
	/HISTOGRAM(NORMAL)=AT_bin_degree.
GRAPH
	/HISTOGRAM(NORMAL)=AT_bin_in_degree.
GRAPH
	/HISTOGRAM(NORMAL)=AT_bin_out_degree.
GRAPH
	/HISTOGRAM(NORMAL)=AT_bin_betweeness.
GRAPH
	/HISTOGRAM(NORMAL)=AT_bin_closeness.
GRAPH
	/HISTOGRAM(NORMAL)=AT_bin_pagerank.
GRAPH
	/HISTOGRAM(NORMAL)=AT_bin_c_size.
GRAPH
	/HISTOGRAM(NORMAL)=AT_bin_c_density.
GRAPH
	/HISTOGRAM(NORMAL)=AT_bin_c_hierarchy.
GRAPH
	/HISTOGRAM(NORMAL)=AT_bin_c_index.
GRAPH
	/HISTOGRAM(NORMAL)=AT_volume_in.
GRAPH
	/HISTOGRAM(NORMAL)=AT_volume_out.
GRAPH
	/HISTOGRAM(NORMAL)=RT_volume_in.
GRAPH
	/HISTOGRAM(NORMAL)=RT_volume_out.

* Examine the IVs and DVs *

EXAMINE VARIABLES= FF_bin_degree FF_bin_in_degree FF_bin_out_degree FF_bin_betweeness FF_bin_closeness FF_bin_eigenvector 
FF_volume_in FF_volume_out
FF_bin_c_size FF_bin_c_density FF_bin_c_hierarchy FF_bin_c_index AT_bin_degree AT_bin_in_degree AT_bin_out_degree AT_bin_betweeness 
AT_bin_closeness AT_bin_eigenvector AT_bin_c_size AT_bin_c_density AT_bin_c_hierarchy AT_bin_c_index AT_volume_in AT_volume_out RT_volume_in RT_volume_out
  /PLOT NPPLOT  
  /STATISTICS DESCRIPTIVES.

* Transform the problematic ones *

COMPUTE EXP_FF_bin_degree=EXP(FF_bin_degree).
COMPUTE EXP_FF_bin_in_degree=EXP(FF_bin_in_degree).
COMPUTE EXP_FF_bin_out_degree=EXP(FF_bin_out_degree).
COMPUTE LN_FF_volume_in=LN(FF_volume_in+1).
COMPUTE LN_FF_volume_out=LN(FF_volume_out+1).
COMPUTE EXP_FF_bin_betweeness=EXP(FF_bin_betweeness).
COMPUTE EXP_FF_bin_closeness=EXP(FF_bin_closeness). 
COMPUTE LN_FF_bin_pagerank=LN(FF_bin_pagerank+1).
COMPUTE LN_FF_bin_c_size=LN(FF_bin_c_size+1).
COMPUTE LN_FF_bin_c_density=LN(FF_bin_c_density+1).
COMPUTE LN_FF_bin_c_hierarchy=LN(FF_bin_c_hierarchy+1).
COMPUTE LN_FF_bin_c_index=LN(FF_bin_c_index+1).
COMPUTE EXP_AT_bin_in_degree=EXP(AT_bin_in_degree).
COMPUTE LN_AT_bin_pagerank=LN(AT_bin_pagerank+1).
COMPUTE LN_AT_bin_c_size=LN(AT_bin_c_size+1).
COMPUTE LN_AT_bin_c_density=LN(AT_bin_c_density+1).
COMPUTE LN_AT_bin_c_hierarchy=LN(AT_bin_c_hierarchy+1).
COMPUTE LN_AT_bin_c_index=LN(AT_bin_c_index+1).
COMPUTE LN_AT_volume_in=LN(AT_volume_in+1).
COMPUTE LN_AT_volume_out=LN(AT_volume_out+1).
COMPUTE LN_RT_volume_in=LN(RT_volume_in+1).
COMPUTE LN_RT_volume_out=LN(RT_volume_out+1).


* Output examination of the transformed variables *

EXAMINE VARIABLES EXP_FF_bin_degree EXP_FF_bin_in_degree EXP_FF_bin_out_degree LN_FF_volume_in LN_FF_volume_out EXP_FF_bin_betweeness EXP_FF_bin_closeness LN_FF_bin_pagerank
LN_FF_bin_c_size LN_FF_bin_c_density LN_FF_bin_c_hierarchy LN_FF_bin_c_index
EXP_AT_bin_in_degree LN_AT_bin_pagerank LN_AT_bin_c_size LN_AT_bin_c_density LN_AT_bin_c_hierarchy LN_AT_bin_c_index
LN_AT_volume_in LN_AT_volume_out LN_RT_volume_in LN_RT_volume_out
  /PLOT NPPLOT  
  /STATISTICS DESCRIPTIVES.

*Test for multicolinearity * 
* Shift the IVs factors  around and note the results. VIF score should be smaller than 10, but not higher. We see that a number of variables are multicollinear especially with the volume ins for at and ff

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COLLIN TOL 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT   LN_FF_volume_in
  /METHOD=ENTER LN_FF_bin_c_index LN_AT_bin_c_index AT_bin_betweeness AT_bin_closeness LN_AT_bin_eigenvector LN_AT_volume_in EXP_FF_bin_betweeness EXP_FF_bin_closeness LN_FF_bin_eigenvector        
.
* ###########FACTOR#############

/* Possible IVs
/* FF_bin_in_degre AT_bin_in_degre
/* FF_bin_c_index  AT_bin_c_index 
/* FF_bin_betweeness AT_bin_betweeness
/* FF_bin_closeness AT_bin_closeness 
/* AT_bin_pagerank FF_bin_pagerank


/* Exploratory factor analysis checking the possible dimensions and nice to see correlations 

FACTOR 
  /VARIABLES  LN_FF_volume_in  LN_AT_volume_in LN_AT_volume_out LN_FF_volume_out FF_bin_closeness AT_bin_closeness AT_bin_pagerank FF_bin_pagerank FF_bin_betweeness AT_bin_betweeness  FF_bin_c_index  AT_bin_c_index 
  /MISSING LISTWISE 
  /ANALYSIS LN_FF_volume_in  LN_AT_volume_in LN_AT_volume_out LN_FF_volume_out FF_bin_closeness AT_bin_closeness AT_bin_pagerank FF_bin_pagerank FF_bin_betweeness AT_bin_betweeness FF_bin_c_index  AT_bin_c_index 
  /PRINT UNIVARIATE INITIAL CORRELATION SIG DET KMO INV REPR AIC EXTRACTION ROTATION 
  /FORMAT SORT BLANK(.4) 
  /PLOT EIGEN ROTATION 
  /CRITERIA  MINEIGEN(0.7)    ITERATE(25) /* MINEIGEN(1)  FACTORS(2) 
  /EXTRACTION PC 
  /CRITERIA ITERATE(25) 
  /ROTATION VARIMAX  /*   OBLIMIN VARIMAX
  /METHOD=CORRELATION.

/* IMPORTANT: Component analysis analyzing the resulting two factors AT and FF *

FACTOR 
  /VARIABLES  LN_FF_volume_in  LN_AT_volume_in LN_AT_volume_out LN_FF_volume_out FF_bin_closeness AT_bin_closeness 
  /MISSING LISTWISE 
  /ANALYSIS LN_FF_volume_in  LN_AT_volume_in LN_AT_volume_out LN_FF_volume_out FF_bin_closeness AT_bin_closeness 
  /PRINT UNIVARIATE INITIAL CORRELATION SIG DET KMO INV REPR AIC EXTRACTION ROTATION 
  /FORMAT SORT BLANK(.4) 
  /PLOT EIGEN ROTATION 
  /CRITERIA  MINEIGEN(0.7)    ITERATE(25) /* MINEIGEN(1)  FACTORS(2) 
  /EXTRACTION PC 
  /CRITERIA ITERATE(25) 
  /ROTATION VARIMAX  /*   OBLIMIN VARIMAX
  /METHOD=CORRELATION.

*###################### REGRESSIONS ##################################*

* Perform a exploratory regressions using BACKWARD method with DV: RT_volume_in*

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS R ANOVA 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT LN_RT_volume_in 
  /METHOD=BACKWARD EXP_FF_bin_degree EXP_FF_bin_in_degree EXP_FF_bin_out_degree LN_FF_volume_in LN_FF_volume_out EXP_FF_bin_betweeness EXP_FF_bin_closeness LN_FF_bin_eigenvector
LN_FF_bin_c_size LN_FF_bin_c_density LN_FF_bin_c_hierarchy LN_FF_bin_c_index
EXP_AT_bin_in_degree LN_AT_bin_eigenvector LN_AT_bin_c_size LN_AT_bin_c_density LN_AT_bin_c_hierarchy LN_AT_bin_c_index
LN_AT_volume_in LN_AT_volume_out  LN_RT_volume_out
 /SCATTERPLOT=(*ZRESID ,*ZPRED)
 /PARTIALPLOT ALL
  /RESIDUALS HISTOGRAM(ZRESID) NORMPROB(ZRESID).


*The influence of the indegrees on retweets*
* RESULT: It seems that taking into account volume in and out for ff and at is the best model (also according to factors)

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT LN_RT_volume_in 
  /METHOD=ENTER LN_FF_volume_in LN_AT_volume_in 
 /METHOD=ENTER LN_AT_volume_out LN_FF_volume_out
  /SCATTERPLOT=(*ZPRED ,*ZRESID) 
  /RESIDUALS DURBIN HISTOGRAM(ZRESID) NORMPROB(ZRESID)
  /PARTIALPLOT ALL.

/* Perform multi step regression of resulting network measures*/
/* If we include more measures like betweeness , closeness, pagerank or eigenvector due to multicollineary they cannot add much to the model see below
/* The only one significant is AT-bin-closeness for "MAYBE" collinearity reasons LN_AT_volume_out
/* Generally looking at the R matrix it becomes obvious that the closeness indexes are 0.8 correlated with the corresponding FF/AT volume out counterparts

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT LN_RT_volume_in 
  /METHOD=ENTER LN_FF_volume_in LN_AT_volume_in 
 /METHOD=ENTER LN_AT_volume_out LN_FF_volume_out
 /METHOD=ENTER LN_AT_volume_out LN_FF_volume_out
 /METHOD=ENTER FF_bin_c_index  AT_bin_c_index 
 /METHOD=ENTER FF_bin_betweeness AT_bin_betweeness
 /METHOD=ENTER FF_bin_closeness AT_bin_closeness 
 /METHOD=ENTER AT_bin_pagerank FF_bin_pagerank
  /SCATTERPLOT=(*ZPRED ,*ZRESID) 
  /RESIDUALS DURBIN HISTOGRAM(ZRESID) NORMPROB(ZRESID)
  /PARTIALPLOT ALL.