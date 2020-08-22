clear
%% initial population
numPop=100;
numMarriage=50;
numKids=numPop/numMarriage;
maxH=360;
maxS=1000;
maxV=800;
hairColPDF=makedist('Weibull',1,0.5);
hairCol_HSV(:,1,1)=((45-29)*rand(numPop,1)+29)/maxH;
rng('default')
randomizer1=random(hairColPDF,numPop,1);
randomizer1=randomizer1/max(randomizer1);
hairCol_HSV(:,1,2)=((0.4*maxS*randomizer1)+(0.5*maxS))/maxS;
randomizer2=random(hairColPDF,numPop,1);
randomizer2=randomizer1/max(randomizer2);
hairCol_HSV(:,1,3)=((maxV-200)*randomizer1)/maxV;
hairCol_RGB=hsv2rgb(hairCol_HSV);
%% selection and evolution
numGen=50;
hairCol_kids_HSV=zeros(numPop,numGen,3);
hairCol_kids_RGB=zeros(numPop,numGen,3);
hairCol_kids_HSV(:,1,:)=hairCol_HSV;
hairCol_kids_RGB(:,1,:)=hairCol_RGB;
hairCol_SV_sum=hairCol_HSV(:,1,2)+hairCol_HSV(:,1,3);
hairCol_HSV_sort=sortrows([hairCol_HSV(:,1,1),hairCol_HSV(:,1,2),hairCol_HSV(:,1,3),hairCol_SV_sum],[4 2 3],{'descend' 'descend' 'descend'});
for gen=2:numGen
    pop=1;
    for marriage=1:numMarriage
        pairs=randperm(200,200);
        idx_parent1=2*marriage-1;
        idx_parent2=2*marriage;
        parent1=hairCol_HSV_sort(idx_parent1,:);
        parent1(2)=maxS*parent1(2);
        parent1(3)=maxV*parent1(3);
        parent2=hairCol_HSV_sort(idx_parent2,:);
        parent2(2)=maxS*parent2(2);
        parent2(3)=maxV*parent2(3);
        S_bin_length=10;
        V_bin_length=10;
        parent1_SVbin=cellstr(dec2bin(parent1(:,2:3),10));
        parent2_SVbin=cellstr(dec2bin(parent2(:,2:3),10));
        for child=1:numKids
            parent1_SVcat=strcat(parent1_SVbin{1},parent1_SVbin{2});
            parent2_SVcat=strcat(parent2_SVbin{1},parent2_SVbin{2});
            random_num=randperm(S_bin_length+V_bin_length,6);
            random_num=sort(random_num);
            random_idx=sort(randperm(4,2));
            kids_hairCol_bin=parent1_SVcat;
            kids_hairCol_bin(random_num(random_idx(1)):random_num(random_idx(2)))=parent2_SVcat(random_num(random_idx(1)):random_num(random_idx(2)));
            idx_mutate=randperm(S_bin_length+V_bin_length,3);
            if ~mod(randi(1000),8)==1
                for idx=1:3
                    if kids_hairCol_bin(idx_mutate(idx))=='1'
                        kids_hairCol_bin(idx_mutate(idx))='0';
                    else
                        kids_hairCol_bin(idx_mutate(idx))='1';
                    end
                end
            end
            hairCol_kids_HSV(pop,gen,1)=mean([parent1(1),parent2(1)]);
            hairCol_kids_HSV(pop,gen,2)=(bin2dec(kids_hairCol_bin(1:S_bin_length)))/(maxS);
            hairCol_kids_HSV(pop,gen,3)=(bin2dec(kids_hairCol_bin(S_bin_length+1:end)))/(maxV);
            hairCol_kids_RGB(pop,gen,:)=hsv2rgb(hairCol_kids_HSV(pop,gen,:));
            pop=pop+1;
        end
    end
    hairCol_SV_sum=hairCol_kids_HSV(:,gen,2)+hairCol_kids_HSV(:,gen,3);
    hairCol_HSV_sort=sortrows([hairCol_kids_HSV(:,gen,1),hairCol_kids_HSV(:,gen,2),hairCol_kids_HSV(:,gen,3),hairCol_SV_sum],[4 2 3],{'descend' 'descend' 'descend'});
end
%% plotting
hairCol_kids_RGB = permute(hairCol_kids_RGB,[2 1 3]);
image(hairCol_kids_RGB(1:numGen,1:numPop,:))
axis ij
ylabel('Generasi ke-{\it n}')
xlabel('Individu ke-{\it i}')
daspect([1 1 1])