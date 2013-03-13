function [reply] = askyesno(Q)
% function [reply] = askyesno(Q)
%
% The function shows the passed question text and waits for input from the
% user. Until n, no, y, or yes is typed in, the question is asked over again.
% Finally, the result (reply) is set to true, if the answer was yes, and to
% false if the answer was no.
%
% ex.call: reply = askyesno('Want more cookies? [Y/N] ');

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
