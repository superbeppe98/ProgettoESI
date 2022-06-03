clear all
close all
clc

list=dir('images/*.jpg');
s='images/';
gh=figure('NumberTitle', 'off', 'Name', 'Galleria');

% Cross-correlazione 2D normalizzata per trovare difetti su tessuti
for index=1:size(list,1)
    % Eseguo una lista for per eseguire l'algoritmo su ogni immagine della
    % cartella images
    name=strcat(s,list(index).name);
    disp(list(index).name)
    A = rgb2gray(imread(name));
    [R,C]=size(A);
    c=0;
    soglia=0;
    
    % Eseguo un ciclo while per ottimizzare la soglia con cui effettuare il
    % filtro
    while (soglia<0.08)
        
        % Definisco una serie di pattern, tutti quadrati 20x20
        hcm = fix(C/2)-20;      % Half columns minus value
        hc  = fix(C/2);         % Half columns
        cm  = C-20;             % Columns minus value
        hrm = fix(R/2)-20;      % Half rows minus value
        hr  = fix(R/2);         % Half rows
        rm  = R-20;             % Rows minus value
        
        randomX1 = 1;
        randomY1 = randi([1 hcm]);
        pattern1 = A(1:20,randomY1:randomY1+19);
        
        randomX2 = 1;
        randomY2 = randi([hc cm]);
        pattern2 = A(1:20,randomY2:randomY2+19);
        
        randomX3 = randi([1 hrm]);
        randomY3 = cm;
        pattern3 = A(randomX3:randomX3+19,randomY3:randomY3+19);
        
        randomX4 = randi([hr rm]);
        randomY4 = cm;
        pattern4 = A(randomX4:randomX4+19,randomY4:randomY4+19);
        
        randomX5 = rm;
        randomY5 = randi([hc cm]);
        pattern5 = A(randomX5:randomX5+19,randomY5:randomY5+19);
        
        randomX6 = rm;
        randomY6 = randi([1 hcm]);
        pattern6 = A(randomX6:randomX6+19,randomY6:randomY6+19);
        
        randomX7 = randi([1 hrm]);
        randomY7 = 1;
        pattern7 = A(randomX7:randomX7+19,1:20);
        
        randomX8 = randi([hr rm]);
        randomY8 = 1;
        pattern8 = A(randomX8:randomX8+19,1:20);
        
        % Calcolo la xcorr-2D (normalizzata). Size = N+M-1
        c1 = normxcorr2(pattern1,A);
        c2 = normxcorr2(pattern2,A);
        c3 = normxcorr2(pattern3,A);
        c4 = normxcorr2(pattern4,A);
        c5 = normxcorr2(pattern5,A);
        c6 = normxcorr2(pattern6,A);
        c7 = normxcorr2(pattern7,A);
        c8 = normxcorr2(pattern8,A);
        
        % Calcolo media
        c = (c1+c2+c3+c4+c5+c6+c7+c8)/8;
        
        % Size(pattern)-1
        c = c(19:end-19,19:end-19);
        c=abs(c);
        
        % Scelta della soglia in modo automatico
        maxC=max(c,[],'all');
        minC=min(c,[],'all');
        soglia=((maxC-minC)/100)*30;
    end
    
    % Effettuiamo il filtraggio con soglia automatica
    disp(soglia);%?!?
    mask = c<soglia;
    
    % Scelta del disco in base alla soglia
    disco=2;
    if(soglia<0.1)
        disco=3;
    end
    if(soglia<0.085)
        disco=4;
    end
    disp(disco);%?!?
    se = strel('disk',disco);
    mask2 = imopen(mask,se);
    
    % Elimino i bordi dell'immagine usati dai pattern
    A=A(9:end-10,9:end-10);
    A1 = A;
    A1(mask2)= 255;
    Af=cat(3,A1,A,A);
    
    % Genero una galleria composta da immagini e rispettive immagini
    % elaborate
    set(gh, 'Position', get(0, 'Screensize'));
    subplot(5, 5, index);
    imshowpair(A,Af,'montage')
    title(list(index).name)
    
    % Visualizzo l'immagine elaborata
    figure('NumberTitle', 'off', 'Name', list(index).name);
    imshowpair(A,Af,'montage')
    
    pause(1.5);
    close(list(index).name);
end
