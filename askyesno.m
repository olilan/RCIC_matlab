function [reply] = askyesno(Q)
% function [reply] = askyesno(Q)
%
% The function shows the passed question text and waits for input from the
% user. Until n, no, y, or yes is typed in, the question is asked over again.
% Finally, the result (reply) is set to true, if the answer was yes, and to
% false if the answer was no.
%
% ex.call: reply = askyesno('Want more cookies? [Y/N] ');
%
% ----------------------------------------------------------------------------
% Copyright (C) 2013, Oliver Langner and Ron Dotsch
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the Eclipse Public License as published by
% the Eclipse Foundation, version 1.0.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% Eclipse Public License for more details.
%
% You should have received a copy of the Eclipse Public License
% along with this program.  If not, see
% http://www.eclipse.org/legal/epl-v10.html
% ----------------------------------------------------------------------------

%init reply variable
reply = '';

while true
    %ask user whether to proceed
    reply = upper(input(Q, 's'));
    
    %check for valid input
    switch reply
        case {'N','NO'}
            reply = false;
            return
        case {'Y', 'YES'}
            reply = true;
            return
    end
end
