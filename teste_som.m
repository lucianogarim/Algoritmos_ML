clear all
clc

amostra = load('r15.txt');
amostra = amostra(:,1:2);

prompt = 'Qual algoritmo você quer usar?\n ';

disp('1- K-means')
disp('2- SOM + K-means')
disp('3- PCA + K-means')

ent = input(prompt);

prompt = 'Digite 1 para você escolher o número de classes, ou 2 para o algoritmo escolher? \n ';
escolha = input(prompt);

switch escolha
    
    case 1
        prompt = 'Qual o número de classes você quer? \n ';
        k = input(prompt);
    case 2
        E = evalclusters(amostra,'kmeans','silhouette','klist',[1:20]);
        k = E.OptimalK;
    otherwise
        disp('Entrada Inválida')
        return;
end

switch ent
    
    case 1
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                          Aplicação do K-means                          %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if escolha == 1
            % K-means
            [idx,C] = kmeans(amostra,k);
        elseif escolha == 2
                idx = E.OptimalY;
        end
        
        % Visualização
        colormap = vga;
        gscatter(amostra(:,1),amostra(:,2),idx,colormap);
        
    case 2
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %    Aplicação do SOM para redução de dimensão e aplicação do K-means    %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
        
        % SOM
        x = amostra';
        prompt = 'Você quer um mapa SOM 1D ou 2D? \n ';
        map = input(prompt);
        switch map
            case 1
                net = selforgmap([k]);
            case 2
                if isprime(k)==0
                    malha = factor (k);
                else
                    malha = factor (k+1);
                end
                net = selforgmap([malha(1:2)]);
            otherwise
                disp('Entrada Inválida')
                return;
        end
        net = train(net,x);
        y = net(x);
        classes = vec2ind(y);
        
        % K-means
        [idx,C] = kmeans(classes',k);
        
        % Visualização
        colormap = vga;
        gscatter(amostra(:,1),amostra(:,2),idx,colormap);
        
    case 3
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %    Aplicação do PCA para redução de dimensão e aplicação do K-means    %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        S = cov(amostra);
        [vec,val] = eigs(S,size(S,2));
        
        % contribuição de cada componente principal
        soma = 0;
        contr = zeros(size(vec,2));
        for i=1:size(vec,2)
            contr(i) = (val(i,i)/trace(S))*100;
            soma = soma+contr(i);
            if soma>= 70
                break;
            end
        end
        
        Y = amostra*vec(:,1:i);
        
        [idx,C] = kmeans(Y,k);
        
        % Visualização
        colormap = vga;
        
        gscatter(amostra(:,1),amostra(:,2),idx,colormap);        
    otherwise
        disp('Entrada Inválida')
end