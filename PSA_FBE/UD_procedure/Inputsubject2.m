function [sub,info] = Inputsubject2(sub,info)

start_value = string(info.UD_start_value); step_size = string(info.UD_step_size_down);
if sub.ses_num == 1
    prompt = {...
        'Numero voluntario',...
        'Numero sessao',...
        'Olho dominante (E/D)',...
        'Limiar inicial',...
        'Step size',...
        'TREINO?'};

    defanswer = {sub.id, sub.ses, '', start_value, step_size,''};
    answer = inputdlg(prompt, '', [1 22], defanswer);

    sub.id = answer{1};
    sub.id_num = str2double(answer{1});

    sub.ses = answer{2};
    sub.ses_num = str2double(answer{2});


    sub.eye = answer{3};
    if sub.eye == 'E'; sub.eye_num = 1;
    elseif sub.eye == 'D'; sub.eye_num = 2;
    else; error('Olho dominante inválido.');
    end

    sub.treino = answer{6};

else

    prompt = {...
        'Numero voluntario',...
        'Numero sessao',...
        'Olho dominante (E/D)',...
        'Limiar inicial',...
        'Step size',...
        'TREINO?'};

    defanswer = {sub.id, sub.ses, '', '', '',''};
    answer = inputdlg(prompt, '', [1 22], defanswer);

    sub.id = answer{1};
    sub.id_num = str2double(answer{1});

    sub.ses = answer{2};
    sub.ses_num = str2double(answer{2});


    sub.eye = answer{3};
    if sub.eye == 'E'; sub.eye_num = 1;
    elseif sub.eye == 'D'; sub.eye_num = 2;
    else; error('Olho dominante inválido.');
    end

     info.UD_start_value = str2double(answer{4});
     info.UD_step_size_down = str2double(answer{5});

     sub.treino = answer{6};

end


end