
                              mxLINDO 
                    A MATLAB Interface to LINDO API  
         
                       Copyright (c) 2020
  
         LINDO Systems, Inc.           312.988.7422
         1415 North Dayton St.         info@lindo.com
         Chicago, IL 60622             http://www.lindo.com                  


1.Setting Up 
=============
After installing LINDO API, follow the steps below to set up the interface 
between LINDO API and MATLAB. Please refer to Chapter 10 in LINDO API user 
manual for further information on mxLINDO.

 -----------------------------------------------------------------------
  IMPORTANT: mxLINDO is currently available on Windows platforms only.
 -----------------------------------------------------------------------

  - STEP 1. Edit the <MATLAB_ROOT>\TOOLBOX\LOCAL\STARTUP.M file that came 
  with your MATLAB distribution using a text editor, where <MATLAB_ROOT> 
  is the Matlab installation path. If you do not have the STARTUP.M file, 
  then create it from STARTUPSAV.M. 

  - STEP 2. Append the following lines to the end of your STARTUP.M file to 
  update your MATLAB environment path. It is assumed that your LINDO API 
  installation directory is 'C:\LINDOAPI'.

        global MY_LICENSE_FILE
        MY_LICENSE_FILE = 'C:\LINDOAPI\LICENSE\lndapiXX.lic';
        path(path,'C:\LINDOAPI\BIN\WIN32')
        %path(path,'C:\LINDOAPI\BIN\WIN64') %% for 64-bit installations
        path(path,'C:\LINDOAPI\INCLUDE')
        path(path,'C:\LINDOAPI\MATLAB'); 
        
  lndapiXX.lic should be replaced with the license file in LINDOAPI\LICENSE folder.


  - STEP 3. Start a MATLAB session and type 'mxLINDO' at command prompt. You 
  should see the following message on your screen. 

  >> mxlindo

    mxLINDO (R) Matlab Interface Version x.x.x
    for LINDO API (R) Version x.x.x
    Copyright (c) 20xx by LINDO Systems, Inc.
    All rights reserved.

    Usage: [z1,z2,..,zk] = mxLINDO('LSfuncName',a1,a2,...,an)


2.Trying Samples
=================
If you see the above message, then you have successfully set up the interface. 
Now, try the sample m-functions under LINDOAPI\MATLAB to explore the various 
ways to create and solve optimization problems within MATLAB.  

Try LMTESTQP.m, which  solves a simple quadratic program using the barrier 
solver. 
  >> lmtestqp       

Try LMTESTNLP1.m, which solves a simple nonlinear program using the multistart 
NLP solver. 
  >> lmtestnlp1       

Try LMTESTGOP1.m, which solves a simple nonlinear program using the global solver. 
  >> lmtestgop1       

Make sure that your MATLAB environment path contains the name of the directory 
where the sample m-functions are located (e.g. 'LINDOAPI\MATLAB' as in STEP 2 
above). 



3.Troubleshooting 
==================
  i) If you get the following error message when you type 'mxLINDO' at command 
  prompt, 

        >> mxLINDO
        ??? Invalid MEX-file

  it means that 'mxLINDO' cannot find a required component of LINDO API on your 
  system. There is either an error in your LINDO API installation or your 
  mxLINDO is incompatible with the LINDO API version installed on your system. 
  Reinstall LINDO API after uninstalling the existing one. 


  ii) If you get the following error message when trying the m-functions that 
  came with LINDO API

        >> lmsolvef('\lindoapi\samples\data\testlp.mps');
        Invalid license file: \lndapiXX.lic 

  then go back to 'Setting Up' and verify that you have modified your 
  'STARTUP.M' file as indicated in STEP 2.  This error indicates that LINDO 
  API license file cannot be found in MATLAB search path.  In a default 
  installation, the license file is under LINDOAPI\LICENSE directory on your 
  system.
