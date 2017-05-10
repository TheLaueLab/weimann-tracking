function makeavi64bit_real_data(parameters,newY_cell,T,save_dir)

mov=VideoWriter(strcat(save_dir,filesep,'track.avi'));

%Set properties and open object
mov.FrameRate = str2double(parameters.FBS);
open(mov);

nTracks = length(dir(strcat(save_dir,filesep,'track','*.dat')));
Data = cell(nTracks, 1);

    for ii = 1:nTracks,
    fileName = strcat(save_dir,filesep,'track_', num2str(ii), '.dat');
    Data{ii} = load(fileName);
    end

h = waitbar(0,'Making avi file...','Position',[300,100,270,60]);


for t=1:T,
    imagesc(newY_cell(:, :, t));  colormap('gray'); hold on;truesize; hold on;
    for n=1:nTracks,
        track = Data{n};
        seq = track(:, 1);
        P = find(seq == t);
        if ~isempty(P)
            index = P(1);
            name = strcat(' \leftarrow ', num2str(n));
            text(track(index, 3), track(index, 2), name,'FontSize',8,'FontWeight','demi','Color', 'c');
        end
    end
    drawnow;
    currFrame = getframe;
    writeVideo(mov,currFrame);
    hold off;
    waitbar(t/T,h)
end

close(h);

close(mov);