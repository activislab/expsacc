
function PEST_analysis(UD,resp,sub)


%% calculate d' prime
hits1 = resp(:,1);
fa1 = resp(:,2);
cr1 = resp(:,3);
miss1 = resp(:,4);

hits11 = sum(hits1) / (sum(hits1) + sum(miss1));

fa11 = sum(fa1) / (sum(fa1) + sum(cr1));

pHF = [hits11 fa11];
[dP, C, lnB, pC]=PAL_SDT_1AFC_PHFtoDP(pHF);

pH=pHF(:,1);
pF=pHF(:,2);

SDM=[pH';pF';dP';pC';C';lnB'];
SDM=SDM';

format short 

fprintf('\n');
disp('     pHit      pFA      d-prime   p Corr    crit C    crit lnB');
disp(SDM);



if pF <= .25
    disp('Aceitar limiar. Baixo FA');
    color = [0.7 0.9 0.7];
else
    disp('Rejeitar limiar. Alto FA');
    color = [0.9 0.7 0.7];
end

%%

figure(1)

set(gca,'TickDir','out');
ylim([0 1]);hold on;
set(gca,'YTickLabel',0:0.2:1);
set(gca,'color', [.9 .9 .9]);
hold on;

t = 1:length(UD.x);
plot(t,UD.x,'k');
hold on;
plot(t(UD.response == 1),UD.x(UD.response == 1),'ko', 'MarkerFaceColor','k');
plot(t(UD.response == 0),UD.x(UD.response == 0),'ko', 'MarkerFaceColor','w');

yline(0.5,'--');
xlabel('Trial',FontWeight='bold');
ylabel('Gabor Contrast','FontWeight','bold');

format short

Mean = PAL_AMUD_analyzeUD(UD,'reversals',5);

txt = sprintf('Mean: %d',Mean);
text(5, 0.7,txt);

ylim([0 1]);hold on;
set(gca,'YTickLabel',0:0.1:1);
hold on;

axes('Position',[.75 .7 .14 .2])
set(gca,'TickDir','out','XTick',[]);
ylabel('FA rate','FontWeight','bold');
ylim([0 1]);
yline(0.25,'--');
set(gca,'color', color);
hold on;
bar(1,SDM(2),'k');



end
