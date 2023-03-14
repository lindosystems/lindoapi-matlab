% Display Lindo API version
[Version,BuiltOn] = mxlindo('LSgetVersionInfo');
fprintf('\nLINDO API version %s (%s)\n',Version,BuiltOn);