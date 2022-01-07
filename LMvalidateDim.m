function [nErr] = LMvalidateDim(c,A,b,csense,lb,ub)
% LMvalidateDim: Validate input dimensions
%
% Copyright (c) 2001-2021
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com    
%
% [nErr] = LMvalidateDim(LSprob)

if nargin<1,
    help LMvalidateDim;
    return
end
if nargin<6,
    ub = [];
    if nargin<5,
        lb = [];
        if nargin<4,
            csense=[];
            if nargin<3,
                b=[];
                if nargin<2,
                    fprintf('LMvalidateDim requires at least two arguments\n');
                    return;
                end
            end
        end
    end
end
[m,n] = size(A);
nErr = 0;
if ~(min(size(c))<=1 && min(size(b))<=1 && min(size(lb))<=1 && min(size(ub))<=1),
    warning('Input c, b, lb, ub, are required to vectors with size (N x 1) or (1 x N)');
    return;
end

if n ~= max(size(c)),
    warning('c and A dimensions mismatch');
    nErr=-1;
    return;
end

if ~isempty(b) && m ~= max(size(b)),
    warning('b and A dimensions mismatch');
    nErr=-1;
    return;
end

if ~isempty(csense) && m ~= length(csense),
    warning('csense and A dimensions mismatch');
    nErr=-1;
    return;
end

if ~isempty(lb) && max(size(lb)) ~= max(size(c)),
    warning('c and lb dimensions mismatch');
    nErr=-1;
    return;
end

if ~isempty(ub) && max(size(ub)) ~= max(size(c)),
    warning('c and ub dimensions mismatch');
    nErr=-1;
    return;
end
