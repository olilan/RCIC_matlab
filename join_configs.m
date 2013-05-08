function [cfg] = join_configs(default, cfg)
% function [cfg] = join_configs(default, cfg)
%
% The function compares the two structures default and cfg, and adds all
% fields from default that are missing in cfg to cfg.
%
% ex.call: cfg = join_configs(default, cfg);
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

%get list of defaults not in cfg
missing = setdiff(fieldnames(default), fieldnames(cfg));

for m = 1 : length(missing)
    %add missing field to cfg
    cfg.(missing{m}) = default.(missing{m});
end