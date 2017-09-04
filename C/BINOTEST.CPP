//#include "stdafx.h"
#include<stdio.h>
#include<stdlib.h>
#include<conio.h>
#include<math.h>
#include<vector>
#include<assert.h>

extern "C"
{
#include "binocdf.h"
}




//int computer_choice_reward(int *rarr, int *rewarr, int narr, int norder)
int computer_choice_reward(int *rarr  , int narr_response,				\
						   int *rewarr, int narr_reward,				\
						   int norder,									\
						   std::vector<double>  & prob_details,			\
						   std::vector<double>  & diff_details,			\
						   std::vector<double>  & reward_prob_details,	\
						   std::vector<double>  & rew_diff_details,		\
						   int & order_picked,
						   int &algorithm_type
					)
{
#ifdef TESTING
	FILE * afile;
#endif
	int i,j,h,k;
	int same_pattern, nminprb, nminprbk, rprb, cchoice;
	int ntot[2][20], npat[2][20];
	int maxorder;
	double parr[2][20], dparr[2][20], minprb, minpval;
	int narr=-1;

	//if(narr<10) return rand()%2;

	//<djb 30sept2002>
	if (narr_response== narr_reward) 
	{	
		narr= narr_reward;
		
	}
    else
	{
		assert(narr_response!= narr_reward);
	}
	//</djb 30sept2002>

	// **** This is a minor change (9/12/2002) ***
	// and it is the source of an nasty bug !!!

	maxorder=norder;	//<djb 30sept2002>
	if(narr<norder) maxorder=narr;


#ifdef TESTING
	afile=fopen("c:/trash/testing.txt","a");
	fprintf(afile,"\ntrial %d\n",narr);
	fclose(afile);
#endif
	minprb=1.0;
	minpval=1.0;
	nminprb=-1;		// order selected;
	nminprbk=-1;	// which algorithm (reward(0) or not(1))

	//<djb 30sept2002>
	order_picked =-1; // -1 indicates that the computer could not reject hypothesis and did not pick an order
	algorithm_type=-1;// -1 as for order picked 
					  // 0= reward + response !!!!!!!   1 = response history only
	//</djb 30sept2002>
	
	for(k=0;k<2;k++) {	// ** checks with(k=0) and without(K=1) reward
		for(i=0;i<maxorder;i++) {
			ntot[k][i]=0;
			npat[k][i]=0;
			for(j=0;j<narr-i;j++) {
				same_pattern=1;
				for(h=0;h<i;h++) {
					// *** The following includes the key changes (9/12/2002) ***
					if(k==0) {
						if(rarr[j+h]!=rarr[narr-i+h]||rewarr[j+h]!=rewarr[narr-i+h]) same_pattern=0;													
					}
					else {
						if(rarr[j+h]!=rarr[narr-i+h]) same_pattern=0;							
					}
					if(!same_pattern) break;
				}
				if(!same_pattern) continue;
				ntot[k][i]++;
				if(rarr[j+i]>0) npat[k][i]++;
			}			
			if(ntot[k][i]==0) {
				parr[k][i]=0.5;
#ifdef TESTING
				afile=fopen("c:/trash/testing.txt","a");
				fprintf(afile,"Order=%d: No patterns found.\n", i);
				fclose(afile);
#endif
			}
			else
			{


				//<djb 30sept2002>
				double value=fabs((npat[k][i]/((float)ntot[k][i])) -0.5); // nasty - the npat[i]/ntot[i] =0 always
				
				if (k==1)//no reward
				{
					
					diff_details[i]=value;
				}
				else
				{
					
					rew_diff_details[i]=value;
				}

				//</djb 30sept2002>

	            if (npat[k][i]> (ntot[k][i])/2)
				{                
	                parr[k][i]=binocdf((ntot[k][i]-npat[k][i]), ntot[k][i], 0.5);
#ifdef TESTING
					afile=fopen("c:/trash/testing.txt","a");
					fprintf(afile,"Order=%d: Tot=%d, Pat=%d, B(%d,%d)=%f\n", i, ntot[k][i], npat[k][i], ntot[k][i]-npat[k][i], ntot[k][i], parr[k][i]);
					fclose(afile);
#endif
					dparr[k][i]=1.0-(double)npat[k][i]/(double)ntot[k][i];
				}
				else
				{
	                parr[k][i]=binocdf(npat[k][i], ntot[k][i], 0.5);
#ifdef TESTING
					afile=fopen("c:/trash/testing.txt","a");
					fprintf(afile,"Order=%d: Tot=%d, Pat=%d, B(%d,%d)=%f\n", i, ntot[k][i], npat[k][i], npat[k][i], ntot[k][i], parr[k][i]);
					fclose(afile);
#endif
					dparr[k][i]=(double)npat[k][i]/(double)ntot[k][i];
				}
			}      
	
			if(parr[k][i]>0.5) parr[k][i]=1.0-parr[k][i];// tail probability					
	
			//<djb 30sept2002>
			if (k==1) //no reward
			{
				prob_details[i]=parr[k][i];
			}
			else      //reward
			{
				reward_prob_details[i]=parr[k][i];
			}
			//</djb 30sept2002>



			if(minprb>dparr[k][i]&&parr[k][i]<0.025) {
				minprb=dparr[k][i];
				minpval=parr[k][i];
				nminprb=i;	// order
				nminprbk=k;	// algorithm
			}

		}	// i (order)
	}	// k (reward)
		
	if(minprb==1.0) return rand()%2;	// cannot reject any null hypothesis!
#ifdef TESTING
    afile=fopen("c:/trash/testing.txt","a");
	fprintf(afile,"**Min prob = %f (p=%f), RW=%d, Order=%d\n", minprb, minpval, nminprbk, nminprb);
	fclose(afile);
#endif
	//<djb 30sept2002>
	order_picked  = nminprb;
	algorithm_type= nminprbk;
	//<djb 30sept2002>



	rprb=rand()%ntot[nminprbk][nminprb];
	if(npat[nminprbk][nminprb]>ntot[nminprb][nminprb]/2) {
		if(rprb<npat[nminprbk][nminprb]) cchoice=1;
		else cchoice=0;
	}
	else {	
		if(rprb<=npat[nminprbk][nminprb]) cchoice=1;
		else cchoice=0;
	}
#ifdef TESTING
	afile=fopen("c:/trash/testing.txt","a");
	fprintf(afile,"choice =%d\n",cchoice);
	fclose(afile);
#endif
/*
the following was added on 2mar2004 as i think that the above code is meant to give the target that won't be rewarded
ie the one the animal is expected to pick
*/
	int djbrv= -1;

    if (cchoice==0)
	{
		djbrv=1;
	}
    else if ( cchoice==1)
	{
		djbrv=0;
	}
    else assert(0);


	//return cchoice;
	return djbrv;
	
}
#ifdef	dontcompile
here
{
	int i,j,h,k;
	int same_pattern, nminprb, rprb, cchoice;
	int ntot[20], npat[20];
	int maxorder;
	double parr[20];
	double dcparr[20];		//<djb 30sept2002>
	double rewdcparr[20];	//<djb 30sept2002>
	double minprb;
	int narr=0;

	//if(narr<10) return rand()%2;


	//<djb 30sept2002>
	if (narr_response== narr_reward) 
	{	
		narr= narr_reward;
		
	}
    else
	{
		assert(narr_response!= narr_reward);
	}
	//</djb 30sept2002>




	// **** This is a minor change (9/12/2002) ***
	if(narr<norder) maxorder=narr;

	minprb=1.0;
	
	//<djb 30sept2002>
	order_picked =-1; // -1 indicates that the computer could not reject hypothesis and did not pick an order
	//</djb 30sept2002>


	for(k=0;k<2;k++) 
	{	// ** checks with(k=0) and without(K=1) reward
		for(i=0;i<maxorder;i++) {
			ntot[i]=0;
			npat[i]=0;
			for(j=0;j<narr-i;j++) {
				same_pattern=1;
				for(h=0;h<i;h++) {
					// *** The following includes the key changes (9/12/2002) ***
					if(k==0) {
						if(rarr[j+h]!=rarr[narr-i+h]||rewarr[j+h]!=rewarr[narr-i+h]) same_pattern=0;													
					}
					else {
						if(rarr[j+h]!=rarr[narr-i+h]) same_pattern=0;							
					}
					if(!same_pattern) break;
				}
				if(!same_pattern) continue;
				ntot[i]++;
				if(rarr[j+i]>0) npat[i]++;
			}			
			if(ntot[i]==0) {
				parr[i]=0.5;
				//printf("Order=%d: No patterns found.\n", i);
			}
			else
			{
				//<djb 30sept2002>
				value=fabs((npat[i]/((float)ntot[i])) -0.5); // nasty - the npat[i]/ntot[i] =0 always
				if (k==1)//no reward
				{
					dcparr[i]=value
					diff_details[i]=dcparr[i]; 
				}
				else
				{
					rewdcparr[i]=fabs((npat[i]/((float)ntot[i])) -0.5); // nasty - the npat[i]/ntot[i] =0 always 
					rew_diff_details[i]=rewdcparr[i]; 
				}

				//</djb 30sept2002>


	            if (npat[i]> (ntot[i])/2)
				{                
	                parr[i]=binocdf((ntot[i]-npat[i]), ntot[i], 0.5);
					//printf("Order=%d: Tot=%d, Pat=%d, B(%d,%d)=%f\n", i, ntot[i], npat[i], ntot[i]-npat[i], ntot[i], parr[i]);
				}
				else
				{
	                parr[i]=binocdf(npat[i], ntot[i], 0.5);
					//printf("Order=%d: Tot=%d, Pat=%d, B(%d,%d)=%f\n", i, ntot[i], npat[i], npat[i], ntot[i], parr[i]);
				}
			}      
	
			if(parr[i]>0.5) parr[i]=1.0-parr[i];// tail probability					
	

			//<djb 30sept2002>
			if (k==1) //no reward
			{
				prob_details[i]=parr[i];
			}
			else      //reward
			{
				reward_prob_details[i]=parr[i];
			}
			//</djb 30sept2002>

			if(minprb>parr[i]) {
				minprb=parr[i];
				nminprb=i;
			}

		}	// i (order)
	}	// k (reward)
		
	if(minprb>=0.025) return rand()%2;	// cannot reject any null hypothesis!


	//printf("Min prob = %f (order =%d)\n", minprb, nminprb);
	
	//<djb 30sept2002>
	order_picked = nminprb;//nmaxdcp; djb should this be nmaxdcp
	//<djb 30sept2002>

	rprb=rand()%ntot[nminprb];
	if(rprb<npat[nminprb]) 
	{
		cchoice=1;
	}
	else 
	{
		cchoice=0;
	}

	return cchoice;
	
}
#endif

int computer_choice(int *rarr, int narr, int norder, std::vector<double>  & prob_details, \
					std::vector<double>  & diff_details, int & order_picked )
{
	int i,j,h;
	int same_pattern, nminprb, rprb, cchoice, nmaxdcp;
	int ntot[20], npat[20];
	double parr[20], dcparr[20], minprb;
    double maxdcp;


	minprb=1.0;
	order_picked=-1; // -1 will indicate that computer could not reject any null hypothesis and there for did not pick an order
					
	for(i=0;i<norder;i++) 
	{
		ntot[i]=0;
		npat[i]=0;
		prob_details.push_back(-1.0);
		diff_details.push_back(0);
		for(j=0;j<narr-i;j++) 
		{
			same_pattern=1;
			for(h=0;h<i;h++) 
			{
				if(rarr[j+h]!=rarr[narr-i+h]) 
				{
					same_pattern=0;
					break;
				}
			}
			if(!same_pattern) continue;
			ntot[i]++;
			if(rarr[j+i]>0) npat[i]++;
		}			
		if(ntot[i]==0) parr[i]=0.5;
		else
        {
			dcparr[i]=fabs((npat[i]/((float)ntot[i])) -0.5); // nasty - the npat[i]/ntot[i] =0 always 
			diff_details[i]=dcparr[i]; 

            if (npat[i]> (ntot[i])/2)
            {
                
                parr[i]=binocdf((ntot[i]-npat[i]), ntot[i], 0.5);
            }
            else
            {
                parr[i]=binocdf(npat[i], ntot[i], 0.5);
            }
        }
        

        if(parr[i]>0.5) parr[i]=1.0-parr[i];// tail probability					
		//printf("i=%d ntot[i]=%d npat[i]=%d: p = %f\n", i, ntot[i], npat[i], parr[i]);
		prob_details[i]=parr[i];
		if(minprb>parr[i]) 
		{
			minprb=parr[i];
			nminprb=i;
		}
	}
	
	if(minprb>=0.025)
	{
		return rand()%2;	// cannot reject any null hypothesis!
	}


    //// new way (after 4/5/2002) 
    maxdcp=0.0;
	nmaxdcp =-1; // intialization added by djb on 2mar2004
    for(i=0;i<norder;i++) 
	{
        if(maxdcp<dcparr[i]&&parr[i]<0.025) 
		{
            maxdcp=dcparr[i];
            nmaxdcp=i;
        }
    }
	order_picked = nmaxdcp;
    rprb=rand()%ntot[nmaxdcp];
    if(rprb<npat[nmaxdcp])
	{
		cchoice=1;
	}
    else 
	{
		cchoice=0;
	}

	/*  *** old way (before 4/5/2002) ***
	rprb=rand()%ntot[nminprb];
	if(rprb<npat[nminprb]) cchoice=1;
	else cchoice=0;
	*/

	//return cchoice;
	// the following was added 2mar2004 so that the selection process picks the target to reward 
	// not the expected target
	int djbrv= -1;

    if (cchoice==0)
	{
		djbrv=1;
	}
    else if ( cchoice==1)
	{
		djbrv=0;
	}
    else assert(0);


	//return cchoice;
	return djbrv;
	
}


