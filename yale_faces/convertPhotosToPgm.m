path_current=pwd;

for j=1:15

    cd(strcat('s', sprintf('%02d',j)));

    files=dir('*.gif'); 
    num_files = numel(files);
    
    for k=1:num_files
        image = imread(files(k).name);
        image = imresize(image,0.5);
        nameOfFile = files(k).name(1:(end-3));
        imwrite(image, strcat(nameOfFile, 'pgm'));
    end
    cd(path_current);
end