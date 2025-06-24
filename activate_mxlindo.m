% Activate mxlindo 
LINDOAPI_HOME=getenv('LINDOAPI_HOME');
global MY_LICENSE_FILE
MY_LICENSE_FILE = [ LINDOAPI_HOME '/license/lndapi160.lic'];
path(path,[ LINDOAPI_HOME '/bin/linux64'])
%path(path,[ LINDOAPI_HOME '/bin/win64'])
path(path,[ LINDOAPI_HOME '/include'])
path(path,[ LINDOAPI_HOME '/matlab']); 