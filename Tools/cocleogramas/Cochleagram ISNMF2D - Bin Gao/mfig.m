function varargout = mfig(varargin)
% MFIG Create named figure window
%
% MFIG(FIGNAME) Creates a named figure called FIGNAME. If FIGNAME
% already exists, it just becomes the current figure.
if nargin==0
    h = figure;
else
    name = varargin{1};
    h = findobj('Name', name, 'Type', 'Figure');
    if isempty(h)
        h = figure;
        set(h, 'Name', name);
        set(h, 'NumberTitle', 'off');
    else
        h = h(1);
        set(0, 'CurrentFigure', h);
    end
end

if nargout>=1
    varargout{1} = h;
end