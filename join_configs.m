function [cfg] = join_configs(default, cfg)
% function [cfg] = join_configs(default, cfg)
%
% The function compares the two structures default and cfg, and adds all
% fields from default that are missing in cfg to cfg.
%
% ex.call: cfg = join_configs(default, cfg);

%get list of defaults not in cfg
missing = setdiff(fieldnames(default), fieldnames(cfg));

for m = 1 : length(missing)
    %add missing field to cfg
    cfg.(missing{m}) = default.(missing{m});
end