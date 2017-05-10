function drawTest_all(myTrack, setup, ntrack,parameters, stack_count)
color = rand(1, 3);
mu = myTrack(:, 2:3);
axis([1 setup.N(stack_count)*parameters.PixelSize/1000 1 setup.M(stack_count)*parameters.PixelSize/1000]);
plot(mu(:, 2)*parameters.PixelSize/1000, mu(:, 1)*parameters.PixelSize/1000,'Color', color,'LineWidth', 1.5);
hold on;
drawnow;
