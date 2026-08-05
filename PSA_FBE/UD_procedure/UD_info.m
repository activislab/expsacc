
function [info] = UD_info(info,sub)
% 1Up/1Down PARAMETERS
info.UD_step_size_down = .05;    
info.UD_step_size_up = info.UD_step_size_down;
info.UD_stop_criterion = 'trials';   
info.UD_stop_rule = 48;
info.UD_start_value = 1; % .3    
info.UD_xmax = 1;
info.UD_xmin = 0;

end


