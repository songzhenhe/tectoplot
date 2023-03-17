/* MDenoise.cpp: Feature-Preserving Mesh Denoising.
 * Copyright (C) 2007 Cardiff University, UK
 *
 * Version: 1.0
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 59 Temple Place - Su
 *
 * The copyright of triangle.h and triangle.c belong to Jonathan Richard Shewchuk
 * Further information about these two files see the files themselves.
 *
 * Author: Xianfang Sun
 *
 * usage: Mdenoise -i input_file [options]
 *      -e         Common Edge Type of Face Neighbourhood (Default: Common Vertex)
 *      -t float   Threshold (0,1), Default value: 0.4
 *      -n int     Number of Iterations for Normal updating, Default value: 20
 *      -v int     Number of Iterations for Vertex updating, Default value: 50
 *      -o char[]  Output file
 *      -a         Adds edges and vertices to generate high-quality triangle mesh.
 *                 Only function when the input is .xyz file.
 *      -z         Only z-direction position is updated.
 *
 * Supported input type: .gts, .obj, .off, .ply, .ply2, .smf, .stl, .wrl, .xyz, and .asc
 * Supported output type: .obj, .off, .ply, .ply2, .xyz, and .asc
 * Default file extension: .off
 *
 * Examples:
 * Mdenoise -i cylinderN02.ply2
 * Mdenoise -i cylinderN02.ply2 -n 5 -o cylinderDN
 * Mdenoise -i cylinderN02.ply2 -t 0.8 -e -v 20 -o cylinderDN.obj
 * Mdenoise -i FandiskNI02-05 -o FandiskDN.ply
 * Mdenoise -i -i Terrain.xyz -o TerrainP -z -n 1
 * Mdenoise -i my_dem_utm.asc -o my_dem_utmP -n 4
 *
 * Note: For the .asc file, the program always sets the switch -z on, whether you have
 * put it on the command line or not. If there is a .prj file with the same name as the
 * input .asc file, it is copied to a .prj file with the same name as the output .asc file.
 *
 * About the file formats:
 * All kinds of input files except for .xyz and .asc files have the standard format of
 * CAD or geometrical processing files. The .xyz and .asc files are primarily designed
 * for dealing with geological data, where the .asc files have the standard ESRI ASCII Grid
 * format, and the .xyz files have the following format:
 * The first few lines (optional) are comment lines starting with #, and the rest lines are
 * the main data. Each line represents one point, consisting of the x, y, z coordinates,
 * and (optional) other data. The program will only load and save x, y, z coordinates and
 * ignore all the other information.
 *
 * Reference:
 * @article{SRML071,
 *   author = "Xianfang Sun and Paul L. Rosin and Ralph R. Martin and Frank C. Langbein",
 *   title = "Fast and effective feature-preserving mesh denoising",
 *   journal = "IEEE Transactions on Visualization and Computer Graphics",
 *   volume = "13",
 *   number = "5",
 *   pages  = "925--938",
 *   year = "2007",
 * }
 *
 * to compile on unix platforms:
 *     g++ -o mdenoise mdenoise.cpp triangle.c
 * also lines 66 & 112 of mdenoise.cpp should be commented out on unix platforms
 */

#define VOID int

#include "mdenoise.h"
#include "triangle.h"
#include <time.h>
//#include <new.h> // This line should be commented out on unix

//functions deal with memory allocation errors.
void *MyMalloc(size_t size)
{
	void *memptr;

	memptr = (void *) malloc(size);
	if (memptr == (void *) NULL) {
		fprintf(stderr,"\nError malloc:  Out of memory.\n");
		fprintf(stderr,"The model data is too big.\n");
		exit(1);
	}
	return(memptr);
}

void *MyRealloc(void *memblock, size_t size)
{
	void *oldbuffer;
	oldbuffer = memblock;
	if((memblock = realloc(memblock, size))==NULL)
	{
		free(oldbuffer);
		fprintf(stderr,"\nError realloc:  Out of memory.\n");
		fprintf(stderr,"The model data is too big.\n");
		exit(1);
	}
	return(memblock);
}

// Define a function to be called if new fails to allocate memory.
int MyNewHandler( size_t size ) // This function can be comment out on unix
{
	fprintf(stderr,"\nError new:  Out of memory.\n");
	fprintf(stderr,"The model data is too big.\n");
	exit(1);
}

// Define the global arrays that will hold the data
float *m_datain;
float *m_dataout;

int main(int argc, char* argv[])
{
    clock_t start, finish;
    double  duration;
    int filename_i=0;
    int filename_o=0;
	struct ESRIHeader eheader;

    /* parse command line */

    for (int i = 1; i < argc; i++) {
        if (argv[i][0] == '-') {
            switch(argv[i][1]) {
                case 'i':
                case 'I':
                    i++;
                    filename_i = i;
                    break;
                case 'o':
                case 'O':
                    i++;
                    filename_o = i;
                    break;
                default:
                    printf("unknown option %s\n",argv[i]);
                    options(argv[0]);
            }
        }
        else {
            printf("unknown option %s\n",argv[i]);
            options(argv[0]);
        }
    }


    ///////////////////////////////////////////////////////////////////////////////////
    if (filename_i == 0) {
        printf("Error: input filename required\n");
        options(argv[0]);
    }
	/////////////////////////////////////////////////////////////////////

    //Read file
    int fileext_i;
    int fileext_o;
    char filename[201];
    char pathname[206];
    int filelen = strlen(argv[filename_i]);
    strcpy(pathname,argv[filename_i]);

    pathname[filelen]='\0';

    strncpy(filename,pathname,filelen-4);
    filename[filelen-4]='\0';


    printf("Input File: %s\n",pathname);
    FILE *fp = fopen(pathname, "rb");
    if (!fp) {
        printf("Can't open file to load!\n");
        return 0;
    }
    else
    {
        start = clock();
        printf("Read Model...");
        m_nNumFace = ReadData(fp, fileext_i,&eheader);
        finish = clock();
        duration = (double)(finish - start) / CLOCKS_PER_SEC;
        printf( "%10.3f seconds\n", duration );
    }
    fclose(fp);

    // //Denoising Model...
    // start = clock();
    // printf("Denoising Model...");
    // MeshDenoise(m_bNeighbourCV, m_fSigma, m_nIterations, m_nVIterations);
    // finish = clock();
    // duration = (double)(finish - start) / CLOCKS_PER_SEC;
    // printf( "%10.3f seconds\n", duration );

    for(int i=0; i<eheader.nrows; i++)
    {
        for(int j=0;j<eheader.ncols;j++)
        {
            if (i>1 && j>1) {
                m_dataout[j+i*eheader.ncols]=2*m_datain[j+i*eheader.ncols];
            } else {
                m_dataout[j+i*eheader.ncols]=m_datain[j+i*eheader.ncols];
            }
        }
    }

    //Saving Model...
    start = clock();
    printf("Saving Model...");

    char szFileName[206];
    strcpy(pathname,filename);
    sprintf(szFileName,"_out.asc");
    strcat(pathname,szFileName);

    fp = fopen(pathname, "w");
    if (!fp) {
        printf("Can't open file to write!\n");
        return 0;
    }

    SaveData(fp,fileext_o,&eheader);
    fclose(fp);

    finish = clock();
    duration = (double)(finish - start) / CLOCKS_PER_SEC;
    printf( "%10.3f seconds\n", duration );
    return 0;
}

int ReadData(FILE * fp, int nfileext, struct ESRIHeader* header)
{

    ReadESRI(fp,header);
    
    m_dataout = (float *)MyMalloc(m_nNumVertex*sizeof(float));

    return  m_nNumVertex;
}


// This function reads in an ESRI .asc file that is a header followed by an m*n array of data 
// The header contains a list of NoData cells given by linear index, so we need to keep
// track of which cells are NoData when we read the file in. 

void ReadESRI(FILE* fp, struct ESRIHeader* header)
{
    int i,ii,j,k,kk[4],nTmp,nTotal;
    float fTmp0,fTmp1,fTmp2;
	char sTmp[40];
	double * value, fTmp;

	fscanf(fp,"%s %d", sTmp, &(header->ncols));
	fscanf(fp,"%s %d", sTmp, &(header->nrows));
	fscanf(fp,"%s %lf", sTmp, &(header->xllcorner));
	fscanf(fp,"%s %lf", sTmp, &(header->yllcorner));
	fscanf(fp,"%s %lf", sTmp, &(header->cellsize));
	fscanf(fp,"%s %lf", sTmp, &fTmp);

	nTotal = header->ncols*header->nrows;
	value = (double *)MyMalloc(nTotal*sizeof(double));
	header->index = (int *)MyMalloc(nTotal*sizeof(int));

	if((sTmp[0]=='n')||(sTmp[0]=='N'))
	{
		header->isnodata = true;
		header->nodata_value = fTmp;
		for(i=0;i<nTotal;i++)
		{
			fscanf(fp,"%lf", value+i);
		}
	}
	else
	{
		header->isnodata = false;
		value[1] = fTmp;
		sscanf(sTmp,"%lf",value);
		for(i=2;i<nTotal;i++)
		{
			fscanf(fp,"%lf", value+i);
		}
	}

	m_datain = (float *)MyMalloc(nTotal*sizeof(float));
	if(header->isnodata)
	{
		m_nNumVertex = 0;
		for(i=0; i<header->nrows; i++)
		{
			for(j=0;j<header->ncols;j++)
			{
				k = j+i*header->ncols;
				if(abs(value[k]-header->nodata_value)<FLT_EPSILON)
				{
					header->index[k] =nTotal;
				}
				else
				{
					m_datain[m_nNumVertex]=float(value[k]);
					header->index[k] =m_nNumVertex;
					m_nNumVertex++;
				}
			}
		}
		m_datain = (float *)MyRealloc(m_datain, m_nNumVertex*sizeof(float));
	}
	else
	{
		m_nNumVertex = nTotal;
		for(i=0; i<header->nrows; i++)
		{
			for(j=0;j<header->ncols;j++)
			{
				k = j+i*header->ncols;
				m_datain[k]=float(value[k]);
				header->index[k]=k;
			}
		}
	}
    free(value);
}

void SaveData(FILE * fp, int nfileext, struct ESRIHeader* header)
{
    SaveESRI(fp, header);
}

void SaveESRI(FILE * fp, ESRIHeader* header)
{
    int i,j,k,nTotal;
    fprintf(fp,"ncols          %d\n",header->ncols);
    fprintf(fp,"nrows          %d\n",header->nrows);
    fprintf(fp,"xllcorner      %lf\n",header->xllcorner);
    fprintf(fp,"yllcorner      %lf\n",header->yllcorner);
    fprintf(fp,"cellsize       %lf\n",header->cellsize);

	nTotal = header->nrows*header->ncols;
	if(header->isnodata){
		fprintf(fp,"NODATA_value   %lf\n",header->nodata_value);
		for(i=0;i<header->nrows;i++)
		{
			for(j=0;j<header->ncols;j++){
				k = j+i*header->ncols;
				k = header->index[k];
				if(k==nTotal){
					fprintf(fp,"%lf ", header->nodata_value);
				}else{
					fprintf(fp,"%lf ", m_dataout[k]);
				}
			}
			fprintf(fp,"\n");
		}
	}
	else{
		for(i=0;i<header->nrows;i++)
		{
			for(j=0;j<header->ncols;j++){
				k = j+i*header->ncols;
				fprintf(fp,"%lf ", m_dataout[k]);
			}
			fprintf(fp,"\n");
		}
	}
}

void options(char *progname)
{
   printf("usage: %s -i input_file [options]\n",progname);
   exit(-1);
}


